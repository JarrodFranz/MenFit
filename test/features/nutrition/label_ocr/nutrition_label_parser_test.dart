import 'package:flutter_test/flutter_test.dart';

import 'package:menfit_app/core/domain/ocr/ocr_text.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_warnings.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/nutrition_label_parser.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/parsed_nutrition_label.dart';

import 'label_fixtures.dart';

/// The parser against the transcribed corpus in `label_fixtures.dart`.
///
/// Read that file's header first: these panels were **written by hand to
/// model** ML Kit output, not captured from real packaging. They pin the
/// parser's rules down; they say nothing about how it behaves on a photo
/// taken in a supermarket aisle, which is a separate, still-outstanding
/// piece of work (ADR 012).
/// Every value the parser managed to place in a column.
///
/// Replaces the old `ParsedNutritionLabel.raw`, which was removed for
/// having no reader in `lib/`. The counts here are one higher per column
/// than the raw ones were wherever a figure is *derived* (calories from
/// kilojoules, sodium from salt) rather than read.
int placedValues(ParsedNutritionLabel label) =>
    (label.perServing?.values.length ?? 0) + (label.per100?.values.length ?? 0);

void main() {
  const parser = NutritionLabelParser();

  group('FSANZ two-column panel', () {
    final label = parser.parse(fsanzTwoColumn());

    test('recognises the standard and the serving statement', () {
      expect(label.format, LabelFormat.fsanz);
      expect(label.serving?.description, '30g');
      expect(label.serving?.grams, 30);
      expect(label.serving?.servingsPerPackage, 12);
      expect(label.serving?.millilitres, isNull);
    });

    test('reads both columns and keeps them apart', () {
      final perServing = label.perServing!;
      expect(perServing.basis, ColumnBasis.perServing);
      expect(perServing.energyKj?.value, 830);
      expect(perServing.energyKcal?.value, 198);
      expect(perServing.proteinG?.value, closeTo(5.2, 0.001));
      expect(perServing.fatG?.value, closeTo(10.2, 0.001));
      expect(perServing.saturatedFatG?.value, closeTo(4.1, 0.001));
      expect(perServing.carbsG?.value, closeTo(18.6, 0.001));
      expect(perServing.sugarsG?.value, closeTo(2.1, 0.001));
      expect(perServing.fiberG?.value, closeTo(3.4, 0.001));
      expect(perServing.sodiumMg?.value, 115);

      final per100 = label.per100!;
      expect(per100.basis, ColumnBasis.per100g);
      expect(per100.energyKj?.value, 2770);
      expect(per100.energyKcal?.value, 662);
      expect(per100.proteinG?.value, closeTo(17.3, 0.001));
      expect(per100.fatG?.value, closeTo(34, 0.001));
      expect(per100.saturatedFatG?.value, closeTo(13.7, 0.001));
      expect(per100.carbsG?.value, closeTo(62, 0.001));
      expect(per100.sugarsG?.value, closeTo(7, 0.001));
      expect(per100.fiberG?.value, closeTo(11.3, 0.001));
      expect(per100.sodiumMg?.value, 383);
    });

    test('reads the bracketed calorie line as energy for its column', () {
      // "(198 Cal)" sits on its own row with no label of its own.
      expect(label.perServing?.energyKcal?.sourceText, '(198Cal)');
      expect(label.per100?.energyKcal?.sourceText, '(662Cal)');
    });

    test('a clean panel produces no cautions and reads every row', () {
      expect(label.warnings, isEmpty);
      expect(label.perServing?.hasCompleteMacros, isTrue);
      // Nine rows read in each of the two quantity columns.
      expect(placedValues(label), 18);
    });

    test('a cleanly read row scores high, and the inferred one scores '
        'lower on purpose', () {
      // Replaces an assertion on the removed `overallConfidence`, which
      // was a *mean* — and a mean hid the one interesting number on this
      // panel. Every labelled row here scores 0.98; the calorie figure
      // scores 0.833 because "(198 Cal)" sits on its own line with no
      // label of its own, so its row is matched by position rather than
      // read (`_readRow`, distance 1, x0.85). That is a property of the
      // FSANZ layout, not a defect in the photo.
      final perServing = label.perServing!;
      expect(perServing.proteinG!.confidence, greaterThan(0.9));
      expect(perServing.carbsG!.confidence, greaterThan(0.9));
      expect(perServing.fatG!.confidence, greaterThan(0.9));

      expect(
        perServing.energyKcal!.confidence,
        lessThan(perServing.proteinG!.confidence),
      );
      // ...and still comfortably clear of the review form's "check this"
      // threshold of 0.6 (`presentation/label_scan_fields.dart`), so a
      // clean panel raises no markers at all. The number is restated
      // rather than imported: this is a domain test, and the parser knows
      // nothing about the form that reads it.
      expect(perServing.energyKcal!.confidence, greaterThan(0.8));
    });

    test('what the panel does not state stays unknown, never zero', () {
      final perServing = label.perServing!;
      expect(perServing.ironMg, isNull);
      expect(perServing.calciumMg, isNull);
      expect(perServing.potassiumMg, isNull);
      expect(perServing.cholesterolMg, isNull);
      expect(perServing.vitaminDMcg, isNull);
      expect(perServing.vitaminCMg, isNull);
      expect(perServing.transFatG, isNull);
      expect(perServing.addedSugarsG, isNull);

      final facts = perServing.toNutritionFacts();
      expect(facts.caloriesKcal, 198);
      expect(facts.proteinGrams, closeTo(5.2, 0.001));
      expect(facts.carbsGrams, closeTo(18.6, 0.001));
      expect(facts.fatGrams, closeTo(10.2, 0.001));
      expect(facts.saturatedFatGrams, closeTo(4.1, 0.001));
      expect(facts.fiberGrams, closeTo(3.4, 0.001));
      expect(facts.sugarsGrams, closeTo(2.1, 0.001));
      expect(facts.sodiumMg, 115);
      // The thirteen optional nutrients keep "unknown" as null.
      expect(facts.ironMg, isNull);
      expect(facts.calciumMg, isNull);
      expect(facts.potassiumMg, isNull);
      expect(facts.cholesterolMg, isNull);
      expect(facts.vitaminDMcg, isNull);
      expect(facts.vitaminCMg, isNull);
      expect(facts.transFatGrams, isNull);
      expect(facts.addedSugarsGrams, isNull);
      expect(facts.monounsaturatedFatGrams, isNull);
      expect(facts.polyunsaturatedFatGrams, isNull);
    });
  });

  group('the same panel with OCR noise', () {
    final clean = parser.parse(fsanzTwoColumn());
    final noisy = parser.parse(fsanzNoisy());

    test('reads through digit-for-letter confusions in nutrient names', () {
      // "Pr0tein" and "S0dium".
      expect(noisy.perServing?.proteinG?.value, closeTo(5.2, 0.001));
      expect(noisy.perServing?.sodiumMg?.value, 115);
    });

    test('reads a mangled nutrient name within edit distance', () {
      // "Saturatecl".
      expect(noisy.perServing?.saturatedFatG?.value, closeTo(4.1, 0.001));
    });

    test('glues a number the engine split in two back together', () {
      // "1" + "0.2" + "g", emitted as three elements.
      expect(noisy.perServing?.fatG?.value, closeTo(10.2, 0.001));
    });

    test('repairs a letter O inside a number, and says it did', () {
      // "34.O" in the per-100 g column.
      expect(noisy.per100?.fatG?.value, closeTo(34, 0.001));
      expect(noisy.warnings, contains(warnRepairedDigits));
    });

    test('every kind of noise costs confidence', () {
      expect(
        noisy.perServing!.proteinG!.confidence,
        lessThan(clean.perServing!.proteinG!.confidence),
      );
      // A mangled name is read, but trusted less than a clean one on the
      // same panel.
      expect(
        noisy.perServing!.saturatedFatG!.confidence,
        lessThan(noisy.perServing!.proteinG!.confidence),
      );
      // A repaired digit is trusted less than a clean number beside it.
      expect(
        noisy.per100!.fatG!.confidence,
        lessThan(noisy.per100!.proteinG!.confidence),
      );
    });
  });

  group('FSANZ with a %DI column', () {
    final label = parser.parse(fsanzThreeColumn());

    test('the quantity columns are still read correctly', () {
      expect(label.perServing?.proteinG?.value, closeTo(5.2, 0.001));
      expect(label.per100?.proteinG?.value, closeTo(17.3, 0.001));
      expect(label.perServing?.sodiumMg?.value, 115);
      expect(label.per100?.sodiumMg?.value, 383);
    });

    test('percentages never become values', () {
      // Four nutrient rows x two quantity columns, plus the calorie figure
      // each column derives from its kilojoules. If any of the "9%",
      // "10%", "15%" or "5%" tokens had been read, this would be larger.
      expect(placedValues(label), 10);
      for (final column in [label.perServing!, label.per100!]) {
        for (final value in column.values) {
          expect(value.unitAsRead, isNot('%'));
        }
      }
    });
  });

  group('a per-100 mL drink', () {
    final label = parser.parse(fsanzPer100Millilitres());

    test('lands in per100 with millilitres flagged, not as grams', () {
      expect(label.perServing, isNull);
      expect(label.per100?.basis, ColumnBasis.per100ml);
      expect(label.warnings, contains(warnPer100Millilitres));
    });

    test('a serving volume is never recorded as a serving weight', () {
      expect(label.serving?.millilitres, 250);
      expect(label.serving?.grams, isNull);
    });

    test('the numbers themselves are read', () {
      expect(label.per100?.energyKj?.value, 195);
      expect(label.per100?.proteinG?.value, closeTo(0.5, 0.001));
      expect(label.per100?.carbsG?.value, closeTo(10.6, 0.001));
      expect(label.per100?.sodiumMg?.value, 8);
    });
  });

  group('US FDA Nutrition Facts', () {
    final label = parser.parse(usFdaPanel());

    test('recognises the standard and the serving statement', () {
      expect(label.format, LabelFormat.usFda);
      expect(label.serving?.grams, 55);
      expect(label.serving?.servingsPerPackage, 8);
      expect(label.serving?.description, '2/3 cup (55g)');
    });

    test('a bare "Calories" number is energy in kilocalories', () {
      expect(label.perServing?.energyKcal?.value, 230);
      expect(label.perServing?.energyKj, isNull);
    });

    test('reads the single column and drops the %DV one', () {
      final column = label.perServing!;
      expect(label.per100, isNull);
      expect(column.fatG?.value, 8);
      expect(column.saturatedFatG?.value, 1);
      expect(column.transFatG?.value, 0);
      expect(column.cholesterolMg?.value, 0);
      expect(column.sodiumMg?.value, 160);
      expect(column.carbsG?.value, 37);
      expect(column.fiberG?.value, 4);
      expect(column.sugarsG?.value, 12);
      expect(column.proteinG?.value, 3);
      expect(column.vitaminDMcg?.value, 2);
      expect(column.calciumMg?.value, 260);
      expect(column.ironMg?.value, 8);
      expect(column.potassiumMg?.value, 235);
      // 15 values read, and not one of the eight percentages among them.
      expect(placedValues(label), 15);
    });

    test('reads a row whose number sits inside its own name', () {
      // "Includes 10g Added Sugars 20%".
      expect(label.perServing?.addedSugarsG?.value, 10);
    });

    test('a stated zero is zero, not unknown', () {
      expect(label.perServing?.transFatG?.value, 0);
      expect(label.perServing?.toNutritionFacts().transFatGrams, 0);
    });
  });

  group('EU/UK typical values', () {
    final label = parser.parse(euUkPanel());

    test('recognises the standard and the single per-100 g column', () {
      expect(label.format, LabelFormat.euUk);
      expect(label.perServing, isNull);
      expect(label.per100?.basis, ColumnBasis.per100g);
    });

    test('reads "of which" sub-rows as their own nutrients', () {
      expect(label.per100?.saturatedFatG?.value, closeTo(3.1, 0.001));
      expect(label.per100?.sugarsG?.value, closeTo(5.2, 0.001));
      expect(label.per100?.fatG?.value, closeTo(12.5, 0.001));
      expect(label.per100?.carbsG?.value, closeTo(62.4, 0.001));
    });

    test('converts salt to sodium and says so', () {
      // 1.25 g of salt carries 500 mg of sodium.
      expect(label.per100?.sodiumMg?.value, closeTo(500, 0.001));
      expect(label.warnings, contains(warnSodiumDerivedFromSalt));
      // The derived figure carries no printed unit: nothing on the panel
      // stated one for sodium.
      expect(label.per100?.sodiumMg?.unitAsRead, '');
      expect(label.per100?.sodiumMg?.sourceText, '1.25g');
    });

    test('both energy figures were printed, so neither is derived', () {
      expect(label.per100?.energyKj?.value, 1046);
      expect(label.per100?.energyKcal?.value, 250);
      expect(
        label.warnings,
        isNot(contains(warnEnergyDerivedFromKilojoules)),
      );
      expect(label.warnings, isNot(contains(warnEnergyFiguresDisagree)));
    });
  });

  group('comma decimals', () {
    final label = parser.parse(commaDecimalPanel());

    test('a comma before three digits is a thousands separator', () {
      expect(label.per100?.energyKj?.value, 1046);
    });

    test('a comma before one or two digits is a decimal point', () {
      expect(label.per100?.fatG?.value, closeTo(12.5, 0.001));
      expect(label.per100?.proteinG?.value, closeTo(5.2, 0.001));
      expect(label.per100?.sodiumMg?.value, closeTo(320, 0.001));
    });
  });

  group('bounds and stated zeroes', () {
    final label = parser.parse(boundedValuePanel());

    test('"<1 g" is read as half the bound, with low confidence', () {
      final sugars = label.perServing!.sugarsG!;
      expect(sugars.value, closeTo(0.5, 0.001));
      expect(sugars.confidence, lessThanOrEqualTo(0.5));
      expect(label.warnings, contains(warnLessThanValues));
    });

    test('"less than 0.5 g" split across four elements reads the same', () {
      expect(label.perServing?.fatG?.value, closeTo(0.25, 0.001));
      expect(label.perServing?.fatG?.sourceText, '<0.5g');
    });

    test('"Nil" is a stated zero', () {
      expect(label.perServing?.sodiumMg?.value, 0);
    });

    test('an unstated macro is null here and only zero in the facts', () {
      final column = label.perServing!;
      expect(column.proteinG, isNull);
      expect(column.carbsG, isNull);
      expect(column.hasCompleteMacros, isFalse);
      // `NutritionFacts` cannot carry "unknown" for the four required
      // fields, so it reports 0. That is a limit of the target type, and
      // callers must pre-fill from the nullable fields above instead.
      final facts = column.toNutritionFacts();
      expect(facts.proteinGrams, 0);
      expect(facts.carbsGrams, 0);
      // The optional ones keep the distinction.
      expect(facts.sodiumMg, 0);
      expect(facts.ironMg, isNull);
    });
  });

  group('kilojoules only', () {
    final label = parser.parse(kilojoulesOnlyPanel());

    test('derives calories, flags them, and trusts them less', () {
      final perServing = label.perServing!;
      expect(perServing.energyKj?.value, 830);
      expect(perServing.energyKcal?.value, closeTo(198.375, 0.01));
      expect(perServing.energyKcal?.unitAsRead, '');
      expect(
        perServing.energyKcal!.confidence,
        lessThan(perServing.energyKj!.confidence),
      );
      expect(label.warnings, contains(warnEnergyDerivedFromKilojoules));
    });

    test('derives for every column, not just the first', () {
      expect(label.per100?.energyKcal?.value, closeTo(662.046, 0.01));
    });
  });

  group('column-major recognition order', () {
    final rowMajor = parser.parse(fsanzTwoColumn());
    final columnMajor = parser.parse(fsanzTwoColumnInterleaved());

    test('rows are rebuilt from geometry, not from block order', () {
      // Same panel, emitted one block per column with the values before
      // the labels — the real ML Kit failure mode.
      expect(columnMajor.format, rowMajor.format);
      expect(
        columnMajor.perServing?.proteinG?.value,
        rowMajor.perServing?.proteinG?.value,
      );
      expect(
        columnMajor.perServing?.sodiumMg?.value,
        rowMajor.perServing?.sodiumMg?.value,
      );
      expect(
        columnMajor.per100?.saturatedFatG?.value,
        rowMajor.per100?.saturatedFatG?.value,
      );
      expect(
        columnMajor.per100?.energyKj?.value,
        rowMajor.per100?.energyKj?.value,
      );
      expect(placedValues(columnMajor), placedValues(rowMajor));
      expect(columnMajor.warnings, isEmpty);
    });
  });

  group('unreadable column headings', () {
    final label = parser.parse(headerlessTwoColumn());
    final withHeadings = parser.parse(kilojoulesOnlyPanel());

    test('columns are inferred from where the numbers sit', () {
      expect(label.perServing?.proteinG?.value, closeTo(5.2, 0.001));
      expect(label.per100?.proteinG?.value, closeTo(17.3, 0.001));
    });

    test('and the guess is declared and costs confidence', () {
      expect(label.warnings, contains(warnColumnsAssumed));
      expect(
        label.perServing!.proteinG!.confidence,
        lessThan(withHeadings.perServing!.proteinG!.confidence),
      );
    });

    test('three columns infer perServing, percentDaily and per100g', () {
      final label3 = parser.parse(headerlessThreeColumn());
      expect(label3.warnings, contains(warnColumnsAssumed));
      expect(label3.perServing?.energyKj?.value, 720);
      expect(label3.perServing?.proteinG?.value, closeTo(15.0, 0.001));
      expect(label3.perServing?.fatG?.value, closeTo(1.5, 0.001));
      expect(label3.per100?.energyKj?.value, 847);
      expect(label3.per100?.proteinG?.value, closeTo(17.6, 0.001));
      expect(label3.per100?.fatG?.value, closeTo(1.8, 0.001));
    });
  });

  group('FSANZ three-column stacked panel', () {
    final label = parser.parse(fsanzThreeColumnStacked());

    test('recognises the standard and the serving statement', () {
      expect(label.format, LabelFormat.fsanz);
      expect(label.serving?.description, '85g');
      expect(label.serving?.grams, 85);
      expect(label.serving?.servingsPerPackage, 2);
    });

    test('detects multi-line stacked headers and skips both header rows', () {
      // Both header rows are skipped, so '85g' from 'Serving 85g' is not
      // mistaken for nutrient data.
      expect(label.perServing, isNotNull);
      expect(label.per100, isNotNull);
      expect(label.perServing?.energyKj?.value, 720);
      expect(label.perServing?.proteinG?.value, closeTo(15.0, 0.001));
      expect(label.perServing?.fatG?.value, closeTo(1.5, 0.001));
      expect(label.perServing?.saturatedFatG?.value, closeTo(0.4, 0.001));
      expect(label.perServing?.carbsG?.value, closeTo(22.0, 0.001));
      expect(label.perServing?.sugarsG?.value, closeTo(1.2, 0.001));
      expect(label.perServing?.sodiumMg?.value, 320);

      expect(label.per100?.energyKj?.value, 847);
      expect(label.per100?.proteinG?.value, closeTo(17.6, 0.001));
      expect(label.per100?.fatG?.value, closeTo(1.8, 0.001));
      expect(label.per100?.saturatedFatG?.value, closeTo(0.5, 0.001));
      expect(label.per100?.carbsG?.value, closeTo(25.9, 0.001));
      expect(label.per100?.sugarsG?.value, closeTo(1.4, 0.001));
      expect(label.per100?.sodiumMg?.value, 376);
    });

    test('middle %DI column is discarded and does not bleed into macros', () {
      // Verify that %DI values (8%, 30%, 2%, etc.) are not in perServing
      // or per100.
      expect(label.perServing?.proteinG?.value, isNot(closeTo(30.0, 0.001)));
      expect(label.per100?.proteinG?.value, isNot(closeTo(30.0, 0.001)));
      expect(label.perServing?.proteinG?.value, closeTo(15.0, 0.001));
      expect(label.per100?.proteinG?.value, closeTo(17.6, 0.001));
    });
  });

  group('a panel whose standard cannot be named', () {
    final label = parser.parse(unattributablePanel());

    test('is still read, and says only that it is unattributable', () {
      // A tight crop that lost every heading is not an unreadable photo.
      // The caller must not turn this into "couldn't read a panel" — the
      // numbers are all there (`food_form_controller.dart#scanLabel`).
      expect(label.format, LabelFormat.unknown);
      expect(label.isEmpty, isFalse);
      expect(label.primaryColumn?.proteinG?.value, closeTo(5.2, 0.001));
      expect(label.primaryColumn?.carbsG?.value, closeTo(18.6, 0.001));
      expect(label.primaryColumn?.fatG?.value, closeTo(10.2, 0.001));
      expect(label.warnings, contains(warnUnknownFormat));
    });
  });

  group('column headings as format cues', () {
    test('"per serving" and "calories" are cues in their own right', () {
      // The heading row is the panel. A crop that keeps "Per Serving |
      // Per 100 g" but loses "Nutrition Information" was previously
      // unattributable.
      final cropped = parser.parse(
        panelOf([
          row(0, [
            ('Per', 190),
            ('Serving', 214),
            ('Per', 310),
            ('100g', 333),
          ]),
          ...fsanzTwoColumnRows().skip(4),
        ]),
      );

      expect(cropped.format, LabelFormat.fsanz);
      expect(cropped.warnings, isNot(contains(warnUnknownFormat)));
    });
  });

  group('energy printed as a bare "Calories"', () {
    final label = parser.parse(fsanzBareCaloriesPanel());

    test("the row's own name outranks the panel-wide default", () {
      // An unlabelled energy figure is kilojoules everywhere but a US
      // panel — except on a row that calls itself Calories. Read as 230 kJ
      // this would reach the form as 55 kcal: a quarter of the truth, and
      // entirely plausible-looking.
      expect(label.format, LabelFormat.fsanz);
      expect(label.primaryColumn?.energyKcal?.value, 230);
      expect(label.primaryColumn?.energyKj, isNull);
      expect(
        label.warnings,
        isNot(contains(warnEnergyDerivedFromKilojoules)),
      );
    });
  });

  group('input that is not a nutrition panel', () {
    test('a receipt returns unknown with nothing read, and no throw', () {
      final label = parser.parse(receipt());
      expect(label.format, LabelFormat.unknown);
      expect(label.perServing, isNull);
      expect(label.per100, isNull);
      expect(label.serving, isNull);
      expect(placedValues(label), 0);
      expect(label.isEmpty, isTrue);
      expect(label.warnings, contains(warnNoPanelFound));
    });

    test('an empty result returns unknown rather than throwing', () {
      final label = parser.parse(OcrResult.empty);
      expect(label.format, LabelFormat.unknown);
      expect(label.isEmpty, isTrue);
      expect(label.warnings, isNotEmpty);
    });

    test('degenerate geometry does not throw', () {
      // Every box collapsed to a point: the parser's tolerances are all
      // fractions of the median element height, which is zero here.
      const zero = OcrRect(left: 0, top: 0, right: 0, bottom: 0);
      final label = parser.parse(
        const OcrResult(
          blocks: [
            OcrBlock(
              text: 'Protein 5.2 g',
              box: zero,
              lines: [
                OcrLine(
                  text: 'Protein 5.2 g',
                  box: zero,
                  elements: [
                    OcrElement(text: 'Protein', box: zero),
                    OcrElement(text: '5.2', box: zero),
                    OcrElement(text: 'g', box: zero),
                  ],
                ),
              ],
            ),
          ],
          fullText: 'Protein 5.2 g',
        ),
      );
      expect(label.warnings, isNotEmpty);
    });

    test('blocks with no lines and lines with no elements do not throw', () {
      const box = OcrRect(left: 0, top: 0, right: 40, bottom: 14);
      final label = parser.parse(
        const OcrResult(
          blocks: [
            OcrBlock(text: 'Energy 830 kJ', box: box),
            OcrBlock(
              text: '',
              box: box,
              lines: [OcrLine(text: 'Protein 5.2 g', box: box)],
            ),
          ],
          fullText: 'Energy 830 kJ Protein 5.2 g',
        ),
      );
      // The real expectation, not merely "it returned something".
      //
      // `flattenElements` keeps a degenerate block or line by turning its
      // whole text into a *single* element — nothing is dropped. But the
      // row reader needs the nutrient name and its number in separate
      // elements to tell them apart, and one element reading
      // "Protein 5.2 g" offers no split, so nothing can be placed. The
      // honest answer is "nothing read", which is what the caller turns
      // into "couldn't read a panel"
      // (`food_form_controller.dart#scanLabel` refuses on `isEmpty`).
      //
      // Not a limitation that bites in practice: ML Kit always populates
      // elements. This pins the behaviour for an adapter that does not.
      expect(label.format, LabelFormat.unknown);
      expect(label.isEmpty, isTrue);
      expect(label.perServing, isNull);
      expect(label.per100, isNull);
      expect(label.warnings, contains(warnNoPanelFound));
    });
  });
}
