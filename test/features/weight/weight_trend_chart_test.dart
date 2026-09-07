import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/weight/domain/weight_range.dart';
import 'package:menfit_app/features/weight/domain/weight_trend.dart';
import 'package:menfit_app/features/weight/presentation/widgets/weight_trend_chart.dart';

void main() {
  final day1 = LocalDate(2026, 3, 1);

  WeightLog log(int offset, double kg) {
    final day = day1.addDays(offset);
    return WeightLog(
      id: '${day.toIso()}-$kg',
      day: day,
      weightKg: kg,
      createdAt: DateTime.utc(2026, 3, 1, 7),
      updatedAt: DateTime.utc(2026, 3, 1, 7),
    );
  }

  WeightTrendSeries seriesOf(List<double> values) => computeWeightTrend(
    logs: [for (var i = 0; i < values.length; i++) log(i, values[i])],
  );

  Widget host(
    WeightTrendSeries series, {
    WeightSeriesMode mode = WeightSeriesMode.readingsAndTrend,
    UnitSystem unitSystem = UnitSystem.metric,
  }) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: WeightTrendChart(
          series: series,
          unitSystem: unitSystem,
          seriesMode: mode,
        ),
      ),
    );
  }

  LineChartData dataOf(WidgetTester tester) =>
      tester.widget<LineChart>(find.byType(LineChart)).data;

  testWidgets('renders a chart for a fixture series', (tester) async {
    await tester.pumpWidget(host(seriesOf([60, 61, 60, 62, 60, 61, 60])));
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);
    // One trend line and one dot-only series.
    expect(dataOf(tester).lineBarsData, hasLength(2));
  });

  testWidgets('renders nothing but space for an empty series', (tester) async {
    await tester.pumpWidget(host(const WeightTrendSeries.empty()));
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('trend-only mode drops the raw readings', (tester) async {
    await tester.pumpWidget(
      host(
        seriesOf([60, 61, 60, 62, 60, 61, 60]),
        mode: WeightSeriesMode.trendOnly,
      ),
    );
    await tester.pumpAndSettle();

    expect(dataOf(tester).lineBarsData, hasLength(1));
  });

  testWidgets('trend-only still shows readings when there is no trend', (
    tester,
  ) async {
    // Under the minimum-data gate there is no line to show instead, so
    // hiding the dots would leave an empty frame.
    await tester.pumpWidget(
      host(seriesOf([60, 61, 60]), mode: WeightSeriesMode.trendOnly),
    );
    await tester.pumpAndSettle();

    expect(dataOf(tester).lineBarsData, hasLength(1));
    expect(dataOf(tester).lineBarsData.single.spots, hasLength(3));
  });

  group('y axis', () {
    testWidgets('never starts at zero', (tester) async {
      await tester.pumpWidget(host(seriesOf([60, 61, 60, 62, 60, 61, 60])));
      await tester.pumpAndSettle();

      expect(dataOf(tester).minY, greaterThan(50));
    });

    testWidgets('pads so no reading sits on the frame', (tester) async {
      await tester.pumpWidget(host(seriesOf([60, 61, 60, 62, 60, 61, 60])));
      await tester.pumpAndSettle();

      expect(dataOf(tester).minY, lessThan(60));
      expect(dataOf(tester).maxY, greaterThan(62));
    });

    testWidgets('does not rescale when the dots are hidden', (tester) async {
      final series = seriesOf([60, 61, 60, 62, 60, 61, 60]);

      await tester.pumpWidget(host(series));
      await tester.pumpAndSettle();
      final withDots = (dataOf(tester).minY, dataOf(tester).maxY);

      await tester.pumpWidget(host(series, mode: WeightSeriesMode.trendOnly));
      await tester.pumpAndSettle();

      expect((dataOf(tester).minY, dataOf(tester).maxY), withDots);
    });

    testWidgets('gives a flat series an axis with height', (tester) async {
      await tester.pumpWidget(host(seriesOf([60, 60, 60, 60, 60, 60])));
      await tester.pumpAndSettle();

      expect(dataOf(tester).maxY, greaterThan(dataOf(tester).minY));
    });
  });

  group('unit preference', () {
    testWidgets('plots kilograms for a metric user', (tester) async {
      await tester.pumpWidget(host(seriesOf([60, 61, 60, 62, 60, 61, 60])));
      await tester.pumpAndSettle();

      expect(dataOf(tester).maxY, lessThan(100));
    });

    testWidgets('plots pounds for an imperial user', (tester) async {
      await tester.pumpWidget(
        host(
          seriesOf([60, 61, 60, 62, 60, 61, 60]),
          unitSystem: UnitSystem.imperial,
        ),
      );
      await tester.pumpAndSettle();

      expect(dataOf(tester).maxY, greaterThan(130));
    });

    testWidgets('summarises itself in the reading unit for screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          seriesOf([60, 61, 60, 62, 60, 61, 60]),
          unitSystem: UnitSystem.imperial,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(RegExp('lb')), findsOneWidget);
      handle.dispose();
    });
  });

  group('interactive touch', () {
    testWidgets('tooltip item shows the reading', (tester) async {
      await tester.pumpWidget(host(seriesOf([60, 61, 62])));
      await tester.pumpAndSettle();

      final touchData = dataOf(tester).lineTouchData;
      final tooltipData = touchData.touchTooltipData;

      final items0 = tooltipData.getTooltipItems([
        LineBarSpot(
          dataOf(tester).lineBarsData.first,
          0,
          const FlSpot(0, 60),
        ),
      ]);
      expect(items0.first!.text, contains('60.0 kg'));
    });

    testWidgets('provides touched spot indicators with dotted line', (
      tester,
    ) async {
      await tester.pumpWidget(host(seriesOf([60, 61, 62])));
      await tester.pumpAndSettle();

      final touchData = dataOf(tester).lineTouchData;
      final indicators = touchData.getTouchedSpotIndicator(
        dataOf(tester).lineBarsData.first,
        [0],
      );

      expect(indicators, hasLength(1));
      expect(indicators.first?.indicatorBelowLine.dashArray, const [4, 4]);
    });
  });
}
