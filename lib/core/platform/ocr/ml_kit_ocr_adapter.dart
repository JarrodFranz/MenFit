import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:menfit_app/core/platform/ocr/ocr_adapter.dart';

/// The one file in the app allowed to import
/// `google_mlkit_text_recognition` (pinned by
/// `test/core/platform/ocr/ocr_import_guard_test.dart`).
///
/// It is also the one file that must never be reached from a web build:
/// `google_mlkit_commons` imports `dart:io` unconditionally, which does not
/// merely fail at runtime on web, it fails to compile. `ocr_platform.dart`
/// is the conditional seam that keeps this file out of the web compile —
/// import that, not this.
///
/// Everything platform-shaped about recognition lives here: the recogniser
/// lifecycle, the `InputImage` construction, and the mapping of ML Kit's
/// types onto the Flutter-free [OcrResult] family the parser reads.
final class MlKitOcrAdapter implements OcrAdapter {
  /// [recognizer] is injectable so the mapping and the lifecycle can be
  /// exercised without a device; production code constructs it with no
  /// arguments (see `ocr_platform_io.dart`).
  /// `TextRecognizer`'s default script is Latin, which is the one this
  /// feature needs (FSANZ/FDA/EU panels); the argument is left off rather
  /// than restated because the analyzer rejects redundant defaults.
  MlKitOcrAdapter({TextRecognizer? recognizer})
    : _recognizer = recognizer ?? TextRecognizer();

  final TextRecognizer _recognizer;

  @override
  bool get isSupported => true;

  @override
  Future<OcrResult> recognize(OcrImage image) async =>
      mapRecognizedText(await _recognizer.processImage(toInputImage(image)));

  @override
  Future<void> dispose() => _recognizer.close();
}

/// Maps an [OcrImage] onto the `InputImage` factory that matches it.
///
/// `InputImage.fromBitmap` is the raw-pixel one — despite the name it takes
/// plain RGBA bytes plus dimensions and derives the stride itself.
/// `InputImage.fromBytes` is deliberately not used: it wants planar camera
/// frames with format and row-stride metadata, which is a different thing
/// from an in-memory image.
@visibleForTesting
InputImage toInputImage(OcrImage image) => switch (image) {
  OcrImageFile(:final path) => InputImage.fromFilePath(path),
  OcrImageRawRgba(
    :final bytes,
    :final width,
    :final height,
    :final rotationDegrees,
  ) =>
    InputImage.fromBitmap(
      bitmap: bytes,
      width: width,
      height: height,
      rotation: rotationDegrees,
    ),
};

/// Maps ML Kit's recognition output onto the port's value types.
///
/// Public so it can be tested against constructed ML Kit objects without a
/// platform channel — `TextBlock`, `TextLine` and `TextElement` all have
/// public constructors, so the mapping is exercised for real rather than
/// against a stand-in that could drift from it.
///
/// `confidence` is copied through exactly as it arrives, `null` included.
/// ML Kit documents it as Android-only and it is reported to be null even
/// there; substituting a number would make an absent measurement
/// indistinguishable from a real one. `TextBlock` has no confidence at all,
/// which is why [OcrBlock] does not carry one.
@visibleForTesting
OcrResult mapRecognizedText(RecognizedText recognised) => OcrResult(
  fullText: recognised.text,
  blocks: recognised.blocks.map(_mapBlock).toList(growable: false),
);

OcrBlock _mapBlock(TextBlock block) => OcrBlock(
  text: block.text,
  box: _mapRect(block.boundingBox),
  lines: block.lines.map(_mapLine).toList(growable: false),
);

OcrLine _mapLine(TextLine line) => OcrLine(
  text: line.text,
  box: _mapRect(line.boundingBox),
  confidence: line.confidence,
  elements: line.elements.map(_mapElement).toList(growable: false),
);

OcrElement _mapElement(TextElement element) => OcrElement(
  text: element.text,
  box: _mapRect(element.boundingBox),
  confidence: element.confidence,
);

OcrRect _mapRect(Rect rect) => OcrRect(
  left: rect.left,
  top: rect.top,
  right: rect.right,
  bottom: rect.bottom,
);
