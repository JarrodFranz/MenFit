import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/progress/domain/weekly_summary.dart';
import 'package:menfit_app/features/progress/presentation/widgets/weekly_distance_chart.dart';

/// The bar chart's Enhanced Semantics description is built from the series,
/// not from a template with a number dropped into it — these tests change
/// the data and expect the sentence to change with it.
void main() {
  WeeklySummary week(int index, double km) => WeeklySummary(
    weekStart: LocalDate(2026, 3, 2).addDays(index * 7),
    distanceMeters: km * 1000,
    movingTime: Duration(minutes: (km * 6).round()),
    activityCount: km > 0 ? 1 : 0,
  );

  String describe(List<double> kms) {
    final summaries = [
      for (var i = 0; i < kms.length; i++) week(i, kms[i]),
    ];
    return weeklyDistanceDescription(
      summaries: summaries,
      displayValues: kms,
      unitWord: 'kilometres',
    );
  }

  test('counts the bars and names the highest week by date and value', () {
    final label = describe([4, 8.2, 6]);

    expect(label, contains('3 bars, one per week'));
    expect(label, contains('Highest week of 9 Mar, 8.2 kilometres'));
  });

  test('says an empty week is empty rather than reading "0.0"', () {
    final label = describe([4, 8.2, 0]);

    expect(label, contains('Lowest week of 16 Mar, no distance logged'));
    expect(label, contains('1 week with nothing logged'));
  });

  test('quotes the current week last, as the chart highlights it', () {
    expect(describe([4, 8.2, 6]), contains('This week 6.0 kilometres'));
  });

  test('spells the unit out — an abbreviation is not a spoken word', () {
    final label = weeklyDistanceDescription(
      summaries: [week(0, 3)],
      displayValues: const [1.9],
      unitWord: 'miles',
    );

    expect(label, contains('1.9 miles'));
    expect(label, isNot(contains(' mi,')));
  });

  test('describes the series, not a placeholder', () {
    expect(describe([4, 8.2, 6]), isNot(equals(describe([1, 2, 3]))));
  });

  group('the chart attaches it only when the preference is on', () {
    Widget host({required bool enhancedSemantics}) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: WeeklyDistanceChart(
          summaries: [week(0, 4), week(1, 8.2), week(2, 6)],
          unitSystem: UnitSystem.metric,
          enhancedSemantics: enhancedSemantics,
        ),
      ),
    );

    testWidgets('off: the short label is unchanged', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(enhancedSemantics: false));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(RegExp('^Weekly distance chart, last 3 weeks')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp('bars, one per week')), findsNothing);

      handle.dispose();
    });

    testWidgets('on: the bars are described in words', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(enhancedSemantics: true));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(RegExp('3 bars, one per week')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('Highest week of 9 Mar, 8.2 kilometres')),
        findsOneWidget,
      );

      handle.dispose();
    });
  });
}
