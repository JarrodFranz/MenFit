import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';

/// Explains an applied BMR floor, in the words the domain carries.
///
/// Product decision 2, made visible: a deficit that would have gone below
/// the user's estimated resting needs is allowed to be *asked for*, but the
/// target it produces is raised to that floor and the app says so. The copy
/// is [floorExplanation] verbatim — the one place the rule is worded — and
/// the figures come off [FlooredCalorieTarget], so this widget invents
/// nothing and can't drift from the rule.
///
/// Styled as information, never as a warning: no error colour, no alert
/// icon. Nothing here is the user's mistake.
class FlooredTargetNote extends StatelessWidget {
  const FlooredTargetNote(this.outcome, {super.key});

  final FlooredCalorieTarget outcome;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
          SizedBox(width: tokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The gap you asked for goes below your estimated resting '
                  'needs of about ${formatEstimatedKcal(outcome.floorKcal)} '
                  'a day.',
                  style: textTheme.bodyMedium,
                ),
                SizedBox(height: tokens.spacingSm),
                Text(floorExplanation, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
