import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists accessibility settings in [SharedPreferences].
class AccessibilityRepository {
  const AccessibilityRepository(this._preferences);

  final SharedPreferences? _preferences;

  static const String _colorBlindnessKey = 'accessibility_color_blindness';
  static const String _highContrastKey = 'accessibility_high_contrast';
  static const String _textScaleKey = 'accessibility_text_scale';
  static const String _boldTextKey = 'accessibility_bold_text';
  static const String _reduceMotionKey = 'accessibility_reduce_motion';
  static const String _largeTouchTargetsKey =
      'accessibility_large_touch_targets';
  static const String _hapticFeedbackKey = 'accessibility_haptic_feedback';

  /// Absent for every install that predates the sound cue (ADR 014), which
  /// is why [getPreferences] reads a missing value as `true`: an existing
  /// user gets the same default a new one does, not silence.
  static const String _soundCuesKey = 'accessibility_sound_cues';
  static const String _enhancedSemanticsKey =
      'accessibility_enhanced_semantics';

  /// Loads the persisted accessibility preferences.
  AccessibilityPreferences getPreferences() {
    final prefs = _preferences;
    if (prefs == null) return AccessibilityPreferences.defaults;

    final colorBlindnessStr = prefs.getString(_colorBlindnessKey);
    final colorBlindness = ColorBlindnessMode.values.firstWhere(
      (m) => m.name == colorBlindnessStr,
      orElse: () => ColorBlindnessMode.none,
    );

    final textScaleStr = prefs.getString(_textScaleKey);
    final textScale = TextScalePreset.values.firstWhere(
      (s) => s.name == textScaleStr,
      orElse: () => TextScalePreset.system,
    );

    return AccessibilityPreferences(
      colorBlindness: colorBlindness,
      highContrast: prefs.getBool(_highContrastKey) ?? false,
      textScale: textScale,
      boldText: prefs.getBool(_boldTextKey) ?? false,
      reduceMotion: prefs.getBool(_reduceMotionKey) ?? false,
      largeTouchTargets: prefs.getBool(_largeTouchTargetsKey) ?? false,
      hapticFeedback: prefs.getBool(_hapticFeedbackKey) ?? true,
      soundCues: prefs.getBool(_soundCuesKey) ?? true,
      enhancedSemantics: prefs.getBool(_enhancedSemanticsKey) ?? false,
    );
  }

  /// Persists full [preferences].
  Future<void> setPreferences(AccessibilityPreferences preferences) async {
    final prefs = _preferences;
    if (prefs == null) return;

    await Future.wait([
      prefs.setString(_colorBlindnessKey, preferences.colorBlindness.name),
      prefs.setBool(_highContrastKey, preferences.highContrast),
      prefs.setString(_textScaleKey, preferences.textScale.name),
      prefs.setBool(_boldTextKey, preferences.boldText),
      prefs.setBool(_reduceMotionKey, preferences.reduceMotion),
      prefs.setBool(_largeTouchTargetsKey, preferences.largeTouchTargets),
      prefs.setBool(_hapticFeedbackKey, preferences.hapticFeedback),
      prefs.setBool(_soundCuesKey, preferences.soundCues),
      prefs.setBool(_enhancedSemanticsKey, preferences.enhancedSemantics),
    ]);
  }

  /// Resets all accessibility preferences to system defaults.
  Future<void> resetDefaults() async {
    final prefs = _preferences;
    if (prefs == null) return;

    await Future.wait([
      prefs.remove(_colorBlindnessKey),
      prefs.remove(_highContrastKey),
      prefs.remove(_textScaleKey),
      prefs.remove(_boldTextKey),
      prefs.remove(_reduceMotionKey),
      prefs.remove(_largeTouchTargetsKey),
      prefs.remove(_hapticFeedbackKey),
      prefs.remove(_soundCuesKey),
      prefs.remove(_enhancedSemanticsKey),
    ]);
  }
}
