import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/data/open_food_facts_mapper.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';

void main() {
  group('parseOpenFoodFactsHit', () {
    test(
      'extracts serving description and per-serving energy when present',
      () {
        final hit = {
          'code': '1234567890',
          'product_name': 'Iced Latte',
          'product_name_en': 'Iced Latte (English)',
          'brands': 'Starbucks',
          'serving_size': '350 ml (1 cup)',
          'serving_quantity': 350,
          'nutriments': {
            'energy-kcal_100g': 40,
            'energy-kcal_serving': 140,
            'proteins_100g': 2.0,
            'carbohydrates_100g': 5.0,
            'fat_100g': 1.5,
          },
        };

        final summary = parseOpenFoodFactsHit(hit);
        expect(summary, isNotNull);
        expect(summary!.source, FoodSource.openFoodFacts);
        expect(summary.name, 'Iced Latte (English)');
        expect(summary.brand, 'Starbucks');
        expect(summary.servingDescription, '350 ml (1 cup)');
        expect(summary.servingCaloriesKcal, 140);
        expect(summary.caloriesKcal, 40);
      },
    );

    test(
      'derives per-serving calories from 100g when serving_serving is absent',
      () {
        final hit = {
          'code': '987654321',
          'product_name': 'Almond Milk',
          'serving_size': '200 ml',
          'serving_quantity': 200,
          'nutriments': {
            'energy-kcal_100g': 30,
            'proteins_100g': 1.0,
            'carbohydrates_100g': 2.0,
            'fat_100g': 1.0,
          },
        };

        final summary = parseOpenFoodFactsHit(hit);
        expect(summary, isNotNull);
        expect(summary!.servingCaloriesKcal, 60); // 30 * (200 / 100)
      },
    );

    test(
      'extracts serving weight from string serving_size without '
      'serving_quantity',
      () {
        final hit = {
          'code': '1122334455',
          'product_name': 'Big Mac',
          'brands': "McDonald's",
          'serving_size': '232 g',
          'nutriments': {
            'energy-kcal_100g': 228,
            'proteins_100g': 12.0,
            'carbohydrates_100g': 18.0,
            'fat_100g': 12.0,
          },
        };

        final summary = parseOpenFoodFactsHit(hit);
        expect(summary, isNotNull);
        expect(summary!.servingDescription, '232 g');
        expect(summary.servingGrams, 232);
        expect(summary.servingCaloriesKcal, closeTo(528.96, 0.1));
      },
    );

    test(
      'extracts serving volume from quantity when serving_size is omitted',
      () {
        final hit = {
          'code': '5544332211',
          'product_name': 'Cola Can',
          'quantity': '330 ml',
          'nutriments': {
            'energy-kcal_100g': 42,
            'proteins_100g': 0.0,
            'carbohydrates_100g': 10.6,
            'fat_100g': 0.0,
          },
        };

        final summary = parseOpenFoodFactsHit(hit);
        expect(summary, isNotNull);
        expect(summary!.servingDescription, '330 ml');
        expect(summary.servingVolumeMl, 330);
        expect(summary.servingGrams, isNull);
        expect(summary.servingCaloriesKcal, closeTo(138.6, 0.1));
      },
    );

    test(
      'falls back to perServing macros scaled to 100g when per100g is omitted',
      () {
        final hit = {
          'code': '778899',
          'product_name': 'Protein Bar',
          'serving_size': '50 g',
          'nutriments': {
            'energy-kcal_serving': 200,
            'proteins_serving': 20.0,
            'carbohydrates_serving': 15.0,
            'fat_serving': 6.0,
          },
        };

        final summary = parseOpenFoodFactsHit(hit);
        expect(summary, isNotNull);
        expect(summary!.servingCaloriesKcal, 200);
        expect(summary.caloriesKcal, 400);
        expect(summary.proteinGrams, 40.0);
        expect(summary.carbsGrams, 30.0);
        expect(summary.fatGrams, 12.0);
      },
    );
  });

  group('parseOpenFoodFactsProduct', () {
    test(
      'extracts serving grams and scales per100g macros when serving_quantity '
      'is missing',
      () {
        final product = {
          'code': '1122334455',
          'product_name': 'Big Mac',
          'brands': "McDonald's",
          'serving_size': '232 g',
          'nutriments': {
            'energy-kcal_100g': 228,
            'proteins_100g': 12.0,
            'carbohydrates_100g': 18.0,
            'fat_100g': 12.0,
          },
        };

        final providerFood = parseOpenFoodFactsProduct(
          product,
          echoedCode: '1122334455',
        );
        expect(providerFood.source, FoodSource.openFoodFacts);
        expect(providerFood.servingDescription, '232 g');
        expect(providerFood.servingGrams, 232);
        expect(providerFood.servingVolumeMl, isNull);
        expect(providerFood.caloriesKcal, closeTo(528.96, 0.1));
        expect(providerFood.proteinGrams, closeTo(27.84, 0.1));
        expect(providerFood.carbsGrams, closeTo(41.76, 0.1));
        expect(providerFood.fatGrams, closeTo(27.84, 0.1));
      },
    );

    test(
      'extracts serving volume ml and sets servingBasis to per100ml for '
      'liquid products',
      () {
        final product = {
          'code': '5544332211',
          'product_name': 'Cola Can',
          'serving_size': '330 ml',
          'nutriments': {
            'energy-kcal_100g': 42,
            'proteins_100g': 0.0,
            'carbohydrates_100g': 10.6,
            'fat_100g': 0.0,
          },
        };

        final providerFood = parseOpenFoodFactsProduct(
          product,
          echoedCode: '5544332211',
        );
        expect(providerFood.source, FoodSource.openFoodFacts);
        expect(providerFood.servingDescription, '330 ml');
        expect(providerFood.servingVolumeMl, 330);
        expect(providerFood.servingGrams, isNull);
        expect(providerFood.servingBasis, ServingBasis.per100ml);
        expect(providerFood.caloriesKcal, closeTo(138.6, 0.1));
      },
    );
  });

  // The 2026-09-03 bug: an Australian search returned Bulgarian products
  // with Cyrillic names and Cyrillic gram sizes ("500 г").
  group('language and non-Latin free text', () {
    test('the name preference follows the requested language', () {
      final hit = {
        'code': '1',
        'product_name': 'Nusskrem',
        'product_name_de': 'Nuss-Nougat-Creme',
        'product_name_en': 'Hazelnut spread',
      };

      expect(
        parseOpenFoodFactsHit(hit, languageCode: 'de')!.name,
        'Nuss-Nougat-Creme',
      );
      // No entry for the requested language: the record's own name, not
      // nothing and not a different language's guess.
      expect(parseOpenFoodFactsHit(hit, languageCode: 'fr')!.name, 'Nusskrem');
    });

    test('defaults to English, which is what this client always sent', () {
      final hit = {
        'code': '1',
        'product_name': 'Nusskrem',
        'product_name_en': 'Hazelnut spread',
      };

      expect(parseOpenFoodFactsHit(hit)!.name, 'Hazelnut spread');
    });

    test('a Cyrillic gram size yields NO serving weight, and the text is '
        'kept verbatim', () {
      // "500 г" - the unit is Cyrillic ge, not a Latin "g". Reading the 500
      // as grams would be a plausible-looking wrong number that every macro
      // then gets scaled by, which is the only kind of error that matters
      // here. Unknown is the correct answer.
      final hit = {
        'code': '3800065000000',
        'product_name': 'Българско бяло саламурено сирене',
        'quantity': '500 г',
        'nutriments': {'energy-kcal_100g': 260.0},
      };

      final summary = parseOpenFoodFactsHit(hit);

      expect(summary!.servingGrams, isNull);
      expect(summary.servingDescription, '500 г');
      // Per-100 g calories survive; only the serving arithmetic is refused.
      expect(summary.caloriesKcal, 260);
      expect(summary.servingCaloriesKcal, isNull);
    });

    test('a Cyrillic serving_size does not fall through to a bare number '
        'either', () {
      final product = {
        'code': '3800065000000',
        'product_name': 'Козе сирене',
        'serving_size': '30 г',
        'nutriments': {'energy-kcal_100g': 260.0},
      };

      final providerFood = parseOpenFoodFactsProduct(
        product,
        echoedCode: '3800065000000',
      );

      // No usable weight, so the honest basis is per 100 g rather than a
      // serving whose size we invented.
      expect(providerFood.servingGrams, 100);
      expect(providerFood.servingDescription, '100 g');
      expect(providerFood.caloriesKcal, 260);
    });

    test('a Latin gram size in the same record shape still parses', () {
      // Guards the fix from being "reject anything unfamiliar": the
      // ordinary case must keep working.
      final hit = {
        'code': '1',
        'product_name': 'Feta',
        'quantity': '500 g',
        'nutriments': {'energy-kcal_100g': 260.0},
      };

      expect(parseOpenFoodFactsHit(hit)!.servingGrams, 500);
    });
  });
}
