import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/domain/quantity_unit.dart';

/// The conversion is the whole feature: every number the diary shows for a
/// weight-logged entry is this arithmetic multiplied by a snapshot. A wrong
/// factor here is a wrong calorie and a wrong iron figure, silently.
void main() {
  double convert({
    required double amount,
    required QuantityUnit unit,
    required double? servingGrams,
    double? servingVolumeMl,
  }) {
    final result = servingsFor(
      amount: amount,
      unit: unit,
      servingGrams: servingGrams,
      servingVolumeMl: servingVolumeMl,
    );
    return (result as ConvertedQuantity).servings;
  }

  group('servingsFor', () {
    test('servings pass through untouched, weight or no weight', () {
      expect(
        convert(amount: 2.5, unit: QuantityUnit.serving, servingGrams: 30),
        2.5,
      );
      // The case that matters: a food nobody weighed is still loggable.
      expect(
        convert(amount: 2.5, unit: QuantityUnit.serving, servingGrams: null),
        2.5,
      );
    });

    test('grams divide by the serving weight', () {
      // A 30 g serving, 90 g eaten.
      expect(
        convert(amount: 90, unit: QuantityUnit.gram, servingGrams: 30),
        3,
      );
      // The everyday case: a scale reading that is not a whole serving.
      expect(
        convert(amount: 47, unit: QuantityUnit.gram, servingGrams: 30),
        closeTo(1.5666666, 1e-6),
      );
    });

    test('the mass factors are the exact international definitions', () {
      // 1 oz = 28.349523125 g exactly; against a 1 g serving the serving
      // count IS the gram count, which isolates the factor itself.
      expect(
        convert(amount: 1, unit: QuantityUnit.ounce, servingGrams: 1),
        closeTo(28.349523125, 1e-9),
      );
      expect(
        convert(amount: 1, unit: QuantityUnit.pound, servingGrams: 1),
        closeTo(453.59237, 1e-9),
      );
      expect(
        convert(amount: 1, unit: QuantityUnit.kilogram, servingGrams: 1),
        1000,
      );
      // And a pound really is 16 ounces, which catches a transcription slip
      // in either constant that the absolute checks above could share.
      expect(
        convert(amount: 1, unit: QuantityUnit.pound, servingGrams: 1),
        closeTo(
          convert(amount: 16, unit: QuantityUnit.ounce, servingGrams: 1),
          1e-9,
        ),
      );
    });

    test('a mass against no serving weight refuses rather than guessing', () {
      for (final grams in <double?>[null, 0, -5, double.nan, double.infinity]) {
        expect(
          servingsFor(
            amount: 100,
            unit: QuantityUnit.gram,
            servingGrams: grams,
          ),
          isA<NoServingWeight>(),
          reason: 'servingGrams=$grams must not convert',
        );
      }
    });

    test('zero grams does not sneak through as infinity', () {
      // Dividing by zero yields a double that is not null and not NaN, so a
      // nullable-double API would have handed this to the diary as a number.
      final result = servingsFor(
        amount: 100,
        unit: QuantityUnit.gram,
        servingGrams: 0,
      );
      expect(result, isA<NoServingWeight>());
    });

    test('millilitres divide by the serving volume', () {
      // A 250 ml serving, 500 ml consumed.
      expect(
        convert(
          amount: 500,
          unit: QuantityUnit.millilitre,
          servingGrams: null,
          servingVolumeMl: 250,
        ),
        2,
      );
      // Fluid ounces convert against serving volume
      expect(
        convert(
          amount: 1,
          unit: QuantityUnit.fluidOunce,
          servingGrams: null,
          servingVolumeMl: 29.5735295625,
        ),
        closeTo(1.0, 1e-6),
      );
    });

    test(
      'volume unit refuses with NoServingVolume when neither volume nor '
      'weight is known',
      () {
        for (final vol in <double?>[null, 0, -5, double.nan, double.infinity]) {
          expect(
            servingsFor(
              amount: 100,
              unit: QuantityUnit.millilitre,
              servingGrams: null,
              servingVolumeMl: vol,
            ),
            isA<NoServingVolume>(),
            reason: 'servingVolumeMl=$vol must not convert',
          );
        }
      },
    );

    test(
      'volume unit falls back to serving weight for legacy pre-v25 entries',
      () {
        expect(
          convert(
            amount: 200,
            unit: QuantityUnit.millilitre,
            servingGrams: 50,
          ),
          4,
        );
      },
    );
  });

  group('amountFor round-trips', () {
    test('what was logged is what reads back', () {
      for (final unit in QuantityUnit.values) {
        final servings = convert(
          amount: 47,
          unit: unit,
          servingGrams: 30,
        );
        final back = amountFor(
          servings: servings,
          unit: unit,
          servingGrams: 30,
        );
        expect(
          (back as ConvertedAmount).amount,
          closeTo(47, 1e-9),
          reason: '$unit must survive a round trip',
        );
      }
    });

    test('volume units round-trip against servingVolumeMl', () {
      final servings = convert(
        amount: 250,
        unit: QuantityUnit.millilitre,
        servingGrams: null,
        servingVolumeMl: 100,
      );
      final back = amountFor(
        servings: servings,
        unit: QuantityUnit.millilitre,
        servingGrams: null,
        servingVolumeMl: 100,
      );
      expect((back as ConvertedAmount).amount, closeTo(250, 1e-9));
    });

    test('refuses on the same terms as servingsFor', () {
      expect(
        amountFor(
          servings: 2,
          unit: QuantityUnit.gram,
          servingGrams: null,
        ),
        isA<NoServingWeight>(),
      );
      expect(
        amountFor(
          servings: 2,
          unit: QuantityUnit.serving,
          servingGrams: null,
        ),
        isA<ConvertedAmount>(),
      );
      expect(
        amountFor(
          servings: 2,
          unit: QuantityUnit.millilitre,
          servingGrams: null,
        ),
        isA<NoServingVolume>(),
      );
    });
  });

  group('availableFor', () {
    test('offers volume units when servingVolumeMl is present', () {
      // Pure volume food (no mass)
      expect(
        QuantityUnit.availableFor(null, servingVolumeMl: 250),
        QuantityUnit.offerableVolume,
      );
      expect(QuantityUnit.availableFor(null, servingVolumeMl: 250), [
        QuantityUnit.serving,
        QuantityUnit.millilitre,
        QuantityUnit.fluidOunce,
      ]);

      // Dual-unit food (both mass and volume known)
      final dualOffered = QuantityUnit.availableFor(250, servingVolumeMl: 250);
      expect(dualOffered, [
        QuantityUnit.serving,
        QuantityUnit.gram,
        QuantityUnit.ounce,
        QuantityUnit.kilogram,
        QuantityUnit.pound,
        QuantityUnit.millilitre,
        QuantityUnit.fluidOunce,
      ]);
    });

    test('a weighed serving offers every MASS unit', () {
      expect(QuantityUnit.availableFor(30), QuantityUnit.offerable);
      expect(QuantityUnit.availableFor(30), [
        QuantityUnit.serving,
        QuantityUnit.gram,
        QuantityUnit.ounce,
        QuantityUnit.kilogram,
        QuantityUnit.pound,
      ]);
    });

    test('an unweighed serving offers only servings', () {
      // Not a degraded picker for its own sake: offering grams here would
      // mean inventing a weight or logging a zero.
      for (final grams in <double?>[null, 0, -1]) {
        expect(
          QuantityUnit.availableFor(grams),
          [QuantityUnit.serving],
          reason: 'servingGrams=$grams',
        );
      }
    });

    test('never offers a volume unit, whatever the serving weight', () {
      // `knowledge/domain/nutrition.md`: a millilitre is not a mass. The app
      // stores no density, so 100 ml of oil (~92 g) and of honey (~140 g)
      // would both be logged as 100 g — a number that looks right and is
      // wrong, which in a diary is the worst failure there is.
      for (final grams in <double?>[null, 0, 1, 30, 1000]) {
        final offered = QuantityUnit.availableFor(grams);
        expect(
          offered,
          isNot(contains(QuantityUnit.millilitre)),
          reason: 'servingGrams=$grams',
        );
        expect(
          offered,
          isNot(contains(QuantityUnit.fluidOunce)),
          reason: 'servingGrams=$grams',
        );
        expect(offered.where((unit) => unit.isVolume), isEmpty);
      }
    });

    test('the offerable list itself holds no volume unit', () {
      // Asserted on the constant as well as on the function, so a unit added
      // to the list later is caught even if `availableFor` grows a branch
      // that skips the filter.
      expect(QuantityUnit.offerable.where((unit) => unit.isVolume), isEmpty);
      expect(QuantityUnit.millilitre.isVolume, isTrue);
      expect(QuantityUnit.fluidOunce.isVolume, isTrue);
      expect(QuantityUnit.gram.isVolume, isFalse);
      expect(QuantityUnit.serving.isVolume, isFalse);
    });

    test(
      'a legacy entry logged in millilitres still finds its own unit in the '
      'picker',
      () {
        // The one place a volume unit may still appear: an entry logged
        // while they were offered, reopened for editing. Without this, the
        // dropdown would be handed a selected value it has no item for,
        // which asserts — and the entry would become uneditable.
        final offered = QuantityUnit.availableFor(
          30,
          including: QuantityUnit.millilitre,
        );

        expect(offered, contains(QuantityUnit.millilitre));
        // Appended, not reinstated: everything else is unchanged, so no NEW
        // entry gains a volume unit from this.
        expect(offered.take(QuantityUnit.offerable.length), [
          ...QuantityUnit.offerable,
        ]);
        expect(offered, isNot(contains(QuantityUnit.fluidOunce)));
      },
    );

    test('including a unit already offered changes nothing', () {
      expect(
        QuantityUnit.availableFor(30, including: QuantityUnit.gram),
        QuantityUnit.offerable,
      );
      expect(
        QuantityUnit.availableFor(30, including: QuantityUnit.serving),
        QuantityUnit.offerable,
      );
    });

    test(
      'including still surfaces the unit for an unweighed food, though '
      'nothing can be converted against it',
      () {
        // No serving weight means no conversion for any mass unit, legacy or
        // not (`servingsFor`/`amountFor` both refuse) — but the dropdown
        // still needs its selected value among its items, or it asserts.
        expect(
          QuantityUnit.availableFor(null, including: QuantityUnit.millilitre),
          [QuantityUnit.serving, QuantityUnit.millilitre],
        );
        // [serving] itself needs no special-casing: it's already the sole
        // entry.
        expect(
          QuantityUnit.availableFor(null, including: QuantityUnit.serving),
          [QuantityUnit.serving],
        );
      },
    );
  });

  group('stored volume entries keep working', () {
    test('every volume unit still parses back from storage', () {
      // The values stay in the enum precisely so this keeps holding.
      // Deleting them would break deserialisation of real rows in order to
      // fix a rule about new input.
      expect(QuantityUnit.fromStorage('millilitre'), QuantityUnit.millilitre);
      expect(QuantityUnit.fromStorage('fluidOunce'), QuantityUnit.fluidOunce);
    });

    test('and still convert exactly as they always did', () {
      // No data changed, so no stored entry may change value. 200 ml against
      // a 50 g serving is what it was before the units stopped being
      // offered.
      expect(
        convert(amount: 200, unit: QuantityUnit.millilitre, servingGrams: 50),
        4,
      );
      expect(
        convert(amount: 1, unit: QuantityUnit.fluidOunce, servingGrams: 1),
        closeTo(29.5735, 1e-9),
      );
    });

    test('and still label themselves', () {
      expect(QuantityUnit.millilitre.shortLabel, 'ml');
      expect(QuantityUnit.fluidOunce.shortLabel, 'fl oz');
      expect(QuantityUnit.millilitre.label, 'millilitre');
      expect(QuantityUnit.fluidOunce.label, 'fluid ounce');
    });
  });

  group('storage round-trip', () {
    test('every unit survives being written and read back', () {
      for (final unit in QuantityUnit.values) {
        expect(QuantityUnit.fromStorage(unit.toStorage()), unit);
      }
    });

    test('an unknown key reads as servings, not as a crash', () {
      // Every entry written before units existed was in servings.
      expect(QuantityUnit.fromStorage(''), QuantityUnit.serving);
      expect(QuantityUnit.fromStorage('furlong'), QuantityUnit.serving);
    });
  });
}
