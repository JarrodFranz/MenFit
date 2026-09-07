import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Function signature for saving binary or text file data to the user's device
/// via an OS save dialog.
///
/// Returns the resulting file [Uri], or `null` if the user cancelled.
typedef FileSaver = Future<Uri?> Function({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
  String? dialogTitle,
});

/// Default file saver implementation invoking the native or web file picker.
Future<Uri?> saveWithFilePicker({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
  String? dialogTitle,
}) {
  return FilePicker.saveFile(
    fileName: fileName,
    bytes: bytes,
    mimeType: mimeType,
    dialogTitle: dialogTitle,
  );
}
