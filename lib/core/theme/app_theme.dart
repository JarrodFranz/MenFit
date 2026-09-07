import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';

/// Builds the app's light and dark [ThemeData], seeded from Forge burnt
/// orange on charcoal — the brand's strength-first accent. Deliberately
/// restrained: one warm accent over neutral Material 3 surfaces.
abstract final class AppTheme {
  static const Color _seed = Color(0xFFD84A1B);

  /// The bundled variable font used for all app text (see `assets/fonts/`).
  static const String fontFamily = 'Inter';

  /// `kMinInteractiveDimension` — Material's own floor and Android's
  /// documented minimum. WCAG 2.5.5 (AAA) asks for 44; this is the
  /// stricter of the two, and the number the Large Touch Targets switch
  /// promises on the settings screen.
  static const Size _minTouchTarget = Size(48, 48);

  /// Applies [AccessibilityPreferences.largeTouchTargets] to [base].
  ///
  /// Done at the theme rather than per widget so one switch covers every
  /// button, chip, switch, checkbox, radio and icon button in the app at
  /// once — a per-call-site approach would be inert on the next screen
  /// somebody writes.
  ///
  /// Three things have to change together, and missing any one of them
  /// leaves the target short:
  ///
  /// 1. `materialTapTargetSize` — on desktop platforms `ThemeData` defaults
  ///    this to [MaterialTapTargetSize.shrinkWrap], which is why the audit
  ///    measured 40dp buttons and 38dp chips on the Windows target while
  ///    the same widgets are already 48dp on Android/iOS.
  /// 2. `visualDensity` — desktop also defaults to [VisualDensity.compact],
  ///    whose `-4` base-size adjustment is subtracted from the padded
  ///    minimum, landing on 44dp rather than 48dp.
  /// 3. `minimumSize` on the button styles, so the *visible* control grows
  ///    with its hit area instead of a 40dp button floating inside an
  ///    invisible 48dp box — a motor-impaired user aims at what she sees.
  static ThemeData _withLargeTouchTargets(ThemeData base) {
    const buttonStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(_minTouchTarget),
      tapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );
    return base.copyWith(
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      filledButtonTheme: const FilledButtonThemeData(style: buttonStyle),
      outlinedButtonTheme: const OutlinedButtonThemeData(style: buttonStyle),
      textButtonTheme: const TextButtonThemeData(style: buttonStyle),
      elevatedButtonTheme: const ElevatedButtonThemeData(style: buttonStyle),
      iconButtonTheme: const IconButtonThemeData(style: buttonStyle),
      // No `chipTheme` entry: `ChipThemeData` carries neither
      // `materialTapTargetSize` nor `visualDensity`, so a chip reads both
      // straight off `ThemeData` — the two fields set above are what grows
      // it from 38dp to 48dp.
      switchTheme: const SwitchThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      checkboxTheme: const CheckboxThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.standard,
      ),
      radioTheme: const RadioThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.standard,
      ),
    );
  }

  /// Returns the theme seed color appropriate for [mode].
  ///
  /// For [ColorBlindnessMode.monochromacy], an achromatic slate gray seed is
  /// used to eliminate coloured tints across Material 3 surfaces.
  /// For [ColorBlindnessMode.protanopia] and [ColorBlindnessMode.deuteranopia],
  /// the universally accessible Okabe-Ito blue seed (0xFF0072B2) is used.
  /// For [ColorBlindnessMode.tritanopia], an accessible dark cyan/teal seed
  /// (0xFF028090) is used.
  static Color seedFor(ColorBlindnessMode mode) => switch (mode) {
    ColorBlindnessMode.monochromacy => const Color(0xFF666666),
    ColorBlindnessMode.protanopia ||
    ColorBlindnessMode.deuteranopia => const Color(0xFF0072B2),
    ColorBlindnessMode.tritanopia => const Color(0xFF028090),
    ColorBlindnessMode.none => _seed,
  };

  static ThemeData light([
    AccessibilityPreferences accessibility = AccessibilityPreferences.defaults,
  ]) {
    final seed = seedFor(accessibility.colorBlindness);
    final isMonochrome =
        accessibility.colorBlindness == ColorBlindnessMode.monochromacy;
    final seedScheme = ColorScheme.fromSeed(seedColor: seed);

    // Provide crisp, high-contrast surfaces without a muddy grey or
    // glaring tint pulled from the accent.
    final colorScheme = seedScheme.copyWith(
      primary: isMonochrome
          ? (accessibility.highContrast
                ? const Color(0xFF000000)
                : const Color(0xFF222222))
          : null,
      onPrimary: isMonochrome ? const Color(0xFFFFFFFF) : null,
      primaryContainer: isMonochrome
          ? (accessibility.highContrast
                ? const Color(0xFFE0E0E0)
                : const Color(0xFFEEEEEE))
          : null,
      onPrimaryContainer: isMonochrome ? const Color(0xFF000000) : null,
      secondary: isMonochrome
          ? (accessibility.highContrast
                ? const Color(0xFF333333)
                : const Color(0xFF555555))
          : null,
      onSecondary: isMonochrome ? const Color(0xFFFFFFFF) : null,
      secondaryContainer: isMonochrome ? const Color(0xFFE8E8E8) : null,
      onSecondaryContainer: isMonochrome ? const Color(0xFF000000) : null,
      surface: const Color(0xFFFAF8F5),
      onSurface: accessibility.highContrast
          ? const Color(0xFF000000)
          : const Color(0xFF1E1A20),
      onSurfaceVariant: accessibility.highContrast
          ? const Color(0xFF222222)
          : (isMonochrome ? const Color(0xFF444444) : const Color(0xFF534652)),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFFFFFFF),
      surfaceContainer: const Color(0xFFFFFFFF),
      surfaceContainerHigh: isMonochrome
          ? const Color(0xFFF2F2F2)
          : const Color(0xFFF6F3F8),
      surfaceContainerHighest: isMonochrome
          ? const Color(0xFFE6E6E6)
          : const Color(0xFFEDE8F0),
      surfaceTint: Colors.transparent,
      outline: accessibility.highContrast
          ? const Color(0xFF000000)
          : (isMonochrome ? const Color(0xFF777777) : const Color(0xFF8C7D8A)),
      outlineVariant: accessibility.highContrast
          ? const Color(0xFF555555)
          : (isMonochrome ? const Color(0xFFD0D0D0) : const Color(0xFFE4DCE6)),
    );

    final base = ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: accessibility.highContrast
          ? const Color(0xFFFFFFFF)
          : const Color(0xFFFAF8F5),
      fontFamily: fontFamily,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: accessibility.highContrast
                ? const Color(0xFF000000)
                : const Color(0xFFECE7EE),
            width: accessibility.highContrast ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: accessibility.highContrast
            ? const Color(0xFFFFFFFF)
            : const Color(0xFFFAF8F5),
        foregroundColor: accessibility.highContrast
            ? const Color(0xFF000000)
            : const Color(0xFF1E1A20),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: const Color(0x14000000),
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppTokens.light(accessibility),
      ],
    );
    final themed = base.copyWith(
      textTheme: _withVariableWeights(base, boldText: accessibility.boldText),
    );
    return accessibility.largeTouchTargets
        ? _withLargeTouchTargets(themed)
        : themed;
  }

  static ThemeData dark([
    AccessibilityPreferences accessibility = AccessibilityPreferences.defaults,
  ]) {
    final seed = seedFor(accessibility.colorBlindness);
    final isMonochrome =
        accessibility.colorBlindness == ColorBlindnessMode.monochromacy;
    final seedScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    final colorScheme = seedScheme.copyWith(
      primary: isMonochrome
          ? (accessibility.highContrast
                ? const Color(0xFFFFFFFF)
                : const Color(0xFFE0E0E0))
          : null,
      onPrimary: isMonochrome ? const Color(0xFF000000) : null,
      primaryContainer: isMonochrome
          ? (accessibility.highContrast
                ? const Color(0xFF333333)
                : const Color(0xFF2B2B2B))
          : null,
      onPrimaryContainer: isMonochrome ? const Color(0xFFFFFFFF) : null,
      secondary: isMonochrome ? const Color(0xFFCCCCCC) : null,
      onSecondary: isMonochrome ? const Color(0xFF000000) : null,
      secondaryContainer: isMonochrome ? const Color(0xFF333333) : null,
      onSecondaryContainer: isMonochrome ? const Color(0xFFFFFFFF) : null,
      surface: accessibility.highContrast
          ? const Color(0xFF000000)
          : (isMonochrome
                ? const Color(0xFF141414)
                : const Color(0xFF121212)),
      onSurface: accessibility.highContrast
          ? const Color(0xFFFFFFFF)
          : (isMonochrome ? const Color(0xFFEEEEEE) : null),
      onSurfaceVariant: accessibility.highContrast
          ? const Color(0xFFE5E5E5)
          : (isMonochrome ? const Color(0xFFB0B0B0) : null),
      outline: accessibility.highContrast
          ? const Color(0xFFFFFFFF)
          : (isMonochrome ? const Color(0xFF888888) : null),
      outlineVariant: accessibility.highContrast
          ? const Color(0xFFAAAAAA)
          : (isMonochrome ? const Color(0xFF444444) : null),
      surfaceTint: Colors.transparent,
    );

    final base = ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: accessibility.highContrast
          ? const Color(0xFF000000)
          : null,
      fontFamily: fontFamily,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: accessibility.highContrast
                ? const Color(0xFFFFFFFF)
                : Colors.transparent,
            width: accessibility.highContrast ? 1.5 : 0.0,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppTokens.dark(accessibility),
      ],
    );
    final themed = base.copyWith(
      textTheme: _withVariableWeights(base, boldText: accessibility.boldText),
    );
    return accessibility.largeTouchTargets
        ? _withLargeTouchTargets(themed)
        : themed;
  }

  /// Sets an explicit `wght` [FontVariation] on every style in
  /// `theme.textTheme`, derived from that style's [TextStyle.fontWeight]
  /// (defaulting to [FontWeight.w400] when unset).
  static TextTheme _withVariableWeights(
    ThemeData theme, {
    bool boldText = false,
  }) {
    final geometry = theme.typography.englishLike;

    TextStyle? withWeight(TextStyle? style, TextStyle? geometryStyle) {
      if (style == null) return null;
      var weight = geometryStyle?.fontWeight ?? FontWeight.w400;
      if (boldText) {
        weight = switch (weight) {
          FontWeight.w300 || FontWeight.w400 => FontWeight.w600,
          FontWeight.w500 => FontWeight.w700,
          _ => FontWeight.w800,
        };
      }
      return style.copyWith(
        fontWeight: boldText ? weight : null,
        fontVariations: [FontVariation('wght', weight.value.toDouble())],
      );
    }

    final textTheme = theme.textTheme;
    return textTheme.copyWith(
      displayLarge: withWeight(textTheme.displayLarge, geometry.displayLarge),
      displayMedium: withWeight(
        textTheme.displayMedium,
        geometry.displayMedium,
      ),
      displaySmall: withWeight(textTheme.displaySmall, geometry.displaySmall),
      headlineLarge: withWeight(
        textTheme.headlineLarge,
        geometry.headlineLarge,
      ),
      headlineMedium: withWeight(
        textTheme.headlineMedium,
        geometry.headlineMedium,
      ),
      headlineSmall: withWeight(
        textTheme.headlineSmall,
        geometry.headlineSmall,
      ),
      titleLarge: withWeight(textTheme.titleLarge, geometry.titleLarge),
      titleMedium: withWeight(textTheme.titleMedium, geometry.titleMedium),
      titleSmall: withWeight(textTheme.titleSmall, geometry.titleSmall),
      bodyLarge: withWeight(textTheme.bodyLarge, geometry.bodyLarge),
      bodyMedium: withWeight(textTheme.bodyMedium, geometry.bodyMedium),
      bodySmall: withWeight(textTheme.bodySmall, geometry.bodySmall),
      labelLarge: withWeight(textTheme.labelLarge, geometry.labelLarge),
      labelMedium: withWeight(textTheme.labelMedium, geometry.labelMedium),
      labelSmall: withWeight(textTheme.labelSmall, geometry.labelSmall),
    );
  }
}

/// Text-style helpers for numeric displays.
extension StatTextStyle on TextStyle {
  /// Applies tabular (fixed-width) figures, so stacked numeric displays
  /// — pace, distance, splits — align digit-for-digit instead of jittering
  /// as digits change width. Use for any stats/pace display instead of
  /// hand-rolling `FontFeature.tabularFigures()` at each call site.
  TextStyle get tabularFigures {
    return copyWith(
      fontFeatures: [
        ...?fontFeatures,
        const FontFeature.tabularFigures(),
      ],
    );
  }
}
