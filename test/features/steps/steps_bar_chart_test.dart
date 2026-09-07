import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/steps/presentation/steps_chart_semantics.dart';
import 'package:menfit_app/features/steps/presentation/steps_copy.dart';
import 'package:menfit_app/features/steps/presentation/steps_stats.dart';
import 'package:menfit_app/features/steps/presentation/widgets/steps_bar_chart.dart';

void main() {
  final monday = LocalDate(2026, 8, 31);
  final today = DateTime(2026, 9, 6);

  Future<void> pumpChart(
    WidgetTester tester,
    List<StepsDayView> days, {
    int target = 7500,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: StepsBarChart(days: days, target: target, today: today),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a day with no row gets no bar, and keeps its slot', (
    tester,
  ) async {
    final days = buildStepsDays(
      start: monday,
      end: monday.addDays(6),
      stepsByDay: {monday: 9000, monday.addDays(2): 3000},
    );

    await pumpChart(tester, days);

    final chart = tester.widget<BarChart>(find.byType(BarChart));
    final groups = chart.data.barGroups;

    // Seven slots, so the week still reads as seven columns...
    expect(groups, hasLength(7));
    // ...but only the two recorded days carry a rod. A zero-height rod
    // would be a drawn claim of "zero steps"; there is none.
    expect(groups[0].barRods, hasLength(1));
    expect(groups[1].barRods, isEmpty);
    expect(groups[2].barRods, hasLength(1));
    for (final index in [3, 4, 5, 6]) {
      expect(groups[index].barRods, isEmpty, reason: 'slot $index');
    }
    expect(groups[0].barRods.single.toY, 9000);
  });

  testWidgets('a recorded zero is a real bar, not a gap', (tester) async {
    final days = buildStepsDays(
      start: monday,
      end: monday.addDays(1),
      stepsByDay: {monday: 0, monday.addDays(1): 5000},
    );

    await pumpChart(tester, days);

    final groups = tester
        .widget<BarChart>(find.byType(BarChart))
        .data
        .barGroups;
    expect(groups[0].barRods, hasLength(1));
    expect(groups[0].barRods.single.toY, 0);
  });

  testWidgets('the target line is always inside the plotted range', (
    tester,
  ) async {
    // A very quiet week: without the target being folded into the axis
    // maximum, the 7,500 line would sit above the top of the chart and
    // silently disappear.
    final days = buildStepsDays(
      start: monday,
      end: monday.addDays(2),
      stepsByDay: {monday: 400},
    );

    await pumpChart(tester, days);

    final data = tester.widget<BarChart>(find.byType(BarChart)).data;
    expect(data.maxY, greaterThanOrEqualTo(7500));
    expect(data.extraLinesData.horizontalLines.single.y, 7500);
  });

  testWidgets('names how many days have no recorded count', (tester) async {
    final days = buildStepsDays(
      start: monday,
      end: monday.addDays(6),
      stepsByDay: {monday: 9000},
    );

    await pumpChart(tester, days);

    expect(find.text(stepsMissingDaysNote(6)), findsOneWidget);
  });

  testWidgets('an entirely unrecorded range shows the empty panel', (
    tester,
  ) async {
    final days = buildStepsDays(
      start: monday,
      end: monday.addDays(6),
      stepsByDay: const {},
    );

    await pumpChart(tester, days);

    expect(find.byType(BarChart), findsNothing);
    expect(find.text(stepsRangeEmptyTitle), findsOneWidget);
    expect(find.text(stepsRangeEmptyBody), findsOneWidget);
  });

  group('stepsChartDescription', () {
    test('describes the real series, gaps included', () {
      final days = buildStepsDays(
        start: monday,
        end: monday.addDays(6),
        stepsByDay: {
          monday: 9000,
          monday.addDays(1): 2000,
          monday.addDays(3): 12000,
        },
      );

      final description = stepsChartDescription(
        days: days,
        target: 7500,
        numberFormat: NumberFormat.decimalPattern(),
      );

      expect(description, contains('7 days, 3 with a recorded count'));
      expect(description, contains('Highest Thursday 3 September, 12,000'));
      expect(description, contains('Lowest Tuesday 1 September, 2,000'));
      expect(description, contains('2 of 3 recorded days reached 7,500 steps'));
      expect(description, contains('4 days have no recorded count'));
    });

    test('says so rather than inventing a shape when nothing is recorded', () {
      final days = buildStepsDays(
        start: monday,
        end: monday.addDays(2),
        stepsByDay: const {},
      );

      expect(
        stepsChartDescription(
          days: days,
          target: 7500,
          numberFormat: NumberFormat.decimalPattern(),
        ),
        contains('no recorded step counts in this range'),
      );
    });
  });
}
