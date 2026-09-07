import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/tokens.dart';

void main() {
  group('AppTokens', () {
    test('light ThemeData exposes AppTokens', () {
      final theme = AppTheme.light();
      final tokens = theme.extension<AppTokens>();

      expect(tokens, isNotNull);
      expect(tokens!.spacingMd, 16);
      expect(tokens.radiusMd, 12);
    });

    test('dark ThemeData exposes AppTokens', () {
      final theme = AppTheme.dark();
      final tokens = theme.extension<AppTokens>();

      expect(tokens, isNotNull);
      expect(tokens!.spacingMd, 16);
      expect(tokens.radiusMd, 12);
    });

    test('lerp interpolates between light and dark presets', () {
      final light = AppTokens.light();
      final dark = AppTokens.dark();

      final midpoint = light.lerp(dark, 0.5);

      expect(midpoint.spacingMd, closeTo(16, 0.001));
      expect(
        midpoint.success,
        Color.lerp(light.success, dark.success, 0.5),
      );
    });

    test('lerp at t=0 and t=1 returns the endpoints', () {
      final light = AppTokens.light();
      final dark = AppTokens.dark();

      final start = light.lerp(dark, 0);
      final end = light.lerp(dark, 1);

      expect(start.success, light.success);
      expect(end.success, dark.success);
    });

    test('lerp with a non-AppTokens extension returns this', () {
      final light = AppTokens.light();

      final result = light.lerp(null, 0.5);

      expect(result, same(light));
    });

    test('copyWith overrides only the requested fields', () {
      final light = AppTokens.light();
      final copy = light.copyWith(spacingMd: 100);

      expect(copy.spacingMd, 100);
      expect(copy.spacingSm, light.spacingSm);
      expect(copy.success, light.success);
    });
  });
}
