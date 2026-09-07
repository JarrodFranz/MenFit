import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:menfit_app/core/theme/breakpoints.dart';
import 'package:menfit_app/core/utils/text_measure.dart';
import 'package:menfit_app/features/activity/presentation/widgets/active_workout_banner.dart';

/// A single navigation destination shared by both the compact
/// [NavigationBar] and the medium/expanded [NavigationRail] layouts.
class AdaptiveDestination {
  const AdaptiveDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// A responsive scaffold that drives its layout from [WindowSize]:
///
/// * compact -> [Scaffold] with a bottom [NavigationBar].
/// * medium/expanded -> a [Row] with a [NavigationRail] (extended once the
///   window reaches [WindowSize.large]) beside the body.
///
/// Designed to sit directly on top of a [StatefulShellRoute]'s
/// `navigationShell`, using its `currentIndex` and `goBranch` to drive and
/// react to tab selection.
class AppAdaptiveScaffold extends StatelessWidget {
  const AppAdaptiveScaffold({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<AdaptiveDestination> destinations;

  /// Per-destination width at or above which Material's default 12sp
  /// [NavigationBar] label fits our longest label ("Nutrition") on one line.
  ///
  /// Measured, not guessed: `test/core/adaptive_scaffold_real_font_test.dart`
  /// renders the real shipped Inter at 320/375/412dp and fails if any label
  /// wraps. 62 is the tightest value that passes all three — 58 and 56 both
  /// let "Nutrition" wrap at 320dp. At 375dp and above the six labels fit at
  /// full size, so no shrink applies there at all; only the smallest phones
  /// (~320dp, 53dp per cell) give any ground.
  ///
  /// Do NOT re-tune this from an ordinary widget test — those run with
  /// `--use-test-fonts`, where every glyph is a fixed-width box and every
  /// label "wraps" at any size.
  static const double _comfortableCellWidth = 62;

  /// Smallest label size we'll shrink to. Below this the label stops being
  /// worth showing at all, and the right answer would be fewer tabs.
  static const double _minLabelFontSize = 9;

  /// Label style for the compact [NavigationBar], shrunk proportionally
  /// once destinations get tight.
  ///
  /// Material sizes bottom-bar labels for 3-5 destinations. Past that each
  /// cell narrows until a single-word label wraps *mid-word* - Material's
  /// label widget has no ellipsis and no hyphenation, so "Nutrition"
  /// renders as "Nutri / tion". Shrinking the style keeps them on one line.
  /// The rail has room to spare and is deliberately left alone.
  ///
  /// This scales the *base* size only - the user's own text-scale setting
  /// still applies on top, so this never fights an accessibility
  /// preference.
  TextStyle? _compactLabelStyle(BuildContext context, double availableWidth) {
    final base =
        Theme.of(context).navigationBarTheme.labelTextStyle?.resolve({}) ??
        Theme.of(context).textTheme.labelMedium;
    final baseSize = base?.fontSize ?? 12;
    if (destinations.isEmpty) return base;

    final cellWidth = availableWidth / destinations.length;
    if (cellWidth >= _comfortableCellWidth) return base;

    return base?.copyWith(
      fontSize: (baseSize * cellWidth / _comfortableCellWidth).clamp(
        _minLabelFontSize,
        baseSize,
      ),
    );
  }

  /// The scale ceiling Material applies to [NavigationBar] labels.
  ///
  /// `NavigationDestination` renders its label inside
  /// `MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3)`, so a 200% OS
  /// font setting still draws the label at 130%. Measuring against the
  /// unclamped scaler would hide labels that would in fact have fitted.
  /// Kept in step with `_kMaxLabelTextScaleFactor` in the framework's
  /// `navigation_bar.dart`.
  static const double _labelMaxTextScale = 1.3;

  /// Whether every destination label fits on one line in the width one
  /// destination actually gets, at the text scale this build is under.
  ///
  /// This is a measurement, not a breakpoint: `constraints.maxWidth /
  /// destinations.length` is the exact cell width Material's equal-width
  /// destination row hands each label, and [measuredTextWidth] lays the
  /// longest label out in the same style and the same (clamped) scaler the
  /// framework will use. A constant would be wrong at the first text-size
  /// change; this cannot be.
  bool _labelsFit(
    BuildContext context,
    double availableWidth,
    TextStyle? labelStyle,
  ) {
    if (destinations.isEmpty) return true;
    final cellWidth = availableWidth / destinations.length;
    return textsFitOnOneLine(
      context,
      destinations.map((destination) => destination.label),
      style: labelStyle,
      // No margin is subtracted, deliberately. The cell boundary *is*
      // Material's wrap point, so "fits the cell" and "is not broken
      // mid-word" are the same statement; and because each label is
      // centred in its own cell, two neighbours could only touch if both
      // filled their cells exactly, which none of these six strings does.
      // Reserving even 4dp here would hide the labels at 115% on a 411dp
      // phone, where they demonstrably still fit.
      maxWidth: cellWidth,
      scaler: MediaQuery.textScalerOf(
        context,
      ).clamp(maxScaleFactor: _labelMaxTextScale),
    );
  }

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final windowSize = WindowSize.fromWidth(constraints.maxWidth);

        if (windowSize.isCompact) {
          final labelStyle = _compactLabelStyle(context, constraints.maxWidth);
          // Icon-only is the fallback, never the default: labels stay for as
          // long as they demonstrably fit, because an unlabelled bar costs
          // every user who does not already know what the six glyphs mean.
          // When they do not fit, the choice is between a hidden label and a
          // word broken mid-way ("Wellb / eing") — and a mid-word break is
          // both illegible and, unlike a hidden label, unrecoverable: the
          // hidden one is still read out by TalkBack/VoiceOver and still
          // shown on long press (see `tooltip` below).
          final showLabels = _labelsFit(
            context,
            constraints.maxWidth,
            labelStyle,
          );
          return Scaffold(
            body: Column(
              children: [
                Expanded(child: navigationShell),
                const ActiveWorkoutBanner(),
              ],
            ),
            bottomNavigationBar: NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: WidgetStateProperty.all(labelStyle),
              ),
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onDestinationSelected,
                labelBehavior: showLabels
                    ? NavigationDestinationLabelBehavior.alwaysShow
                    : NavigationDestinationLabelBehavior.alwaysHide,
                destinations: [
                  for (final destination in destinations)
                    NavigationDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: destination.label,
                      // Stated rather than left to the framework default
                      // (which is also the label): with labels hidden this
                      // is the only way a sighted user recovers the name,
                      // so it must not depend on a default we do not own.
                      tooltip: destination.label,
                    ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: windowSize.isAtLeastLarge,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onDestinationSelected,
                labelType: windowSize.isAtLeastLarge
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                destinations: [
                  for (final destination in destinations)
                    NavigationRailDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: Text(destination.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: navigationShell),
                    const ActiveWorkoutBanner(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
