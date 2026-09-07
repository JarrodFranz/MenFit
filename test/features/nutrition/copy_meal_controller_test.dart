import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_repository.dart';
import 'package:menfit_app/features/nutrition/domain/quantity_unit.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/copy_meal_controller.dart';

/// "Copy from yesterday": what moves, what doesn't, and when it isn't
/// offered at all.
void main() {
  final today = LocalDate.today();
  final yesterday = today.addDays(-1);
  final now = DateTime.utc(2026, 9, 1, 8);

  late db.AppDatabase database;
  late ProviderContainer container;
  late NutritionRepository repository;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    repository = container.read(nutritionRepositoryProvider);
    addTearDown(container.dispose);
    addTearDown(database.close);
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

  Future<int> copy(LocalDate day, MealType meal) {
    return container
        .read(copyMealControllerProvider(day, meal).notifier)
        .copyFromPreviousDay();
  }

  test('copies every entry of that meal onto the selected day', () async {
    final food = oats();
    await repository.saveFood(food);
    await repository.saveEntry(
      NutritionEntry.fromFood(
        id: 'y1',
        day: yesterday,
        meal: MealType.breakfast,
        food: food,
        amount: 1.5,
        now: now,
      ),
    );
    await repository.saveEntry(
      NutritionEntry.fromFood(
        id: 'y2',
        day: yesterday,
        meal: MealType.breakfast,
        food: food,
        amount: 120,
        unit: QuantityUnit.gram,
        now: now,
      ),
    );

    expect(await copy(today, MealType.breakfast), 2);

    final copied = await repository.getEntriesFor(today);
    expect(copied, hasLength(2));
    expect(copied.every((e) => e.meal == MealType.breakfast), isTrue);
    // New rows, not moved ones.
    expect(copied.map((e) => e.id), isNot(contains('y1')));
    expect(copied.map((e) => e.id), isNot(contains('y2')));
    expect(copied.map((e) => e.id).toSet(), hasLength(2));
  });

  test('the snapshot and the quantity travel exactly as they were', () async {
    final food = oats();
    await repository.saveFood(food);
    await repository.saveEntry(
      NutritionEntry.fromFood(
        id: 'y1',
        day: yesterday,
        meal: MealType.lunch,
        food: food,
        amount: 120,
        unit: QuantityUnit.gram,
        now: now,
      ),
    );

    await copy(today, MealType.lunch);

    final source = (await repository.getEntriesFor(yesterday)).single;
    final copied = (await repository.getEntriesFor(today)).single;
    expect(copied.quantityAmount, source.quantityAmount);
    expect(copied.quantityUnit, source.quantityUnit);
    expect(copied.quantityServings, source.quantityServings);
    expect(copied.servingGrams, source.servingGrams);
    expect(copied.perServing, source.perServing);
    expect(copied.foodId, source.foodId);
    expect(copied.foodName, source.foodName);
    expect(copied.foodBrand, source.foodBrand);
    expect(copied.servingDescription, source.servingDescription);
    // The whole reason the snapshot travels: the copy contributes the same
    // nutrition the original did.
    expect(copied.facts.caloriesKcal, source.facts.caloriesKcal);
  });

  test("copying edits nothing on yesterday's rows", () async {
    final food = oats();
    await repository.saveFood(food);
    await repository.saveEntry(
      NutritionEntry.fromFood(
        id: 'y1',
        day: yesterday,
        meal: MealType.dinner,
        food: food,
        amount: 2,
        now: now,
      ),
    );
    final before = await repository.getEntriesFor(yesterday);

    await copy(today, MealType.dinner);

    final after = await repository.getEntriesFor(yesterday);
    expect(after, hasLength(1));
    expect(after.single.id, 'y1');
    expect(after.single.day, yesterday);
    expect(after.single.quantityServings, before.single.quantityServings);
  });

  test('copies only the meal asked for', () async {
    final food = oats();
    await repository.saveFood(food);
    for (final meal in [MealType.breakfast, MealType.dinner]) {
      await repository.saveEntry(
        NutritionEntry.fromFood(
          id: 'y-${meal.name}',
          day: yesterday,
          meal: meal,
          food: food,
          amount: 1,
          now: now,
        ),
      );
    }

    expect(await copy(today, MealType.breakfast), 1);

    final copied = await repository.getEntriesFor(today);
    expect(copied, hasLength(1));
    expect(copied.single.meal, MealType.breakfast);
  });

  test('is a no-op when the previous day has nothing for that meal', () async {
    expect(await copy(today, MealType.snack), 0);
    expect(await repository.getEntriesFor(today), isEmpty);
  });

  test('copies a quick-add entry, which has no food behind it', () async {
    await repository.saveEntry(
      NutritionEntry(
        id: 'y-quick',
        day: yesterday,
        meal: MealType.snack,
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

    expect(await copy(today, MealType.snack), 1);
    final copied = (await repository.getEntriesFor(today)).single;
    expect(copied.foodId, isNull);
    expect(copied.foodName, 'Lunch out');
    expect(copied.facts.caloriesKcal, 600);
  });

  test('copies an entry whose food has since been deleted', () async {
    final food = oats();
    await repository.saveFood(food);
    await repository.saveEntry(
      NutritionEntry.fromFood(
        id: 'y1',
        day: yesterday,
        meal: MealType.breakfast,
        food: food,
        amount: 1,
        now: now,
      ),
    );
    await repository.deleteFood(food.id);

    expect(await copy(today, MealType.breakfast), 1);
    // The snapshot is what makes this possible — nothing re-reads the food.
    final copied = (await repository.getEntriesFor(today)).single;
    expect(copied.foodName, 'Porridge oats');
    expect(copied.perServing.caloriesKcal, 300);
  });

  group('copyableMeals', () {
    Future<Set<MealType>> waitForMeals(
      LocalDate day,
      bool Function(Set<MealType>) predicate,
    ) async {
      final completer = Completer<Set<MealType>>();
      final subscription = container.listen(copyableMealsProvider(day), (
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

    test('names exactly the meals the previous day has', () async {
      final food = oats();
      await repository.saveFood(food);
      await repository.saveEntry(
        NutritionEntry.fromFood(
          id: 'y1',
          day: yesterday,
          meal: MealType.breakfast,
          food: food,
          amount: 1,
          now: now,
        ),
      );

      final meals = await waitForMeals(today, (m) => m.isNotEmpty);
      expect(meals, {MealType.breakfast});
    });

    test('is empty when the previous day is empty', () async {
      expect(await waitForMeals(today, (m) => true), isEmpty);
    });

    test('is empty for a day in the future, whatever came before it', () async {
      final food = oats();
      await repository.saveFood(food);
      await repository.saveEntry(
        NutritionEntry.fromFood(
          id: 't1',
          day: today,
          meal: MealType.breakfast,
          food: food,
          amount: 1,
          now: now,
        ),
      );

      // Today has breakfast, so tomorrow would otherwise be offered it.
      expect(await waitForMeals(today.addDays(1), (m) => true), isEmpty);
    });
  });
}
