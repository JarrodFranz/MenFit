import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/nutrition_widgets.dart';
import 'package:menfit_app/features/progress/domain/progress_period.dart';

/// Nutrition overview card for the Progress dashboard, displaying
/// total/average calories, macro breakdown, and diary logging consistency for
/// the selected period.
class ProgressNutritionCard extends StatelessWidget {
  const ProgressNutritionCard({
    required this.totals,
    required this.target,
    required this.goals,
    required this.hideCalorieNumbers,
    required this.period,
    super.key,
  });

  final RangeNutritionTotals totals;
  final DayCalorieTarget target;
  final NutritionGoals? goals;
  final bool hideCalorieNumbers;
  final ProgressPeriod period;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final targetKcal = target.targetKcal;
    final avgKcal = totals.dailyAverage.caloriesKcal;
    final isMultiDay = period != ProgressPeriod.day;
    final displayKcal = isMultiDay ? avgKcal : totals.total.caloriesKcal;

    final macroTargets = goals?.macroTargetGramsFor(targetKcal);

    if (totals.daysWithEntries == 0) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nutrition',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.restaurant_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
              SizedBox(height: tokens.spacingMd),
              Text(
                'No meals logged during this '
                '${period.label.toLowerCase()}. Log meals in the '
                'Nutrition tab to see your nutrition trends here.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and the "logged N of M days" note are both text of
            // unbounded width, so a plain `Row` overflowed to the right by
            // up to 25px once the text scaled. `Wrap` puts the note on its
            // own line when the pair no longer fits side by side.
            Wrap(
              spacing: tokens.spacingSm,
              runSpacing: tokens.spacingXs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Nutrition',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Logged ${totals.daysWithEntries} of '
                  '${totals.daysInRange} '
                  '${totals.daysInRange == 1 ? 'day' : 'days'}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingMd),
            if (!hideCalorieNumbers) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMultiDay ? 'Daily Average' : 'Calories',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          formatKcal(displayKcal),
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (targetKcal != null)
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Target',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            formatKcal(targetKcal),
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (targetKcal != null && targetKcal > 0) ...[
                SizedBox(height: tokens.spacingSm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (displayKcal / targetKcal).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
              ],
              SizedBox(height: tokens.spacingMd),
            ],
            Text(
              isMultiDay ? 'Daily Average Macros' : 'Macros',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            _MacroBar(
              label: 'Protein',
              loggedGrams: isMultiDay
                  ? totals.dailyAverage.proteinGrams
                  : totals.total.proteinGrams,
              targetGrams: macroTargets?.protein,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 8),
            _MacroBar(
              label: 'Carbohydrates',
              loggedGrams: isMultiDay
                  ? totals.dailyAverage.carbsGrams
                  : totals.total.carbsGrams,
              targetGrams: macroTargets?.carbs,
              color: Colors.cyan,
            ),
            const SizedBox(height: 8),
            _MacroBar(
              label: 'Fat',
              loggedGrams: isMultiDay
                  ? totals.dailyAverage.fatGrams
                  : totals.total.fatGrams,
              targetGrams: macroTargets?.fat,
              color: Colors.purpleAccent,
            ),
            SizedBox(height: tokens.spacingMd),
            Text(
              isMultiDay ? 'Daily Average Micronutrients' : 'Micronutrients',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            _MicronutrientBar(
              label: 'Iron',
              logged: isMultiDay
                  ? totals.dailyAverage.ironMg
                  : totals.total.ironMg,
              target: 18,
              unit: 'mg',
              isPartial: isMultiDay
                  ? totals.dailyAverage.ironIsPartial
                  : totals.total.ironIsPartial,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 8),
            _MicronutrientBar(
              label: 'Calcium',
              logged: isMultiDay
                  ? totals.dailyAverage.calciumMg
                  : totals.total.calciumMg,
              target: 1000,
              unit: 'mg',
              isPartial: isMultiDay
                  ? totals.dailyAverage.calciumIsPartial
                  : totals.total.calciumIsPartial,
              color: Colors.teal,
            ),
            const SizedBox(height: 8),
            _MicronutrientBar(
              label: 'Vitamin D',
              logged: isMultiDay
                  ? totals.dailyAverage.vitaminDMcg
                  : totals.total.vitaminDMcg,
              target: 15,
              unit: 'mcg',
              isPartial: isMultiDay
                  ? totals.dailyAverage.vitaminDIsPartial
                  : totals.total.vitaminDIsPartial,
              color: Colors.amber.shade700,
            ),
          ],
        ),
      ),
    );
  }
}

class _MicronutrientBar extends StatelessWidget {
  const _MicronutrientBar({
    required this.label,
    required this.logged,
    required this.target,
    required this.unit,
    required this.isPartial,
    required this.color,
  });

  final String label;
  final double? logged;
  final double target;
  final String unit;
  final bool isPartial;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final hasValue = logged != null;
    final progress = hasValue && target > 0
        ? (logged! / target).clamp(0.0, 1.0)
        : 0.0;

    final String formattedLogged;
    if (!hasValue) {
      formattedLogged = 'Not listed';
    } else {
      final isWhole = logged! >= 10 && logged!.truncateToDouble() == logged!;
      formattedLogged = '${logged!.toStringAsFixed(isWhole ? 0 : 1)} $unit';
    }
    final targetStr = target.truncateToDouble() == target
        ? target.toStringAsFixed(0)
        : target.toStringAsFixed(1);
    final formattedTarget = '$targetStr $unit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(label, style: textTheme.bodySmall),
                  if (isPartial) ...[
                    const SizedBox(width: 6),
                    Text(
                      '(floor)',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  hasValue
                      ? '$formattedLogged / $formattedTarget'
                      : formattedLogged,
                  maxLines: 1,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasValue
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
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

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.loggedGrams,
    required this.targetGrams,
    required this.color,
  });

  final String label;
  final double loggedGrams;
  final double? targetGrams;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final target = targetGrams;
    final progress = target != null && target > 0
        ? (loggedGrams / target).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: textTheme.bodySmall)),
            const SizedBox(width: 8),
            // The gram figures are numbers: they get shrunk to fit rather
            // than ellipsised, because "12" where "120 g" was meant is not
            // a cosmetic loss.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  target != null
                      ? '${formatGrams(loggedGrams)} / ${formatGrams(target)}'
                      : formatGrams(loggedGrams),
                  maxLines: 1,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
