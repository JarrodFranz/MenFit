import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';

void main() {
  group('AppTheme seed remapping and ColorScheme', () {
    test('seedFor maps each ColorBlindnessMode to its intended seed', () {
      expect(
        AppTheme.seedFor(ColorBlindnessMode.monochromacy),
        const Color(0xFF666666),
      );
      expect(
        AppTheme.seedFor(ColorBlindnessMode.protanopia),
        const Color(0xFF0072B2),
      );
      expect(
        AppTheme.seedFor(ColorBlindnessMode.deuteranopia),
        const Color(0xFF0072B2),
      );
      expect(
        AppTheme.seedFor(ColorBlindnessMode.tritanopia),
        const Color(0xFF028090),
      );
      expect(
        AppTheme.seedFor(ColorBlindnessMode.none),
        const Color(0xFF8F4C86),
      );
    });

    test('monochrome light theme has neutral achromatic primary & nav bar', () {
      const prefs = AccessibilityPreferences(
        colorBlindness: ColorBlindnessMode.monochromacy,
      );
      final theme = AppTheme.light(prefs);

      // Primary is charcoal/black, not orchid plum.
      expect(theme.colorScheme.primary, const Color(0xFF222222));
      expect(theme.colorScheme.surfaceTint, Colors.transparent);
      expect(
        theme.navigationBarTheme.indicatorColor,
        const Color(0xFFE8E8E8),
      );
    });

    test('monochrome dark theme has neutral achromatic primary & nav bar', () {
      const prefs = AccessibilityPreferences(
        colorBlindness: ColorBlindnessMode.monochromacy,
      );
      final theme = AppTheme.dark(prefs);

      expect(theme.colorScheme.primary, const Color(0xFFE0E0E0));
      expect(theme.colorScheme.surfaceTint, Colors.transparent);
      expect(
        theme.navigationBarTheme.indicatorColor,
        const Color(0xFF333333),
      );
    });

    test('protanopia theme seeds with Okabe-Ito blue', () {
      const prefs = AccessibilityPreferences(
        colorBlindness: ColorBlindnessMode.protanopia,
      );
      final theme = AppTheme.light(prefs);

      // Blue seed produces blue primary rather than purple.
      expect(
        theme.colorScheme.primary.b,
        greaterThan(theme.colorScheme.primary.r),
      );
    });
  });

  group('High-Contrast AppTokens', () {
    test('light theme high contrast switches to AAA compliant deep tones', () {
      const prefs = AccessibilityPreferences(highContrast: true);
      final tokens = AppTokens.light(prefs);

      expect(tokens.success, const Color(0xFF0D5A34));
      expect(tokens.warning, const Color(0xFF78350F));
      expect(tokens.cyclePhaseMenstrual, const Color(0xFF881337));
      expect(tokens.cyclePhaseFollicular, const Color(0xFF9A3412));
      expect(tokens.cyclePhaseOvulatory, const Color(0xFF115E59));
      expect(tokens.cyclePhaseLuteal, const Color(0xFF581C87));
    });

    test('dark theme high contrast switches to AAA compliant bright tones', () {
      const prefs = AccessibilityPreferences(highContrast: true);
      final tokens = AppTokens.dark(prefs);

      expect(tokens.success, const Color(0xFF6EE7B7));
      expect(tokens.warning, const Color(0xFFFDE047));
      expect(tokens.cyclePhaseMenstrual, const Color(0xFFFDA4AF));
      expect(tokens.cyclePhaseFollicular, const Color(0xFFFDBA74));
      expect(tokens.cyclePhaseOvulatory, const Color(0xFF5EEAD4));
      expect(tokens.cyclePhaseLuteal, const Color(0xFFD8B4FE));
    });

    test('monochromacy high contrast uses pure black/white anchors', () {
      const prefs = AccessibilityPreferences(
        colorBlindness: ColorBlindnessMode.monochromacy,
        highContrast: true,
      );
      final lightTokens = AppTokens.light(prefs);
      final darkTokens = AppTokens.dark(prefs);

      expect(lightTokens.success, const Color(0xFF000000));
      expect(lightTokens.cyclePhaseMenstrual, const Color(0xFF000000));
      expect(darkTokens.success, const Color(0xFFFFFFFF));
      expect(darkTokens.cyclePhaseMenstrual, const Color(0xFFFFFFFF));
    });
  });
}
