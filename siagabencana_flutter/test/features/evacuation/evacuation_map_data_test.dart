import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:siagabencana_flutter/features/evacuation/data/evacuation_map_data.dart';

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
        expect(route?.title, 'Jalur Evakuasi Utara');
        expect(outside, isNull);
      },
    );
  });
}
