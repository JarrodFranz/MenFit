import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/wellbeing/data/drift_wellbeing_repository.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/checkin_sheet.dart';
import 'package:menfit_app/features/wellbeing/presentation/flare_dialog.dart';
import 'package:menfit_app/features/wellbeing/presentation/wellbeing_screen.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/history_tiles.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tears the tree down and pumps one frame so live Drift stream timers get
/// a chance to fire and cancel, instead of being reported as pending.
///
/// Top-level, not a local closure inside [main]: it is referenced from
/// `pumpApp`'s `addTearDown`, and Dart does not hoist local functions.
Future<void> flushDriftTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

/// The Wellbeing tab's multi-day surfaces: logging a flare-up straight from
/// the tab, a range flare reading as a range in the history list, and
/// marking a whole range of recovery days from the app-bar action.
void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Future<db.AppDatabase> pumpApp(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(500, 1100)
      ..devicePixelRatio = 1;

    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();
    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    // Registered after `database.close` so it runs before it (teardowns are
    // LIFO). Each test body ALSO calls this at the end: the body call is
    // what satisfies flutter_test's end-of-body "no pending timers"
    // invariant (addTearDown callbacks run after that check), while this
    // registration is what still tears the tree down when an expectation
    // FAILS and the body call is skipped - without it one failing test
    // leaves live Drift stream timers behind and wedges the whole file
    // (see `routes_flow_test.dart`). Pumping an already-detached tree again
    // is a no-op, so running both is safe.
    addTearDown(() => flushDriftTimers(tester));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(database),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    return database;
  }

  /// Lets a UI-triggered Drift write complete outside the fake-async zone
  /// (the documented CL-10-family wedge - central `testing-pitfalls.md`),
  /// then settles the resulting UI.
  Future<void> settleRealAsync(WidgetTester tester) async {
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openWellbeingTab(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Recovery'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WellbeingScreen), findsOneWidget);
  }

  /// Drives a Material date picker to [day] via its text-entry mode, in the
  /// US default test locale's MM/DD/YYYY format. [openIcon] selects which
  /// date field to open when a dialog shows more than one.
  Future<void> pickDate(
    WidgetTester tester,
    Finder openIcon,
    LocalDate day,
  ) async {
    await tester.tap(openIcon);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to input'));
    await tester.pumpAndSettle();
    final formatted =
        '${day.month.toString().padLeft(2, '0')}/'
        '${day.day.toString().padLeft(2, '0')}/'
        '${day.year}';
    // Scoped to the picker: the dialog underneath still has its own text
    // fields, and an unscoped `.first` types the date into one of those.
    await tester.enterText(
      find.descendant(
        of: find.byType(DatePickerDialog),
        matching: find.byType(TextField),
      ),
      formatted,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  test('formatFlareSpan reads a multi-day flare as a range', () {
    FlareEvent flare(LocalDate day, LocalDate? endDay) => FlareEvent(
      id: 'f',
      day: day,
      endDay: endDay,
      severity: FlareSeverity.mild,
      impact: FlareImpact.none,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    expect(formatFlareSpan(flare(LocalDate(2026, 3, 3), null)), '3 Mar');
    expect(
      formatFlareSpan(flare(LocalDate(2026, 3, 3), LocalDate(2026, 3, 3))),
      '3 Mar',
    );
    expect(
      formatFlareSpan(flare(LocalDate(2026, 3, 3), LocalDate(2026, 3, 7))),
      '3–7 Mar',
    );
    expect(
      formatFlareSpan(flare(LocalDate(2026, 2, 28), LocalDate(2026, 3, 3))),
      '28 Feb – 3 Mar',
    );
  });

  testWidgets('the Wellbeing tab logs a check-in from its own button', (
    tester,
  ) async {
    // Before this button existed, `CheckinSheet` was reachable only from
    // the Home tab's auto-hiding card or by tapping an ALREADY-logged
    // entry in the history - so the tab named after wellbeing could not
    // record its own primary daily action.
    await pumpApp(tester);
    await openWellbeingTab(tester);

    expect(find.text('Log today’s check-in'), findsOneWidget);
    await tester.tap(find.byKey(const Key('wellbeingLogCheckinButton')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckinSheet), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('the app-bar action opens the same check-in sheet', (
    tester,
  ) async {
    // The second door, for someone already scrolled down the history.
    await pumpApp(tester);
    await openWellbeingTab(tester);

    await tester.tap(find.byKey(const Key('wellbeingLogCheckinAction')));
    await tester.pumpAndSettle();
    expect(find.byType(CheckinSheet), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets(
    'the check-in button offers to revisit once today is already logged',
    (tester) async {
      final database = await pumpApp(tester);
      final repository = DriftWellbeingRepository(database);
      await repository.saveCheckin(
        DailyCheckin(
          id: EntityId.generate(),
          day: LocalDate.today(),
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
          energy: 4,
        ),
      );
      await settleRealAsync(tester);
      await openWellbeingTab(tester);

      // Never "you have not logged yet" - the button reflects their state
      // rather than asserting a shortfall.
      expect(find.text('Revisit today’s check-in'), findsOneWidget);
      expect(find.text('Log today’s check-in'), findsNothing);

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    "the Wellbeing tab's floating action button logs a flare-up from that "
    'tab, with the single-day / date-range choice available',
    (tester) async {
      await pumpApp(tester);
      await openWellbeingTab(tester);

      await tester.tap(find.text('Log a flare-up'));
      await tester.pumpAndSettle();

      expect(find.byType(FlareDialog), findsOneWidget);
      expect(find.text('Single day'), findsOneWidget);
      expect(find.text('Date range'), findsOneWidget);
      // The recovery tick box sits below the impact options, unticked for a
      // day that isn't already a recovery day.
      final checkbox = tester.widget<CheckboxListTile>(
        find.byType(CheckboxListTile),
      );
      expect(checkbox.value, isFalse);

      await flushDriftTimers(tester);
    },
  );

  testWidgets('a range flare renders as a range in the history list', (
    tester,
  ) async {
    final database = await pumpApp(tester);
    final today = LocalDate.today();
    final start = today.addDays(-2);
    final now = DateTime.now().toUtc();

    await DriftWellbeingRepository(database).saveFlare(
      FlareEvent(
        id: EntityId.generate(),
        day: start,
        endDay: today,
        severity: FlareSeverity.moderate,
        impact: FlareImpact.reducedTraining,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await tester.pumpAndSettle();
    await openWellbeingTab(tester);

    final titleFinder = find.textContaining('· Flare-up');
    expect(titleFinder, findsOneWidget);
    final title = tester.widget<Text>(titleFinder).data!;

    expect(
      title,
      contains('–'),
      reason: 'a multi-day flare must read as a range, not one day',
    );
    final startOnly = DateFormat(
      'd MMM',
    ).format(DateTime(start.year, start.month, start.day));
    expect(
      title,
      isNot(equals('$startOnly · Flare-up')),
      reason: 'the row must not show only the first day of the range',
    );

    await flushDriftTimers(tester);
  });

  testWidgets(
    'the recovery dialog marks a whole range of days in one action',
    (tester) async {
      final database = await pumpApp(tester);
      final today = LocalDate.today();
      await openWellbeingTab(tester);

      await tester.tap(find.byTooltip('Mark recovery days'));
      await tester.pumpAndSettle();
      expect(find.text('Mark recovery days'), findsWidgets);

      // Switch to a range: the last day defaults to today, so only the
      // first day needs picking.
      await tester.tap(find.text('Date range'));
      await tester.pumpAndSettle();
      expect(find.text('First day'), findsOneWidget);
      expect(find.text('Last day'), findsOneWidget);

      await pickDate(
        tester,
        find.byIcon(Icons.edit_calendar_outlined).first,
        today.addDays(-2),
      );

      final markButton = find.widgetWithText(
        FilledButton,
        'Mark recovery days',
      );
      await tester.ensureVisible(markButton);
      await tester.tap(markButton);
      await settleRealAsync(tester);

      final rows = await database.select(database.recoveryDays).get();
      expect(
        rows.map((row) => row.day).toSet(),
        {
          today.addDays(-2).toIso(),
          today.addDays(-1).toIso(),
          today.toIso(),
        },
      );

      await flushDriftTimers(tester);
    },
  );
}
