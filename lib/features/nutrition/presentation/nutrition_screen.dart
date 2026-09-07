import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/fueling_consistency_evaluator.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/micronutrient_adequacy.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/copy_meal_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/log_entry_dialog.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_day_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/quick_add_dialog.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/day_selector.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/day_totals_card.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/meal_section.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/micronutrient_adequacy_card.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/nutrition_overview_carousel.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/water_intake_card.dart';

/// `/nutrition` — the food diary for one day: the day's summary, then the
/// four meals in [MealType] order, each with its entries, its subtotal and
/// its own "Add food".
///
/// The day is browsable backwards without limit and never forwards past
/// today (see [SelectedNutritionDay]).
///
/// **Hide calorie numbers is a mode, not a decoration.** When
/// [NutritionGoals.hideCalorieNumbers] is on, no calorie figure is built
/// anywhere on this screen — the day's energy block, every meal subtotal and
/// every row's trailing figure are replaced by macro lines or omitted. The
/// figures are still recorded and still there when the preference goes off
/// (`domain/nutrition_goals.dart`), and both adequacy indicators (protein,
/// iron) stay visible throughout, which is the point.
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final day = ref.watch(selectedNutritionDayProvider);
    final entriesAsync = ref.watch(nutritionEntriesProvider(day));
    final totalsAsync = ref.watch(dayNutritionTotalsProvider(day));
    final goals = ref.watch(nutritionGoalsProvider).value;
    final target = ref.watch(dayCalorieTargetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Nutrition goals',
            onPressed: () =>
                const NutritionGoalsRouteData().push<void>(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: switch ((entriesAsync, totalsAsync)) {
              (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
                Center(child: Text(userMessageFor(error))),
              (
                AsyncData(value: final entries),
                AsyncData(value: final totals),
              ) =>
                _DayView(
                  day: day,
                  entries: entries,
                  totals: totals,
                  goals: goals,
                  target: target,
                ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ),
      ),
    );
  }
}

class _DayView extends ConsumerWidget {
  const _DayView({
    required this.day,
    required this.entries,
    required this.totals,
    required this.goals,
    required this.target,
  });

  final LocalDate day;
  final List<NutritionEntry> entries;
  final DayNutritionTotals totals;
  final NutritionGoals? goals;
  final DayCalorieTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final fuelingConsistency = ref.watch(fuelingConsistencyProvider).value;
    final hideCalories = goals?.hideCalorieNumbers ?? false;
    // Which meals the day before this one has something in. Absent while it
    // loads, which reads as "no offer yet" rather than a flicker of one.
    final copyable =
        ref.watch(copyableMealsProvider(day)).value ?? const <MealType>{};

    final adequacyItems = evaluateMicronutrientAdequacy(totals: totals.total);

    return ListView(
      padding: EdgeInsets.all(tokens.spacingMd),
      children: [
        DaySelector(
          day: day,
          onChanged: ref.read(selectedNutritionDayProvider.notifier).select,
        ),
        SizedBox(height: tokens.spacingSm),
        if (fuelingConsistency != null &&
            fuelingConsistency.isMilestoneAchieved) ...[
          _FuelingConsistencyCard(result: fuelingConsistency),
          SizedBox(height: tokens.spacingSm),
        ],
        NutritionOverviewCarousel(
          totals: totals.total,
          target: target,
          goals: goals,
          hideCalorieNumbers: hideCalories,
        ),
        SizedBox(height: tokens.spacingSm),
        if (totals.total.isEmpty)
          const _DayEmptyState()
        else ...[
          DayTotalsCard(
            totals: totals.total,
            target: target,
            goals: goals,
            hideCalorieNumbers: hideCalories,
          ),
          SizedBox(height: tokens.spacingSm),
          MicronutrientAdequacyCard(items: adequacyItems),
        ],
        SizedBox(height: tokens.spacingSm),
        WaterIntakeCard(day: day),
        SizedBox(height: tokens.spacingSm),
        for (final meal in MealType.values)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.spacingSm),
            child: MealSection(
              meal: meal,
              entries: [
                for (final entry in entries)
                  if (entry.meal == meal) entry,
              ],
              subtotal: totals.byMeal[meal] ?? NutritionTotals.empty,
              hideCalorieNumbers: hideCalories,
              onAddFood: () => NutritionAddFoodRouteData(
                day: day.toIso(),
                meal: meal,
              ).push<void>(context),
              onQuickAdd: () => QuickAddDialog.show(
                context,
                day: day,
                meal: meal,
              ),
              onCopyFromYesterday:
                  copyable.contains(meal) &&
                      !ref.watch(copyMealControllerProvider(day, meal))
                  ? () => unawaited(_copyFromYesterday(context, ref, meal))
                  : null,
              onEditEntry: (entry) => LogEntryDialog.show(
                context,
                day: day,
                meal: entry.meal,
                existing: entry,
              ),
            ),
          ),
        SizedBox(height: tokens.spacingSm),
        const _Disclaimer(),
        SizedBox(height: tokens.spacingXl),
      ],
    );
  }

  /// Repeats [meal] from the day before, then says how much moved.
  ///
  /// The confirmation counts items and nothing else: a figure for what was
  /// just copied would put an energy total in front of someone who may have
  /// turned those off, and would read as a verdict on the meal either way
  /// (`knowledge/domain/nutrition.md`'s copy stance).
  Future<void> _copyFromYesterday(
    BuildContext context,
    WidgetRef ref,
    MealType meal,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final copied = await ref
          .read(copyMealControllerProvider(day, meal).notifier)
          .copyFromPreviousDay();
      // Nothing to copy: the offer was already gone by the time it was
      // taken. Saying "copied 0" would be noise about a non-event.
      if (copied == 0) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              copied == 1 ? 'Copied 1 item' : 'Copied $copied items',
            ),
          ),
        );
    } on Object catch (error) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(userMessageFor(error))));
    }
  }
}

/// Shown in place of the summary on a day with nothing logged.
///
/// Warm and un-instructive on purpose: it says what the screen is, not what
/// the user should eat, and it doesn't imply an empty day is a lapse
/// (`knowledge/domain/nutrition.md`'s ED-safe stance).
class _DayEmptyState extends StatelessWidget {
  const _DayEmptyState();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingLg),
        child: Column(
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: tokens.spacingMd),
            Text(
              "Nothing in the diary for this day. Add what you'd like to "
              'keep track of, whenever suits you.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Nutrition figures come from what you enter, and any daily figure is '
      'an estimate rather than medical advice.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _FuelingConsistencyCard extends StatelessWidget {
  const _FuelingConsistencyCard({required this.result});

  final FuelingConsistencyResult result;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(tokens.spacingSm),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.stars_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: tokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        result.milestoneTitle ?? 'Fueling Consistency Win',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (result.badgeLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          result.badgeLabel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: tokens.spacingXs),
                Text(
                  result.milestoneSubtitle ??
                      'Consistency in nourishing your body builds strength.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
