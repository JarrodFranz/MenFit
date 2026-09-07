import 'package:flutter/foundation.dart';

/// Whether this platform supports the app's spoken voice cues.
///
/// True on Android and iOS where `flutter_tts` has native audio focus
/// management and background audio ducking.
///
/// False on Web (browsers cannot duck background audio and block un-gestured
/// audio speech) and desktop targets (Windows plugin has known
/// MissingPluginException limitations).
///
/// Mirrors the pattern in `core/platform/audio/audio_cue_support.dart`
/// and `core/platform/barcode_scanning.dart`.
bool get speechSupport {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}
