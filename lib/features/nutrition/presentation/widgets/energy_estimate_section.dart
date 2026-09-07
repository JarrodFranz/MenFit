import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/floored_target_note.dart';

/// The estimate the goals screen is built on, and the daily figure it
/// resolves to — including both non-happy paths, spelled out.
///
/// - [NoEnergyEstimate] names the inputs it is still waiting on, using the
///   labels the domain carries, and sends the user to the right place for
///   each: the profile holds height/weight/date of birth, while the activity
///   level lives on *this* screen — which is exactly why
///   `NoEnergyEstimate.activityLevelMissing` is tracked apart from
///   `missing`.
/// - [FlooredCalorieTarget] is never presented as a bare number: the applied
///   floor and its explanation are shown by [FlooredTargetNote].
///
/// Every figure here is labelled as an estimate. The research review
/// (`knowledge/research/nutrition_energy_estimates.md`) is explicit that
/// these are outside ±10% for one person in five, and that the UI must not
/// paper over it.
class EnergyEstimateSection extends StatelessWidget {
  const EnergyEstimateSection({
    required this.estimate,
    required this.outcome,
    required this.onOpenProfile,
    super.key,
  });

  final EnergyEstimateResult? estimate;
  final CalorieTargetOutcome? outcome;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final estimateResult = estimate;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your energy estimate', style: textTheme.titleMedium),
            SizedBox(height: tokens.spacingSm),
            if (estimateResult == null)
              const LinearProgressIndicator()
            else
              switch (estimateResult) {
                final EnergyEstimate value => _Estimate(estimate: value),
                final NoEnergyEstimate value => _MissingInputs(
                  gap: value,
                  onOpenProfile: onOpenProfile,
                ),
              },
            ..._targetBlock(context, tokens),
          ],
        ),
      ),
    );
  }

  List<Widget> _targetBlock(BuildContext context, AppTokens tokens) {
    final textTheme = Theme.of(context).textTheme;
    return switch (outcome) {
      CalorieTarget(:final targetKcal) => [
        SizedBox(height: tokens.spacingMd),
        Text(
          'That works out at about ${formatEstimatedKcal(targetKcal)} a day '
          'for the goal below.',
          style: textTheme.bodyMedium,
        ),
      ],
      final FlooredCalorieTarget value => [
        SizedBox(height: tokens.spacingMd),
        Text(
          'Your daily figure is about '
          '${formatEstimatedKcal(value.targetKcal)}.',
          style: textTheme.bodyMedium,
        ),
        SizedBox(height: tokens.spacingSm),
        FlooredTargetNote(value),
      ],
      NoCalorieTarget() || null => const [],
    };
  }
}

class _Estimate extends StatelessWidget {
  const _Estimate({required this.estimate});

  final EnergyEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About ${formatEstimatedKcal(estimate.basalMetabolicRateKcal)} a day '
          'at rest.',
          style: textTheme.bodyLarge,
        ),
        SizedBox(height: tokens.spacingXs),
        Text(
          'About ${formatEstimatedKcal(estimate.totalDailyEnergyKcal)} a day '
          'with a ${estimate.activityLevel.label.toLowerCase()} routine.',
          style: textTheme.bodyLarge,
        ),
        SizedBox(height: tokens.spacingSm),
        Text(
          'Both figures are estimates worked out from your profile, not '
          'measurements, and not medical advice. The everyday figure is the '
          'rougher of the two.',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MissingInputs extends StatelessWidget {
  const _MissingInputs({required this.gap, required this.onOpenProfile});

  final NoEnergyEstimate gap;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "There isn't enough in your profile to estimate this yet.",
          style: textTheme.bodyLarge,
        ),
        if (gap.missing.isNotEmpty) ...[
          SizedBox(height: tokens.spacingSm),
          Text(
            'We still need ${formatMissingInputs(gap.missing)}.',
            style: textTheme.bodyMedium,
          ),
          SizedBox(height: tokens.spacingSm),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onOpenProfile,
              icon: const Icon(Icons.person_outline),
              label: const Text('Open your profile'),
            ),
          ),
        ],
        if (gap.activityLevelMissing) ...[
          SizedBox(height: tokens.spacingSm),
          Text(
            'We also need a typical activity level — you can pick one further '
            'down this screen.',
            style: textTheme.bodyMedium,
          ),
        ],
        SizedBox(height: tokens.spacingSm),
        Text(
          'The diary works without any of this. Nothing here is required.',
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
