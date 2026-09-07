/// Merging a scanned nutrition panel into a form the user may already have
/// started.
///
/// **Never replace what she typed.** A scan fills blanks and nothing else.
/// The alternative — a scan that overwrites — turns one tap into silent
/// data loss on the one screen where the numbers are the whole point, and
/// it does it at the moment she is least likely to re-read the fields she
/// had already finished. Where the panel and the form disagree, hers wins
/// and the disagreement is *said*, under the review banner, rather than
/// resolved on her behalf.
///
/// Pure: takes a state, returns a state. The controller owns when this
/// runs; this owns what it does.
library;

import 'package:menfit_app/features/nutrition/presentation/food_form_state.dart';
import 'package:menfit_app/features/nutrition/presentation/label_scan_fields.dart';

/// [current] with every blank field the panel could fill, filled.
///
/// The basis (amount, unit, serving weight) is only taken from the panel
/// when the form is still on its untouched defaults — an amount she has
/// already set is a field like any other, and a scan may not move it.
FoodFormState applyLabelScan(
  FoodFormState current,
  LabelScanFields fields,
) {
  final filled = <String, String>{};
  final kept = <String>[];

  for (final entry in fields.values.entries) {
    final existing = _fieldOf(current, entry.key);
    if (existing.trim().isEmpty) {
      filled[entry.key] = entry.value;
    } else if (existing.trim() != entry.value) {
      kept.add(_keptNote(entry.key, read: entry.value));
    }
  }

  var next = _withValues(current, filled);
  final basisIsUntouched = _isUntouchedBasis(current);
  if (basisIsUntouched) {
    next = _withBasis(next, fields);
  } else if (fields.basis != LabelScanBasis.serving ||
      fields.servingGrams.isNotEmpty) {
    kept.add(_keptBasisNote);
  }

  return next.copyWith(
    labelScanApplied: true,
    // Only the fields actually taken from the panel can be marked "check
    // this": a marker beside a number she typed herself would be the app
    // doubting her handwriting.
    //
    // Markers from an earlier scan survive for fields **this** scan did not
    // refill. Their values are still on the form and were still read off a
    // photo, so dropping the marker would quietly upgrade an unsure number
    // to a checked one. Where this scan did refill a field, its verdict
    // replaces the old one.
    lowConfidenceFields: {
      for (final field in current.lowConfidenceFields)
        if (!filled.containsKey(field)) field,
      for (final field in fields.lowConfidenceFields)
        if (filled.containsKey(field)) field,
    },
    labelWarnings: [...fields.warnings, ...kept],
    // **Sticky, and independent of who set the basis.** Deriving it from
    // `basisIsUntouched` was a hole in two directions: the first per-100 mL
    // scan itself sets the basis, so a *second* scan of the same panel
    // recomputed the flag as `false` and let the save through; and a user
    // who had already typed an amount never set it at all. Either way the
    // blank amount is read as 100 by `_effectiveServing` and per-100 mL
    // figures are saved as per-100 g.
    labelIsPerVolume: fields.needsWeight || current.labelIsPerVolume,
    // A weight she typed *before* this scan was not about this label's
    // basis, so a per-volume panel always asks again. Cleared by
    // `FoodFormController.updateBasisAmount` — touching the amount is the
    // confirmation.
    labelVolumeWeightConfirmed:
        !fields.needsWeight && current.labelVolumeWeightConfirmed,
  );
}

/// "Kept your value for calories (label read 198)."
///
/// The one message in this feature that interpolates a recognised value,
/// and a deliberate exception to the rule in
/// `domain/label_ocr/label_warnings.dart` that no warning quotes one. That
/// rule protects fixed *parser* strings, which end up in test output and
/// crash text; this string is built in the presentation layer, exists only
/// to be rendered on the form beside the fields it is about, and is
/// useless without the two numbers it compares — "we read something
/// different" tells the user nothing she can act on. It stays S2: display
/// only, never a log line, never an exception message.
String _keptNote(String field, {required String read}) {
  final name = ScanField.displayNames[field] ?? field;
  return 'Kept your value for $name (label read $read).';
}

