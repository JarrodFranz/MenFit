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
import 'package:menfit_app/features/nutrition/presentation/food_search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nutrition_day_screen_test.dart' show flushDriftTimers;

/// `/nutrition/add`'s "Recent" region: the shortcut that only exists while
/// the search box is empty (`presentation/food_search_screen.dart`'s class
/// doc), driven through the real picker rather than just the query
/// (`recent_foods_test.dart` already covers `getRecentFoods`/
/// `watchRecentFoods` at the repository and provider layers).
///
/// **Every body here ends with `await flushDriftTimers(tester)`, and it has
/// to be the last statement rather than a teardown** — same Drift-timer
/// discipline as `manage_foods_screen_test.dart`, for the same reason: these
/// tests pump the real `App`, which mounts screens watching live Drift
/// streams, and the pending-timer invariant is checked before any
/// `addTearDown` callback runs.
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
  );

  Food bagel() => Food(
    id: 'food-bagel',
    name: 'Bagel',
    servingDescription: '1 bagel',
    perServing: const NutritionFacts(
      caloriesKcal: 250,
      proteinGrams: 9,
      carbsGrams: 48,
      fatGrams: 1,
    ),
    createdAt: now,
    updatedAt: now,
  );

  /// Writes straight through the repository before the app is pumped, and
  /// disposes the container **inside** this helper rather than through
  /// `addTearDown` — a container still holding a Drift subscription when the
  /// pending-timer invariant is checked would fail the test it only meant to
  /// seed (same reasoning as `manage_foods_screen_test.dart#seed`).
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

  /// Saves both foods and logs each once, [bagel] most recently — so "most
  /// recent first" and "alphabetical would get this wrong" are both
  /// checkable from the same fixture.
  Future<void> seedTwoLoggedFoods() => seed((container) async {
    final repository = container.read(nutritionRepositoryProvider);
    await repository.saveFood(apple());
    await repository.saveFood(bagel());
    await repository.saveEntry(
      NutritionEntry.fromFood(
        id: 'entry-apple',
        day: today,
        meal: MealType.breakfast,
        food: apple(),
        amount: 1,
        now: now.subtract(const Duration(hours: 2)),
      ),
    );
    await repository.saveEntry(
      NutritionEntry.fromFood(
        id: 'entry-bagel',
        day: today,
        meal: MealType.breakfast,
        food: bagel(),
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

  /// Nutrition tab → breakfast's "Add food", which is `FoodSearchScreen`.
  Future<void> openPicker(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Nutrition'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addFood-breakfast')));
    await tester.pumpAndSettle();
    expect(find.byType(FoodSearchScreen), findsOneWidget);
  }

  testWidgets('lists both logged foods, most recent first', (tester) async {
    await seedTwoLoggedFoods();
    await pumpApp(tester);
    await openPicker(tester);

    expect(find.text('Recent'), findsOneWidget);
    final recentTop = tester.getTopLeft(
      find.byKey(const Key('recent-food-bagel')),
    );
    final recentBottom = tester.getTopLeft(
      find.byKey(const Key('recent-food-apple')),
    );
    // Bagel was logged more recently than Apple, so it must sit above it —
    // not the alphabetical order `searchFoods('')` would otherwise give the
    // picker.
    expect(recentTop.dy, lessThan(recentBottom.dy));

    await flushDriftTimers(tester);
  });

  testWidgets('typing hides the Recent section', (tester) async {
    await seedTwoLoggedFoods();
    await pumpApp(tester);
    await openPicker(tester);

    expect(find.text('Recent'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('foodSearchField')), 'bag');
    await tester.pumpAndSettle();

    expect(find.text('Recent'), findsNothing);
    expect(find.byKey(const Key('recent-food-bagel')), findsNothing);

    await flushDriftTimers(tester);
  });

  testWidgets(
    'the same food in both Recent and Your foods raises no duplicate-key '
    'exception',
    (tester) async {
      await seedTwoLoggedFoods();
      await pumpApp(tester);
      await openPicker(tester);

      // With the query blank, `searchFoods('')` lists the whole catalogue
      // (`domain/nutrition_repository.dart`), so both logged foods appear a
      // second time under "Your foods" — the exact situation a shared,
      // un-prefixed key between the two regions would collide on.
      expect(find.text('Your foods'), findsOneWidget);
      expect(find.byKey(const Key('recent-food-apple')), findsOneWidget);
      expect(find.byKey(const Key('recent-food-bagel')), findsOneWidget);
      expect(find.byKey(const ValueKey('food-apple')), findsOneWidget);
      expect(find.byKey(const ValueKey('food-bagel')), findsOneWidget);
      expect(tester.takeException(), isNull);

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'hide calorie numbers blanks the Recent tiles too',
    (tester) async {
      await seedTwoLoggedFoods();
      await saveGoals(
        NutritionGoals(
          id: 'goals-1',
          hideCalorieNumbers: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await pumpApp(tester);
      await openPicker(tester);

      expect(find.text('Recent'), findsOneWidget);
      // Nowhere on the picker — Recent included — does a calorie figure
      // render while the preference is on.
      expect(find.textContaining('kcal'), findsNothing);

      await flushDriftTimers(tester);
    },
  );

  testWidgets(
    'overflow menu contains quick add, create food, and manage foods',
    (tester) async {
      await pumpApp(tester);
      await openPicker(tester);

      expect(find.byKey(const Key('foodSearchOverflowAction')), findsOneWidget);
      await tester.tap(find.byKey(const Key('foodSearchOverflowAction')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('quickAddMenuItem')), findsOneWidget);
      expect(find.byKey(const Key('createFoodMenuItem')), findsOneWidget);
      expect(find.byKey(const Key('manageFoodsMenuItem')), findsOneWidget);

      await flushDriftTimers(tester);
    },
  );
}
