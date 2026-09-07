import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/food_search_ranking.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

void main() {
  group('hasCaloriesOrMacros', () {
    test('returns false when all nutrition fields are null', () {
      const summary = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '1',
        name: 'Empty Food',
      );
      expect(hasCaloriesOrMacros(summary), isFalse);
    });

    test('returns true when only calories are present', () {
      const summary = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '2',
        name: 'Calorie Food',
        caloriesKcal: 150,
      );
      expect(hasCaloriesOrMacros(summary), isTrue);
    });

    test('returns true when calories are zero (e.g. Diet Coke)', () {
      const summary = ProviderFoodSummary(
        source: FoodSource.openFoodFacts,
        barcode: '3',
        name: 'Diet Coke',
        caloriesKcal: 0,
        proteinGrams: 0,
        carbsGrams: 0,
        fatGrams: 0,
      );
      expect(hasCaloriesOrMacros(summary), isTrue);
    });

    test('returns true when servingCaloriesKcal is present', () {
      const summary = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '4',
        name: 'Serving Calorie Food',
        servingCaloriesKcal: 120,
      );
      expect(hasCaloriesOrMacros(summary), isTrue);
    });

    test('returns true when only macros are present', () {
      const summary = ProviderFoodSummary(
        source: FoodSource.openFoodFacts,
        barcode: '5',
        name: 'Macro Food',
        proteinGrams: 20,
      );
      expect(hasCaloriesOrMacros(summary), isTrue);
    });
  });

  group('evaluateNutritionTier', () {
    test('identifies full macros and calories', () {
      const food = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '1',
        name: 'Complete',
        caloriesKcal: 200,
        proteinGrams: 10,
        carbsGrams: 25,
        fatGrams: 5,
      );
      expect(
        evaluateNutritionTier(food),
        equals(NutritionCompletenessTier.fullMacrosAndCalories),
      );
    });

    test('identifies partial macros and calories', () {
      const food = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '2',
        name: 'Partial',
        caloriesKcal: 200,
        proteinGrams: 10,
      );
      expect(
        evaluateNutritionTier(food),
        equals(NutritionCompletenessTier.partialMacrosAndCalories),
      );
    });

    test('identifies calories only', () {
      const food = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '3',
        name: 'Calories Only',
        caloriesKcal: 100,
      );
      expect(
        evaluateNutritionTier(food),
        equals(NutritionCompletenessTier.caloriesOnly),
      );
    });

    test('identifies macros only', () {
      const food = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '4',
        name: 'Macros Only',
        proteinGrams: 15,
      );
      expect(
        evaluateNutritionTier(food),
        equals(NutritionCompletenessTier.macrosOnly),
      );
    });

    test('identifies none', () {
      const food = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '5',
        name: 'Empty',
      );
      expect(
        evaluateNutritionTier(food),
        equals(NutritionCompletenessTier.none),
      );
    });
  });

  group('filterAndRankFoodSearchResults', () {
    test('filters out foods with neither calories nor macros', () {
      const valid = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '1',
        name: 'Latte',
        caloriesKcal: 150,
      );
      const empty = ProviderFoodSummary(
        source: FoodSource.openFoodFacts,
        barcode: '2',
        name: 'Hollow Product',
      );

      final result = filterAndRankFoodSearchResults([
        valid,
        empty,
      ], query: 'latte');
      expect(result.length, equals(1));
      expect(result.first.barcode, equals('1'));
    });

    test('prioritizes exact match over prefix match', () {
      const prefix = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '1',
        name: 'Starbucks Coffee Drink',
        caloriesKcal: 100,
        proteinGrams: 5,
        carbsGrams: 10,
        fatGrams: 2,
      );
      const exact = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '2',
        name: 'Starbucks',
        caloriesKcal: 100,
        proteinGrams: 5,
        carbsGrams: 10,
        fatGrams: 2,
      );

      final result = filterAndRankFoodSearchResults(
        [prefix, exact],
        query: 'starbucks',
      );
      expect(result.first.barcode, equals('2'));
      expect(result.last.barcode, equals('1'));
    });

    test('prioritizes macros + cals over cals only within same match tier', () {
      const calsOnly = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '1',
        name: 'Starbucks Iced Latte',
        caloriesKcal: 120,
      );
      const withMacros = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '2',
        name: 'Starbucks Iced Latte',
        caloriesKcal: 120,
        proteinGrams: 6,
        carbsGrams: 12,
        fatGrams: 4,
      );

      final result = filterAndRankFoodSearchResults(
        [calsOnly, withMacros],
        query: 'starbucks iced latte',
      );
      expect(result.first.barcode, equals('2'));
      expect(result.last.barcode, equals('1'));
    });

    test('prioritizes cals only over macros only', () {
      const macrosOnly = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '1',
        name: 'Starbucks Iced Latte',
        proteinGrams: 6,
      );
      const calsOnly = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '2',
        name: 'Starbucks Iced Latte',
        caloriesKcal: 120,
      );

      final result = filterAndRankFoodSearchResults(
        [macrosOnly, calsOnly],
        query: 'starbucks iced latte',
      );
      expect(result.first.barcode, equals('2'));
      expect(result.last.barcode, equals('1'));
    });

    test('prioritizes tighter/closer matches when match tier is the same', () {
      const longTitle = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '1',
        name: 'Starbucks Iced Latte Extra Foam Sugar Free Vanilla Syrup',
        caloriesKcal: 120,
        proteinGrams: 6,
        carbsGrams: 12,
        fatGrams: 4,
      );
      const shortTitle = ProviderFoodSummary(
        source: FoodSource.fatSecret,
        barcode: '2',
        name: 'Starbucks Iced Latte',
        caloriesKcal: 120,
        proteinGrams: 6,
        carbsGrams: 12,
        fatGrams: 4,
      );

      final result = filterAndRankFoodSearchResults(
        [longTitle, shortTitle],
        query: 'starbucks iced latte',
      );
      expect(result.first.barcode, equals('2'));
      expect(result.last.barcode, equals('1'));
    });
  });
}
