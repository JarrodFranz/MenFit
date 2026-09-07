import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';

void main() {
  group('AppTokens Accessibility Color Palettes', () {
    test('standard mode produces default brand tokens', () {
      final lightTokens = AppTokens.light();
      final darkTokens = AppTokens.dark();

      expect(lightTokens.cyclePhaseMenstrual, equals(const Color(0xFFD64D6E)));
      expect(darkTokens.cyclePhaseMenstrual, equals(const Color(0xFFE68A9C)));
      expect(lightTokens.success, equals(const Color(0xFF1B8755)));
    });

    test('protanopia & deuteranopia use Okabe-Ito accessible palette', () {
      final tokens = AppTokens.light(
        const AccessibilityPreferences(
          colorBlindness: ColorBlindnessMode.deuteranopia,
        ),
      );

      // In Okabe-Ito, menstrual is vermilion (#D55E00) and success is
      // blue (#0072B2)
      expect(tokens.cyclePhaseMenstrual, equals(const Color(0xFFD55E00)));
      expect(tokens.success, equals(const Color(0xFF0072B2)));
      expect(tokens.warning, equals(const Color(0xFFE69F00)));
      // Distinct hues for all 4 phases
      expect(
        {
          tokens.cyclePhaseMenstrual,
          tokens.cyclePhaseFollicular,
          tokens.cyclePhaseOvulatory,
          tokens.cyclePhaseLuteal,
        }.length,
        equals(4),
      );
    });

    test('tritanopia uses cyan/teal/crimson palette', () {
      final tokens = AppTokens.light(
        const AccessibilityPreferences(
          colorBlindness: ColorBlindnessMode.tritanopia,
        ),
      );

      expect(tokens.cyclePhaseMenstrual, equals(const Color(0xFFD90429)));
      expect(tokens.cyclePhaseFollicular, equals(const Color(0xFF00A896)));
      expect(
        {
          tokens.cyclePhaseMenstrual,
          tokens.cyclePhaseFollicular,
          tokens.cyclePhaseOvulatory,
          tokens.cyclePhaseLuteal,
        }.length,
        equals(4),
      );
    });

    test('monochromacy uses grayscale tokens', () {
      final tokens = AppTokens.light(
        const AccessibilityPreferences(
          colorBlindness: ColorBlindnessMode.monochromacy,
        ),
      );

      expect(tokens.cyclePhaseMenstrual, equals(const Color(0xFF111111)));
      expect(tokens.cyclePhaseFollicular, equals(const Color(0xFF444444)));
      expect(tokens.cyclePhaseOvulatory, equals(const Color(0xFF666666)));
      expect(tokens.cyclePhaseLuteal, equals(const Color(0xFF888888)));
    });

    test('high contrast sets tighter corner radiuses', () {
      final normal = AppTokens.light();
      final highContrast = AppTokens.light(
        const AccessibilityPreferences(highContrast: true),
      );

      expect(highContrast.radiusSm, lessThan(normal.radiusSm));
      expect(highContrast.radiusMd, lessThan(normal.radiusMd));
      expect(highContrast.radiusLg, lessThan(normal.radiusLg));
    });
  });
}
