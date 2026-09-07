import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/presentation/widgets/day_totals_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nutrition/nutrition_day_screen_test.dart'
    show flushDriftTimers, mealSection, scrollTo;

void main() {
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.implicitView?.resetPhysicalSize();
    binding.platformDispatcher.implicitView?.resetDevicePixelRatio();
  });

  Future<db.AppDatabase> pumpApp(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(500, 1400)
      ..devicePixelRatio = 1;

    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();
    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    // Registered AFTER database.close so it runs BEFORE it (teardowns are
    // LIFO), and registered here rather than called at the end of the test
    // body so it still runs when a test FAILS — otherwise live Drift stream
    // timers wedge the rest of the suite (`test/features/routes_flow_test.dart`).
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

  /// Lets UI-triggered Drift writes finish outside the fake-async zone, then
  /// pumps for the resulting UI (central testing-pitfalls.md).
  Future<void> settleRealAsync(WidgetTester tester) async {
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  Future<void> goToNutrition(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Nutrition'),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fillFoodForm(WidgetTester tester) async {
    Future<void> enter(String key, String value) async {
      await scrollTo(tester, find.byKey(Key(key)));
      await tester.enterText(find.byKey(Key(key)), value);
      await tester.pump();
    }

    await enter('foodNameField', 'Porridge oats');
    await enter('servingDescriptionField', '1 cup (dry)');
    await enter('caloriesField', '300');
    await enter('proteinField', '10');
    await enter('carbsField', '54');
    await enter('fatField', '5');

    final expansion = find.byKey(const Key('additionalNutrientsTile'));
    await scrollTo(tester, expansion);
    await tester.tap(expansion);
    await tester.pumpAndSettle();
    await enter('ironField', '3');
  }

  testWidgets(
    'signature flow: empty diary -> create a custom food (invalid first) -> '
    'log two servings into breakfast -> the meal subtotal and the day totals '
    'both move',
    (tester) async {
      final database = await pumpApp(tester);
      await goToNutrition(tester);

      expect(
        find.textContaining('Nothing in the diary for this day'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('addFood-breakfast')));
      await tester.pumpAndSettle();

      // Nothing in the catalogue yet: the empty state is where "create a
      // food" has to be, because this is the moment it's needed.
      expect(
        find.textContaining('Nothing here matches that yet'),
        findsOneWidget,
      );
      await tester.tap(find.text('Create a new food'));
      await tester.pumpAndSettle();
      expect(find.text('New food'), findsOneWidget);

      // Saving an empty form reports every field and writes nothing.
      await scrollTo(tester, find.text('Save food'));
      await tester.tap(find.text('Save food'));
      await settleRealAsync(tester);

      await scrollTo(tester, find.textContaining('Give this food a name'));
      expect(find.textContaining('Give this food a name'), findsOneWidget);
      // Calories, protein, carbs and fat are required; optional nutrients
      // and grams per serving are not, and are silent.
      expect(find.text('Add a number here (0 is fine).'), findsNWidgets(4));
      expect(await database.select(database.foods).get(), isEmpty);

      await fillFoodForm(tester);
      await scrollTo(tester, find.text('Save food'));
      await tester.tap(find.text('Save food'));
      await settleRealAsync(tester);

      // Back on the picker, with the log dialog already open on the food
      // just created.
      expect(find.text('Add to your day'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('300 kcal'),
        ),
        findsOneWidget,
      );

      await tester.enterText(find.byKey(const Key('quantityField')), '2');
      await tester.pump();
      // The quantity's nutrition is shown before anything is committed.
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('600 kcal'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('P 20 g · C 108 g · F 10 g'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Iron 6.0 mg'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Add'));
      await settleRealAsync(tester);

      // Dialog and picker are both gone; we're back on the diary.
      expect(find.text('Add to your day'), findsNothing);
      expect(find.text('Nutrition'), findsWidgets);

      final rows = await database.select(database.nutritionEntries).get();
      expect(rows, hasLength(1));
      expect(rows.single.meal, 'breakfast');
      expect(rows.single.quantityServings, 2);
      // The entry snapshots the food's nutrition rather than pointing at it.
      expect(rows.single.caloriesKcal, 300);

      expect(
        find.descendant(
          of: find.byType(DayTotalsCard),
          matching: find.text('600 kcal'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: mealSection(MealType.breakfast),
          matching: find.text('600 kcal'),
        ),
        findsNWidgets(2),
      );
      expect(
        find.descendant(
          of: mealSection(MealType.dinner),
          matching: find.textContaining('kcal'),
        ),
        findsNothing,
      );

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'editing a logged entry restates the day; deleting it empties the day '
    'and the table',
    (tester) async {
      final database = await pumpApp(tester);
      await goToNutrition(tester);

      // Log one entry through the UI so the edit path starts from a real row.
      await tester.tap(find.byKey(const Key('addFood-lunch')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create a new food'));
      await tester.pumpAndSettle();
      await fillFoodForm(tester);
      await scrollTo(tester, find.text('Save food'));
      await tester.tap(find.text('Save food'));
      await settleRealAsync(tester);
      await tester.enterText(find.byKey(const Key('quantityField')), '2');
      await tester.pump();
      await tester.tap(find.text('Add'));
      await settleRealAsync(tester);

      // Edit: halve the quantity.
      await scrollTo(tester, find.text('Porridge oats'));
      await tester.tap(find.text('Porridge oats'));
      await tester.pumpAndSettle();
      expect(find.text('Edit this entry'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('quantityField')), '1');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await settleRealAsync(tester);

      await scrollTo(tester, find.byType(DayTotalsCard));
      expect(
        find.descendant(
          of: find.byType(DayTotalsCard),
          matching: find.text('300 kcal'),
        ),
        findsOneWidget,
      );
      final edited = await database.select(database.nutritionEntries).get();
      expect(edited.single.quantityServings, 1);

      // Delete: the day goes back to its empty state, and the row is really
      // gone (a food diary's delete is a hard delete — see
      // `domain/nutrition_repository.dart#deleteEntry`).
      await scrollTo(tester, find.text('Porridge oats'));
      await tester.tap(find.text('Porridge oats'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await settleRealAsync(tester);

      await scrollTo(
        tester,
        find.textContaining('Nothing in the diary for this day'),
      );
      expect(
        find.textContaining('Nothing in the diary for this day'),
        findsOneWidget,
      );
      expect(await database.select(database.nutritionEntries).get(), isEmpty);
      // The food itself stays in the catalogue, ready to log again.
      expect(await database.select(database.foods).get(), hasLength(1));

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'the goals screen is reachable from the diary, and turning on hide '
    'calorie numbers empties every calorie figure out of the diary',
    (tester) async {
      await pumpApp(tester);
      await goToNutrition(tester);

      await tester.tap(find.byTooltip('Nutrition goals'));
      await tester.pumpAndSettle();
      expect(find.text('Nutrition goals'), findsWidgets);

      await scrollTo(tester, find.byKey(const Key('hideCaloriesSwitch')));
      await tester.tap(find.byKey(const Key('hideCaloriesSwitch')));
      await settleRealAsync(tester);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.textContaining('kcal'), findsNothing);

      await flushDriftTimers(tester);
    },
  );
}
