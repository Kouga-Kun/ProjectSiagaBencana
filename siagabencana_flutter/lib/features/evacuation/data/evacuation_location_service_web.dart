import 'dart:async';
import 'dart:js_interop';

import 'evacuation_location_service.dart';

@JS('navigator.geolocation')
external _Geolocation? get _geolocation;

extension type _Geolocation._(JSObject _) implements JSObject {
  external void getCurrentPosition(
    JSFunction successCallback, [
    JSFunction? errorCallback,
    _PositionOptions? options,
  ]);
}

extension type _PositionOptions._(JSObject _) implements JSObject {
  external factory _PositionOptions({
    bool? enableHighAccuracy,
    int? timeout,
    int? maximumAge,
  });
}

extension type _GeolocationPosition._(JSObject _) implements JSObject {
  external _GeolocationCoordinates get coords;
}

extension type _GeolocationCoordinates._(JSObject _) implements JSObject {
  external double get latitude;
  external double get longitude;
  external double? get accuracy;
}

extension type _GeolocationPositionError._(JSObject _) implements JSObject {
  external int get code;
  external String get message;
}

Future<EvacuationUserCoordinates> fetchEvacuationUserLocation() {
  final geo = _geolocation;
  if (geo == null) {
    return Future.error(
      const EvacuationLocationException(
        'Browser Anda tidak mendukung fitur pelacakan lokasi (GPS). Gunakan fitur pencarian lokasi pada peta.',
      ),
    );
  }

  final completer = Completer<EvacuationUserCoordinates>();

  void completeError(String message, {bool isPermissionDenied = false}) {
    if (!completer.isCompleted) {
      completer.completeError(
        EvacuationLocationException(
          message,
          isPermissionDenied: isPermissionDenied,
        ),
      );
    }
  }

  geo.getCurrentPosition(
    ((_GeolocationPosition pos) {
      if (!completer.isCompleted) {
        final coords = pos.coords;
        completer.complete(
          EvacuationUserCoordinates(
            latitude: coords.latitude,
            longitude: coords.longitude,
            accuracyMeters: coords.accuracy,
          ),
        );
      }
    }).toJS,
    ((_GeolocationPositionError error) {
      final isDenied = error.code == 1;
      final message = switch (error.code) {
        1 =>
          'Izin akses lokasi ditolak oleh pengguna. Aktifkan izin lokasi pada browser untuk mengetahui zona risiko bencana di posisi Anda.',
        2 =>
          'Informasi posisi GPS perangkat belum dapat ditentukan saat ini. Pastikan layanan lokasi aktif atau gunakan kotak pencarian lokasi.',
        3 =>
          'Waktu permintaan lokasi GPS habis. Silakan coba lagi atau gunakan kotak pencarian lokasi.',
        _ =>
          'Lokasi perangkat belum dapat diambil. Silakan coba lagi atau cari lokasi melalui search bar.',
      };
      completeError(message, isPermissionDenied: isDenied);
    }).toJS,
    _PositionOptions(
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 0,
    ),
  );

  return completer.future;
}

