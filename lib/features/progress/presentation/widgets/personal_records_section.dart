import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/domain/personal_records.dart';
import 'package:menfit_app/features/activity/domain/track_analysis.dart';

/// The Progress screen's personal-records list: best-effort times per
/// standard distance (only for distances at least one activity has reached
/// - see `personal_records.dart`), then longest activity and most
/// elevation gain, each as its own row. Only rows for records that
/// actually exist are shown; an encouraging empty state replaces the
/// whole section when [records] has none at all.
class PersonalRecordsSection extends StatelessWidget {
  const PersonalRecordsSection({
    required this.records,
    required this.unitSystem,
    super.key,
  });

  final PersonalRecords records;
  final UnitSystem unitSystem;

  bool get _hasAnyRecord =>
      records.bestEfforts.isNotEmpty ||
      records.longestDistance != null ||
      records.mostElevationGain != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasAnyRecord) return const _EmptyRecords();

    final tokens = Theme.of(context).extension<AppTokens>()!;
    final longestDistance = records.longestDistance;
    final mostElevationGain = records.mostElevationGain;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final distanceMeters in standardEffortDistances)
          if (records.bestEfforts[distanceMeters] case final entry?)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.spacingSm),
              child: _RecordRow(
                key: ValueKey('best-effort-$distanceMeters'),
                label:
                    standardEffortDistanceNames[distanceMeters] ??
                    '${distanceMeters.toStringAsFixed(0)} m',
                value: _bestEffortValue(entry, distanceMeters, unitSystem),
                activityId: entry.activityId,
                activityTitle: entry.activityTitle,
                startedAt: entry.startedAt,
              ),
            ),
        if (longestDistance != null)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.spacingSm),
            child: _RecordRow(
              key: const ValueKey('longest-distance'),
              label: 'Longest activity',
              value: formatDistance(longestDistance.value, unitSystem),
              activityId: longestDistance.activityId,
              activityTitle: longestDistance.activityTitle,
              startedAt: longestDistance.startedAt,
            ),
          ),
        if (mostElevationGain != null)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.spacingSm),
            child: _RecordRow(
              key: const ValueKey('most-elevation-gain'),
              label: 'Most elevation gain',
              // Elevation is always shown in metres regardless of
              // unitSystem, matching `activity_detail_screen.dart`'s stats
              // grid - there is no imperial elevation display anywhere yet.
              value: '${mostElevationGain.value.toStringAsFixed(0)} m',
              activityId: mostElevationGain.activityId,
              activityTitle: mostElevationGain.activityTitle,
              startedAt: mostElevationGain.startedAt,
            ),
          ),
      ],
    );
  }
}

/// `"m:ss · m:ss /km"` (duration, then pace over the target distance).
String _bestEffortValue(
  PrEntry<Duration> entry,
  double distanceMeters,
  UnitSystem unitSystem,
) {
  final km = distanceMeters / 1000;
  final paceSecondsPerKm = entry.value.inSeconds / km;
  return '${formatDuration(entry.value)} · '
      '${formatPace(paceSecondsPerKm, unitSystem)}';
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.label,
    required this.value,
    required this.activityId,
    required this.activityTitle,
    required this.startedAt,
    super.key,
  });

  final String label;
  final String value;
  final String activityId;
  final String activityTitle;

  /// UTC.
  final DateTime startedAt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(label, style: textTheme.titleSmall),
        subtitle: Text(
          '$activityTitle · ${DateFormat.yMMMd().format(startedAt.toLocal())}',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(value, style: textTheme.titleMedium?.tabularFigures),
        onTap: () => ActivityDetailRouteData(activityId).go(context),
      ),
    );
  }
}

/// Shown instead of the list when there isn't a single record yet -
/// encourages logging rather than showing a bare "no data" message, and is
/// plain about what unlocks best-effort times specifically.
class _EmptyRecords extends StatelessWidget {
  const _EmptyRecords();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(tokens.spacingLg),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: Text(
        'Log an activity to start earning personal records — recorded '
        'runs (with GPS) also unlock best-effort times for standard '
        'distances.',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
