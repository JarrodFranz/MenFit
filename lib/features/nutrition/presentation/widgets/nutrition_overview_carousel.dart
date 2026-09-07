import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/utils/text_measure.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/floored_target_note.dart';

/// Swipeable overview carousel at the top of the Nutrition diary, presenting
/// Calories, Macros, and Nutrient progress cards with dot indicators.
///
/// **Guardrails upheld (`knowledge/domain/nutrition.md`):**
/// - Progress rings clamp at 1.0 (100%) and never turn red past goal.
/// - Remaining calculations are non-negative (`math.max(0, target - logged)`).
/// - When [hideCalorieNumbers] is on, the Calories card is omitted entirely and
///   the carousel presents macro-first views.
class NutritionOverviewCarousel extends StatefulWidget {
  const NutritionOverviewCarousel({
    required this.totals,
    required this.target,
    required this.goals,
    required this.hideCalorieNumbers,
    super.key,
  });

  final NutritionTotals totals;
  final DayCalorieTarget target;
  final NutritionGoals? goals;
  final bool hideCalorieNumbers;

  @override
  State<NutritionOverviewCarousel> createState() =>
      _NutritionOverviewCarouselState();
}

class _NutritionOverviewCarouselState extends State<NutritionOverviewCarousel> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;

    final pages = <Widget>[
      if (!widget.hideCalorieNumbers)
        _CaloriesCard(
          totals: widget.totals,
          target: widget.target,
        ),
      _MacrosCard(
        totals: widget.totals,
        target: widget.target,
        goals: widget.goals,
      ),
      _NutrientDetailsCard(
        totals: widget.totals,
        target: widget.target,
        goals: widget.goals,
      ),
    ];

    if (pages.isEmpty) return const SizedBox.shrink();

    // Ensure _currentPage is in bounds if pages count changed.
    final pageIndex = _currentPage.clamp(0, pages.length - 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          // The carousel pages are text-dense (calorie ring plus three
          // stat rows), so a hard 220 overflowed by up to ~104px once the
          // text scaled. Growing the viewport with the scaler is the only
          // remedy that does not shrink the numbers the user asked to see
          // bigger; clamped so a 200% OS setting cannot push the rest of
          // the diary off the first screen entirely (2.0 is Android's own
          // maximum font scale, so nothing is clamped away in practice).
          height:
              220 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0),
          child: PageView(
            controller: _controller,
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: pages,
          ),
        ),
        SizedBox(height: tokens.spacingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < pages.length; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == pageIndex ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: i == pageIndex
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                ),
              ),
          ],
        ),
        if (widget.target.floored != null && !widget.hideCalorieNumbers) ...[
          SizedBox(height: tokens.spacingSm),
          FlooredTargetNote(widget.target.floored!),
        ],
      ],
    );
  }
}

/// Circular progress ring for Calories with Base Goal and Food summary.
class _CaloriesCard extends StatelessWidget {
  const _CaloriesCard({
    required this.totals,
    required this.target,
  });

  final NutritionTotals totals;
  final DayCalorieTarget target;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final targetKcal = target.targetKcal;
    final loggedKcal = totals.caloriesKcal;
    final remaining = targetKcal != null
        ? math.max(0, targetKcal - loggedKcal).toDouble()
        : null;
    final progress = targetKcal != null && targetKcal > 0
        ? (loggedKcal / targetKcal).clamp(0.0, 1.0)
        : 0.0;

    final stats = <({IconData icon, Color color, String label, String value})>[
      (
        icon: Icons.flag_outlined,
        color: colorScheme.onSurfaceVariant,
        label: 'Base Goal',
        value: targetKcal != null ? formatKcal(targetKcal) : '—',
      ),
      (
        icon: Icons.restaurant_outlined,
        color: colorScheme.primary,
        label: 'Food',
        value: formatKcal(loggedKcal),
      ),
      (
        icon: Icons.local_fire_department_outlined,
        color: colorScheme.tertiary,
        label: 'Exercise',
        value: '0',
      ),
    ];

