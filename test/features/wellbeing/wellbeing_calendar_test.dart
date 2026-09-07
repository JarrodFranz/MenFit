import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/core/widgets/month_calendar.dart';
import 'package:menfit_app/features/streaks/data/drift_recovery_repository.dart';
import 'package:menfit_app/features/wellbeing/data/drift_wellbeing_repository.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/wellbeing_watch_providers.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_calendar.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_calendar_cells.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_day_sheet.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_glyphs.dart';

/// Tears the tree down and pumps one frame so live Drift stream timers get
/// a chance to fire and cancel, instead of being reported as pending.
Future<void> flushDriftTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

/// The Wellbeing tab's month grid: which days carry which glyph, that the
/// glyphs are named, that navigation stops at the current month, and that a
/// day opens its detail sheet.
void main() {
  final today = LocalDate.today();
  final firstOfMonth = LocalDate(today.year, today.month, 1);
  final previousMonth = DateTime(today.year, today.month - 1);

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Finder markerIn(IconData glyph) => find.descendant(
    of: find.byType(WellbeingDayCell),
    matching: find.byIcon(glyph),
  );

  Future<db.AppDatabase> pumpCalendar(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(500, 1100)
      ..devicePixelRatio = 1;

    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    addTearDown(() => flushDriftTimers(tester));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(child: WellbeingCalendar()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return database;
  }

  Future<void> seedCheckin(db.AppDatabase database, LocalDate day) {
    final now = DateTime.utc(2026);
    return DriftWellbeingRepository(database).saveCheckin(
      DailyCheckin(
        id: EntityId.generate(),
        day: day,
        energy: 4,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> seedFlare(
    db.AppDatabase database,
    LocalDate day, {
    LocalDate? endDay,
  }) {
    final now = DateTime.utc(2026);
    return DriftWellbeingRepository(database).saveFlare(
      FlareEvent(
        id: EntityId.generate(),
        day: day,
        endDay: endDay,
        severity: FlareSeverity.mild,
        impact: FlareImpact.none,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  testWidgets('an empty month draws no markers but still names the glyphs', (
    tester,
  ) async {
    await pumpCalendar(tester);

    expect(markerIn(checkinGlyph), findsNothing);
    expect(markerIn(flareGlyph), findsNothing);
    expect(markerIn(recoveryGlyph), findsNothing);

    // The legend is what turns three symbols into three facts.
    expect(find.text('Check-in'), findsOneWidget);
    expect(find.text('Flare-up'), findsOneWidget);
    expect(find.text('Recovery day'), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('each record type draws its own distinct glyph', (tester) async {
    final database = await pumpCalendar(tester);

    await seedCheckin(database, firstOfMonth);
    await seedFlare(database, firstOfMonth.addDays(1));
    await DriftRecoveryRepository(database).markRecoveryDay(firstOfMonth);
    await tester.pumpAndSettle();

    expect(markerIn(checkinGlyph), findsOneWidget);
    expect(markerIn(flareGlyph), findsOneWidget);
    expect(markerIn(recoveryGlyph), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('a multi-day flare marks every day it covers', (tester) async {
    final database = await pumpCalendar(tester);

    await seedFlare(
      database,
      firstOfMonth,
      endDay: firstOfMonth.addDays(2),
    );
    await tester.pumpAndSettle();

    expect(markerIn(flareGlyph), findsNWidgets(3));

    await flushDriftTimers(tester);
  });

  testWidgets('a check-in with nothing answered is not a marked day', (
    tester,
  ) async {
    final database = await pumpCalendar(tester);

    final now = DateTime.utc(2026);
    await DriftWellbeingRepository(database).saveCheckin(
      DailyCheckin(
        id: EntityId.generate(),
        day: firstOfMonth,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await tester.pumpAndSettle();

    expect(markerIn(checkinGlyph), findsNothing);

    await flushDriftTimers(tester);
  });

  testWidgets('a record on a neighbouring-month CELL is marked, not blanked', (
    tester,
  ) async {
    final database = await pumpCalendar(tester);

    // The grid draws leading days from the previous month and trailing
    // days from the next. Those cells are real days the range query
    // covers, and the sheet they open shows their records, so blanking
    // their markers made the grid disagree with itself.
    final range = monthCalendarGridRange(
      DateTime(today.year, today.month),
    );
    await seedFlare(database, range.first);
    await seedFlare(database, range.last);
    await tester.pumpAndSettle();

    // `first` and `last` are distinct days on every possible month shape.
    expect(markerIn(flareGlyph), findsNWidgets(2));

    await flushDriftTimers(tester);
  });

  testWidgets(
    'a flare straddling the month boundary marks the trailing cells',
    (tester) async {
      final database = await pumpCalendar(tester);

      final range = monthCalendarGridRange(
        DateTime(today.year, today.month),
      );
      final lastOfMonth = LocalDate(
        today.year,
        today.month,
        DateTime(today.year, today.month + 1, 0).day,
      );
      // Runs from the last day of the displayed month into the next one.
      // The trailing cells the grid draws for those next-month days must
      // carry the flame too.
      await seedFlare(database, lastOfMonth, endDay: lastOfMonth.addDays(2));
      await tester.pumpAndSettle();

      final trailingCellsDrawn = lastOfMonth.difference(range.last);
      expect(
        markerIn(flareGlyph),
        findsNWidgets(1 + (trailingCellsDrawn < 2 ? trailingCellsDrawn : 2)),
        reason: 'every covered day the grid actually draws is marked',
      );

      await flushDriftTimers(tester);
    },
  );

  testWidgets('an out-of-month cell announces its records too', (tester) async {
    final handle = tester.ensureSemantics();
    final database = await pumpCalendar(tester);

    final range = monthCalendarGridRange(
      DateTime(today.year, today.month),
    );
    await seedCheckin(database, range.first);
    await tester.pumpAndSettle();

    // The spoken label never depended on which month a cell belongs to;
    // the marker gate used to, which meant a leading/trailing day could
    // announce "nothing logged" over a day that had a check-in.
    expect(
      find.bySemanticsLabel(RegExp('check-in logged')),
      findsOneWidget,
    );

    handle.dispose();
    await flushDriftTimers(tester);
  });

  testWidgets('a failed read says so instead of reading as an empty month', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(500, 1100)
      ..devicePixelRatio = 1;

    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    addTearDown(() => flushDriftTimers(tester));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          // Two parameters, not three: the generated family passes its
          // args as a single `(LocalDate, LocalDate)` record.
          checkinsForRangeProvider.overrideWith(
            (ref, args) => Stream<List<DailyCheckin>>.error(
              const StorageException(message: 'Failed to watch check-ins'),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(child: WellbeingCalendar()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // "Nothing logged" is a claim about her records; the app must not make
    // it about data it never managed to read.
    expect(find.text("Couldn't load this month."), findsOneWidget);
    // The dates are still correct and still tappable — only the markers
    // are unknown, so the grid stays.
    expect(find.byType(WellbeingDayCell), findsWidgets);

    await flushDriftTimers(tester);
  });

  testWidgets('forward navigation stops at the current month', (tester) async {
    await pumpCalendar(tester);

    final next = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right),
    );
    expect(
      next.onPressed,
      isNull,
      reason: 'nothing can be logged on a month that has not happened',
    );

    await flushDriftTimers(tester);
  });

  testWidgets("paging back shows the previous month's records, and returns", (
    tester,
  ) async {
    final database = await pumpCalendar(tester);

    await seedCheckin(
      database,
      LocalDate(previousMonth.year, previousMonth.month, 1),
    );
    await tester.pumpAndSettle();
    expect(markerIn(checkinGlyph), findsNothing);

    await tester.tap(find.byTooltip('Previous Month'));
    await tester.pumpAndSettle();
    expect(markerIn(checkinGlyph), findsOneWidget);

    // Off the current month, the jump-back affordance appears.
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(markerIn(checkinGlyph), findsNothing);

    await flushDriftTimers(tester);
  });

  testWidgets("tapping a day opens that day's sheet", (tester) async {
    await pumpCalendar(tester);

    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();

    expect(find.byType(WellbeingDaySheet), findsOneWidget);
    expect(find.text('Check-in'), findsWidgets);

    await flushDriftTimers(tester);
  });

  testWidgets('a logged day announces what is on it', (tester) async {
    final handle = tester.ensureSemantics();
    final database = await pumpCalendar(tester);

    await seedFlare(database, firstOfMonth);
    await DriftRecoveryRepository(database).markRecoveryDay(firstOfMonth);
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp('flare-up, recovery day')),
      findsOneWidget,
    );

    handle.dispose();
    await flushDriftTimers(tester);
  });

  testWidgets('the grid and its legend survive 320dp at 150% text', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 900)
      ..devicePixelRatio = 1;

    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    addTearDown(() => flushDriftTimers(tester));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) => MediaQuery(
              // copyWith, not a bare MediaQueryData: replacing the whole
              // thing would zero the view size and every layout with it.
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: const Scaffold(
                body: SingleChildScrollView(child: WellbeingCalendar()),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await seedCheckin(database, firstOfMonth);
    await seedFlare(database, firstOfMonth);
    await DriftRecoveryRepository(database).markRecoveryDay(firstOfMonth);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // All three glyphs stay drawn on the one day at the tightest width —
    // the cell scales down rather than dropping a marker.
    expect(markerIn(checkinGlyph), findsOneWidget);
    expect(markerIn(flareGlyph), findsOneWidget);
    expect(markerIn(recoveryGlyph), findsOneWidget);

    await flushDriftTimers(tester);
  });
}
