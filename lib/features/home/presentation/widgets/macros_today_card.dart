import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/home/domain/home_macro_rows.dart';
import 'package:menfit_app/features/home/presentation/widgets/home_card.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/nutrition_widgets.dart';

/// Today's energy and macros, compact, on the home dashboard.
///
/// ## The ED-safe rules this card is bound by
///
/// `knowledge/domain/nutrition.md`. They are the reason this is not simply
/// a smaller copy of the diary's day card:
///
/// * **`hideCalorieNumbers` removes the energy line entirely** — not
///   blanked, not greyed, not replaced by a dash. The macros stay, which is
///   the whole point of the preference (`domain/nutrition_goals.dart`).
/// * **No judgement copy.** "N of M kcal", never "N remaining", never
///   "M over". Nothing turns red past the target and the bars clamp at
///   full (`domain/home_macro_rows.dart`).
/// * **No target is a normal state.** "No target set" is a statement, not a
///   prompt, and the card works entirely without one.
///
/// The energy target comes from `dayCalorieTargetProvider` rather than from
/// `goals.calorieTargetKcal` so this card and the diary cannot disagree
/// about the figure: that provider is where "her own target, else the
/// estimate with the BMR floor applied" is decided, and re-deriving it here
/// would be a second definition of a number the floor exists to protect.
class MacrosTodayCard extends ConsumerWidget {
  const MacrosTodayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final today = LocalDate.today();
    final totals =
        ref.watch(dayNutritionTotalsProvider(today)).value?.total ??
        NutritionTotals.empty;
    final goals = ref.watch(nutritionGoalsProvider).value;
    final target = ref.watch(dayCalorieTargetProvider);
    final hideCalorieNumbers = goals?.hideCalorieNumbers ?? false;

    final rows = homeMacroRows(
      totals: totals,
      goals: goals,
      basisKcal: target.targetKcal,
    );

    return HomeCard(
      icon: Icons.restaurant_outlined,
      title: 'Nutrition today',
      onTap: () => const NutritionRouteData().go(context),
      semanticsLabel: 'Nutrition today, open the food diary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!hideCalorieNumbers) ...[
            _EnergyLine(totals: totals, target: target),
            SizedBox(height: tokens.spacingSm),
          ],
          for (final row in rows) ...[
            _MacroBar(row: row),
            SizedBox(height: tokens.spacingXs),
          ],
          if (totals.isEmpty)
            Text(
              'Nothing logged yet today.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _EnergyLine extends StatelessWidget {
  const _EnergyLine({required this.totals, required this.target});

  final NutritionTotals totals;
  final DayCalorieTarget target;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final targetKcal = target.targetKcal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          targetKcal == null
              ? formatKcal(totals.caloriesKcal)
              : '${formatKcal(totals.caloriesKcal)} of '
                    '${target.isEstimate ? 'about ' : ''}'
                    '${formatEstimatedKcal(targetKcal)}',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 2,
        ),
        if (targetKcal == null)
          Text(
            'No target set',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

/// One macro: its name, "N g" (or "N g of M g"), and — only when there is a
/// target — a clamped bar.
class _MacroBar extends StatelessWidget {
  const _MacroBar({required this.row});

  final HomeMacroRow row;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final targetGrams = row.targetGrams;
    final value = targetGrams == null
        ? formatGrams(row.grams)
        : '${formatGrams(row.grams)} of ${formatGrams(targetGrams)}';
    final fraction = row.fraction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                row.macro.label,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: tokens.spacingXs),
            // A clipped number is a wrong number, not a cosmetic clip
            // (`knowledge/engineering/accessibility.md`), so this scales
            // down rather than ellipsising.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(value, style: textTheme.labelMedium),
              ),
            ),
          ],
        ),
        if (fraction != null) ...[
          SizedBox(height: tokens.spacingXs / 2),
          LinearProgressIndicator(
            value: fraction,
            borderRadius: BorderRadius.circular(tokens.radiusSm),
          ),
        ],
      ],
    );
  }
}
