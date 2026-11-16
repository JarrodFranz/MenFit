import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';

class KetoMacrosCard extends ConsumerWidget {
  const KetoMacrosCard({required this.day, super.key});

  final LocalDate day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final totals = ref.watch(dayNutritionTotalsProvider(day));
    final goals = ref.watch(nutritionGoalsProvider);
    final basis = ref.watch(dayCalorieTargetProvider);
    final targets = goals.value?.macroTargetGramsFor(basis.targetKcal);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Macros from your diary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: tokens.spacingSm),
            totals.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text(userMessageFor(error)),
              data: (dayTotals) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dayTotals.total.isEmpty)
                    const Text('No food recorded for this day.'),
                  for (final macro in [
                    (
                      'Recorded carbs',
                      dayTotals.total.carbsGrams,
                      targets?.carbs,
                    ),
                    ('Protein', dayTotals.total.proteinGrams, targets?.protein),
                    ('Fat', dayTotals.total.fatGrams, targets?.fat),
                  ])
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: tokens.spacingXs),
                      child: Text(
                        [
                          '${macro.$1}: ${macro.$2.toStringAsFixed(1)} g',
                          if (macro.$3 != null)
                            'current target ${macro.$3!.toStringAsFixed(1)} g',
                        ].join(' · '),
                      ),
                    ),
                ],
              ),
            ),
            if (goals.isLoading) const Text('Loading targets…'),
            if (goals.hasError) const Text('Targets could not be loaded.'),
            if (goals.value?.macroTargetMode == MacroTargetMode.percent &&
                (basis.targetKcal == null || basis.targetKcal! <= 0))
              const Text(
                'Set an energy target in Nutrition goals to display '
                'percentage targets in grams.',
              ),
            SizedBox(height: tokens.spacingSm),
            const Text(
              'Carbs are recorded as entered or supplied by the food '
              'source. Fibre is not subtracted.',
            ),
            Wrap(
              spacing: tokens.spacingSm,
              children: [
                TextButton(
                  onPressed: () => const NutritionRouteData().go(context),
                  child: const Text('Open food diary'),
                ),
                TextButton(
                  onPressed: () =>
                      const NutritionGoalsRouteData().push<void>(context),
                  child: const Text('Edit macro targets'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
