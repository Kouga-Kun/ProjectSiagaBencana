import 'dart:typed_data';

import 'profile_photo_picker_io.dart'
    if (dart.library.js_interop) 'profile_photo_picker_web.dart'
    as platform;

class PickedProfilePhoto {
  const PickedProfilePhoto({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;

  int get sizeInBytes => bytes.lengthInBytes;
}

typedef ProfilePhotoPicker = Future<PickedProfilePhoto?> Function();

Future<PickedProfilePhoto?> pickProfilePhotoFromDevice() =>
    platform.pickProfilePhotoFromDevice();
