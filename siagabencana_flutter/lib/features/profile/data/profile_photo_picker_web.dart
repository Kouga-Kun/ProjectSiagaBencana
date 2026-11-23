import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'profile_photo_picker.dart';

@JS('document.createElement')
external _HTMLInputElement _createElement(String tagName);

extension type _HTMLInputElement._(JSObject _) implements JSObject {
  external set type(String value);
  external set accept(String value);
  external _FileList? get files;
  external void click();
  external void addEventListener(String type, JSFunction listener);
}

extension type _FileList._(JSObject _) implements JSObject {
  external int get length;
  external _WebFile? item(int index);
}

extension type _WebFile._(JSObject _) implements JSObject {
  external String get name;
  external int get size;
  external JSPromise<JSArrayBuffer> arrayBuffer();
}

Future<PickedProfilePhoto?> pickProfilePhotoFromDevice() {
  final completer = Completer<PickedProfilePhoto?>();
  final input = _createElement('input')
    ..type = 'file'
    ..accept = '.jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp';

  void completeSafe(PickedProfilePhoto? result) {
    if (!completer.isCompleted) {
      completer.complete(result);
    }
  }

  input.addEventListener(
    'change',
    ((JSAny? _) {
      unawaited(() async {
        try {
          final files = input.files;
          if (files == null || files.length == 0) {
            completeSafe(null);
            return;
          }
          final file = files.item(0);
          if (file == null) {
            completeSafe(null);
            return;
          }
          final buffer = await file.arrayBuffer().toDart;
          final Uint8List bytes = buffer.toDart.asUint8List();
          completeSafe(PickedProfilePhoto(bytes: bytes, fileName: file.name));
        } catch (_) {
          completeSafe(null);
        }
      }());
    }).toJS,
  );

  input.addEventListener(
    'cancel',
    ((JSAny? _) {
      completeSafe(null);
    }).toJS,
  );

  input.click();
  return completer.future;
}
