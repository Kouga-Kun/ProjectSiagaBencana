import 'sos_location_service_io.dart'
    if (dart.library.js_interop) 'sos_location_service_web.dart'
    as platform;

class SosCoordinates {
  const SosCoordinates({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
}

class SosLocationException implements Exception {
  const SosLocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

typedef SosLocationFetcher = Future<SosCoordinates> Function();

Future<SosCoordinates> fetchCurrentDeviceLocation() =>
    platform.fetchCurrentDeviceLocation();
