import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_validation.dart';

FoodValidation _validFood({
  String name = 'Porridge oats',
  String servingDescription = '1 cup (dry)',
  double? caloriesKcal = 300,
  double? proteinGrams = 10,
  double? carbsGrams = 54,
  double? fatGrams = 5,
  double? ironMg,
  double? servingGrams,
}) {
  return validateFood(
    name: name,
    servingDescription: servingDescription,
    caloriesKcal: caloriesKcal,
    proteinGrams: proteinGrams,
    carbsGrams: carbsGrams,
    fatGrams: fatGrams,
    ironMg: ironMg,
    servingGrams: servingGrams,
  );
}

void main() {
  group('validateFood', () {
    test('a complete, sane food validates', () {
      final result = _validFood(ironMg: 2.5, servingGrams: 80);
      expect(result.isValid, isTrue);
    });

    test('iron and serving grams are optional - null is valid', () {
      final result = _validFood();
      expect(result.ironError, isNull);
      expect(result.servingGramsError, isNull);
      expect(result.isValid, isTrue);
    });

    test('a blank or whitespace-only name is rejected', () {
      expect(_validFood(name: '').nameError, isNotNull);
      expect(_validFood(name: '   ').nameError, isNotNull);
      expect(_validFood(name: '  Oats  ').nameError, isNull);
    });

    test('a blank serving description is rejected', () {
      expect(
        _validFood(servingDescription: '').servingDescriptionError,
        isNotNull,
      );
      expect(
        _validFood(servingDescription: ' \t ').servingDescriptionError,
        isNotNull,
      );
    });

    test('the four core numbers are required - null is not "assume zero"', () {
      expect(_validFood(caloriesKcal: null).caloriesError, isNotNull);
      expect(_validFood(proteinGrams: null).proteinError, isNotNull);
      expect(_validFood(carbsGrams: null).carbsError, isNotNull);
      expect(_validFood(fatGrams: null).fatError, isNotNull);
    });

    test('zero is an accepted answer for every number', () {
      final result = _validFood(
        caloriesKcal: 0,
        proteinGrams: 0,
        carbsGrams: 0,
        fatGrams: 0,
        ironMg: 0,
        servingGrams: 0,
      );
      expect(result.isValid, isTrue);
    });

    test('negative values are rejected on every numeric field', () {
      expect(_validFood(caloriesKcal: -1).caloriesError, isNotNull);
      expect(_validFood(proteinGrams: -0.1).proteinError, isNotNull);
      expect(_validFood(carbsGrams: -5).carbsError, isNotNull);
      expect(_validFood(fatGrams: -5).fatError, isNotNull);
      expect(_validFood(ironMg: -1).ironError, isNotNull);
      expect(_validFood(servingGrams: -1).servingGramsError, isNotNull);
    });

    group('fat-finger upper bounds', () {
      test('exactly at the bound is accepted; just over is not', () {
        expect(
          _validFood(caloriesKcal: maxCaloriesPerServing).caloriesError,
          isNull,
        );
        expect(
          _validFood(caloriesKcal: maxCaloriesPerServing + 1).caloriesError,
          isNotNull,
        );

        expect(
          _validFood(proteinGrams: maxMacroGramsPerServing).proteinError,
          isNull,
        );
        expect(
          _validFood(proteinGrams: maxMacroGramsPerServing + 1).proteinError,
          isNotNull,
        );

        expect(_validFood(ironMg: maxIronMgPerServing).ironError, isNull);
        expect(
          _validFood(ironMg: maxIronMgPerServing + 1).ironError,
          isNotNull,
        );

        // A per-100 g serving basis puts real foods above 100 mg: dried
        // thyme is about 124 mg/100 g. Rejecting it would leave clearing
        // the field as the only way on, turning a known figure into
        // "unknown".
        expect(_validFood(ironMg: 123.6).ironError, isNull);
        // ...while a grams-to-milligrams conversion applied twice still
        // does not get through.
        expect(_validFood(ironMg: 16070).ironError, isNotNull);

        expect(
          _validFood(servingGrams: maxServingGrams).servingGramsError,
          isNull,
        );
        expect(
          _validFood(servingGrams: maxServingGrams + 1).servingGramsError,
          isNotNull,
        );
      });

      test('carbs and fat use the macro bound too', () {
        expect(
          _validFood(carbsGrams: maxMacroGramsPerServing + 1).carbsError,
          isNotNull,
        );
        expect(
          _validFood(fatGrams: maxMacroGramsPerServing + 1).fatError,
          isNotNull,
        );
      });
    });

    test('NaN and infinity read as "no number given", not as in-range', () {
      // Every comparison against NaN is false, so an unguarded bounds check
      // would let it through silently.
      expect(_validFood(caloriesKcal: double.nan).caloriesError, isNotNull);
      expect(
        _validFood(caloriesKcal: double.infinity).caloriesError,
        isNotNull,
      );
      expect(_validFood(ironMg: double.nan).ironError, isNotNull);
    });

    test(
      'no message shames, praises, or moralises about food '
      '(knowledge/domain/nutrition.md ED-safe stance)',
      () {
        // Deliberately trigger every error at once and inspect the copy.
        final result = validateFood(
          name: '',
          servingDescription: '',
          caloriesKcal: -1,
          proteinGrams: maxMacroGramsPerServing + 1,
          // carbsGrams deliberately omitted - the "required" error path.
          fatGrams: double.nan,
          ironMg: -1,
          servingGrams: maxServingGrams + 1,
        );
        final messages = <String?>[
          result.nameError,
          result.servingDescriptionError,
          result.caloriesError,
          result.proteinError,
          result.carbsError,
          result.fatError,
          result.ironError,
          result.servingGramsError,
        ].whereType<String>().map((m) => m.toLowerCase());

        expect(messages, isNotEmpty);
        for (final message in messages) {
          for (final banned in <String>[
            'unhealthy',
            'bad',
            'junk',
            'treat yourself',
            'too much',
            'too many calories',
            'excessive',
            'should not',
            "shouldn't",
            'guilt',
            'cheat',
          ]) {
            expect(
              message,
              isNot(contains(banned)),
              reason: 'validation copy must never moralise ($banned)',
            );
          }
        }
      },
    );
  });

  group('validateNutritionEntry', () {
    final today = LocalDate(2026, 8, 20);

    test('a sane entry on today validates', () {
      final result = validateNutritionEntry(
        day: today,
        today: today,
        quantityServings: 1.5,
      );
      expect(result.isValid, isTrue);
    });

    test('a past day validates - backfilling the diary is normal', () {
      final result = validateNutritionEntry(
        day: today.addDays(-30),
        today: today,
        quantityServings: 1,
      );
      expect(result.dayError, isNull);
    });

    test('a future day is rejected', () {
      final result = validateNutritionEntry(
        day: today.addDays(1),
        today: today,
        quantityServings: 1,
      );
      expect(result.dayError, isNotNull);
      expect(result.isValid, isFalse);
    });

    test('quantity must be greater than zero', () {
      for (final quantity in <double>[0, -0.5, -10]) {
        final result = validateNutritionEntry(
          day: today,
          today: today,
          quantityServings: quantity,
        );
        expect(result.quantityError, isNotNull, reason: '$quantity');
      }
      expect(
        validateNutritionEntry(
          day: today,
          today: today,
          quantityServings: 0.01,
        ).quantityError,
        isNull,
      );
    });

    test('a missing quantity is rejected', () {
      final result = validateNutritionEntry(day: today, today: today);
      expect(result.quantityError, isNotNull);
    });

    test('quantity has a fat-finger upper bound: at it, then over it', () {
      expect(
        validateNutritionEntry(
          day: today,
          today: today,
          quantityServings: maxQuantityServings,
        ).quantityError,
        isNull,
      );
      expect(
        validateNutritionEntry(
          day: today,
          today: today,
          quantityServings: maxQuantityServings + 1,
        ).quantityError,
        isNotNull,
      );
    });

    test('NaN quantity reads as "no number given"', () {
      expect(
        validateNutritionEntry(
          day: today,
          today: today,
          quantityServings: double.nan,
        ).quantityError,
        isNotNull,
      );
    });

    test('a non-positive typed amount is rejected on its own terms', () {
      // 0 g is a deletion rather than a log, whatever unit it is in — and
      // reporting it against the typed number rather than against a
      // converted zero is what makes the message make sense.
      for (final amount in <double>[0, -0.5, -250]) {
        final result = validateNutritionEntry(
          day: today,
          today: today,
          quantityServings: 2,
          quantityAmount: amount,
        );
        expect(result.quantityError, isNotNull, reason: '$amount');
      }
    });

    test('a non-finite typed amount reads as "no number given"', () {
      for (final amount in <double>[double.nan, double.infinity]) {
        expect(
          validateNutritionEntry(
            day: today,
            today: today,
            quantityServings: 2,
            quantityAmount: amount,
          ).quantityError,
          isNotNull,
          reason: '$amount',
        );
      }
    });

    test(
      'the bounds stay on the serving count, so one set of limits covers '
      'every unit',
      () {
        // A large gram figure is perfectly ordinary; what it converts to is
        // what the fat-finger bound is about.
        expect(
          validateNutritionEntry(
            day: today,
            today: today,
            quantityServings: 2,
            quantityAmount: 250,
          ).isValid,
          isTrue,
          reason: '250 g is not 250 servings',
        );
        expect(
          validateNutritionEntry(
            day: today,
            today: today,
            quantityServings: maxQuantityServings + 1,
            quantityAmount: 5000,
          ).quantityError,
          isNotNull,
        );
      },
    );

    test('no validation message interpolates a logged value (S2)', () {
      final result = validateNutritionEntry(
        day: LocalDate(2026, 12, 25),
        today: today,
        quantityServings: 999,
        quantityAmount: 47,
      );
      expect(result.quantityError, isNot(contains('47')));
      expect(result.dayError, isNot(contains('2026')));
      expect(result.quantityError, isNot(contains('999')));
    });
  });

  group('validateMacroTargetPercentages', () {
    test('a split that adds up to 100 is valid', () {
      expect(
        validateMacroTargetPercentages(
          proteinPercent: 30,
          carbPercent: 40,
          fatPercent: 30,
        ).isValid,
        isTrue,
      );
    });

    test('thirds written by hand still add up', () {
      expect(
        validateMacroTargetPercentages(
          proteinPercent: 33.3,
          carbPercent: 33.3,
          fatPercent: 33.4,
        ).isValid,
        isTrue,
        reason: 'the tolerance is for float arithmetic and thirds, not slack',
      );
    });

    test('all three blank is valid - no target is a valid state', () {
      expect(validateMacroTargetPercentages().isValid, isTrue);
    });

    test('a split that comes up short states the arithmetic', () {
      final result = validateMacroTargetPercentages(
        proteinPercent: 30,
        carbPercent: 36,
        fatPercent: 30,
      );

      expect(result.isValid, isFalse);
      expect(
        result.sumError,
        'These come to 96% — they need to add up to 100% between them.',
      );
      expect(
        result.proteinError,
        isNull,
        reason: 'no single field is the wrong one when a split misses',
      );
      expect(result.carbError, isNull);
      expect(result.fatError, isNull);
    });

    test('a split that goes over states the arithmetic the same way', () {
      expect(
        validateMacroTargetPercentages(
          proteinPercent: 40,
          carbPercent: 40,
          fatPercent: 30,
        ).sumError,
        'These come to 110% — they need to add up to 100% between them.',
      );
    });

    test('a fractional total prints one decimal, not float noise', () {
      final message = validateMacroTargetPercentages(
        proteinPercent: 30.2,
        carbPercent: 40.1,
        fatPercent: 30.2,
      ).sumError!;

      expect(message, contains('100.5%'));
      expect(message, isNot(contains('100.49999')));
    });

    test('a part-written split asks for the missing shares, not the sum', () {
      final result = validateMacroTargetPercentages(
        proteinPercent: 30,
        fatPercent: 30,
      );

      expect(result.isValid, isFalse);
      expect(result.carbError, isNotNull);
      expect(result.proteinError, isNull);
      expect(result.fatError, isNull);
      expect(
        result.sumError,
        isNull,
        reason: 'there is no total to state until all three are numbers',
      );
    });

    test('0 is an accepted share', () {
      expect(
        validateMacroTargetPercentages(
          proteinPercent: 0,
          carbPercent: 100,
          fatPercent: 0,
        ).isValid,
        isTrue,
      );
    });

    test('a share outside 0-100 is reported on its own field', () {
      final over = validateMacroTargetPercentages(
        proteinPercent: 140,
        carbPercent: 40,
        fatPercent: 30,
      );
      expect(over.proteinError, macroPercentTooLargeMessage);
      expect(
        over.sumError,
        isNull,
        reason: 'the field that cannot be read reports first',
      );

      final under = validateMacroTargetPercentages(
        proteinPercent: -5,
        carbPercent: 75,
        fatPercent: 30,
      );
      expect(under.proteinError, isNotNull);
      expect(under.isValid, isFalse);
    });

    test('NaN and infinity read as no number given', () {
      expect(
        validateMacroTargetPercentages(
          proteinPercent: double.nan,
          carbPercent: 40,
          fatPercent: 30,
        ).proteinError,
        isNotNull,
      );
      expect(
        validateMacroTargetPercentages(
          proteinPercent: double.infinity,
          carbPercent: 40,
          fatPercent: 30,
        ).proteinError,
        isNotNull,
      );
    });

    test('no message judges the split', () {
      final messages = [
        validateMacroTargetPercentages(
          proteinPercent: 5,
          carbPercent: 5,
          fatPercent: 5,
        ).sumError!,
        validateMacroTargetPercentages(
          proteinPercent: 90,
          carbPercent: 90,
          fatPercent: 90,
        ).sumError!,
        macroPercentTooLargeMessage,
      ];

      for (final message in messages) {
        for (final judgement in [
          'balanced',
          'recommend',
          'healthy',
          'optimal',
          'should',
          'too much',
          'too little',
          'high',
          'low',
        ]) {
          expect(
            message.toLowerCase(),
            isNot(contains(judgement)),
            reason: 'this app makes no nutrition recommendation',
          );
        }
      }
    });
  });
}