const _keptBasisNote =
    'Kept your amount and unit — check they match what the label is per.';

/// Whether the amount/serving half of the form is still exactly as it
/// opened.
///
/// Conservative on purpose: anything at all in the serving weight or the
/// portion description, or an amount other than the default, means she has
/// been here, and a scan does not get to redefine what the numbers are per.
bool _isUntouchedBasis(FoodFormState state) =>
    state.basisMode == FoodBasisMode.serving &&
    state.basisUnit == 'serving' &&
    state.basisAmount.trim() == '1' &&
    state.servingGrams.trim().isEmpty &&
    state.servingDescription.trim().isEmpty;

FoodFormState _withBasis(FoodFormState state, LabelScanFields fields) {
  switch (fields.basis) {
    case LabelScanBasis.serving:
      if (fields.servingGrams.isEmpty) {
        // Numbers per an unstated serving: the values are worth having,
        // the amount is hers to give.
        return state.copyWith(
          servingDescription: fields.servingDescription,
        );
      }
      return state.copyWith(
        basisMode: FoodBasisMode.serving,
        basisUnit: 'g',
        basisAmount: fields.servingGrams,
        servingDescription: fields.servingDescription,
        servingGrams: fields.servingGrams,
      );
    case LabelScanBasis.per100g:
      return state.copyWith(
        basisMode: FoodBasisMode.perReference,
        basisUnit: 'g',
        basisAmount: '100',
      );
    case LabelScanBasis.per100ml:
      // Per-reference mode with a **blank** amount, and no attempt to turn
      // 100 mL into 100 g. A millilitre is not a mass
      // (`knowledge/domain/nutrition.md`: 100 ml of oil is ~92 g, of honey
      // ~140 g), so the weight is the one thing on this panel the app
      // cannot supply. `labelIsPerVolume` then blocks the save until she
      // does — see `FoodFormState.needsWeightForVolumeLabel`.
      return state.copyWith(
        basisMode: FoodBasisMode.perReference,
        basisUnit: 'g',
        basisAmount: '',
      );
  }
}

String _fieldOf(FoodFormState state, String field) => switch (field) {
  ScanField.calories => state.calories,
  ScanField.protein => state.protein,
  ScanField.carbs => state.carbs,
  ScanField.fat => state.fat,
  ScanField.saturatedFat => state.saturatedFat,
  ScanField.transFat => state.transFat,
  ScanField.fiber => state.fiber,
  ScanField.sugars => state.sugars,
  ScanField.addedSugars => state.addedSugars,
  ScanField.sodium => state.sodium,
  ScanField.potassium => state.potassium,
  ScanField.cholesterol => state.cholesterol,
  ScanField.iron => state.iron,
  ScanField.calcium => state.calcium,
  ScanField.vitaminD => state.vitaminD,
  ScanField.vitaminC => state.vitaminC,
  _ => '',
};

FoodFormState _withValues(FoodFormState state, Map<String, String> values) =>
    state.copyWith(
      calories: values[ScanField.calories] ?? state.calories,
      protein: values[ScanField.protein] ?? state.protein,
      carbs: values[ScanField.carbs] ?? state.carbs,
      fat: values[ScanField.fat] ?? state.fat,
      saturatedFat: values[ScanField.saturatedFat] ?? state.saturatedFat,
      transFat: values[ScanField.transFat] ?? state.transFat,
      fiber: values[ScanField.fiber] ?? state.fiber,
      sugars: values[ScanField.sugars] ?? state.sugars,
      addedSugars: values[ScanField.addedSugars] ?? state.addedSugars,
      sodium: values[ScanField.sodium] ?? state.sodium,
      potassium: values[ScanField.potassium] ?? state.potassium,
      cholesterol: values[ScanField.cholesterol] ?? state.cholesterol,
      iron: values[ScanField.iron] ?? state.iron,
      calcium: values[ScanField.calcium] ?? state.calcium,
      vitaminD: values[ScanField.vitaminD] ?? state.vitaminD,
      vitaminC: values[ScanField.vitaminC] ?? state.vitaminC,
    );
