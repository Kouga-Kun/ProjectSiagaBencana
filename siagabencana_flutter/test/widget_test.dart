import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:siagabencana_flutter/app/network/api_config.dart';
import 'package:siagabencana_flutter/app/siaga_app.dart';
import 'package:siagabencana_flutter/features/auth/data/auth_session_service.dart';
import 'package:siagabencana_flutter/features/home/data/home_data_service.dart';

void main() {
  testWidgets(
    'Home, account flow, and navigation adapt cleanly to mobile, tablet, and desktop',
    (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;

      final client = MockClient((request) async {
        final path = request.url.path;
        if (path == '/api/auth/status') {
          return http.Response(
            jsonEncode({'authenticated': false, 'user': null}),
            200,
          );
        }
        if (path == '/api/laporan') {
          return http.Response(
            jsonEncode({
              'data': [],
              'stats': {
                'total_reports': 0,
                'disaster_type_count': 0,
                'affected_area_count': 0,
                'pending_reports': 0,
              },
              'options': {},
              'current_page': 1,
              'last_page': 1,
            }),
            200,
          );
        }
        if (request.url.host == 'api.open-meteo.com') {
          return http.Response(
            jsonEncode({
              'current': {'temperature_2m': 28, 'weather_code': 0},
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

      const apiConfig = ApiConfig(baseUrl: 'https://siagabencana.test');
      final dataService = HomeDataService(apiConfig: apiConfig, client: client);
      final authService = AuthSessionService(
        apiConfig: apiConfig,
        client: client,
      );

      await tester.pumpWidget(
        SiagaApp(
          homeDataService: dataService,
          authSessionService: authService,
        ),
      );
      await tester.pumpAndSettle();

      // Mobile view: bottom NavigationBar + Home hero visible without BMKG warning
      expect(find.textContaining('Kenali risiko.'), findsOneWidget);
      expect(find.text('Peringatan BMKG'), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);

      // Navigate via Lainnya bottom sheet -> Laporan
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Laporan'));
      await tester.pumpAndSettle();
      expect(find.text('Laporan dan riwayat bencana'), findsOneWidget);

      // Navigate to Profile via AppBar action
      await tester.tap(find.byTooltip('Buka profil'));
      await tester.pumpAndSettle();
      expect(find.text('Belum masuk ke akun'), findsOneWidget);

      // Navigate to Login & check form validation
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      expect(find.text('Masuk ke akun'), findsOneWidget);

      await tester.drag(find.byType(ListView).last, const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();
      expect(find.text('Email wajib diisi.'), findsOneWidget);

      // Tablet view (800x1024): still compact navigation without overflow
      tester.view.physicalSize = const Size(800, 1024);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);

      // Desktop view (1280x900): sidebar replaces bottom NavigationBar
      tester.view.physicalSize = const Size(1280, 900);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Bantuan SOS'), findsOneWidget);
      expect(find.text('Peta Evakuasi'), findsOneWidget);
    },
  );
}
