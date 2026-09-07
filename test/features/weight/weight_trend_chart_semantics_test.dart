import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/weight/domain/weight_range.dart';
import 'package:menfit_app/features/weight/domain/weight_trend.dart';
import 'package:menfit_app/features/weight/presentation/widgets/weight_trend_chart.dart';

import 'weight_test_vocabulary.dart';

/// The weight chart under **Enhanced Semantics**.
///
/// Two things are being held at once here, and the second is the harder
/// one: the description has to carry the *shape* of the series, and it has
/// to do it without ever framing a direction — the same rule the drawn
/// chart follows with its single colour. "Lowest" and "Highest" name
/// points on an axis; "loss", "gain" and "progress" would name a verdict.
void main() {
  final day1 = LocalDate(2026, 3, 1);

  WeightLog log(int offset, double kg) => WeightLog(
    id: '$offset-$kg',
    day: day1.addDays(offset),
    weightKg: kg,
    createdAt: DateTime.utc(2026, 3, 1, 7),
    updatedAt: DateTime.utc(2026, 3, 1, 7),
  );

  WeightTrendSeries seriesOf(List<double> values) => computeWeightTrend(
    logs: [for (var i = 0; i < values.length; i++) log(i, values[i])],
  );

  Widget host(
    WeightTrendSeries series, {
    required bool enhancedSemantics,
  }) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: WeightTrendChart(
        series: series,
        unitSystem: UnitSystem.metric,
        seriesMode: WeightSeriesMode.readingsAndTrend,
        enhancedSemantics: enhancedSemantics,
      ),
    ),
  );

  /// The chart's single semantics label — the widget's own root
  /// [Semantics], which sets `excludeSemantics`, so there is exactly one
  /// node for a screen reader to read.
  String labelOf(WidgetTester tester) {
    final semantics = tester.widget<Semantics>(
      find
          .descendant(
            of: find.byType(WeightTrendChart),
            matching: find.byType(Semantics),
          )
          .first,
    );
    return semantics.properties.label!;
  }

  testWidgets('off: the short label is unchanged', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(seriesOf([60, 61, 60, 62]), enhancedSemantics: false),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp('^Weight chart, 4 readings')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('Lowest')), findsNothing);

    handle.dispose();
  });

  testWidgets('on: the label describes the series', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(seriesOf([60, 61, 60, 62]), enhancedSemantics: true),
    );
    await tester.pumpAndSettle();

    final label = labelOf(tester);
    expect(label, contains('4 readings'));
    expect(label, contains('from 1 Mar to 4 Mar'));
    expect(label, contains('First 60.0 kg on 1 Mar'));
    expect(label, contains('Latest 62.0 kg on 4 Mar'));
    expect(label, contains('Lowest 60.0 kg on 1 Mar'));
    expect(label, contains('Highest 62.0 kg on 4 Mar'));

    handle.dispose();
  });

  testWidgets('on: says when there is no trend line rather than implying one', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(seriesOf([60]), enhancedSemantics: true));
    await tester.pumpAndSettle();

    final label = labelOf(tester);
    expect(label, contains('1 reading'));
    expect(label, contains('No trend line yet'));

    handle.dispose();
  });

  testWidgets('on: carries no judgement vocabulary', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(seriesOf([62, 61, 60, 59, 58]), enhancedSemantics: true),
    );
    await tester.pumpAndSettle();

    expectNoJudgementVocabulary(
      labelOf(tester),
      source: 'WeightTrendChart enhanced semantics label',
    );

    handle.dispose();
  });
}
