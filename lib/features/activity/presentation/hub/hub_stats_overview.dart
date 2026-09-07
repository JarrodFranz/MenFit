import 'package:flutter/material.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/presentation/hub/exercise_hub_providers.dart';

/// Dynamic overview cards customized to the exercise type.
class HubStatsOverview extends StatelessWidget {
  const HubStatsOverview({
    required this.type,
    required this.stats,
    required this.unitSystem,
    super.key,
  });

  final ActivityType type;
  final ExerciseHubStats stats;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();
    final textTheme = Theme.of(context).textTheme;

    final isDistance =
        type == ActivityType.run ||
        type == ActivityType.walk ||
        type == ActivityType.hike ||
        type == ActivityType.ride;

    final distUnit = unitSystem == UnitSystem.imperial ? 'mi' : 'km';
    final distanceVal = unitSystem == UnitSystem.imperial
        ? stats.totalDistanceMiles.toStringAsFixed(1)
        : stats.totalDistanceKm.toStringAsFixed(1);

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: themedCardShape(
        context,
        radius: 16,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${type.label} Overview',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${stats.totalActivities} sessions',
                    textAlign: TextAlign.end,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingMd),
            if (type == ActivityType.strength) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatTile(
                    label: 'Total Volume',
                    value: stats.totalVolumeKg >= 1000
                        ? '${(stats.totalVolumeKg / 1000).toStringAsFixed(1)} t'
                        : '${stats.totalVolumeKg.toStringAsFixed(0)} kg',
                  ),
                  StatTile(
                    label: 'Sets Logged',
                    value: '${stats.totalSets}',
                  ),
                  StatTile(
                    label: 'Total Time',
                    value: _formatDuration(stats.totalDuration),
                  ),
                ],
              ),
            ] else if (isDistance) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatTile(
                    label: 'Total Distance',
                    value: '$distanceVal $distUnit',
                  ),
                  StatTile(
                    label: 'Total Time',
                    value: _formatDuration(stats.totalDuration),
                  ),
                  StatTile(
                    label: 'Avg Pace',
                    value: stats.avgPaceSecondsPerKm > 0
                        ? formatPace(
                            stats.avgPaceSecondsPerKm,
                            unitSystem,
                          )
                        : '--:--',
                  ),
                ],
              ),
            ] else if (type == ActivityType.swim) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatTile(
                    label: 'Total Distance',
                    value: '${stats.totalDistanceMeters.toStringAsFixed(0)} m',
                  ),
                  StatTile(
                    label: 'Total Laps',
                    value: '${stats.totalLaps}',
                  ),
                  StatTile(
                    label: 'Total Time',
                    value: _formatDuration(stats.totalDuration),
                  ),
                ],
              ),
            ] else if (type == ActivityType.hiit) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatTile(
                    label: 'Rounds',
                    value: '${stats.totalRounds}',
                  ),
                  StatTile(
                    label: 'Workouts',
                    value: '${stats.totalActivities}',
                  ),
                  StatTile(
                    label: 'Total Time',
                    value: _formatDuration(stats.totalDuration),
                  ),
                ],
              ),
            ] else if (type == ActivityType.other) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatTile(
                    label: 'Total Time',
                    value: _formatDuration(stats.totalDuration),
                  ),
                  StatTile(
                    label: 'Activities',
                    value: '${stats.totalActivities}',
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatTile(
                    label: 'Mindful Time',
                    value: _formatDuration(stats.totalDuration),
                  ),
                  StatTile(
                    label: 'Sessions',
                    value: '${stats.totalActivities}',
                  ),
                  // No history means no most-practised style, so the tile
                  // says so. It used to invent 'Primary Focus: Flow', which
                  // is not a style she has ever logged and not one the
                  // tracker even offers (ADR 014 §5).
                  StatTile(
                    label: 'Most practised style',
                    value: stats.primaryFocusOrStyle ?? '—',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes} min';
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          // A truncated stat *value* is a wrong number: "42.8 km" clipped to
          // "42.8…" or "1h 55m" to "1h…" reads as a different measurement,
          // not as a shortened one. So the value is never ellipsised — it
          // is scaled down to whatever the third of a card it has, and only
          // the label (which the surrounding context can supply) is allowed
          // to wrap or, in the last resort, to end in an ellipsis.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            // Two lines only for a label that has somewhere to break.
            // Material has no hyphenation, so a second line offered to a
            // single word ("Workouts") is spent breaking it in half —
            // which is worse than the ellipsis it replaced.
            maxLines: label.contains(' ') ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
