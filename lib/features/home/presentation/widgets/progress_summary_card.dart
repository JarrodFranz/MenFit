import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/home/presentation/widgets/home_card.dart';
import 'package:menfit_app/features/progress/progress_providers.dart';

/// This week's activity volume, with a way through to the full Progress
/// screen.
///
/// Reads `weeklySummariesProvider` — `progress`' own definition of a week
/// (Monday start, zero-filled, midnight-rollover aware) — rather than
/// re-folding the activity list here, so the home card and the Progress
/// chart can't disagree about what "this week" contains. The current week
/// is the **last** entry: that provider returns oldest-first and always
/// returns a full run of weeks, so the last one always exists.
class ProgressSummaryCard extends ConsumerWidget {
  const ProgressSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final summaries = ref.watch(weeklySummariesProvider).value;
    final unitSystem =
        ref.watch(activityUnitSystemProvider).value ?? UnitSystem.metric;
    final thisWeek = (summaries == null || summaries.isEmpty)
        ? null
        : summaries.last;

    return HomeCard(
      icon: Icons.insights_outlined,
      title: 'This week',
      onTap: () => const ProgressRouteData().go(context),
      semanticsLabel: "This week's volume, open Progress",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // A clipped distance is a wrong distance
          // (`knowledge/engineering/accessibility.md`).
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              // `--` while the first emission is still in flight: an
              // unloaded week is not a week of nothing.
              thisWeek == null
                  ? '--'
                  : formatDistance(thisWeek.distanceMeters, unitSystem),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: tokens.spacingXs / 2),
          Text(
            thisWeek == null
                ? 'Loading this week'
                : _workoutsLabel(thisWeek.activityCount),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
          ),
          SizedBox(height: tokens.spacingSm),
          Row(
            children: [
              // `Flexible`, not a bare `Text`: at 150% scale on a 320dp
              // phone this row gets 256dp and the label alone wants ~275,
              // which overflowed the row rather than wrapping. Flexible
              // (loose, so the chevron stays beside the label instead of
              // being pushed to the card's edge) lets it take two lines;
              // the ellipsis is the last resort under that.
              Flexible(
                child: Text(
                  'View progress',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _workoutsLabel(int count) => switch (count) {
    0 => 'No workouts logged yet',
    1 => '1 workout',
    _ => '$count workouts',
  };
}
