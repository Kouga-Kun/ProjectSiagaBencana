import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:siagabencana_flutter/app/network/api_config.dart';
import 'package:siagabencana_flutter/app/siaga_theme.dart';
import 'package:siagabencana_flutter/features/home/data/home_data_service.dart';
import 'package:siagabencana_flutter/features/home/presentation/home_page.dart';

void main() {
  testWidgets(
    'renders weather and air quality cleanly without BMKG warnings or alert API call',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final requestedPaths = <String>[];
      final client = MockClient((request) async {
        requestedPaths.add(request.url.path);
        return _openMeteoResponse(request);
      });
      addTearDown(client.close);

      await tester.pumpWidget(
        MaterialApp(
          theme: SiagaTheme.light,
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

      expect(requestedPaths, isNot(contains('/api/peringatan-bencana')));
      expect(find.text('Peringatan BMKG'), findsNothing);
      expect(find.text('Cuaca Kota Padang'), findsOneWidget);
      expect(find.text('22°C'), findsOneWidget);
      expect(find.text('Berawan'), findsOneWidget);
      expect(find.text('Kualitas Udara'), findsNWidgets(2));
      expect(find.text('AQI 42'), findsOneWidget);
      expect(find.text('Baik'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shows loading state then live weather and air quality values', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final weatherCompleter = Completer<http.Response>();
    final airCompleter = Completer<http.Response>();
    final client = MockClient((request) {
      if (request.url.host == 'api.open-meteo.com') {
        return weatherCompleter.future;
      }
      return airCompleter.future;
    });
    addTearDown(client.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: SiagaTheme.light,
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

    expect(find.text('Memuat data'), findsNWidgets(2));
    expect(find.text('Peringatan BMKG'), findsNothing);

    weatherCompleter.complete(
      _openMeteoResponse(
        http.Request('GET', Uri.https('api.open-meteo.com', '/v1/forecast')),
      ),
    );
    airCompleter.complete(
      _openMeteoResponse(
        http.Request(
          'GET',
          Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('22°C'), findsOneWidget);
    expect(find.text('AQI 42'), findsOneWidget);
  });

  testWidgets('shows retry action when Open-Meteo source requests fail', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final client = MockClient((request) async => http.Response('{}', 503));
    addTearDown(client.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: SiagaTheme.light,
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

    expect(find.text('Peringatan BMKG'), findsNothing);
    expect(find.text('Belum tersedia'), findsNWidgets(2));
    expect(find.text('Coba lagi'), findsNWidgets(2));
  });

  testWidgets('adapts proportionally across mobile, tablet, and desktop', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final size in const [
      Size(375, 812),
      Size(820, 1024),
      Size(1440, 900),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;

      final client = MockClient((request) async => _openMeteoResponse(request));
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(size),
          theme: SiagaTheme.light,
          home: Scaffold(
            body: HomePage(
              key: ValueKey(size),
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

      await tester.scrollUntilVisible(
        find.text('Pemantauan kondisi terkini'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Pemantauan kondisi terkini'), findsOneWidget);
      expect(find.text('Peringatan BMKG'), findsNothing);
      expect(tester.takeException(), isNull);
      client.close();
    }
  });
}

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
