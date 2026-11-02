import 'evacuation_location_service_io.dart'
    if (dart.library.js_interop) 'evacuation_location_service_web.dart'
    as platform;

class EvacuationUserCoordinates {
  const EvacuationUserCoordinates({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
}

class EvacuationLocationException implements Exception {
  const EvacuationLocationException(
    this.message, {
    this.isPermissionDenied = false,
  });

  final String message;
  final bool isPermissionDenied;

  @override
  String toString() => message;
}

typedef EvacuationLocationFetcher = Future<EvacuationUserCoordinates> Function();

Future<EvacuationUserCoordinates> fetchEvacuationUserLocation() =>
    platform.fetchEvacuationUserLocation();

