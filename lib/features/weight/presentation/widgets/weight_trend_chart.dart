import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/weight/domain/weight_range.dart';
import 'package:menfit_app/features/weight/domain/weight_trend.dart';
import 'package:menfit_app/features/weight/presentation/weight_format.dart';

/// The weight timeline: individual readings as dots, the smoothed trend as
/// a line.
///
/// Design rules, following `features/progress/presentation/widgets/`'s
/// `weekly_distance_chart.dart` and departing from it only where weight
/// needs something different:
///
/// - **The y-axis never starts at zero.** A body-weight axis from 0 makes
///   every real change invisible; this one is ranged to the readings plus
///   a small padding.
/// - **The axis is ranged from the raw readings even when only the trend
///   is drawn**, so hiding the dots does not silently rescale the chart
///   and magnify the line's slope. What the toggle changes is what is
///   drawn, never how steep it looks.
/// - **One colour, no valence.** The trend uses [ColorScheme.primary] and
///   the dots [ColorScheme.onSurfaceVariant], whichever way the line is
///   going. Nothing here is ever green for down or red for up — see
///   `knowledge/domain/mens_health.md`.
/// - **Gaps are gaps.** A day with no reading contributes no point; the
///   line joins the readings either side of a gap because that is what a
///   line does, but no value is invented for the days in between (see
///   `domain/weight_trend.dart`).
class WeightTrendChart extends StatelessWidget {
  const WeightTrendChart({
    required this.series,
    required this.unitSystem,
    required this.seriesMode,
    this.height = 240,
    this.enhancedSemantics = false,
    super.key,
  });

  final WeightTrendSeries series;
  final UnitSystem unitSystem;
  final WeightSeriesMode seriesMode;

  final double height;

  /// The user's Enhanced Semantics preference. Off by default; when on,
  /// the chart's label describes the readings rather than only counting
  /// them.
  final bool enhancedSemantics;

  @override
  Widget build(BuildContext context) {
    final points = series.points;
    if (points.isEmpty) return SizedBox(height: height);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final firstDay = points.first.day;
    final span = firstDay.difference(points.last.day);
    final maxX = math.max(span, 1).toDouble();

    final rawValues = [
      for (final point in points) displayWeight(point.weightKg, unitSystem),
    ];
    final (minY, maxY, step) = _axisBounds(rawValues);

    // The trend is only drawn where the engine defined it; a day it left
    // null produces no spot, so the line breaks rather than guessing.
    final trendSpots = <FlSpot>[
      for (final point in points)
        if (point.trendKg != null)
          FlSpot(
            firstDay.difference(point.day).toDouble(),
            displayWeight(point.trendKg!, unitSystem),
          ),
    ];
    final rawSpots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(firstDay.difference(points[i].day).toDouble(), rawValues[i]),
    ];

    // Raw dots are hidden when the user asked for the trend alone, and
    // shown regardless when there is no trend line to show instead.
    final showRaw =
        seriesMode == WeightSeriesMode.readingsAndTrend || trendSpots.isEmpty;

