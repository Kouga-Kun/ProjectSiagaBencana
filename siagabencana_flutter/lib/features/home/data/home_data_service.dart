import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../app/network/api_config.dart';
import 'bmkg_models.dart';
import 'open_meteo_models.dart';

class HomeDataService {
  HomeDataService({required this.apiConfig, http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final ApiConfig apiConfig;
  final http.Client _client;
  final bool _ownsClient;

  Future<BmkgAlertResponse> loadBmkgAlerts() async {
    final json = await _getJson(apiConfig.endpoint('api/peringatan-bencana'));
    return BmkgAlertResponse.fromJson(json);
  }

  Future<CurrentWeather> loadWeather() async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '-0.9471',
      'longitude': '100.4172',
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,weather_code',
      'timezone': 'Asia/Jakarta',
    });
    return CurrentWeather.fromJson(await _getJson(uri));
  }

  Future<CurrentAirQuality> loadAirQuality() async {
    final uri = Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality', {
      'latitude': '-0.9471',
      'longitude': '100.4172',
      'current': 'us_aqi,pm2_5,pm10',
      'timezone': 'Asia/Jakarta',
    });
    return CurrentAirQuality.fromJson(await _getJson(uri));
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HomeDataException(
        'Layanan mengembalikan status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Respons layanan bukan objek JSON.');
    }
    return decoded;
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}

class HomeDataException implements Exception {
  const HomeDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
