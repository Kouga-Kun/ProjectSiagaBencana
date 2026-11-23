import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../app/network/api_config.dart';
import '../../auth/data/auth_session_service.dart';

class SosDataService {
  SosDataService({
    required this.apiConfig,
    http.Client? client,
    this.authService,
  }) : _client = client ?? authService?.client ?? http.Client(),
       _ownsClient = client == null && authService == null;

  final ApiConfig apiConfig;
  final http.Client _client;
  final bool _ownsClient;
  final AuthSessionService? authService;

  Future<List<SosRequestItem>> fetchUserHistory() async {
    late final Uri uri;
    try {
      uri = apiConfig.endpoint('api/sos/riwayat');
    } catch (_) {
      throw const SosDataException(
        'Layanan SOS belum dapat dijangkau. Periksa konfigurasi API_BASE_URL.',
      );
    }

    try {
      final response = await _client
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
            },
          )
          .timeout(const Duration(seconds: 15));

      final decoded = _decodeJson(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SosDataException(_extractError(response.statusCode, decoded));
      }

      final rawList = decoded['data'];
      if (rawList is! List) {
        throw const SosDataException(
          'Format riwayat SOS dari server tidak valid.',
        );
      }

      return rawList
          .whereType<Map>()
          .map(
            (item) => SosRequestItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on SosDataException {
      rethrow;
    } on TimeoutException {
      throw const SosDataException(
        'Waktu koneksi ke server habis saat memuat riwayat SOS.',
      );
    } catch (_) {
      throw const SosDataException(
        'Tidak dapat memuat riwayat permintaan SOS. Coba lagi.',
      );
    }
  }

  Future<SosSubmissionResult> submitSosRequest({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    String? csrfToken;
    if (authService != null) {
      try {
        csrfToken = await authService!.fetchCsrfToken();
      } on AuthSessionException catch (error) {
        throw SosDataException(error.message);
      }
    }

    late final Uri uri;
    try {
      uri = apiConfig.endpoint('api/sos');
    } catch (_) {
      throw const SosDataException(
        'Layanan SOS belum dapat dijangkau. Periksa konfigurasi API_BASE_URL.',
      );
    }

    final payload = <String, Object?>{
      'latitude': latitude,
      'longitude': longitude,
      if (address != null && address.trim().isNotEmpty)
        'address': address.trim(),
    };

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
              if (csrfToken != null && csrfToken.isNotEmpty)
                'X-CSRF-TOKEN': csrfToken,
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      final decoded = _decodeJson(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SosDataException(_extractError(response.statusCode, decoded));
      }

      final rawItem = decoded['data'];
      if (rawItem is! Map) {
        throw const SosDataException(
          'Respons penyimpanan SOS dari server tidak valid.',
        );
      }

      final item = SosRequestItem.fromJson(Map<String, dynamic>.from(rawItem));
      final message =
          decoded['message'] is String &&
              (decoded['message'] as String).trim().isNotEmpty
          ? decoded['message'] as String
          : 'Permintaan SOS berhasil disimpan ke sistem dengan status Menunggu.';

      return SosSubmissionResult(item: item, message: message);
    } on SosDataException {
      rethrow;
    } on TimeoutException {
      throw const SosDataException(
        'Koneksi terlalu lama saat mengirim permintaan SOS. Coba lagi.',
      );
    } catch (_) {
      throw const SosDataException(
        'Terjadi kendala saat mengirim permintaan SOS. Coba lagi.',
      );
    }
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw const FormatException('Not a JSON object');
    } on FormatException {
      throw SosDataException(
        'Server mengembalikan respons yang tidak dapat dibaca (HTTP ${response.statusCode}).',
      );
    }
  }

  String _extractError(int statusCode, Map<String, dynamic> response) {
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
    if (response['message'] is String &&
        (response['message'] as String).trim().isNotEmpty) {
      return response['message'] as String;
    }
    return switch (statusCode) {
      401 => 'Sesi akun berakhir. Silakan login kembali.',
      419 => 'Sesi keamanan berakhir. Muat ulang lalu coba lagi.',
      _ => 'Permintaan SOS belum berhasil diproses ($statusCode).',
    };
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}

class SosSubmissionResult {
  const SosSubmissionResult({required this.item, required this.message});

  final SosRequestItem item;
  final String message;
}

class SosRequestItem {
  const SosRequestItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.status,
    required this.statusLabel,
    required this.createdAt,
    this.handlerName,
    this.handledAt,
  });

  factory SosRequestItem.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt() ?? 0;
    final userId = (json['user_id'] as num?)?.toInt() ?? 0;
    final userName = json['user_name']?.toString() ?? '-';
    final rawPhone = json['user_phone']?.toString().trim();
    final latitude = (json['latitude'] as num?)?.toDouble() ?? 0.0;
    final longitude = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    final rawAddress = json['address']?.toString().trim();
    final status = (json['status']?.toString() ?? 'menunggu').toLowerCase();
    final statusLabel =
        json['status_label']?.toString() ??
        switch (status) {
          'diproses' => 'Diproses',
          'selesai' => 'Selesai',
          _ => 'Menunggu',
        };
    final createdAt = DateTime.tryParse(json['created_at']?.toString() ?? '');
    final handledAt = DateTime.tryParse(json['handled_at']?.toString() ?? '');
    final rawHandler = json['handler_name']?.toString().trim();

    return SosRequestItem(
      id: id,
      userId: userId,
      userName: userName,
      userPhone: (rawPhone == null || rawPhone.isEmpty) ? null : rawPhone,
      latitude: latitude,
      longitude: longitude,
      address: (rawAddress == null || rawAddress.isEmpty) ? null : rawAddress,
      status: status,
      statusLabel: statusLabel,
      createdAt: createdAt,
      handlerName: (rawHandler == null || rawHandler.isEmpty)
          ? null
          : rawHandler,
      handledAt: handledAt,
    );
  }

  final int id;
  final int userId;
  final String userName;
  final String? userPhone;
  final double latitude;
  final double longitude;
  final String? address;
  final String status;
  final String statusLabel;
  final DateTime? createdAt;
  final String? handlerName;
  final DateTime? handledAt;
}

class SosDataException implements Exception {
  const SosDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
