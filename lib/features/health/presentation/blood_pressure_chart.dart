import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_copy.dart';

/// Systolic and diastolic over time, structure copied from
/// `WeightTrendChart`: y-axis never from zero, no valence colours (primary
/// and tertiary, told apart by legend and dot shape too), one point per
/// reading and nothing invented between readings.
class BloodPressureChart extends StatelessWidget {
  const BloodPressureChart({
    required this.readings,
    this.height = 220,
    super.key,
  });

  /// Any order; plotted oldest first.
  final List<BloodPressureReading> readings;
  final double height;

  static const _referenceSystolic = 140.0;
  static const _referenceDiastolic = 90.0;

  @override
  Widget build(BuildContext context) {
    if (readings.length < 2) return const Text(bpChartTooFew);

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tokens = theme.extension<AppTokens>()!;
    final sorted = [...readings]
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final start = sorted.first.measuredAt;
    double xOf(BloodPressureReading r) =>
        r.measuredAt.difference(start).inMinutes / Duration.minutesPerDay;
    final maxX = math.max(xOf(sorted.last), 1).toDouble();

    final values = [
      for (final r in sorted) ...[r.systolic, r.diastolic],
      _referenceSystolic,
      _referenceDiastolic,
    ];
    final low = values.reduce(math.min) - 10;
    final high = values.reduce(math.max) + 10;
    const step = 20.0;
    final minY = (low / step).floorToDouble() * step;
    final maxY = (high / step).ceilToDouble() * step;

    LineChartBarData series(
      Color color,
      int Function(BloodPressureReading) pick, {
      required bool square,
    }) => LineChartBarData(
      spots: [
        for (final r in sorted) FlSpot(xOf(r), pick(r).toDouble()),
      ],
      color: color,
      dotData: FlDotData(
        getDotPainter: (spot, percent, bar, index) => square
            ? FlDotSquarePainter(size: 6, color: color, strokeWidth: 0)
            : FlDotCirclePainter(radius: 3, color: color),
      ),
    );

    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );
    HorizontalLine reference(double y) => HorizontalLine(
      y: y,
      color: colors.outline,
      strokeWidth: 1,
      dashArray: const [6, 4],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: tokens.spacingMd,
          runSpacing: tokens.spacingXs,
          children: [
            _LegendItem(color: colors.primary, label: bpLegendSystolic),
            _LegendItem(
              color: colors.tertiary,
              label: bpLegendDiastolic,
              square: true,
            ),
          ],
        ),
        SizedBox(height: tokens.spacingSm),
        Semantics(
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
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    reference(_referenceSystolic),
                    reference(_referenceDiastolic),
                  ],
                ),
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
                                minutes: (value * Duration.minutesPerDay)
                                    .round(),
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
                    // One tooltip per reading: the systolic spot carries
                    // the whole reading, the diastolic spot adds nothing.
                    getTooltipItems: (spots) => spots
                        .map(
                          (spot) => spot.barIndex == 0 || spots.length == 1
                              ? LineTooltipItem(
                                  _tooltip(sorted[spot.spotIndex]),
                                  TextStyle(
                                    color: colors.onInverseSurface,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                        )
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  series(colors.primary, (r) => r.systolic, square: false),
                  series(colors.tertiary, (r) => r.diastolic, square: true),
                ],
              ),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ),
        SizedBox(height: tokens.spacingSm),
        Text(bpChartCaption, style: labelStyle),
      ],
    );
  }

  String _tooltip(BloodPressureReading r) =>
      '${DateFormat('d MMM, h:mm a').format(r.measuredAt.toLocal())}\n'
      '${bpValues(r.systolic, r.diastolic)}';

  String _semanticsLabel(List<BloodPressureReading> sorted) {
    final first = sorted.first;
    final last = sorted.last;
    String reading(BloodPressureReading r) =>
        '${bpValues(r.systolic, r.diastolic)} on ${_shortDate(r.measuredAt)}';
    return 'Blood pressure chart, ${sorted.length} readings. '
        'First ${reading(first)}. Latest ${reading(last)}.';
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.square = false,
  });

  final Color color;
  final String label;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: tokens.spacingSm,
          height: tokens.spacingSm,
          decoration: BoxDecoration(
            color: color,
            shape: square ? BoxShape.rectangle : BoxShape.circle,
          ),
        ),
        SizedBox(width: tokens.spacingXs),
        Flexible(child: Text(label)),
      ],
    );
  }
}

String _shortDate(DateTime utc) => DateFormat('d MMM').format(utc.toLocal());
