import 'package:menfit_app/core/domain/ocr/ocr_text.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_column_builder.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_columns.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_lexicon.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_numbers.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_rows.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_serving.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_value_conversion.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_warnings.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/parsed_nutrition_label.dart';

/// Reads a printed nutrition panel out of recognised text.
///
/// Pure Dart, no engine, no plugin, no Flutter — the whole point is that
/// the hard part of ADR 012 is testable from fixtures on any platform,
/// including the two (Web, Windows) that have no OCR path at all.
///
/// The output is a **candidate** (`ParsedNutritionLabel`), never a `Food`.
/// This is a heuristic over noisy input and it is wrong sometimes; the
/// mandatory review form, not this class, is what makes the feature safe.
class NutritionLabelParser {
  const NutritionLabelParser();

  /// Read [ocr] as a nutrition panel.
  ///
  /// Never throws. A receipt, a blurred frame and an empty result all come
  /// back as [LabelFormat.unknown] with no columns and a warning, because
  /// every failure here has a perfectly good manual path behind it and a
  /// crash in front of a camera helps nobody.
  ParsedNutritionLabel parse(OcrResult ocr) {
    try {
      return _parse(ocr);
    } on Object {
      return ParsedNutritionLabel.unrecognised(
        warnings: const [warnCouldNotRead],
      );
    }
  }

  ParsedNutritionLabel _parse(OcrResult ocr) {
    final rows = clusterRows(ocr);
    if (rows.isEmpty) {
      return ParsedNutritionLabel.unrecognised(
        warnings: const [warnNoPanelFound],
      );
    }

    // Insertion-ordered so warnings read top-down, de-duplicated so one
    // repeated cause does not produce a wall of identical lines.
    final warnings = <String>{};
    final format = _detectFormat(ocr, rows);
    final serving = parseServing(rows);
    if (serving != null && serving.hasMultipleGramFigures) {
      warnings.add(warnMultipleServingGramFigures);
    }
    final headerLayout = detectHeaderColumns(rows);
    final readings = _readRows(rows, headerLayout);

    if (readings.isEmpty) {
      warnings.add(warnNoPanelFound);
      return ParsedNutritionLabel(
        format: format,
        serving: serving,
        warnings: warnings.toList(),
      );
    }

    final layout = headerLayout ?? _inferLayout(readings, warnings);
    final accumulators = <LabelColumn, ColumnAccumulator>{
      for (final column in layout.columns)
        column: ColumnAccumulator(column.kind),
    };

    for (final reading in readings) {
      for (final read in reading.values) {
        final token = read.token;
        // A share of a reference intake is not a quantity of food.
        if (token.unit == UnitKind.percent) continue;
        final converted = convertForField(
          reading.field,
          token,
          format,
          energyNamedAsCalories: reading.namedAsCalories,
        );
        if (converted == null) {
          warnings.add(warnImplausibleUnit);
          continue;
        }
        final hit = layout.hitFor(read.x);
        final parsed = ParsedValue(
          value: converted.value,
          unitAsRead: converted.unitAsRead,
          confidence: confidenceFor(
            elementConfidence: read.confidence,
            labelDistance: reading.distance,
            unitFactor: converted.unitFactor,
            columnCertainty: hit?.certainty ?? 0.5,
            isBound: token.isBound,
            digitsRepaired: token.digitsRepaired,
          ),
          sourceText: token.sourceText,
        );
        if (token.isTrace) {
          warnings.add(warnTraceValues);
        } else if (token.isBound) {
          warnings.add(warnLessThanValues);
        }
        if (token.digitsRepaired) warnings.add(warnRepairedDigits);

        if (hit == null || hit.column.kind == ColumnKind.percentDaily) {
          continue;
        }
        final accumulator = accumulators[hit.column];
        if (accumulator == null) continue;
        if (reading.field == LabelField.energy && converted.isKilojoule) {
          accumulator.addEnergyKj(parsed);
        } else {
          accumulator.add(reading.field, parsed);
        }
      }
    }

    ParsedColumn? perServing;
    ParsedColumn? per100;
    for (final entry in accumulators.entries) {
      final accumulator = entry.value;
      if (accumulator.isEmpty) continue;
      accumulator.finish();
      if (accumulator.derivedKcalFromKj) {
        warnings.add(warnEnergyDerivedFromKilojoules);
      }
      if (accumulator.energyDisagrees) {
        warnings.add(warnEnergyFiguresDisagree);
      }
      if (accumulator.derivedSodiumFromSalt) {
        warnings.add(warnSodiumDerivedFromSalt);
      }
      if (accumulator.sawDuplicate) warnings.add(warnDuplicateValues);

      final column = accumulator.build();
      final kind = entry.key.kind;
      if (kind == ColumnKind.perServing) {
        perServing ??= column;
      } else if (kind == ColumnKind.per100g || kind == ColumnKind.per100ml) {
        per100 ??= column;
      }
    }

    if (per100?.basis == ColumnBasis.per100ml) {
      warnings.add(warnPer100Millilitres);
    }
    if (format == LabelFormat.unknown) warnings.add(warnUnknownFormat);

    return ParsedNutritionLabel(
      format: format,
      serving: serving,
      perServing: perServing,
      per100: per100,
      warnings: warnings.toList(),
    );
  }

  List<_RowReading> _readRows(List<OcrRow> rows, ColumnLayout? headerLayout) {
    final out = <_RowReading>[];
    var energySeen = false;
    for (var i = 0; i < rows.length; i++) {
      if (headerLayout?.isHeaderRow(i) ?? false) continue;
      final reading = _readRow(rows[i], energySeen: energySeen);
      if (reading == null) continue;
      if (reading.field == LabelField.energy) energySeen = true;
      out.add(reading);
    }
    return out;
  }

