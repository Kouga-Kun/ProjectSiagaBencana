import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:siagabencana_flutter/app/navigation/app_section.dart';
import 'package:siagabencana_flutter/app/network/api_config.dart';
import 'package:siagabencana_flutter/app/siaga_app.dart';
import 'package:siagabencana_flutter/app/siaga_theme.dart';
import 'package:siagabencana_flutter/features/auth/data/auth_session_service.dart';
import 'package:siagabencana_flutter/features/education/data/education_data_service.dart';
import 'package:siagabencana_flutter/features/education/presentation/education_page.dart';
import 'package:siagabencana_flutter/features/home/data/home_data_service.dart';

void main() {
  testWidgets(
    'Unauthenticated user tapping Edukasi Bencana is redirected to Login and returned after login',
    (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;

      bool loggedIn = false;

      final mockClient = MockClient((request) async {
        final path = request.url.path;

        if (path == '/api/auth/status') {
          if (!loggedIn) {
            return http.Response(
              jsonEncode({'authenticated': false, 'user': null}),
              200,
            );
          }
          return http.Response(
            jsonEncode({
              'authenticated': true,
              'user': {
                'id': 1,
                'name': 'Budi Siaga',
                'email': 'budi@example.com',
                'role': 'warga',
              },
            }),
            200,
          );
        }

        if (path == '/api/auth/csrf') {
          return http.Response(jsonEncode({'csrf_token': 'test-token'}), 200);
        }

        if (path == '/api/auth/login') {
          loggedIn = true;
          return http.Response(
            jsonEncode({
              'message': 'Login berhasil.',
              'user': {
                'id': 1,
                'name': 'Budi Siaga',
                'email': 'budi@example.com',
                'role': 'warga',
              },
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

        if (request.url.host == 'air-quality-api.open-meteo.com') {
          return http.Response(
            jsonEncode({
              'current': {'us_aqi': 25},
            }),
            200,
          );
        }

        if (path.startsWith('/api/edukasi')) {
          if (!loggedIn) {
            return http.Response(
              jsonEncode({'message': 'Unauthenticated.'}),
              401,
            );
          }
          if (path == '/api/edukasi/materi') {
            return http.Response(
              jsonEncode({
                'data': [
                  {
                    'id': 1,
                    'category': 'Gempa Bumi',
                    'title': 'Pengertian Gempa Bumi',
                    'slug': 'pengertian-gempa-bumi',
                    'difficulty': 'Dasar',
                    'summary': 'Ringkasan gempa bumi.',
                    'content': 'Konten gempa bumi lengkap.',
                    'key_points': ['Poin 1'],
                    'action_steps': ['Langkah 1'],
                    'things_to_avoid': ['Hindari 1'],
                    'source_reference': 'BNPB & BMKG',
                    'is_completed': false,
                    'is_favorite': false,
                    'progress_percent': 0,
                  },
                ],
              }),
              200,
            );
          }
          if (path == '/api/edukasi/simulasi' ||
              path == '/api/edukasi/kuis' ||
              path == '/api/edukasi/misi') {
            return http.Response(jsonEncode({'data': []}), 200);
          }
          if (path == '/api/edukasi/progres') {
            return http.Response(
              jsonEncode({
                'data': {
                  'authenticated': true,
                  'has_activity': false,
                  'initial_message': 'Mulai belajar hari ini!',
                  'overall_percentage': 0,
                  'total_points': 0,
                  'level': {
                    'level_number': 1,
                    'level_name': 'Pemula Siaga',
                    'current_points': 0,
                    'next_level_points': 200,
                    'level_progress_percent': 0,
                  },
                  'materials': {
                    'completed': 0,
                    'total': 24,
                    'earthquake_completed': 0,
                    'earthquake_total': 12,
                    'tsunami_completed': 0,
                    'tsunami_total': 12,
                  },
                  'simulations': {'completed': 0, 'total': 12, 'history': []},
                  'quizzes': {'completed_quizzes': 0, 'total_quizzes': 4, 'history': []},
                  'missions': {'completed': 0, 'total': 14, 'history': []},
                  'badges': {'earned_count': 0, 'total_count': 5, 'items': []},
                  'recent_activities': [],
                  'activity_chart': [],
                  'pending_reminders': [],
                },
              }),
              200,
            );
          }
        }

        return http.Response(jsonEncode({}), 200);
      });
      addTearDown(mockClient.close);

      const apiConfig = ApiConfig(baseUrl: 'https://siagabencana.test');
      final authService = AuthSessionService(
        apiConfig: apiConfig,
        client: mockClient,
      );
      final homeService = HomeDataService(
        apiConfig: apiConfig,
        client: mockClient,
      );

      await tester.pumpWidget(
        SiagaApp(
          homeDataService: homeService,
          authSessionService: authService,
        ),
      );
      await tester.pumpAndSettle();

      // Tap Edukasi Bencana while unauthenticated -> redirected to Login page
      await tester.tap(find.text('Edukasi Bencana').first);
      await tester.pumpAndSettle();

      expect(find.text('Masuk ke akun'), findsOneWidget);
      expect(find.text('Login Diperlukan'), findsOneWidget);

      // Submit login credentials -> automatically returned to Edukasi Bencana
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'budi@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'PasswordAman123!',
      );
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Edukasi Gempa Bumi dan Tsunami'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Pengertian Gempa Bumi'), findsOneWidget);
    },
  );

  testWidgets(
    'EducationPage displays login gate when rendered with null user',
    (WidgetTester tester) async {
      final service = EducationDataService(
        apiConfig: const ApiConfig(baseUrl: 'https://siagabencana.test'),
      );
      addTearDown(service.dispose);

      bool loginPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: SiagaTheme.light,
          home: Scaffold(
            body: EducationPage(
              service: service,
              user: null,
              onNavigate: (AppSection _) {},
              onRequireLogin: () => loginPressed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Login Diperlukan untuk Edukasi Bencana'),
        findsOneWidget,
      );
      await tester.tap(find.text('Masuk ke Akun SiagaBencana'));
      await tester.pump();
      expect(loginPressed, isTrue);
    },
  );
}