    final bars = <LineChartBarData>[
      if (trendSpots.isNotEmpty)
        LineChartBarData(
          spots: trendSpots,
          color: colorScheme.primary,
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
        ),
      if (showRaw)
        LineChartBarData(
          spots: rawSpots,
          // The dots are the series; the connecting line would read as
          // "these values are continuous", which is the misreading this
          // whole feature exists to prevent.
          color: Colors.transparent,
          barWidth: 0,
          dotData: FlDotData(
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 2.5,
              color: colorScheme.onSurfaceVariant,
              strokeColor: Colors.transparent,
            ),
          ),
        ),
    ];
    final trendBarIndex = trendSpots.isNotEmpty ? 0 : -1;

    return Semantics(
      label: enhancedSemantics
          ? _extendedSemanticsLabel(points)
          : _semanticsLabel(points),
      // Same reasoning as `weekly_distance_chart.dart`: without this the
      // axis and tooltip text nodes underneath would be read out one by
      // one alongside the summary.
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            clipData: const FlClipData.all(),
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: step,
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
                  reservedSize: 40,
                  interval: step,
                  getTitlesWidget: (value, meta) => Text(
                    value.toStringAsFixed(step < 1 ? 1 : 0),
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
                  interval: math.max(1, (maxX / 4).floor()).toDouble(),
                  getTitlesWidget: (value, meta) => SideTitleWidget(
                    meta: meta,
                    // Edge labels are centred on the axis end and otherwise
                    // spill past the chart (the last date ran off the screen
                    // on device, 2026-09-02).
                    fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                    child: Text(
                      _shortDate(firstDay.addDays(value.round())),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipColor: (spot) => colorScheme.inverseSurface,
                getTooltipItems: (spots) => [
                  for (final spot in spots)
                    _buildTooltipItem(
                      spot: spot,
                      day: firstDay.addDays(spot.x.round()),
                      isTrend: spot.barIndex == trendBarIndex,
                      colorScheme: colorScheme,
                    ),
                ],
              ),
              getTouchedSpotIndicator: (barData, spotIndexes) => [
                for (final _ in spotIndexes)
                  TouchedSpotIndicatorData(
                    FlLine(
                      color: colorScheme.outlineVariant,
                      strokeWidth: 1.5,
                      dashArray: const [4, 4],
                    ),
                    FlDotData(
                      getDotPainter: (spot, percent, bar, idx) {
                        final isTrend =
                            bar.color == colorScheme.primary &&
                            bar.barWidth > 0;
                        if (isTrend) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: colorScheme.primary,
                            strokeColor: colorScheme.surface,
                            strokeWidth: 2,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 4.5,
                          color: colorScheme.onSurfaceVariant,
                          strokeColor: colorScheme.surface,
                          strokeWidth: 2,
                        );
                      },
                    ),
                  ),
              ],
            ),
            lineBarsData: bars,
          ),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  LineTooltipItem _buildTooltipItem({
    required FlSpot spot,
    required LocalDate day,
    required bool isTrend,
    required ColorScheme colorScheme,
  }) {
    final value = '${spot.y.toStringAsFixed(1)} ${weightUnitLabel(unitSystem)}';
    final date = _shortDate(day);

    final baseText = isTrend
        ? '$date · $value (${series.windowDays}-day trend)'
        : '$date · $value';

    return LineTooltipItem(
      baseText,
      TextStyle(
        color: colorScheme.onInverseSurface,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  String _semanticsLabel(List<WeightTrendPoint> points) {
    final latest = points.last;
    final count = points.length;
    final readings = count == 1 ? '1 reading' : '$count readings';
    return 'Weight chart, $readings, latest '
        '${formatWeight(latest.weightKg, unitSystem)} on '
        '${_shortDate(latest.day)}';
  }

  /// The readings, said out loud.
  ///
  /// Deliberately *descriptive and directionless*, the same rule the drawn
  /// chart follows: it says where the line starts, where it ends, the
  /// range it moved through and how many readings there are — it never
  /// says "up", "down", "gain", "loss", "progress" or anything that frames
  /// a direction as better (see `weight_copy.dart`, and
  /// `test/features/weight/weight_test_vocabulary.dart`, which gates the
  /// chart's rendered semantics too). A screen-reader user gets the shape
  /// of the data and draws their own conclusion, exactly as a sighted user
  /// does.
  String _extendedSemanticsLabel(List<WeightTrendPoint> points) {
    final values = [for (final point in points) point.weightKg];
    var lowest = points.first;
    var highest = points.first;
    for (var i = 1; i < points.length; i++) {
      if (values[i] < lowest.weightKg) lowest = points[i];
      if (values[i] > highest.weightKg) highest = points[i];
    }

    String reading(WeightTrendPoint point) =>
        '${formatWeight(point.weightKg, unitSystem)} on '
        '${_shortDate(point.day)}';

    final span =
        'from ${_shortDate(points.first.day)} to '
        '${_shortDate(points.last.day)}';

    final sentences = <String>[
      'Weight chart',
      if (points.length == 1) '1 reading' else '${points.length} readings',
      span,
      'First ${reading(points.first)}',
      'Latest ${reading(points.last)}',
      if (points.length > 1) ...[
        'Lowest ${reading(lowest)}',
        'Highest ${reading(highest)}',
      ],
      if (series.hasTrend)
        'A ${series.windowDays}-day trend line is drawn through the readings'
      else
        'No trend line yet',
    ];
    return '${sentences.join('. ')}.';
  }
}

/// Y-axis bounds and gridline step for [values], padded so no point sits
/// on the frame — and never anchored at zero.
///
/// Pure and free of [BuildContext] so it can be unit-tested on its own,
/// same as `weekly_distance_chart.dart`'s `niceInterval`.
(double minY, double maxY, double step) _axisBounds(List<double> values) {
  final low = values.reduce(math.min);
  final high = values.reduce(math.max);
  final spread = high - low;
  // A flat series still needs an axis with height, or the single value
  // would sit on both the floor and the ceiling.
  final padding = math.max(0.5, spread * 0.15);
  final minY = low - padding;
  final maxY = high + padding;
  final step = _axisStep(maxY - minY);
  return (minY, maxY, step);
}

/// A 1/2/5x10^n gridline step giving roughly four gridlines across
/// [range], floored at 0.5 so a narrow axis doesn't get a 0.1 step's worth
/// of clutter.
double _axisStep(double range) {
  if (range <= 0) return 1;
  final rough = range / 4;
  final magnitude = math
      .pow(10, (math.log(rough) / math.ln10 + 1e-9).floor())
      .toDouble();
  for (final multiple in const [1.0, 2.0, 5.0]) {
    final candidate = multiple * magnitude;
    if (candidate >= rough) return math.max(0.5, candidate);
  }
  return math.max(0.5, 10 * magnitude);
}

String _shortDate(LocalDate day) =>
    DateFormat('d MMM').format(DateTime(day.year, day.month, day.day));
