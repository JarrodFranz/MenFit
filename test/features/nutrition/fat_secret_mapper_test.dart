import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_mapper.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

void main() {
  const mapper = FatSecretMapper();

  group('FatSecretMapper.parseFoodDetail', () {
    test('parses detailed food record with servings and micronutrients', () {
      final json = {
        'food': {
          'food_id': '33691',
          'food_name': 'Rolled Oats',
          'brand_name': 'Quaker',
          'servings': {
            'serving': [
              {
                'serving_id': '1',
                'serving_description': '1/2 cup (40g)',
                'metric_serving_amount': '40.000',
                'metric_serving_unit': 'g',
                'calories': '150',
                'carbohydrate': '27.00',
                'protein': '5.00',
                'fat': '3.00',
                'saturated_fat': '0.50',
                'fiber': '4.00',
                'sodium': '0',
                'potassium': '150',
                'calcium': '20',
                'iron': '1.80',
                'vitamin_d': '0',
                'vitamin_c': '0',
              },
            ],
          },
        },
      };

      final food = mapper.parseFoodDetail(json);

      expect(food, isNotNull);
      expect(food!.source, equals(FoodSource.fatSecret));
      expect(food.providerFoodId, equals('33691'));
      // Fetched by food_id with no scanned GTIN: no barcode (B23).
      expect(food.barcode, isNull);
      expect(food.name, equals('Rolled Oats'));
      expect(food.brand, equals('Quaker'));
      expect(food.servingDescription, equals('1/2 cup (40g)'));
      expect(food.servingBasis, equals(ServingBasis.statedPerServing));
      expect(food.servingGrams, equals(40.0));
      expect(food.caloriesKcal, equals(150.0));
      expect(food.carbsGrams, equals(27.0));
      expect(food.proteinGrams, equals(5.0));
      expect(food.fatGrams, equals(3.0));
      expect(food.saturatedFatGrams, equals(0.50));
      expect(food.fiberGrams, equals(4.0));
      expect(food.sodiumMg, equals(0.0));
      expect(food.potassiumMg, equals(150.0));
      expect(food.calciumMg, equals(20.0));
      expect(food.ironMg, equals(1.80));
      expect(food.hasCompleteMacros, isTrue);
      expect(food.hasIron, isTrue);
      expect(food.hasCompleteNutritionFacts, isTrue);
    });

    test('selects gram metric serving when multiple servings are provided', () {
      final json = {
        'food': {
          'food_id': '501',
          'food_name': 'Peanut Butter',
          'brand_name': 'Skippy',
          'servings': {
            'serving': [
              {
                'serving_id': '10',
                'serving_description': '1 package (16 oz)',
                'metric_serving_amount': null,
                'metric_serving_unit': null,
                'calories': '2400',
                'carbohydrate': '80.0',
                'protein': '90.0',
                'fat': '200.0',
              },
              {
                'serving_id': '11',
                'serving_description': '2 tbsp (32g)',
                'metric_serving_amount': '32.000',
                'metric_serving_unit': 'g',
                'calories': '190',
                'carbohydrate': '7.00',
                'protein': '7.00',
                'fat': '16.00',
                'iron': '0.90',
              },
            ],
          },
        },
      };

      final food = mapper.parseFoodDetail(json);

      expect(food, isNotNull);
      expect(food!.servingDescription, equals('2 tbsp (32g)'));
      expect(food.servingGrams, equals(32.0));
      expect(food.caloriesKcal, equals(190.0));
      expect(food.fatGrams, equals(16.0));
    });

    test('handles empty servings gracefully', () {
      final json = {
        'food': {
          'food_id': '999',
          'food_name': 'Loose Apple',
          'servings': null,
        },
      };

      final food = mapper.parseFoodDetail(json);

      expect(food, isNotNull);
      expect(food!.source, equals(FoodSource.fatSecret));
      expect(food.name, equals('Loose Apple'));
      expect(food.hasNoNutritionData, isTrue);
    });

    test('formats generic 1 serving with metric grams into description', () {
      final json = {
        'food': {
          'food_id': '401',
          'food_name': 'Cooked Rice',
          'servings': {
            'serving': {
              'serving_id': '1',
              'serving_description': '1 serving',
              'metric_serving_amount': '250.000',
              'metric_serving_unit': 'g',
              'calories': '325',
              'carbohydrate': '70.0',
              'protein': '6.0',
              'fat': '1.0',
            },
          },
        },
      };

      final food = mapper.parseFoodDetail(json);
      expect(food, isNotNull);
      expect(food!.servingDescription, equals('1 serving (250 g)'));
      expect(food.servingGrams, equals(250.0));
    });

    test('formats generic 1 serving with metric ml into description', () {
      final json = {
        'food': {
          'food_id': '402',
          'food_name': 'Chocolate Milk',
          'servings': {
            'serving': {
              'serving_id': '1',
              'serving_description': '1 serving',
              'metric_serving_amount': '600.000',
              'metric_serving_unit': 'ml',
              'calories': '400',
              'carbohydrate': '50.0',
              'protein': '18.0',
              'fat': '12.0',
            },
          },
        },
      };

      final food = mapper.parseFoodDetail(json);
      expect(food, isNotNull);
      expect(food!.servingDescription, equals('1 serving (600 ml)'));
      expect(food.servingVolumeMl, equals(600.0));
      expect(food.servingGrams, isNull);
    });

    test('formats named serving with metric ml into description', () {
      final json = {
        'food': {
          'food_id': '403',
          'food_name': 'Protein Shake',
          'servings': {
            'serving': {
              'serving_id': '1',
              'serving_description': '1 bottle',
              'metric_serving_amount': '500.000',
              'metric_serving_unit': 'ml',
              'calories': '250',
              'carbohydrate': '10.0',
              'protein': '30.0',
              'fat': '5.0',
            },
          },
        },
      };

      final food = mapper.parseFoodDetail(json);
      expect(food, isNotNull);
      expect(food!.servingDescription, equals('1 bottle (500 ml)'));
      expect(food.servingVolumeMl, equals(500.0));
      expect(food.servingGrams, isNull);
    });
  });
}
