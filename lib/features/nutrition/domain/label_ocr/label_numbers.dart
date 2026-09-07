/// Reading numbers and units off a panel.
///
/// The hard part is not the arithmetic, it is deciding what *is* a number.
/// `S0dium` and `O.5` are both letters-and-digits soup after OCR, and only
/// one of them is a value. The rule this file enforces:
///
/// > a token is a value only if its leading run parses as a number
/// > **containing at least one real digit** and everything after it is a
/// > **unit we recognise**.
///
/// `S0dium` fails on the trailing `dium`; `O.5` passes with the `O`
/// repaired to a zero. Without the trailing-unit test, `S0dium` reads as
/// the number 50 — its leading run `S0` repairs to `50` — which is the
/// kind of plausible-looking wrong answer this feature must never
/// produce.
library;

import 'package:menfit_app/features/nutrition/domain/label_ocr/label_lexicon.dart';

/// A unit as printed on a panel.
enum UnitKind {
  kilojoule,
  kilocalorie,
  gram,
  milligram,
  microgram,
  millilitre,

  /// `%DI`, `%DV`, `%RI` — a share of a reference intake, never a
  /// quantity of food. Always discarded.
  percent,

  /// No unit printed.
  none,
}

/// The kind of quantity a [UnitKind] measures.
enum UnitFamily { energy, mass, volume, percent, none }

/// What family a unit belongs to.
UnitFamily familyOf(UnitKind unit) => switch (unit) {
  UnitKind.kilojoule || UnitKind.kilocalorie => UnitFamily.energy,
  UnitKind.gram || UnitKind.milligram || UnitKind.microgram => UnitFamily.mass,
  UnitKind.millilitre => UnitFamily.volume,
  UnitKind.percent => UnitFamily.percent,
  UnitKind.none => UnitFamily.none,
};

const _unitTokens = <String, UnitKind>{
  'kj': UnitKind.kilojoule,
  'kilojoule': UnitKind.kilojoule,
  'kilojoules': UnitKind.kilojoule,
  'kcal': UnitKind.kilocalorie,
  'cal': UnitKind.kilocalorie,
  'cals': UnitKind.kilocalorie,
  'calorie': UnitKind.kilocalorie,
  'calories': UnitKind.kilocalorie,
  'g': UnitKind.gram,
  'gm': UnitKind.gram,
  'gms': UnitKind.gram,
  'gram': UnitKind.gram,
  'grams': UnitKind.gram,
  'mg': UnitKind.milligram,
  'mgs': UnitKind.milligram,
  'milligram': UnitKind.milligram,
  'milligrams': UnitKind.milligram,
  'mcg': UnitKind.microgram,
  'ug': UnitKind.microgram,
  'µg': UnitKind.microgram,
  'μg': UnitKind.microgram,
  'microgram': UnitKind.microgram,
  'micrograms': UnitKind.microgram,
  'ml': UnitKind.millilitre,
  'mls': UnitKind.millilitre,
  'millilitre': UnitKind.millilitre,
  'millilitres': UnitKind.millilitre,
  'milliliter': UnitKind.millilitre,
  'milliliters': UnitKind.millilitre,
  '%': UnitKind.percent,
  '%di': UnitKind.percent,
  '%dv': UnitKind.percent,
  '%ri': UnitKind.percent,
  '%rl': UnitKind.percent,
  'di': UnitKind.percent,
  'dv': UnitKind.percent,
};

/// The unit a trailing token names, or [UnitKind.none] when it names
/// nothing we know.
UnitKind unitKindFrom(String raw) {
  // No unit contains a digit, so a trailing run that does ("g10") is junk
  // rather than a unit — otherwise stripping the digits would invent one.
  if (RegExp('[0-9]').hasMatch(raw)) return UnitKind.none;
  final cleaned = raw.toLowerCase().replaceAll(RegExp('[^a-z%µμ]'), '');
  if (cleaned.isEmpty) return UnitKind.none;
  return _unitTokens[cleaned] ?? UnitKind.none;
}

