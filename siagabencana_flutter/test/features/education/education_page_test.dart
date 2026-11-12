import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siagabencana_flutter/app/navigation/app_section.dart';
import 'package:siagabencana_flutter/app/siaga_theme.dart';
import 'package:siagabencana_flutter/features/education/data/education_data_service.dart';
import 'package:siagabencana_flutter/features/education/presentation/education_page.dart';

void main() {
  testWidgets(
    'EducationPage renders title, subtitle, categories, progress, and tabs',
    (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;

      final service = EducationDataService();

      await tester.pumpWidget(
        MaterialApp(
          theme: SiagaTheme.light,
          home: Scaffold(
            body: EducationPage(
              service: service,
              onNavigate: (AppSection _) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edukasi Gempa Bumi dan Tsunami'), findsOneWidget);
      expect(
        find.textContaining(
          'Kenali Risikonya, Lindungi Dirimu, Selamatkan Sesama.',
        ),
        findsOneWidget,
      );

      // Categories and sub-features
      expect(find.text('Gempa Bumi'), findsWidgets);
      expect(find.text('Tsunami'), findsWidgets);
      expect(find.text('Belajar'), findsWidgets);
      expect(find.text('Simulasi'), findsWidgets);
      expect(find.text('Kuis'), findsWidgets);
      expect(find.text('Misi Siaga'), findsWidgets);

      // Materials rendered in Belajar tab
      expect(find.text('Pengertian Gempa Bumi'), findsOneWidget);
      expect(find.text('Pengertian Tsunami'), findsOneWidget);

      // Switch to Simulasi tab
      await tester.tap(find.text('Simulasi').first);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Gempa Terjadi Saat Berada di Dalam Rumah'),
        findsOneWidget,
      );

      // Switch to Kuis tab
      await tester.tap(find.text('Kuis').first);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Kuis Gempa Bumi: Pengetahuan Dasar'),
        findsOneWidget,
      );

      // Switch to Misi Siaga tab
      await tester.tap(find.text('Misi Siaga').first);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Kenali Tempat Berlindung yang Aman di Rumah'),
        findsOneWidget,
      );
    },
  );
}

