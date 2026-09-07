/// Display formatting for diary figures.
///
/// One place for every nutrition number the UI renders, so the day view, the
/// picker and the log dialog can't drift apart on rounding or units.
///
/// **No decimals on energy.** `knowledge/research/nutrition_energy_estimates.md`
/// is explicit that BMR/TDEE estimates are outside ±10% for one person in
/// five, so a figure like `1,847.3 kcal` would imply a precision this
/// feature does not have — round generously and never show tenths.
/// [formatEstimatedKcal] rounds harder still, to the nearest 10, for the
/// figures that come out of the estimate rather than off a label.
///
/// These functions take already-computed values and only turn them into
/// strings; nothing here decides anything. S2 (nutrition figures) applies to
/// the results — display only, never a log line or an exception message.
library;

import 'package:menfit_app/features/nutrition/domain/energy_estimate.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';

/// Energy, e.g. `'480 kcal'`.
String formatKcal(num kcal) => '${kcal.round()} kcal';

/// Energy from an estimate, rounded to the nearest 10, e.g. `'1850 kcal'`.
String formatEstimatedKcal(num kcal) => '${(kcal / 10).round() * 10} kcal';

/// A macro mass, e.g. `'54 g'`.
String formatGrams(num grams) => '${grams.round()} g';

/// Iron, to one decimal place, e.g. `'8.4 mg'`. Iron figures are small
/// enough that rounding to whole milligrams would lose most of the signal.
String formatIronMg(num milligrams) => '${milligrams.toStringAsFixed(1)} mg';

/// A nutrition number as the **text a form field starts with**: `''` for an
/// unknown value, `'372'` for a whole one, `'8.5'` otherwise.
///
/// The empty string for `null` is load-bearing rather than cosmetic. A
/// provider that never stated a number must seed a **blank** field, not
/// `0`: `0` is a claim about the food, and the whole shape of the
/// review-before-save flow (ADR 010) rests on the user being asked for what
/// nobody has filled in. Existing validation then requires the four macros,
/// which is exactly the intended outcome.
///
/// Two decimal places at most, trailing zeros trimmed — enough to carry a
/// value derived by scaling per-100 g figures without printing float noise
/// into a text field the user is about to edit.
///
/// **A nonzero value never renders as `'0'`.** Two decimals alone would send
/// anything under 0.005 to `'0.00'` and then to `'0'`, which is the same
/// falsehood as seeding `'0'` for `null`, only harder to spot: it turns a
/// small true number into a claim of *none*, in a field the user is about to
/// save as her own definition of the food. So below that point the value is
/// rendered to two **significant** figures instead of two decimal places,
/// which keeps a digit alive however small it is. Values under 1e-6 come out
/// in exponent form (`'1.0e-7'`); they are reachable only from arithmetic on
/// a provider figure that was already vanishing, and an odd-looking true
/// number beats a tidy false one.
String formatNutritionField(double? value) {
  if (value == null || !value.isFinite) return '';
  if (value == value.roundToDouble()) return value.round().toString();
  final fixed = value.abs() >= 0.005
      ? value.toStringAsFixed(2)
      : value.toStringAsPrecision(2);
  return fixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

// A logged quantity ('47 g', '1.5 servings') is deliberately *not*
// formatted here: it belongs to the entry, which knows the unit it was
// logged in, so it lives on `NutritionEntry.quantityLabel` where the diary
// row and the log dialog read the same one string.

/// The inputs an energy estimate is still waiting on, as a readable list —
/// `'your height and your weight'`.
///
/// Built from [EnergyEstimateInput.label]s in enum order so the sentence is
/// stable, and from the set [NoEnergyEstimate] actually carries so the UI
/// can never name an input that isn't missing. Returns an empty string for
/// an empty set; callers check first.
String formatMissingInputs(Set<EnergyEstimateInput> missing) {
  final labels = [
    for (final input in EnergyEstimateInput.values)
      if (missing.contains(input)) input.label,
  ];
  if (labels.isEmpty) return '';
  if (labels.length == 1) return labels.single;
  return '${labels.sublist(0, labels.length - 1).join(', ')} and '
      '${labels.last}';
}

/// A figure the source may simply not state, e.g. `'54 g'` or `'—'`.
///
/// The dash is not a zero and must never be read as one: a food database
/// omits what no contributor entered (`domain/provider_food.dart`), and
/// printing `0 g` there would turn someone else's gap into a claim about the
/// food.
String formatOptionalGrams(num? grams) =>
    grams == null ? '—' : formatGrams(grams);

/// Energy the source may not state, e.g. `'372 kcal'` or `'—'`. Same
/// unknown-is-not-zero rule as [formatOptionalGrams].
String formatOptionalKcal(num? kcal) => kcal == null ? '—' : formatKcal(kcal);

/// The three macros of a food-database search hit, which are **per 100 g**
/// and any of which may be unstated: `'P 12 g · C 60 g · F —'`.
///
/// Separate from [formatMacroLine] because the two are per different things.
/// A per-100 g figure shown where a per-serving one belongs is wrong by a
/// factor nobody can see, so the basis is never inferred from context — the
/// caller labels the region and this line only fills it.
String formatPer100gMacroLine({
  double? proteinGrams,
  double? carbsGrams,
  double? fatGrams,
}) =>
    'P ${formatOptionalGrams(proteinGrams)} · '
    'C ${formatOptionalGrams(carbsGrams)} · '
    'F ${formatOptionalGrams(fatGrams)}';

/// The three macros on one line, e.g. `'P 20 g · C 54 g · F 5 g'`.
///
/// Deliberately carries no energy figure: it is what the diary shows in
/// place of calories when the hide-calorie-numbers preference is on
/// (`domain/nutrition_goals.dart`).
String formatMacroLine(NutritionFacts facts) =>
    'P ${formatGrams(facts.proteinGrams)} · '
    'C ${formatGrams(facts.carbsGrams)} · '
    'F ${formatGrams(facts.fatGrams)}';
