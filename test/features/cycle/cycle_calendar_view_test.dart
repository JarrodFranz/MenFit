import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/cycle_calendar_view.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/cycle_day_detail_sheet.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/dotted_circle_painter.dart';

/// The wiring that moved when the month grid was extracted into
/// `core/widgets/month_calendar.dart`: the per-day visuals still reach the
/// grid, the arrows and Today button still page it, and a tap still opens
/// the day sheet. `cycle_calendar_semantics_test.dart` covers the spoken
/// half; this covers the drawn and tapped half.
void main() {
  final today = LocalDate.today();
  final menstrual = AppTheme.light()
      .extension<AppTokens>()!
      .cyclePhaseMenstrual;

  /// A period logged earlier *this* displayed month and long finished —
  /// the same anchoring as `cycle_calendar_semantics_test.dart`, so the
  /// grid always opens on a month containing logged days.
  List<CycleRecord> records() {
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

  Future<void> pumpCalendar(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(500, 1400)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: CycleCalendarView(
                records: records(),
                predictionEngine: CyclePredictionEngine(),
                confidence: CycleConfidence.low,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// A logged period day: a circle filled with the menstrual token, inside
  /// the grid (the legend draws the same swatch, hence the scoping).
  Finder loggedPeriodCells() => find.descendant(
    of: find.byType(GridView),
    matching: find.byWidgetPredicate((widget) {
      if (widget is! Container) return false;
      final decoration = widget.decoration;
      return decoration is BoxDecoration &&
          decoration.color == menstrual &&
          decoration.shape == BoxShape.circle;
    }),
  );

  Finder predictedCells() => find.descendant(
    of: find.byType(GridView),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint && widget.painter is DottedCirclePainter,
    ),
  );

  String monthLabel(DateTime month) => DateFormat('MMMM yyyy').format(month);

  testWidgets('a logged period day is drawn as a filled cell', (tester) async {
    await pumpCalendar(tester);

    expect(loggedPeriodCells(), findsWidgets);
  });

  testWidgets('the grid draws predicted period days as dotted cells', (
    tester,
  ) async {
    await pumpCalendar(tester);

    // Predictions start a cycle after the logged period, so they are not
    // guaranteed to fall inside the month the calendar opens on — but they
    // repeat every ~28 days for six months, and a month grid spans at
    // least 35 days, so the next month's grid must contain one. Paging
    // forward is also the assertion that forward navigation is uncapped
    // here (unlike the wellbeing calendar): looking ahead is the point.
    await tester.tap(find.byTooltip('Next Month'));
    await tester.pumpAndSettle();

    expect(predictedCells(), findsWidgets);
  });

  testWidgets('the arrows and the Today button page the month', (tester) async {
    await pumpCalendar(tester);

    final thisMonth = DateTime(today.year, today.month);
    expect(find.text(monthLabel(thisMonth)), findsOneWidget);
    expect(find.text('Today'), findsNothing);

    await tester.tap(find.byTooltip('Next Month'));
    await tester.pumpAndSettle();
    expect(
      find.text(monthLabel(DateTime(today.year, today.month + 1))),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Previous Month'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Previous Month'));
    await tester.pumpAndSettle();
    expect(
      find.text(monthLabel(DateTime(today.year, today.month - 1))),
      findsOneWidget,
    );

    // Off the current month, the jump-back affordance appears and works.
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.text(monthLabel(thisMonth)), findsOneWidget);
    expect(find.text('Today'), findsNothing);
  });

  testWidgets('tapping a day opens the cycle day detail sheet', (tester) async {
    await pumpCalendar(tester);

    // Day 3 is inside the logged period, so the sheet opens on a day with
    // a status to show. `.first` guards against a trailing cell of the
    // next month carrying the same numeral.
    await tester.tap(find.text('3').first);
    await tester.pumpAndSettle();

    expect(find.byType(CycleDayDetailSheet), findsOneWidget);
    expect(find.textContaining('Logged Period Day'), findsOneWidget);
  });

  testWidgets(
    'the visual legend shows non-color indicators and labels for all phases',
    (tester) async {
      await pumpCalendar(tester);

      expect(find.text('Logged period'), findsOneWidget);
      expect(find.text('Predicted period'), findsOneWidget);
      expect(find.text('Follicular'), findsOneWidget);
      expect(find.text('Ovulation'), findsOneWidget);
      expect(find.text('Luteal'), findsOneWidget);
    },
  );

  testWidgets(
    'the grid renders non-color shape markers for cycle phases',
    (tester) async {
      await pumpCalendar(tester);

      // Verify that follicular, ovulation, or luteal shape markers are rendered
      // within grid cells.
      final follicularMarkers = find.byKey(
        const Key('cycleCalendarFollicularMarker'),
      );
      final ovulationMarkers = find.byKey(
        const Key('cycleCalendarOvulationMarker'),
      );
      final ovulatoryWindowMarkers = find.byKey(
        const Key('cycleCalendarOvulatoryWindowMarker'),
      );
      final lutealMarkers = find.byKey(const Key('cycleCalendarLutealMarker'));

      // At least one phase marker should be present in the month's days.
      expect(
        follicularMarkers.evaluate().isNotEmpty ||
            ovulationMarkers.evaluate().isNotEmpty ||
            ovulatoryWindowMarkers.evaluate().isNotEmpty ||
            lutealMarkers.evaluate().isNotEmpty,
        isTrue,
      );
    },
  );
}
