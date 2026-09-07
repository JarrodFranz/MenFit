import 'package:flutter/material.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/progress/domain/progress_period.dart';
import 'package:menfit_app/features/progress/domain/weekly_summary.dart';
import 'package:menfit_app/features/progress/presentation/widgets/weekly_distance_chart.dart';

/// Activity overview card for the Progress dashboard, displaying total
/// distance, time, workouts, and the trend chart for the selected period.
class ProgressActivityCard extends StatelessWidget {
  const ProgressActivityCard({
    required this.activities,
    required this.weeklySummaries,
    required this.unitSystem,
    required this.period,
    required this.anchor,
    this.enhancedSemantics = false,
    super.key,
  });

  final List<Activity> activities;
  final List<WeeklySummary> weeklySummaries;
  final UnitSystem unitSystem;
  final ProgressPeriod period;
  final LocalDate anchor;

  /// The user's Enhanced Semantics preference, passed straight through to
  /// the chart — the only thing on this card that carries meaning a screen
  /// reader cannot otherwise get at.
  final bool enhancedSemantics;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final range = period.rangeFor(anchor);

    final periodActivities = activities.where((a) {
      final localDay = LocalDate.fromDateTime(a.startedAt.toLocal());
      return !localDay.isBefore(range.start) && !localDay.isAfter(range.end);
    }).toList();

    var totalDistanceMeters = 0.0;
    var totalMovingSeconds = 0;
    for (final a in periodActivities) {
      totalDistanceMeters += a.distanceMeters;
      totalMovingSeconds += a.movingTime.inSeconds;
    }

    final isImperial = unitSystem == UnitSystem.imperial;
    final distanceVal = isImperial
        ? UnitConversions.kmToMi(totalDistanceMeters / 1000)
        : totalDistanceMeters / 1000;
    final distanceUnit = isImperial ? 'mi' : 'km';

    final hours = totalMovingSeconds ~/ 3600;
    final minutes = (totalMovingSeconds % 3600) ~/ 60;
    final durationStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activity & Exercise',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.directions_run_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: tokens.spacingMd),
            Row(
              children: [
                Expanded(
                  child: _ActivityStatTile(
                    key: const ValueKey('progress-stat-distance'),
                    label: 'Distance',
                    value: '${distanceVal.toStringAsFixed(1)} $distanceUnit',
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: _ActivityStatTile(
                    key: const ValueKey('progress-stat-moving-time'),
                    label: 'Moving Time',
                    value: totalMovingSeconds > 0 ? durationStr : '0m',
                  ),
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: _ActivityStatTile(
                    key: const ValueKey('progress-stat-workouts'),
                    label: 'Workouts',
                    value: '${periodActivities.length}',
                  ),
                ),
              ],
            ),
            if (period == ProgressPeriod.week &&
                weeklySummaries.isNotEmpty) ...[
              SizedBox(height: tokens.spacingLg),
              Text(
                'Weekly distance ($distanceUnit)',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: tokens.spacingSm),
              WeeklyDistanceChart(
                summaries: weeklySummaries,
                unitSystem: unitSystem,
                enhancedSemantics: enhancedSemantics,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActivityStatTile extends StatelessWidget {
  const _ActivityStatTile({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(tokens.spacingSm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
