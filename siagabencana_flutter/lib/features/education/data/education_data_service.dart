import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../app/network/api_config.dart';
import '../../auth/data/auth_session_service.dart';
import 'education_models.dart';
import 'education_seed_data.dart';

export 'education_models.dart';
export 'education_seed_data.dart';

class EducationDataService extends ChangeNotifier {
  EducationDataService({
    String? baseUrl,
    http.Client? client,
    AuthSessionService? authService,
    bool? autoSync,
  }) : _baseUrlOverride = baseUrl,
       _clientOverride = client,
       _authServiceOverride = authService,
       _autoSync = autoSync ?? true;

  static final EducationDataService instance = EducationDataService();

  final String? _baseUrlOverride;
  final http.Client? _clientOverride;
  final AuthSessionService? _authServiceOverride;
  final bool _autoSync;
  bool _isAuthenticated = false;

  void setAuthenticated(bool value) {
    if (_isAuthenticated != value) {
      _isAuthenticated = value;
      notifyListeners();
    }
  }

  List<EducationMaterialItem> _materials = List<EducationMaterialItem>.from(
    EducationSeedData.defaultMaterials,
  );
  List<SimulationItem> _simulations = List<SimulationItem>.from(
    EducationSeedData.defaultSimulations,
  );
  final List<QuizItem> _quizzes = List<QuizItem>.from(
    EducationSeedData.defaultQuizzes,
  );
  List<MissionItem> _missions = List<MissionItem>.from(
    EducationSeedData.defaultMissions,
  );
  final List<BadgeItem> _badges = List<BadgeItem>.from(
    EducationSeedData.defaultBadges,
  );

  bool _isLoading = false;
  String? _statusMessage;

  List<EducationMaterialItem> get materials =>
      List<EducationMaterialItem>.unmodifiable(_materials);
  List<SimulationItem> get simulations =>
      List<SimulationItem>.unmodifiable(_simulations);
  List<QuizItem> get quizzes => List<QuizItem>.unmodifiable(_quizzes);
  List<MissionItem> get missions => List<MissionItem>.unmodifiable(_missions);
  List<BadgeItem> get badges => List<BadgeItem>.unmodifiable(_badges);
  bool get isLoading => _isLoading;
  String? get statusMessage => _statusMessage;

  String get _effectiveBaseUrl {
    final candidate =
        _baseUrlOverride ?? const ApiConfig.fromEnvironment().baseUrl;
    return candidate.trim();
  }

  bool get isRemoteEnabled => _autoSync && _effectiveBaseUrl.isNotEmpty;

  late final http.Client _defaultClient = http.Client();

  http.Client get _client =>
      _clientOverride ?? _authServiceOverride?.client ?? _defaultClient;

  Map<String, String> _buildHeaders({String? csrfToken, bool jsonBody = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };
    if (jsonBody) {
      headers['Content-Type'] = 'application/json';
    }
    if (csrfToken != null && csrfToken.isNotEmpty) {
      headers['X-CSRF-TOKEN'] = csrfToken;
    }
    return headers;
  }

