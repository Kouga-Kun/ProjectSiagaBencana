import 'sos_location_service.dart';

Future<SosCoordinates> fetchCurrentDeviceLocation() async {
  throw const SosLocationException(
    'Layanan GPS otomatis tidak tersedia pada perangkat ini. Silakan masukkan koordinat lokasi secara manual.',
  );
}
