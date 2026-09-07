import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';

void main() {
  group('AppTokens Accessibility Color Palettes', () {
    test('standard mode produces default brand tokens', () {
      final lightTokens = AppTokens.light();
      final darkTokens = AppTokens.dark();

      expect(lightTokens.intensityHard, equals(const Color(0xFFD64D6E)));
      expect(darkTokens.intensityHard, equals(const Color(0xFFE68A9C)));
      expect(lightTokens.success, equals(const Color(0xFF1B8755)));
    });

    test('protanopia & deuteranopia use Okabe-Ito accessible palette', () {
      final tokens = AppTokens.light(
        const AccessibilityPreferences(
          colorBlindness: ColorBlindnessMode.deuteranopia,
        ),
      );

      // In Okabe-Ito, the hardest intensity is vermilion (#D55E00) and
      // success is blue (#0072B2)
      expect(tokens.intensityHard, equals(const Color(0xFFD55E00)));
      expect(tokens.success, equals(const Color(0xFF0072B2)));
      expect(tokens.warning, equals(const Color(0xFFE69F00)));
      // Distinct hues across all 3 workout intensities
      expect(
        {
          tokens.intensityEasy,
          tokens.intensityModerate,
          tokens.intensityHard,
        }.length,
        equals(3),
      );
    });

    test('tritanopia uses cyan/teal/crimson palette', () {
      final tokens = AppTokens.light(
        const AccessibilityPreferences(
          colorBlindness: ColorBlindnessMode.tritanopia,
        ),
      );

      expect(tokens.intensityHard, equals(const Color(0xFFD90429)));
      expect(tokens.intensityEasy, equals(const Color(0xFF00A896)));
      expect(
        {
          tokens.intensityEasy,
          tokens.intensityModerate,
          tokens.intensityHard,
        }.length,
        equals(3),
      );
    });

    test('monochromacy uses grayscale tokens', () {
      final tokens = AppTokens.light(
        const AccessibilityPreferences(
          colorBlindness: ColorBlindnessMode.monochromacy,
        ),
      );

      expect(tokens.intensityHard, equals(const Color(0xFF111111)));
      expect(tokens.intensityModerate, equals(const Color(0xFF444444)));
      expect(tokens.intensityEasy, equals(const Color(0xFF777777)));
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