/// Whether a token is *only* a unit — `g`, `kJ`, `%`. Used to glue a unit
/// the engine split off back onto the number in front of it.
bool isUnitOnlyToken(String raw) {
  final cleaned = raw.trim();
  if (cleaned.isEmpty) return false;
  if (RegExp('[0-9]').hasMatch(cleaned)) return false;
  return unitKindFrom(cleaned) != UnitKind.none;
}

/// One number read off the panel, before it is assigned to a nutrient.
class NumericToken {
  const NumericToken({
    required this.value,
    required this.unit,
    required this.unitAsRead,
    required this.sourceText,
    this.isBound = false,
    this.isTrace = false,
    this.digitsRepaired = false,
  });

  /// The number as printed, in [unit] — no conversion has happened yet.
  final double value;

  final UnitKind unit;

  /// The unit exactly as recognised, `''` when none was printed.
  final String unitAsRead;

  final String sourceText;

  /// The panel said "less than" (`<1 g`), or hedged with "trace".
  /// For a bound, [value] holds **half** the stated limit — the usual
  /// convention — and it is always warned about.
  final bool isBound;

  /// The panel printed "trace" rather than a figure. Read as zero, and
  /// warned about separately from a "less than" bound because it is a
  /// different kind of hedge.
  final bool isTrace;

  /// A digit-for-letter OCR confusion was repaired to read this
  /// (`1O.5` → `10.5`). Costs confidence.
  final bool digitsRepaired;
}

/// Matches a leading number-ish run followed by an optional unit.
///
/// The run's character class includes the letters OCR swaps for digits, so
/// they can be repaired; the "must contain a real digit" test below is
/// what stops a plain word from getting in.
final _numberPattern = RegExp(
  r'^([<≤])?\s*([0-9oOlLiI|sS.,]+)\s*(.*)$',
);

/// Parse one token as a value, or return `null` when it is not one.
///
/// Returning `null` is also how the caller tells words from numbers — see
/// [isValueToken].
NumericToken? parseNumericToken(String raw) {
  var text = raw.trim();
  if (text.isEmpty) return null;

  // Panels bracket the second energy unit: "(198 Cal)".
  text = text.replaceAll(RegExp(r'[()\[\]]'), '').trim();
  if (text.isEmpty) return null;

  // A stated zero. "Nil" is a claim the panel makes; "trace" is a hedge,
  // so it is read as zero but warned about by the caller.
  final alphaOnly = text.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
  if (text.replaceAll(RegExp('[^0-9]'), '').isEmpty) {
    if (alphaOnly == 'nil') {
      return NumericToken(
        value: 0,
        unit: UnitKind.none,
        unitAsRead: '',
        sourceText: raw,
      );
    }
    if (alphaOnly == 'trace') {
      return NumericToken(
        value: 0,
        unit: UnitKind.none,
        unitAsRead: '',
        sourceText: raw,
        isBound: true,
        isTrace: true,
      );
    }
  }

  final lowered = text.toLowerCase();
  if (lowered.contains('less than')) {
    text = '<${text.substring(lowered.indexOf('less than') + 9)}';
  }

  final match = _numberPattern.firstMatch(text.trim());
  if (match == null) return null;

  var rawDigits = match.group(2)!;
  var tail = '';
  // A confusable letter at the *end* of an integer run is far more often
  // a unit than a digit: "2L" is two litres on a receipt, not twenty-one.
  // After a decimal point it can only be a digit ("34.O" is 34.0), so the
  // repair is allowed there and nowhere else — anything else gets handed
  // to the unit test below, which rejects it.
  while (rawDigits.isNotEmpty &&
      !rawDigits.contains('.') &&
      !rawDigits.contains(',') &&
      _isRepairableLetter(rawDigits[rawDigits.length - 1])) {
    tail = rawDigits[rawDigits.length - 1] + tail;
    rawDigits = rawDigits.substring(0, rawDigits.length - 1);
  }
  if (!RegExp('[0-9]').hasMatch(rawDigits)) return null;

  final repaired = _repairDigits(rawDigits);
  final normalised = _normaliseSeparators(repaired);
  if (normalised == null) return null;
  final parsed = double.tryParse(normalised);
  if (parsed == null || !parsed.isFinite) return null;

  final rest = '$tail${match.group(3)!}'.trim();
  final unit = unitKindFrom(rest);
  // Anything trailing that is not a unit we know means this was never a
  // value — see the library doc.
  if (rest.isNotEmpty && unit == UnitKind.none) return null;

  final isBound = match.group(1) != null;
  return NumericToken(
    // "<1 g" is read as half the bound: the panel is asserting an upper
    // limit, and half of it is the conventional midpoint. Low confidence
    // and a warning always travel with it.
    value: isBound ? parsed / 2 : parsed,
    unit: unit,
    unitAsRead: unit == UnitKind.none ? '' : rest,
    sourceText: raw,
    isBound: isBound,
    digitsRepaired: repaired != rawDigits,
  );
}

