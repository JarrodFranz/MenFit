import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/domain/challenge_codes.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';

/// Which activity types count towards a challenge.
///
/// Selecting nothing is a real answer, not a missing one — an empty set
/// means every type counts
/// (`domain/challenge.dart#ChallengeBlueprint.activityTypes`) — so the
/// picker has no "All" chip to get out of sync with the empty state, and
/// the helper line says plainly what nothing selected does.
///
/// Ordered by [codeActivityTypes], the frozen wire order, so the picker
/// reads in the same order as everything else in this feature.
class ActivityTypePicker extends StatelessWidget {
  const ActivityTypePicker({
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final Set<ActivityType> selected;

  final void Function(ActivityType type) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(activityTypesFieldLabel, style: theme.textTheme.labelLarge),
        SizedBox(height: tokens.spacingXs),
        Wrap(
          spacing: tokens.spacingXs,
          runSpacing: tokens.spacingXs,
          children: [
            for (final type in codeActivityTypes)
              FilterChip(
                key: Key('challengeActivityChip_${type.toStorage()}'),
                showCheckmark: false,
                label: Text(type.label),
                selected: selected.contains(type),
                onSelected: (_) => onToggle(type),
              ),
          ],
        ),
        SizedBox(height: tokens.spacingXs),
        Text(
          activityTypesHelper,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
