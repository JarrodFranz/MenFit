import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/widgets/month_calendar.dart';

/// The month grid both the cycle and wellbeing calendars are built on.
///
/// Everything asserted here is behaviour the cycle calendar had before the
/// grid was extracted into `core/widgets/`, plus the forward cap the
/// wellbeing calendar needs.
void main() {
  // August 2026 starts on a Saturday and has 31 days: 5 leading blanks + 31
  // = 36, which rounds up to a six-row, 42-cell grid. February 2026 starts
  // on a Sunday with 28 days (6 + 28 = 34) and fits in five rows.
  final august = DateTime(2026, 8);
  final february = DateTime(2026, 2);
  final today = LocalDate(2026, 8, 12);

  /// Records what the grid asked the caller to draw, so the test can assert
  /// on the slots rather than on pixels.
  late List<MonthCalendarDay> builtDays;
  late List<DateTime> monthChanges;
  late List<LocalDate> taps;

  setUp(() {
    builtDays = [];
    monthChanges = [];
    taps = [];
  });

  Widget host({
    DateTime? month,
    DateTime? latestMonth,
    String? Function(MonthCalendarDay day)? semanticsLabel,
  }) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: MonthCalendar(
            month: month ?? august,
            today: today,
            latestMonth: latestMonth,
            onMonthChanged: monthChanges.add,
            onDayTap: taps.add,
            cellBuilder: (day) {
              builtDays.add(day);
              return MonthCalendarCell(
                semanticsLabel: semanticsLabel?.call(day),
                child: Center(child: Text('${day.date.day}')),
              );
            },
          ),
        ),
      ),
    );
  }

  group('monthCalendarGridRange', () {
    test('spans the CELLS the grid draws, not the calendar month', () {
      // August 2026: 5 leading July cells, 6 trailing September ones.
      final range = monthCalendarGridRange(august);
      expect(range.first, LocalDate(2026, 7, 27));
      expect(range.last, LocalDate(2026, 9, 6));
    });

    test(
      'a five-row month still reports its own leading and trailing days',
      () {
        // February 2026: 6 leading January cells, 1 trailing March one.
        final range = monthCalendarGridRange(february);
        expect(range.first, LocalDate(2026, 1, 26));
        expect(range.last, LocalDate(2026, 3, 1));
      },
    );

    test('the range covers exactly the cells the grid builds', () async {
      // The guarantee callers depend on: a per-day query over this range
      // can answer every cell the builder is about to ask about.
      for (final month in [august, february, DateTime(2026, 3)]) {
        final range = monthCalendarGridRange(month);
        final metrics = monthCalendarGridMetrics(month);
        expect(
          range.first.difference(range.last) + 1,
          metrics.totalCells,
          reason: 'the span must have exactly one day per cell',
        );
      }
    });
  });

  testWidgets('a month needing six rows lays out 42 cells', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(builtDays, hasLength(42));
    expect(find.text('August 2026'), findsOneWidget);
  });

  testWidgets('a month that fits in five rows lays out 35', (tester) async {
    await tester.pumpWidget(host(month: february));
    await tester.pumpAndSettle();

    expect(builtDays, hasLength(35));
  });

  testWidgets('leading and trailing cells carry the neighbouring months', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    final leading = builtDays.take(5).toList();
    expect(leading.every((d) => !d.isCurrentMonth), isTrue);
    expect(leading.first.date, LocalDate(2026, 7, 27));
    expect(leading.last.date, LocalDate(2026, 7, 31));

    expect(builtDays[5].date, LocalDate(2026, 8, 1));
    expect(builtDays[5].isCurrentMonth, isTrue);

    // 5 leading + 31 days = 36 slots used, so the remaining 6 spill into
    // September.
    expect(builtDays[36].date, LocalDate(2026, 9, 1));
    expect(builtDays[36].isCurrentMonth, isFalse);
    expect(builtDays.last.date, LocalDate(2026, 9, 6));
  });

  testWidgets('exactly one cell is flagged as today, and only in its month', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(builtDays.where((d) => d.isToday).map((d) => d.date), [today]);

    builtDays.clear();
    await tester.pumpWidget(host(month: february));
    await tester.pumpAndSettle();
    expect(builtDays.where((d) => d.isToday), isEmpty);
  });

  testWidgets('the arrows report the adjacent month', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Next Month'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Previous Month'));
    await tester.pumpAndSettle();

    expect(monthChanges, [DateTime(2026, 9), DateTime(2026, 7)]);
  });

  testWidgets('a horizontal swipe pages the month', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.fling(find.byType(GridView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();

    expect(monthChanges, [DateTime(2026, 9)]);
  });

  testWidgets('latestMonth disables forward navigation at the cap', (
    tester,
  ) async {
    await tester.pumpWidget(host(latestMonth: august));
    await tester.pumpAndSettle();

    final next = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right),
    );
    expect(next.onPressed, isNull);

    // The swipe has to be blocked too, not just the button — otherwise the
    // cap is decorative on a phone.
    await tester.fling(find.byType(GridView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(monthChanges, isEmpty);

    // Backwards still works.
    await tester.tap(find.byTooltip('Previous Month'));
    await tester.pumpAndSettle();
    expect(monthChanges, [DateTime(2026, 7)]);
  });

  testWidgets('latestMonth leaves earlier months freely navigable forward', (
    tester,
  ) async {
    await tester.pumpWidget(host(month: february, latestMonth: august));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Next Month'));
    await tester.pumpAndSettle();
    expect(monthChanges, [DateTime(2026, 3)]);
  });

  testWidgets('the Today button shows only off the current month', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsNothing);

    await tester.pumpWidget(host(month: february));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(monthChanges, [DateTime(2026, 8)]);
  });

  testWidgets('tapping a cell reports that day', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(find.text('12'));
    await tester.pumpAndSettle();

    expect(taps, [LocalDate(2026, 8, 12)]);
  });

  testWidgets('a labelled cell announces the label and stays activatable', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        semanticsLabel: (day) =>
            day.date == LocalDate(2026, 8, 12) ? 'Something logged' : null,
      ),
    );
    await tester.pumpAndSettle();

    final labelled = find.bySemanticsLabel('Something logged');
    expect(labelled, findsOneWidget);
    expect(
      tester.getSemantics(labelled),
      isSemantics(hasTapAction: true, isButton: true),
    );

    // The description replaces the bare number rather than being read out
    // alongside it...
    expect(find.bySemanticsLabel('12'), findsNothing);
    // ...while an unlabelled day keeps announcing its number.
    expect(find.bySemanticsLabel('13'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('a labelled cell is still tappable through its wrapper', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(semanticsLabel: (day) => 'Day ${day.date.day}'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('12'));
    await tester.pumpAndSettle();

    expect(taps, [LocalDate(2026, 8, 12)]);
  });
}
