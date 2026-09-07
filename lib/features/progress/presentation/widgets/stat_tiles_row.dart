import 'package:flutter/material.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/progress/domain/weekly_summary.dart';

/// A comparison against last week for one stat: compact on-screen text
/// (already formatted for display - e.g. `"▲ 4.0 km"`), the full
/// phrasing carried by a [Tooltip]/[Semantics] node (e.g. `"+4.0 km vs
/// last week"`), and whether the change is an increase - callers color an
/// increase with [AppTokens.success] and everything else (decrease or
/// flat) as a neutral [ColorScheme.onSurfaceVariant]; a decrease is never
/// shown in an error color (see this wave's brief - encouragement, not
/// judgement).
///
/// `compact` is deliberately terse (F6): these tiles are ~98dp wide, and
/// the previous `"+4.00 km vs last week"` line routinely overflowed or
/// ellipsized into illegibility at that width. The full comparison
/// (including the "vs last week" phrasing) survives as `full`, surfaced
/// via [Tooltip]/[Semantics] rather than dropped.
typedef _Delta = ({String compact, String full, bool isUp});

/// The "this week" stat tiles row: Distance, Time, Activities, each with a
/// small delta line comparing against last week.
///
/// [summaries] must be non-empty and end with the current week (the
/// contract `computeWeeklySummaries` always satisfies) - the screen only
/// builds this once `weeklySummariesProvider` has data.
class StatTilesRow extends StatelessWidget {
  const StatTilesRow({
    required this.summaries,
    required this.unitSystem,
    super.key,
  });

  final List<WeeklySummary> summaries;
  final UnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final thisWeek = summaries.last;
    final lastWeek = summaries[summaries.length - 2];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _StatTile(
            key: const ValueKey('stat-tile-distance'),
            label: 'Distance',
            value: _formatDistanceOneDecimal(
              thisWeek.distanceMeters,
              unitSystem,
            ),
            delta: _distanceDelta(thisWeek, lastWeek, unitSystem),
          ),
        ),
        SizedBox(width: tokens.spacingMd),
        Expanded(
          child: _StatTile(
            key: const ValueKey('stat-tile-time'),
            label: 'Time',
            value: formatDuration(thisWeek.movingTime),
            delta: _timeDelta(thisWeek, lastWeek),
          ),
        ),
        SizedBox(width: tokens.spacingMd),
        Expanded(
          child: _StatTile(
            key: const ValueKey('stat-tile-activities'),
            label: 'Activities',
            value: '${thisWeek.activityCount}',
            delta: _countDelta(thisWeek, lastWeek),
          ),
        ),
      ],
    );
  }
}

/// Formats a distance to one decimal place (e.g. `"12.4 km"`) - a shorter
/// sibling of `pace_format.dart`'s `formatDistance` (two decimals), used
/// only for this row's value line and delta magnitudes so they fit the
/// tiles' ~98dp width (F6). Not reused elsewhere: the activity detail
/// screen and PR section still want `formatDistance`'s extra precision.
String _formatDistanceOneDecimal(double meters, UnitSystem unitSystem) {
  final safeMeters = meters.isFinite && meters > 0 ? meters : 0.0;
  final km = safeMeters / 1000;
  if (unitSystem == UnitSystem.imperial) {
    return '${UnitConversions.kmToMi(km).toStringAsFixed(1)} mi';
  }
  return '${km.toStringAsFixed(1)} km';
}

/// `null` when both weeks are zero for this stat - nothing meaningful to
/// compare yet, so the tile shows no delta line at all rather than a
/// confusing "+0.0 km vs last week".
_Delta? _distanceDelta(
  WeeklySummary thisWeek,
  WeeklySummary lastWeek,
  UnitSystem unitSystem,
) {
  if (thisWeek.distanceMeters == 0 && lastWeek.distanceMeters == 0) {
    return null;
  }
  final deltaMeters = thisWeek.distanceMeters - lastWeek.distanceMeters;
  if (deltaMeters == 0) return _sameAsLastWeek;
  final isUp = deltaMeters > 0;
  final magnitude = _formatDistanceOneDecimal(deltaMeters.abs(), unitSystem);
  return _deltaFor(magnitude: magnitude, isUp: isUp);
}

_Delta? _timeDelta(WeeklySummary thisWeek, WeeklySummary lastWeek) {
  if (thisWeek.movingTime == Duration.zero &&
      lastWeek.movingTime == Duration.zero) {
    return null;
  }
  final deltaSeconds =
      thisWeek.movingTime.inSeconds - lastWeek.movingTime.inSeconds;
  if (deltaSeconds == 0) return _sameAsLastWeek;
  final isUp = deltaSeconds > 0;
  final magnitude = formatDuration(Duration(seconds: deltaSeconds.abs()));
  return _deltaFor(magnitude: magnitude, isUp: isUp);
}

_Delta? _countDelta(WeeklySummary thisWeek, WeeklySummary lastWeek) {
  if (thisWeek.activityCount == 0 && lastWeek.activityCount == 0) return null;
  final delta = thisWeek.activityCount - lastWeek.activityCount;
  if (delta == 0) return _sameAsLastWeek;
  final isUp = delta > 0;
  final plural = delta.abs() == 1 ? 'activity' : 'activities';
  return _deltaFor(
    magnitude: '${delta.abs()}',
    isUp: isUp,
    fullUnitSuffix: ' $plural',
  );
}

/// The shared "no change" delta: a compact `"· same"` marker (neutral
/// color, matching a decrease) rather than a misleading `"+0"`.
const _Delta _sameAsLastWeek = (
  compact: '· same',
  full: 'Same as last week',
  isUp: false,
);

/// Builds a [_Delta] from an already-formatted, sign-free [magnitude] (e.g.
/// `"4.0 km"`, `"4:15"`, `"1"`) - shared by all three stats so the compact
/// arrow-glyph convention and full "vs last week" phrasing stay consistent.
_Delta _deltaFor({
  required String magnitude,
  required bool isUp,
  String fullUnitSuffix = '',
}) {
  final arrow = isUp ? '▲' : '▼'; // ▲ / ▼
  final sign = isUp ? '+' : '-';
  return (
    compact: '$arrow $magnitude',
    full: '$sign$magnitude$fullUnitSuffix vs last week',
    isUp: isUp,
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    this.delta,
    super.key,
  });

  final String label;
  final String value;
  final _Delta? delta;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final delta = this.delta;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold)
              .tabularFigures,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (delta != null) ...[
          SizedBox(height: tokens.spacingXs),
          Tooltip(
            message: delta.full,
            child: Semantics(
              label: delta.full,
              // Without this, the compact `Text` below's own auto-generated
              // semantics node (reading the arrow glyph literally) would
              // merge with this label instead of being replaced by it -
              // the same double-announcement fix as `home_screen.dart`'s
              // `_DashboardCard` (F8).
              excludeSemantics: true,
              child: Text(
                delta.compact,
                style: textTheme.bodySmall?.copyWith(
                  color: delta.isUp
                      ? tokens.success
                      : colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
