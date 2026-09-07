import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/accessibility/data/accessibility_repository.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AccessibilityPreferences', () {
    test('defaults have expected initial values', () {
      const prefs = AccessibilityPreferences.defaults;
      expect(prefs.colorBlindness, equals(ColorBlindnessMode.none));
      expect(prefs.highContrast, isFalse);
      expect(prefs.textScale, equals(TextScalePreset.system));
      expect(prefs.boldText, isFalse);
      expect(prefs.reduceMotion, isFalse);
      expect(prefs.largeTouchTargets, isFalse);
      expect(prefs.hapticFeedback, isTrue);
      expect(prefs.soundCues, isTrue);
      expect(prefs.enhancedSemantics, isFalse);
    });

    test('copyWith properly updates fields', () {
      const prefs = AccessibilityPreferences.defaults;
      final updated = prefs.copyWith(
        colorBlindness: ColorBlindnessMode.deuteranopia,
        highContrast: true,
        textScale: TextScalePreset.huge,
        boldText: true,
        reduceMotion: true,
        largeTouchTargets: true,
        hapticFeedback: false,
        soundCues: false,
        enhancedSemantics: true,
      );

      expect(updated.colorBlindness, equals(ColorBlindnessMode.deuteranopia));
      expect(updated.highContrast, isTrue);
      expect(updated.textScale, equals(TextScalePreset.huge));
      expect(updated.boldText, isTrue);
      expect(updated.reduceMotion, isTrue);
      expect(updated.largeTouchTargets, isTrue);
      expect(updated.hapticFeedback, isFalse);
      expect(updated.soundCues, isFalse);
      expect(updated.enhancedSemantics, isTrue);
    });

    test('equality and hashCode work as value objects', () {
      const a = AccessibilityPreferences(
        colorBlindness: ColorBlindnessMode.protanopia,
        highContrast: true,
      );
      const b = AccessibilityPreferences(
        colorBlindness: ColorBlindnessMode.protanopia,
        highContrast: true,
      );
      const c = AccessibilityPreferences(
        colorBlindness: ColorBlindnessMode.tritanopia,
        highContrast: true,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('AccessibilityRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('returns defaults when preferences are empty', () async {
      final prefs = await SharedPreferences.getInstance();
      final repository = AccessibilityRepository(prefs);

      final result = repository.getPreferences();
      expect(result, equals(AccessibilityPreferences.defaults));
    });

    test('persists and retrieves updated preferences', () async {
      final prefs = await SharedPreferences.getInstance();
      final repository = AccessibilityRepository(prefs);

      const custom = AccessibilityPreferences(
        colorBlindness: ColorBlindnessMode.tritanopia,
        highContrast: true,
        textScale: TextScalePreset.extraLarge,
        boldText: true,
        reduceMotion: true,
        largeTouchTargets: true,
        hapticFeedback: false,
        soundCues: false,
        enhancedSemantics: true,
      );

      await repository.setPreferences(custom);
      final retrieved = repository.getPreferences();

      expect(retrieved, equals(custom));
    });

    test('resetDefaults clears persisted accessibility keys', () async {
      final prefs = await SharedPreferences.getInstance();
      final repository = AccessibilityRepository(prefs);

      await repository.setPreferences(
        const AccessibilityPreferences(
          colorBlindness: ColorBlindnessMode.monochromacy,
          highContrast: true,
        ),
      );

      await repository.resetDefaults();
      final result = repository.getPreferences();

      expect(result, equals(AccessibilityPreferences.defaults));
    });
  });
}