  Future<String?> _fetchCsrfIfPossible() async {
    if (_authServiceOverride != null) {
      try {
        return await _authServiceOverride.fetchCsrfToken();
      } catch (_) {}
    }
    try {
      final res = await _client
          .get(_uri('/api/auth/csrf'), headers: _buildHeaders())
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['csrf_token'] is String) {
          return decoded['csrf_token'] as String;
        }
      }
    } catch (_) {}
    return null;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalizedBase = _effectiveBaseUrl.endsWith('/')
        ? _effectiveBaseUrl.substring(0, _effectiveBaseUrl.length - 1)
        : _effectiveBaseUrl;
    final parsed = Uri.parse('$normalizedBase$path');
    if (query == null || query.isEmpty) {
      return parsed;
    }
    return parsed.replace(queryParameters: query);
  }

  EducationUserProgress get currentProgress {
    final eqDone = _materials
        .where((m) => m.category == 'Gempa Bumi' && m.isCompleted)
        .length;
    final eqTotal = _materials
        .where((m) => m.category == 'Gempa Bumi')
        .length;
    final tsDone = _materials
        .where((m) => m.category == 'Tsunami' && m.isCompleted)
        .length;
    final tsTotal = _materials.where((m) => m.category == 'Tsunami').length;
    final matDone = eqDone + tsDone;
    final matTotal = _materials.length;

    final simDone = _simulations.where((s) => s.isCompleted).length;
    final simTotal = _simulations.length;

    final qzDone = _quizzes.where((q) => q.isCompleted).length;
    final qzTotal = _quizzes.length;

    final eqQuizzesDone = _quizzes
        .where((q) => q.category == 'Gempa Bumi' && q.bestScore != null)
        .toList();
    final tsQuizzesDone = _quizzes
        .where((q) => q.category == 'Tsunami' && q.bestScore != null)
        .toList();

    final eqQuizAvg = eqQuizzesDone.isEmpty
        ? 0
        : (eqQuizzesDone
                      .map((e) => e.bestScore ?? 0)
                      .reduce((a, b) => a + b) /
                  eqQuizzesDone.length)
              .round();
    final tsQuizAvg = tsQuizzesDone.isEmpty
        ? 0
        : (tsQuizzesDone
                      .map((e) => e.bestScore ?? 0)
                      .reduce((a, b) => a + b) /
                  tsQuizzesDone.length)
              .round();

    final msDone = _missions.where((m) => m.userStatus == 'selesai').length;
    final msInProgress = _missions
        .where((m) => m.userStatus == 'sedang_dikerjakan')
        .length;
    final msTotal = _missions.length;

    final eqSimDone = _simulations
        .where((s) => s.category == 'Gempa Bumi' && s.isCompleted)
        .length;
    final tsSimDone = _simulations
        .where((s) => s.category == 'Tsunami' && s.isCompleted)
        .length;
    final highScoreSims = _simulations
        .where((s) => (s.bestScore ?? 0) >= 80)
        .length;

    final evaluatedBadges = _badges.map((b) {
      bool earned = b.isEarned;
      if (b.code == 'siaga-gempa' &&
          eqDone >= 3 &&
          eqSimDone >= 1 &&
          eqQuizzesDone.isNotEmpty) {
        earned = true;
      } else if (b.code == 'siaga-tsunami' &&
          tsDone >= 3 &&
          tsSimDone >= 1 &&
          tsQuizzesDone.isNotEmpty) {
        earned = true;
      } else if (b.code == 'ahli-evakuasi' && highScoreSims >= 2) {
        earned = true;
      } else if (b.code == 'pembelajar-aktif' && matDone >= 6 && qzDone >= 2) {
        earned = true;
      } else if (b.code == 'keluarga-siaga' && msDone >= 3) {
        earned = true;
      }
      return b.copyWith(isEarned: earned);
    }).toList();

    final totalUnits = matTotal + simTotal + qzTotal + msTotal;
    final doneUnits = matDone + simDone + qzDone + msDone;
    final pct = totalUnits > 0 ? ((doneUnits / totalUnits) * 100).round() : 0;

    final matPoints = matDone * 25;
    final simPoints = _simulations.fold<int>(
      0,
      (sum, s) => sum + (s.bestScore ?? 0),
    );
    final qzPoints = _quizzes.fold<int>(
      0,
      (sum, q) => sum + (q.bestScore ?? 0),
    );
    final msPoints = _missions
        .where((m) => m.userStatus == 'selesai')
        .fold<int>(0, (sum, m) => sum + m.points);
    final badgePoints = evaluatedBadges
        .where((b) => b.isEarned)
        .fold<int>(0, (sum, b) => sum + b.pointsReward);

    final totalPoints =
        matPoints + simPoints + qzPoints + msPoints + badgePoints;
    final hasAct = doneUnits > 0 || msInProgress > 0;

    return EducationUserProgress(
      authenticated: _isAuthenticated,
      hasActivity: hasAct,
      initialMessage: hasAct
          ? 'Terus tingkatkan kesiapsiagaanmu dengan menyelesaikan materi, simulasi, kuis, dan Misi Siaga.'
          : 'Belum ada aktivitas pembelajaran. Mulai pelajari materi Gempa Bumi atau Tsunami pertamamu sekarang!',
      overallPercentage: pct,
      totalPoints: totalPoints,
      materialsCompleted: matDone,
      materialsTotal: matTotal,
      earthquakeMaterialsCompleted: eqDone,
      earthquakeMaterialsTotal: eqTotal,
      tsunamiMaterialsCompleted: tsDone,
      tsunamiMaterialsTotal: tsTotal,
      simulationsCompleted: simDone,
      simulationsTotal: simTotal,
      quizzesCompleted: qzDone,
      quizzesTotal: qzTotal,
      earthquakeQuizAverage: eqQuizAvg,
      tsunamiQuizAverage: tsQuizAvg,
      missionsCompleted: msDone,
      missionsTotal: msTotal,
      badges: evaluatedBadges,
    );
  }

  Future<void> refreshAll() async {
    if (!isRemoteEnabled) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final matResponse = await _client
          .get(
            _uri('/api/edukasi/materi'),
            headers: _buildHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (matResponse.statusCode == 200) {
        final decoded = jsonDecode(matResponse.body);
        if (decoded is Map && decoded['data'] is List) {
          final parsed = (decoded['data'] as List)
              .whereType<Map>()
              .map(
                (item) => EducationMaterialItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
          if (parsed.isNotEmpty) {
            _materials = parsed;
          }
        }
      }

      final simResponse = await _client
          .get(
            _uri('/api/edukasi/simulasi'),
            headers: _buildHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (simResponse.statusCode == 200) {
        final decoded = jsonDecode(simResponse.body);
        if (decoded is Map && decoded['data'] is List) {
          final parsed = (decoded['data'] as List)
              .whereType<Map>()
              .map(
                (item) =>
                    SimulationItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
          if (parsed.isNotEmpty) {
            _simulations = parsed;
          }
        }
      }

      final msResponse = await _client
          .get(
            _uri('/api/edukasi/misi'),
            headers: _buildHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (msResponse.statusCode == 200) {
        final decoded = jsonDecode(msResponse.body);
        if (decoded is Map && decoded['data'] is List) {
          final parsed = (decoded['data'] as List)
              .whereType<Map>()
              .map(
                (item) => MissionItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
          if (parsed.isNotEmpty) {
            _missions = parsed;
          }
        }
      }
    } catch (_) {
      // Gunakan dataset bawaan yang sudah disinkronkan apabila jaringan tidak terjangkau
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<EducationMaterialItem> filterMaterials({
    String search = '',
    String category = 'Semua',
    String difficulty = 'Semua',
  }) {
    final kw = search.trim().toLowerCase();
    return _materials.where((item) {
      if (category != 'Semua' && item.category != category) {
        return false;
      }
      if (difficulty != 'Semua' && item.difficulty != difficulty) {
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
    return _materials.isNotEmpty ? _attachSiblings(_materials.first) : null;
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

  Future<String> toggleMaterialCompletion(
    int materialId, {
    bool? completed,
  }) async {
    final idx = _materials.indexWhere((m) => m.id == materialId);
    if (idx < 0) {
      return 'Materi tidak ditemukan.';
    }
    final target = completed ?? !_materials[idx].isCompleted;
    _materials[idx] = _materials[idx].copyWith(isCompleted: target);
    notifyListeners();

    if (isRemoteEnabled) {
      try {
        final csrf = await _fetchCsrfIfPossible();
        final response = await _client
            .post(
              _uri('/api/edukasi/materi/$materialId/selesai'),
              headers: _buildHeaders(
                csrfToken: csrf,
                jsonBody: true,
              ),
              body: jsonEncode({'is_completed': target}),
            )
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] is String) {
            return decoded['message'] as String;
          }
        }
      } catch (_) {}
    }

    return target
        ? 'Materi "${_materials[idx].title}" berhasil ditandai selesai!'
        : 'Tanda selesai materi dibatalkan.';
  }

  Future<void> recordSimulationScore(int simulationId, int score) async {
    final idx = _simulations.indexWhere((s) => s.id == simulationId);
    if (idx >= 0) {
      final existingBest = _simulations[idx].bestScore ?? 0;
      _simulations[idx] = _simulations[idx].copyWith(
        isCompleted: true,
        bestScore: score > existingBest ? score : existingBest,
      );
      notifyListeners();
    }

    if (isRemoteEnabled) {
      try {
        final sim = _simulations.firstWhere((s) => s.id == simulationId);
        final choicesMap = <String, int>{};
        for (final step in sim.steps) {
          if (step.choices.isNotEmpty) {
            final chosen = step.choices.firstWhere(
              (c) => c.isCorrect,
              orElse: () => step.choices.first,
            );
            choicesMap[step.id.toString()] = chosen.id;
          }
        }
        final csrf = await _fetchCsrfIfPossible();
        await _client
            .post(
              _uri('/api/edukasi/simulasi/$simulationId/submit'),
              headers: _buildHeaders(
                csrfToken: csrf,
                jsonBody: true,
              ),
              body: jsonEncode({'choices': choicesMap}),
            )
            .timeout(const Duration(seconds: 10));
      } catch (_) {}
    }
  }

  Future<QuizSubmissionResult> evaluateAndSubmitQuiz(
    QuizItem quiz,
    Map<int, int> selectedOptionIdsByQuestionId,
  ) async {
    int correctCount = 0;
    int wrongCount = 0;
    final reviews = <QuizQuestionReview>[];
    final recommendedSlugs = <String>{};

    for (final q in quiz.questions) {
      final selectedId = selectedOptionIdsByQuestionId[q.id];
      QuizOptionItem? selectedOpt;
      QuizOptionItem? correctOpt;

      for (final opt in q.options) {
        if (opt.id == selectedId) {
          selectedOpt = opt;
        }
        if (opt.isCorrect) {
          correctOpt = opt;
        }
      }

      final isRight = selectedOpt != null && selectedOpt.isCorrect;
      if (isRight) {
        correctCount++;
      } else {
        wrongCount++;
        if (q.recommendedMaterialSlug != null) {
          recommendedSlugs.add(q.recommendedMaterialSlug!);
        }
      }

      reviews.add(
        QuizQuestionReview(
          questionNumber: q.questionNumber,
          subtopic: q.subtopic,
          questionText: q.questionText,
          selectedOptionLabel: selectedOpt?.optionLabel ?? '-',
          selectedOptionText: selectedOpt?.optionText ?? 'Belum dijawab',
          correctOptionLabel: correctOpt?.optionLabel ?? 'A',
          correctOptionText: correctOpt?.optionText ?? '-',
          isCorrect: isRight,
          explanation: q.explanation,
          recommendedMaterialSlug: q.recommendedMaterialSlug,
        ),
      );
    }

    final totalQ = quiz.questions.length;
    final pct = totalQ > 0 ? ((correctCount / totalQ) * 100) : 0.0;
    final score = pct.round();

    final idx = _quizzes.indexWhere((item) => item.id == quiz.id);
    if (idx >= 0) {
      final prevBest = _quizzes[idx].bestScore ?? 0;
      _quizzes[idx] = _quizzes[idx].copyWith(
        isCompleted: true,
        bestScore: score > prevBest ? score : prevBest,
      );
      notifyListeners();
    }

    final recs = _materials
        .where(
          (m) =>
              recommendedSlugs.contains(m.slug) ||
              (recommendedSlugs.isEmpty && m.category == quiz.category),
        )
        .take(3)
        .map(
          (m) => EducationMaterialRef(
            id: m.id,
            title: m.title,
            slug: m.slug,
            category: m.category,
          ),
        )
        .toList();

    if (isRemoteEnabled) {
      try {
        final csrf = await _fetchCsrfIfPossible();
        final payloadAnswers = <String, int>{};
        selectedOptionIdsByQuestionId.forEach((k, v) {
          payloadAnswers[k.toString()] = v;
        });
        await _client
            .post(
              _uri('/api/edukasi/kuis/${quiz.id}/submit'),
              headers: _buildHeaders(
                csrfToken: csrf,
                jsonBody: true,
              ),
              body: jsonEncode({'answers': payloadAnswers}),
            )
            .timeout(const Duration(seconds: 10));
      } catch (_) {}
    }

    return QuizSubmissionResult(
      totalQuestions: totalQ,
      correctAnswers: correctCount,
      wrongAnswers: wrongCount,
      finalScore: score,
      percentage: double.parse(pct.toStringAsFixed(1)),
      reviews: reviews,
      recommendedMaterials: recs,
    );
  }

  Future<String> updateMissionStatus(
    int missionId,
    String newStatus, {
    String? notes,
  }) async {
    final idx = _missions.indexWhere((m) => m.id == missionId);
    if (idx < 0) {
      return 'Misi tidak ditemukan.';
    }

    _missions[idx] = _missions[idx].copyWith(
      userStatus: newStatus,
      notes: notes,
    );
    notifyListeners();

    if (isRemoteEnabled) {
      try {
        final csrf = await _fetchCsrfIfPossible();
        await _client
            .patch(
              _uri('/api/edukasi/misi/$missionId/status'),
              headers: _buildHeaders(
                csrfToken: csrf,
                jsonBody: true,
              ),
              body: jsonEncode({'status': newStatus, 'notes': notes}),
            )
            .timeout(const Duration(seconds: 10));
      } catch (_) {}
    }

    return 'Status misi "${_missions[idx].title}" diperbarui menjadi ${_missions[idx].userStatusLabel}.';
  }
}
