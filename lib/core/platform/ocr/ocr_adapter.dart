import 'dart:typed_data';

import 'package:menfit_app/core/domain/ocr/ocr_text.dart';

export 'package:menfit_app/core/domain/ocr/ocr_text.dart';

/// An image handed to [OcrAdapter.recognize].
///
/// Two variants because ML Kit takes two genuinely different things and
/// neither substitutes for the other:
///
/// - [OcrImageFile] — a path to an encoded image (a JPEG from the camera).
///   This is the phase-1 path: the OS camera app writes a file into the app
///   cache and hands back its path; there is no version of that flow that
///   avoids the file, so the file is deleted immediately after recognition
///   instead (`label_capture.dart`).
/// - [OcrImageRawRgba] — raw RGBA pixels already in memory, e.g. from
///   `ui.Image.toByteData(format: rawRgba)`. Nothing uses it yet; it exists
///   because it is the only in-memory path ML Kit actually accepts. Its
///   `fromBytes` sibling is for *planar camera frames* (nv21/yuv/bgra with
///   stride metadata), not encoded JPEG bytes, so "just pass the JPEG
///   bytes" is not an option that exists.
sealed class OcrImage {
  const OcrImage();

  /// An encoded image (JPEG/PNG) at [path] on the local filesystem.
  const factory OcrImage.file(String path) = OcrImageFile;

  /// Raw RGBA pixels, 4 bytes per pixel, [width] * [height] of them.
  ///
  /// [rotationDegrees] must be 0, 90, 180 or 270; anything else is treated
  /// as 0 by the platform. Android-only — iOS ignores it.
  const factory OcrImage.rawRgba({
    required Uint8List bytes,
    required int width,
    required int height,
    int rotationDegrees,
  }) = OcrImageRawRgba;
}

/// See [OcrImage.file].
final class OcrImageFile extends OcrImage {
  const OcrImageFile(this.path);

  final String path;
}

/// See [OcrImage.rawRgba].
final class OcrImageRawRgba extends OcrImage {
  const OcrImageRawRgba({
    required this.bytes,
    required this.width,
    required this.height,
    this.rotationDegrees = 0,
  });

  final Uint8List bytes;
  final int width;
  final int height;
  final int rotationDegrees;
}

/// Port for on-device text recognition (ADR 012).
///
/// Nothing outside `core/platform/ocr/` may import
/// `google_mlkit_text_recognition` or `image_picker` (architecture rule 4,
/// pinned by `test/core/platform/ocr/ocr_import_guard_test.dart`). Feature
/// code depends on this interface and gets the real implementation from
/// `ocrAdapterProvider`.
///
/// **Recognition is on-device and stays on-device.** The implementation
/// talks to a native `MethodChannel`; no image, crop, or recognised string
/// is sent anywhere, written to a log, or persisted. That is the whole
/// premise the feature was approved on, and an implementation of this
/// interface that phones out would violate it silently — so there is
/// exactly one, and it lives next to this file.
abstract interface class OcrAdapter {
  /// Whether this build can actually recognise anything. `false` on web,
  /// Windows, macOS and Linux, where [recognize] returns
  /// [OcrResult.unsupported] rather than throwing.
  ///
  /// Callers should gate their entry point on `textRecognitionSupported`
  /// (`text_recognition.dart`) instead — it answers the same question
  /// without constructing an adapter.
  bool get isSupported;

  /// Recognises text in [image].
  ///
  /// Returns [OcrResult.unsupported] where [isSupported] is `false`. May
  /// throw `PlatformException` on a real device — a corrupt file, a
  /// revoked permission — which the caller must handle; nothing here
  /// swallows it into an empty result, because "no text found" and
  /// "recognition failed" need different words in front of the user.
  Future<OcrResult> recognize(OcrImage image);

  /// Releases the native recogniser. Owned by `ocrAdapterProvider`, which
  /// calls this on dispose; feature code should not.
  Future<void> dispose();
}
