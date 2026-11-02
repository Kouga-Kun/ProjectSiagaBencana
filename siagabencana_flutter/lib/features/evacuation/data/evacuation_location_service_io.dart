import 'evacuation_location_service.dart';

Future<EvacuationUserCoordinates> fetchEvacuationUserLocation() async {
  throw const EvacuationLocationException(
    'Layanan GPS otomatis tidak tersedia pada platform ini. Silakan gunakan kotak pencarian lokasi pada peta.',
  );
}

