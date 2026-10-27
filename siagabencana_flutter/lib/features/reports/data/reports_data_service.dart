import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../app/network/api_config.dart';
import '../../auth/data/auth_session_service.dart';

class ReportsDataService {
  ReportsDataService({
    required this.apiConfig,
    http.Client? client,
    this.authService,
  }) : _client = client ?? authService?.client ?? http.Client(),
       _ownsClient = client == null && authService == null;

  final ApiConfig apiConfig;
  final http.Client _client;
  final bool _ownsClient;
  final AuthSessionService? authService;

  Future<Map<String, dynamic>> loadReports({
    int page = 1,
    Map<String, String> filters = const {},
  }) async {
    final query = <String, String>{'page': page.toString(), ...filters}
      ..removeWhere((key, value) => value.trim().isEmpty);

    final uri = apiConfig
        .endpoint('api/laporan')
        .replace(queryParameters: query);

    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));

    final decoded = _decodeResponse(response);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Respons API laporan bukan objek JSON.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ReportsDataException(
        decoded['message']?.toString() ??
            'Server mengembalikan status ${response.statusCode}.',
      );
    }

    if (decoded['data'] is! List) {
      throw const FormatException(
        'Data laporan tidak ditemukan pada respons API.',
      );
    }

    return decoded;
  }

  Future<Map<String, dynamic>> createReport({
    required Map<String, dynamic> data,
  }) async {
    String? csrfToken;
    if (authService != null) {
      try {
        csrfToken = await authService!.fetchCsrfToken();
      } on AuthSessionException catch (error) {
        throw ReportsDataException(error.message);
      }
    }

    final response = await _client
        .post(
          apiConfig.endpoint('api/laporan'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            if (csrfToken != null && csrfToken.isNotEmpty)
              'X-CSRF-TOKEN': csrfToken,
          },
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 12));

    final decoded = _decodeResponse(response);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Respons pengiriman laporan bukan objek JSON.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errors = decoded['errors'];
      final detail = errors is Map
          ? errors.values
                .expand((value) => value is List ? value : [value])
                .join('\n')
          : decoded['message']?.toString();

      throw ReportsDataException(
        detail?.toString().isNotEmpty == true
            ? detail.toString()
            : 'Gagal mengirim laporan (${response.statusCode}).',
      );
    }

    return decoded;
  }

  dynamic _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw ReportsDataException(
        'Respons server tidak valid (HTTP ${response.statusCode}).',
      );
    }
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}

class ReportsDataException implements Exception {
  const ReportsDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
