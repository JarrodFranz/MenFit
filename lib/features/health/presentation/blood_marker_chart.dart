import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/presentation/blood_marker_copy.dart';

/// Glucose over time in [unit] (readings in the other unit converted for
/// display only). Structure as `BloodPressureChart`; no reference band,
/// because one chart mixes contexts with different ranges or none.
class BloodMarkerChart extends StatelessWidget {
  const BloodMarkerChart({
    required this.readings,
    required this.unit,
    this.height = 220,
    super.key,
  });

  /// Any order; plotted oldest first.
  final List<BloodMarkerReading> readings;
  final BloodMarkerUnit unit;
  final double height;

  double _y(BloodMarkerReading r) => glucoseIn(unit, r.value, r.unit);

  @override
  Widget build(BuildContext context) {
    if (readings.length < 2) return const Text(glucoseChartTooFew);

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sorted = [...readings]
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final start = sorted.first.measuredAt;
    double xOf(BloodMarkerReading r) =>
        r.measuredAt.difference(start).inMinutes / Duration.minutesPerDay;
    final maxX = math.max(xOf(sorted.last), 1).toDouble();

    final values = [for (final r in sorted) _y(r)];
    final base = unit == BloodMarkerUnit.mmolPerL ? 1.0 : 20.0;
    final low = values.reduce(math.min) - base;
    final high = values.reduce(math.max) + base;
    // Widen the grid step so there are at most about six labels.
    final step = base * math.max(1, ((high - low) / base / 6).ceil());
    final minY = math.max(0, (low / step).floor() * step).toDouble();
    final maxY = (high / step).ceilToDouble() * step;

    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );

    return Semantics(
      label: _semanticsLabel(sorted),
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
                  FlLine(color: colors.outlineVariant, strokeWidth: 1),
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
                  getTitlesWidget: (value, meta) =>
                      Text(value.toStringAsFixed(0), style: labelStyle),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: math.max(1, (maxX / 3).floor()).toDouble(),
                  getTitlesWidget: (value, meta) => SideTitleWidget(
                    meta: meta,
                    fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                    child: Text(
                      _shortDate(
                        start.add(
                          Duration(
                            minutes: (value * Duration.minutesPerDay).round(),
                          ),
                        ),
                      ),
                      style: labelStyle,
                    ),
                  ),
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipColor: (spot) => colors.inverseSurface,
                getTooltipItems: (spots) => [
                  for (final spot in spots)
                    LineTooltipItem(
                      _tooltip(sorted[spot.spotIndex]),
                      TextStyle(
                        color: colors.onInverseSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [for (final r in sorted) FlSpot(xOf(r), _y(r))],
                color: colors.primary,
                dotData: FlDotData(
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(radius: 3, color: colors.primary),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 250),
        ),
      ),
    );
  }

  String _shown(BloodMarkerReading r) => glucoseValue(_y(r), unit);

  String _tooltip(BloodMarkerReading r) => [
    DateFormat('d MMM, h:mm a').format(r.measuredAt.toLocal()),
    _shown(r),
    ?r.context?.label,
  ].join('\n');

  String _semanticsLabel(List<BloodMarkerReading> sorted) {
    String reading(BloodMarkerReading r) =>
        '${_shown(r)} on ${_shortDate(r.measuredAt)}';
    return 'Blood glucose chart, ${sorted.length} readings. '
        'First ${reading(sorted.first)}. Latest ${reading(sorted.last)}.';
  }
}

String _shortDate(DateTime utc) => DateFormat('d MMM').format(utc.toLocal());
