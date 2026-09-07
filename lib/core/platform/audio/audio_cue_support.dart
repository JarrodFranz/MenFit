import 'package:flutter/foundation.dart';

/// Whether this platform can play the app's audio cues at all.
///
/// True on all four targets — `audioplayers` has a first-party
/// implementation for Android, iOS, web and Windows, and a bundled asset
/// needs no permission anywhere. It exists as a named flag rather than a
/// hard-coded `true` for the same reason
/// `core/platform/barcode_scanning.dart` does: the provider that picks
/// between the real player and the no-op has to ask *something*, and when a
/// platform does drop off this list the answer changes in one place instead
/// of at every call site.
///
/// The check is [kIsWeb] first and then [defaultTargetPlatform],
/// deliberately without a `dart:io` `Platform` import — mirroring
/// `core/platform/barcode_scanning.dart` and
/// `core/platform/health/health_platform_support.dart`. `dart:io` does not
/// merely fail at runtime on web, it **fails to compile** there. The [kIsWeb]
/// test still has to come first, because on web [defaultTargetPlatform]
/// reports the *browser's host OS*.
///
/// ## Caveat: Windows N and KN editions
///
/// `audioplayers_windows` is built on Windows Media Foundation, which is not
/// installed on the N and KN editions of Windows (the EU/Korea builds sold
/// without Windows Media Player) until the user installs the Media Feature
/// Pack. On those machines the plugin fails at **player creation**, and
/// because `AudioPlayer` creates itself asynchronously the failure surfaces on
/// the first awaited call rather than at construction — which is why
/// `AudioplayersCuePlayer` guards `preload()` and latches itself unavailable
/// instead of letting the exception escape onto the practice's start tap.
/// Treated as a degraded cue, never as a crash: the visual and haptic
/// channels carry the boundary on their own.
///
/// This flag stays `true` on Windows regardless. The N-edition case is not
/// detectable from Dart, it is a small minority of machines, and reporting
/// the whole platform unsupported to spare them would take the chime away
/// from every other Windows user.
bool get audioCueSupport {
  if (kIsWeb) return true;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS ||
    TargetPlatform.windows => true,
    TargetPlatform.fuchsia || TargetPlatform.linux => false,
  };
}

/// Whether this platform lowers other apps' audio for the duration of a cue.
///
/// **Android only, and on purpose.** Android's audio focus has an explicit
/// "transient, may duck" request, so their music dips under the chime and
/// comes back — the behaviour a cue over a playlist should have.
///
/// iOS has no equivalent that is worth taking: ducking there means an
/// `AVAudioSession` category change that also overrides the hardware silent
/// switch and can pause their music outright. ADR 014 chose the quieter
/// contract instead — `ambient` + `mixWithOthers`, which respects the silent
/// switch and mixes rather than interrupts. On web and Windows there is no
/// focus concept exposed at all; the cue simply plays over whatever else is
/// sounding.
///
/// Exposed so a settings or help surface can describe what actually happens
/// on the device in hand rather than making a claim that is true on one
/// platform.
bool get audioDuckingSupported =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
