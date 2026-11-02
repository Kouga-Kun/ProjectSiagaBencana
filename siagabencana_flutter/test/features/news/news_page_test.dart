import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:siagabencana_flutter/app/navigation/app_section.dart';
import 'package:siagabencana_flutter/app/network/api_config.dart';
import 'package:siagabencana_flutter/features/news/data/news_data_service.dart';
import 'package:siagabencana_flutter/features/news/presentation/news_page.dart';

void main() {
  testWidgets(
    'NewsPage displays Headline News, Berita Bencana Lainnya, filters by category and search, shows empty message, and navigates to NewsDetailPage',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 1500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final articles = <Map<String, Object?>>[
        {
          'id': 2,
          'title': 'Peringatan Dini Cuaca Sumatera Barat',
          'slug': 'peringatan-dini-cuaca-sumatera-barat',
          'category': NewsCategories.earlyWarning,
          'image_url': null,
          'summary': 'Ringkasan peringatan dini potensi hujan disertai petir.',
          'content':
              'Isi lengkap berita peringatan dini dari BMKG untuk wilayah Sumatera Barat.',
          'source': 'BMKG Sumatera Barat',
          'published_at': '2026-10-30T01:00:00+07:00',
          'published_formatted': '30 Oktober 2026 • 01:00 WIB',
          'status': 'published',
          'status_label': 'Dipublikasikan',
          'is_featured': true,
          'is_headline': true,
        },
        {
          'id': 1,
          'title': 'Panduan Tas Siaga Bencana Keluarga',
          'slug': 'panduan-tas-siaga-bencana-keluarga',
          'category': NewsCategories.education,
          'image_url': null,
          'summary': 'Ringkasan perlengkapan darurat untuk 72 jam pertama.',
          'content':
              'Isi lengkap edukasi penyusunan tas siaga bencana bagi masyarakat Kota Padang.',
          'source': 'BPBD Kota Padang',
          'published_at': '2026-10-29T10:00:00+07:00',
          'published_formatted': '29 Oktober 2026 • 10:00 WIB',
          'status': 'published',
          'status_label': 'Dipublikasikan',
          'is_featured': false,
          'is_headline': false,
        },
      ];

      final client = MockClient((request) async {
        if (request.url.path == '/api/berita') {
          final search = request.url.queryParameters['search']?.toLowerCase();
          final category = request.url.queryParameters['category'];

          final filtered = articles.where((item) {
            final matchesSearch =
                search == null ||
                search.isEmpty ||
                (item['title'] as String).toLowerCase().contains(search);
            final matchesCategory =
                category == null ||
                category.isEmpty ||
                item['category'] == category;
            return matchesSearch && matchesCategory;
          }).toList();

          return http.Response(
            jsonEncode({
              'data': filtered,
              'featured': filtered.isNotEmpty ? filtered.first : null,
              'headline': filtered.isNotEmpty ? filtered.first : null,
              'categories': NewsCategories.all,
            }),
            200,
            headers: const {'content-type': 'application/json; charset=utf-8'},
          );
        }

        if (request.url.path.startsWith('/api/berita/')) {
          final slug = request.url.pathSegments.last;
          final match = articles.firstWhere(
            (item) => item['slug'] == slug,
            orElse: () => articles.first,
          );
          return http.Response(
            jsonEncode({'data': match}),
            200,
            headers: const {'content-type': 'application/json; charset=utf-8'},
          );
        }

        return http.Response('{}', 404);
      });

      final service = NewsDataService(
        apiConfig: const ApiConfig(baseUrl: 'https://siagabencana.test'),
        client: client,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsPage(
              onOpenSection: (AppSection _) {},
              dataService: service,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Menampilkan Headline News, Berita Bencana Lainnya, dan pil kategori
      expect(find.text('Headline News'), findsOneWidget);
      expect(find.text('BERITA UTAMA'), findsOneWidget);
      expect(find.text('Berita Bencana Lainnya'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Semua Berita'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Bencana'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Peringatan Dini'), findsOneWidget);
      expect(
        find.widgetWithText(ChoiceChip, 'Edukasi Kebencanaan'),
        findsOneWidget,
      );
      expect(find.text('Peringatan Dini Cuaca Sumatera Barat'), findsWidgets);
      expect(find.text('Panduan Tas Siaga Bencana Keluarga'), findsOneWidget);

      // Filter berdasarkan kategori "Edukasi Kebencanaan"
      await tester.tap(find.widgetWithText(ChoiceChip, 'Edukasi Kebencanaan'));
      await tester.pumpAndSettle();

      expect(find.text('Panduan Tas Siaga Bencana Keluarga'), findsWidgets);
      expect(find.text('Peringatan Dini Cuaca Sumatera Barat'), findsNothing);

      // Reset filter kembali ke Semua Berita
      await tester.tap(find.text('Reset Filter'));
      await tester.pumpAndSettle();
      expect(find.text('Peringatan Dini Cuaca Sumatera Barat'), findsWidgets);

      // Pencarian dengan kata kunci yang tidak ditemukan
      await tester.enterText(find.byType(TextField), 'KataKunciTidakAda');
      await tester.tap(find.text('Cari Berita'));
      await tester.pumpAndSettle();

      expect(find.text('Berita tidak tersedia'), findsOneWidget);

      // Reset filter lalu cari berdasarkan judul yang ada
      await tester.tap(find.text('Tampilkan semua berita'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Tas Siaga');
      await tester.tap(find.text('Cari Berita'));
      await tester.pumpAndSettle();

      expect(find.text('Panduan Tas Siaga Bencana Keluarga'), findsWidgets);
      expect(find.text('Peringatan Dini Cuaca Sumatera Barat'), findsNothing);

      // Klik tombol "Baca Selengkapnya" untuk membuka halaman Detail Berita
      await tester.tap(find.text('Baca Selengkapnya'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Berita'), findsOneWidget);
      expect(find.text('Sumber: BPBD Kota Padang'), findsOneWidget);
      expect(
        find.textContaining('Isi lengkap edukasi penyusunan tas siaga bencana'),
        findsOneWidget,
      );

      // Tombol kembali ke halaman berita
      await tester.tap(find.text('Kembali ke Halaman Berita'));
      await tester.pumpAndSettle();

      expect(find.text('Berita & Edukasi Kesiapsiagaan'), findsOneWidget);
      service.close();
    },
  );
}

