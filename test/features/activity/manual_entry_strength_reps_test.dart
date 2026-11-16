// Regression tests for B1 (known_bugs.md): in manual strength entry the reps
// field accepted no input. Root cause: the field sat in a fixed 56dp box and
// its "reps" suffix consumed the whole width, leaving the EditableText 0dp
// wide. These tests type through the real text-input channel (tap, then
// testTextInput) rather than tester.enterText, which bypasses hit-testing.
//
// pumpAndSettle is avoided after a field gains focus: the cursor blink keeps
// scheduling frames, so pumpAndSettle would spin until its 10-minute timeout.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/presentation/manual_entry_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _short = Duration(milliseconds: 300);
const _timeout = Timeout(Duration(seconds: 60));

void main() {
  late db.AppDatabase database;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    prefs = await SharedPreferences.getInstance();
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpWithSquat(
    WidgetTester tester, {
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = const Size(411, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(database),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const ManualEntryScreen(initialType: ActivityType.strength),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Exercise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
  }

  Finder repsField(int setIndex, int setCount) =>
      find.byKey(ValueKey('reps-0-$setIndex-$setCount-1'));

  Finder editableIn(Finder field) =>
      find.descendant(of: field, matching: find.byType(EditableText));

  Future<void> typeInto(WidgetTester tester, Finder field, String text) async {
    await tester.tap(field);
    await tester.pump(_short);
    tester.testTextInput.enterText(text);
    await tester.pump(_short);
  }

  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  for (final scale in [1.0, 1.5]) {
    testWidgets(
      'reps input has usable width at text scale $scale',
      (tester) async {
        await pumpWithSquat(tester, textScale: scale);
        final editable = editableIn(repsField(0, 3));
        expect(editable, findsOneWidget);
        expect(tester.getSize(editable).width, greaterThanOrEqualTo(48));
        await disposeTree(tester);
      },
      timeout: _timeout,
    );
  }

  testWidgets(
    'typing into reps updates the field and is saved',
    (tester) async {
      await pumpWithSquat(tester);
      final field = repsField(0, 3);
      await typeInto(tester, field, '12');
      expect(
        tester.widget<EditableText>(editableIn(field)).controller.text,
        '12',
      );

      // Duration is required to save.
      await tester.enterText(find.byType(TextField).at(1), '45');
      await tester.pump(_short);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(_short);
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump(_short);
      await tester.pump(_short);

      final rows = await database.select(database.activities).get();
      expect(rows, hasLength(1));
      final details =
          WorkoutDetails.fromStorage(rows.first.metadataJson)!
              as StrengthWorkoutDetails;
      expect(details.exercises.single.sets.first.reps, 12);
      await disposeTree(tester);
    },
    timeout: _timeout,
  );

  testWidgets(
    'removing a set re-seeds the remaining rows from state',
    (tester) async {
      await pumpWithSquat(tester);
      await typeInto(tester, repsField(1, 3), '7');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(_short);

      await tester.tap(find.byTooltip('Remove set').first);
      await tester.pump(_short);

      // Old set 2 (7 reps) is now the first row.
      final first = repsField(0, 2);
      expect(
        tester.widget<EditableText>(editableIn(first)).controller.text,
        '7',
      );
      await disposeTree(tester);
    },
    timeout: _timeout,
  );
}
