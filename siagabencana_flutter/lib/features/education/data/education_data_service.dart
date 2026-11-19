import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../app/network/api_config.dart';
import '../../auth/data/auth_session_service.dart';
import 'education_models.dart';

export 'education_models.dart';

class EducationDataException implements Exception {
  const EducationDataException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class EducationDataService extends ChangeNotifier {
  EducationDataService({
    ApiConfig? apiConfig,
    http.Client? client,
    this.authService,
    this.onUnauthorized,
  }) : _apiConfig = apiConfig ?? const ApiConfig.fromEnvironment(),
       _clientOverride = client;

  final ApiConfig _apiConfig;
  final http.Client? _clientOverride;
  final AuthSessionService? authService;
  final VoidCallback? onUnauthorized;

  AuthUser? _currentUser;
  List<EducationMaterialItem> _materials = const <EducationMaterialItem>[];
  List<SimulationItem> _simulations = const <SimulationItem>[];
  List<QuizItem> _quizzes = const <QuizItem>[];
  List<MissionItem> _missions = const <MissionItem>[];
  EducationUserProgress _progress = EducationUserProgress.empty;

  bool _isLoading = false;
  String? _loadError;
  SaveSyncStatus _saveStatus = SaveSyncStatus.idle;
  String? _saveStatusMessage;
  Future<void> Function()? _pendingRetryAction;

  Timer? _materialSaveDebounce;
  Timer? _simulationDraftDebounce;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  List<EducationMaterialItem> get materials =>
      List<EducationMaterialItem>.unmodifiable(_materials);
  List<SimulationItem> get simulations =>
      List<SimulationItem>.unmodifiable(_simulations);
  List<QuizItem> get quizzes => List<QuizItem>.unmodifiable(_quizzes);
  List<MissionItem> get missions => List<MissionItem>.unmodifiable(_missions);
  EducationUserProgress get currentProgress => _progress;
  bool get isLoading => _isLoading;
  String? get loadError => _loadError;
  SaveSyncStatus get saveStatus => _saveStatus;
  String? get saveStatusMessage => _saveStatusMessage;
  bool get hasPendingRetry => _pendingRetryAction != null;

  http.Client get _client =>
      _clientOverride ?? authService?.client ?? http.Client();

  /// Bind the active authenticated user. Switches accounts cleanly without leaking prior user data.
  void bindUser(AuthUser? user) {
    if (user == null) {
      clearSession();
      return;
    }

    final changed = _currentUser?.id != user.id;
    _currentUser = user;
    if (changed) {
      _resetInMemoryData();
      notifyListeners();
      unawaited(refreshAll());
    }
  }

  /// Clear all in-memory user data on logout without deleting anything in Laravel DB.
  void clearSession() {
    _materialSaveDebounce?.cancel();
    _simulationDraftDebounce?.cancel();
    _currentUser = null;
    _resetInMemoryData();
    notifyListeners();
  }

  void _resetInMemoryData() {
    _materials = const <EducationMaterialItem>[];
    _simulations = const <SimulationItem>[];
    _quizzes = const <QuizItem>[];
    _missions = const <MissionItem>[];
    _progress = EducationUserProgress.empty;
    _loadError = null;
    _saveStatus = SaveSyncStatus.idle;
    _saveStatusMessage = null;
    _pendingRetryAction = null;
  }

  @override
  void dispose() {
    _materialSaveDebounce?.cancel();
    _simulationDraftDebounce?.cancel();
    super.dispose();
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    final endpoint = _apiConfig.endpoint(normalized);
    if (query == null || query.isEmpty) {
      return endpoint;
    }
    return endpoint.replace(queryParameters: query);
  }

  Map<String, String> _headers({String? csrfToken, bool jsonBody = false}) {
    return <String, String>{
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      if (jsonBody) 'Content-Type': 'application/json',
      if (csrfToken != null && csrfToken.isNotEmpty) 'X-CSRF-TOKEN': csrfToken,
    };
  }

  Future<String?> _fetchCsrfToken() async {
    if (authService != null) {
      return authService!.fetchCsrfToken();
    }
    final res = await _client
        .get(_uri('api/auth/csrf'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map && decoded['csrf_token'] is String) {
        return decoded['csrf_token'] as String;
      }
    }
    return null;
  }

  Map<String, dynamic> _decodeJsonOrThrow(http.Response response) {
    if (response.statusCode == 401) {
      clearSession();
      onUnauthorized?.call();
      throw const EducationDataException(
        'Sesi login Anda berakhir. Silakan masuk kembali untuk mengakses Edukasi Bencana.',
        statusCode: 401,
      );
    }

    if (response.statusCode == 403) {
      throw const EducationDataException(
        'Akses ditolak. Anda tidak memiliki izin untuk operasi ini.',
        statusCode: 403,
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw EducationDataException(
        'Respons server tidak dapat dibaca (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw EducationDataException(
        'Format respons server tidak valid (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw EducationDataException(
        decoded['message']?.toString() ??
            'Permintaan gagal (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  Future<void> refreshAll() async {
    if (_currentUser == null) {
      return;
    }

    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      final results = await Future.wait<http.Response>([
        _client
            .get(_uri('api/edukasi/materi'), headers: _headers())
            .timeout(const Duration(seconds: 12)),
        _client
            .get(_uri('api/edukasi/simulasi'), headers: _headers())
            .timeout(const Duration(seconds: 12)),
        _client
            .get(_uri('api/edukasi/kuis'), headers: _headers())
            .timeout(const Duration(seconds: 12)),
        _client
            .get(_uri('api/edukasi/misi'), headers: _headers())
            .timeout(const Duration(seconds: 12)),
        _client
            .get(_uri('api/edukasi/progres'), headers: _headers())
            .timeout(const Duration(seconds: 12)),
      ]);

      final matJson = _decodeJsonOrThrow(results[0]);
      final simJson = _decodeJsonOrThrow(results[1]);
      final quizJson = _decodeJsonOrThrow(results[2]);
      final missionJson = _decodeJsonOrThrow(results[3]);
      final progJson = _decodeJsonOrThrow(results[4]);

      if (matJson['data'] is List) {
        _materials = (matJson['data'] as List)
            .whereType<Map>()
            .map(
              (item) => EducationMaterialItem.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      if (simJson['data'] is List) {
        _simulations = (simJson['data'] as List)
            .whereType<Map>()
            .map(
              (item) =>
                  SimulationItem.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      if (quizJson['data'] is List) {
        _quizzes = (quizJson['data'] as List)
            .whereType<Map>()
            .map((item) => QuizItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }

      if (missionJson['data'] is List) {
        _missions = (missionJson['data'] as List)
            .whereType<Map>()
            .map(
              (item) => MissionItem.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      if (progJson['data'] is Map) {
        _progress = EducationUserProgress.fromJson(
          Map<String, dynamic>.from(progJson['data'] as Map),
        );
      }

      _loadError = null;
    } on EducationDataException catch (e) {
      _loadError = e.message;
    } catch (_) {
      _loadError =
          'Tidak dapat terhubung ke server Edukasi Bencana. Periksa koneksi jaringan lalu coba muat ulang.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<EducationMaterialItem> filterMaterials({
    String search = '',
    String category = 'Semua',
    String difficulty = 'Semua',
    bool favoritesOnly = false,
  }) {
    final kw = search.trim().toLowerCase();
    return _materials.where((item) {
      if (category != 'Semua' && item.category != category) {
        return false;
      }
      if (difficulty != 'Semua' && item.difficulty != difficulty) {
        return false;
      }
      if (favoritesOnly && !item.isFavorite) {
        return false;
      }
      if (kw.isNotEmpty) {
        final inTitle = item.title.toLowerCase().contains(kw);
        final inSummary = item.summary.toLowerCase().contains(kw);
        final inContent = item.content.toLowerCase().contains(kw);
        if (!inTitle && !inSummary && !inContent) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  EducationMaterialItem? findMaterialBySlugOrId(String slugOrId) {
    for (final item in _materials) {
      if (item.slug == slugOrId || item.id.toString() == slugOrId) {
        return _attachSiblings(item);
      }
    }
    return null;
  }

  Future<EducationMaterialItem> fetchMaterialDetail(String slugOrId) async {
    final res = await _client
        .get(_uri('api/edukasi/materi/$slugOrId'), headers: _headers())
        .timeout(const Duration(seconds: 12));
    final decoded = _decodeJsonOrThrow(res);
    final item = EducationMaterialItem.fromJson(
      Map<String, dynamic>.from(decoded['data'] as Map),
    );
    _upsertLocalMaterial(item);
    notifyListeners();
    return item;
  }

  EducationMaterialItem _attachSiblings(EducationMaterialItem current) {
    final siblings = _materials
        .where((m) => m.category == current.category)
        .toList();
    final idx = siblings.indexWhere((m) => m.id == current.id);
    final prev = (idx > 0)
        ? EducationMaterialRef(
            id: siblings[idx - 1].id,
            title: siblings[idx - 1].title,
            slug: siblings[idx - 1].slug,
            category: siblings[idx - 1].category,
          )
        : null;
    final next = (idx >= 0 && idx < siblings.length - 1)
        ? EducationMaterialRef(
            id: siblings[idx + 1].id,
            title: siblings[idx + 1].title,
            slug: siblings[idx + 1].slug,
            category: siblings[idx + 1].category,
          )
        : null;
    return current.copyWith(previousMaterial: prev, nextMaterial: next);
  }

  void _upsertLocalMaterial(EducationMaterialItem updated) {
    final idx = _materials.indexWhere((m) => m.id == updated.id);
    if (idx >= 0) {
      final list = List<EducationMaterialItem>.from(_materials);
      list[idx] = updated;
      _materials = list;
    }
  }

  /// Debounced auto-save for reading position / section / favorite.
  void scheduleMaterialProgressSave(
    int materialId, {
    int? lastPosition,
    String? lastSection,
    int? progressPercent,
    bool? isFavorite,
  }) {
    if (_currentUser == null) {
      return;
    }
    _materialSaveDebounce?.cancel();
    _materialSaveDebounce = Timer(const Duration(milliseconds: 850), () {
      unawaited(
        saveMaterialProgressNow(
          materialId,
          lastPosition: lastPosition,
          lastSection: lastSection,
          progressPercent: progressPercent,
          isFavorite: isFavorite,
        ),
      );
    });
  }

  Future<bool> saveMaterialProgressNow(
    int materialId, {
    int? lastPosition,
    String? lastSection,
    int? progressPercent,
    bool? isFavorite,
  }) async {
    if (_currentUser == null) {
      return false;
    }

    _saveStatus = SaveSyncStatus.saving;
    _saveStatusMessage = 'Sedang menyimpan progres membaca...';
    notifyListeners();

    final payload = <String, dynamic>{
      'last_position': ?lastPosition,
      'last_section': ?lastSection,
      'progress_percent': ?progressPercent,
      'is_favorite': ?isFavorite,
    };

    try {
      final csrf = await _fetchCsrfToken();
      final res = await _client
          .post(
            _uri('api/edukasi/materi/$materialId/progres'),
            headers: _headers(csrfToken: csrf, jsonBody: true),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 12));

      final decoded = _decodeJsonOrThrow(res);
      final data = decoded['data'] is Map
          ? Map<String, dynamic>.from(decoded['data'] as Map)
          : const <String, dynamic>{};

      final idx = _materials.indexWhere((m) => m.id == materialId);
      if (idx >= 0) {
        final list = List<EducationMaterialItem>.from(_materials);
        list[idx] = list[idx].copyWith(
          isFavorite: data['is_favorite'] == true,
          lastPosition: (data['last_position'] as num?)?.toInt() ??
              list[idx].lastPosition,
          lastSection: data['last_section']?.toString() ?? list[idx].lastSection,
          progressPercent: (data['progress_percent'] as num?)?.toInt() ??
              list[idx].progressPercent,
          lastReadAt: data['last_read_at']?.toString(),
        );
        _materials = list;
      }

      _saveStatus = SaveSyncStatus.saved;
      _saveStatusMessage = 'Progres tersimpan otomatis';
      _pendingRetryAction = null;
      notifyListeners();
      return true;
    } catch (e) {
      _saveStatus = SaveSyncStatus.error;
      _saveStatusMessage = e is EducationDataException
          ? e.message
          : 'Gagal menyimpan progres (koneksi terputus). Ketuk Coba Lagi.';
      _pendingRetryAction = () async {
        await saveMaterialProgressNow(
          materialId,
          lastPosition: lastPosition,
          lastSection: lastSection,
          progressPercent: progressPercent,
          isFavorite: isFavorite,
        );
      };
      notifyListeners();
      return false;
    }
  }

  /// Marks material complete ONLY AFTER backend confirms HTTP 200.
  Future<String> toggleMaterialCompletion(
    int materialId, {
    bool? completed,
  }) async {
    if (_currentUser == null) {
      throw const EducationDataException(
        'Login diperlukan untuk menyimpan penyelesaian materi.',
        statusCode: 401,
      );
    }

    final idx = _materials.indexWhere((m) => m.id == materialId);
    final currentCompleted = idx >= 0 ? _materials[idx].isCompleted : false;
    final target = completed ?? !currentCompleted;

    _saveStatus = SaveSyncStatus.saving;
    _saveStatusMessage = 'Menyimpan status materi ke server...';
    notifyListeners();

    try {
      final csrf = await _fetchCsrfToken();
      final res = await _client
          .post(
            _uri('api/edukasi/materi/$materialId/selesai'),
            headers: _headers(csrfToken: csrf, jsonBody: true),
            body: jsonEncode({'is_completed': target}),
          )
          .timeout(const Duration(seconds: 12));

      final decoded = _decodeJsonOrThrow(res);
      final serverCompleted = decoded['is_completed'] == true;

      if (idx >= 0) {
        final list = List<EducationMaterialItem>.from(_materials);
        list[idx] = list[idx].copyWith(
          isCompleted: serverCompleted,
          progressPercent: serverCompleted ? 100 : list[idx].progressPercent,
          lastPosition: serverCompleted ? 100 : list[idx].lastPosition,
        );
        _materials = list;
      }

      if (decoded['progress'] is Map) {
        _progress = EducationUserProgress.fromJson(
          Map<String, dynamic>.from(decoded['progress'] as Map),
        );
      }

      _saveStatus = SaveSyncStatus.saved;
      _saveStatusMessage = 'Tersimpan di server';
      _pendingRetryAction = null;
      notifyListeners();

      return decoded['message']?.toString() ??
          (serverCompleted
              ? 'Materi berhasil ditandai selesai!'
              : 'Penanda selesai dibatalkan.');
    } catch (e) {
      _saveStatus = SaveSyncStatus.error;
      _saveStatusMessage = e is EducationDataException
          ? e.message
          : 'Gagal menyimpan status materi. Status belum diubah. Coba lagi.';
      _pendingRetryAction = () async {
        await toggleMaterialCompletion(materialId, completed: target);
      };
      notifyListeners();
      rethrow;
    }
  }

  /// Debounced auto-save for in-progress simulation state.
  void scheduleSimulationDraftSave(
    int simulationId, {
    required int currentStepIndex,
    required Map<int, int> selectedChoices,
  }) {
    if (_currentUser == null) {
      return;
    }
    _simulationDraftDebounce?.cancel();
    _simulationDraftDebounce = Timer(const Duration(milliseconds: 700), () {
      unawaited(
        saveSimulationDraftNow(
          simulationId,
          currentStepIndex: currentStepIndex,
          selectedChoices: selectedChoices,
        ),
      );
    });
  }

  Future<bool> saveSimulationDraftNow(
    int simulationId, {
    required int currentStepIndex,
    required Map<int, int> selectedChoices,
  }) async {
    if (_currentUser == null) {
      return false;
    }

    _saveStatus = SaveSyncStatus.saving;
    _saveStatusMessage = 'Menyimpan tahapan simulasi...';
    notifyListeners();

    final encodedChoices = <String, int>{};
    selectedChoices.forEach((stepId, choiceId) {
      encodedChoices[stepId.toString()] = choiceId;
    });

    try {
      final csrf = await _fetchCsrfToken();
      final res = await _client
          .post(
            _uri('api/edukasi/simulasi/$simulationId/progres'),
            headers: _headers(csrfToken: csrf, jsonBody: true),
            body: jsonEncode({
              'current_step_index': currentStepIndex,
              'selected_choices': encodedChoices,
            }),
          )
          .timeout(const Duration(seconds: 12));

      final decoded = _decodeJsonOrThrow(res);
      final draft = decoded['draft'] is Map
          ? SimulationDraftData.fromJson(
              Map<String, dynamic>.from(decoded['draft'] as Map),
            )
          : null;

      final idx = _simulations.indexWhere((s) => s.id == simulationId);
      if (idx >= 0 && draft != null) {
        final list = List<SimulationItem>.from(_simulations);
        list[idx] = list[idx].copyWith(draft: draft);
        _simulations = list;
      }

      _saveStatus = SaveSyncStatus.saved;
      _saveStatusMessage = 'Tahapan simulasi tersimpan';
      _pendingRetryAction = null;
      notifyListeners();
      return true;
    } catch (e) {
      _saveStatus = SaveSyncStatus.error;
      _saveStatusMessage = e is EducationDataException
          ? e.message
          : 'Gagal menyimpan draf simulasi. Data sementara dipertahankan.';
      _pendingRetryAction = () async {
        await saveSimulationDraftNow(
          simulationId,
          currentStepIndex: currentStepIndex,
          selectedChoices: selectedChoices,
        );
      };
      notifyListeners();
      return false;
    }
  }

  /// Submits actual user choices to Laravel for backend scoring & idempotent persistence.
  Future<SimulationSubmissionResult> submitSimulation(
    int simulationId,
    Map<int, int> choicesByStepId, {
    required String clientSubmissionId,
  }) async {
    if (_currentUser == null) {
      throw const EducationDataException(
        'Login diperlukan untuk menyimpan hasil simulasi.',
        statusCode: 401,
      );
    }

    _saveStatus = SaveSyncStatus.saving;
    _saveStatusMessage = 'Menilai & menyimpan hasil simulasi...';
    notifyListeners();

    final encodedChoices = <String, int>{};
    choicesByStepId.forEach((stepId, choiceId) {
      encodedChoices[stepId.toString()] = choiceId;
    });

    try {
      final csrf = await _fetchCsrfToken();
      final res = await _client
          .post(
            _uri('api/edukasi/simulasi/$simulationId/submit'),
            headers: _headers(csrfToken: csrf, jsonBody: true),
            body: jsonEncode({
              'choices': encodedChoices,
              'client_submission_id': clientSubmissionId,
            }),
          )
          .timeout(const Duration(seconds: 12));

      final decoded = _decodeJsonOrThrow(res);
      final resultMap = Map<String, dynamic>.from(decoded['result'] as Map);
      final submission = SimulationSubmissionResult.fromJson(
        resultMap,
        idempotentReplay: decoded['idempotent_replay'] == true,
      );

      final idx = _simulations.indexWhere((s) => s.id == simulationId);
      if (idx >= 0) {
        final list = List<SimulationItem>.from(_simulations);
        final prevBest = list[idx].bestScore ?? 0;
        list[idx] = list[idx].copyWith(
          isCompleted: true,
          bestScore: submission.score > prevBest ? submission.score : prevBest,
          latestScore: submission.score,
          attemptsCount: list[idx].attemptsCount + (submission.idempotentReplay ? 0 : 1),
          clearDraft: true,
        );
        _simulations = list;
      }

      if (decoded['progress'] is Map) {
        _progress = EducationUserProgress.fromJson(
          Map<String, dynamic>.from(decoded['progress'] as Map),
        );
      }

      _saveStatus = SaveSyncStatus.saved;
      _saveStatusMessage = 'Hasil simulasi tersimpan';
      _pendingRetryAction = null;
      notifyListeners();
      return submission;
    } catch (e) {
      _saveStatus = SaveSyncStatus.error;
      _saveStatusMessage = e is EducationDataException
          ? e.message
          : 'Gagal mengirim hasil simulasi. Data pilihan dipertahankan — tekan Coba Lagi.';
      notifyListeners();
      rethrow;
    }
  }

  /// Fetch quiz questions from backend (never includes is_correct or explanation).
  Future<QuizItem> fetchQuizDetail(String slugOrId) async {
    final res = await _client
        .get(_uri('api/edukasi/kuis/$slugOrId'), headers: _headers())
        .timeout(const Duration(seconds: 12));
    final decoded = _decodeJsonOrThrow(res);
    return QuizItem.fromJson(Map<String, dynamic>.from(decoded['data'] as Map));
  }

  /// Submit quiz answers to Laravel backend for authoritative grading & history persistence.
  Future<QuizSubmissionResult> submitQuiz(
    QuizItem quiz,
    Map<int, int> selectedOptionIdsByQuestionId, {
    required String clientSubmissionId,
  }) async {
    if (_currentUser == null) {
      throw const EducationDataException(
        'Login diperlukan untuk mengirim hasil kuis.',
        statusCode: 401,
      );
    }

    _saveStatus = SaveSyncStatus.saving;
    _saveStatusMessage = 'Menilai & menyimpan hasil kuis di server...';
    notifyListeners();

    final payloadAnswers = <String, int>{};
    selectedOptionIdsByQuestionId.forEach((questionId, optionId) {
      payloadAnswers[questionId.toString()] = optionId;
    });

    try {
      final csrf = await _fetchCsrfToken();
      final res = await _client
          .post(
            _uri('api/edukasi/kuis/${quiz.id}/submit'),
            headers: _headers(csrfToken: csrf, jsonBody: true),
            body: jsonEncode({
              'answers': payloadAnswers,
              'client_submission_id': clientSubmissionId,
            }),
          )
          .timeout(const Duration(seconds: 12));

      final decoded = _decodeJsonOrThrow(res);
      final resultMap = Map<String, dynamic>.from(decoded['result'] as Map);
      final submission = QuizSubmissionResult.fromJson(resultMap);

      final idx = _quizzes.indexWhere((q) => q.id == quiz.id);
      if (idx >= 0) {
        final list = List<QuizItem>.from(_quizzes);
        list[idx] = list[idx].copyWith(
          isCompleted: true,
          bestScore: submission.bestScore ?? submission.finalScore,
          latestScore: submission.latestScore ?? submission.finalScore,
          attemptsCount: submission.attemptsCount,
        );
        _quizzes = list;
      }

      if (decoded['progress'] is Map) {
        _progress = EducationUserProgress.fromJson(
          Map<String, dynamic>.from(decoded['progress'] as Map),
        );
      }

      _saveStatus = SaveSyncStatus.saved;
      _saveStatusMessage = 'Hasil kuis berhasil dinilai & disimpan';
      _pendingRetryAction = null;
      notifyListeners();
      return submission;
    } catch (e) {
      _saveStatus = SaveSyncStatus.error;
      _saveStatusMessage = e is EducationDataException
          ? e.message
          : 'Gagal mengirim jawaban kuis. Jawabanmu tetap tersimpan sementara — tekan Coba Lagi.';
      notifyListeners();
      rethrow;
    }
  }

  /// Updates mission status ONLY AFTER backend confirms HTTP 200.
  Future<String> updateMissionStatus(
    int missionId,
    String newStatus, {
    String? notes,
  }) async {
    if (_currentUser == null) {
      throw const EducationDataException(
        'Login diperlukan untuk memperbarui Misi Siaga.',
        statusCode: 401,
      );
    }

    _saveStatus = SaveSyncStatus.saving;
    _saveStatusMessage = 'Menyimpan status Misi Siaga...';
    notifyListeners();

    try {
      final csrf = await _fetchCsrfToken();
      final res = await _client
          .patch(
            _uri('api/edukasi/misi/$missionId/status'),
            headers: _headers(csrfToken: csrf, jsonBody: true),
            body: jsonEncode({
              'status': newStatus,
              'notes': ?notes,
            }),
          )
          .timeout(const Duration(seconds: 12));

      final decoded = _decodeJsonOrThrow(res);
      if (decoded['data'] is Map) {
        final updatedMission = MissionItem.fromJson(
          Map<String, dynamic>.from(decoded['data'] as Map),
        );
        final idx = _missions.indexWhere((m) => m.id == missionId);
        if (idx >= 0) {
          final list = List<MissionItem>.from(_missions);
          list[idx] = updatedMission;
          _missions = list;
        }
      }

      if (decoded['progress'] is Map) {
        _progress = EducationUserProgress.fromJson(
          Map<String, dynamic>.from(decoded['progress'] as Map),
        );
      }

      _saveStatus = SaveSyncStatus.saved;
      _saveStatusMessage = 'Status Misi Siaga tersimpan';
      _pendingRetryAction = null;
      notifyListeners();

      return decoded['message']?.toString() ?? 'Status Misi Siaga diperbarui.';
    } catch (e) {
      _saveStatus = SaveSyncStatus.error;
      _saveStatusMessage = e is EducationDataException
          ? e.message
          : 'Gagal memperbarui status misi. Coba lagi.';
      _pendingRetryAction = () async {
        await updateMissionStatus(missionId, newStatus, notes: notes);
      };
      notifyListeners();
      rethrow;
    }
  }

  Future<String> updateReminderPreference(ReminderPreference pref) async {
    if (_currentUser == null) {
      throw const EducationDataException(
        'Login diperlukan untuk menyimpan pengaturan pengingat.',
        statusCode: 401,
      );
    }

    _saveStatus = SaveSyncStatus.saving;
    _saveStatusMessage = 'Menyimpan pengaturan pengingat...';
    notifyListeners();

    try {
      final csrf = await _fetchCsrfToken();
      final res = await _client
          .put(
            _uri('api/edukasi/pengingat'),
            headers: _headers(csrfToken: csrf, jsonBody: true),
            body: jsonEncode(pref.toJson()),
          )
          .timeout(const Duration(seconds: 12));

      final decoded = _decodeJsonOrThrow(res);
      await refreshAll();

      _saveStatus = SaveSyncStatus.saved;
      _saveStatusMessage = 'Pengaturan pengingat tersimpan';
      _pendingRetryAction = null;
      notifyListeners();
      return decoded['message']?.toString() ??
          'Pengaturan pengingat berhasil disimpan.';
    } catch (e) {
      _saveStatus = SaveSyncStatus.error;
      _saveStatusMessage = e is EducationDataException
          ? e.message
          : 'Gagal menyimpan pengaturan pengingat.';
      _pendingRetryAction = () async {
        await updateReminderPreference(pref);
      };
      notifyListeners();
      rethrow;
    }
  }

  Future<void> retryLastSave() async {
    final action = _pendingRetryAction;
    if (action != null) {
      await action();
    }
  }

  String generateClientSubmissionId(String prefix, int entityId) {
    final userPart = _currentUser?.id ?? 0;
    final ts = DateTime.now().microsecondsSinceEpoch;
    return '$prefix-$userPart-$entityId-$ts';
  }
}
