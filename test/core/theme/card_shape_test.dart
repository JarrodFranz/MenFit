import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';

/// A `Card(shape: RoundedRectangleBorder(borderRadius: ...))` replaces the
/// theme's shape wholesale and so silently drops the outline `AppTheme`
/// carries in its `cardTheme.shape.side` - including the High Contrast
/// outline. Seen on device 2026-09-02: the Home dashboard tiles had no
/// outline while every neighbouring card did. `themedCardShape` exists so a
/// call site can change the radius without losing that side.
void main() {
  RoundedRectangleBorder themeSideOf(ThemeData theme) =>
      theme.cardTheme.shape! as RoundedRectangleBorder;

  Future<RoundedRectangleBorder> pumpAndReadShape(
    WidgetTester tester,
    ThemeData theme, {
    BorderSide? side,
  }) async {
    late RoundedRectangleBorder shape;
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) {
            shape = themedCardShape(
              context,
              radius: 12,
              side: side,
            ) as RoundedRectangleBorder;
            return Card(shape: shape, child: const SizedBox(width: 40));
          },
        ),
      ),
    );
    // MaterialApp animates theme changes (AnimatedTheme), so a second pump in
    // the same test still sees the OLD theme on its first frame. Settle so the
    // shape read reflects the theme actually passed in.
    await tester.pumpAndSettle();
    return shape;
  }

  testWidgets('keeps the High Contrast outline that a bare shape would drop', (
    tester,
  ) async {
    final theme = AppTheme.light(
      const AccessibilityPreferences(highContrast: true),
    );
    final expected = themeSideOf(theme).side;
    expect(
      expected.width,
      greaterThanOrEqualTo(1.5),
      reason: 'the theme signals High Contrast with a 1.5dp side',
    );

    final shape = await pumpAndReadShape(tester, theme);

    expect(shape.side, expected);
    expect(shape.borderRadius, BorderRadius.circular(12));
  });

  testWidgets('matches the default theme side when High Contrast is off', (
    tester,
  ) async {
    final theme = AppTheme.light();
    final shape = await pumpAndReadShape(tester, theme);

    expect(shape.side, themeSideOf(theme).side);
  });

  testWidgets('honours a bespoke side outside High Contrast only', (
    tester,
  ) async {
    const accent = BorderSide(color: Colors.pink);

    final normal = await pumpAndReadShape(
      tester,
      AppTheme.light(),
      side: accent,
    );
    expect(normal.side, accent, reason: 'a tinted card keeps its tint');

    final hcTheme = AppTheme.light(
      const AccessibilityPreferences(highContrast: true),
    );
    final highContrast = await pumpAndReadShape(tester, hcTheme, side: accent);
    expect(
      highContrast.side,
      themeSideOf(hcTheme).side,
      reason: 'High Contrast replaces faint/accent outlines by design',
    );
  });

  testWidgets('dark theme High Contrast outline is preserved too', (
    tester,
  ) async {
    final theme = AppTheme.dark(
      const AccessibilityPreferences(highContrast: true),
    );
    final shape = await pumpAndReadShape(tester, theme);
    expect(shape.side, themeSideOf(theme).side);
    expect(shape.side.width, greaterThanOrEqualTo(1.5));
  });
}
