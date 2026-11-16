import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/data/drift_activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/streaks/data/drift_recovery_repository.dart';
import 'package:menfit_app/features/wellbeing/data/drift_wellbeing_repository.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/wellbeing_screen.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/history_tiles.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end coverage for managing/amending recovery days (S1-3): the
/// streak card's "Today" management sheet (tapping the protected card),
/// and the wellbeing history screen's recovery-day rows + retroactive
/// "Mark recovery days" action — through the real provider chain, the
/// same convention as `recovery_prompt_flow_test.dart`.
void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  /// Pumps the real [App] over [database]/[prefs] if given, otherwise a
  /// fresh in-memory database and a fresh mocked [SharedPreferences]
  /// instance — same helper shape as `recovery_prompt_flow_test.dart`'s.
  Future<db.AppDatabase> pumpApp(
    WidgetTester tester, {
    db.AppDatabase? database,
    SharedPreferences? prefs,
  }) async {
    tester.view
      ..physicalSize = const Size(400, 900)
      ..devicePixelRatio = 1;

    var resolvedPrefs = prefs;
    if (resolvedPrefs == null) {
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      resolvedPrefs = await SharedPreferences.getInstance();
    }
    final resolvedDatabase =
        database ?? db.AppDatabase.forTesting(NativeDatabase.memory());
    if (database == null) addTearDown(resolvedDatabase.close);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(resolvedPrefs),
          appDatabaseProvider.overrideWithValue(resolvedDatabase),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    return resolvedDatabase;
  }

  Future<void> flushTimers(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  /// Lets a UI-triggered Drift write complete for real, then settles.
  ///
  /// Some Drift writes triggered from widget taps never complete under
  /// pumped fake time (the documented CL-10-family wedge - central
  /// `testing-pitfalls.md`): the tap's async chain silently stalls, no
  /// stream emission follows, and dependent expectations fail even though
  /// the code is correct. `runAsync` steps outside the fake-async zone so
  /// the real timers/IO can fire.
  Future<void> settleRealAsync(WidgetTester tester) async {
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
  }

  /// Advances past a SnackBar's default ~4s auto-dismiss timer and settles
  /// the exit animation. `pumpAndSettle()` alone does NOT do this (a bare
  /// `Timer` firing doesn't itself keep scheduling frames, so
  /// `pumpAndSettle` stops well before 4s of virtual time elapse) - without
  /// this, a still-visible SnackBar from an earlier action can sit exactly
  /// where a later tap target is and silently steal the hit test.
  Future<void> flushSnackbar(WidgetTester tester) async {
    // Deterministic dismissal rather than waiting out the ~4s timer: a
    // snackbar shown during a `runAsync` window (settleRealAsync) arms its
    // auto-dismiss as a REAL-zone timer, which fake-time pumps never
    // advance - such a snackbar would otherwise sit on screen for the rest
    // of the test stealing hit tests (diagnosed 2026-08-28).
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
        .clearSnackBars();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  /// Taps a bottom-nav destination by [label] - scoped to [NavigationBar]
  /// specifically, since some destination labels (e.g. "Nutrition") also
  /// appear as a dashboard card's title on the Home screen.
  Future<void> tapNavDestination(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// An instant that lands on [day] in this machine's local timezone - same
  /// helper shape as `streaks_providers_test.dart`'s.
  DateTime instantOnLocalDay(LocalDate day) {
    return DateTime(day.year, day.month, day.day, 12).toUtc();
  }

  Activity activity({required LocalDate day, required String id}) {
    return Activity(
      id: id,
      activityType: ActivityType.run,
      title: 'Run',
      startedAt: instantOnLocalDay(day),
      movingTime: const Duration(minutes: 30),
      elapsedTime: const Duration(minutes: 30),
      distanceMeters: 5000,
      source: ActivitySource.manual,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  testWidgets(
    'marking today recovery via the card, then tapping the protected card, '
    'shows the explicit source in the Today sheet; Remove returns the card '
    'to normal and Undo restores it',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final database = await pumpApp(tester);

      await tester.tap(find.text('Make today a recovery day'));
      await settleRealAsync(tester);
      expect(find.text('Recovery day'), findsOneWidget);

      // Let the "Recovery day marked" snackbar (still showing - see
      // `flushSnackbar`'s dartdoc) clear before the next interaction, so it
      // can't overlap/steal the tap below.
      await flushSnackbar(tester);

      // Deliberate tap on the now-protected card - opens the Today sheet.
      await tester.tap(find.text('Recovery day'));
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(
        find.text('You marked today as a recovery day'),
        findsOneWidget,
      );
      expect(find.text('Remove recovery day'), findsOneWidget);
      // Only the one active source - no flare copy.
      expect(find.text('You logged a flare-up today'), findsNothing);

      await tester.ensureVisible(find.text('Remove recovery day'));
      await tester.tap(find.text('Remove recovery day'));
      await settleRealAsync(tester);

      // Nothing protects today any more - the sheet closes itself and the
      // card behind it is back to the unprotected state.
      expect(find.text('Today'), findsNothing);
      expect(find.text('Make today a recovery day'), findsOneWidget);
      expect(find.text('Recovery day removed'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      final rowsAfterRemove = await database
          .select(database.recoveryDays)
          .get();
      expect(rowsAfterRemove, isEmpty);

      await tester.tap(find.text('Undo'));
      await settleRealAsync(tester);

      expect(find.text('Recovery day'), findsOneWidget);
      final rowsAfterUndo = await database.select(database.recoveryDays).get();
      expect(rowsAfterUndo, hasLength(1));

      semanticsHandle.dispose();
      await flushTimers(tester);
    },
  );

  testWidgets(
    'a protecting flare AND an explicit recovery day both list in the '
    'Today sheet; removing the explicit recovery day keeps the card '
    'protected (the flare still covers it) and the sheet stays open',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final database = await pumpApp(tester);
      final today = LocalDate.today();

      final now = DateTime.now().toUtc();
      await DriftWellbeingRepository(database).saveFlare(
        FlareEvent(
          id: EntityId.generate(),
          day: today,
          severity: FlareSeverity.moderate,
          impact: FlareImpact.unableToTrain,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await DriftRecoveryRepository(database).markRecoveryDay(today);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Recovery day'));
      await tester.pumpAndSettle();

      expect(
        find.text('You marked today as a recovery day'),
        findsOneWidget,
      );
      expect(find.text('You logged a flare-up today'), findsOneWidget);
      expect(find.text('View in Recovery'), findsOneWidget);

      await tester.ensureVisible(find.text('Remove recovery day'));
      await tester.tap(find.text('Remove recovery day'));
      await tester.pumpAndSettle();

      // The flare source still protects today - the sheet stays open and
      // shows only the remaining source; no misleading "at risk" copy.
      expect(find.text('Today'), findsOneWidget);
      expect(
        find.text('You marked today as a recovery day'),
        findsNothing,
      );
      expect(find.text('You logged a flare-up today'), findsOneWidget);

      // The card behind the (still-open) sheet reflects the same thing -
      // still protected, not "make today a recovery day" again.
      expect(find.text('Recovery day'), findsOneWidget);
      expect(find.text('Make today a recovery day'), findsNothing);

      semanticsHandle.dispose();
      await flushTimers(tester);
    },
  );

  testWidgets(
    'the wellbeing history screen lists a recovery day with its note, '
    'Remove deletes it, and marking a PAST day as recovery heals a '
    'previously broken streak through the real provider chain',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final database = await pumpApp(tester);
      final today = LocalDate.today();

      // Seed a recovery day two days ago, WITH a note, directly via the
      // repository - the note-rendering/removal assertions below don't
      // need to also exercise the marking UI (that's covered separately
      // by the retroactive-heal half of this test).
      await DriftRecoveryRepository(
        database,
      ).markRecoveryDay(today.addDays(-2), note: 'Sore calves after Tuesday');

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.byType(WellbeingScreen), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byType(RecoveryTile),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Scoped to the history CARD: the tab's calendar legend names the
      // same three record types the cards do, so an unscoped
      // `textContaining('Recovery day')` now also matches the legend item.
      expect(
        find.descendant(
          of: find.byType(RecoveryTile),
          matching: find.textContaining('Recovery day'),
        ),
        findsOneWidget,
      );
      expect(find.text('Sore calves after Tuesday'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove'));
      await settleRealAsync(tester);
      await flushSnackbar(tester);

      expect(find.text('Sore calves after Tuesday'), findsNothing);
      final rowsAfterRemove = await database
          .select(database.recoveryDays)
          .get();
      expect(rowsAfterRemove, isEmpty);

      // --- Retroactive heal: activity 2 days ago + today, with a gap on
      // day -1 - a plain, currently-broken streak (mirrors
      // `streaks_providers_test.dart`'s retroactive-flare scenario).
      await DriftActivityRepository(
        database,
      ).saveActivity(activity(day: today.addDays(-2), id: 'old'));
      await DriftActivityRepository(
        database,
      ).saveActivity(activity(day: today, id: 'new'));
      await tester.pumpAndSettle();

      // The Home screen's streak card is NOT findable while the Wellbeing
      // branch is the active tab (go_router's `StatefulShellRoute.
      // indexedStack` keeps the inactive Home branch mounted but not
      // painted, and default finders skip that) - switch back to the Home
      // tab to read the streak, then return via the check-in card's
      // History link.
      await tapNavDestination(tester, 'Home');
      expect(find.text('1-day streak'), findsOneWidget);
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Mark recovery days'));
      await tester.pumpAndSettle();
      expect(find.text('Mark recovery days'), findsWidgets);

      // Open the OS date picker via the dialog's Date field, then switch
      // it to text-entry mode and type yesterday's date (the exact gap
      // day) in the US default test locale's MM/DD/YYYY format.
      await tester.tap(find.byIcon(Icons.edit_calendar_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Switch to input'));
      await tester.pumpAndSettle();
      final yesterday = today.addDays(-1);
      final formatted =
          '${yesterday.month.toString().padLeft(2, '0')}/'
          '${yesterday.day.toString().padLeft(2, '0')}/'
          '${yesterday.year}';
      // Scoped to the picker dialog: the mark-recovery dialog's Note
      // TextField is still in the tree behind it, and an unscoped `.first`
      // types the date into the note instead (leaving the picker on its
      // default date - diagnosed 2026-08-28).
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

      await tester.ensureVisible(find.text('Mark recovery day'));
      await tester.tap(find.text('Mark recovery day'));
      await settleRealAsync(tester);

      // Same rule as above: switch back to the Home tab to read the healed
      // streak from the card.
      await flushSnackbar(tester);
      await tapNavDestination(tester, 'Home');
      expect(find.text('2-day streak'), findsOneWidget);

      semanticsHandle.dispose();
      await flushTimers(tester);
    },
  );

  testWidgets(
    'the Today sheet, the wellbeing history recovery row, and the mark '
    'dialog never use punitive language - warm, source-specific copy only',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final database = await pumpApp(tester);
      final today = LocalDate.today();
      final now = DateTime.now().toUtc();

      await DriftRecoveryRepository(
        database,
      ).markRecoveryDay(today, note: 'Feeling tender');
      await DriftWellbeingRepository(database).saveFlare(
        FlareEvent(
          id: EntityId.generate(),
          day: today,
          severity: FlareSeverity.mild,
          impact: FlareImpact.unableToTrain,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Recovery day'));
      await tester.pumpAndSettle();

      for (final word in ['excused', 'failed', 'frozen', 'freeze', 'skipped']) {
        expect(find.textContaining(word, findRichText: true), findsNothing);
      }
      expect(find.text('Remove recovery day'), findsOneWidget);
      expect(find.text('You logged a flare-up today'), findsOneWidget);

      // Dismiss the sheet by tapping the modal barrier above it, rather
      // than removing the only source that's keeping it open (both
      // sources here should stay intact for the History-screen half of
      // this test below).
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      for (final word in ['excused', 'failed', 'frozen', 'freeze', 'skipped']) {
        expect(find.textContaining(word, findRichText: true), findsNothing);
      }

      await tester.tap(find.byTooltip('Mark recovery days'));
      await tester.pumpAndSettle();
      for (final word in ['excused', 'failed', 'frozen', 'freeze', 'skipped']) {
        expect(find.textContaining(word, findRichText: true), findsNothing);
      }

      semanticsHandle.dispose();
      await flushTimers(tester);
    },
  );
}
