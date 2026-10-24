import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:siagabencana_flutter/app/network/api_config.dart';
import 'package:siagabencana_flutter/features/home/data/bmkg_models.dart';
import 'package:siagabencana_flutter/features/home/data/home_data_service.dart';

void main() {
  group('ApiConfig', () {
    test('resolves endpoint from a configured host', () {
      final config = ApiConfig(baseUrl: 'http://127.0.0.1:8000');
      expect(
        config.endpoint('api/peringatan-bencana').toString(),
        'http://127.0.0.1:8000/api/peringatan-bencana',
      );
    });

    test('rejects missing base URL', () {
      expect(
        () => const ApiConfig(baseUrl: '').endpoint('api/peringatan-bencana'),
        throwsStateError,
      );
    });
  });

  group('BmkgAlertResponse', () {
    test(
      'keeps every backend coverage and boolean without deriving a city match',
      () {
        final response = BmkgAlertResponse.fromJson({
          'success': true,
          'source': 'BMKG',
          'checked_at': '2026-10-24T10:30:00+07:00',
          'alerts': [
            _alert('kota_padang', true),
            _alert('sumbar_lainnya', false),
            _alert('provinsi_lain', false),
            _alert('tidak_diketahui', false),
            {'title': 'Tanpa flag', 'coverage': 'kota_padang'},
            {'title': 'Cakupan asing', 'coverage': 'future_value'},
          ],
        });

        expect(response.source, 'BMKG');
        expect(response.alerts.map((alert) => alert.coverage).toList(), [
          AlertCoverage.kotaPadang,
          AlertCoverage.sumbarLainnya,
          AlertCoverage.provinsiLain,
          AlertCoverage.tidakDiketahui,
          AlertCoverage.kotaPadang,
          AlertCoverage.tidakDiketahui,
        ]);
        expect(
          response.alerts.map((alert) => alert.isSpecificToPadang).toList(),
          [true, false, false, false, false, false],
        );
        expect(response.alerts.last.officialLink, isNull);
        expect(response.alerts.first.officialLink?.host, 'www.bmkg.go.id');
      },
    );

    test('rejects unsuccessful or malformed response structures', () {
      expect(
        () => BmkgAlertResponse.fromJson({'success': false}),
        throwsFormatException,
      );
      expect(
        () =>
            BmkgAlertResponse.fromJson({'success': true, 'alerts': 'invalid'}),
        throwsFormatException,
      );
      expect(() => BmkgAlert.fromJson({'title': 123}), throwsFormatException);
    });
  });

  test('HomeDataService requests BMKG and both Open-Meteo resources', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      if (request.url.path == '/api/peringatan-bencana') {
        return http.Response(
          jsonEncode({'success': true, 'source': 'BMKG', 'alerts': []}),
          200,
        );
      }
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

    final alerts = await service.loadBmkgAlerts();
    final weather = await service.loadWeather();
    final air = await service.loadAirQuality();

    expect(alerts.alerts, isEmpty);
    expect(weather.condition, 'Berawan');
    expect(air.category, 'Baik');
    expect(requests.map((request) => request.url.host), [
      'siagabencana.test',
      'api.open-meteo.com',
      'air-quality-api.open-meteo.com',
    ]);
    expect(requests.first.headers['Accept'], 'application/json');
    expect(requests.last.url.queryParameters['current'], 'us_aqi,pm2_5,pm10');
    client.close();
  });
}

Map<String, Object?> _alert(String coverage, bool isSpecific) => {
  'title': 'Contoh peringatan',
  'description': 'Deskripsi dari respons backend.',
  'published_formatted': '24 Oktober 2026, 10:00 WIB',
  'link': 'https://www.bmkg.go.id/alerts/nowcast/id/sample.xml',
  'coverage': coverage,
  'is_specific_to_padang': isSpecific,
};