    final ring = SizedBox(
      width: _ringDiameter,
      height: _ringDiameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 9,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                remaining != null
                    ? formatKcal(remaining)
                    : formatKcal(loggedKcal),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                remaining != null && remaining > 0
                    ? 'Remaining'
                    : (targetKcal != null && loggedKcal >= targetKcal
                          ? 'Goal met'
                          : 'Logged'),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final statColumn = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final stat in stats) ...[
          if (stat != stats.first) SizedBox(height: tokens.spacingSm),
          _StatRow(
            icon: stat.icon,
            iconColor: stat.color,
            label: stat.label,
            value: stat.value,
          ),
        ],
      ],
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Calories',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Text(
                  'Daily Target',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // A 120dp ring beside three label/value rows stops fitting well
            // before the largest text sizes: starved of width the labels
            // wrapped over several lines each and pushed the card 24px past
            // the bottom of the carousel viewport. Above that point the ring
            // moves above the rows, which gives every label the full card
            // width and puts each row back on one line.
            //
            // Two conditions, not one. Stacking is *taller* than the
            // side-by-side arrangement, and the page it sits in is
            // `220 * textScale` tall (clamped at 2x) — so below 130% there
            // is no room for the stacked form even when the rows are
            // cramped, and forcing it there trades a horizontal squeeze for
            // a 48px vertical overflow at default settings. Above 130% the
            // viewport has grown enough to hold it.
            LayoutBuilder(
              builder: (context, constraints) {
                final beside =
                    constraints.maxWidth - _ringDiameter - tokens.spacingLg;
                final fitsBeside = _statsFitWithin(
                  context,
                  beside,
                  stats: stats,
                  labelStyle: textTheme.bodyMedium,
                  valueStyle: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                );
                final viewportCanHoldStack =
                    MediaQuery.textScalerOf(context).scale(1) >=
                    _stackedLayoutMinTextScale;
                if (fitsBeside || !viewportCanHoldStack) {
                  return Row(
                    children: [
                      ring,
                      SizedBox(width: tokens.spacingLg),
                      Expanded(child: statColumn),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: ring),
                    SizedBox(height: tokens.spacingMd),
                    statColumn,
                  ],
                );
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  /// Whether every stat row fits on one line in [available] logical pixels.
  ///
  /// Measured against the strings this card is actually about to draw, at
  /// the text scale this build is under — a fixed width threshold would be
  /// right at 100% and wrong at every other setting, which is the whole
  /// class of bug this layout is fixing.
  bool _statsFitWithin(
    BuildContext context,
    double available, {
    required List<({IconData icon, Color color, String label, String value})>
    stats,
    required TextStyle? labelStyle,
    required TextStyle? valueStyle,
  }) {
    if (available <= 0) return false;
    for (final stat in stats) {
      final needed =
          _statRowLeading +
          measuredTextWidth(context, stat.label, style: labelStyle) +
          _statRowGap +
          measuredTextWidth(context, stat.value, style: valueStyle);
      if (needed > available) return false;
    }
    return true;
  }
}

/// Diameter of the calorie ring, and the two fixed gaps inside a
/// [_StatRow] — the numbers [_CaloriesCard._statsFitWithin] has to add to
/// the measured text to know whether a row fits.
const double _ringDiameter = 120;

/// The text scale at which the carousel page (`220 * scale`) is finally
/// tall enough for the ring to sit above the stat rows instead of beside
/// them.
const double _stackedLayoutMinTextScale = 1.3;
const double _statRowLeading = 26;
const double _statRowGap = 8;

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // With the label already `Expanded`, a value wide enough on its
        // own ("2,120 kcal" bold at 150%) had nothing left to shrink into
        // and overflowed the row to the right. `scaleDown` keeps it on one
        // line at full size until it genuinely cannot fit, and only then
        // shrinks — letting it wrap instead made the card 54px too tall,
        // trading a small horizontal clip for a large vertical one.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 3 Circular progress rings for Carbohydrates, Fat, and Protein.
class _MacrosCard extends StatelessWidget {
  const _MacrosCard({
    required this.totals,
    required this.target,
    required this.goals,
  });

  final NutritionTotals totals;
  final DayCalorieTarget target;
  final NutritionGoals? goals;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final macroTargets = goals?.macroTargetGramsFor(target.targetKcal);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Macros',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Grams & Goals',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MacroRing(
                  label: 'Carbohydrates',
                  color: Colors.cyan,
                  loggedGrams: totals.carbsGrams,
                  targetGrams: macroTargets?.carbs,
                ),
                _MacroRing(
                  label: 'Fat',
                  color: Colors.purpleAccent,
                  loggedGrams: totals.fatGrams,
                  targetGrams: macroTargets?.fat,
                ),
                _MacroRing(
                  label: 'Protein',
                  color: Colors.orangeAccent,
                  loggedGrams: totals.proteinGrams,
                  targetGrams: macroTargets?.protein,
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _MacroRing extends StatelessWidget {
  const _MacroRing({
    required this.label,
    required this.color,
    required this.loggedGrams,
    required this.targetGrams,
  });

  final String label;
  final Color color;
  final double loggedGrams;
  final double? targetGrams;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final target = targetGrams;
    final progress = target != null && target > 0
        ? (loggedGrams / target).clamp(0.0, 1.0)
        : 0.0;
    final remaining = target != null
        ? math.max(0, target - loggedGrams).toDouble()
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 68,
                height: 68,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatGrams(loggedGrams),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (target != null)
                    Text(
                      '/${formatGrams(target)}',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 9,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          remaining != null
              ? (remaining > 0 ? '${formatGrams(remaining)} left' : 'Goal met')
              : 'Logged',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Nutrient progress bars for Protein, Iron, Carbs, and Fat.
class _NutrientDetailsCard extends StatelessWidget {
  const _NutrientDetailsCard({
    required this.totals,
    required this.target,
    required this.goals,
  });

  final NutritionTotals totals;
  final DayCalorieTarget target;
  final NutritionGoals? goals;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final macroTargets = goals?.macroTargetGramsFor(target.targetKcal);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nutrient Breakdown',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  totals.ironIsPartial ? 'Iron is partial' : 'Daily status',
                  style: textTheme.bodySmall?.copyWith(
                    color: totals.ironIsPartial
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Spacer(),
            _NutrientBar(
              label: 'Protein',
              logged: formatGrams(totals.proteinGrams),
              target: macroTargets?.protein != null
                  ? formatGrams(macroTargets!.protein!)
                  : null,
              progress:
                  macroTargets?.protein != null && macroTargets!.protein! > 0
                  ? (totals.proteinGrams / macroTargets.protein!).clamp(
                      0.0,
                      1.0,
                    )
                  : 0.0,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 8),
            _NutrientBar(
              label: 'Carbohydrates',
              logged: formatGrams(totals.carbsGrams),
              target: macroTargets?.carbs != null
                  ? formatGrams(macroTargets!.carbs!)
                  : null,
              progress: macroTargets?.carbs != null && macroTargets!.carbs! > 0
                  ? (totals.carbsGrams / macroTargets.carbs!).clamp(0.0, 1.0)
                  : 0.0,
              color: Colors.cyan,
            ),
            const SizedBox(height: 8),
            _NutrientBar(
              label: 'Fat',
              logged: formatGrams(totals.fatGrams),
              target: macroTargets?.fat != null
                  ? formatGrams(macroTargets!.fat!)
                  : null,
              progress: macroTargets?.fat != null && macroTargets!.fat! > 0
                  ? (totals.fatGrams / macroTargets.fat!).clamp(0.0, 1.0)
                  : 0.0,
              color: Colors.purpleAccent,
            ),
            const SizedBox(height: 8),
            _NutrientBar(
              label: 'Iron',
              logged: totals.ironMg == null
                  ? 'Not listed'
                  : formatIronMg(totals.ironMg!),
              target: null,
              progress: 0,
              color: colorScheme.primary,
              customNote: totals.ironIsPartial ? 'Partial' : null,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _NutrientBar extends StatelessWidget {
  const _NutrientBar({
    required this.label,
    required this.logged,
    required this.target,
    required this.progress,
    required this.color,
    this.customNote,
  });

  final String label;
  final String logged;
  final String? target;
  final double progress;
  final Color color;
  final String? customNote;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: textTheme.bodySmall),
            Text(
              customNote ?? (target != null ? '$logged / $target' : logged),
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
