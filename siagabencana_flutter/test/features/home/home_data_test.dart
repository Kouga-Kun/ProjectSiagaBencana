import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:siagabencana_flutter/app/network/api_config.dart';
import 'package:siagabencana_flutter/features/home/data/home_data_service.dart';

void main() {
  group('ApiConfig', () {
    test('resolves endpoint from a configured host', () {
      const config = ApiConfig(baseUrl: 'http://127.0.0.1:8000');
      expect(
        config.endpoint('api/berita').toString(),
        'http://127.0.0.1:8000/api/berita',
      );
    });

    test('rejects missing base URL', () {
      expect(
        () => const ApiConfig(baseUrl: '').endpoint('api/berita'),
        throwsStateError,
      );
    });
  });

  test('HomeDataService requests both Open-Meteo resources', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      if (request.url.host == 'api.open-meteo.com') {
        return http.Response(
          jsonEncode({
            'current': {
              'temperature_2m': 22,
              'weather_code': 3,
              'time': '2026-10-24T10:00',
            },
          }),
          200,
        );
      }
      return http.Response(
        jsonEncode({
          'current': {
            'us_aqi': 42,
            'pm2_5': 8.1,
            'pm10': 12,
            'time': '2026-10-24T10:00',
          },
        }),
        200,
      );
    });
    final service = HomeDataService(
      apiConfig: const ApiConfig(baseUrl: 'https://siagabencana.test'),
      client: client,
    );

    final weather = await service.loadWeather();
    final air = await service.loadAirQuality();

    expect(weather.condition, 'Berawan');
    expect(air.category, 'Baik');
    expect(requests.map((request) => request.url.host), [
      'api.open-meteo.com',
      'air-quality-api.open-meteo.com',
    ]);
    expect(requests.first.headers['Accept'], 'application/json');
    expect(requests.last.url.queryParameters['current'], 'us_aqi,pm2_5,pm10');
    client.close();
  });
}
