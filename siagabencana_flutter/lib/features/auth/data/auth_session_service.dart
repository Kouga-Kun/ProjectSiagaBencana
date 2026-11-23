import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../app/network/api_config.dart';
import 'session_http_client.dart';

class AuthSessionService {
  AuthSessionService({required this.apiConfig, http.Client? client})
    : _client = client ?? createSessionHttpClient(),
      _ownsClient = client == null;

  final ApiConfig apiConfig;
  final http.Client _client;
  final bool _ownsClient;
  String? _csrfToken;

  http.Client get client => _client;

  Future<String> fetchCsrfToken() async {
    await _fetchCsrfToken();
    return _csrfToken!;
  }

  Future<AuthUser?> fetchCurrentUser() async {
    final data = await _request('GET', 'api/auth/status');
    if (data['authenticated'] != true) {
      return null;
    }
    return _userFrom(data['user']);
  }

  Future<AuthUser> fetchProfile() async {
    final data = await _request('GET', 'api/profile');
    return _userFrom(data['user']);
  }

  Future<ProfileUpdateResult> updateProfile({
    required String name,
    required String phone,
    required String address,
    Uint8List? photoBytes,
    String? photoFileName,
  }) async {
    await _fetchCsrfToken();

    final Map<String, dynamic> data;
    if (photoBytes != null &&
        photoBytes.isNotEmpty &&
        photoFileName != null &&
        photoFileName.trim().isNotEmpty) {
      data = await _multipartRequest(
        'api/profile',
        fields: {'name': name, 'phone': phone, 'address': address},
        photoBytes: photoBytes,
        photoFileName: photoFileName,
      );
    } else {
      data = await _request('POST', 'api/profile', {
        'name': name,
        'phone': phone,
        'address': address,
      });
    }

    final updatedUser = _userFrom(data['user']);
    final message =
        data['message'] is String &&
            (data['message'] as String).trim().isNotEmpty
        ? data['message'] as String
        : 'Informasi profil berhasil diperbarui.';

    return ProfileUpdateResult(user: updatedUser, message: message);
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    await _fetchCsrfToken();
    final data = await _request('POST', 'api/auth/login', {
      'email': email,
      'password': password,
    });
    return _confirmSession(data);
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _fetchCsrfToken();
    final data = await _request('POST', 'api/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    return _confirmSession(data);
  }

  Future<void> logout() async {
    await _fetchCsrfToken();
    await _request('POST', 'api/auth/logout');
    if (await fetchCurrentUser() != null) {
      throw const AuthSessionException(
        'Akun belum berhasil keluar. Coba lagi.',
      );
    }
  }

  String? resolveMediaUrl(String? rawUrl) {
    final trimmed = rawUrl?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    final parsed = Uri.tryParse(trimmed);
    if (parsed == null) {
      return trimmed;
    }

    try {
      final pathWithQuery = parsed.hasQuery
          ? '${parsed.path}?${parsed.query}'
          : parsed.path;
      return apiConfig.endpoint(pathWithQuery).toString();
    } catch (_) {
      return trimmed;
    }
  }

  Future<AuthUser> _confirmSession(Map<String, dynamic> response) async {
    final responseUser = _userFrom(response['user']);
    final currentUser = await fetchCurrentUser();
    if (currentUser == null || currentUser.id != responseUser.id) {
      throw const AuthSessionException(
        'Status akun belum dapat dipastikan. Periksa koneksi lalu coba lagi.',
      );
    }
    return currentUser;
  }

  Future<void> _fetchCsrfToken() async {
    final data = await _request('GET', 'api/auth/csrf');
    final token = data['csrf_token'];
    if (token is! String || token.isEmpty) {
      throw const AuthSessionException('Sesi keamanan belum siap. Coba lagi.');
    }
    _csrfToken = token;
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, [
    Map<String, Object?>? body,
  ]) async {
    late final Uri uri;
    try {
      uri = apiConfig.endpoint(path);
    } catch (_) {
      throw const AuthSessionException(
        'Layanan akun belum dapat dijangkau. Coba lagi nanti.',
      );
    }

    try {
      final request = http.Request(method, uri)
        ..headers['Accept'] = 'application/json'
        ..headers['X-Requested-With'] = 'XMLHttpRequest';
      if (body != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(body);
      }
      if (method != 'GET' && _csrfToken != null) {
        request.headers['X-CSRF-TOKEN'] = _csrfToken!;
      }

      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(
        streamed,
      ).timeout(const Duration(seconds: 15));
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const AuthSessionException(
          'Layanan memberikan respons yang tidak dapat dibaca. Coba lagi.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthSessionException(_errorMessage(response.statusCode, decoded));
      }
      return decoded;
    } on AuthSessionException {
      rethrow;
    } on TimeoutException {
      throw const AuthSessionException(
        'Koneksi terlalu lama. Periksa jaringan lalu coba lagi.',
      );
    } on http.ClientException {
      throw const AuthSessionException(
        'Tidak dapat terhubung. Periksa koneksi lalu coba lagi.',
      );
    } on FormatException {
      throw const AuthSessionException(
        'Layanan memberikan respons yang tidak dapat dibaca. Coba lagi.',
      );
    } catch (_) {
      throw const AuthSessionException(
        'Terjadi kendala saat memproses akun. Coba lagi.',
      );
    }
  }

  Future<Map<String, dynamic>> _multipartRequest(
    String path, {
    required Map<String, String> fields,
    required Uint8List photoBytes,
    required String photoFileName,
  }) async {
    late final Uri uri;
    try {
      uri = apiConfig.endpoint(path);
    } catch (_) {
      throw const AuthSessionException(
        'Layanan akun belum dapat dijangkau. Coba lagi nanti.',
      );
    }

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json'
        ..headers['X-Requested-With'] = 'XMLHttpRequest'
        ..fields.addAll(fields);
      if (_csrfToken != null) {
        request.headers['X-CSRF-TOKEN'] = _csrfToken!;
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: photoFileName,
        ),
      );

      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(
        streamed,
      ).timeout(const Duration(seconds: 20));
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const AuthSessionException(
          'Layanan memberikan respons yang tidak dapat dibaca. Coba lagi.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthSessionException(_errorMessage(response.statusCode, decoded));
      }
      return decoded;
    } on AuthSessionException {
      rethrow;
    } on TimeoutException {
      throw const AuthSessionException(
        'Koneksi terlalu lama. Periksa jaringan lalu coba lagi.',
      );
    } on http.ClientException {
      throw const AuthSessionException(
        'Tidak dapat terhubung. Periksa koneksi lalu coba lagi.',
      );
    } on FormatException {
      throw const AuthSessionException(
        'Layanan memberikan respons yang tidak dapat dibaca. Coba lagi.',
      );
    } catch (_) {
      throw const AuthSessionException(
        'Terjadi kendala saat menyimpan perubahan profil. Coba lagi.',
      );
    }
  }

  AuthUser _userFrom(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const AuthSessionException(
        'Informasi akun tidak dapat dibaca. Coba lagi.',
      );
    }
    try {
      final parsed = AuthUser.fromJson(value);
      return parsed.copyWith(
        profilePhotoUrl: resolveMediaUrl(parsed.profilePhotoUrl),
      );
    } on FormatException {
      throw const AuthSessionException(
        'Informasi akun tidak dapat dibaca. Coba lagi.',
      );
    }
  }

  String _errorMessage(int statusCode, Map<String, dynamic> response) {
    final errors = response['errors'];
    if (errors is Map) {
      for (final messages in errors.values) {
        if (messages is List &&
            messages.isNotEmpty &&
            messages.first is String) {
          return messages.first as String;
        }
      }
    }
    if (response['message'] is String) {
      return response['message'] as String;
    }
    return switch (statusCode) {
      401 => 'Sesi akun berakhir. Silakan masuk kembali.',
      419 => 'Sesi keamanan berakhir. Muat ulang lalu coba lagi.',
      429 => 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.',
      _ => 'Permintaan belum berhasil. Periksa data dan coba lagi.',
    };
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}

class ProfileUpdateResult {
  const ProfileUpdateResult({required this.user, required this.message});

  final AuthUser user;
  final String message;
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.profilePhotoUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final email = json['email'];
    final role = json['role'];
    if (id is! num || name is! String || email is! String || role is! String) {
      throw const FormatException('Invalid account response.');
    }

    String? optionalString(Object? raw) {
      if (raw is! String) return null;
      final trimmed = raw.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return AuthUser(
      id: id.toInt(),
      name: name,
      email: email,
      role: role,
      phone: optionalString(json['phone']),
      address: optionalString(json['address']),
      profilePhotoUrl: optionalString(json['profile_photo_url']),
    );
  }

  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String? profilePhotoUrl;

  AuthUser copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? address,
    String? profilePhotoUrl,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}

class AuthSessionException implements Exception {
  const AuthSessionException(this.message);

  final String message;
}
