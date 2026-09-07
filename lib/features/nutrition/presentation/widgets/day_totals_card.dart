import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/floored_target_note.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/nutrition_stat_tile.dart';

/// The day's summary: energy against the target, then the four nutrients.
///
/// Three rules this widget exists to hold (`knowledge/domain/nutrition.md`):
///
/// 1. **Nothing turns red past the target.** The progress bar clamps at full
///    and the copy stays "X of about Y" whichever side of the target the day
///    lands on. There is no "over", no negative "remaining", and no colour
///    change — an amount eaten is not a score.
/// 2. **Protein and iron share the top row**, in identical
///    [NutritionStatTile]s; carbs and fat sit below them.
/// 3. **A partial iron total says so.** [NutritionTotals.ironIsPartial]
///    means at least one logged food never stated its iron, so the figure is
///    a floor — the note under the row says that in words rather than
///    letting the number imply completeness.
///
/// With [hideCalorieNumbers] on, the entire energy block is omitted — not
/// blanked, not greyed. The macros and both adequacy figures stay, which is
/// the point of the preference (`domain/nutrition_goals.dart`).
class DayTotalsCard extends StatelessWidget {
  const DayTotalsCard({
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
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final floored = target.floored;
    // Never `goals?.proteinTargetGrams` and friends directly: those hold a
    // value only when the user stated her targets in grams, so a percent-mode
    // goal read that way would show no macro target at all. `target.targetKcal`
    // is already "her explicit calorie target, else the resolved one with the
    // BMR floor applied", which is exactly the basis a share is a share of.
    final macroTargets = goals?.macroTargetGramsFor(target.targetKcal);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hideCalorieNumbers) ...[
              _EnergyBlock(totals: totals, target: target),
              SizedBox(height: tokens.spacingMd),
            ],
            Row(
              children: [
                Expanded(
                  child: NutritionStatTile(
                    label: 'Protein',
                    value: formatGrams(totals.proteinGrams),
                    note: _targetNote(macroTargets?.protein),
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: NutritionStatTile(
                    label: 'Iron',
                    value: totals.ironMg == null
                        ? 'Not listed'
                        : formatIronMg(totals.ironMg!),
                    note: totals.ironIsPartial ? 'So far' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingSm),
            Row(
              children: [
                Expanded(
                  child: NutritionStatTile(
                    label: 'Carbs',
                    value: formatGrams(totals.carbsGrams),
                    note: _targetNote(macroTargets?.carbs),
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: NutritionStatTile(
                    label: 'Fat',
                    value: formatGrams(totals.fatGrams),
                    note: _targetNote(macroTargets?.fat),
                  ),
                ),
              ],
            ),
            if (totals.ironIsPartial) ...[
              SizedBox(height: tokens.spacingSm),
              Text(
                "Some of what's logged today doesn't list iron, so this is "
                'a partial total.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            // Hidden calorie numbers means no target is on screen to
            // explain, so the floor note would be explaining a figure the
            // user asked not to see. It stays on the goals screen, where the
            // request that triggered it lives.
            if (floored != null && !hideCalorieNumbers) ...[
              SizedBox(height: tokens.spacingMd),
              FlooredTargetNote(floored),
            ],
          ],
        ),
      ),
    );
  }

  String? _targetNote(double? targetGrams) =>
      targetGrams == null ? null : 'of ${formatGrams(targetGrams)}';
}

class _EnergyBlock extends StatelessWidget {
  const _EnergyBlock({required this.totals, required this.target});

  final NutritionTotals totals;
  final DayCalorieTarget target;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final targetKcal = target.targetKcal;
    final logged = totals.caloriesKcal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Energy',
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: tokens.spacingXs),
        Text(
          targetKcal == null
              ? formatKcal(logged)
              : '${formatKcal(logged)} of '
                    '${target.isEstimate ? 'about ' : ''}'
                    '${formatEstimatedKcal(targetKcal)}',
          style: textTheme.titleLarge,
        ),
        if (targetKcal != null && targetKcal > 0) ...[
          SizedBox(height: tokens.spacingSm),
          // Clamped, single-colour, and never inverted past the target:
          // see this file's rule 1.
          LinearProgressIndicator(
            value: (logged / targetKcal).clamp(0.0, 1.0),
            borderRadius: BorderRadius.circular(tokens.radiusSm),
          ),
        ],
        if (target.isEstimate) ...[
          SizedBox(height: tokens.spacingXs),
          Text(
            'Estimated from your profile, not a measurement.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
