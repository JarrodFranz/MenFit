import 'package:menfit_app/core/platform/ocr/ocr_adapter.dart';
import 'package:menfit_app/core/platform/ocr/unsupported_ocr_adapter.dart';

/// Web implementation of the `ocr_platform.dart` seam. Never selected on a
/// platform that has `dart:io`.

/// Web has no on-device recogniser (ADR 012), so there is only one answer.
OcrAdapter createOcrAdapter() => const UnsupportedOcrAdapter();

/// No-op: web never reaches the capture flow (the entry point is gated on
/// `textRecognitionSupported`), and `image_picker_for_web` hands back a
/// blob URL rather than a filesystem path, so there would be nothing to
/// unlink even if it did.
Future<void> deleteCapturedFile(String path) async {}
