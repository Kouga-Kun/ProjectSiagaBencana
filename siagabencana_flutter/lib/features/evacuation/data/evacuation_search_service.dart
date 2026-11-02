import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'evacuation_map_data.dart';

class EvacuationSearchResult {
  const EvacuationSearchResult({
    required this.title,
    required this.subtitle,
    required this.position,
    this.isOfficialPoint = false,
  });

  final String title;
  final String subtitle;
  final LatLng position;
  final bool isOfficialPoint;
}

class EvacuationSearchException implements Exception {
  const EvacuationSearchException(this.message);

  final String message;

  @override
  String toString() => message;
}

class EvacuationSearchService {
  EvacuationSearchService({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  Future<List<EvacuationSearchResult>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final normalized = trimmed.toLowerCase();
    final localMatches = <EvacuationSearchResult>[
      for (final point in EvacuationMapData.points)
        if (point.name.toLowerCase().contains(normalized) ||
            point.description.toLowerCase().contains(normalized) ||
            point.areaName.toLowerCase().contains(normalized) ||
            point.category.toLowerCase().contains(normalized))
          EvacuationSearchResult(
            title: point.name,
            subtitle: '${point.category} • ${point.areaName} (${point.description})',
            position: point.position,
            isOfficialPoint: true,
          ),
    ];

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': trimmed,
        'format': 'jsonv2',
        'addressdetails': '1',
        'limit': '6',
        'countrycodes': 'id',
      });

      final response = await _client
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Accept-Language': 'id,en',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (localMatches.isNotEmpty) {
          return localMatches;
        }
        throw EvacuationSearchException(
          'Layanan pencarian lokasi mengembalikan status ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List) {
        return localMatches;
      }

      final geocoded = <EvacuationSearchResult>[];
      for (final raw in decoded.whereType<Map>()) {
        final item = Map<String, dynamic>.from(raw);
        final lat = double.tryParse(item['lat']?.toString() ?? '');
        final lon = double.tryParse(item['lon']?.toString() ?? '');
        if (lat == null || lon == null) {
          continue;
        }

        final displayName = item['display_name']?.toString().trim() ?? '';
        final rawName = item['name']?.toString().trim() ?? '';
        final parts = displayName
            .split(',')
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();

        final title = rawName.isNotEmpty
            ? rawName
            : (parts.isNotEmpty ? parts.first : trimmed);
        final subtitle = displayName.isNotEmpty
            ? displayName
            : 'Koordinat ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';

        geocoded.add(
          EvacuationSearchResult(
            title: title,
            subtitle: subtitle,
            position: LatLng(lat, lon),
          ),
        );
      }

      return [...localMatches, ...geocoded];
    } on EvacuationSearchException {
      if (localMatches.isNotEmpty) {
        return localMatches;
      }
      rethrow;
    } on TimeoutException {
      if (localMatches.isNotEmpty) {
        return localMatches;
      }
      throw const EvacuationSearchException(
        'Waktu pencarian lokasi habis. Periksa koneksi internet lalu coba lagi.',
      );
    } catch (_) {
      if (localMatches.isNotEmpty) {
        return localMatches;
      }
      throw const EvacuationSearchException(
        'Pencarian lokasi belum dapat dilakukan saat ini. Periksa koneksi internet.',
      );
    }
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}

