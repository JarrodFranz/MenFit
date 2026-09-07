import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_mapper.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

void main() {
  const mapper = FatSecretMapper();

  group('FatSecretMapper.parseSearchHits', () {
    test('parses multiple foods array in search results', () {
      final json = {
        'foods': {
          'food': [
            {
              'food_id': '101',
              'food_name': 'Rolled Oats',
              'brand_name': 'Quaker',
              'food_description':
                  'Per 100g - Calories: 389kcal | Fat: 6.90g | '
                  'Carbs: 66.30g | Protein: 16.90g',
            },
            {
              'food_id': '102',
              'food_name': 'Steel Cut Oats',
              'brand_name': "Bob's Red Mill",
              'food_description':
                  'Per 1/4 cup (45g) - Calories: 170kcal | Fat: 3.00g | '
                  'Carbs: 29.00g | Protein: 7.00g',
            },
          ],
          'max_results': '20',
          'page_number': '0',
          'total_results': '2',
        },
      };

      final hits = mapper.parseSearchHits(json);

      expect(hits.length, equals(2));

      final hit1 = hits[0];
      expect(hit1.source, equals(FoodSource.fatSecret));
      expect(hit1.barcode, equals('101'));
      expect(hit1.name, equals('Rolled Oats'));
      expect(hit1.brand, equals('Quaker'));
      expect(hit1.displayName, equals('Rolled Oats · Quaker'));
      expect(hit1.caloriesKcal, equals(389.0));
      expect(hit1.fatGrams, equals(6.90));
      expect(hit1.carbsGrams, equals(66.30));
      expect(hit1.proteinGrams, equals(16.90));
      expect(hit1.servingDescription, equals('100 g'));
      expect(hit1.servingGrams, equals(100.0));

      final hit2 = hits[1];
      expect(hit2.barcode, equals('102'));
      expect(hit2.name, equals('Steel Cut Oats'));
      expect(hit2.servingDescription, equals('1/4 cup (45g)'));
      expect(hit2.servingGrams, equals(45.0));
      expect(hit2.servingCaloriesKcal, equals(170.0));
    });

    test(
      'parses single food object when API returns a Map instead of List',
      () {
        final json = {
          'foods': {
            'food': {
              'food_id': '201',
              'food_name': 'Greek Yogurt',
              'brand_name': 'Chobani',
              'food_description':
                  'Per 1 container (150g) - Calories: 130kcal | '
                  'Fat: 0.00g | Carbs: 11.00g | Protein: 15.00g',
            },
          },
        };

        final hits = mapper.parseSearchHits(json);

        expect(hits.length, equals(1));
        expect(hits.first.barcode, equals('201'));
        expect(hits.first.name, equals('Greek Yogurt'));
        expect(hits.first.brand, equals('Chobani'));
        expect(hits.first.servingGrams, equals(150.0));
        expect(hits.first.servingCaloriesKcal, equals(130.0));
      },
    );

    test(
      'preserves macros when portion has no gram weight (Per 1 serving)',
      () {
        final json = {
          'foods': {
            'food': [
              {
                'food_id': '301',
                'food_name': 'Iced Shaken Espresso (Venti)',
                'brand_name': 'Starbucks',
                'food_description':
                    'Per 1 serving - Calories: 160kcal | Fat: 2.50g | '
                    'Carbs: 33.00g | Protein: 2.00g',
              },
            ],
            'max_results': '20',
            'page_number': '0',
            'total_results': '1',
          },
        };

        final hits = mapper.parseSearchHits(json);
        expect(hits.length, equals(1));
        final hit = hits.first;
        expect(hit.name, equals('Iced Shaken Espresso (Venti)'));
        expect(hit.servingDescription, equals('1 serving'));
        expect(hit.servingGrams, isNull);
        expect(hit.servingCaloriesKcal, equals(160.0));
        expect(hit.caloriesKcal, equals(160.0));
        expect(hit.fatGrams, equals(2.50));
        expect(hit.carbsGrams, equals(33.00));
        expect(hit.proteinGrams, equals(2.00));
      },
    );

    test(
      'extracts servingVolumeMl when portion has ml unit (Per 1 bottle 600ml)',
      () {
        final json = {
          'foods': {
            'food': [
              {
                'food_id': '302',
                'food_name': 'Iced Tea',
                'brand_name': 'Lipton',
                'food_description':
                    'Per 1 bottle (600ml) - Calories: 120kcal | '
                    'Fat: 0.00g | Carbs: 30.00g | Protein: 0.00g',
              },
            ],
            'max_results': '20',
            'page_number': '0',
            'total_results': '1',
          },
        };

        final hits = mapper.parseSearchHits(json);
        expect(hits.length, equals(1));
        final hit = hits.first;
        expect(hit.servingDescription, equals('1 bottle (600ml)'));
        expect(hit.servingVolumeMl, equals(600.0));
        expect(hit.servingGrams, isNull);
        expect(hit.servingCaloriesKcal, equals(120.0));
      },
    );

    test('returns empty list for empty or missing food object', () {
      expect(mapper.parseSearchHits({}), isEmpty);
      expect(mapper.parseSearchHits({'foods': null}), isEmpty);
      expect(
        mapper.parseSearchHits({
          'foods': {'food': null},
        }),
        isEmpty,
      );
      expect(
        mapper.parseSearchHits({
          'foods': {'food': <dynamic>[]},
        }),
        isEmpty,
      );
    });
  });

  group('FatSecretMapper.parseBarcodeToFoodId', () {
    test('extracts food_id from nested value object', () {
      final json = {
        'food_id': {'value': '54321'},
      };
      expect(mapper.parseBarcodeToFoodId(json), equals('54321'));
    });

    test('extracts food_id from flat string', () {
      final json = {'food_id': '98765'};
      expect(mapper.parseBarcodeToFoodId(json), equals('98765'));
    });

    test('returns null when food_id missing', () {
      expect(mapper.parseBarcodeToFoodId({}), isNull);
    });
  });

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
      expect(food.barcode, equals('33691'));
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
