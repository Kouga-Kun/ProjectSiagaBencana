import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';
import 'package:siagabencana_flutter/features/evacuation/data/evacuation_location_service.dart';
import 'package:siagabencana_flutter/features/evacuation/data/evacuation_map_data.dart';
import 'package:siagabencana_flutter/features/evacuation/data/evacuation_search_service.dart';
import 'package:siagabencana_flutter/features/evacuation/presentation/evacuation_map.dart';

void main() {
  group('EvacuationMapData', () {
    test('preserves the Blade map center, zones, routes, and points', () {
      expect(EvacuationMapData.center, const LatLng(-0.9300, 100.3800));
      expect(EvacuationMapData.initialZoom, 13);
      expect(EvacuationMapData.zones, hasLength(3));
      expect(EvacuationMapData.routes, hasLength(2));
      expect(EvacuationMapData.points, hasLength(4));
      expect(
        EvacuationMapData.zones.map((zone) => zone.southWest).toList(),
        const [
          LatLng(-0.9700, 100.3400),
          LatLng(-0.9700, 100.3600),
          LatLng(-0.9700, 100.3850),
        ],
      );
      expect(EvacuationMapData.routes.first.points, const [
        LatLng(-0.9250, 100.3520),
        LatLng(-0.9250, 100.3680),
        LatLng(-0.9168, 100.4113),
      ]);
      expect(EvacuationMapData.points.first.name, 'Kantor BPBD Kota Padang');
      expect(
        EvacuationMapData.points.first.position,
        const LatLng(-0.9168, 100.4113),
      );
    });

    test(
      'tap selection uses only the static Blade zones and route geometry',
      () {
        final danger = EvacuationMapData.selectionAt(
          const LatLng(-0.9300, 100.3500),
        );
        final route = EvacuationMapData.selectionAt(
          const LatLng(-0.9250, 100.3600),
        );
        final outside = EvacuationMapData.selectionAt(
          const LatLng(-0.8800, 100.5000),
        );

        expect(danger?.title, 'Zona Bahaya');
        expect(danger?.riskLevel, 'Tinggi');
        expect(danger?.nearestPoint?.point.name, isNotEmpty);
        expect(route?.title, 'Jalur Evakuasi Utara');
        expect(outside, isNull);
      },
    );

    test('evaluates user coordinate inside mapped zone and outside mapped zone', () {
      final inDanger = EvacuationMapData.evaluateCoordinate(
        const LatLng(-0.9300, 100.3500),
        locationLabel: 'Lokasi Anda',
        isUserLocation: true,
      );
      expect(inDanger.zone?.id, 'danger');
      expect(
        inDanger.statusMessage,
        contains('Lokasi Anda berada di Zona Bahaya (Risiko Tinggi)'),
      );
      expect(inDanger.nearestPoint.point.name, 'Kantor Gubernur Sumbar');

      final outOfZone = EvacuationMapData.evaluateCoordinate(
        const LatLng(-0.8500, 100.4800),
        locationLabel: 'Lokasi Anda',
        isUserLocation: true,
      );
      expect(outOfZone.zone, isNull);
      expect(
        outOfZone.statusTitle,
        contains('Zona risiko belum tersedia untuk lokasi tersebut'),
      );
      expect(
        outOfZone.statusMessage,
        contains('Lokasi Anda berada di luar zona bencana yang terpetakan'),
      );
      expect(outOfZone.nearestPoint.point.name, 'Kantor BPBD Kota Padang');
    });
  });

  group('EvacuationSearchService', () {
    test('combines official evacuation points and geocoding results', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {
              'name': 'Jalan Khatib Sulaiman',
              'display_name':
                  'Jalan Khatib Sulaiman, Padang Utara, Kota Padang, Sumatera Barat',
              'lat': '-0.9180',
              'lon': '100.3620',
            },
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = EvacuationSearchService(client: client);
      final results = await service.searchLocations('Padang');

      expect(results, isNotEmpty);
      expect(results.any((item) => item.isOfficialPoint), isTrue);
      expect(
        results.any((item) => item.title == 'Jalan Khatib Sulaiman'),
        isTrue,
      );
    });
  });

  group('EvacuationMapPanel widget', () {
    testWidgets(
      'supports searching location and displays zone & evacuation details',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode([
              {
                'name': 'Pantai Padang',
                'display_name': 'Pantai Padang, Padang Barat, Kota Padang',
                'lat': '-0.9350',
                'lon': '100.3510',
              },
            ]),
            200,
          );
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EvacuationMapPanel(
                  searchService: EvacuationSearchService(client: mockClient),
                ),
              ),
            ),
          ),
        );

        expect(
          find.text('Peta Evakuasi Interaktif Kota Padang'),
          findsOneWidget,
        );
        expect(find.text('Lokasi Saya'), findsOneWidget);
        expect(find.text('Peta Jalan'), findsOneWidget);
        expect(find.text('Detail Kota'), findsOneWidget);
        expect(find.text('Satelit'), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'Pantai Padang');
        await tester.tap(find.text('Cari Lokasi'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Pantai Padang'), findsWidgets);
        await tester.tap(find.text('Pantai Padang').last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.textContaining('Detail Zona & Informasi Evakuasi: Zona Bahaya'),
          findsOneWidget,
        );
        expect(find.textContaining('Risiko Tinggi'), findsWidgets);
        expect(find.textContaining('Titik Evakuasi Terdekat'), findsOneWidget);
      },
    );

    testWidgets(
      'handles Lokasi Saya inside zone, outside zone, and permission denied',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        var mode = 'danger';
        Future<EvacuationUserCoordinates> fakeLocationFetcher() async {
          if (mode == 'denied') {
            throw const EvacuationLocationException(
              'Izin akses lokasi ditolak. Aktifkan izin lokasi pada browser untuk mengetahui zona bencana di posisi Anda.',
            );
          }
          if (mode == 'outside') {
            return const EvacuationUserCoordinates(
              latitude: -0.8400,
              longitude: 100.4900,
            );
          }
          return const EvacuationUserCoordinates(
            latitude: -0.9300,
            longitude: 100.3500,
          );
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EvacuationMapPanel(locationFetcher: fakeLocationFetcher),
              ),
            ),
          ),
        );

        // 1. Inside Danger Zone
        await tester.tap(find.text('Lokasi Saya'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.textContaining(
            'Lokasi Anda berada di Zona Bahaya (Risiko Tinggi)',
          ),
          findsWidgets,
        );

        // 2. Outside Mapped Zones
        mode = 'outside';
        await tester.tap(find.text('Lokasi Saya'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.textContaining(
            'Zona risiko belum tersedia untuk lokasi tersebut',
          ),
          findsWidgets,
        );

        // 3. Permission Denied
        mode = 'denied';
        await tester.tap(find.text('Lokasi Saya'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.textContaining('Izin akses lokasi ditolak'),
          findsOneWidget,
        );
      },
    );
  });
}
