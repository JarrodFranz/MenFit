import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_controller.dart';

/// Haptics that honour the user's Haptic Feedback preference.
///
/// Every vibration in the app goes through here. The preference was being
/// checked at some call sites and not others, which is the failure mode a
/// per-call-site guard always has: the guard is invisible at the point
/// where it is missing, so the next `HapticFeedback.mediumImpact()`
/// somebody writes is unguarded by default. Routing them through one
/// entry point inverts that — the guard is the default, and skipping it
/// takes a deliberate direct call to [HapticFeedback].
///
/// Each method returns the platform future rather than swallowing it, so
/// call sites keep whatever they already do with it: `unawaited(...)` for
/// a fire-and-forget buzz, `await` where the caller sequences something
/// after it.
///
/// Intensity conventions, as used across the app:
/// - [lightImpact] — a correction or an undo (removing a lap).
/// - [mediumImpact] — an ordinary confirmation (a set started, a lap
///   counted, a share taken, a badge shown).
/// - [heavyImpact] — an interval boundary or a target reached: the pulses
///   that have to land when she is *not* looking at the screen.
abstract final class AccessibilityHaptics {
  static Future<void> lightImpact(WidgetRef ref) =>
      _fire(ref, HapticFeedback.lightImpact);

  static Future<void> mediumImpact(WidgetRef ref) =>
      _fire(ref, HapticFeedback.mediumImpact);

  static Future<void> heavyImpact(WidgetRef ref) =>
      _fire(ref, HapticFeedback.heavyImpact);

  static Future<void> _fire(WidgetRef ref, Future<void> Function() effect) {
    if (!ref.read(accessibilityControllerProvider).hapticFeedback) {
      return Future<void>.value();
    }
    return effect();
  }
}
