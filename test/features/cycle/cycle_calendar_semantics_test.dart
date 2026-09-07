import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/cycle_calendar_view.dart';

/// The month grid under **Enhanced Semantics**.
///
/// The calendar's whole payload is drawn: a solid dot for a logged period,
/// a dotted ring for a predicted one, a tinted dot for the estimated phase.
/// A screen reader gets none of that, so with the preference on each cell
/// has to say it in words — and with the preference off it must go back to
/// the bare day number, because a 40-word announcement on every one of 42
/// cells is its own accessibility problem.
///
/// Dates are anchored to today so the logged period is always inside the
/// month the calendar opens on, rather than depending on when the suite
/// runs.
void main() {
  final today = LocalDate.today();

  /// A period logged earlier *this* displayed month, and long finished, so
  /// the grid shows logged days, estimated-phase days and (further out)
  /// predicted days together.
  List<CycleRecord> recordsInThisMonth() {
    final start = LocalDate(today.year, today.month, 2);
    return [
      CycleRecord(
        id: 'test-cycle',
        periodStart: start,
        periodEnd: start.addDays(4),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    ];
  }

  Widget host({required bool enhancedSemantics}) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: SingleChildScrollView(
        child: CycleCalendarView(
          records: recordsInThisMonth(),
          predictionEngine: CyclePredictionEngine(),
          confidence: CycleConfidence.low,
          enhancedSemantics: enhancedSemantics,
        ),
      ),
    ),
  );

  testWidgets('off: days announce as the bare number they always did', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(enhancedSemantics: false));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('Period logged')), findsNothing);
    expect(find.bySemanticsLabel(RegExp('Estimated')), findsNothing);
    expect(find.bySemanticsLabel('2'), findsWidgets);

    handle.dispose();
  });

  testWidgets('on: a logged day is announced as a fact', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(enhancedSemantics: true));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('Period logged')), findsWidgets);
    expect(
      find.bySemanticsLabel(RegExp('Period logged.*estimate')),
      findsNothing,
      reason: 'a day the user logged is not a prediction',
    );

    handle.dispose();
  });

  testWidgets('on: everything the engine inferred is named an estimate', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(enhancedSemantics: true));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp(r'Estimated \w+ phase')), findsWidgets);
    expect(
      find.bySemanticsLabel(RegExp('phase(?!.*confidence)')),
      findsNothing,
      reason: 'an estimated phase must carry the prediction confidence',
    );

    handle.dispose();
  });

  testWidgets('on: the day stays activatable by a screen reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(enhancedSemantics: true));
    await tester.pumpAndSettle();

    // `excludeSemantics` drops the InkWell's node; without the action
    // restated on the wrapper, TalkBack would read the day and be unable
    // to open it.
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('Period logged')).first),
      // `isSemantics`, not `matchesSemantics`: the latter asserts every
      // unspecified property is at its default, so it would demand an
      // empty label — the exact opposite of what this widget now does.
      isSemantics(hasTapAction: true, isButton: true),
    );

    handle.dispose();
  });

  testWidgets('on: the day number alone is no longer announced', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(enhancedSemantics: true));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('2'),
      findsNothing,
      reason:
          'the description replaces the number rather than being read out '
          'alongside it',
    );

    handle.dispose();
  });
}