  /// Read one row as "a nutrient name, then its numbers".
  ///
  /// The name is taken from the **leading** run of non-numeric tokens.
  /// When that fails, every non-numeric token in the row is tried
  /// together, which is what makes the US "Includes 10g Added Sugars"
  /// row readable — its number sits in the middle of its own name.
  _RowReading? _readRow(OcrRow row, {required bool energySeen}) {
    final leading = <String>[];
    for (final element in row.elements) {
      if (isValueToken(element.text)) break;
      leading.add(element.text);
    }

    final words = <String>[];
    final values = <_RowValue>[];
    for (final element in row.elements) {
      final token = parseNumericToken(element.text);
      if (token == null) {
        words.add(element.text);
        continue;
      }
      values.add(
        _RowValue(
          token: token,
          x: element.box.centerX,
          confidence: element.confidence,
        ),
      );
    }
    if (values.isEmpty) return null;

    final match =
        matchLabelField(leading.join(' ')) ?? matchLabelField(words.join(' '));
    if (match != null) {
      return _RowReading(
        field: match.field,
        distance: match.distance,
        values: values,
        namedAsCalories: match.synonym.startsWith('calorie'),
      );
    }

    // FSANZ prints the calorie figure on its own line under the kilojoule
    // one, with no label of its own: "Energy 830 kJ" then "(198 Cal)".
    final allEnergy = values.every(
      (v) => familyOf(v.token.unit) == UnitFamily.energy,
    );
    if (energySeen && allEnergy) {
      return _RowReading(
        field: LabelField.energy,
        // Inferred from position rather than read, so never distance 0.
        distance: 1,
        values: values,
      );
    }
    return null;
  }

  /// Columns for a panel whose headings could not be read.
  ColumnLayout _inferLayout(
    List<_RowReading> readings,
    Set<String> warnings,
  ) {
    final xs = <double>[];
    var maxPerRow = 0;
    for (final reading in readings) {
      // An energy row carries kJ *and* Cal inside one column, so it is no
      // evidence of a second column and its x positions are misleading.
      if (reading.field == LabelField.energy) continue;
      var count = 0;
      for (final read in reading.values) {
        if (read.token.unit == UnitKind.percent) continue;
        xs.add(read.x);
        count++;
      }
      if (count > maxPerRow) maxPerRow = count;
    }
    if (xs.isEmpty) {
      warnings.add(warnBasisUnclear);
      return const ColumnLayout(columns: [], fromHeaders: false);
    }
    // When 3 or more values appear per row (common in Australian panels with
    // a middle %DI column), isolate the middle column as percentDaily so it
    // does not bleed into serving or 100g numbers.
    final count = maxPerRow >= 3 ? 3 : (maxPerRow < 2 ? 1 : 2);
    if (count == 1) {
      warnings.add(warnBasisUnclear);
      return columnsFromValuePositions(xs, 1, const [
        ColumnKind.perServing,
      ]);
    }
    if (count == 3) {
      warnings.add(warnColumnsAssumed);
      return columnsFromValuePositions(xs, 3, const [
        ColumnKind.perServing,
        ColumnKind.percentDaily,
        ColumnKind.per100g,
      ]);
    }
    warnings.add(warnColumnsAssumed);
    return columnsFromValuePositions(xs, 2, const [
      ColumnKind.perServing,
      ColumnKind.per100g,
    ]);
  }

  LabelFormat _detectFormat(OcrResult ocr, List<OcrRow> rows) {
    final buffer = StringBuffer(ocr.fullText);
    for (final row in rows) {
      buffer
        ..write(' ')
        ..write(row.text);
    }
    final hay = normaliseHeaderText(buffer.toString());
    bool has(String cue) => hay.contains(normaliseHeaderText(cue));
    int score(List<String> cues) => cues.where(has).length;

    // Two phrases are decisive on their own; everything else is scored.
    if (has('nutrition facts')) return LabelFormat.usFda;
    if (has('nutrition information')) return LabelFormat.fsanz;

    final fsanz = score(const [
      'servings per package',
      'per serve',
      // A tight crop that loses the "Nutrition Information" heading still
      // has its column headings, and those are the panel.
      'per serving',
      'quantity per serving',
      'daily intake',
      '%di',
    ]);
    final usFda = score(const [
      'daily value',
      '%dv',
      'servings per container',
      'total carbohydrate',
      'amount per serving',
      // The FDA panel is the one that spells energy "Calories"; FSANZ
      // abbreviates it to "Cal" beside the kilojoules and the EU prints
      // "kcal", neither of which matches this.
      'calories',
    ]);
    final euUk = score(const [
      'typical values',
      'of which',
      'reference intake',
      'salt',
    ]);

    if (fsanz == 0 && usFda == 0 && euUk == 0) return LabelFormat.unknown;
    if (fsanz >= usFda && fsanz >= euUk) return LabelFormat.fsanz;
    if (usFda >= euUk) return LabelFormat.usFda;
    return LabelFormat.euUk;
  }
}

/// One value read off a row, before it is placed in a column.
class _RowValue {
  const _RowValue({required this.token, required this.x, this.confidence});

  final NumericToken token;
  final double x;
  final double? confidence;
}

/// One nutrient row: which nutrient, how sure of the name, what numbers.
class _RowReading {
  const _RowReading({
    required this.field,
    required this.distance,
    required this.values,
    this.namedAsCalories = false,
  });

  final LabelField field;
  final int distance;
  final List<_RowValue> values;

  /// The row's printed name was *calories*, not *energy*. Decides what an
  /// energy figure with no unit is — see `convertForField`.
  final bool namedAsCalories;
}
