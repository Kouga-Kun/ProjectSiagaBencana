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
    this.areaName = 'Wilayah Kota Padang',
    this.disasterType = 'Potensi Bencana Pesisir & Gempa Bumi',
    this.riskLevel = 'Sedang',
    this.evacuationInfo = 'Ikuti jalur dan arahan evakuasi resmi menuju titik aman.',
  });

  final String id;
  final String title;
  final String description;
  final LatLng southWest;
  final LatLng northEast;
  final Color color;
  final String areaName;
  final String disasterType;
  final String riskLevel;
  final String evacuationInfo;

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
    this.category = 'Titik Evakuasi & Instansi Resmi',
    this.areaName = 'Kota Padang',
  });

  final String name;
  final LatLng position;
  final String description;
  final String category;
  final String areaName;
}

class EvacuationNearestPoint {
  const EvacuationNearestPoint({
    required this.point,
    required this.distanceKm,
  });

  final EvacuationMapPoint point;
  final double distanceKm;

  String get formattedDistance {
    if (distanceKm < 1.0) {
      final meters = (distanceKm * 1000).round();
      return '$meters m';
    }
    return '${distanceKm.toStringAsFixed(2)} km';
  }
}

class EvacuationLocationAssessment {
  const EvacuationLocationAssessment({
    required this.position,
    required this.inMappedZone,
    required this.statusTitle,
    required this.statusMessage,
    required this.nearestPoint,
    required this.selection,
    this.zone,
    this.locationLabel,
  });

  final LatLng position;
  final bool inMappedZone;
  final String statusTitle;
  final String statusMessage;
  final EvacuationMapZone? zone;
  final EvacuationNearestPoint nearestPoint;
  final EvacuationMapSelection selection;
  final String? locationLabel;
}

class EvacuationMapData {
  static const center = LatLng(-0.9300, 100.3800);
  static const initialZoom = 13.0;

  static const zones = [
    EvacuationMapZone(
      id: 'danger',
      title: 'Zona Bahaya',
      description:
          'Area pesisir pantai. Risiko tinggi hantaman gelombang. Segera evakuasi dari sini!',
      southWest: LatLng(-0.9700, 100.3400),
      northEast: LatLng(-0.8900, 100.3600),
      color: Color(0xFFDC2626),
      areaName: 'Wilayah Pesisir Pantai Kota Padang (Padang Barat, Ulak Karang, Purus)',
      disasterType: 'Tsunami & Gelombang Pasang Pesisir',
      riskLevel: 'Tinggi',
      evacuationInfo:
          'Segera lakukan evakuasi mandiri menjauhi garis pantai ke arah Timur menuju Zona Aman (Bypass/dataran tinggi) atau shelter evakuasi vertikal terdekat.',
    ),
    EvacuationMapZone(
      id: 'warning',
      title: 'Zona Waspada',
      description:
          'Area tengah kota. Tetap waspada dan ikuti jalur evakuasi ke arah Timur.',
      southWest: LatLng(-0.9700, 100.3600),
      northEast: LatLng(-0.8900, 100.3850),
      color: Color(0xFFEAB308),
      areaName: 'Wilayah Tengah Kota Padang (Sawahan, Jati, Sudirman, Khatib Sulaiman)',
      disasterType: 'Dampak Gempa Bumi & Limpasan Tsunami',
      riskLevel: 'Sedang',
      evacuationInfo:
          'Pantau informasi resmi BMKG/BPBD, siapkan Tas Siaga Bencana, dan ikuti rambu jalur evakuasi utama ke arah Timur menuju Zona Aman.',
    ),
    EvacuationMapZone(
      id: 'safe',
      title: 'Zona Aman',
      description:
          'Area Bypass dan dataran tinggi. Lokasi pengungsian akhir.',
      southWest: LatLng(-0.9700, 100.3850),
      northEast: LatLng(-0.8900, 100.4300),
      color: Color(0xFF16A34A),
      areaName: 'Wilayah Bypass & Dataran Tinggi Kota Padang (Kuranji, Pauh, Lubuk Begalung)',
      disasterType: 'Zona Pengungsian & Titik Aman Tsunami',
      riskLevel: 'Rendah (Zona Aman)',
      evacuationInfo:
          'Area tujuan evakuasi akhir di dataran tinggi dan koridor Bypass. Ikuti arahan petugas di posko utama dan titik kumpul resmi.',
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
      category: 'Posko Utama & Pusat Komando',
      areaName: 'Koridor Bypass, Kota Padang',
    ),
    EvacuationMapPoint(
      name: 'RSUP Dr. M. Djamil',
      position: LatLng(-0.9429, 100.3621),
      description: 'Layanan Medis Darurat (Zona Waspada)',
      category: 'Fasilitas Medis Darurat',
      areaName: 'Sawahan, Kota Padang',
    ),
    EvacuationMapPoint(
      name: 'Kantor Gubernur Sumbar',
      position: LatLng(-0.9238, 100.3624),
      description: 'Titik Kumpul Sementara',
      category: 'Titik Kumpul Sementara',
      areaName: 'Jl. Jend. Sudirman, Kota Padang',
    ),
    EvacuationMapPoint(
      name: 'Polresta Padang',
      position: LatLng(-0.9483, 100.3636),
      description: 'Pusat Keamanan',
      category: 'Pusat Keamanan & Koordinasi',
      areaName: 'Jl. Moh. Yamin, Kota Padang',
    ),
  ];

