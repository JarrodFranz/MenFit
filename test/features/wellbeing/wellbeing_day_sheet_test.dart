import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/streaks/data/drift_recovery_repository.dart';
import 'package:menfit_app/features/wellbeing/data/drift_wellbeing_repository.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/symptom_type.dart';
import 'package:menfit_app/features/wellbeing/presentation/checkin_sheet.dart';
import 'package:menfit_app/features/wellbeing/presentation/flare_dialog.dart';
import 'package:menfit_app/features/wellbeing/presentation/mark_recovery_day_dialog.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/history_tiles.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_day_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tears the tree down and pumps one frame so live Drift stream timers get
/// a chance to fire and cancel, instead of being reported as pending.
Future<void> flushDriftTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

/// The day detail sheet a calendar day opens: all three record types, the
/// empty states, the future-day case, and that every way out of it lands in
/// an existing editor rather than a new one.
void main() {
  final today = LocalDate.today();
  final past = today.addDays(-3);
  final future = today.addDays(3);

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  /// Pumps a host with one button that opens the sheet for [day], and taps
  /// it. Returns the database so a test can seed before or after.
  Future<db.AppDatabase> pumpHost(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(500, 1400)
      ..devicePixelRatio = 1;

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    addTearDown(() => flushDriftTimers(tester));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  for (final (label, day) in [
                    ('open-past', past),
                    ('open-today', today),
                    ('open-future', future),
                  ])
                    TextButton(
                      onPressed: () =>
                          WellbeingDaySheet.show(context, day: day),
                      child: Text(label),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return database;
  }

  /// Lets a UI-triggered Drift write complete for real, then settles.
  /// Some Drift writes triggered from widget taps never complete under
  /// pumped fake time (the documented CL-10-family wedge - central
  /// `testing-pitfalls.md`).
  Future<void> settleRealAsync(WidgetTester tester) async {
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> seedCheckin(db.AppDatabase database, LocalDate day) {
    final now = DateTime.utc(2026);
    return DriftWellbeingRepository(database).saveCheckin(
      DailyCheckin(
        id: EntityId.generate(),
        day: day,
        energy: 4,
        pain: 2,
        symptoms: const [SymptomType.cramping],
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> seedFlare(db.AppDatabase database, LocalDate day) {
    final now = DateTime.utc(2026);
    return DriftWellbeingRepository(database).saveFlare(
      FlareEvent(
        id: EntityId.generate(),
        day: day,
        severity: FlareSeverity.moderate,
        impact: FlareImpact.reducedTraining,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  testWidgets('a day with nothing on it says so in all three sections', (
    tester,
  ) async {
    await pumpHost(tester);
    await open(tester, 'open-past');

    expect(find.text('No check-in logged.'), findsOneWidget);
    expect(find.text('No flare-up logged.'), findsOneWidget);
    expect(find.text('Not marked as a recovery day.'), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('all three sections render what was logged for the day', (
    tester,
  ) async {
    final database = await pumpHost(tester);
    await seedCheckin(database, past);
    await seedFlare(database, past);
    await DriftRecoveryRepository(database).markRecoveryDay(
      past,
      note: 'Rested up',
    );
    await tester.pumpAndSettle();

    await open(tester, 'open-past');

    // Check-in: answered scores only, plus the symptoms she picked.
    expect(find.text('4 of 5'), findsOneWidget);
    expect(find.text('2 of 5'), findsOneWidget);
    expect(find.text('Muscle cramps'), findsOneWidget);
    expect(
      find.text('Sleep'),
      findsNothing,
      reason: 'a question she skipped is not shown as a gap',
    );

    // Flare-up and recovery day reuse the history list's own rows.
    expect(find.textContaining('Moderate'), findsOneWidget);
    expect(find.text('Rested up'), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('"Log check-in for this day" opens the check-in sheet on THAT '
      'day', (tester) async {
    await pumpHost(tester);
    await open(tester, 'open-past');

    await tester.tap(find.byKey(const Key('wellbeingDayLogCheckinButton')));
    await tester.pumpAndSettle();

    final sheet = tester.widget<CheckinSheet>(find.byType(CheckinSheet));
    expect(sheet.day, past);
    expect(sheet.existing, isNull);

    await flushDriftTimers(tester);
  });

  testWidgets('an already-logged day hands the same check-in back to edit', (
    tester,
  ) async {
    final database = await pumpHost(tester);
    await seedCheckin(database, past);
    await tester.pumpAndSettle();
    await open(tester, 'open-past');

    expect(find.text('Edit this check-in'), findsOneWidget);
    await tester.tap(find.byKey(const Key('wellbeingDayLogCheckinButton')));
    await tester.pumpAndSettle();

    final sheet = tester.widget<CheckinSheet>(find.byType(CheckinSheet));
    expect(sheet.day, past);
    expect(sheet.existing?.energy, 4);

    await flushDriftTimers(tester);
  });

  testWidgets('a logged flare opens the existing flare dialog for editing', (
    tester,
  ) async {
    final database = await pumpHost(tester);
    await seedFlare(database, past);
    await tester.pumpAndSettle();
    await open(tester, 'open-past');

    await tester.tap(find.byType(FlareTile));
    await tester.pumpAndSettle();

    expect(find.byType(FlareDialog), findsOneWidget);
    expect(find.text('Edit flare-up'), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets(
    'logging a flare is offered on past days and seeds the dialog with '
    'that day',
    (tester) async {
      await pumpHost(tester);

      await open(tester, 'open-past');
      final logButton = find.byKey(const Key('wellbeingDayLogFlareButton'));
      expect(logButton, findsOneWidget);

      await tester.tap(logButton);
      await tester.pumpAndSettle();

      expect(find.byType(FlareDialog), findsOneWidget);
      expect(
        find.text(
          DateFormat.yMMMd().format(
            DateTime(past.year, past.month, past.day),
          ),
        ),
        findsOneWidget,
      );

      // Close dialog & sheet.
      Navigator.of(tester.element(find.byType(FlareDialog))).pop();
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(WellbeingDaySheet))).pop();
      await tester.pumpAndSettle();

      await open(tester, 'open-today');
      expect(
        find.byKey(const Key('wellbeingDayLogFlareButton')),
        findsOneWidget,
      );

      await flushDriftTimers(tester);
    },
  );

  testWidgets('Undo still restores the day after the recovery tile unmounts', (
    tester,
  ) async {
    final database = await pumpHost(tester);
    await DriftRecoveryRepository(database).markRecoveryDay(
      past,
      note: 'Sore calves',
    );
    await tester.pumpAndSettle();
    await open(tester, 'open-past');

    await tester.tap(find.byTooltip('Remove'));
    await settleRealAsync(tester);

    // The sheet closes itself on removal. It has to: the snackbar is
    // painted in the ROOT Scaffold, underneath this bottom sheet, so
    // while the sheet is open the Undo action is covered and a tap on it
    // lands on the sheet instead (silently - `tester.tap` only warns when
    // the hit test finds a different widget).
    expect(find.byType(WellbeingDaySheet), findsNothing);
    expect(await database.select(database.recoveryDays).get(), isEmpty);

    // ...which is what makes the Undo reachable at all.
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.tap(find.widgetWithText(SnackBarAction, 'Undo'));
    await settleRealAsync(tester);

    // The tile is unmounted by this point (the whole sheet is gone), so
    // an Undo written against its `ref` throws a StateError and silently
    // restores nothing.
    expect(tester.takeException(), isNull);
    final restored = await database.select(database.recoveryDays).get();
    // `hasLength` before `single`: a regression here should report "no
    // rows" rather than a bare "Bad state: No element".
    expect(restored, hasLength(1));
    expect(restored.single.day, past.toIso());
    expect(
      restored.single.note,
      'Sore calves',
      reason: 'Undo restores the note it removed, not a bare day',
    );

    await flushDriftTimers(tester);
  });

  testWidgets('reopening the day after Undo shows the restored recovery day', (
    tester,
  ) async {
    final database = await pumpHost(tester);
    await DriftRecoveryRepository(database).markRecoveryDay(past);
    await tester.pumpAndSettle();
    await open(tester, 'open-past');

    await tester.tap(find.byTooltip('Remove'));
    await settleRealAsync(tester);
    await tester.tap(find.widgetWithText(SnackBarAction, 'Undo'));
    await settleRealAsync(tester);

    await open(tester, 'open-past');
    expect(find.byType(RecoveryTile), findsOneWidget);
    expect(
      find.byKey(const Key('wellbeingDayMarkRecoveryButton')),
      findsNothing,
    );

    await flushDriftTimers(tester);
  });

  testWidgets('an unmarked past day offers to be marked, seeded with THAT '
      'day', (tester) async {
    await pumpHost(tester);
    await open(tester, 'open-past');

    await tester.tap(find.byKey(const Key('wellbeingDayMarkRecoveryButton')));
    await tester.pumpAndSettle();

    final dialog = tester.widget<MarkRecoveryDayDialog>(
      find.byType(MarkRecoveryDayDialog),
    );
    expect(
      dialog.initialDay,
      past,
      reason: 'she has already picked the day by tapping it on the calendar',
    );

    await flushDriftTimers(tester);
  });

  testWidgets('a day that already has a recovery day offers no second one', (
    tester,
  ) async {
    final database = await pumpHost(tester);
    await DriftRecoveryRepository(database).markRecoveryDay(past);
    await tester.pumpAndSettle();
    await open(tester, 'open-past');

    expect(
      find.byKey(const Key('wellbeingDayMarkRecoveryButton')),
      findsNothing,
    );
    expect(find.byType(RecoveryTile), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('a day that already has a flare can still take another one', (
    tester,
  ) async {
    final database = await pumpHost(tester);
    await seedFlare(database, today);
    await tester.pumpAndSettle();
    await open(tester, 'open-today');

    // Multiple flares per day are allowed (`WellbeingRepository.saveFlare`),
    // so the button belongs to the section, not to its empty case.
    expect(find.byType(FlareTile), findsOneWidget);
    expect(find.byKey(const Key('wellbeingDayLogFlareButton')), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('a day that has not happened yet offers nothing', (tester) async {
    await pumpHost(tester);
    await open(tester, 'open-future');

    expect(
      find.textContaining("This day hasn't happened yet"),
      findsOneWidget,
    );
    expect(find.text('Check-in'), findsNothing);
    expect(find.byKey(const Key('wellbeingDayLogCheckinButton')), findsNothing);
    expect(find.byKey(const Key('wellbeingDayLogFlareButton')), findsNothing);

    await flushDriftTimers(tester);
  });

  testWidgets('the last action clears the system navigation bar', (
    tester,
  ) async {
    // The device bug (2026-09-03, Android 3-button navigation): the sheet
    // is pushed on the root navigator, which is right, but nothing padded
    // its content for the system nav bar, so "Mark as a recovery day" -
    // the last row - sat underneath it and could not be tapped.
    // `showAppBottomSheet` (`core/widgets/app_bottom_sheet.dart`) applies
    // that inset once for every sheet in the app.
    const navBar = 48.0;
    tester.view.viewPadding = const FakeViewPadding(bottom: navBar);
    addTearDown(tester.view.resetViewPadding);

    await pumpHost(tester);
    await open(tester, 'open-past');

    final button = find.byKey(const Key('wellbeingDayMarkRecoveryButton'));
    expect(button, findsOneWidget);

    // 1400 physical px at devicePixelRatio 1 (see pumpHost).
    const screenHeight = 1400.0;
    expect(
      tester.getRect(button).bottom,
      lessThanOrEqualTo(screenHeight - navBar),
      reason:
          '"Mark as a recovery day" is drawn under the system '
          'navigation bar',
    );

    await flushDriftTimers(tester);
  });

  testWidgets('the sheet scrolls rather than overflowing when full', (
    tester,
  ) async {
    final database = await pumpHost(tester);
    tester.view
      ..physicalSize = const Size(320, 560)
      ..devicePixelRatio = 1;
    await seedCheckin(database, past);
    await seedFlare(database, past);
    await DriftRecoveryRepository(database).markRecoveryDay(past);
    await tester.pumpAndSettle();

    await open(tester, 'open-past');

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(WellbeingDaySheet),
        matching: find.byType(SingleChildScrollView),
      ),
      findsOneWidget,
    );

    await flushDriftTimers(tester);
  });
}
