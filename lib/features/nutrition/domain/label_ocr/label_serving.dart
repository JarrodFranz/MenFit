/// The serving statement above the table.
///
/// Panels state it three ways and all three end up here: FSANZ prints
/// "Servings per package: 12" and "Serving size: 30 g" on separate lines,
/// the US prints "8 servings per container" with the count *before* the
/// words, and both print a description that mixes a household measure
/// with a weight ("2/3 cup (55 g)").
///
/// The description is kept verbatim and never re-parsed downstream — the
/// same stance `ProviderFood.servingDescription` takes, for the same
/// reason: these strings are not normalised by anyone.
library;

import 'package:menfit_app/features/nutrition/domain/label_ocr/label_numbers.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_rows.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/parsed_nutrition_label.dart';

final _servingSizePattern = RegExp(
  r'serv(?:ing|e)\s*size',
  caseSensitive: false,
);

final _servingsPerPackPattern = RegExp(
  r'serv(?:ings?|es)?\s*per\s*(?:package|pack|container|pkt)',
  caseSensitive: false,
);

/// Any run that could be "a number with a unit stuck to it".
final _quantityPattern = RegExp(r'[0-9]+(?:[.,][0-9]+)?\s*[a-zA-Zµμ]*');

/// A bare count.
final _countPattern = RegExp('[0-9]+(?:[.,][0-9]+)?');

/// Read the serving lines, or `null` when the panel states none.
ParsedServing? parseServing(List<OcrRow> rows) {
  String? description;
  double? grams;
  double? millilitres;
  double? servingsPerPackage;
  var gramFiguresCount = 0;

  for (final row in rows) {
    final text = row.text;

    final sizeMatch = _servingSizePattern.firstMatch(text);
    if (sizeMatch != null && description == null) {
      final tail = text
          .substring(sizeMatch.end)
          .replaceFirst(RegExp(r'^[\s:\-–—]+'), '')
          .trim();
      if (tail.isNotEmpty) {
        description = tail;
        for (final quantity in _quantityPattern.allMatches(tail)) {
          final token = parseNumericToken(quantity.group(0)!);
          if (token == null) continue;
          if (token.unit == UnitKind.gram) {
            gramFiguresCount++;
            grams ??= token.value;
          } else if (token.unit == UnitKind.millilitre && millilitres == null) {
            millilitres = token.value;
          }
        }
      }
    }

    if (_servingsPerPackPattern.hasMatch(text) && servingsPerPackage == null) {
      // Bare digits, not [_quantityPattern]: the count sits *before* the
      // words on a US panel ("8 servings per container"), so the run
      // would come out as "8 servings" and fail to parse as a value.
      final count = _countPattern.firstMatch(text);
      if (count != null) {
        servingsPerPackage = parseNumericToken(count.group(0)!)?.value;
      }
    }
  }

  if (description == null &&
      grams == null &&
      millilitres == null &&
      servingsPerPackage == null) {
    return null;
  }
  return ParsedServing(
    description: description ?? '',
    grams: grams,
    millilitres: millilitres,
    servingsPerPackage: servingsPerPackage,
    hasMultipleGramFigures: gramFiguresCount > 1,
  );
}
