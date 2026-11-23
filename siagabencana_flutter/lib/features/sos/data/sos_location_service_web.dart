import 'dart:async';
import 'dart:js_interop';

import 'sos_location_service.dart';

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

Future<SosCoordinates> fetchCurrentDeviceLocation() {
  final geo = _geolocation;
  if (geo == null) {
    return Future.error(
      const SosLocationException(
        'Browser Anda tidak mendukung layanan lokasi (GPS). Silakan masukkan lokasi secara manual.',
      ),
    );
  }

  final completer = Completer<SosCoordinates>();

  void completeError(String message) {
    if (!completer.isCompleted) {
      completer.completeError(SosLocationException(message));
    }
  }

  geo.getCurrentPosition(
    ((_GeolocationPosition pos) {
      if (!completer.isCompleted) {
        final coords = pos.coords;
        completer.complete(
          SosCoordinates(
            latitude: coords.latitude,
            longitude: coords.longitude,
            accuracyMeters: coords.accuracy,
          ),
        );
      }
    }).toJS,
    ((_GeolocationPositionError error) {
      final message = switch (error.code) {
        1 =>
          'Izin akses lokasi ditolak pada browser. Aktifkan izin lokasi atau masukkan koordinat lokasi secara manual.',
        2 =>
          'Informasi lokasi GPS perangkat tidak dapat ditentukan. Silakan masukkan lokasi secara manual.',
        3 =>
          'Waktu pengambilan lokasi GPS habis. Silakan coba lagi atau masukkan lokasi secara manual.',
        _ =>
          'Lokasi GPS belum berhasil diperoleh. Silakan masukkan lokasi secara manual.',
      };
      completeError(message);
    }).toJS,
    _PositionOptions(
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 0,
    ),
  );

  return completer.future;
}
