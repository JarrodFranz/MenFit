import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_goals_controller.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/daily_targets_section.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/energy_estimate_section.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/goal_preferences_section.dart';

/// `/nutrition/goals` — the estimate, the daily targets, and the display
/// preference, in that order: what the app worked out, then what the user
/// wants, then how they'd like to see it.
///
/// A thin orchestrator over three sections (`widgets/`), same shape as
/// `profile_screen.dart`, so it stays well under the splitting guideline.
///
/// Calorie figures are **not** hidden on this screen when the
/// hide-calorie-numbers preference is on: this is the surface where a
/// calorie target is entered and where the preference itself lives, so
/// blanking the field would leave the user unable to set or unset the thing
/// they came here for. The preference is about the diary
/// (`domain/nutrition_goals.dart` words it exactly that way).
class NutritionGoalsScreen extends ConsumerWidget {
  const NutritionGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final goalsAsync = ref.watch(nutritionGoalsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition goals')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: goalsAsync.when(
              data: (goals) => _Sections(goals: goals),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text(userMessageFor(error))),
            ),
          ),
        ),
      ),
    );
  }
}

class _Sections extends ConsumerWidget {
  const _Sections({required this.goals});

  final NutritionGoals? goals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final estimate = ref.watch(energyEstimateProvider).value;
    final outcome = ref.watch(calorieTargetProvider).value;

    return ListView(
      padding: EdgeInsets.all(tokens.spacingMd),
      children: [
        EnergyEstimateSection(
          estimate: estimate,
          outcome: outcome,
          // The profile is where height, weight and date of birth live, and
          // it sits in another branch of the shell — `go`, not `push`, so
          // the user lands there properly rather than on a profile stacked
          // on top of the nutrition tab.
          onOpenProfile: () => const SettingsProfileRouteData().go(context),
        ),
        SizedBox(height: tokens.spacingMd),
        GoalPreferencesSection(goals: goals),
        SizedBox(height: tokens.spacingMd),
        DailyTargetsSection(
          // Rebuilds the section's text controllers from scratch when the
          // goals row first comes into existence, rather than relying on a
          // didUpdateWidget that can't tell "created" from "echoed".
          key: ValueKey(goals?.id),
          goals: goals,
        ),
        SizedBox(height: tokens.spacingMd),
        Text(
          'These figures are estimates, and nothing here is medical advice. '
          'A dietitian can help you with anything this app should not.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: tokens.spacingXl),
      ],
    );
  }
}
