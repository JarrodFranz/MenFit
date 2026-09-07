import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';

import 'harness/a11y_findings.dart';

/// WCAG contrast audit of the app's own colour tokens, across every
/// [ColorBlindnessMode] and both contrast settings.
///
/// This is a pure computation over `AppTheme`/`AppTokens`, not a screen
/// walk, because contrast is a property of the palette rather than of a
/// layout — and because a screen walk can only sample the backgrounds that
/// happen to be on screen. Every pair below has a **resolved** background:
/// either a `ColorScheme` role whose partner role is defined by Material,
/// or the exact `alphaBlend` the widget performs. Pairs whose background
/// cannot be resolved statically (a colour drawn over a photo, a map tile,
/// or a gradient) are listed at the end as *not assessed* rather than
/// guessed at.
///
/// Re-run with:
/// `flutter test test/accessibility/a11y_contrast_audit_test.dart`
void main() {
  final report = A11yReport('contrast');
  tearDownAll(report.write);

  for (final mode in ColorBlindnessMode.values) {
    for (final highContrast in [false, true]) {
      for (final brightness in Brightness.values) {
        final prefs = AccessibilityPreferences(
          colorBlindness: mode,
          highContrast: highContrast,
        );
        final label =
            '${mode.name}/${highContrast ? 'hc' : 'std'}/${brightness.name}';

        test('contrast — $label', () {
          final theme = brightness == Brightness.light
              ? AppTheme.light(prefs)
              : AppTheme.dark(prefs);
          final scheme = theme.colorScheme;
          final tokens = theme.extension<AppTokens>()!;
          final card =
              theme.cardTheme.color ??
              (brightness == Brightness.light
                  ? const Color(0xFFFFFFFF)
                  : scheme.surfaceContainerHigh);

          void check(
            String name,
            Color foreground,
            Color background, {
            required double threshold,
          }) {
            final ratio = _contrast(foreground, background);
            if (ratio >= threshold) return;
            report.add(
              A11yFinding(
                screen: 'palette',
                scenario: label,
                issue: A11yIssue.contrast,
                severity: ratio < threshold * 0.7
                    ? A11ySeverity.high
                    : A11ySeverity.medium,
                detail:
                    '$name: ${_hex(foreground)} on ${_hex(background)} '
                    '(needs $threshold:1)',
                measurement: '${ratio.toStringAsFixed(2)}:1',
              ),
            );
          }

          // Material's own text-on-surface pairs. 4.5:1 is the WCAG AA
          // body-text threshold.
          check(
            'onSurface on surface',
            scheme.onSurface,
            scheme.surface,
            threshold: 4.5,
          );
          check(
            'onSurfaceVariant on surface',
            scheme.onSurfaceVariant,
            scheme.surface,
            threshold: 4.5,
          );
          check(
            'onSurfaceVariant on surfaceContainerHigh',
            scheme.onSurfaceVariant,
            scheme.surfaceContainerHigh,
            threshold: 4.5,
          );
          check(
            'onSurface on card',
            scheme.onSurface,
            card,
            threshold: 4.5,
          );
          check(
            'onPrimary on primary',
            scheme.onPrimary,
            scheme.primary,
            threshold: 4.5,
          );
          check(
            'onPrimaryContainer on primaryContainer',
            scheme.onPrimaryContainer,
            scheme.primaryContainer,
            threshold: 4.5,
          );
          check(
            'onError on error',
            scheme.onError,
            scheme.error,
            threshold: 4.5,
          );
          check(
            'onSecondaryContainer on secondaryContainer',
            scheme.onSecondaryContainer,
            scheme.secondaryContainer,
            threshold: 4.5,
          );

          // The app's own semantic tokens. Each is used two ways: as label
          // text over a 15-18% tint of itself (see
          // `record_screen.dart`'s warning banner and the workout-intensity
          // chips), and as a solid fill that must be distinguishable
          // from the surface behind it (3:1, the WCAG non-text threshold).
          final semantic = <String, Color>{
            'success': tokens.success,
            'warning': tokens.warning,
            'intensityEasy': tokens.intensityEasy,
            'intensityModerate': tokens.intensityModerate,
            'intensityHard': tokens.intensityHard,
          };

          for (final entry in semantic.entries) {
            final tint = Color.alphaBlend(
              entry.value.withValues(alpha: 0.15),
              card,
            );
            check(
              '${entry.key} text on its own 15% tint',
              entry.value,
              tint,
              threshold: 4.5,
            );
            check(
              '${entry.key} fill against card',
              entry.value,
              card,
              threshold: 3,
            );
          }

          // Colour alone must never be the only difference between two
          // meanings. Intensity colours that collapse into each other under
          // a simulation are a real failure of the mode's purpose, so the
          // pairwise separation is measured too — 1.2:1 is a deliberately
          // low bar: below it the two are visually the same swatch.
          final intensities = {
            'easy': tokens.intensityEasy,
            'moderate': tokens.intensityModerate,
            'hard': tokens.intensityHard,
          }.entries.toList();
          for (var i = 0; i < intensities.length; i++) {
            for (var j = i + 1; j < intensities.length; j++) {
              final ratio = _contrast(
                intensities[i].value,
                intensities[j].value,
              );
              if (ratio >= 1.2) continue;
              report.add(
                A11yFinding(
                  screen: 'palette',
                  scenario: label,
                  issue: A11yIssue.contrast,
                  severity: A11ySeverity.medium,
                  detail:
                      'workout intensities "${intensities[i].key}" and '
                      '"${intensities[j].key}" are near-indistinguishable by '
                      'luminance — the legend and any icon/label cue carry '
                      'the whole meaning',
                  measurement: '${ratio.toStringAsFixed(2)}:1',
                ),
              );
            }
          }
        });
      }
    }
  }

  test('backgrounds that could not be resolved statically are declared', () {
    // Honesty rather than a guess: these foregrounds are painted over
    // content the palette does not determine, so no ratio is reported for
    // them and they need a human/device check.
    report.add(
      const A11yFinding(
        screen: 'palette',
        scenario: 'n/a',
        issue: A11yIssue.contrast,
        severity: A11ySeverity.low,
        detail:
            'NOT ASSESSED: route polyline and marker colours over map '
            'tiles (routes feature), and any text drawn over a chart fill '
            '(fl_chart) — the background is imagery/derived, not a token, '
            'so a static ratio would be fiction',
      ),
    );
    expect(report.findings, isNotEmpty);
  });
}

/// WCAG 2.x relative luminance.
double _luminance(Color color) {
  double channel(double value) {
    return value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double _contrast(Color foreground, Color background) {
  final a = _luminance(foreground);
  final b = _luminance(background);
  final lighter = math.max(a, b);
  final darker = math.min(a, b);
  return (lighter + 0.05) / (darker + 0.05);
}

String _hex(Color color) {
  final value =
      ((color.a * 255).round() << 24) |
      ((color.r * 255).round() << 16) |
      ((color.g * 255).round() << 8) |
      (color.b * 255).round();
  return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}
