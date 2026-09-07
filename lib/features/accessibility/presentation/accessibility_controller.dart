import 'package:flutter_riverpod/misc.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/features/accessibility/data/accessibility_repository.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accessibility_controller.g.dart';

/// Provider for the [AccessibilityRepository].
@Riverpod(keepAlive: true)
AccessibilityRepository accessibilityRepository(Ref ref) {
  try {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AccessibilityRepository(prefs);
  } on ProviderException catch (error) {
    if (error.exception is! UnimplementedError) rethrow;
    return const AccessibilityRepository(null);
  }
}

/// State notifier managing user accessibility preferences.
@Riverpod(keepAlive: true)
class AccessibilityController extends _$AccessibilityController {
  @override
  AccessibilityPreferences build() {
    final repository = ref.watch(accessibilityRepositoryProvider);
    return repository.getPreferences();
  }

  /// Sets the color blindness adaptation mode.
  Future<void> setColorBlindness(ColorBlindnessMode mode) async {
    final updated = state.copyWith(colorBlindness: mode);
    state = updated;
    await ref.read(accessibilityRepositoryProvider).setPreferences(updated);
  }

  /// Toggles high contrast mode.
  Future<void> setHighContrast({required bool enabled}) async {
    final updated = state.copyWith(highContrast: enabled);
    state = updated;
    await ref.read(accessibilityRepositoryProvider).setPreferences(updated);
  }

  /// Sets the text scaling preset factor.
  Future<void> setTextScale(TextScalePreset preset) async {
    final updated = state.copyWith(textScale: preset);
    state = updated;
    await ref.read(accessibilityRepositoryProvider).setPreferences(updated);
  }

  /// Toggles bold text typography across all styles.
  Future<void> setBoldText({required bool enabled}) async {
    final updated = state.copyWith(boldText: enabled);
    state = updated;
    await ref.read(accessibilityRepositoryProvider).setPreferences(updated);
  }

  /// Toggles reduced motion (disabling transitions/animations).
  Future<void> setReduceMotion({required bool enabled}) async {
    final updated = state.copyWith(reduceMotion: enabled);
    state = updated;
    await ref.read(accessibilityRepositoryProvider).setPreferences(updated);
  }

  /// Toggles large touch targets (48x48dp min bounding box).
  Future<void> setLargeTouchTargets({required bool enabled}) async {
    final updated = state.copyWith(largeTouchTargets: enabled);
    state = updated;
    await ref.read(accessibilityRepositoryProvider).setPreferences(updated);
  }

  /// Toggles haptic feedback pulses.
  Future<void> setHapticFeedback({required bool enabled}) async {
    final updated = state.copyWith(hapticFeedback: enabled);
    state = updated;
    await ref.read(accessibilityRepositoryProvider).setPreferences(updated);
  }

  /// Toggles the transition/interval sound cue.
  Future<void> setSoundCues({required bool enabled}) async {
    final updated = state.copyWith(soundCues: enabled);
    state = updated;
    await ref.read(accessibilityRepositoryProvider).setPreferences(updated);
  }

  /// Toggles enhanced screen reader semantic announcements.
  Future<void> setEnhancedSemantics({required bool enabled}) async {
    final updated = state.copyWith(enhancedSemantics: enabled);
    state = updated;
    await ref.read(accessibilityRepositoryProvider).setPreferences(updated);
  }

  /// Resets all preferences to default.
  Future<void> resetDefaults() async {
    state = AccessibilityPreferences.defaults;
    await ref.read(accessibilityRepositoryProvider).resetDefaults();
  }
}
