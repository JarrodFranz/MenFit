/// Turning a printed figure into this app's unit for its nutrient, and
/// deciding how much to trust it.
///
/// Both halves are judgement, not arithmetic: a nutrient row can carry a
/// unit that makes no sense for it (an energy figure on a fat row means
/// the row was mis-clustered, not that the fat is measured in kilojoules),
/// and a figure past what packaging can physically state arrived by a
/// mis-read. Both are dropped rather than passed on looking plausible.
library;

import 'package:menfit_app/features/nutrition/domain/label_ocr/label_lexicon.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/label_numbers.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/parsed_nutrition_label.dart';

/// A value in this app's unit for its nutrient, with what the conversion
/// cost in confidence.
class ConvertedValue {
  const ConvertedValue({
    required this.value,
    required this.unitAsRead,
    required this.unitFactor,
    this.isKilojoule = false,
  });

  final double value;
  final String unitAsRead;
  final double unitFactor;
  final bool isKilojoule;
}

/// The largest value each canonical unit can plausibly hold on a panel.
/// A number past this arrived by a mis-read, not off the packaging.
const _plausibleMaximum = <UnitKind, double>{
  UnitKind.gram: 1000,
  UnitKind.milligram: 100000,
  UnitKind.microgram: 100000,
  UnitKind.kilocalorie: 20000,
  UnitKind.kilojoule: 90000,
};

/// [energyNamedAsCalories] says the row that carried this number was
/// labelled with the word *calories* rather than *energy*. It decides what
/// an energy figure printed with **no unit** is, and it outranks [format],
/// which is only a guess about the whole panel: a bare "Calories 230" read
/// as 230 kJ is 55 kcal, a quarter of the truth, and it would arrive in the
/// form looking perfectly reasonable. The panel-wide default stays
/// kilojoules because that is what an unlabelled figure means everywhere
/// except a US panel.
ConvertedValue? convertForField(
  LabelField field,
  NumericToken token,
  LabelFormat format, {
  bool energyNamedAsCalories = false,
}) {
  if (field == LabelField.energy) {
    switch (token.unit) {
      case UnitKind.kilojoule:
        return _plausible(
          ConvertedValue(
            value: token.value,
            unitAsRead: token.unitAsRead,
            unitFactor: 1,
            isKilojoule: true,
          ),
          UnitKind.kilojoule,
        );
      case UnitKind.kilocalorie:
        return _plausible(
          ConvertedValue(
            value: token.value,
            unitAsRead: token.unitAsRead,
            unitFactor: 1,
          ),
          UnitKind.kilocalorie,
        );
      case UnitKind.none:
        // The US panel prints a bare "Calories 230"; on every other panel
        // an energy figure with no unit is kilojoules. A row that names
        // itself "Calories" says so directly, and is believed even when the
        // panel's own standard could not be identified — which is exactly
        // the case where the format default is least trustworthy.
        final isKilojoule =
            !energyNamedAsCalories && format != LabelFormat.usFda;
        return _plausible(
          ConvertedValue(
            value: token.value,
            unitAsRead: '',
            unitFactor: 0.8,
            isKilojoule: isKilojoule,
          ),
          isKilojoule ? UnitKind.kilojoule : UnitKind.kilocalorie,
        );
      case UnitKind.gram:
      case UnitKind.milligram:
      case UnitKind.microgram:
      case UnitKind.millilitre:
      case UnitKind.percent:
        return null;
    }
  }

  final canonical = canonicalUnitFor(field);
  if (token.unit == canonical) {
    return _plausible(
      ConvertedValue(
        value: token.value,
        unitAsRead: token.unitAsRead,
        unitFactor: 1,
      ),
      canonical,
    );
  }
  if (familyOf(token.unit) == UnitFamily.mass) {
    final converted = convertMass(token.value, token.unit, canonical);
    if (converted == null) return null;
    return _plausible(
      ConvertedValue(
        value: converted,
        unitAsRead: token.unitAsRead,
        unitFactor: 0.95,
      ),
      canonical,
    );
  }
  if (token.unit == UnitKind.none) {
    return _plausible(
      ConvertedValue(value: token.value, unitAsRead: '', unitFactor: 0.8),
      canonical,
    );
  }
  // An energy or volume figure on a nutrient row is a mis-read row.
  return null;
}

ConvertedValue? _plausible(ConvertedValue converted, UnitKind canonical) {
  final maximum = _plausibleMaximum[canonical];
  if (maximum != null && converted.value > maximum) return null;
  if (converted.value < 0) return null;
  return converted;
}

double confidenceFor({
  required double? elementConfidence,
  required int labelDistance,
  required double unitFactor,
  required double columnCertainty,
  required bool isBound,
  required bool digitsRepaired,
}) {
  var score = 1.0;
  // An absent engine confidence is no signal, not a bad one — ML Kit
  // often reports none at all (ADR 012).
  if (elementConfidence != null) {
    score *= 0.6 + 0.4 * elementConfidence.clamp(0.0, 1.0);
  }
  score *= switch (labelDistance) {
    0 => 1.0,
    1 => 0.85,
    _ => 0.7,
  };
  score *= unitFactor;
  score *= columnCertainty;
  if (isBound) score *= 0.5;
  if (digitsRepaired) score *= 0.8;
  return score.clamp(0.0, 1.0);
}