  static EvacuationMapZone? zoneAt(LatLng position) {
    for (final zone in zones) {
      if (zone.contains(position)) {
        return zone;
      }
    }
    return null;
  }

  static EvacuationNearestPoint nearestEvacuationPoint(LatLng position) {
    var bestPoint = points.first;
    var bestDistance = _haversineDistanceKm(position, bestPoint.position);

    for (final point in points.skip(1)) {
      final distance = _haversineDistanceKm(position, point.position);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestPoint = point;
      }
    }

    return EvacuationNearestPoint(
      point: bestPoint,
      distanceKm: bestDistance,
    );
  }

  static EvacuationLocationAssessment evaluateCoordinate(
    LatLng position, {
    String? locationLabel,
    bool isUserLocation = false,
  }) {
    final zone = zoneAt(position);
    final nearest = nearestEvacuationPoint(position);
    final prefix = isUserLocation
        ? 'Lokasi Anda'
        : (locationLabel != null && locationLabel.trim().isNotEmpty
              ? locationLabel.trim()
              : 'Lokasi yang dipilih');

    if (zone != null) {
      final statusTitle =
          '$prefix berada di ${zone.title} (Risiko ${zone.riskLevel}).';
      final statusMessage =
          '$statusTitle Jenis potensi bencana: ${zone.disasterType}. ${zone.evacuationInfo}';

      return EvacuationLocationAssessment(
        position: position,
        inMappedZone: true,
        statusTitle: statusTitle,
        statusMessage: statusMessage,
        zone: zone,
        nearestPoint: nearest,
        locationLabel: locationLabel,
        selection: EvacuationMapSelection(
          title: zone.title,
          description: zone.description,
          position: position,
          color: zone.color,
          areaName: locationLabel ?? zone.areaName,
          disasterType: zone.disasterType,
          riskLevel: zone.riskLevel,
          evacuationInfo: zone.evacuationInfo,
          nearestPoint: nearest,
        ),
      );
    }

    const statusTitle =
        'Zona risiko belum tersedia untuk lokasi tersebut.';
    final statusMessage =
        '$prefix berada di luar zona bencana yang terpetakan saat ini. Titik evakuasi terdekat dari posisi ini adalah ${nearest.point.name} (${nearest.formattedDistance}).';

    return EvacuationLocationAssessment(
      position: position,
      inMappedZone: false,
      statusTitle: statusTitle,
      statusMessage: statusMessage,
      zone: null,
      nearestPoint: nearest,
      locationLabel: locationLabel,
      selection: EvacuationMapSelection(
        title: locationLabel ?? 'Di Luar Zona Terpetakan',
        description:
            'Zona risiko belum tersedia untuk lokasi tersebut pada pemetaan saat ini.',
        position: position,
        color: const Color(0xFF475569),
        areaName:
            locationLabel ??
            'Koordinat ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
        disasterType: 'Belum Terpetakan',
        riskLevel: 'Zona risiko belum tersedia',
        evacuationInfo:
            'Tetap pantau informasi resmi BPBD dan BMKG. Gunakan titik evakuasi resmi terdekat bila terjadi keadaan darurat.',
        nearestPoint: nearest,
      ),
    );
  }

  static EvacuationMapSelection selectionForPoint(EvacuationMapPoint point) {
    final zone = zoneAt(point.position);
    final nearest = nearestEvacuationPoint(point.position);

    return EvacuationMapSelection(
      title: point.name,
      description: point.description,
      position: point.position,
      color: const Color(0xFF16A34A),
      pointName: point.name,
      areaName: point.areaName,
      disasterType: zone?.disasterType ?? 'Titik Evakuasi & Instansi Darurat',
      riskLevel: zone != null ? '${zone.title} (Risiko ${zone.riskLevel})' : 'Titik Resmi',
      evacuationInfo:
          '${point.category} — ${point.description}. ${zone?.evacuationInfo ?? "Ikuti arahan petugas di lokasi."}',
      nearestPoint: nearest,
    );
  }

  static EvacuationMapSelection? selectionAt(LatLng position) {
    final nearest = nearestEvacuationPoint(position);

    for (final route in routes) {
      if (_isNearRoute(position, route.points)) {
        final zone = zoneAt(position);
        return EvacuationMapSelection(
          title: route.title,
          description: route.description,
          position: position,
          color: const Color(0xFFDC2626),
          areaName: zone?.areaName ?? 'Jalur Evakuasi Kota Padang',
          disasterType: zone?.disasterType ?? 'Jalur Evakuasi Tsunami & Gempa Bumi',
          riskLevel: zone != null ? '${zone.title} (Risiko ${zone.riskLevel})' : 'Jalur Evakuasi Resmi',
          evacuationInfo:
              '${route.description} Ikuti rambu evakuasi menuju dataran tinggi / Zona Aman.',
          nearestPoint: nearest,
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
          areaName: zone.areaName,
          disasterType: zone.disasterType,
          riskLevel: zone.riskLevel,
          evacuationInfo: zone.evacuationInfo,
          nearestPoint: nearest,
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

  static double _haversineDistanceKm(LatLng a, LatLng b) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLon = _degToRad(b.longitude - a.longitude);
    final lat1 = _degToRad(a.latitude);
    final lat2 = _degToRad(b.latitude);

    final sinDLat = math.sin(dLat / 2);
    final sinDLon = math.sin(dLon / 2);
    final h =
        sinDLat * sinDLat +
        math.cos(lat1) * math.cos(lat2) * sinDLon * sinDLon;
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return earthRadiusKm * c;
  }

  static double _degToRad(double degree) => degree * (math.pi / 180.0);
}

class EvacuationMapSelection {
  const EvacuationMapSelection({
    required this.title,
    required this.description,
    required this.position,
    required this.color,
    this.pointName,
    this.areaName,
    this.disasterType,
    this.riskLevel,
    this.evacuationInfo,
    this.nearestPoint,
  });

  final String title;
  final String description;
  final LatLng position;
  final Color color;
  final String? pointName;
  final String? areaName;
  final String? disasterType;
  final String? riskLevel;
  final String? evacuationInfo;
  final EvacuationNearestPoint? nearestPoint;
}
