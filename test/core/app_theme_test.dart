import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';

void main() {
  group('AppTheme variable font weights', () {
    // Inter (assets/fonts/Inter.ttf) is a variable font - `fontWeight`
    // alone doesn't select a weight on it. AppTheme must additionally set
    // an explicit `wght` FontVariation matching each style's fontWeight
    // (M3's default TextTheme spans w400 and w500) or every style silently
    // renders at the font's default instance regardless of fontWeight.
    // titleLarge and bodyMedium are both w400 in the M3 type scale, so
    // titleMedium (w500) is included too - a mapping that only ever
    // produces the w400 fallback (e.g. one reading fontWeight from
    // ThemeData.textTheme before Theme.of(context) has merged in the real
    // per-style geometry - see the doc comment on
    // AppTheme._withVariableWeights) would still pass a titleLarge/
    // bodyMedium-only assertion by coincidence.
    test('light textTheme sets wght FontVariation from fontWeight', () {
      final textTheme = AppTheme.light().textTheme;

      expect(
        textTheme.titleLarge!.fontVariations,
        contains(const FontVariation('wght', 400)),
      );
      expect(
        textTheme.bodyMedium!.fontVariations,
        contains(const FontVariation('wght', 400)),
      );
      expect(
        textTheme.titleMedium!.fontVariations,
        contains(const FontVariation('wght', 500)),
      );
    });

    test('dark textTheme sets wght FontVariation from fontWeight', () {
      final textTheme = AppTheme.dark().textTheme;

      expect(
        textTheme.titleLarge!.fontVariations,
        contains(const FontVariation('wght', 400)),
      );
      expect(
        textTheme.bodyMedium!.fontVariations,
        contains(const FontVariation('wght', 400)),
      );
      expect(
        textTheme.titleMedium!.fontVariations,
        contains(const FontVariation('wght', 500)),
      );
    });
  });
}
