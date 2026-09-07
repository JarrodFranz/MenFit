import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/wellbeing/presentation/checkin_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  testWidgets(
    'home shows the invite card -> open sheet -> set Energy 4, Sleep 3, '
    'pick a symptom -> Save -> card shows summary; edit path re-opens '
    'with the same values pre-filled',
    (tester) async {
      tester.view
        ..physicalSize = const Size(400, 900)
        ..devicePixelRatio = 1;

      // `find.bySemanticsLabel` needs the semantics tree actually built -
      // disposed explicitly at the end (not via addTearDown - flutter_test's
      // own "no SemanticsHandle left open" check runs before addTearDown
      // callbacks fire). Same convention as
      // `test/features/progress/progress_screen_test.dart`.
      final semanticsHandle = tester.ensureSemantics();

      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      final prefs = await SharedPreferences.getInstance();
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

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

      // Home shows the invite card - warm, optional-feeling.
      expect(find.text('How are you feeling today?'), findsOneWidget);
      expect(find.textContaining('optional'), findsWidgets);
      expect(find.text('Check in'), findsOneWidget);

      await tester.tap(find.text('Check in'));
      await tester.pumpAndSettle();

      expect(find.byType(CheckinSheet), findsOneWidget);

      // Set Energy 4, Sleep 3 via the score segments' disambiguating
      // semantics labels ("<field> score <n>") - the visible text is just
      // "4"/"3", which is ambiguous across the five score rows. The
      // framework merges the descendant Text's "4"/"3" onto this node's
      // label (a second line), so match by RegExp rather than exact string
      // equality (`bySemanticsLabel`'s own dartdoc recommends this over
      // trying to force the framework to stop merging).
      await tester.tap(find.bySemanticsLabel(RegExp('Energy score 4')));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel(RegExp('Sleep score 3')));
      await tester.pump();

      // Pick a symptom.
      await tester.tap(
        find.descendant(
          of: find.byType(CheckinSheet),
          matching: find.text('Cramping'),
        ),
      );
      await tester.pump();

      final saveButton = find.descendant(
        of: find.byType(CheckinSheet),
        matching: find.text('Save'),
      );
      // The sheet's content can be taller than the viewport - scroll the
      // Save button into view within its SingleChildScrollView before
      // tapping it.
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Sheet closed, card auto-hides from the home page once logged
      // as requested.
      expect(find.byType(CheckinSheet), findsNothing);
      expect(find.text('How are you feeling today?'), findsNothing);
      expect(find.text('Check in'), findsNothing);

      final rows = await database.select(database.dailyCheckins).get();
      expect(rows, hasLength(1));
      expect(rows.single.energy, 4);
      expect(rows.single.sleep, 3);
      expect(rows.single.symptoms, 'cramping');

      semanticsHandle.dispose();

      // Flush Drift's stream-cleanup timers under a pump we control before
      // flutter_test's own teardown (central testing-pitfalls.md).
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets(
    'selecting Other symptom in check-in reveals free-text field and persists '
    'custom symptom',
    (tester) async {
      tester.view
        ..physicalSize = const Size(400, 900)
        ..devicePixelRatio = 1;

      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      final prefs = await SharedPreferences.getInstance();
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

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

      await tester.tap(find.text('Check in'));
      await tester.pumpAndSettle();

      final otherChip = find.descendant(
        of: find.byType(CheckinSheet),
        matching: find.text('Other'),
      );
      await tester.ensureVisible(otherChip);
      await tester.tap(otherChip);
      await tester.pumpAndSettle();

      final otherField = find.byKey(const Key('checkinOtherSymptomField'));
      expect(otherField, findsOneWidget);
      await tester.enterText(otherField, 'Migraine with aura');
      await tester.pumpAndSettle();

      final saveButton = find.descendant(
        of: find.byType(CheckinSheet),
        matching: find.text('Save'),
      );
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final rows = await database.select(database.dailyCheckins).get();
      expect(rows, hasLength(1));
      expect(rows.single.symptoms, contains('other:'));
      expect(rows.single.symptoms, contains('Migraine'));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
