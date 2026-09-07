import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';

final LocalDate _day = LocalDate(2026, 8, 20);
final DateTime _now = DateTime.utc(2026, 8, 20, 9);

NutritionEntry _entry({
  required String id,
  required MealType meal,
  required double quantityServings,
  double caloriesKcal = 100,
  double proteinGrams = 10,
  double carbsGrams = 20,
  double fatGrams = 5,
  double? ironMg,
}) {
  return NutritionEntry(
    id: id,
    day: _day,
    meal: meal,
    foodName: 'Food $id',
    quantityServings: quantityServings,
    // These totals are about the multiplier only; every entry here was
    // logged in servings, so the amount is the same number.
    quantityAmount: quantityServings,
    perServing: NutritionFacts(
      caloriesKcal: caloriesKcal,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      fatGrams: fatGrams,
      ironMg: ironMg,
    ),
    createdAt: _now,
    updatedAt: _now,
  );
}

void main() {
  group('computeDayTotals', () {
    test('an empty day totals to zero, with an empty slice per meal', () {
      final totals = computeDayTotals([]);

      expect(totals.total.caloriesKcal, 0);
      expect(totals.total.proteinGrams, 0);
      expect(totals.total.carbsGrams, 0);
      expect(totals.total.fatGrams, 0);
      expect(totals.total.entryCount, 0);
      expect(totals.total.isEmpty, isTrue);
      expect(
        totals.total.ironMg,
        isNull,
        reason: 'no entry stated iron, so the day has no iron figure at all',
      );
      expect(
        totals.total.ironIsPartial,
        isFalse,
        reason: 'nothing is missing from a total of nothing',
      );

      expect(totals.byMeal.keys, containsAll(MealType.values));
      for (final meal in MealType.values) {
        expect(totals.byMeal[meal]!.entryCount, 0, reason: meal.name);
      }
    });

    test('quantity scales an entry: 2.5 servings multiplies every field', () {
      final totals = computeDayTotals([
        _entry(
          id: 'a',
          meal: MealType.breakfast,
          quantityServings: 2.5,
          ironMg: 2,
        ),
      ]);

      expect(totals.total.caloriesKcal, 250);
      expect(totals.total.proteinGrams, 25);
      expect(totals.total.carbsGrams, 50);
      expect(totals.total.fatGrams, 12.5);
      expect(totals.total.ironMg, 5);
      expect(totals.total.entryCount, 1);
    });

    test('sums across meals, and subtotals each meal separately', () {
      final totals = computeDayTotals([
        _entry(id: 'a', meal: MealType.breakfast, quantityServings: 1),
        _entry(id: 'b', meal: MealType.breakfast, quantityServings: 2),
        _entry(id: 'c', meal: MealType.dinner, quantityServings: 3),
      ]);

      expect(totals.total.caloriesKcal, 600);
      expect(totals.total.proteinGrams, 60);
      expect(totals.total.entryCount, 3);

      expect(totals.byMeal[MealType.breakfast]!.caloriesKcal, 300);
      expect(totals.byMeal[MealType.breakfast]!.entryCount, 2);
      expect(totals.byMeal[MealType.dinner]!.caloriesKcal, 300);
      expect(totals.byMeal[MealType.dinner]!.entryCount, 1);
      expect(
        totals.byMeal[MealType.lunch]!.entryCount,
        0,
        reason: 'every meal gets a slice, even the ones with nothing in them',
      );
      expect(totals.byMeal[MealType.lunch]!.caloriesKcal, 0);
    });

    test(
      'per-meal subtotals sum back to the day total (no entry lost or '
      'double-counted)',
      () {
        final entries = [
          _entry(id: 'a', meal: MealType.breakfast, quantityServings: 1),
          _entry(id: 'b', meal: MealType.lunch, quantityServings: 1.5),
          _entry(id: 'c', meal: MealType.dinner, quantityServings: 2),
          _entry(id: 'd', meal: MealType.snack, quantityServings: 0.5),
        ];
        final totals = computeDayTotals(entries);

        final mealSum = totals.byMeal.values.fold<double>(
          0,
          (sum, meal) => sum + meal.caloriesKcal,
        );
        final mealCount = totals.byMeal.values.fold<int>(
          0,
          (sum, meal) => sum + meal.entryCount,
        );
        expect(mealSum, closeTo(totals.total.caloriesKcal, 1e-9));
        expect(mealCount, totals.total.entryCount);
        expect(mealCount, entries.length);
      },
    );

    group('iron honesty', () {
      test(
        'a day where every entry states iron reports a complete total',
        () {
          final totals = computeDayTotals([
            _entry(
              id: 'a',
              meal: MealType.breakfast,
              quantityServings: 1,
              ironMg: 3,
            ),
            _entry(
              id: 'b',
              meal: MealType.dinner,
              quantityServings: 2,
              ironMg: 1,
            ),
          ]);

          expect(totals.total.ironMg, 5);
          expect(totals.total.ironIsPartial, isFalse);
        },
      );

      test(
        'one entry without iron makes the total partial, and the known part '
        'is still reported rather than collapsing to null',
        () {
          final totals = computeDayTotals([
            _entry(
              id: 'a',
              meal: MealType.breakfast,
              quantityServings: 1,
              ironMg: 3,
            ),
            _entry(id: 'b', meal: MealType.dinner, quantityServings: 1),
          ]);

          expect(totals.total.ironMg, 3);
          expect(
            totals.total.ironIsPartial,
            isTrue,
            reason: 'a food that never stated iron must not be read as zero',
          );
        },
      );

      test(
        'partial-ness is tracked per meal, not smeared across the whole day',
        () {
          final totals = computeDayTotals([
            _entry(
              id: 'a',
              meal: MealType.breakfast,
              quantityServings: 1,
              ironMg: 3,
            ),
            _entry(id: 'b', meal: MealType.dinner, quantityServings: 1),
          ]);

          expect(totals.byMeal[MealType.breakfast]!.ironIsPartial, isFalse);
          expect(totals.byMeal[MealType.breakfast]!.ironMg, 3);
          expect(totals.byMeal[MealType.dinner]!.ironIsPartial, isTrue);
          expect(totals.byMeal[MealType.dinner]!.ironMg, isNull);
          expect(totals.total.ironIsPartial, isTrue);
        },
      );

      test('a day where nothing states iron reports no iron figure', () {
        final totals = computeDayTotals([
          _entry(id: 'a', meal: MealType.breakfast, quantityServings: 1),
        ]);

        expect(totals.total.ironMg, isNull);
        expect(totals.total.ironIsPartial, isTrue);
      });
    });
  });

  group('NutritionFacts', () {
    test('scaling unknown iron keeps it unknown, never zero', () {
      const facts = NutritionFacts(caloriesKcal: 100, proteinGrams: 5);
      final scaled = facts.scaled(3);

      expect(scaled.caloriesKcal, 300);
      expect(scaled.proteinGrams, 15);
      expect(scaled.ironMg, isNull);
      expect(scaled.hasIron, isFalse);
    });

    test('zero is the identity for plus', () {
      const facts = NutritionFacts(
        caloriesKcal: 120,
        proteinGrams: 8,
        carbsGrams: 14,
        fatGrams: 3,
        ironMg: 1.2,
      );
      expect(NutritionFacts.zero.plus(facts), facts);
      expect(facts.plus(NutritionFacts.zero), facts);
    });
  });

  group('the optional nutrients added in schema v21', () {
    NutritionEntry entryWithFibre({
      required String id,
      required double? fiberGrams,
      double quantityServings = 1,
    }) {
      return NutritionEntry(
        id: id,
        day: _day,
        meal: MealType.breakfast,
        foodName: 'Food $id',
        quantityServings: quantityServings,
        quantityAmount: quantityServings,
        perServing: NutritionFacts(
          caloriesKcal: 100,
          proteinGrams: 10,
          carbsGrams: 20,
          fatGrams: 5,
          fiberGrams: fiberGrams,
        ),
        createdAt: _now,
        updatedAt: _now,
      );
    }

    test('a day with two fibre-bearing entries sums their fibre', () {
      final totals = computeDayTotals([
        entryWithFibre(id: 'a', fiberGrams: 3),
        entryWithFibre(id: 'b', fiberGrams: 4.5, quantityServings: 2),
      ]);

      expect(totals.total.facts.fiberGrams, 12);
      expect(totals.byMeal[MealType.breakfast]!.facts.fiberGrams, 12);
    });

    test('one unstated fibre plus 5 g totals 5 g, not an error', () {
      // The "sum is a floor, not a guess" rule: unknown contributes nothing
      // rather than collapsing the total to unknown.
      final totals = computeDayTotals([
        entryWithFibre(id: 'a', fiberGrams: null),
        entryWithFibre(id: 'b', fiberGrams: 5),
      ]);

      expect(totals.total.facts.fiberGrams, 5);
    });

    test('a day where nobody stated fibre totals null, not zero', () {
      final totals = computeDayTotals([
        entryWithFibre(id: 'a', fiberGrams: null),
        entryWithFibre(id: 'b', fiberGrams: null),
      ]);

      expect(totals.total.facts.fiberGrams, isNull);
    });

    test('the range daily average carries them too', () {
      // `computeRangeNutritionTotals` builds its average by hand rather than
      // through `plus`, so it is the one place a new nutrient can be dropped
      // silently.
      final range = computeRangeNutritionTotals(
        entries: [
          entryWithFibre(id: 'a', fiberGrams: 3),
          entryWithFibre(id: 'b', fiberGrams: 4),
        ],
        daysInRange: 2,
      );

      expect(range.total.facts.fiberGrams, 7);
      expect(range.dailyAverage.facts.fiberGrams, 3.5);
    });

    test('an unstated nutrient averages to null, never to zero', () {
      final range = computeRangeNutritionTotals(
        entries: [entryWithFibre(id: 'a', fiberGrams: null)],
        daysInRange: 7,
      );

      expect(range.dailyAverage.facts.fiberGrams, isNull);
      expect(range.dailyAverage.facts.sodiumMg, isNull);
    });

    test(
      'micronutrient partial flags reflect missing nutrients in entries',
      () {
        final totals = computeDayTotals([
          NutritionEntry(
            id: '1',
            day: _day,
            meal: MealType.breakfast,
            foodName: 'Food 1',
            quantityServings: 1,
            quantityAmount: 1,
            perServing: const NutritionFacts(
              caloriesKcal: 100,
              ironMg: 5,
              vitaminDMcg: 10,
              vitaminCMg: 30,
            ),
            createdAt: _now,
            updatedAt: _now,
          ),
          NutritionEntry(
            id: '2',
            day: _day,
            meal: MealType.breakfast,
            foodName: 'Food 2',
            quantityServings: 1,
            quantityAmount: 1,
            perServing: const NutritionFacts(
              caloriesKcal: 150,
              ironMg: 3,
              calciumMg: 300,
              fiberGrams: 5,
              potassiumMg: 400,
            ),
            createdAt: _now,
            updatedAt: _now,
          ),
        ]);

        expect(totals.total.ironIsPartial, isFalse);
        expect(totals.total.calciumIsPartial, isTrue);
        expect(totals.total.vitaminDIsPartial, isTrue);
        expect(totals.total.fiberIsPartial, isTrue);
        expect(totals.total.vitaminCIsPartial, isTrue);
        expect(totals.total.potassiumIsPartial, isTrue);
        expect(totals.total.ironMg, 8);
        expect(totals.total.calciumMg, 300);
        expect(totals.total.vitaminDMcg, 10);
        expect(totals.total.fiberGrams, 5);
        expect(totals.total.vitaminCMg, 30);
        expect(totals.total.potassiumMg, 400);
      },
    );
  });
}
