import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/single_choice_chips.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_goals_controller.dart';

/// Activity level, weight goal, the size of the daily gap, and the
/// hide-calorie-numbers switch.
///
/// Each control writes on change — there is nothing here that could be
/// half-entered, unlike the typed targets next door.
///
/// Two ED-safe defaults are load-bearing and are not "just defaults"
/// (`knowledge/domain/nutrition.md`): the weight goal starts at "Stay where
/// I am", and the daily gap starts at none. Neither is preselected towards
/// losing weight, and the gap control only appears once the user has said
/// they want their weight to move.
class GoalPreferencesSection extends ConsumerWidget {
  const GoalPreferencesSection({required this.goals, super.key});

  final NutritionGoals? goals;

  /// The gap sizes offered, in kilocalories a day. Deliberately modest and
  /// deliberately capped: this is a picker, not a free-text field, and it
  /// does not offer a number the app would only have to floor away.
  static const List<int> gapOptions = [0, 100, 200, 300, 400, 500];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final controller = ref.read(nutritionGoalsControllerProvider.notifier);
    final weightGoal = goals?.weightGoal ?? WeightGoal.maintain;
    final gap = goals?.dailyDeficitKcal ?? 0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A typical day', style: textTheme.titleMedium),
            SizedBox(height: tokens.spacingXs),
            Text(
              'Used for the energy estimate above. Pick whichever describes '
              'most of your days.',
              style: textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            SingleChoiceChips<ActivityLevel>(
              options: ActivityLevel.values,
              labelFor: (option) => option.label,
              selected: goals?.activityLevel,
              onChanged: (value) => unawaited(
                controller.updateGoals(
                  activityLevel: value,
                  clearActivityLevel: value == null,
                ),
              ),
            ),
            if (goals?.activityLevel != null) ...[
              SizedBox(height: tokens.spacingXs),
              Text(
                goals!.activityLevel!.description,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            SizedBox(height: tokens.spacingLg),
            Text('Your weight goal', style: textTheme.titleMedium),
            SizedBox(height: tokens.spacingSm),
            DropdownButtonFormField<WeightGoal>(
              key: const Key('weightGoalField'),
              initialValue: weightGoal,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'I want to',
              ),
              items: [
                for (final value in WeightGoal.values)
                  DropdownMenuItem(value: value, child: Text(value.label)),
              ],
              onChanged: (value) {
                if (value == null) return;
                unawaited(controller.updateGoals(weightGoal: value));
              },
            ),
            if (weightGoal != WeightGoal.maintain) ...[
              SizedBox(height: tokens.spacingMd),
              DropdownButtonFormField<int>(
                key: const Key('dailyGapField'),
                initialValue: gapOptions.contains(gap) ? gap : 0,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Daily difference to aim for',
                ),
                items: [
                  for (final option in gapOptions)
                    DropdownMenuItem(
                      value: option,
                      child: Text(
                        option == 0 ? 'None for now' : '$option kcal a day',
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  unawaited(controller.updateGoals(dailyDeficitKcal: value));
                },
              ),
            ],
            SizedBox(height: tokens.spacingMd),
            SwitchListTile(
              key: const Key('hideCaloriesSwitch'),
              contentPadding: EdgeInsets.zero,
              value: goals?.hideCalorieNumbers ?? false,
              title: const Text('Hide calorie numbers'),
              subtitle: const Text(
                'Your diary shows protein, carbs, fat and iron, and no '
                "calorie figures. Nothing is lost — they're still recorded, "
                'and this switch brings them back.',
              ),
              onChanged: (value) => unawaited(
                controller.updateGoals(hideCalorieNumbers: value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
