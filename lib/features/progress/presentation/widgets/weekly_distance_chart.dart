import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/progress/domain/weekly_summary.dart';

/// The Progress screen's headline visual: one bar per week of [summaries]
/// (oldest first, per `computeWeeklySummaries`'s contract), distance
/// converted to the user's preferred [unitSystem].
///
/// Design rules (distilled from the design-system chart method for this
/// wave): a single series needs no legend - the "Weekly distance" section
/// title above this widget already names what's being shown. The current
/// week's bar is full-opacity [ColorScheme.primary] while every earlier
/// week is the same color at 55% opacity, marking "this week" without
/// needing a legend entry. The grid is recessive (horizontal lines only,
/// [ColorScheme.outlineVariant]) and no bar carries a permanent value
/// label - that detail lives in the touch/hover tooltip instead. All text
/// (axis labels, tooltip) stays in text colors, never the bar's series
/// color.
class WeeklyDistanceChart extends StatelessWidget {
  const WeeklyDistanceChart({
    required this.summaries,
    required this.unitSystem,
    this.enhancedSemantics = false,
    super.key,
  });

  final List<WeeklySummary> summaries;
  final UnitSystem unitSystem;

  /// The user's Enhanced Semantics preference. Off by default, which is
  /// the shipped default: the short label below is enough for most, and
  /// the full read-out of the series is deliberately opt-in.
  final bool enhancedSemantics;

