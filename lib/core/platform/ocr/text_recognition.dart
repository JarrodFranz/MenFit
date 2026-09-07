import 'package:flutter/foundation.dart';

/// Whether this platform can run on-device text recognition, and therefore
/// whether the nutrition-label photo entry point may be shown at all
/// (ADR 012).
///
/// **Android and iOS only.** Every caller must gate the "photograph the
/// label" affordance on this; manual entry and barcode lookup (ADR 010)
/// remain available everywhere and are what the other platforms use
/// instead. Nothing about the food diary depends on OCR existing.
///
/// The platform check is [kIsWeb] first and then [defaultTargetPlatform],
/// deliberately without a `dart:io` `Platform` import — the same reasoning
/// as `core/platform/barcode_scanning.dart`. `dart:io` is not merely
/// unusable on web, it fails to *compile* there, so a `Platform.isX` check
/// would break `flutter build web` outright rather than throwing at
/// runtime. [defaultTargetPlatform] answers the same question and is
/// web-safe; the [kIsWeb] test still has to come first, because on web it
/// reports the *browser's* host OS and returns [TargetPlatform.android] on
/// an Android phone.
///
/// ## Why not Windows
///
/// Two independent blockers, neither of them a package choice (ADR 012).
/// `Windows.Media.Ocr` — the only real on-device OCR on Windows — requires
/// package identity (MSIX or a sparse package), which an unpackaged
/// `flutter build windows` does not have; granting it is a
/// distribution-model decision, not an engineering one. And Windows has no
/// live camera frame source at all (`camera_windows` has never implemented
/// `startImageStream` — see the same note under `barcode_scanning.dart`),
/// so even with OCR available the flow would have to be "import a photo
/// file", not "point the camera".
///
/// ## Why not Web
///
/// There is no on-device OCR in the browser without shipping one. The
/// candidate, Tesseract.js, needs a self-hosted WASM binary plus
/// `.traineddata` under `web/` — self-hosted rather than CDN-loaded, for
/// exactly the privacy reason that keeps web barcode scanning switched off
/// — plus a hand-written `dart:js_interop` bridge. That is a few days of
/// deliberate work with its own asset-versioning burden, deferred rather
/// than rejected (ADR 012), which is why this returns `false` today.
///
/// A second, harder reason applies regardless: `google_mlkit_commons`
/// imports `dart:io` unconditionally, so the ML Kit adapter cannot even be
/// compiled into a web build. It is reached through the conditional
/// `ocr_platform.dart` seam for that reason, and this flag is what the UI
/// asks.
///
/// macOS and Linux return `false` for the plainer reason that this app has
/// no desktop-camera story at all, and ML Kit does not support them.
bool get textRecognitionSupported {
  if (kIsWeb) return false;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    TargetPlatform.fuchsia ||
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows => false,
  };
}
