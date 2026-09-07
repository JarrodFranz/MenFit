import 'package:flutter/foundation.dart';

/// Whether this platform has a health platform to read at all — Health
/// Connect on Android, HealthKit on iOS.
///
/// This is the **compile-target** question, answered synchronously and
/// without touching a plugin, so a provider can branch on it before it has
/// an adapter. It is deliberately weaker than
/// `HealthPlatformAdapter.isSupported()`, which additionally asks Android
/// whether Health Connect is actually installed and usable — that answer
/// needs a platform call and can only be a `Future`. Use this to decide
/// whether the feature exists here; use the adapter to decide whether it
/// works right now.
///
/// The check is [kIsWeb] first and then [defaultTargetPlatform],
/// deliberately without a `dart:io` `Platform` import — mirroring
/// `core/platform/barcode_scanning.dart` and
/// `core/platform/location/geolocator_location_adapter.dart`. `dart:io` does
/// not merely fail at runtime on web, it **fails to compile** there, so a
/// `Platform.isX` check in a web-reachable file would break
/// `flutter build web` outright (the same trap `package_decisions.md`
/// records for `health` itself). The [kIsWeb] test has to come first,
/// because on web [defaultTargetPlatform] reports the *browser's host OS*
/// and returns [TargetPlatform.android] on an Android phone.
///
/// Windows, macOS and Linux return false for the plain reason that neither
/// Health Connect nor HealthKit exists there; the app shows step history
/// already synced by a phone, and says honestly that nothing new can be read.
bool get healthPlatformSupported {
  if (kIsWeb) return false;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    TargetPlatform.fuchsia ||
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows => false,
  };
}
