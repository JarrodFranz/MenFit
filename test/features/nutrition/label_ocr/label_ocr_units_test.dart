import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_lexicon.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_numbers.dart';

/// The two pieces the whole parser rests on: deciding what is a number,
/// and deciding what a nutrient name is.
///
/// Both are where a heuristic goes wrong quietly. A number parser that
/// accepts too much invents figures out of nutrient names; a name matcher
/// with too much slack files sugar under salt. The cases below are the
/// boundaries, not a sample.
void main() {
  group('reading a number off a panel', () {
    test('plain figures, with and without a unit', () {
      expect(parseNumericToken('5.2')?.value, closeTo(5.2, 0.001));
      expect(parseNumericToken('5.2')?.unit, UnitKind.none);
      expect(parseNumericToken('5.2g')?.value, closeTo(5.2, 0.001));
      expect(parseNumericToken('5.2g')?.unit, UnitKind.gram);
      expect(parseNumericToken('160mg')?.unit, UnitKind.milligram);
      expect(parseNumericToken('2mcg')?.unit, UnitKind.microgram);
      expect(parseNumericToken('2µg')?.unit, UnitKind.microgram);
      expect(parseNumericToken('250mL')?.unit, UnitKind.millilitre);
      expect(parseNumericToken('830 kJ')?.unit, UnitKind.kilojoule);
      expect(parseNumericToken('198 Cal')?.unit, UnitKind.kilocalorie);
      expect(parseNumericToken('250kcal')?.unit, UnitKind.kilocalorie);
    });

    test('brackets around the second energy figure are stripped', () {
      final token = parseNumericToken('(198 Cal)');
      expect(token?.value, 198);
      expect(token?.unit, UnitKind.kilocalorie);
    });

    test('a comma is a thousands separator only before three digits', () {
      expect(parseNumericToken('1,046kJ')?.value, 1046);
      expect(parseNumericToken('2,5 g')?.value, closeTo(2.5, 0.001));
      expect(parseNumericToken('0,8')?.value, closeTo(0.8, 0.001));
      // Both separators: the rightmost one is the decimal.
      expect(parseNumericToken('1,046.5')?.value, closeTo(1046.5, 0.001));
    });

    test('"less than" is read as half the bound and marked', () {
      final short = parseNumericToken('<1g')!;
      expect(short.value, closeTo(0.5, 0.001));
      expect(short.isBound, isTrue);
      expect(short.unit, UnitKind.gram);

      final spelled = parseNumericToken('less than 0.5 g')!;
      expect(spelled.value, closeTo(0.25, 0.001));
      expect(spelled.isBound, isTrue);
    });

    test('a stated zero and a trace are told apart', () {
      final nil = parseNumericToken('Nil')!;
      expect(nil.value, 0);
      expect(nil.isBound, isFalse);
      expect(nil.isTrace, isFalse);

      final trace = parseNumericToken('Trace')!;
      expect(trace.value, 0);
      expect(trace.isTrace, isTrue);
    });

    test('letters read as digits are repaired, and the repair is flagged', () {
      final letterO = parseNumericToken('O.5')!;
      expect(letterO.value, closeTo(0.5, 0.001));
      expect(letterO.digitsRepaired, isTrue);

      final mixed = parseNumericToken('1O.5g')!;
      expect(mixed.value, closeTo(10.5, 0.001));
      expect(mixed.unit, UnitKind.gram);
      expect(mixed.digitsRepaired, isTrue);

      expect(parseNumericToken('5.2g')?.digitsRepaired, isFalse);
    });

    test('a word is never a number, however digit-like its letters', () {
      // The load-bearing case: without the "everything after the number
      // must be a unit we know" rule, `S0dium` reads as 51.
      expect(parseNumericToken('S0dium'), isNull);
      expect(parseNumericToken('Protein'), isNull);
      expect(parseNumericToken('Iron'), isNull);
      expect(parseNumericToken('lOOg'), isNull);
      expect(parseNumericToken('D3'), isNull);
      expect(parseNumericToken('2/3'), isNull);
      expect(parseNumericToken('2L'), isNull);
      expect(parseNumericToken(''), isNull);
      expect(parseNumericToken('-'), isNull);
    });

    test('a percentage is recognised so it can be discarded', () {
      expect(parseNumericToken('10%')?.unit, UnitKind.percent);
      expect(parseNumericToken('10%DI')?.unit, UnitKind.percent);
      expect(parseNumericToken('45%')?.unit, UnitKind.percent);
    });

    test('a lone unit is a unit, a number with one is not', () {
      expect(isUnitOnlyToken('g'), isTrue);
      expect(isUnitOnlyToken('kJ'), isTrue);
      expect(isUnitOnlyToken('%'), isTrue);
      expect(isUnitOnlyToken('5.2g'), isFalse);
      expect(isUnitOnlyToken('Protein'), isFalse);
    });
  });

  group('matching a nutrient name', () {
    LabelField? fieldOf(String raw) => matchLabelField(raw)?.field;

    test('the names panels actually print', () {
      expect(fieldOf('Energy'), LabelField.energy);
      expect(fieldOf('Calories'), LabelField.energy);
      expect(fieldOf('Protein'), LabelField.protein);
      expect(fieldOf('Total Fat'), LabelField.fat);
      expect(fieldOf('Fat, total'), LabelField.fat);
      expect(fieldOf('Total Carbohydrate'), LabelField.carbs);
      expect(fieldOf('Carbohydrate'), LabelField.carbs);
      expect(fieldOf('Dietary Fibre'), LabelField.fiber);
      expect(fieldOf('Dietary Fiber'), LabelField.fiber);
      expect(fieldOf('Sodium'), LabelField.sodium);
      expect(fieldOf('Salt'), LabelField.salt);
      expect(fieldOf('Vitamin D'), LabelField.vitaminD);
      expect(fieldOf('Iron'), LabelField.iron);
      expect(fieldOf('Potassium'), LabelField.potassium);
    });

    test('a qualified sub-row resolves to the nutrient, not its parent', () {
      expect(fieldOf('- saturated'), LabelField.saturatedFat);
      expect(fieldOf('of which saturates'), LabelField.saturatedFat);
      expect(fieldOf('Saturated Fat'), LabelField.saturatedFat);
      expect(fieldOf('of which sugars'), LabelField.sugars);
      expect(fieldOf('Total Sugars'), LabelField.sugars);
      expect(fieldOf('Includes Added Sugars'), LabelField.addedSugars);
      expect(fieldOf('Trans Fat'), LabelField.transFat);
    });

    test('digit-for-letter confusions in a name are repaired', () {
      expect(fieldOf('S0dium'), LabelField.sodium);
      expect(fieldOf('Pr0tein'), LabelField.protein);
    });

    test('a mangled name matches within edit distance, and reports it', () {
      final match = matchLabelField('Saturatecl')!;
      expect(match.field, LabelField.saturatedFat);
      expect(match.distance, 2);
      expect(matchLabelField('Protein')!.distance, 0);
    });

    test('a short name gets no slack at all', () {
      // "fat" and "salt" are three and four characters; one edit of
      // tolerance would let them claim their neighbours' rows.
      expect(fieldOf('Fat'), LabelField.fat);
      expect(fieldOf('Bat'), isNull);
      expect(fieldOf('Malt'), isNull);
    });

    test('text that is not a nutrient name matches nothing', () {
      expect(fieldOf('Servings per package:'), isNull);
      expect(fieldOf('Serving size:'), isNull);
      expect(fieldOf('NUTRITION INFORMATION'), isNull);
      expect(fieldOf('MILK 2L'), isNull);
      expect(fieldOf('TOTAL'), isNull);
      expect(fieldOf('EFTPOS'), isNull);
      expect(fieldOf('Fa'), isNull);
      expect(fieldOf(''), isNull);
    });
  });

  group('conversions', () {
    test('salt to sodium uses 400 mg per gram', () {
      expect(saltGramsToSodiumMg(1.25), closeTo(500, 0.001));
      expect(saltGramsToSodiumMg(0), 0);
    });

    test('kilojoules to kilocalories uses 4.184', () {
      expect(kilojoulesToKilocalories(4.184), closeTo(1, 0.0001));
      expect(kilojoulesToKilocalories(830), closeTo(198.375, 0.01));
    });

    test('mass conversions stay inside the mass family', () {
      expect(
        convertMass(0.12, UnitKind.gram, UnitKind.milligram),
        closeTo(120, 0.0001),
      );
      expect(
        convertMass(2000, UnitKind.microgram, UnitKind.milligram),
        closeTo(2, 0.0001),
      );
      expect(convertMass(1, UnitKind.kilojoule, UnitKind.gram), isNull);
      expect(convertMass(1, UnitKind.millilitre, UnitKind.gram), isNull);
    });

    test('each nutrient has one canonical unit', () {
      expect(canonicalUnitFor(LabelField.protein), UnitKind.gram);
      expect(canonicalUnitFor(LabelField.sodium), UnitKind.milligram);
      expect(canonicalUnitFor(LabelField.iron), UnitKind.milligram);
      expect(canonicalUnitFor(LabelField.vitaminD), UnitKind.microgram);
      expect(canonicalUnitFor(LabelField.energy), UnitKind.kilocalorie);
    });
  });

  group('heading normalisation', () {
    test('folds the glyphs OCR confuses, in both directions', () {
      expect(normaliseHeaderText('Per lOOg'), normaliseHeaderText('Per 100g'));
      expect(normaliseHeaderText('Per 1OO g'), normaliseHeaderText('per 100g'));
      expect(
        normaliseHeaderText('Per Serving'),
        normaliseHeaderText('per servlng'),
      );
    });

    test('drops punctuation but keeps digits and the percent sign', () {
      expect(normaliseHeaderText('Per 100 g:'), 'per100g');
      expect(normaliseHeaderText('%DI'), '%d1');
    });
  });
}