/// Whether a token reads as a value rather than as words.
bool isValueToken(String raw) => parseNumericToken(raw) != null;

bool _isRepairableLetter(String ch) => switch (ch) {
  'o' || 'O' || 'l' || 'L' || 'i' || 'I' || '|' || 's' || 'S' => true,
  _ => false,
};

String _repairDigits(String run) {
  final out = StringBuffer();
  for (final rune in run.runes) {
    final ch = String.fromCharCode(rune);
    switch (ch) {
      case 'o':
      case 'O':
        out.write('0');
      case 'l':
      case 'L':
      case 'i':
      case 'I':
      case '|':
        out.write('1');
      case 's':
      case 'S':
        out.write('5');
      default:
        out.write(ch);
    }
  }
  return out.toString();
}

/// Turn a printed number into something `double.parse` accepts.
///
/// A comma is a thousands separator when exactly three digits follow it
/// (`1,250 kJ`) and a decimal point otherwise (`2,5 g`) — the ambiguity is
/// real and this is the only rule that gets both European panels and
/// four-digit kilojoule figures right. A lone dot is always decimal, so a
/// European thousands dot (`1.250 kJ`) is a known mis-read.
String? _normaliseSeparators(String run) {
  if (run.isEmpty) return null;
  var text = run;
  final hasComma = text.contains(',');
  final hasDot = text.contains('.');

  if (hasComma && hasDot) {
    // The rightmost separator is the decimal one; the rest are grouping.
    final lastComma = text.lastIndexOf(',');
    final lastDot = text.lastIndexOf('.');
    if (lastDot > lastComma) {
      text = text.replaceAll(',', '');
    } else {
      text =
          '${text.substring(0, lastComma).replaceAll('.', '')}'
          '.${text.substring(lastComma + 1)}';
    }
  } else if (hasComma) {
    if (RegExp(r'^\d{1,3}(,\d{3})+$').hasMatch(text)) {
      text = text.replaceAll(',', '');
    } else {
      text = text.replaceAll(',', '.');
    }
  }

  if ('.'.allMatches(text).length > 1) return null;
  if (!RegExp(r'^\d*\.?\d+$').hasMatch(text)) return null;
  return text;
}

/// The unit this app stores a nutrient in.
UnitKind canonicalUnitFor(LabelField field) => switch (field) {
  LabelField.energy => UnitKind.kilocalorie,
  LabelField.protein ||
  LabelField.fat ||
  LabelField.saturatedFat ||
  LabelField.transFat ||
  LabelField.carbs ||
  LabelField.sugars ||
  LabelField.addedSugars ||
  LabelField.fiber ||
  LabelField.salt => UnitKind.gram,
  LabelField.sodium ||
  LabelField.potassium ||
  LabelField.cholesterol ||
  LabelField.calcium ||
  LabelField.iron ||
  LabelField.vitaminC => UnitKind.milligram,
  LabelField.vitaminD => UnitKind.microgram,
};

const _gramsPer = <UnitKind, double>{
  UnitKind.gram: 1,
  UnitKind.milligram: 0.001,
  UnitKind.microgram: 0.000001,
};

/// Convert a mass between g / mg / mcg, or `null` if either side is not a
/// mass.
double? convertMass(double value, UnitKind from, UnitKind to) {
  final fromGrams = _gramsPer[from];
  final toGrams = _gramsPer[to];
  if (fromGrams == null || toGrams == null) return null;
  return value * fromGrams / toGrams;
}

/// Kilojoules to kilocalories. The thermochemical factor, the same one
/// FSANZ panels round with.
double kilojoulesToKilocalories(double kj) => kj / 4.184;
