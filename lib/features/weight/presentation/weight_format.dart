/// Presentation-boundary formatting for body weight.
///
/// Storage is always kilograms (`coding_standards.md`); everything here
/// converts for display or reads a user's typed value back into
/// kilograms. Kept in one file so the chart, the header, the history list
/// and the entry dialog cannot drift apart on rounding or on whether the
/// unit is written `lb` or `lbs`.
library;

import 'package:menfit_app/core/domain/units.dart';

/// Short unit label for [unitSystem] — `kg` or `lb`.
///
/// `lb`, matching `features/profile/domain/profile_validation.dart`. (The
/// Progress screen's older weight tile writes `lbs`; this feature does not
/// follow it.)
String weightUnitLabel(UnitSystem unitSystem) =>
    unitSystem == UnitSystem.imperial ? 'lb' : 'kg';

/// The word for one unit of weight in [unitSystem], for prose that has to
/// name a magnitude ("a kilogram or more").
String weightUnitWord(UnitSystem unitSystem) =>
    unitSystem == UnitSystem.imperial ? 'pound' : 'kilogram';

/// Converts canonical [kg] into the number shown to a [unitSystem] user.
double displayWeight(double kg, UnitSystem unitSystem) =>
    unitSystem == UnitSystem.imperial ? UnitConversions.kgToLb(kg) : kg;

/// Converts a number the user typed in her own units back to kilograms.
double displayWeightToKg(double value, UnitSystem unitSystem) =>
    unitSystem == UnitSystem.imperial ? UnitConversions.lbToKg(value) : value;

/// The number only, to one decimal — for text fields and axis labels.
String formatWeightValue(double kg, UnitSystem unitSystem) =>
    displayWeight(kg, unitSystem).toStringAsFixed(1);

/// Number plus unit, to one decimal: `63.4 kg` / `139.8 lb`.
///
/// One decimal everywhere: it is what a domestic scale reports, and a
/// second decimal would invite reading precision into a measurement that
/// does not have it.
String formatWeight(double kg, UnitSystem unitSystem) =>
    '${formatWeightValue(kg, unitSystem)} ${weightUnitLabel(unitSystem)}';

/// Parses a weight field's text into a display-unit number.
///
/// Returns `null` for empty input and [double.nan] for something typed
/// that isn't a number, so the caller can tell "blank" from "not a
/// number" — same contract and comma-as-decimal tolerance as
/// `features/nutrition/presentation/food_form_controller.dart`'s
/// `parseNutritionNumber`.
double? parseWeightInput(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  return double.tryParse(trimmed.replaceAll(',', '.')) ?? double.nan;
}
