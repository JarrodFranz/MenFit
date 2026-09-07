import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/app/app.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_screen.dart';
import 'package:menfit_app/features/nutrition/presentation/manage_foods_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nutrition_day_screen_test.dart' show flushDriftTimers;

/// `/nutrition/foods` — the screen that finally gives `deleteFood` a caller,
/// reached the way a user reaches it: picker → overflow → Manage foods.
///
/// **Every body here ends with `await flushDriftTimers(tester)`, and it has
/// to be the last statement rather than a teardown.** These tests pump the
/// real `App`, which mounts screens watching Drift streams (and `streaks`'
/// `localDay`, which holds a timer until midnight);
/// `TestWidgetsFlutterBinding._runTestBody` checks the pending-timer
/// invariant the moment the body returns and *before* any `addTearDown`
/// callback runs, so a flush registered as a teardown is too late by
/// construction. The teardown copy in `pumpApp` stays anyway: it cannot stop
/// the assertion, but it keeps a forgotten call from wedging every later
/// test in the file (`test/features/weight/weight_test_vocabulary.dart`
/// documents both halves).
void main() {
  final now = DateTime.utc(2026, 9, 1, 8);
  final today = LocalDate.today();

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

  Food oats() => Food(
    id: 'food-oats',
    name: 'Porridge oats',
    brand: 'Quaker',
    servingDescription: '1 cup (dry)',
    servingGrams: 80,
    perServing: const NutritionFacts(
      caloriesKcal: 300,
      proteinGrams: 10,
      carbsGrams: 54,
      fatGrams: 5,
      ironMg: 3,
    ),
    createdAt: now,
    updatedAt: now,
  );

  Food apple() => Food(
    id: 'food-apple',
    name: 'Apple',
    servingDescription: '1 medium',
    perServing: const NutritionFacts(
      caloriesKcal: 95,
      proteinGrams: 1,
      carbsGrams: 25,
    ),
    createdAt: now,
    updatedAt: now,
    source: FoodSource.openFoodFacts,
  );

  /// Writes straight through the repository before the app is pumped.
  ///
  /// The container is disposed **inside** this helper rather than through
  /// `addTearDown`, for the same reason the flush is a last statement: a
  /// teardown runs after the pending-timer invariant has already been
  /// checked, so a container still holding a Drift subscription then would
  /// fail the test it only meant to seed.
  Future<void> seed(Future<void> Function(ProviderContainer) body) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    try {
      await body(container);
    } finally {
      container.dispose();
    }
  }

  Future<void> saveFoods(List<Food> foods) => seed((container) async {
    final repository = container.read(nutritionRepositoryProvider);
    for (final food in foods) {
      await repository.saveFood(food);
    }
  });

  Future<void> logOats() => seed((container) async {
    final repository = container.read(nutritionRepositoryProvider);
    await repository.saveEntry(
      NutritionEntry.fromFood(
        id: 'entry-1',
        day: today,
        meal: MealType.breakfast,
        food: oats(),
        amount: 1,
        now: now,
      ),
    );
  });

  Future<void> saveGoals(NutritionGoals goals) => seed(
    (container) =>
        container.read(nutritionGoalsRepositoryProvider).saveGoals(goals),
  );

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(500, 1600)
      ..devicePixelRatio = 1;
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();
    // Containment only — see the library doc. The bodies do the real flush.
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
  }

  /// Nutrition tab → a meal's "Add food" → the picker's overflow → here.
  /// Walked rather than deep-linked, because the entry point is half of
  /// what this screen needed to exist.
  Future<void> openManageFoods(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Nutrition'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addFood-breakfast')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('foodSearchOverflowAction')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('manageFoodsMenuItem')));
    await tester.pumpAndSettle();
  }

  Future<void> settleRealAsync(WidgetTester tester) async {
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  testWidgets('the picker overflow reaches it, and it lists the catalogue', (
    tester,
  ) async {
    await saveFoods([oats(), apple()]);
    await pumpApp(tester);
    await openManageFoods(tester);

    expect(find.byType(ManageFoodsScreen), findsOneWidget);
    expect(find.text('Porridge oats · Quaker'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    // Provenance is meaningful under ADR 010, so it is on the row.
    expect(find.text('Yours'), findsOneWidget);
    expect(find.text('Open Food Facts'), findsOneWidget);
    expect(find.text('300 kcal'), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('searching filters the list', (tester) async {
    await saveFoods([oats(), apple()]);
    await pumpApp(tester);
    await openManageFoods(tester);

    await tester.enterText(
      find.byKey(const Key('manageFoodsSearchField')),
      'quak',
    );
    await tester.pumpAndSettle();

    // Matched on brand, not just name.
    expect(find.text('Porridge oats · Quaker'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('manageFoodsSearchField')),
      'zzz',
    );
    await tester.pumpAndSettle();
    expect(find.text('Nothing here matches that.'), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('removing asks first, and cancelling changes nothing', (
    tester,
  ) async {
    await saveFoods([oats()]);
    await pumpApp(tester);
    await openManageFoods(tester);

    await tester.tap(find.byKey(const Key('removeFood-food-oats')));
    await tester.pumpAndSettle();

    expect(find.text('Remove Porridge oats · Quaker?'), findsOneWidget);
    // The promise the confirmation makes, and the reason it is safe to make
    // it: entries hold their own snapshot.
    expect(
      find.textContaining('Anything already in your diary keeps its own'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Porridge oats · Quaker'), findsOneWidget);
    expect(await database.select(database.foods).get(), hasLength(1));

    await flushDriftTimers(tester);
  });

  testWidgets('confirming soft-deletes the food and leaves the diary alone', (
    tester,
  ) async {
    await saveFoods([oats()]);
    await logOats();
    await pumpApp(tester);
    await openManageFoods(tester);

    await tester.tap(find.byKey(const Key('removeFood-food-oats')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmRemoveFoodButton')));
    await settleRealAsync(tester);

    expect(find.text('Porridge oats · Quaker'), findsNothing);
    expect(
      find.textContaining("You haven't saved any foods yet"),
      findsOneWidget,
    );

    // Confirms what happened, in the same ED-neutral voice as the
    // confirmation dialog it followed.
    expect(
      find.text('Removed. Past diary entries keep their details.'),
      findsOneWidget,
    );

    // Soft, not hard: the row survives with `deleted_at` stamped.
    final rows = await database.select(database.foods).get();
    expect(rows, hasLength(1));
    expect(rows.single.deletedAt, isNotNull);

    // And the entry logged from it is completely untouched.
    final entries = await database.select(database.nutritionEntries).get();
    expect(entries, hasLength(1));
    expect(entries.single.foodName, 'Porridge oats');
    expect(entries.single.caloriesKcal, 300.0);

    await flushDriftTimers(tester);
  });

  testWidgets('tapping a food opens the form, seeded from it', (tester) async {
    await saveFoods([oats()]);
    await pumpApp(tester);
    await openManageFoods(tester);

    await tester.tap(find.text('Porridge oats · Quaker'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodFormScreen), findsOneWidget);
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(const Key('foodNameField')),
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text,
      'Porridge oats',
    );

    await flushDriftTimers(tester);
  });

  testWidgets('hide calorie numbers blanks every energy figure here', (
    tester,
  ) async {
    await saveFoods([oats(), apple()]);
    await saveGoals(
      NutritionGoals(
        id: 'goals-1',
        hideCalorieNumbers: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await pumpApp(tester);
    await openManageFoods(tester);

    expect(find.textContaining('kcal'), findsNothing);
    // The macro lines stay — grams are not calories.
    expect(find.textContaining('P 10 g'), findsOneWidget);

    await flushDriftTimers(tester);
  });
}
