import 'dart:io';

import 'package:menfit_app/core/platform/ocr/ml_kit_ocr_adapter.dart';
import 'package:menfit_app/core/platform/ocr/ocr_adapter.dart';
import 'package:menfit_app/core/platform/ocr/text_recognition.dart';
import 'package:menfit_app/core/platform/ocr/unsupported_ocr_adapter.dart';

/// Native implementation of the `ocr_platform.dart` seam.

/// ML Kit where it exists, an honest refusal everywhere else.
///
/// `dart.library.io` is true on Windows, macOS and Linux as well as on the
/// phones, so this still has to ask [textRecognitionSupported] — the seam
/// only decides what can be *compiled*, not what can run.
OcrAdapter createOcrAdapter() => textRecognitionSupported
    ? MlKitOcrAdapter()
    : const UnsupportedOcrAdapter();

/// Deletes the captured photo at [path], best effort.
///
/// The photo of a food package is not something this app keeps: it is read
/// by the recogniser and unlinked in the same breath, never copied, never
/// moved into the gallery, never logged (security_and_privacy.md, S2).
/// This is the only thing standing between "we discard it" and a cache
/// directory that slowly fills with pictures of someone's kitchen, so it
/// runs from a `finally` on every path, cancellation and failure included.
///
/// Failures are swallowed and **not** logged: there is no recovery from a
/// failed unlink, reporting it would abort a recognition that already
/// succeeded, and platform exceptions quote their arguments — the path
/// included.
Future<void> deleteCapturedFile(String path) async {
  try {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  } on Object catch (_) {
    // Intentionally silent; see the doc comment above.
  }
}