  @override
  Widget build(BuildContext context) {
    final hasAnyActivity = summaries.any(
      (summary) => summary.activityCount > 0,
    );
    if (!hasAnyActivity) {
      return const _EmptyChart();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isImperial = unitSystem == UnitSystem.imperial;

    final displayValues = [
      for (final summary in summaries)
        if (isImperial)
          UnitConversions.kmToMi(summary.distanceMeters / 1000)
        else
          summary.distanceMeters / 1000,
    ];
    final maxValue = displayValues.reduce(math.max);
    // A "nice" (1/2/5x10^n) gridline step, chosen so 3-5 gridlines fit
    // regardless of how round `maxValue` itself happens to be - see
    // `niceInterval`'s doc.
    final interval = niceInterval(maxValue);
    final maxY = _maxYFor(maxValue, interval);
    final currentWeekIndex = summaries.length - 1;
    final unitWord = isImperial ? 'miles' : 'kilometres';
    final unitAbbr = isImperial ? 'mi' : 'km';

    return Semantics(
      label: enhancedSemantics
          ? weeklyDistanceDescription(
              summaries: summaries,
              displayValues: displayValues,
              unitWord: unitWord,
            )
          : 'Weekly distance chart, last ${summaries.length} weeks, this week '
                '${displayValues[currentWeekIndex].toStringAsFixed(1)} '
                '$unitWord',
      // Without this, the axis/tooltip text nodes underneath merge into
      // this node's label (newline-joined) instead of being replaced by
      // it - a screen reader would read every axis date label along with
      // the summary, which is exactly the noise this single label exists
      // to avoid.
      excludeSemantics: true,
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            minY: 0,
            alignment: BarChartAlignment.spaceBetween,
            // No `groupsSpace` - `BarChartAlignment.spaceBetween` computes
            // its own inter-group gaps from the available width and ignores
            // this parameter entirely (fl_chart's alignment algorithms
            // don't all read it), so setting it here was a dead knob.
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: interval,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: colorScheme.outlineVariant, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: interval,
                  getTitlesWidget: (value, meta) => Text(
                    _axisLabel(value, interval),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  getTitlesWidget: (value, meta) {
                    final index = value.round();
                    // Every 3rd week's label only - one per bar would
                    // overlap at this chart's typical width.
                    if (index < 0 ||
                        index >= summaries.length ||
                        index % 3 != 0) {
                      return const SizedBox.shrink();
                    }
                    return SideTitleWidget(
                      meta: meta,
                      // Edge labels otherwise spill past the chart bounds.
                      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                      child: Text(
                        _shortDate(summaries[index].weekStart),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipColor: (group) => colorScheme.inverseSurface,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final label = _shortDate(summaries[group.x].weekStart);
                  return BarTooltipItem(
                    'week of $label · ${rod.toY.toStringAsFixed(1)} $unitAbbr',
                    TextStyle(color: colorScheme.onInverseSurface),
                  );
                },
              ),
            ),
            barGroups: [
              for (var i = 0; i < summaries.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: displayValues[i],
                      width: 14,
                      color: i == currentWeekIndex
                          ? colorScheme.primary
                          : colorScheme.primary.withValues(alpha: 0.55),
                      // Rounded only at the tip, never at the baseline.
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The chart's bars, said out loud.
///
/// A bar chart is the one thing on the Progress screen that carries its
/// whole meaning in a picture: the short label ("last 12 weeks, this week
/// 8.2 kilometres") names the chart but not its shape, so a screen-reader
/// user is told a chart exists and nothing it shows. This describes the
/// actual series — how many bars, the biggest and smallest weeks by name
/// and value, and how many weeks are empty — built from the same values
/// the bars are drawn from, never a canned sentence.
///
/// [displayValues] is the series already converted to the user's units and
/// aligned index-for-index with [summaries]; [unitWord] is that unit
/// spelled out ("kilometres"), because an abbreviation read aloud is not a
/// word.
///
/// Pure, so it is unit-tested as text rather than through a pumped chart.
String weeklyDistanceDescription({
  required List<WeeklySummary> summaries,
  required List<double> displayValues,
  required String unitWord,
}) {
  final count = displayValues.length;
  var highIndex = 0;
  var lowIndex = 0;
  for (var i = 1; i < count; i++) {
    if (displayValues[i] > displayValues[highIndex]) highIndex = i;
    if (displayValues[i] < displayValues[lowIndex]) lowIndex = i;
  }
  final emptyWeeks = displayValues.where((value) => value <= 0).length;

  String weekPhrase(int index) =>
      'week of ${_shortDate(summaries[index].weekStart)}';
  String valuePhrase(int index) =>
      '${displayValues[index].toStringAsFixed(1)} $unitWord';

  final sentences = <String>[
    'Weekly distance chart',
    '$count bars, one per week',
    'Highest ${weekPhrase(highIndex)}, ${valuePhrase(highIndex)}',
    if (displayValues[lowIndex] <= 0)
      'Lowest ${weekPhrase(lowIndex)}, no distance logged'
    else
      'Lowest ${weekPhrase(lowIndex)}, ${valuePhrase(lowIndex)}',
    'This week ${valuePhrase(count - 1)}',
    if (emptyWeeks == 1)
      '1 week with nothing logged'
    else if (emptyWeeks > 1)
      '$emptyWeeks weeks with nothing logged',
  ];
  return '${sentences.join('. ')}.';
}

String _shortDate(LocalDate weekStart) {
  return DateFormat(
    'd MMM',
  ).format(DateTime(weekStart.year, weekStart.month, weekStart.day));
}

/// Chooses a "nice" gridline step (1, 2, or 5 x 10^n) for an axis whose
/// largest value is [maxValue], so that 3-5 gridlines (0, interval,
/// 2*interval, ... up to the axis max) fit regardless of how round
/// [maxValue] itself happens to be - replaces the previous fixed
/// `maxValue / 3` step, which produced ugly, non-representable labels
/// (e.g. `7 / 3 = 2.333...`, rounded for display into three misleadingly
/// "clean-looking" but not-actually-round numbers).
///
/// The step is never smaller than 1 once [maxValue] reaches 3 or more
/// (a sub-1 gridline step on a chart already spanning several kilometres/
/// miles would be visual noise) - below that, a 0.5 step is allowed so a
/// very small week (e.g. a single 1 km run) still gets more than one
/// gridline instead of a single `0`-to-`maxValue` block.
///
/// Pure and independent of [BuildContext]/theming so it's unit-testable on
/// its own (see `weekly_distance_chart_test.dart`).
double niceInterval(double maxValue) {
  if (maxValue <= 0) return 1;

  const targetGridlines = 4.0;
  final roughStep = maxValue / targetGridlines;
  final minStep = maxValue >= 3 ? 1.0 : 0.5;

  const niceMultiples = [1.0, 2.0, 5.0, 10.0];
  // The tiny `+1e-9` nudge before flooring guards against a `roughStep`
  // that lands (up to floating-point noise) exactly on a power of ten -
  // without it, `log10(1000)` occasionally evaluating to `2.999999...`
  // could floor to `2` instead of `3` and undershoot the magnitude by 10x.
  final magnitude = math
      .pow(10, (math.log(roughStep) / math.ln10 + 1e-9).floor())
      .toDouble();

  var chosen = niceMultiples.last * magnitude;
  for (final multiple in niceMultiples) {
    final candidate = multiple * magnitude;
    if (candidate >= roughStep) {
      chosen = candidate;
      break;
    }
  }

  return chosen < minStep ? minStep : chosen;
}

/// The smallest multiple of [interval] that is `>= maxValue` - the axis's
/// `maxY`. Guarantees the topmost bar never gets clipped against the last
/// gridline, and that every gridline (`0`, `interval`, `2 * interval`, ...,
/// `maxY`) is an exact multiple of [interval].
double _maxYFor(double maxValue, double interval) {
  if (maxValue <= 0) return interval;
  final steps = (maxValue / interval).ceil();
  return steps * interval;
}

/// Formats an axis label for [value] using as many decimals as [interval]
/// itself needs - zero for a whole-number step, one otherwise. Previously
/// every label used `value.round()` unconditionally, which silently lied
/// for a fractional (e.g. `0.5`) step by rounding `0.5` down to `1`,
/// `1.5` up to `2`, and so on.
String _axisLabel(double value, double interval) {
  final stepNeedsDecimal = interval != interval.roundToDouble();
  return stepNeedsDecimal ? value.toStringAsFixed(1) : value.round().toString();
}

/// Friendly placeholder shown instead of an empty/all-zero chart.
class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingLg),
        child: Text(
          "No activity in the last 12 weeks yet — once you've logged a "
          'few, your weekly distance trend shows up here.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
