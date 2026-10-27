import 'dart:async';
import 'dart:convert';

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
      final response = await http.Response.fromStream(streamed)
          .timeout(const Duration(seconds: 15));
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

  AuthUser _userFrom(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const AuthSessionException(
        'Informasi akun tidak dapat dibaca. Coba lagi.',
      );
    }
    try {
      return AuthUser.fromJson(value);
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

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final email = json['email'];
    final role = json['role'];
    if (id is! num || name is! String || email is! String || role is! String) {
      throw const FormatException('Invalid account response.');
    }
    return AuthUser(id: id.toInt(), name: name, email: email, role: role);
  }

  final int id;
  final String name;
  final String email;
  final String role;
}

class AuthSessionException implements Exception {
  const AuthSessionException(this.message);

  final String message;
}
