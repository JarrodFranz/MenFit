import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/steps/presentation/steps_chart_semantics.dart';
import 'package:menfit_app/features/steps/presentation/steps_copy.dart';
import 'package:menfit_app/features/steps/presentation/steps_stats.dart';

/// One bar per calendar day in the selected range.
///
/// ## The rule this chart exists to keep
///
/// A day with **no row** gets no bar at all — not a zero-height bar, not a
/// bar of the previous day's value, not an interpolation. It keeps its slot
/// on the x-axis (so the week still reads as seven columns) and the note
/// under the chart says how many such days there are. A missing measurement
/// and a measured zero are different facts and the picture must not merge
/// them.
///
/// ## Chart choices
///
/// Single series, so no legend: the heading above names it. One hue
/// ([ColorScheme.primary]); today's bar is that hue at full opacity and
/// every other day at 80%, the same "mark the current period" device
/// `WeeklyDistanceChart` uses. Bars are **not** recoloured by whether they
/// clear the target — the dashed target line already answers that, and
/// colouring by threshold would turn a measurement into a status. Marks are
/// thin with a 4px radius on the top edge only, square on the baseline.
/// Grid is horizontal-only in [ColorScheme.outlineVariant]; all text
/// (axis labels, target label, tooltip) wears text colours, never the bar
/// colour. No permanent per-bar value labels — one direct label on the
/// target line, and the rest lives in the touch/hover tooltip and the list
/// below.
class StepsBarChart extends StatelessWidget {
  const StepsBarChart({
    required this.days,
    required this.target,
    required this.today,
    this.height = 220,
    super.key,
  });

  final List<StepsDayView> days;
  final int target;

  /// Highlighted at full opacity when it falls inside [days].
  final DateTime today;

  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = Theme.of(context).extension<AppTokens>()!;

    final stats = computeStepsRangeStats(days, target: target);
    if (!stats.hasAnyData) {
      return _EmptyChart(height: height);
    }

    final maxSteps = days
        .map((day) => (day.steps ?? 0).toDouble())
        .reduce(math.max);
    // The target line has to fit inside the plot or it silently vanishes on
    // a quiet week.
    final interval = stepsAxisInterval(math.max(maxSteps, target.toDouble()));
    final maxY = stepsAxisMax(math.max(maxSteps, target.toDouble()), interval);

    final barWidth = _barWidthFor(days.length);
    final numberFormat = NumberFormat.decimalPattern();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: stepsChartDescription(
            days: days,
            target: target,
            numberFormat: numberFormat,
          ),
          // Otherwise every axis tick and tooltip node is read out
          // alongside the summary - the noise this one label replaces.
          excludeSemantics: true,
          child: SizedBox(
            height: height,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                alignment: BarChartAlignment.spaceBetween,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: colorScheme.outlineVariant, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: target.toDouble(),
                      color: colorScheme.outline,
                      strokeWidth: 1,
                      dashArray: const [4, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        labelResolver: (_) =>
                            '${numberFormat.format(target)} target',
                      ),
                    ),
                  ],
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval,
                      getTitlesWidget: (value, meta) => Text(
                        _axisLabel(value),
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
                        if (index < 0 || index >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final label = _bottomLabel(index);
                        if (label == null) return const SizedBox.shrink();
                        return SideTitleWidget(
                          meta: meta,
                          fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                          child: Text(
                            label,
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
                      final day = days[group.x];
                      final steps = day.steps;
                      if (steps == null) return null;
                      return BarTooltipItem(
                        '${_tooltipDate(day)} · '
                        '${numberFormat.format(steps)} steps',
                        TextStyle(color: colorScheme.onInverseSurface),
                      );
                    },
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < days.length; i++)
                    BarChartGroupData(
                      x: i,
                      // No rods at all for a day with no row - the slot
                      // stays, the claim does not.
                      barRods: days[i].steps == null
                          ? const []
                          : [
                              BarChartRodData(
                                toY: days[i].steps!.toDouble(),
                                width: barWidth,
                                color: _isToday(i)
                                    ? colorScheme.primary
                                    : colorScheme.primary.withValues(
                                        alpha: 0.8,
                                      ),
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
        ),
        if (stats.missingDays > 0) ...[
          SizedBox(height: tokens.spacingSm),
          Text(
            stepsMissingDaysNote(stats.missingDays),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  bool _isToday(int index) {
    final day = days[index].day;
    return day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;
  }

  /// A weekday initial per bar for a week; day-of-month every 5th bar for a
  /// month, where one label per bar would overlap on a phone.
  String? _bottomLabel(int index) {
    final day = days[index].day;
    if (days.length <= 7) {
      return DateFormat(
        'E',
      ).format(DateTime(day.year, day.month, day.day)).substring(0, 1);
    }
    if (index % 5 != 0) return null;
    return '${day.day}';
  }

  String _tooltipDate(StepsDayView day) {
    return DateFormat(
      'EEE d MMM',
    ).format(DateTime(day.day.year, day.day.month, day.day.day));
  }
}

/// Bar width by how many bars share the width - thin enough that a
/// 31-day month still leaves a visible gap between every pair on a 320dp
/// screen.
double _barWidthFor(int count) {
  if (count <= 7) return 14;
  if (count <= 16) return 8;
  return 5;
}

/// Thousands as `8k`, anything below as the plain number: a steps axis
/// labelled `10,000` three times over eats a third of a phone's width.
String _axisLabel(double value) {
  if (value >= 1000) {
    final thousands = value / 1000;
    final rounded = thousands.roundToDouble();
    return (thousands - rounded).abs() < 0.05
        ? '${rounded.toInt()}k'
        : '${thousands.toStringAsFixed(1)}k';
  }
  return value.round().toString();
}

/// Shown instead of an axis with nothing on it.
class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      // A minimum rather than a fixed height: at 150% text scale on a
      // 320dp screen the two sentences below are taller than the chart
      // they stand in for, and a fixed box would clip them.
      constraints: BoxConstraints(minHeight: height),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              stepsRangeEmptyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: tokens.spacingXs),
            Text(
              stepsRangeEmptyBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
