import 'package:flutter/foundation.dart';

/// Whether this platform can open the in-app barcode scanner
/// (`features/nutrition/presentation/barcode_scan_screen.dart`).
///
/// **Android and iOS only.** Every caller must gate the scan entry point on
/// this; manual barcode entry
/// (`features/nutrition/domain/barcode.dart#validateBarcode`) is available
/// everywhere regardless, and is what the other platforms use instead.
///
/// The platform check is [kIsWeb] first and then [defaultTargetPlatform],
/// deliberately without a `dart:io` `Platform` import — mirroring
/// `platform/location/geolocator_location_adapter.dart`. `dart:io` is not
/// merely unusable on web, it fails to *compile* there, so a `Platform.isX`
/// check would break `flutter build web` outright rather than throwing at
/// runtime. [defaultTargetPlatform] answers the same question and is web-safe;
/// the [kIsWeb] test still has to come first, because on web it reports the
/// *browser's* host OS and returns `TargetPlatform.android` on an Android
/// phone.
///
/// ## Why not Windows
///
/// There is no frame source to decode. `camera_windows` is published by
/// flutter.dev but is explicitly **not an endorsed implementation**, and it
/// has never implemented `startImageStream`. Without a stream of frames
/// nothing can be fed to any decoder, so this is an upstream platform gap
/// rather than a consequence of picking `mobile_scanner`: swapping in a
/// different barcode library changes nothing, because the missing piece is
/// underneath all of them.
///
/// ## Why not Web
///
/// A privacy cost we are not willing to pay silently. `mobile_scanner`'s web
/// backend uses the browser's native `BarcodeDetector` where it exists, but
/// **falls back to fetching a ~2 MB zxing-wasm bundle from the jsDelivr CDN**
/// (and a legacy zxing-js build from unpkg for older browsers). No image data
/// is transmitted — decoding still happens in the page — but merely *opening
/// the scanner* would disclose the user's IP address and a
/// scanning-a-food-barcode-shaped request to a third party who has no reason
/// to know either. That is the sort of thing this app does not do quietly.
///
/// Web scanning can be enabled later without changing that stance, by
/// self-hosting the wasm bundle under `web/` — the same drill already run for
/// `sqlite3.wasm` and `drift_worker.js`
/// (`knowledge/troubleshooting/dependency_resolution.md`) — and calling
/// `MobileScannerPlatform.instance.setBarcodeLibraryScriptUrl(...)` with the
/// local path. **The precondition is that the call happens before the
/// scanner's first use**; the URL is read when the reader is created, so
/// setting it after a preview has started leaves the CDN fetch already made.
/// Doing that is a deliberate piece of work with its own asset-versioning
/// burden, not a flag flip, which is why this returns `false` today.
///
/// macOS and Linux return `false` for the plainer reason that this app has no
/// desktop-camera story at all yet; if a macOS build ever needs one,
/// `mobile_scanner` does support it and this is the single line to revisit.
bool get barcodeScanningSupported {
  if (kIsWeb) return false;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    TargetPlatform.fuchsia ||
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows => false,
  };
}
