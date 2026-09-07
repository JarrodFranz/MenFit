import 'dart:async';

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
import 'package:menfit_app/features/home/presentation/home_screen.dart';
import 'package:menfit_app/features/wellbeing/data/drift_wellbeing_repository.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/presentation/checkin_sheet.dart';
import 'package:menfit_app/features/wellbeing/presentation/flare_dialog.dart';
import 'package:menfit_app/features/wellbeing/presentation/wellbeing_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end coverage for the §5.9 recovery-decision prompt: a check-in
/// reporting significant symptoms offers the choice, and accepting it
/// marks today as protected recovery — visible immediately on the home
/// streak card through the real provider chain (streaks watches
/// wellbeing's flare stream and its own recovery-day stream, both backed
/// by the same in-memory database this test seeds).
///
/// Acceptance criteria exercised:
/// - high-pain check-in offers prompt -> accept -> today is protected
///   recovery, streak card immediately reflects it.
/// - high-pain check-in offers prompt -> decline -> today is NOT protected,
///   prompt does NOT reappear this session.
/// - high-pain check-in with an EXISTING activity today -> NO prompt offered
///   (today is already covered; ADR 007 / rule 7).
/// - mild check-in (pain <= 2, energy >= 3, sleep >= 3) -> NO prompt.
/// - edit an existing check-in to high pain -> prompt offered.
/// - dismissal state is in-memory only (reset on app relaunch).
void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Future<db.AppDatabase> pumpApp(
    WidgetTester tester, {
    db.AppDatabase? database,
    SharedPreferences? prefs,
  }) async {
    tester.view
      ..physicalSize = const Size(400, 900)
      ..devicePixelRatio = 1;

    final resolvedPrefs =
        prefs ??
        await (() async {
          SharedPreferences.setMockInitialValues({'onboarding_complete': true});
          return SharedPreferences.getInstance();
        })();
    final resolvedDatabase =
        database ?? db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(resolvedDatabase.close);

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

  Future<void> saveCheckinWithHighPain(WidgetTester tester) async {
    final entryPoint = find.text('Check in').evaluate().isNotEmpty
        ? find.text('Check in')
        : (find.text('Edit').evaluate().isNotEmpty ? find.text('Edit') : null);
    if (entryPoint != null) {
      await tester.tap(entryPoint);
      await tester.pumpAndSettle();
    } else {
      unawaited(
        CheckinSheet.show(
          tester.element(find.byType(HomeScreen)),
          day: LocalDate.today(),
        ),
      );
      await tester.pumpAndSettle();
    }

    // Tapping an already-selected score clears it (`CheckinController.
    // setPain`'s "tap again to clear") - re-saving an "Edit" flow whose
    // check-in already has pain 5 pre-filled (e.g. F6's re-save-in-a-new-
    // session scenario) must NOT blindly tap it again, or it would clear
    // pain back to `null` instead of keeping it at 5.
    final painFiveFinder = find.bySemanticsLabel(RegExp('Pain score 5'));
    final alreadySelected = tester
        .widgetList<Semantics>(painFiveFinder)
        .any((widget) => widget.properties.selected ?? false);
    if (!alreadySelected) {
      await tester.tap(painFiveFinder);
      await tester.pump();
    }

    final saveButton = find.text('Save');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
  }

  Future<void> flushTimers(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets(
    'a check-in reporting high pain offers the recovery prompt; accepting '
    'it marks today protected and the streak card reflects it immediately',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final database = await pumpApp(tester);

      await saveCheckinWithHighPain(tester);

      // The check-in sheet closed and the recovery prompt appeared, with
      // F3's honest copy - no "safe either way" promise (declining leaves
      // the day unprotected).
      expect(find.text('Make today a recovery day?'), findsOneWidget);
      expect(find.text('Make it a recovery day'), findsOneWidget);
      expect(find.text('Keep training'), findsOneWidget);
      expect(find.textContaining('either way'), findsNothing);

      await tester.tap(find.text('Make it a recovery day'));
      await tester.pumpAndSettle();

      // The prompt closed, and the streak card now shows the protected
      // state - the recovery day was actually persisted, not just
      // acknowledged. Exact match (not `textContaining`): "Recovery day"
      // is also a substring of the card's own subtitle ("Recovery days
      // don't break your streak."), which would otherwise double-match.
      expect(find.text('Recovery day'), findsOneWidget);

      final rows = await database.select(database.recoveryDays).get();
      expect(rows, hasLength(1));

      semanticsHandle.dispose();
      await flushTimers(tester);
    },
  );

  testWidgets(
    'declining the prompt ("Keep training") does not mark a recovery day, '
    'and does not re-offer the prompt again this session for the same day',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final database = await pumpApp(tester);

      await saveCheckinWithHighPain(tester);
      expect(find.text('Keep training'), findsOneWidget);

      await tester.tap(find.text('Keep training'));
      await tester.pumpAndSettle();

      final rows = await database.select(database.recoveryDays).get();
      expect(rows, isEmpty);

      // Edit the check-in and save again (still high pain) - the prompt
      // must not reappear this session.
      unawaited(
        CheckinSheet.show(
          tester.element(find.byType(HomeScreen)),
          day: LocalDate.today(),
        ),
      );
      await tester.pumpAndSettle();
      final saveButton = find.text('Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Make today a recovery day?'), findsNothing);

      semanticsHandle.dispose();
      await flushTimers(tester);
    },
  );

  testWidgets(
    'F6: dismissal is session-only, not persisted - a FRESH ProviderScope '
    'over the SAME prefs+database re-offers the prompt on a new high-pain '
    'save',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      final prefs = await SharedPreferences.getInstance();
      final database = await pumpApp(tester, prefs: prefs);

      await saveCheckinWithHighPain(tester);
      expect(find.text('Keep training'), findsOneWidget);
      await tester.tap(find.text('Keep training'));
      await tester.pumpAndSettle();

      // Flush this App instance's stream-cleanup timers before pumping a
      // second, entirely separate App over the same backing stores
      // (central testing-pitfalls.md) - this is also load-bearing for a
      // second reason: pumping `SizedBox.shrink()` first replaces the root
      // widget's TYPE, forcing Flutter to fully dispose the current
      // `ProviderScope` element (and the `ProviderContainer` its `State`
      // owns) rather than merely updating it in place. Without this,
      // pumping a second structurally-identical `ProviderScope(child: const
      // App())` at the same tree position would just be an *update* to the
      // existing element (same widget type, no key) - the `State`, and
      // with it `ProviderContainer`/every provider's in-memory value
      // (including `recoveryPromptDismissalControllerProvider`, the exact
      // thing this test needs to reset), would survive untouched, defeating
      // the entire point of this test.
      await flushTimers(tester);

      // A brand-new `ProviderScope` (a fresh app "session") over the exact
      // same database/prefs objects - the in-memory-only dismissal state
      // resets to empty, even though the check-in itself (already saved
      // above, pain 5) is still there.
      await pumpApp(tester, database: database, prefs: prefs);

      // Re-saving the same (already pain-5) check-in re-triggers the
      // eligibility check; this fresh session has never dismissed today.
      await saveCheckinWithHighPain(tester);

      expect(find.text('Make today a recovery day?'), findsOneWidget);

      semanticsHandle.dispose();
      await flushTimers(tester);
    },
  );

  testWidgets(
    'F6: today-already-covered guard - an existing activity today means no '
    'prompt, even for a high-pain check-in',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      final prefs = await SharedPreferences.getInstance();
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      final now = DateTime.now().toUtc();
      await DriftActivityRepository(database).saveActivity(
        Activity(
          id: EntityId.generate(),
          activityType: ActivityType.run,
          title: 'Morning run',
          startedAt: now,
          movingTime: const Duration(minutes: 20),
          elapsedTime: const Duration(minutes: 20),
          distanceMeters: 4000,
          source: ActivitySource.manual,
          createdAt: now,
          updatedAt: now,
        ),
      );

      tester.view
        ..physicalSize = const Size(400, 900)
        ..devicePixelRatio = 1;
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

      await saveCheckinWithHighPain(tester);

      expect(find.text('Make today a recovery day?'), findsNothing);

      semanticsHandle.dispose();
      await flushTimers(tester);
    },
  );

  testWidgets(
    'F6: a mild check-in does not prompt; editing it to a significant pain '
    'the same session DOES prompt',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      await pumpApp(tester);

      await tester.tap(find.text('Check in'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(RegExp('Pain score 2')));
      await tester.pump();
      var saveButton = find.text('Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Make today a recovery day?'), findsNothing);

      // Edit the same day's check-in, raising pain to a significant value.
      unawaited(
        CheckinSheet.show(
          tester.element(find.byType(HomeScreen)),
          day: LocalDate.today(),
        ),
      );
      await tester.pumpAndSettle();
      // Clear the mild pain-2 selection, then pick pain 4 - tapping an
      // already-selected score clears it (`CheckinController.setPain`'s
      // "tap again to clear"), so pain 2 must be deselected first.
      await tester.tap(find.bySemanticsLabel(RegExp('Pain score 2')));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel(RegExp('Pain score 4')));
      await tester.pump();
      saveButton = find.text('Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Make today a recovery day?'), findsOneWidget);

      semanticsHandle.dispose();
      await flushTimers(tester);
    },
  );

  testWidgets(
    "F2: logging an impactful flare via the check-in sheet's flare button, "
    'with NO check-in scores set at all, still offers the prompt (the '
    'flare-only trigger)',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      await pumpApp(tester);

      await tester.tap(find.text('Check in'));
      await tester.pumpAndSettle();

      final logFlareButton = find.text('Log a flare-up');
      await tester.ensureVisible(logFlareButton);
      await tester.tap(logFlareButton);
      await tester.pumpAndSettle();

      // The dialog's content can be taller than the viewport - scroll each
      // field into view within its `SingleChildScrollView` before tapping
      // (same pattern as `flare_flow_test.dart`).
      Future<void> tapInDialog(String text) async {
        final finder = find.descendant(
          of: find.byType(FlareDialog),
          matching: find.text(text),
        );
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pump();
      }

      await tapInDialog('Severe');
      // Deliberately "Reduced my training", NOT "Couldn't train": the
      // latter (`FlareImpact.unableToTrain`) auto-protects today via
      // `streak_assembly.dart`'s protection rule (b), which would flip
      // `todayStatus` to `protectedRecovery` BEFORE the eligibility check
      // even runs — correctly short-circuiting to `alreadyCovered` rather
      // than `offer` (today genuinely is already covered by then). A
      // `reducedTraining` impact is exactly the case
      // `hasSignificantSymptoms`'s dartdoc calls out as "worth surfacing,
      // even though it won't auto-protect until the user actually accepts
      // it" - significant enough to prompt, without pre-empting the
      // prompt by already protecting the day itself.
      await tapInDialog('Reduced my training');
      await tapInDialog('Log flare-up');
      await tester.pumpAndSettle();

      // Back on the still-open, still-blank check-in sheet - saving it
      // (a no-op for the check-in itself, since every score is still
      // unset) is what triggers the eligibility check.
      final saveButton = find.text('Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Make today a recovery day?'), findsOneWidget);

      semanticsHandle.dispose();
      await flushTimers(tester);
    },
  );

  testWidgets(
    "F2: editing YESTERDAY's check-in to a high pain never offers the "
    "prompt - only today's own check-in flow does",
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      final prefs = await SharedPreferences.getInstance();
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      final yesterday = LocalDate.today().addDays(-1);
      final now = DateTime.now().toUtc();
      await DriftWellbeingRepository(database).saveCheckin(
        DailyCheckin(
          id: EntityId.generate(),
          day: yesterday,
          energy: 3,
          createdAt: now,
          updatedAt: now,
        ),
      );

      tester.view
        ..physicalSize = const Size(400, 900)
        ..devicePixelRatio = 1;
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

      // Navigate to the wellbeing history screen via the check-in card's
      // "History" link, then open yesterday's entry (the only history
      // entry seeded) for editing.
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.byType(WellbeingScreen), findsOneWidget);
      // Scoped to `WellbeingScreen` (not a bare `find.byType(ListTile)`):
      // `SettingsScreen` also contains `ListTile`s, and go_router's
      // `StatefulShellRoute.indexedStack` branches (`app/router/`) can keep
      // an inactive branch mounted offstage rather than disposing it.
      await tester.tap(
        find
            .descendant(
              of: find.byType(WellbeingScreen),
              matching: find.byType(ListTile),
            )
            .first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel(RegExp('Pain score 5')));
      await tester.pump();
      final saveButton = find.text('Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Make today a recovery day?'), findsNothing);

      semanticsHandle.dispose();
      await flushTimers(tester);
    },
  );
}
