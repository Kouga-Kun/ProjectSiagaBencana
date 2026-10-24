import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class EvacuationMapZone {
  const EvacuationMapZone({
    required this.id,
    required this.title,
    required this.description,
    required this.southWest,
    required this.northEast,
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final LatLng southWest;
  final LatLng northEast;
  final Color color;

  bool contains(LatLng point) =>
      point.latitude >= southWest.latitude &&
      point.latitude <= northEast.latitude &&
      point.longitude >= southWest.longitude &&
      point.longitude <= northEast.longitude;
}

class EvacuationMapRoute {
  const EvacuationMapRoute({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
  });

  final String id;
  final String title;
  final String description;
  final List<LatLng> points;
}

class EvacuationMapPoint {
  const EvacuationMapPoint({
    required this.name,
    required this.position,
    required this.description,
  });

  final String name;
  final LatLng position;
  final String description;
}

class EvacuationMapData {
  static const center = LatLng(-0.9300, 100.3800);
  static const initialZoom = 13.0;

  static const zones = [
    EvacuationMapZone(
      id: 'danger',
      title: 'Zona Bahaya',
      description: 'Area pesisir pantai. Risiko tinggi hantaman gelombang. Segera evakuasi dari sini!',
      southWest: LatLng(-0.9700, 100.3400),
      northEast: LatLng(-0.8900, 100.3600),
      color: Color(0xFFDC2626),
    ),
    EvacuationMapZone(
      id: 'warning',
      title: 'Zona Waspada',
      description: 'Area tengah kota. Tetap waspada dan ikuti jalur evakuasi ke arah Timur.',
      southWest: LatLng(-0.9700, 100.3600),
      northEast: LatLng(-0.8900, 100.3850),
      color: Color(0xFFEAB308),
    ),
    EvacuationMapZone(
      id: 'safe',
      title: 'Zona Aman',
      description: 'Area Bypass dan dataran tinggi. Lokasi pengungsian akhir.',
      southWest: LatLng(-0.9700, 100.3850),
      northEast: LatLng(-0.8900, 100.4300),
      color: Color(0xFF16A34A),
    ),
  ];

  static const routes = [
    EvacuationMapRoute(
      id: 'route-north',
      title: 'Jalur Evakuasi Utara',
      description: 'Mengarah ke Posko Utama BPBD Bypass.',
      points: [
        LatLng(-0.9250, 100.3520),
        LatLng(-0.9250, 100.3680),
        LatLng(-0.9168, 100.4113),
      ],
    ),
    EvacuationMapRoute(
      id: 'route-center',
      title: 'Jalur Evakuasi Tengah',
      description: 'Ikuti jalan utama ke arah Timur menjauhi garis pantai.',
      points: [
        LatLng(-0.9450, 100.3550),
        LatLng(-0.9450, 100.3750),
        LatLng(-0.9450, 100.4100),
      ],
    ),
  ];

  static const points = [
    EvacuationMapPoint(
      name: 'Kantor BPBD Kota Padang',
      position: LatLng(-0.9168, 100.4113),
      description: 'Pusat Komando (Zona Aman)',
    ),
    EvacuationMapPoint(
      name: 'RSUP Dr. M. Djamil',
      position: LatLng(-0.9429, 100.3621),
      description: 'Layanan Medis Darurat (Zona Waspada)',
    ),
    EvacuationMapPoint(
      name: 'Kantor Gubernur Sumbar',
      position: LatLng(-0.9238, 100.3624),
      description: 'Titik Kumpul Sementara',
    ),
    EvacuationMapPoint(
      name: 'Polresta Padang',
      position: LatLng(-0.9483, 100.3636),
      description: 'Pusat Keamanan',
    ),
  ];

  static EvacuationMapSelection? selectionAt(LatLng position) {
    for (final route in routes) {
      if (_isNearRoute(position, route.points)) {
        return EvacuationMapSelection(
          title: route.title,
          description: route.description,
          position: position,
          color: const Color(0xFFDC2626),
        );
      }
    }

    for (final zone in zones) {
      if (zone.contains(position)) {
        return EvacuationMapSelection(
          title: zone.title,
          description: zone.description,
          position: position,
          color: zone.color,
        );
      }
    }

    return null;
  }

  static bool _isNearRoute(LatLng position, List<LatLng> route) {
    for (var index = 0; index < route.length - 1; index++) {
      if (_distanceToSegment(position, route[index], route[index + 1]) <=
          0.0012) {
        return true;
      }
    }
    return false;
  }

  static double _distanceToSegment(LatLng point, LatLng start, LatLng end) {
    final longitudeScale = math.cos(point.latitude * math.pi / 180);
    final pointX = point.longitude * longitudeScale;
    final pointY = point.latitude;
    final startX = start.longitude * longitudeScale;
    final startY = start.latitude;
    final endX = end.longitude * longitudeScale;
    final endY = end.latitude;
    final deltaX = endX - startX;
    final deltaY = endY - startY;
    final segmentLengthSquared = deltaX * deltaX + deltaY * deltaY;

    if (segmentLengthSquared == 0) {
      final latitudeDelta = pointY - startY;
      final longitudeDelta = pointX - startX;
      return math.sqrt(
        latitudeDelta * latitudeDelta + longitudeDelta * longitudeDelta,
      );
    }

    final projection =
        (((pointX - startX) * deltaX) + ((pointY - startY) * deltaY)) /
        segmentLengthSquared;
    final boundedProjection = projection.clamp(0.0, 1.0);
    final nearestX = startX + (boundedProjection * deltaX);
    final nearestY = startY + (boundedProjection * deltaY);
    final latitudeDelta = pointY - nearestY;
    final longitudeDelta = pointX - nearestX;

    return math.sqrt(
      latitudeDelta * latitudeDelta + longitudeDelta * longitudeDelta,
    );
  }
}

class EvacuationMapSelection {
  const EvacuationMapSelection({
    required this.title,
    required this.description,
    required this.position,
    required this.color,
    this.pointName,
  });

  final String title;
  final String description;
  final LatLng position;
  final Color color;
  final String? pointName;
}
