import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/nutrition/domain/macro_locks.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_goals_screen.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/macro_target_fields.dart';

/// Tears the tree down and pumps once so live Drift stream timers fire and
/// cancel instead of being reported as pending — same reason as
/// `nutrition_day_screen_test.dart`'s copy of this.
Future<void> flushDriftTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

/// Scrolls a lazily-built ListView until [finder] matches — content below
/// the fold has never been built, so `ensureVisible` alone throws.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 15 && finder.evaluate().isEmpty; i++) {
    await tester.dragFrom(const Offset(250, 1100), const Offset(0, -300));
    await tester.pump();
  }
  await tester.ensureVisible(finder);
}

void main() {
  final now = DateTime.utc(2026, 8, 27, 8);

  late db.AppDatabase database;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Future<void> saveGoals(NutritionGoals goals) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    await container.read(nutritionGoalsRepositoryProvider).saveGoals(goals);
  }

  Future<NutritionGoals?> readGoals() async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    return container.read(nutritionGoalsRepositoryProvider).getGoals();
  }

  Future<void> pumpGoals(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(500, 1800)
      ..devicePixelRatio = 1;
    addTearDown(() => flushDriftTimers(tester));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const NutritionGoalsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enterInto(WidgetTester tester, String key, String text) async {
    await scrollTo(tester, find.byKey(Key(key)));
    await tester.enterText(find.byKey(Key(key)), text);
    await tester.pump();
  }

  Future<void> switchTo(WidgetTester tester, MacroTargetMode mode) async {
    await scrollTo(tester, find.byKey(const Key('macroTargetModeToggle')));
    await tester.tap(find.text(mode.label));
    await tester.pumpAndSettle();
  }

  Future<void> saveTargets(WidgetTester tester) async {
    await scrollTo(tester, find.text('Save targets'));
    await tester.tap(find.text('Save targets'));
    await tester.pumpAndSettle();
  }

  Future<void> toggleLock(WidgetTester tester, String fieldKey) async {
    await scrollTo(tester, find.byKey(Key('${fieldKey}Lock')));
    await tester.tap(find.byKey(Key('${fieldKey}Lock')));
    await tester.pumpAndSettle();
  }

  String fieldText(WidgetTester tester, String key) =>
      tester.widget<TextField>(find.byKey(Key(key))).controller!.text;

  testWidgets('the targets form starts in grams with no split suggested', (
    tester,
  ) async {
    await pumpGoals(tester);
    await scrollTo(tester, find.byKey(const Key('macroTargetModeToggle')));

    expect(find.byType(MacroGramFields), findsOneWidget);
    expect(find.byType(MacroPercentFields), findsNothing);
    // No default or suggested split anywhere: the fields start blank and
    // nothing describes a ratio as balanced or recommended.
    for (final key in [
      'proteinTargetField',
      'carbTargetField',
      'fatTargetField',
    ]) {
      expect(
        tester.widget<TextField>(find.byKey(Key(key))).controller!.text,
        isEmpty,
      );
    }
    for (final word in ['balanced', 'recommend', '40/30/30', 'suggested']) {
      expect(find.textContaining(word), findsNothing);
    }

    await flushDriftTimers(tester);
  });

  testWidgets('the toggle swaps the macro fields, and the calorie field is '
      'untouched by it', (tester) async {
    await pumpGoals(tester);
    await switchTo(tester, MacroTargetMode.percent);

    expect(find.byType(MacroPercentFields), findsOneWidget);
    expect(find.byType(MacroGramFields), findsNothing);
    expect(find.byKey(const Key('proteinPercentField')), findsOneWidget);
    expect(find.byKey(const Key('proteinTargetField')), findsNothing);
    expect(
      find.byKey(const Key('calorieTargetField')),
      findsOneWidget,
      reason: 'the calorie target is not part of the macro representation',
    );

    await switchTo(tester, MacroTargetMode.grams);
    expect(find.byType(MacroGramFields), findsOneWidget);
    expect(find.byType(MacroPercentFields), findsNothing);

    await flushDriftTimers(tester);
  });

  testWidgets('percentages show the grams they work out to, from the calorie '
      'target as typed', (tester) async {
    await pumpGoals(tester);
    await enterInto(tester, 'calorieTargetField', '2000');
    await switchTo(tester, MacroTargetMode.percent);
    await enterInto(tester, 'proteinPercentField', '30');
    await enterInto(tester, 'carbPercentField', '40');
    await enterInto(tester, 'fatPercentField', '30');

    // 30% of 2000 kcal at 4 kcal/g = 150 g; 40% at 4 = 200 g; 30% at 9 = 67 g.
    expect(find.text('Works out to 150 g a day'), findsOneWidget);
    expect(find.text('Works out to 200 g a day'), findsOneWidget);
    expect(find.text('Works out to 67 g a day'), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('with no calorie target and no estimate the form says a calorie '
      'figure is needed first, and shows no grams', (tester) async {
    await pumpGoals(tester);
    await switchTo(tester, MacroTargetMode.percent);
    await enterInto(tester, 'proteinPercentField', '30');

    expect(
      find.textContaining('Percentages need a daily calorie figure'),
      findsOneWidget,
    );
    expect(find.textContaining('Works out to'), findsNothing);
    expect(
      find.textContaining('0 g'),
      findsNothing,
      reason: 'no basis means no grams, never a target of zero',
    );

    await flushDriftTimers(tester);
  });

  testWidgets(
    'hide calorie numbers leaves no kcal figure anywhere in the macro '
    'section, while the grams stay',
    (tester) async {
      await saveGoals(
        NutritionGoals(
          id: 'goals-1',
          createdAt: now,
          updatedAt: now,
          calorieTargetKcal: 2000,
          hideCalorieNumbers: true,
          macroTargetMode: MacroTargetMode.percent,
          proteinTargetPercent: 30,
          carbTargetPercent: 40,
          fatTargetPercent: 30,
        ),
      );
      await pumpGoals(tester);
      await scrollTo(tester, find.byType(MacroPercentFields));

      final section = find.byType(MacroPercentFields);
      expect(
        find.descendant(of: section, matching: find.textContaining('kcal')),
        findsNothing,
      );
      expect(
        find.descendant(of: section, matching: find.textContaining('2000')),
        findsNothing,
      );
      // Grams are not calories, so they are still theirs to see.
      expect(
        find.descendant(
          of: section,
          matching: find.text('Works out to 150 g a day'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: section,
          matching: find.textContaining('daily calorie target'),
        ),
        findsOneWidget,
        reason: 'the basis is still named in words, just not in numbers',
      );

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'with calorie numbers shown the basis figure is named, so they can see '
    'what the shares are shares of',
    (tester) async {
      await saveGoals(
        NutritionGoals(
          id: 'goals-1',
          createdAt: now,
          updatedAt: now,
          calorieTargetKcal: 2000,
          macroTargetMode: MacroTargetMode.percent,
          proteinTargetPercent: 30,
        ),
      );
      await pumpGoals(tester);
      await scrollTo(tester, find.byType(MacroPercentFields));

      expect(
        find.descendant(
          of: find.byType(MacroPercentFields),
          matching: find.textContaining('2000 kcal'),
        ),
        findsOneWidget,
      );

      await flushDriftTimers(tester);
    },
  );

  testWidgets('switching modes keeps what was typed in the other one', (
    tester,
  ) async {
    await pumpGoals(tester);
    await enterInto(tester, 'proteinTargetField', '110');
    await switchTo(tester, MacroTargetMode.percent);
    await enterInto(tester, 'proteinPercentField', '30');
    await switchTo(tester, MacroTargetMode.grams);

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('proteinTargetField')))
          .controller!
          .text,
      '110',
    );

    await switchTo(tester, MacroTargetMode.percent);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('proteinPercentField')))
          .controller!
          .text,
      '30',
    );

    await flushDriftTimers(tester);
  });

  testWidgets('a split that does not add up blocks the save and states the '
      'arithmetic', (tester) async {
    await pumpGoals(tester);
    await switchTo(tester, MacroTargetMode.percent);
    await enterInto(tester, 'proteinPercentField', '30');
    await enterInto(tester, 'carbPercentField', '36');
    await enterInto(tester, 'fatPercentField', '30');
    await saveTargets(tester);

    expect(
      find.text(
        'These come to 96% — they need to add up to 100% between them.',
      ),
      findsOneWidget,
    );
    expect(
      await readGoals(),
      isNull,
      reason: 'nothing is written while the split is not a whole day',
    );

    await flushDriftTimers(tester);
  });

  testWidgets('a split that adds up saves in percent mode', (tester) async {
    await pumpGoals(tester);
    await enterInto(tester, 'calorieTargetField', '2000');
    await switchTo(tester, MacroTargetMode.percent);
    await enterInto(tester, 'proteinPercentField', '30');
    await enterInto(tester, 'carbPercentField', '40');
    await enterInto(tester, 'fatPercentField', '30');
    await saveTargets(tester);

    final saved = (await readGoals())!;
    expect(saved.macroTargetMode, MacroTargetMode.percent);
    expect(saved.proteinTargetPercent, 30);
    expect(saved.carbTargetPercent, 40);
    expect(saved.fatTargetPercent, 30);
    expect(saved.calorieTargetKcal, 2000);
    expect(saved.hasAnyTarget, isTrue);

    await flushDriftTimers(tester);
  });

  testWidgets('a blank percentage field clears that target, as in grams mode', (
    tester,
  ) async {
    await saveGoals(
      NutritionGoals(
        id: 'goals-1',
        createdAt: now,
        updatedAt: now,
        macroTargetMode: MacroTargetMode.percent,
        proteinTargetPercent: 30,
        carbTargetPercent: 40,
        fatTargetPercent: 30,
      ),
    );
    await pumpGoals(tester);
    await enterInto(tester, 'proteinPercentField', '');
    await enterInto(tester, 'carbPercentField', '');
    await enterInto(tester, 'fatPercentField', '');
    await saveTargets(tester);

    final saved = (await readGoals())!;
    expect(saved.proteinTargetPercent, isNull);
    expect(saved.carbTargetPercent, isNull);
    expect(saved.fatTargetPercent, isNull);

    await flushDriftTimers(tester);
  });

  testWidgets('a share over 100 is reported on its own field', (tester) async {
    await pumpGoals(tester);
    await switchTo(tester, MacroTargetMode.percent);
    await enterInto(tester, 'proteinPercentField', '140');
    await enterInto(tester, 'carbPercentField', '40');
    await enterInto(tester, 'fatPercentField', '30');
    await saveTargets(tester);

    expect(
      find.text("One share can't be more than 100% of the day."),
      findsOneWidget,
    );
    expect(await readGoals(), isNull);

    await flushDriftTimers(tester);
  });

  testWidgets('grams mode still saves grams and records the mode', (
    tester,
  ) async {
    await pumpGoals(tester);
    await enterInto(tester, 'proteinTargetField', '110');
    await enterInto(tester, 'carbTargetField', '240');
    await enterInto(tester, 'fatTargetField', '70');
    await saveTargets(tester);

    final saved = (await readGoals())!;
    expect(saved.macroTargetMode, MacroTargetMode.grams);
    expect(saved.proteinTargetGrams, 110);
    expect(saved.carbTargetGrams, 240);
    expect(saved.fatTargetGrams, 70);

    await flushDriftTimers(tester);
  });

  group('macro locks', () {
    testWidgets('nothing is locked and nothing is computed to begin with', (
      tester,
    ) async {
      await pumpGoals(tester);
      await scrollTo(tester, find.byType(MacroGramFields));

      for (final macro in MacroNutrient.values) {
        expect(
          find.byTooltip(macroLockSemanticsLabel(macro, locked: false)),
          findsOneWidget,
          reason: 'every lock starts open, and says so to a screen reader',
        );
        expect(
          find.byTooltip(macroLockSemanticsLabel(macro, locked: true)),
          findsNothing,
        );
      }
      expect(find.byKey(const Key('macroLockNote')), findsNothing);
      for (final key in [
        'proteinTargetField',
        'carbTargetField',
        'fatTargetField',
      ]) {
        expect(fieldText(tester, key), isEmpty);
        expect(
          tester.widget<TextField>(find.byKey(Key(key))).readOnly,
          isFalse,
        );
      }

      await flushDriftTimers(tester);
    });

    testWidgets('locking two works out the third and marks it as computed', (
      tester,
    ) async {
      await pumpGoals(tester);
      await enterInto(tester, 'calorieTargetField', '2000');
      await enterInto(tester, 'proteinTargetField', '150');
      await enterInto(tester, 'carbTargetField', '200');
      await toggleLock(tester, 'proteinTargetField');
      await toggleLock(tester, 'carbTargetField');

      // 150 g protein + 200 g carbs = 1400 kcal, leaving 600 for fat at 9.
      expect(fieldText(tester, 'fatTargetField'), '66.7');
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('fatTargetField')))
            .readOnly,
        isTrue,
        reason: 'a worked-out value is not a field to type in',
      );
      expect(
        find.text(
          'Worked out from your calorie target and the two you '
          'locked.',
        ),
        findsOneWidget,
        reason: 'the number has to say it was calculated, not typed',
      );
      expect(
        find.byTooltip(
          macroLockSemanticsLabel(MacroNutrient.protein, locked: true),
        ),
        findsOneWidget,
      );

      await flushDriftTimers(tester);
    });

    testWidgets('the computed macro moves when the calorie target does', (
      tester,
    ) async {
      await pumpGoals(tester);
      await enterInto(tester, 'calorieTargetField', '2000');
      await enterInto(tester, 'proteinTargetField', '150');
      await enterInto(tester, 'carbTargetField', '200');
      await toggleLock(tester, 'proteinTargetField');
      await toggleLock(tester, 'carbTargetField');
      expect(fieldText(tester, 'fatTargetField'), '66.7');

      await enterInto(tester, 'calorieTargetField', '2200');

      // 2200 - 1400 = 800 kcal of fat at 9 kcal a gram.
      expect(
        fieldText(tester, 'fatTargetField'),
        '88.9',
        reason: 'tracking the calorie target is the whole point of a lock',
      );

      await flushDriftTimers(tester);
    });

    testWidgets('unlocking one hands the field back to the user', (
      tester,
    ) async {
      await pumpGoals(tester);
      await enterInto(tester, 'calorieTargetField', '2000');
      await enterInto(tester, 'proteinTargetField', '150');
      await enterInto(tester, 'carbTargetField', '200');
      await toggleLock(tester, 'proteinTargetField');
      await toggleLock(tester, 'carbTargetField');
      await toggleLock(tester, 'carbTargetField');

      expect(
        tester
            .widget<TextField>(find.byKey(const Key('fatTargetField')))
            .readOnly,
        isFalse,
      );
      expect(
        fieldText(tester, 'fatTargetField'),
        '66.7',
        reason: 'the last worked-out number stays as an ordinary target',
      );

      await flushDriftTimers(tester);
    });

    testWidgets('one macro locked says what is still unaccounted for', (
      tester,
    ) async {
      await pumpGoals(tester);
      await enterInto(tester, 'calorieTargetField', '2000');
      await enterInto(tester, 'proteinTargetField', '150');
      await toggleLock(tester, 'proteinTargetField');

      expect(
        find.text(
          'Lock two of the three and the app works out the third. Your '
          'locked targets leave 1400 kcal of your calorie target unaccounted '
          'for.',
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('fatTargetField')))
            .readOnly,
        isFalse,
        reason: 'two free macros are underdetermined - no split is invented',
      );

      await flushDriftTimers(tester);
    });

    testWidgets('locked targets past the calorie target state the overage', (
      tester,
    ) async {
      await pumpGoals(tester);
      await enterInto(tester, 'calorieTargetField', '2000');
      await enterInto(tester, 'proteinTargetField', '250');
      await enterInto(tester, 'fatTargetField', '150');
      await toggleLock(tester, 'proteinTargetField');
      await toggleLock(tester, 'fatTargetField');

      // 250 g protein = 1000 kcal, 150 g fat = 1350 kcal: 2350 against 2000.
      expect(
        find.text(
          'Your locked targets already come to 2350 kcal — 350 more than '
          'your calorie target.',
        ),
        findsOneWidget,
      );
      expect(
        fieldText(tester, 'carbTargetField'),
        isEmpty,
        reason: 'no negative gram figure, and no clamp to zero either',
      );

      await flushDriftTimers(tester);
    });

    testWidgets(
      'hide calorie numbers leaves no kcal figure in the macro section, and '
      'still says the locked targets exceed the target',
      (tester) async {
        await saveGoals(
          NutritionGoals(
            id: 'goals-1',
            createdAt: now,
            updatedAt: now,
            calorieTargetKcal: 2000,
            hideCalorieNumbers: true,
            proteinTargetGrams: 250,
            fatTargetGrams: 150,
            macroLocks: const MacroLocks(protein: true, fat: true),
          ),
        );
        await pumpGoals(tester);
        await scrollTo(tester, find.byType(MacroGramFields));

        final section = find.byType(MacroGramFields);
        expect(
          find.descendant(of: section, matching: find.textContaining('kcal')),
          findsNothing,
        );
        expect(
          find.descendant(of: section, matching: find.textContaining('2350')),
          findsNothing,
        );
        expect(
          find.descendant(
            of: section,
            matching: find.textContaining(
              'more energy than your calorie target',
            ),
          ),
          findsOneWidget,
          reason:
              'hiding the figure must not hide the fact - they would be left '
              'with a target that cannot be met and no explanation',
        );

        await flushDriftTimers(tester);
      },
    );

    testWidgets('saving keeps the locks and the computed gram target', (
      tester,
    ) async {
      await pumpGoals(tester);
      await enterInto(tester, 'calorieTargetField', '2000');
      await enterInto(tester, 'proteinTargetField', '150');
      await enterInto(tester, 'carbTargetField', '200');
      await toggleLock(tester, 'proteinTargetField');
      await toggleLock(tester, 'carbTargetField');
      await saveTargets(tester);

      final saved = (await readGoals())!;
      expect(
        saved.macroLocks,
        const MacroLocks(protein: true, carbs: true),
        reason: 'a lock is a durable intent, not a widget state',
      );
      expect(
        saved.fatTargetGrams,
        66.7,
        reason: 'the worked-out value is saved as an ordinary gram target',
      );

      // Reopened, the locks are still on and the third is still computed.
      await pumpGoals(tester);
      await scrollTo(tester, find.byType(MacroGramFields));
      expect(
        find.byTooltip(
          macroLockSemanticsLabel(MacroNutrient.carbs, locked: true),
        ),
        findsOneWidget,
      );
      expect(fieldText(tester, 'fatTargetField'), '66.7');
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('fatTargetField')))
            .readOnly,
        isTrue,
      );

      await flushDriftTimers(tester);
    });

    testWidgets('percent mode has no locks - its third value is arithmetic', (
      tester,
    ) async {
      await pumpGoals(tester);
      await switchTo(tester, MacroTargetMode.percent);

      expect(find.byKey(const Key('proteinTargetFieldLock')), findsNothing);
      expect(find.byKey(const Key('macroLockNote')), findsNothing);

      await flushDriftTimers(tester);
    });

    testWidgets(
      'tapping Calculate with 0 locks populates standard macro spread',
      (
        tester,
      ) async {
        await pumpGoals(tester);
        await enterInto(tester, 'calorieTargetField', '2000');
        await scrollTo(tester, find.byKey(const Key('calculateTargetsButton')));
        await tester.tap(find.byKey(const Key('calculateTargetsButton')));
        await tester.pumpAndSettle();

        expect(fieldText(tester, 'proteinTargetField'), '100');
        expect(fieldText(tester, 'carbTargetField'), '250');
        expect(fieldText(tester, 'fatTargetField'), '66.7');

        await flushDriftTimers(tester);
      },
    );

    testWidgets(
      'tapping Calculate with 1 lock calculates the remaining 2 macros',
      (
        tester,
      ) async {
        await pumpGoals(tester);
        await enterInto(tester, 'calorieTargetField', '2000');
        await enterInto(tester, 'proteinTargetField', '150');
        await toggleLock(tester, 'proteinTargetField');
        await scrollTo(tester, find.byKey(const Key('calculateTargetsButton')));
        await tester.tap(find.byKey(const Key('calculateTargetsButton')));
        await tester.pumpAndSettle();

        expect(fieldText(tester, 'proteinTargetField'), '150');
        expect(fieldText(tester, 'carbTargetField'), '218.8');
        expect(fieldText(tester, 'fatTargetField'), '58.3');

        await flushDriftTimers(tester);
      },
    );

    testWidgets(
      'tapping Calculate with 3 locks recalculates the calorie target',
      (tester) async {
        await pumpGoals(tester);
        await enterInto(tester, 'calorieTargetField', '2500');
        // Lock all three so none of them are computed from 2500
        await toggleLock(tester, 'proteinTargetField');
        await toggleLock(tester, 'carbTargetField');
        await toggleLock(tester, 'fatTargetField');
        await enterInto(tester, 'proteinTargetField', '150');
        await enterInto(tester, 'carbTargetField', '200');
        await enterInto(tester, 'fatTargetField', '50');

        await scrollTo(tester, find.byKey(const Key('calculateTargetsButton')));
        await tester.tap(find.byKey(const Key('calculateTargetsButton')));
        await tester.pumpAndSettle();

        // (150*4) + (200*4) + (50*9) = 600 + 800 + 450 = 1850
        expect(fieldText(tester, 'calorieTargetField'), '1850');

        await flushDriftTimers(tester);
      },
    );
  });
}
