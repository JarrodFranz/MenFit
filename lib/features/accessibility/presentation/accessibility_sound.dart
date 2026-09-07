import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_providers.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_controller.dart';

/// Audio cues that honour the user's Sound Cues preference.
///
/// Every sound the app makes goes through here, for the reason
/// `AccessibilityHaptics` exists in the same shape: a preference checked at
/// each call site is a preference that is *invisible where it is missing*,
/// so the next cue somebody adds is unguarded by default. One funnel
/// inverts that — the guard is what you get unless you deliberately reach
/// past it to `audioCuePlayerProvider`.
///
/// Two entry points because Riverpod's [WidgetRef] and [Ref] share no
/// public supertype: [transitionChime] for widgets, [transitionChimeFor]
/// for controllers and other provider-scoped code. They do the same thing.
///
/// The returned future completes when playback has been *asked for*, not
/// when the chime finishes, and never with an error — the player swallows
/// its own failures (see `core/platform/audio/audio_cue_player.dart`).
/// Call sites are free to `unawaited(...)` it.
///
/// A cue is never the only signal for anything: the phone may be silenced,
/// the gym may be loud, and web and Windows have no haptics to fall back
/// on. The visual channel carries every boundary on its own (ADR 014).
abstract final class AccessibilitySound {
  /// Prepares the cue from a **user gesture** — the Start tap of a practice
  /// or an interval workout, never a controller's `build`.
  ///
  /// Browsers refuse audio that no gesture led to, and the gesture that
  /// counts is the one on the call stack: preloading later, from a timer,
  /// leaves the first real cue silently dropped. It also moves the file
  /// decode off the transition path.
  ///
  /// Skipped entirely when sound cues are off, so nothing touches the audio
  /// session for a user who has turned them off.
  static Future<void> preload(WidgetRef ref) {
    if (!ref.read(accessibilityControllerProvider).soundCues) {
      return Future<void>.value();
    }
    return ref.read(audioCuePlayerProvider).preload();
  }

  /// The chime that marks a boundary: a pose transition, an interval change.
  static Future<void> transitionChime(WidgetRef ref) {
    if (!ref.read(accessibilityControllerProvider).soundCues) {
      return Future<void>.value();
    }
    return ref.read(audioCuePlayerProvider).playTransitionChime();
  }

  /// [transitionChime] for provider-scoped code (a controller's [Ref]).
  static Future<void> transitionChimeFor(Ref ref) {
    if (!ref.read(accessibilityControllerProvider).soundCues) {
      return Future<void>.value();
    }
    return ref.read(audioCuePlayerProvider).playTransitionChime();
  }

  /// [preload] for provider-scoped code. The gesture rule still applies:
  /// only call this on the synchronous path out of a user's tap.
  static Future<void> preloadFor(Ref ref) {
    if (!ref.read(accessibilityControllerProvider).soundCues) {
      return Future<void>.value();
    }
    return ref.read(audioCuePlayerProvider).preload();
  }
}
