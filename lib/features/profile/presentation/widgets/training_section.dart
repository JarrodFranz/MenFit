import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/domain/weekday.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/single_choice_chips.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/profile/presentation/profile_controller.dart';
import 'package:menfit_app/features/profile/presentation/widgets/run_profile_update.dart';
import 'package:menfit_app/features/profile/presentation/widgets/weekday_toggle_row.dart';

/// 'Training' section of `../profile_screen.dart`: fitness goal, running and
/// strength experience, preferred training days, weekly activity goal, and
/// preferred unit system — every field individually optional except units
/// (`knowledge/product/stage1_audit.md` §5.1).
class TrainingSection extends ConsumerWidget {
  const TrainingSection({required this.profile, super.key});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final unitSystem = profile?.unitSystem ?? UnitSystem.metric;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Training', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: tokens.spacingSm),
        Text(
          'Fitness goals (optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: tokens.spacingXs),
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingXs,
          children: [
            for (final goal in FitnessGoal.values)
              FilterChip(
                label: Text(goal.label),
                selected: (profile?.allFitnessGoals ?? const {}).contains(goal),
                onSelected: (selected) async {
                  final current = profile?.allFitnessGoals ?? const {};
                  final next = Set<FitnessGoal>.from(current);
                  if (selected) {
                    next.add(goal);
                  } else {
                    next.remove(goal);
                  }
                  await runProfileUpdate(
                    context,
                    () => ref
                        .read(profileControllerProvider.notifier)
                        .updateProfile(
                          fitnessGoals: next,
                          clearFitnessGoals: next.isEmpty,
                        ),
                  );
                },
              ),
          ],
        ),
        SizedBox(height: tokens.spacingLg),
        Text(
          'Running experience (optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: tokens.spacingXs),
        SingleChoiceChips<ExperienceLevel>(
          options: ExperienceLevel.values,
          labelFor: (level) => level.label,
          selected: profile?.runningExperience,
          onChanged: (level) => runProfileUpdate(
            context,
            () => ref
                .read(profileControllerProvider.notifier)
                .updateProfile(
                  runningExperience: level,
                  clearRunningExperience: level == null,
                ),
          ),
        ),
        SizedBox(height: tokens.spacingLg),
        Text(
          'Strength experience (optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: tokens.spacingXs),
        SingleChoiceChips<ExperienceLevel>(
          options: ExperienceLevel.values,
          labelFor: (level) => level.label,
          selected: profile?.strengthExperience,
          onChanged: (level) => runProfileUpdate(
            context,
            () => ref
                .read(profileControllerProvider.notifier)
                .updateProfile(
                  strengthExperience: level,
                  clearStrengthExperience: level == null,
                ),
          ),
        ),
        SizedBox(height: tokens.spacingLg),
        Text(
          'Preferred training days (optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: tokens.spacingXs),
        WeekdayToggleRow(
          selected: profile?.trainingDays ?? const <Weekday>{},
          onChanged: (days) => runProfileUpdate(
            context,
            () => ref
                .read(profileControllerProvider.notifier)
                .updateProfile(trainingDays: days),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                'How many times per week is your goal to exercise?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              tooltip: 'Target number of workouts or active sessions per week.',
              onPressed: () {
                unawaited(
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Exercise Goal'),
                      content: const Text(
                        'Set how many workouts or active sessions you aim to '
                        'complete each week. We use this to help you pace '
                        'your routine and monitor consistency.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: tokens.spacingSm),
        _WeeklyGoalStepper(value: profile?.weeklyActivityGoal),
        SizedBox(height: tokens.spacingLg),
        Text('Units', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: tokens.spacingSm),
        SegmentedButton<UnitSystem>(
          segments: const [
            ButtonSegment(value: UnitSystem.metric, label: Text('Metric')),
            ButtonSegment(value: UnitSystem.imperial, label: Text('Imperial')),
          ],
          selected: {unitSystem},
          onSelectionChanged: (selection) => runProfileUpdate(
            context,
            () => ref
                .read(profileControllerProvider.notifier)
                .updateProfile(unitSystem: selection.first),
          ),
        ),
      ],
    );
  }
}

/// A -/+ stepper (1-14) for the weekly activity goal, plus a "No goal" chip
/// that clears it back to `null`.
class _WeeklyGoalStepper extends ConsumerWidget {
  const _WeeklyGoalStepper({required this.value});

  final int? value;

  static const int _min = 1;
  static const int _max = 14;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: tokens.spacingSm,
      runSpacing: tokens.spacingSm,
      children: [
        FilterChip(
          label: const Text('No goal'),
          selected: value == null,
          onSelected: (selected) => selected
              ? runProfileUpdate(
                  context,
                  () => ref
                      .read(profileControllerProvider.notifier)
                      .updateProfile(clearWeeklyActivityGoal: true),
                )
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          tooltip: 'One activity fewer per week',
          onPressed: value == null || value! <= _min
              ? null
              : () => _set(context, ref, value! - 1),
        ),
        SizedBox(
          width: 112,
          child: Text(
            value == null
                ? 'Not set'
                : '$value ${value == 1 ? 'time' : 'times'} / week',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
            // Bare "3 / week" reads as "three slash week" to a screen
            // reader and loses what it counts.
            semanticsLabel: value == null
                ? 'Weekly activity goal not set'
                : 'Weekly activity goal: $value activities per week',
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'One activity more per week',
          onPressed: value != null && value! >= _max
              ? null
              : () => _set(context, ref, value == null ? _min : value! + 1),
        ),
      ],
    );
  }

  Future<void> _set(BuildContext context, WidgetRef ref, int newValue) {
    return runProfileUpdate(
      context,
      () => ref
          .read(profileControllerProvider.notifier)
          .updateProfile(weeklyActivityGoal: newValue.clamp(_min, _max)),
    );
  }
}
