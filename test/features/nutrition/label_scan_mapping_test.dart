import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_warnings.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/nutrition_label_parser.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/parsed_nutrition_label.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_state.dart';
import 'package:menfit_app/features/nutrition/presentation/label_scan_fields.dart';
import 'package:menfit_app/features/nutrition/presentation/label_scan_merge.dart';

import 'label_ocr/label_fixtures.dart';

/// What a photographed panel puts in the form, and what it refuses to.
///
/// Two rules carry the whole feature and are asserted here rather than
/// through the widget tree, because they are arithmetic-free statements
/// about data:
///
/// 1. **Unknown is blank, never `0`.** `ParsedColumn.toNutritionFacts()`
///    cannot express an unread core macro — `NutritionFacts` requires
///    energy and the three macros, so it emits `0` — which is why the
///    mapping reads the nullable `ParsedValue` fields and this test exists
///    to say so.
/// 2. **A scan fills blanks and never overwrites.** What the user typed is
///    theirs; where the panel disagrees, the disagreement is reported.
void main() {
  const parser = NutritionLabelParser();

  ParsedValue reading(double value, {double confidence = 0.9}) => ParsedValue(
    value: value,
    unitAsRead: 'g',
    confidence: confidence,
    sourceText: '$value g',
  );

  ParsedNutritionLabel labelWith({
    ParsedColumn? perServing,
    ParsedColumn? per100,
    ParsedServing? serving,
    List<String> warnings = const [],
  }) => ParsedNutritionLabel(
    format: LabelFormat.fsanz,
    warnings: warnings,
    serving: serving,
    perServing: perServing,
    per100: per100,
  );

  group('mapParsedLabel', () {
    test('a nutrient the panel never stated has no entry at all', () {
      // Not `'0'`, and not `''` either: an absent key is what the merge
      // reads as "leave that field alone".
      final fields = mapParsedLabel(
        labelWith(
          serving: const ParsedServing(description: '30 g', grams: 30),
          perServing: ParsedColumn(
            basis: ColumnBasis.perServing,
            energyKcal: reading(198),
            proteinG: reading(5.2),
          ),
        ),
      );

      expect(fields.values[ScanField.calories], '198');
      expect(fields.values[ScanField.protein], '5.2');
      // Unread core macros.
      expect(fields.values.containsKey(ScanField.carbs), isFalse);
      expect(fields.values.containsKey(ScanField.fat), isFalse);
      // Unread optional nutrients.
      expect(fields.values.containsKey(ScanField.iron), isFalse);
      expect(fields.values.containsKey(ScanField.sodium), isFalse);
      expect(fields.values.values, isNot(contains('0')));
    });

    test('a stated zero is kept as a zero', () {
      // The other half of rule 1: "the panel says none" is a real reading
      // and must survive, or every trace figure would silently vanish.
      final fields = mapParsedLabel(
        labelWith(
          serving: const ParsedServing(description: '30 g', grams: 30),
          perServing: ParsedColumn(
            basis: ColumnBasis.perServing,
            energyKcal: reading(198),
            transFatG: reading(0),
          ),
        ),
      );

      expect(fields.values[ScanField.transFat], '0');
    });

    test('prefers per serving when the panel stated a serving weight', () {
      final fields = mapParsedLabel(
        labelWith(
          serving: const ParsedServing(
            description: '1 biscuit (30 g)',
            grams: 30,
          ),
          perServing: ParsedColumn(
            basis: ColumnBasis.perServing,
            energyKcal: reading(198),
          ),
          per100: ParsedColumn(
            basis: ColumnBasis.per100g,
            energyKcal: reading(662),
          ),
        ),
      );

      expect(fields.basis, LabelScanBasis.serving);
      expect(fields.values[ScanField.calories], '198');
      expect(fields.servingGrams, '30');
      expect(fields.servingDescription, '1 biscuit (30 g)');
    });

    test('falls back to per 100 g when no serving weight was printed', () {
      final fields = mapParsedLabel(
        labelWith(
          serving: const ParsedServing(description: '1 biscuit'),
          perServing: ParsedColumn(
            basis: ColumnBasis.perServing,
            energyKcal: reading(198),
          ),
          per100: ParsedColumn(
            basis: ColumnBasis.per100g,
            energyKcal: reading(662),
          ),
        ),
      );

      expect(fields.basis, LabelScanBasis.per100g);
      expect(fields.values[ScanField.calories], '662');
      expect(fields.servingGrams, isEmpty);
    });

    test('a per-100 mL panel keeps its own basis and carries no weight', () {
      final fields = mapParsedLabel(
        labelWith(
          serving: const ParsedServing(description: '250 mL', millilitres: 250),
          per100: ParsedColumn(
            basis: ColumnBasis.per100ml,
            energyKcal: reading(47),
          ),
          warnings: const [warnPer100Millilitres],
        ),
      );

      expect(fields.basis, LabelScanBasis.per100ml);
      expect(fields.needsWeight, isTrue);
      // A millilitre is not a mass (`knowledge/domain/nutrition.md`).
      expect(fields.servingGrams, isEmpty);
      // The parser's wording is replaced by one that says what to do next.
      expect(fields.warnings, contains(labelScanPerVolumeWarning));
      expect(fields.warnings, isNot(contains(warnPer100Millilitres)));
    });

    test('marks only the readings below the check threshold', () {
      final fields = mapParsedLabel(
        labelWith(
          serving: const ParsedServing(description: '30 g', grams: 30),
          perServing: ParsedColumn(
            basis: ColumnBasis.perServing,
            energyKcal: reading(198, confidence: 0.95),
            proteinG: reading(5.2, confidence: labelScanCheckThreshold),
            carbsG: reading(18.6, confidence: 0.4),
          ),
        ),
      );

      expect(fields.lowConfidenceFields, {ScanField.carbs});
    });
  });

  group('mapParsedLabel over the parser, on fixtures', () {
    test('an FSANZ panel lands on its per-serving column', () {
      final fields = mapParsedLabel(parser.parse(fsanzTwoColumn()));

      expect(fields.basis, LabelScanBasis.serving);
      expect(fields.servingGrams, '30');
      expect(fields.values[ScanField.calories], '198');
      expect(fields.values[ScanField.protein], '5.2');
      expect(fields.values[ScanField.carbs], '18.6');
      expect(fields.values[ScanField.fat], '10.2');
      expect(fields.values[ScanField.saturatedFat], '4.1');
      expect(fields.values[ScanField.fiber], '3.4');
      expect(fields.values[ScanField.sodium], '115');
      // Nothing this panel does not print.
      expect(fields.values.containsKey(ScanField.iron), isFalse);
      expect(fields.values.containsKey(ScanField.calcium), isFalse);
      expect(fields.values.containsKey(ScanField.vitaminD), isFalse);
      expect(fields.lowConfidenceFields, isEmpty);
    });

    test('a noisy panel marks what it was unsure of', () {
      final fields = mapParsedLabel(parser.parse(fsanzNoisy()));

      // "Saturatecl" is read, and trusted less for having been guessed at.
      expect(fields.values[ScanField.saturatedFat], '4.1');
      expect(fields.lowConfidenceFields, contains(ScanField.saturatedFat));
      // A clean reading on the same panel is not marked.
      expect(
        fields.lowConfidenceFields,
        isNot(contains(ScanField.protein)),
      );
    });

    test('a drink panel asks for a weight instead of inventing one', () {
      final fields = mapParsedLabel(parser.parse(fsanzPer100Millilitres()));

      expect(fields.basis, LabelScanBasis.per100ml);
      expect(fields.servingGrams, isEmpty);
      expect(fields.values[ScanField.carbs], '10.6');
      expect(fields.warnings, contains(labelScanPerVolumeWarning));
    });
  });

  group('applyLabelScan', () {
    const blank = FoodFormState();

    test('fills blank fields and sets the basis from the panel', () {
      final next = applyLabelScan(
        blank,
        mapParsedLabel(parser.parse(fsanzTwoColumn())),
      );

      expect(next.calories, '198');
      expect(next.protein, '5.2');
      expect(next.basisMode, FoodBasisMode.serving);
      expect(next.basisUnit, 'g');
      expect(next.basisAmount, '30');
      expect(next.labelScanApplied, isTrue);
      expect(next.labelIsPerVolume, isFalse);
    });

    test('never overwrites what they typed, and says where it differed', () {
      final next = applyLabelScan(
        blank.copyWith(calories: '210', protein: '5.2'),
        mapParsedLabel(parser.parse(fsanzTwoColumn())),
      );

      expect(next.calories, '210', reason: 'their value wins');
      expect(
        next.labelWarnings,
        contains('Kept your value for calories (label read 198).'),
      );
      // A value they typed that agrees with the panel is not worth a note.
      expect(
        next.labelWarnings.where((w) => w.contains('protein')),
        isEmpty,
      );
      // Nor is it "read off a label", so it carries no check marker.
      expect(next.lowConfidenceFields, isNot(contains(ScanField.calories)));
    });

    test('leaves an amount they already set alone', () {
      final next = applyLabelScan(
        blank.copyWith(basisAmount: '45', basisUnit: 'g'),
        mapParsedLabel(parser.parse(fsanzTwoColumn())),
      );

      expect(next.basisAmount, '45');
      expect(
        next.labelWarnings,
        contains(
          'Kept your amount and unit — check they match what the label is '
          'per.',
        ),
      );
    });

    test('a per-100 mL panel fills the numbers and blanks the amount', () {
      final next = applyLabelScan(
        blank,
        mapParsedLabel(parser.parse(fsanzPer100Millilitres())),
      );

      expect(next.carbs, '10.6');
      expect(next.basisMode, FoodBasisMode.perReference);
      expect(next.basisAmount, isEmpty);
      expect(next.labelIsPerVolume, isTrue);
      expect(next.needsWeightForVolumeLabel, isTrue);
      // And stops being a blocker once they supply the weight — which
      // means *setting the field*, not merely the field holding a number.
      // `FoodFormController.updateBasisAmount` writes both, and a
      // `copyWith` that moved only the amount would be reproducing the
      // hole this guard closes (a weight that was already there is not an
      // answer to a label they have just photographed).
      expect(
        next
            .copyWith(basisAmount: '104', labelVolumeWeightConfirmed: true)
            .needsWeightForVolumeLabel,
        isFalse,
      );
    });
  });

  group('a per-100 mL panel cannot be saved as per 100 g', () {
    // The regression this group exists for: every route by which the
    // "supply a weight" guard used to fall away, leaving `_effectiveServing`
    // to read a blank amount as 100 and file per-100 mL figures as
    // per-100 g without anybody being told.
    const blank = FoodFormState();
    final volumeLabel = mapParsedLabel(
      parser.parse(fsanzPer100Millilitres()),
    );

    test('a SECOND scan of the same panel does not clear the guard', () {
      // The flag used to be derived from "was the basis untouched", and the
      // first scan is what touches the basis — so scanning twice cleared
      // it and the save went through.
      final once = applyLabelScan(blank, volumeLabel);
      final twice = applyLabelScan(once, volumeLabel);

      expect(once.needsWeightForVolumeLabel, isTrue);
      expect(twice.labelIsPerVolume, isTrue);
      expect(twice.basisAmount, isEmpty);
      expect(twice.needsWeightForVolumeLabel, isTrue);
    });

    test('a weight typed BEFORE the scan is not an answer to it', () {
      // They were defining a food by weight and then photographed a drink
      // printed per 100 mL. The two numbers have nothing to do with each
      // other, and their 250 g is not a claim about what 100 mL weighs.
      final after = applyLabelScan(
        blank.copyWith(basisAmount: '250', basisUnit: 'g'),
        volumeLabel,
      );

      expect(after.basisAmount, '250', reason: 'their value is never replaced');
      expect(after.labelIsPerVolume, isTrue);
      expect(after.labelVolumeWeightConfirmed, isFalse);
      expect(after.needsWeightForVolumeLabel, isTrue);
    });

    test('a per-100 g scan afterwards does not clear it either', () {
      // The values on the form are still the ones printed per 100 mL.
      final after = applyLabelScan(
        applyLabelScan(blank, volumeLabel),
        mapParsedLabel(parser.parse(fsanzTwoColumn())),
      );

      expect(after.labelIsPerVolume, isTrue);
      expect(after.needsWeightForVolumeLabel, isTrue);
    });

    test('clearing the amount again brings the guard back', () {
      // Confirmed once is not confirmed forever: an empty amount is read as
      // 100 by `_effectiveServing`, whenever it becomes empty.
      final confirmed = applyLabelScan(blank, volumeLabel).copyWith(
        basisAmount: '104',
        labelVolumeWeightConfirmed: true,
      );

      expect(confirmed.needsWeightForVolumeLabel, isFalse);
      expect(
        confirmed.copyWith(basisAmount: '').needsWeightForVolumeLabel,
        isTrue,
      );
    });

    test('a panel that is not per volume never sets the guard', () {
      final after = applyLabelScan(
        blank,
        mapParsedLabel(parser.parse(fsanzTwoColumn())),
      );

      expect(after.labelIsPerVolume, isFalse);
      expect(after.needsWeightForVolumeLabel, isFalse);
    });
  });

  group('markers across two scans', () {
    test('a marker survives a scan that did not refill its field', () {
      // The noisy panel marks saturated fat. A second scan of a panel that
      // states no saturated fat leaves that number exactly where it is —
      // still read off a photo, still unsure — so the marker stays.
      const blank = FoodFormState();
      final noisy = applyLabelScan(
        blank,
        mapParsedLabel(parser.parse(fsanzNoisy())),
      );
      expect(noisy.lowConfidenceFields, contains(ScanField.saturatedFat));

      final second = applyLabelScan(
        noisy,
        mapParsedLabel(parser.parse(unattributablePanel())),
      );

      expect(second.saturatedFat, '4.1', reason: 'the value is untouched');
      expect(second.lowConfidenceFields, contains(ScanField.saturatedFat));
    });
  });

  group('the copy the button carries', () {
    test('promises what the camera permission string promises', () {
      // The same promise in two places: the iOS prompt the user sees once,
      // and the line under the button they see every time. A guard on only
      // one of them lets the other quietly drop a claim the implementation
      // still keeps (ADR 012 — nothing leaves the phone, and the photo is
      // deleted in a `finally`).
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      final permission = RegExp(
        r'<key>NSCameraUsageDescription</key>\s*<string>(.*?)</string>',
        dotAll: true,
      ).firstMatch(plist)?.group(1);

      expect(permission, isNotNull);
      for (final claim in [
        (
          'names the nutrition panel',
          RegExp('nutrition (label|panel)', caseSensitive: false),
        ),
        (
          'says the reading happens on the device',
          RegExp('on your (device|phone)', caseSensitive: false),
        ),
        (
          'says the photo is discarded',
          RegExp('discarded', caseSensitive: false),
        ),
      ]) {
        expect(
          permission,
          matches(claim.$2),
          reason: 'NSCameraUsageDescription ${claim.$1}',
        );
        expect(
          labelScanExplainerText,
          matches(claim.$2),
          reason: 'the button explainer ${claim.$1}',
        );
      }
    });
  });

  group('FoodFormSeed.fromParsedLabel', () {
    test('seeds the fields, and blanks for whatever was not printed', () {
      final seed = FoodFormSeed.fromParsedLabel(
        parser.parse(fsanzTwoColumn()),
      );

      expect(seed.calories, '198');
      expect(seed.protein, '5.2');
      expect(seed.carbs, '18.6');
      expect(seed.fat, '10.2');
      expect(seed.servingGrams, '30');
      expect(seed.hasCompleteMacros, isTrue);
      // Unread optional nutrients seed a blank field, never a zero.
      expect(seed.iron, isEmpty);
      expect(seed.calcium, isEmpty);
      expect(seed.vitaminD, isEmpty);
    });

    test("a photographed label is the user's own data, not a database's", () {
      final seed = FoodFormSeed.fromParsedLabel(
        parser.parse(fsanzTwoColumn()),
        barcode: '5000112637922',
      );

      // ADR 010: `source` records where the data came from. Nobody's
      // database supplied this; their camera did.
      expect(seed.source, FoodSource.custom);
      expect(seed.foundInDatabase, isFalse);
      expect(seed.barcode, '5000112637922');
    });

    test('carries no amount for a per-100 mL panel', () {
      final seed = FoodFormSeed.fromParsedLabel(
        parser.parse(fsanzPer100Millilitres()),
      );

      expect(seed.servingBasis, isNull);
      expect(seed.servingGrams, isEmpty);
      expect(seed.carbs, '10.6');
    });
  });
}
