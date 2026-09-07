/// The `dart:io` seam for OCR.
///
/// Two things on this side of the port need `dart:io` and therefore cannot
/// be compiled into a web build:
///
/// 1. `MlKitOcrAdapter`, because `google_mlkit_commons` imports `dart:io`
///    unconditionally. A single import of it from web-reachable code breaks
///    `flutter build web` at compile time, not at runtime — which is the
///    worst kind of break, because nothing on this Windows dev machine
///    notices until the web build runs.
/// 2. Deleting the captured photo, which is `File.delete` and has no
///    web-safe equivalent.
///
/// Same mechanism as `core/platform/health/health_platform_adapter.dart`.
/// Import this file; never import `ml_kit_ocr_adapter.dart` directly
/// outside it.
library;

export 'package:menfit_app/core/platform/ocr/ocr_platform_stub.dart'
    if (dart.library.io) 'package:menfit_app/core/platform/ocr/ocr_platform_io.dart';
