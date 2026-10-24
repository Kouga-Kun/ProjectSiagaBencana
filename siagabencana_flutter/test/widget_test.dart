import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:siagabencana_flutter/app/network/api_config.dart';
import 'package:siagabencana_flutter/features/home/data/home_data_service.dart';
import 'package:siagabencana_flutter/app/siaga_app.dart';

void main() {
  testWidgets(
    'Home, account flow, and navigation adapt to mobile and desktop',
    (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;

      final client = MockClient((request) async {
        if (request.url.path == '/api/peringatan-bencana') {
          return http.Response(
            jsonEncode({'success': true, 'source': 'BMKG', 'alerts': []}),
            200,
          );
        }
        if (request.url.host == 'api.open-meteo.com') {
          return http.Response(
            jsonEncode({
              'current': {'temperature_2m': 22, 'weather_code': 0},
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'current': {'us_aqi': 30},
          }),
          200,
        );
      });
      addTearDown(client.close);
      final dataService = HomeDataService(
        apiConfig: const ApiConfig(baseUrl: 'https://siagabencana.test'),
        client: client,
      );
      await tester.pumpWidget(SiagaApp(homeDataService: dataService));
      await tester.pumpAndSettle();

      expect(find.textContaining('Kenali risiko.'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Laporan'));
      await tester.pumpAndSettle();

      expect(find.text('Laporan dan riwayat bencana'), findsOneWidget);
      expect(find.text('Data laporan belum dimuat'), findsOneWidget);

      await tester.tap(find.byTooltip('Buka profil'));
      await tester.pumpAndSettle();
      expect(find.text('Profil belum terhubung'), findsOneWidget);

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      expect(find.text('Masuk ke akun'), findsOneWidget);
      expect(find.text('Autentikasi belum terhubung'), findsOneWidget);

      await tester.drag(find.byType(ListView).last, const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Validasi login'));
      await tester.pumpAndSettle();
      expect(find.text('Email wajib diisi.'), findsOneWidget);

      tester.view.physicalSize = const Size(1280, 900);
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Profil'), findsOneWidget);
    },
  );
}
