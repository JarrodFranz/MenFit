import 'package:flutter/material.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';

/// Design-system spacing and radius scale, plus semantic colors that don't
/// map onto Material's [ColorScheme] roles (workout intensity,
/// success/warning). Access via `Theme.of(context).extension<AppTokens>()!`.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.contentMaxWidth,
    required this.success,
    required this.warning,
    required this.intensityEasy,
    required this.intensityModerate,
    required this.intensityHard,
  });

  /// Light theme preset.
  factory AppTokens.light([
    AccessibilityPreferences prefs = AccessibilityPreferences.defaults,
  ]) => AppTokens.fromAccessibility(Brightness.light, prefs);

  /// Dark theme preset.
  factory AppTokens.dark([
    AccessibilityPreferences prefs = AccessibilityPreferences.defaults,
  ]) => AppTokens.fromAccessibility(Brightness.dark, prefs);

  /// Generates design tokens tailored to the user's accessibility preferences.
  factory AppTokens.fromAccessibility(
    Brightness brightness,
    AccessibilityPreferences prefs,
  ) {
    final isDark = brightness == Brightness.dark;
    final isHc = prefs.highContrast;

    final (
      success,
      warning,
      intensityEasy,
      intensityModerate,
      intensityHard,
    ) = switch (prefs.colorBlindness) {
      ColorBlindnessMode.protanopia || ColorBlindnessMode.deuteranopia =>
        isHc
            ? (
                // Okabe-Ito high-contrast palette (WCAG AAA compliant)
                isDark
                    ? const Color(0xFF70C9FF)
                    : const Color(0xFF004D7A), // Blue
                isDark
                    ? const Color(0xFFFFF066)
                    : const Color(0xFF7A3E00), // Amber
                isDark ? const Color(0xFF70C9FF) : const Color(0xFF004D7A),
                isDark ? const Color(0xFFFFF066) : const Color(0xFF7A3E00),
                isDark ? const Color(0xFFFFA07A) : const Color(0xFF8F3000),
              )
            : (
                // Okabe-Ito accessible palette (avoids red/green confusion)
                isDark ? const Color(0xFF56B4E9) : const Color(0xFF0072B2),
                isDark ? const Color(0xFFF0E442) : const Color(0xFFE69F00),
                isDark ? const Color(0xFF56B4E9) : const Color(0xFF0072B2),
                isDark ? const Color(0xFFF0E442) : const Color(0xFFE69F00),
                isDark ? const Color(0xFFFF7F50) : const Color(0xFFD55E00),
              ),
      ColorBlindnessMode.tritanopia =>
        isHc
            ? (
                // High-contrast teal/coral/crimson palette (avoids blue/yellow)
                isDark
                    ? const Color(0xFF5CE6BA)
                    : const Color(0xFF005C42), // Mint Green
                isDark
                    ? const Color(0xFFFFA085)
                    : const Color(0xFF8F1D1D), // Coral
                isDark ? const Color(0xFF5EEAD4) : const Color(0xFF00574D),
                isDark ? const Color(0xFFFFA085) : const Color(0xFF8F1D1D),
                isDark ? const Color(0xFFFF6B82) : const Color(0xFF880018),
              )
            : (
                isDark
                    ? const Color(0xFF52B788)
                    : const Color(0xFF009E73), // Mint Green
                isDark ? const Color(0xFFFFA07A) : const Color(0xFFFF6B6B),
                isDark ? const Color(0xFF02C39A) : const Color(0xFF00A896),
                isDark ? const Color(0xFFFFA07A) : const Color(0xFFFF6B6B),
                isDark ? const Color(0xFFEF233C) : const Color(0xFFD90429),
              ),
      ColorBlindnessMode.monochromacy =>
        isHc
            ? (
                // Maximum-contrast grayscale (pure black/white anchors)
                isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                isDark ? const Color(0xFFEEEEEE) : const Color(0xFF222222),
                isDark ? const Color(0xFFCCCCCC) : const Color(0xFF444444),
                isDark ? const Color(0xFFEEEEEE) : const Color(0xFF222222),
                isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
              )
            : (
                isDark ? const Color(0xFFFFFFFF) : const Color(0xFF111111),
                isDark ? const Color(0xFFDDDDDD) : const Color(0xFF444444),
                isDark ? const Color(0xFFAAAAAA) : const Color(0xFF777777),
                isDark ? const Color(0xFFCCCCCC) : const Color(0xFF444444),
                isDark ? const Color(0xFFFFFFFF) : const Color(0xFF111111),
              ),
      ColorBlindnessMode.none =>
        isHc
            ? (isDark
                  ? (
                      // High-contrast luminous dark-mode tokens (WCAG AAA)
                      const Color(0xFF6EE7B7), // Bright mint
                      const Color(0xFFFDE047), // Bright yellow
                      const Color(0xFF6EE7B7),
                      const Color(0xFFFDE047),
                      const Color(0xFFFDA4AF),
                    )
                  : (
                      // High-contrast deep light-mode tokens (WCAG AAA)
                      const Color(0xFF0D5A34), // Deep forest green
                      const Color(0xFF78350F), // Deep warm amber
                      const Color(0xFF0D5A34),
                      const Color(0xFF78350F),
                      const Color(0xFF881337),
                    ))
            : (isDark
                  ? (
                      const Color(0xFF6FBF97),
                      const Color(0xFFE0B25E),
                      const Color(0xFF7FC69A),
                      const Color(0xFFE8B067),
                      const Color(0xFFE68A9C),
                    )
                  : (
                      const Color(0xFF1B8755),
                      const Color(0xFFD97706),
                      const Color(0xFF1B8755),
                      const Color(0xFFD97706),
                      const Color(0xFFD64D6E),
                    )),
    };

    return AppTokens(
      spacingXs: 4,
      spacingSm: 8,
      spacingMd: 16,
      spacingLg: 24,
      spacingXl: 32,
      radiusSm: prefs.highContrast ? 6 : 8,
      radiusMd: prefs.highContrast ? 8 : 12,
      radiusLg: prefs.highContrast ? 14 : 20,
      contentMaxWidth: 560,
      success: success,
      warning: warning,
      intensityEasy: intensityEasy,
      intensityModerate: intensityModerate,
      intensityHard: intensityHard,
    );
  }

  // Spacing scale.
  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;

  // Radius scale.
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;

  /// Max width for a single-column readable content area (onboarding,
  /// forms) - keeps text/inputs from stretching edge-to-edge on wide
  /// windows. See `core/theme/breakpoints.dart` for window-size classes.
  final double contentMaxWidth;

  // Semantic status colors.
  final Color success;
  final Color warning;

  // Workout intensity colors.
  final Color intensityEasy;
  final Color intensityModerate;
  final Color intensityHard;

  @override
  AppTokens copyWith({
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? contentMaxWidth,
    Color? success,
    Color? warning,
    Color? intensityEasy,
    Color? intensityModerate,
    Color? intensityHard,
  }) {
    return AppTokens(
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      intensityEasy: intensityEasy ?? this.intensityEasy,
      intensityModerate: intensityModerate ?? this.intensityModerate,
      intensityHard: intensityHard ?? this.intensityHard,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) {
      return this;
    }
    return AppTokens(
      spacingXs: _lerpDouble(spacingXs, other.spacingXs, t),
      spacingSm: _lerpDouble(spacingSm, other.spacingSm, t),
      spacingMd: _lerpDouble(spacingMd, other.spacingMd, t),
      spacingLg: _lerpDouble(spacingLg, other.spacingLg, t),
      spacingXl: _lerpDouble(spacingXl, other.spacingXl, t),
      radiusSm: _lerpDouble(radiusSm, other.radiusSm, t),
      radiusMd: _lerpDouble(radiusMd, other.radiusMd, t),
      radiusLg: _lerpDouble(radiusLg, other.radiusLg, t),
      contentMaxWidth: _lerpDouble(
        contentMaxWidth,
        other.contentMaxWidth,
        t,
      ),
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      intensityEasy:
          Color.lerp(intensityEasy, other.intensityEasy, t) ?? intensityEasy,
      intensityModerate:
          Color.lerp(intensityModerate, other.intensityModerate, t) ??
          intensityModerate,
      intensityHard:
          Color.lerp(intensityHard, other.intensityHard, t) ?? intensityHard,
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
