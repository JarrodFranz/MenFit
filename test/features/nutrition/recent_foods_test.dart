import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/data/drift_nutrition_repository.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';

/// "Recently logged" and "often logged" as *queries*: which foods come back,
/// in which order, and what is deliberately left out.
///
/// The picker was alphabetical before this, which is the wrong order for a
/// screen whose commonest job is logging the same breakfast again.
void main() {
  final today = LocalDate.today();
  final now = DateTime.now().toUtc();

  late db.AppDatabase database;
  late DriftNutritionRepository repository;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftNutritionRepository(database);
    addTearDown(database.close);
  });

  Food food(String id, String name) => Food(
    id: id,
    name: name,
    servingDescription: '1 serving',
    perServing: const NutritionFacts(
      caloriesKcal: 100,
      proteinGrams: 5,
      carbsGrams: 10,
      fatGrams: 2,
    ),
    createdAt: now,
    updatedAt: now,
  );

  /// An entry logged [minutesAgo] minutes ago. The log time is what
  /// "recent" is measured against, so every test states it explicitly
  /// rather than relying on insertion order.
  NutritionEntry entry({
    required String id,
    required String foodId,
    required int minutesAgo,
    LocalDate? day,
  }) {
    final at = now.subtract(Duration(minutes: minutesAgo));
    return NutritionEntry(
      id: id,
      day: day ?? today,
      meal: MealType.breakfast,
      foodId: foodId,
      foodName: 'whatever',
      quantityServings: 1,
      quantityAmount: 1,
      perServing: const NutritionFacts(
        caloriesKcal: 100,
        proteinGrams: 5,
        carbsGrams: 10,
        fatGrams: 2,
      ),
      createdAt: at,
      updatedAt: at,
    );
  }

  group('getRecentFoods', () {
    test('orders by the most recent entry, not by name', () async {
      await repository.saveFood(food('a', 'Apple'));
      await repository.saveFood(food('b', 'Bagel'));
      await repository.saveFood(food('c', 'Cheese'));
      // Alphabetical order would be Apple, Bagel, Cheese — the exact order
      // this query exists to stop producing.
      await repository.saveEntry(
        entry(id: 'e1', foodId: 'a', minutesAgo: 300),
      );
      await repository.saveEntry(
        entry(id: 'e2', foodId: 'c', minutesAgo: 5),
      );
      await repository.saveEntry(
        entry(id: 'e3', foodId: 'b', minutesAgo: 60),
      );

      final recent = await repository.getRecentFoods();
      expect(recent.map((f) => f.id), ['c', 'b', 'a']);
    });

    test('lists a food once, at its most recent logging', () async {
      await repository.saveFood(food('a', 'Apple'));
      await repository.saveFood(food('b', 'Bagel'));
      await repository.saveEntry(
        entry(id: 'e1', foodId: 'a', minutesAgo: 500),
      );
      await repository.saveEntry(
        entry(id: 'e2', foodId: 'a', minutesAgo: 2),
      );
      await repository.saveEntry(
        entry(id: 'e3', foodId: 'b', minutesAgo: 10),
      );

      final recent = await repository.getRecentFoods();
      expect(recent.map((f) => f.id), ['a', 'b']);
    });

    test('a soft-deleted food never comes back through its history', () async {
      await repository.saveFood(food('a', 'Apple'));
      await repository.saveEntry(
        entry(id: 'e1', foodId: 'a', minutesAgo: 1),
      );
      await repository.deleteFood('a');

      expect(await repository.getRecentFoods(), isEmpty);
      // The entry itself is untouched — the food is gone, the diary is not.
      expect(await repository.getEntriesFor(today), hasLength(1));
    });

    test('an entry with no food behind it contributes nothing', () async {
      // A quick add: real nutrition, no catalogue row to offer again.
      await repository.saveEntry(
        NutritionEntry(
          id: 'quick-1',
          day: today,
          meal: MealType.lunch,
          foodName: 'Lunch out',
          quantityServings: 1,
          quantityAmount: 1,
          perServing: const NutritionFacts(
            caloriesKcal: 600,
            proteinGrams: 20,
            carbsGrams: 70,
            fatGrams: 25,
          ),
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(await repository.getRecentFoods(), isEmpty);
    });

    test('a dangling foodId does not resurrect a food', () async {
      await repository.saveEntry(
        entry(id: 'e1', foodId: 'never-existed', minutesAgo: 1),
      );

      expect(await repository.getRecentFoods(), isEmpty);
    });

    test('honours the limit', () async {
      for (var i = 0; i < 5; i++) {
        await repository.saveFood(food('f$i', 'Food $i'));
        await repository.saveEntry(
          entry(id: 'e$i', foodId: 'f$i', minutesAgo: i),
        );
      }

      final recent = await repository.getRecentFoods(limit: 2);
      expect(recent.map((f) => f.id), ['f0', 'f1']);
    });

    test('a food that has never been logged is not recent', () async {
      await repository.saveFood(food('a', 'Apple'));

      expect(await repository.getRecentFoods(), isEmpty);
      // …but it is still in the catalogue.
      expect(await repository.searchFoods(''), hasLength(1));
    });
  });

  group('getFrequentFoods', () {
    test('orders by how often, not by how recently', () async {
      await repository.saveFood(food('a', 'Apple'));
      await repository.saveFood(food('b', 'Bagel'));
      // Bagel is the more recent, Apple the more frequent.
      await repository.saveEntry(
        entry(id: 'e1', foodId: 'a', minutesAgo: 400),
      );
      await repository.saveEntry(
        entry(id: 'e2', foodId: 'a', minutesAgo: 300),
      );
      await repository.saveEntry(
        entry(id: 'e3', foodId: 'a', minutesAgo: 200),
      );
      await repository.saveEntry(
        entry(id: 'e4', foodId: 'b', minutesAgo: 1),
      );

      expect(
        (await repository.getFrequentFoods()).map((f) => f.id),
        ['a', 'b'],
      );
      expect(
        (await repository.getRecentFoods()).map((f) => f.id),
        ['b', 'a'],
        reason: 'the two orderings must genuinely differ',
      );
    });

    test('counts only inside the window', () async {
      await repository.saveFood(food('a', 'Apple'));
      await repository.saveFood(food('b', 'Bagel'));
      // Apple was a habit two months ago; Bagel is one now.
      for (var i = 0; i < 3; i++) {
        await repository.saveEntry(
          entry(
            id: 'old-$i',
            foodId: 'a',
            minutesAgo: const Duration(days: 60).inMinutes + i,
          ),
        );
      }
      await repository.saveEntry(
        entry(id: 'new-1', foodId: 'b', minutesAgo: 30),
      );

      expect(
        (await repository.getFrequentFoods()).map((f) => f.id),
        ['b'],
      );
    });

    test('honours the limit', () async {
      for (var i = 0; i < 4; i++) {
        await repository.saveFood(food('f$i', 'Food $i'));
        // i+1 entries each, so the count order is f3, f2, f1, f0.
        for (var n = 0; n <= i; n++) {
          await repository.saveEntry(
            entry(id: 'e$i-$n', foodId: 'f$i', minutesAgo: n + 1),
          );
        }
      }

      final frequent = await repository.getFrequentFoods(limit: 2);
      expect(frequent.map((f) => f.id), ['f3', 'f2']);
    });
  });

  group('watchRecentFoods / recentFoodsProvider', () {
    test('the stream re-emits when a food is logged', () async {
      await repository.saveFood(food('a', 'Apple'));

      final emissions = <List<Food>>[];
      // Cancelled inside the body, not via `addTearDown`: a live Drift
      // subscription outliving the body is what leaves drift's stream-cleanup
      // timer pending, and a teardown runs too late to help.
      final subscription = repository.watchRecentFoods().listen(emissions.add);
      try {
        await pumpEventQueue();
        expect(emissions.last, isEmpty);

        await repository.saveEntry(
          entry(id: 'e1', foodId: 'a', minutesAgo: 1),
        );
        await pumpEventQueue();

        expect(emissions.last.map((f) => f.id), ['a']);
      } finally {
        await subscription.cancel();
      }
    });

    /// The bug this guards against is specific and has been shipped before
    /// in this codebase: a one-shot future provider does not notice a food
    /// logged behind its back, so the picker keeps offering a stale
    /// "Recent" list until something else rebuilds it.
    test('the provider refreshes when an entry is written', () async {
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );

      final repository = container.read(nutritionRepositoryProvider);
      await repository.saveFood(food('a', 'Apple'));

      Future<List<Food>> waitForRecent(
        bool Function(List<Food>) predicate,
      ) async {
        final completer = Completer<List<Food>>();
        final subscription = container.listen(recentFoodsProvider, (
          previous,
          next,
        ) {
          final value = next.value;
          if (value != null && predicate(value) && !completer.isCompleted) {
            completer.complete(value);
          }
        }, fireImmediately: true);
        try {
          return await completer.future.timeout(const Duration(seconds: 5));
        } finally {
          subscription.close();
        }
      }

      try {
        expect(await waitForRecent((foods) => foods.isEmpty), isEmpty);

        await repository.saveEntry(
          entry(id: 'e1', foodId: 'a', minutesAgo: 1),
        );

        final refreshed = await waitForRecent((foods) => foods.isNotEmpty);
        expect(refreshed.single.id, 'a');
      } finally {
        // Disposed here rather than in a teardown: the container holds the
        // provider's live Drift subscription, and the body is where it has
        // to stop.
        container.dispose();
      }
    });
  });
}
