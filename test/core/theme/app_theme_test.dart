import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';

void main() {
  group('AppTheme Forge palette', () {
    test('Forge seed drives the default light and dark schemes', () {
      final light = AppTheme.light();
      final dark = AppTheme.dark();
      expect(
        light.colorScheme.primary,
        ColorScheme.fromSeed(seedColor: const Color(0xFFD84A1B)).primary,
      );
      expect(light.scaffoldBackgroundColor, const Color(0xFFFAF8F5));
      expect(dark.scaffoldBackgroundColor, const Color(0xFF121212));
    });

    test('Forge surfaces match the scaffold backgrounds', () {
      expect(AppTheme.light().colorScheme.surface, const Color(0xFFFAF8F5));
      expect(AppTheme.dark().colorScheme.surface, const Color(0xFF121212));
    });
  });
}
