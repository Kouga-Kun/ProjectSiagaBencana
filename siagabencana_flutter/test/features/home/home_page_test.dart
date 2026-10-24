import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:siagabencana_flutter/app/network/api_config.dart';
import 'package:siagabencana_flutter/features/home/data/home_data_service.dart';
import 'package:siagabencana_flutter/features/home/presentation/home_page.dart';

void main() {
  testWidgets('renders each BMKG coverage from backend as a distinct status', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final alerts = [
      _alert('Wilayah Kota Padang', 'kota_padang', true),
      _alert('Wilayah Sumbar lainnya', 'sumbar_lainnya', false),
      _alert('Wilayah provinsi lain', 'provinsi_lain', false),
      _alert('Wilayah belum diketahui', 'tidak_diketahui', false),
    ];
    final client = _client(alerts: alerts);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomePage(
            onOpenSection: (_) {},
            dataService: HomeDataService(
              apiConfig: const ApiConfig(baseUrl: 'https://siagabencana.test'),
              client: client,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Peringatan khusus Kota Padang'), findsOneWidget);
    expect(find.text('Sumatera Barat di luar Kota Padang'), findsOneWidget);
    expect(find.text('Provinsi lain'), findsOneWidget);
    expect(find.text('Cakupan belum dipastikan'), findsOneWidget);
    expect(find.text('Tidak ada peringatan dalam feed'), findsNothing);
    client.close();
  });

  testWidgets('shows loading then an explicit empty-feed message', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final alertResponse = Completer<http.Response>();
    final client = MockClient((request) async {
      if (request.url.path == '/api/peringatan-bencana') {
        return alertResponse.future;
      }
      return _openMeteoResponse(request);
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomePage(
            onOpenSection: (_) {},
            dataService: HomeDataService(
              apiConfig: const ApiConfig(baseUrl: 'https://siagabencana.test'),
              client: client,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Memuat data'), findsOneWidget);

    alertResponse.complete(
      http.Response(
        jsonEncode({
          'success': true,
          'source': 'BMKG',
          'checked_at': '2026-10-24T10:00:00+07:00',
          'alerts': [],
        }),
        200,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tidak ada peringatan dalam feed'), findsOneWidget);
    expect(find.textContaining('bukan jaminan keadaan aman'), findsOneWidget);
    client.close();
  });

  testWidgets('shows retry action when a source request fails', (tester) async {
    tester.view.physicalSize = const Size(1280, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final client = MockClient((request) async => http.Response('{}', 503));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomePage(
            onOpenSection: (_) {},
            dataService: HomeDataService(
              apiConfig: const ApiConfig(baseUrl: 'https://siagabencana.test'),
              client: client,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum tersedia'), findsNWidgets(3));
    expect(find.text('Coba lagi'), findsNWidgets(3));
    client.close();
  });
}

MockClient _client({required List<Map<String, Object?>> alerts}) =>
    MockClient((request) async {
      if (request.url.path == '/api/peringatan-bencana') {
        return http.Response(
          jsonEncode({
            'success': true,
            'source': 'BMKG',
            'checked_at': '2026-10-24T10:00:00+07:00',
            'alerts': alerts,
          }),
          200,
        );
      }
      return _openMeteoResponse(request);
    });

http.Response _openMeteoResponse(http.Request request) {
  if (request.url.host == 'api.open-meteo.com') {
    return http.Response(
      jsonEncode({
        'current': {
          'temperature_2m': 22,
          'relative_humidity_2m': 70,
          'apparent_temperature': 23,
          'wind_speed_10m': 8,
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
}

Map<String, Object?> _alert(String title, String coverage, bool specific) => {
  'title': title,
  'description': 'Informasi sesuai cakupan dari backend.',
  'published_formatted': '24 Oktober 2026, 10:00 WIB',
  'link': 'https://www.bmkg.go.id/alerts/nowcast/id/sample.xml',
  'coverage': coverage,
  'is_specific_to_padang': specific,
};
