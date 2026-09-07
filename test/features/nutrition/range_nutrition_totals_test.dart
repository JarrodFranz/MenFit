import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';

void main() {
  group('computeRangeNutritionTotals', () {
    test('returns empty range totals when entries are empty', () {
      final totals = computeRangeNutritionTotals(
        entries: const [],
        daysInRange: 7,
      );

      expect(totals.daysInRange, equals(7));
      expect(totals.daysWithEntries, equals(0));
      expect(totals.total.caloriesKcal, equals(0));
      expect(totals.dailyAverage.caloriesKcal, equals(0));
      expect(totals.byDay, isEmpty);
    });

    test(
      'aggregates multiple entries across days and calculates daily averages',
      () {
        final day1 = LocalDate(2026, 8, 20);
        final day2 = LocalDate(2026, 8, 21);

        final entries = [
          NutritionEntry(
            id: '1',
            day: day1,
            meal: MealType.breakfast,
            foodName: 'Oatmeal',
            servingDescription: '1 bowl',
            quantityAmount: 1,
            quantityServings: 1,
            perServing: const NutritionFacts(
              caloriesKcal: 300,
              proteinGrams: 10,
              carbsGrams: 50,
              fatGrams: 5,
              ironMg: 2,
            ),
            createdAt: DateTime.utc(2026, 8, 20, 8),
            updatedAt: DateTime.utc(2026, 8, 20, 8),
          ),
          NutritionEntry(
            id: '2',
            day: day1,
            meal: MealType.lunch,
            foodName: 'Chicken Rice',
            servingDescription: '1 plate',
            quantityAmount: 1,
            quantityServings: 1,
            perServing: const NutritionFacts(
              caloriesKcal: 500,
              proteinGrams: 40,
              carbsGrams: 60,
              fatGrams: 10,
              ironMg: 3,
            ),
            createdAt: DateTime.utc(2026, 8, 20, 12),
            updatedAt: DateTime.utc(2026, 8, 20, 12),
          ),
          NutritionEntry(
            id: '3',
            day: day2,
            meal: MealType.dinner,
            foodName: 'Salmon Salad',
            servingDescription: '1 bowl',
            quantityAmount: 1,
            quantityServings: 1,
            perServing: const NutritionFacts(
              caloriesKcal: 600,
              proteinGrams: 35,
              carbsGrams: 15,
              fatGrams: 20,
              ironMg: 1.5,
            ),
            createdAt: DateTime.utc(2026, 8, 21, 19),
            updatedAt: DateTime.utc(2026, 8, 21, 19),
          ),
        ];

        // 7-day range (e.g. week), 2 days with entries
        final totals = computeRangeNutritionTotals(
          entries: entries,
          daysInRange: 7,
        );

        expect(totals.daysInRange, equals(7));
        expect(totals.daysWithEntries, equals(2));
        expect(totals.total.caloriesKcal, equals(1400));
        expect(totals.total.proteinGrams, equals(85));
        expect(totals.total.carbsGrams, equals(125));
        expect(totals.total.fatGrams, equals(35));
        expect(totals.total.ironMg, closeTo(6.5, 0.01));
        expect(totals.total.ironIsPartial, isFalse);

        // Daily averages divided across all 7 days in the range
        expect(totals.dailyAverage.caloriesKcal, closeTo(1400 / 7, 0.01));
        expect(totals.dailyAverage.proteinGrams, closeTo(85 / 7, 0.01));
        expect(totals.dailyAverage.carbsGrams, closeTo(125 / 7, 0.01));
        expect(totals.dailyAverage.fatGrams, closeTo(35 / 7, 0.01));
        expect(totals.dailyAverage.ironMg, closeTo(6.5 / 7, 0.01));

        // byDay map has both days
        expect(totals.byDay.containsKey(day1), isTrue);
        expect(totals.byDay[day1]!.total.caloriesKcal, equals(800));
        expect(totals.byDay.containsKey(day2), isTrue);
        expect(totals.byDay[day2]!.total.caloriesKcal, equals(600));
      },
    );

    test('marks ironIsPartial when any entry in range lacks iron facts', () {
      final day = LocalDate(2026, 8, 20);
      final entries = [
        NutritionEntry(
          id: '1',
          day: day,
          meal: MealType.snack,
          foodName: 'Apple',
          servingDescription: '1 medium',
          quantityAmount: 1,
          quantityServings: 1,
          perServing: const NutritionFacts(
            caloriesKcal: 80,
            proteinGrams: 0.5,
            carbsGrams: 20,
            fatGrams: 0.2,
          ),
          createdAt: DateTime.utc(2026, 8, 20, 15),
          updatedAt: DateTime.utc(2026, 8, 20, 15),
        ),
      ];

      final totals = computeRangeNutritionTotals(
        entries: entries,
        daysInRange: 1,
      );

      expect(totals.total.ironIsPartial, isTrue);
      expect(totals.dailyAverage.ironIsPartial, isTrue);
    });
  });
}
