import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/meal_type.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/quantity_unit.dart';

final DateTime _now = DateTime.utc(2026, 8, 20, 9);
final LocalDate _day = LocalDate(2026, 8, 20);

/// A food whose serving weighs 30 g, so every mass unit converts.
Food _weighed({double? servingGrams = 30}) => Food(
  id: 'food-1',
  name: 'Porridge oats',
  servingDescription: '1 cup (dry)',
  servingGrams: servingGrams,
  perServing: const NutritionFacts(
    caloriesKcal: 300,
    proteinGrams: 10,
    carbsGrams: 54,
    fatGrams: 5,
    ironMg: 3,
  ),
  createdAt: _now,
  updatedAt: _now,
);

NutritionEntry _log({
  required double amount,
  QuantityUnit unit = QuantityUnit.serving,
  double? servingGrams = 30,
  String id = 'entry-1',
}) {
  return NutritionEntry.fromFood(
    id: id,
    day: _day,
    meal: MealType.breakfast,
    food: _weighed(servingGrams: servingGrams),
    amount: amount,
    unit: unit,
    now: _now,
  );
}

void main() {
  group('fromFood derives the serving count', () {
    test('servings pass through', () {
      expect(_log(amount: 2.5).quantityServings, 2.5);
    });

    test('grams divide by the serving weight', () {
      expect(_log(amount: 60, unit: QuantityUnit.gram).quantityServings, 2);
      expect(
        _log(amount: 47, unit: QuantityUnit.gram).quantityServings,
        closeTo(1.5666666, 1e-6),
      );
    });

    test('the larger mass units convert too', () {
      // 1 oz = 28.349523125 g against a 30 g serving.
      expect(
        _log(amount: 1, unit: QuantityUnit.ounce).quantityServings,
        closeTo(28.349523125 / 30, 1e-9),
      );
      expect(
        _log(amount: 0.3, unit: QuantityUnit.kilogram).quantityServings,
        closeTo(10, 1e-9),
      );
      expect(
        _log(amount: 1, unit: QuantityUnit.pound).quantityServings,
        closeTo(453.59237 / 30, 1e-9),
      );
    });

    test('the amount, unit and serving weight are all snapshotted', () {
      final entry = _log(amount: 47, unit: QuantityUnit.gram);
      expect(entry.quantityAmount, 47);
      expect(entry.quantityUnit, QuantityUnit.gram);
      expect(
        entry.servingGrams,
        30,
        reason:
            'the weight the amount was measured against has to travel with '
            'the entry, or editing the food later re-reads what 47 g meant',
      );
    });

    test('a food with no serving weight still logs in servings', () {
      final entry = _log(amount: 2, servingGrams: null);
      expect(entry.quantityServings, 2);
      expect(entry.servingGrams, isNull);
    });

    test(
      'a mass against a food with no serving weight refuses loudly rather '
      'than inventing a weight or quietly logging servings',
      () {
        for (final grams in <double?>[null, 0, -5]) {
          expect(
            () =>
                _log(amount: 60, unit: QuantityUnit.gram, servingGrams: grams),
            throwsArgumentError,
            reason: 'servingGrams=$grams',
          );
        }
      },
    );
  });

  test(
    'the unit changes nothing about the nutrition: 2 servings and 60 g of a '
    '30 g-serving food contribute exactly the same',
    () {
      // The whole correctness claim of logging by weight. If these ever
      // diverge, every day total for a weight-logged entry is wrong.
      final inServings = _log(amount: 2).facts;
      final inGrams = _log(amount: 60, unit: QuantityUnit.gram).facts;

      expect(inGrams.caloriesKcal, inServings.caloriesKcal);
      expect(inGrams.proteinGrams, inServings.proteinGrams);
      expect(inGrams.carbsGrams, inServings.carbsGrams);
      expect(inGrams.fatGrams, inServings.fatGrams);
      expect(inGrams.ironMg, inServings.ironMg);
      expect(inServings.caloriesKcal, 600);
    },
  );

  group('withQuantity', () {
    test('re-derives the serving count and keeps all three in step', () {
      final edited = _log(
        amount: 2,
      ).withQuantity(amount: 90, unit: QuantityUnit.gram);

      expect(edited.quantityAmount, 90);
      expect(edited.quantityUnit, QuantityUnit.gram);
      expect(edited.quantityServings, 3);
      expect(edited.facts.caloriesKcal, 900);
    });

    test('measures against the entry snapshot, not the food today', () {
      // The entry was logged against a 30 g serving; a food edited to 50 g
      // afterwards must not change what 60 g means in this entry.
      final entry = _log(amount: 60, unit: QuantityUnit.gram);
      final reQuantified = entry.withQuantity(
        amount: 60,
        unit: QuantityUnit.gram,
      );
      expect(reQuantified.quantityServings, 2);
    });

    test('refuses a mass when the entry carries no serving weight', () {
      final entry = _log(amount: 2, servingGrams: null);
      expect(
        () => entry.withQuantity(amount: 60, unit: QuantityUnit.gram),
        throwsArgumentError,
      );
    });
  });

  group('quantityLabel', () {
    test('a mass reads back as the mass she typed', () {
      expect(_log(amount: 47, unit: QuantityUnit.gram).quantityLabel, '47 g');
      expect(
        _log(amount: 1.5, unit: QuantityUnit.ounce).quantityLabel,
        '1.5 oz',
      );
      expect(
        _log(amount: 0.3, unit: QuantityUnit.kilogram).quantityLabel,
        '0.3 kg',
      );
      expect(_log(amount: 1, unit: QuantityUnit.pound).quantityLabel, '1 lb');
    });

    test('servings are the unit that pluralises', () {
      expect(_log(amount: 1).quantityLabel, '1 serving');
      expect(_log(amount: 2).quantityLabel, '2 servings');
      expect(_log(amount: 0.5).quantityLabel, '0.5 servings');
      expect(_log(amount: 1.5).quantityLabel, '1.5 servings');
    });

    test('float noise from a round trip never reaches the diary', () {
      // 47 g -> 1.5666… servings -> back again lands a hair off 47.
      final entry = _log(amount: 47, unit: QuantityUnit.gram);
      final roundTripped = entry.withQuantity(
        amount: (amountFor(
          servings: entry.quantityServings,
          unit: QuantityUnit.gram,
          servingGrams: entry.servingGrams,
        ) as ConvertedAmount).amount,
        unit: QuantityUnit.gram,
      );
      expect(roundTripped.quantityLabel, '47 g');
    });
  });
}
