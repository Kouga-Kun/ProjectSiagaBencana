import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:siagabencana_flutter/app/navigation/app_section.dart';
import 'package:siagabencana_flutter/app/network/api_config.dart';
import 'package:siagabencana_flutter/app/siaga_theme.dart';
import 'package:siagabencana_flutter/features/auth/data/auth_session_service.dart';
import 'package:siagabencana_flutter/features/auth/presentation/auth_page.dart';
import 'package:siagabencana_flutter/features/evacuation/presentation/evacuation_page.dart';
import 'package:siagabencana_flutter/features/mitigation/presentation/mitigation_page.dart';
import 'package:siagabencana_flutter/features/profile/presentation/profile_info_page.dart';
import 'package:siagabencana_flutter/features/profile/presentation/profile_page.dart';
import 'package:siagabencana_flutter/features/reports/data/reports_data_service.dart';
import 'package:siagabencana_flutter/features/reports/presentation/reports_page.dart';
import 'package:siagabencana_flutter/features/sos/data/sos_data_service.dart';
import 'package:siagabencana_flutter/features/sos/data/sos_location_service.dart';
import 'package:siagabencana_flutter/features/sos/presentation/sos_page.dart';

void main() {
  const viewports = <String, Size>{
    'mobile': Size(375, 812),
    'tablet': Size(820, 1024),
    'desktop': Size(1440, 900),
  };

  const sampleUser = AuthUser(
    id: 1,
    name: 'Andi Pratama',
    email: 'andi@siagabencana.id',
    role: 'warga',
    phone: '081234567890',
    address: 'Jl. Khatib Sulaiman No. 12, Padang',
  );

  for (final entry in viewports.entries) {
    testWidgets(
      'Core pages render cleanly without overflow on ${entry.key} (${entry.value.width.toInt()}x${entry.value.height.toInt()})',
      (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final mockClient = MockClient((request) async {
          final path = request.url.path;
          if (path == '/api/laporan') {
            return http.Response(
              jsonEncode({
                'data': [
                  {
                    'id': 1,
                    'disaster_type': 'Gempa Bumi',
                    'verification_status': 'verified',
                    'description': 'Guncangan terasa di pesisir Padang Barat.',
                    'affected_area': 'Purus',
                    'district': 'Padang Barat',
                    'city_district': 'Kota Padang',
                    'province': 'Sumatera Barat',
                    'occurred_at': '2026-11-20T09:00:00+07:00',
                    'source_name': 'Warga',
                  },
                ],
                'stats': {
                  'total_reports': 1,
                  'disaster_type_count': 1,
                  'affected_area_count': 1,
                  'pending_reports': 0,
                },
                'options': {
                  'disaster_types': ['Gempa Bumi'],
                  'provinces': ['Sumatera Barat'],
                  'cities': ['Kota Padang'],
                  'districts': ['Padang Barat'],
                },
                'current_page': 1,
                'last_page': 1,
              }),
              200,
            );
          }
          if (path == '/api/sos/riwayat') {
            return http.Response(jsonEncode({'data': []}), 200);
          }
          if (path == '/api/profile') {
            return http.Response(
              jsonEncode({
                'user': {
                  'id': 1,
                  'name': sampleUser.name,
                  'email': sampleUser.email,
                  'role': sampleUser.role,
                  'phone': sampleUser.phone,
                  'address': sampleUser.address,
                },
              }),
              200,
            );
          }
          return http.Response(jsonEncode({}), 200);
        });
        addTearDown(mockClient.close);

        const apiConfig = ApiConfig(baseUrl: 'https://siagabencana.test');
        final authService = AuthSessionService(
          apiConfig: apiConfig,
          client: mockClient,
        );
        final reportsService = ReportsDataService(
          apiConfig: apiConfig,
          client: mockClient,
          authService: authService,
        );
        final sosService = SosDataService(
          apiConfig: apiConfig,
          client: mockClient,
          authService: authService,
        );

        // 1. EvacuationPage
        await tester.pumpWidget(
          MaterialApp(
            theme: SiagaTheme.light,
            home: Scaffold(
              body: EvacuationPage(
                onOpenMitigation: () {},
                onOpenEducation: () {},
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('Peta dan informasi evakuasi'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // 2. ReportsPage
        await tester.pumpWidget(
          MaterialApp(
            theme: SiagaTheme.light,
            home: Scaffold(
              body: ReportsPage(
                authService: authService,
                user: sampleUser,
                dataService: reportsService,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Laporan dan riwayat bencana'), findsOneWidget);
        expect(find.text('+ Buat laporan'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // 3. MitigationPage
        await tester.pumpWidget(
          MaterialApp(
            theme: SiagaTheme.light,
            home: const Scaffold(body: MitigationPage()),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Mitigasi & kesiapsiagaan bencana'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Panduan Tsunami'),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Panduan Tsunami'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Sebelum tsunami'),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Sebelum tsunami'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // 4. ProfilePage
        await tester.pumpWidget(
          MaterialApp(
            theme: SiagaTheme.light,
            home: Scaffold(
              body: ProfilePage(
                onOpenSection: (AppSection _) {},
                user: sampleUser,
                isLoading: false,
                statusError: null,
                onRetryStatus: () {},
                onLogout: () async {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Andi Pratama'), findsOneWidget);
        expect(find.text('Bantuan Darurat SOS'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // 5. ProfileInfoPage
        await tester.pumpWidget(
          MaterialApp(
            theme: SiagaTheme.light,
            home: Scaffold(
              body: ProfileInfoPage(
                user: sampleUser,
                authService: authService,
                onUserUpdated: (_) {},
                onBack: () {},
                onOpenSection: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Informasi Profil Pengguna'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // 6. SosPage
        await tester.pumpWidget(
          MaterialApp(
            theme: SiagaTheme.light,
            home: Scaffold(
              body: SosPage(
                user: sampleUser,
                authService: authService,
                sosDataService: sosService,
                onBack: () {},
                onOpenSection: (_) {},
                locationFetcher: () async => const SosCoordinates(
                  latitude: -0.9471,
                  longitude: 100.4172,
                  accuracyMeters: 15,
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('Bantuan Darurat SOS'), findsOneWidget);
        expect(find.text('TEKAN SOS'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // 7. AuthPage
        await tester.pumpWidget(
          MaterialApp(
            theme: SiagaTheme.light,
            home: Scaffold(
              body: AuthPage(
                isRegistration: false,
                onOpenSection: (_) {},
                authService: authService,
                onAuthenticated: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Masuk ke akun'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
