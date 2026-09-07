import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
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
    Map<LocalDate, CyclePhase> phaseByDay = const {},
  }) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: WeightTrendChart(
          series: series,
          unitSystem: unitSystem,
          seriesMode: mode,
          phaseByDay: phaseByDay,
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

  group('cycle overlay', () {
    testWidgets('draws no bands without phase data', (tester) async {
      await tester.pumpWidget(host(seriesOf([60, 61, 60, 62, 60, 61, 60])));
      await tester.pumpAndSettle();

      expect(
        dataOf(tester).rangeAnnotations.verticalRangeAnnotations,
        isEmpty,
      );
    });

    testWidgets('bands a contiguous run of menstrual days as one', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          seriesOf([60, 61, 60, 62, 60, 61, 60]),
          phaseByDay: {
            day1: CyclePhase.menstrual,
            day1.addDays(1): CyclePhase.menstrual,
            day1.addDays(2): CyclePhase.menstrual,
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(
        dataOf(tester).rangeAnnotations.verticalRangeAnnotations,
        hasLength(1),
      );
    });

    testWidgets('starts a new band when the phase changes', (tester) async {
      await tester.pumpWidget(
        host(
          seriesOf([60, 61, 60, 62, 60, 61, 60]),
          phaseByDay: {
            day1: CyclePhase.menstrual,
            day1.addDays(1): CyclePhase.menstrual,
            day1.addDays(2): CyclePhase.luteal,
            day1.addDays(3): CyclePhase.luteal,
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(
        dataOf(tester).rangeAnnotations.verticalRangeAnnotations,
        hasLength(2),
      );
    });

    testWidgets('leaves the follicular and ovulatory phases unbanded', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          seriesOf([60, 61, 60, 62, 60, 61, 60]),
          phaseByDay: {
            day1: CyclePhase.follicular,
            day1.addDays(1): CyclePhase.follicular,
            day1.addDays(2): CyclePhase.ovulatory,
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(
        dataOf(tester).rangeAnnotations.verticalRangeAnnotations,
        isEmpty,
        reason: 'banding all four phases would tile the whole background',
      );
    });

    testWidgets('bandedCyclePhases is exactly menstrual and luteal', (
      tester,
    ) async {
      expect(bandedCyclePhases, {CyclePhase.menstrual, CyclePhase.luteal});
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

  testWidgets('the legend names both bands', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: WeightPhaseLegend()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Menstrual'), findsOneWidget);
    expect(find.text('Luteal'), findsOneWidget);
    expect(find.text('Follicular'), findsNothing);
  });

  group('interactive touch & cycle-aware tooltip', () {
    testWidgets('tooltip item appends cycle phase for banded days', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          seriesOf([60, 61, 62]),
          phaseByDay: {
            day1: CyclePhase.menstrual,
            day1.addDays(1): CyclePhase.luteal,
            day1.addDays(2): CyclePhase.follicular,
          },
        ),
      );
      await tester.pumpAndSettle();

      final touchData = dataOf(tester).lineTouchData;
      final tooltipData = touchData.touchTooltipData;

      // Spot 0: day1 (menstrual)
      final items0 = tooltipData.getTooltipItems([
        LineBarSpot(
          dataOf(tester).lineBarsData.first,
          0,
          const FlSpot(0, 60),
        ),
      ]);
      expect(items0.first!.text, contains('60.0 kg'));
      expect(
        items0.first!.children!.any(
          (s) => s.toPlainText().contains('Menstrual phase'),
        ),
        isTrue,
      );

      // Spot 1: day1 + 1 (luteal)
      final items1 = tooltipData.getTooltipItems([
        LineBarSpot(
          dataOf(tester).lineBarsData.first,
          0,
          const FlSpot(1, 61),
        ),
      ]);
      expect(
        items1.first!.children!.any(
          (s) => s.toPlainText().contains('Luteal phase'),
        ),
        isTrue,
      );

      // Spot 2: day1 + 2 (follicular - unbanded)
      final items2 = tooltipData.getTooltipItems([
        LineBarSpot(
          dataOf(tester).lineBarsData.first,
          0,
          const FlSpot(2, 62),
        ),
      ]);
      expect(items2.first!.children, isEmpty);
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
