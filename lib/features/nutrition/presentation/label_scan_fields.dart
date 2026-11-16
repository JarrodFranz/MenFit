/// Turning a parsed nutrition label into form-field text.
///
/// The **one** implementation of "what does this label put where", shared
/// by the two entry points that need it: `FoodFormController.scanLabel`,
/// which merges a scan into a form the user may already have typed in, and
/// `FoodFormSeed.fromParsedLabel`, which opens a fresh form from one. Two
/// mappings would disagree about which column to read, and the
/// disagreement would look like a parser bug.
///
/// **Nothing here is a decision to save anything.** ADR 012 makes the
/// review form mandatory: this produces candidate text for fields the user
/// then checks, and the existing `validateFood` path is untouched.
///
/// S2 (`knowledge/engineering/security_and_privacy.md`): every string this
/// file produces describes a food a specific person is about to eat. They
/// are display strings only — never a log line, never an analytics event,
/// never an exception message.
library;

import 'package:menfit_app/features/nutrition/domain/label_ocr/label_warnings.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/parsed_nutrition_label.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';

/// Below this, a value gets a visible "check this" marker beside its field.
///
/// The number is a **UI threshold, not a truth threshold**. Every scanned
/// value is checked by the user regardless (ADR 012); this only decides
/// where to point their eye first. 0.6 is the parser's own scale: a clean
/// read with a clean unit and a confident column scores ~1.0, a nutrient
/// name the parser had to guess at costs 30%, a repaired digit 20%, a
/// "less than" bound 50% — so 0.6 catches roughly "one thing went wrong
/// with this number" and above.
const labelScanCheckThreshold = 0.6;

/// What the scanned column is *per*.
///
/// [per100ml] is kept apart from [per100g] rather than folded into it
/// because a millilitre is not a mass — 100 ml of oil is ~92 g, of honey
/// ~140 g (`knowledge/domain/nutrition.md`, "no millilitres and no
/// milligrams"). The app stores a serving *weight*, so a per-100 mL panel
/// can supply the numbers and nothing else: the weight is the user's to
/// enter.
enum LabelScanBasis { serving, per100g, per100ml }

/// The `FoodFormState` field names a nutrition panel can fill.
///
/// Strings rather than an enum because they are what
/// `FoodFormState.lowConfidenceFields` carries to the widgets, and because
/// they match the state's own field names one-for-one — the marker beside
/// `caloriesField` and the value in `state.calories` have to be talking
/// about the same thing.
abstract final class ScanField {
  static const calories = 'calories';
  static const protein = 'protein';
  static const carbs = 'carbs';
  static const fat = 'fat';
  static const saturatedFat = 'saturatedFat';
  static const transFat = 'transFat';
  static const fiber = 'fiber';
  static const sugars = 'sugars';
  static const addedSugars = 'addedSugars';
  static const sodium = 'sodium';
  static const potassium = 'potassium';
  static const cholesterol = 'cholesterol';
  static const iron = 'iron';
  static const calcium = 'calcium';
  static const vitaminD = 'vitaminD';
  static const vitaminC = 'vitaminC';

  /// How each field is named to the user, for the "kept your value" notes.
  /// Lower case: they appear mid-sentence.
  static const displayNames = <String, String>{
    calories: 'calories',
    protein: 'protein',
    carbs: 'carbs',
    fat: 'fat',
    saturatedFat: 'saturated fat',
    transFat: 'trans fat',
    fiber: 'fibre',
    sugars: 'sugars',
    addedSugars: 'added sugars',
    sodium: 'sodium',
    potassium: 'potassium',
    cholesterol: 'cholesterol',
    iron: 'iron',
    calcium: 'calcium',
    vitaminD: 'vitamin D',
    vitaminC: 'vitamin C',
  };
}

/// One scanned panel, as form-field text.
class LabelScanFields {
  const LabelScanFields({
    required this.basis,
    required this.values,
    required this.lowConfidenceFields,
    required this.warnings,
    this.servingDescription = '',
    this.servingGrams = '',
  });

  /// A scan that yielded nothing to fill in.
  static const LabelScanFields none = LabelScanFields(
    basis: LabelScanBasis.serving,
    values: <String, String>{},
    lowConfidenceFields: <String>{},
    warnings: <String>[],
  );

  final LabelScanBasis basis;

  /// [ScanField] name to the text that field should hold.
  ///
  /// **Only fields the panel actually stated appear.** An absent key means
  /// the panel did not say, which is not the same as zero and must leave
  /// the field blank — `ParsedColumn.toNutritionFacts()` cannot express
  /// that for the four core macros (it emits `0`), which is exactly why
  /// this reads the nullable `ParsedValue` fields instead.
  final Map<String, String> values;

  /// Fields whose reading scored below [labelScanCheckThreshold].
  final Set<String> lowConfidenceFields;

  /// Cautions for the review form, in reading order.
  final List<String> warnings;

  /// The serving statement as printed, when [basis] is
  /// [LabelScanBasis.serving].
  final String servingDescription;

  /// The serving weight in grams, as field text, when the panel stated
  /// one. Always `''` for a per-100 mL panel: a volume is not a weight.
  final String servingGrams;

  bool get isEmpty => values.isEmpty;

  /// Whether the panel is per volume, so the app cannot derive a weight
  /// and the user has to supply one before the food can be saved.
  bool get needsWeight => basis == LabelScanBasis.per100ml;
}

/// Reads [label] as form-field text.
///
/// If [preferredBasis] is provided and available on [label], that column is
/// selected. Otherwise, column choice falls back to:
///
/// 1. The per-serving column **when the panel also stated a serving
///    weight** — the only case where the numbers and the amount they are
///    per can both be recorded.
/// 2. Otherwise the per-100 column, which becomes a "Per Reference" basis
///    of 100 g — or, for a per-100 mL panel, values with no amount at all
///    (see [LabelScanBasis.per100ml]).
/// 3. Otherwise a per-serving column with no weight, which fills the
///    numbers and leaves the amount for the user.
LabelScanFields mapParsedLabel(
  ParsedNutritionLabel label, {
  LabelScanBasis? preferredBasis,
}) {
  final serving = label.serving;
  final perServing = label.perServing;
  final per100 = label.per100;

  final ParsedColumn? column;
  final LabelScanBasis basis;
  if (preferredBasis == LabelScanBasis.per100g &&
      per100 != null &&
      !per100.isEmpty) {
    column = per100;
    basis = LabelScanBasis.per100g;
  } else if (preferredBasis == LabelScanBasis.per100ml &&
      per100 != null &&
      !per100.isEmpty) {
    column = per100;
    basis = LabelScanBasis.per100ml;
  } else if (preferredBasis == LabelScanBasis.serving &&
      perServing != null &&
      !perServing.isEmpty) {
    column = perServing;
    basis = LabelScanBasis.serving;
  } else if (perServing != null &&
      !perServing.isEmpty &&
      serving?.grams != null) {
    column = perServing;
    basis = LabelScanBasis.serving;
  } else if (per100 != null && !per100.isEmpty) {
    column = per100;
    basis = per100.basis == ColumnBasis.per100ml
        ? LabelScanBasis.per100ml
        : LabelScanBasis.per100g;
  } else if (perServing != null && !perServing.isEmpty) {
    column = perServing;
    basis = LabelScanBasis.serving;
  } else {
    return LabelScanFields(
      basis: LabelScanBasis.serving,
      values: const {},
      lowConfidenceFields: const {},
      warnings: _warningsFor(label, LabelScanBasis.serving),
    );
  }

  final readings = <String, ParsedValue?>{
    // Energy is read from the kcal figure, which the parser derives from
    // kilojoules when that is all the panel printed — and lowers the
    // confidence accordingly, so a derived figure marks itself.
    ScanField.calories: column.energyKcal,
    ScanField.protein: column.proteinG,
    ScanField.carbs: column.carbsG,
    ScanField.fat: column.fatG,
    ScanField.saturatedFat: column.saturatedFatG,
    ScanField.transFat: column.transFatG,
    ScanField.fiber: column.fiberG,
    ScanField.sugars: column.sugarsG,
    ScanField.addedSugars: column.addedSugarsG,
    ScanField.sodium: column.sodiumMg,
    ScanField.potassium: column.potassiumMg,
    ScanField.cholesterol: column.cholesterolMg,
    ScanField.iron: column.ironMg,
    ScanField.calcium: column.calciumMg,
    ScanField.vitaminD: column.vitaminDMcg,
    ScanField.vitaminC: column.vitaminCMg,
  };

  final values = <String, String>{};
  final lowConfidence = <String>{};
  for (final entry in readings.entries) {
    final reading = entry.value;
    // Absent stays absent. `formatNutritionField(null)` would give `''`
    // anyway, but writing the key at all would say "the panel stated
    // this, as nothing", and the merge treats a present key as a value to
    // put in a blank field.
    if (reading == null) continue;
    values[entry.key] = formatNutritionField(reading.value);
    if (reading.confidence < labelScanCheckThreshold) {
      lowConfidence.add(entry.key);
    }
  }

  return LabelScanFields(
    basis: basis,
    values: values,
    lowConfidenceFields: lowConfidence,
    warnings: _warningsFor(label, basis),
    servingDescription: basis == LabelScanBasis.serving
        ? (serving?.description ?? '')
        : '',
    // A serving volume is never a serving weight, so only grams travel.
    servingGrams: basis == LabelScanBasis.serving
        ? formatNutritionField(serving?.grams)
        : '',
  );
}

/// The parser's cautions, with the per-100 mL one restated in the terms of
/// the form the user is looking at.
///
/// The parser's own copy says the numbers cannot be turned into grams,
/// which is true and, in front of a half-filled form, not actionable. The
/// substitute names the thing to do next. Substituted rather than added,
/// because two lines saying the same thing read as two problems.
List<String> _warningsFor(ParsedNutritionLabel label, LabelScanBasis basis) => [
  for (final warning in label.warnings)
    if (warning == warnPer100Millilitres && basis == LabelScanBasis.per100ml)
      labelScanPerVolumeWarning
    else
      warning,
];

/// Shown after every scan, above the fields. Not dismissible and not
/// conditional on confidence: ADR 012's review step is the safety
/// mechanism, and a banner that appears only for bad reads teaches the
/// user that its absence means "this one is fine".
const labelScanBannerText =
    'Read from a label — check every value before saving.';

/// The button's one-line explainer.
///
/// It makes the same three promises as the iOS
/// `NSCameraUsageDescription` — the nutrition panel, processing on the
/// device, the photo discarded — because they are the same promise made in
/// two places, and a user who reads one and not the other must not get a
/// different story. `test/platform/ocr_platform_config_guard_test.dart`
/// holds the Info.plist string to those claims;
/// `test/features/nutrition/label_scan_mapping_test.dart` holds this one to
/// them, so neither can quietly drop a claim the implementation keeps.
const labelScanExplainerText =
    "Take a photo of the nutrition panel. It's read on your phone and the "
    'photo is discarded.';

/// Replaces `warnPer100Millilitres` on the review form.
///
/// Names only the amount field, and deliberately not "or a serving weight":
/// a per-volume panel puts the form in per-reference mode, where the
/// serving-weight field is not rendered at all, so offering it would point
/// at something they cannot see.
const labelScanPerVolumeWarning =
    'This label is per 100 mL. MenFit records weight — enter the grams for '
    '100 mL before saving.';

/// What one scan did, so the screen knows what to say.
///
/// A returned value rather than the controller reaching for a
/// `ScaffoldMessenger`: the decisions (cancelled, refused, unreadable,
/// applied) are the controller's, the words and the snack bar are the
/// widget's.
enum LabelScanOutcome {
  /// They backed out of the camera. Says nothing — a cancel that produced a
  /// message would be the app arguing with a decision.
  cancelled,

  /// Values were merged into the form.
  applied,

  /// The camera permission is denied. Not a cancellation, and not a crash.
  cameraDenied,

  /// This build has no recogniser. Should be unreachable — the entry point
  /// is gated on `textRecognitionSupported` — so this is the second line of
  /// defence rather than the first.
  unsupported,

  /// A photo came back, and nothing in it read as a nutrition panel.
  notRecognised,

  /// The camera or the recogniser failed. Deliberately one outcome for
  /// every cause: the underlying error can carry a file path to a photo of
  /// the user's food, so it is never shown, never logged, and never
  /// inspected beyond "was this a denied permission".
  failed,
}

/// The message for [outcome], or `null` when it needs none.
String? labelScanMessageFor(LabelScanOutcome outcome) => switch (outcome) {
  LabelScanOutcome.cancelled || LabelScanOutcome.applied => null,
  LabelScanOutcome.cameraDenied =>
    'Camera access is off. Allow it in Settings to scan labels.',
  LabelScanOutcome.unsupported =>
    "Scanning labels isn't available on this device. You can enter the "
        'details yourself.',
  LabelScanOutcome.notRecognised =>
    "Couldn't read a nutrition panel in that photo. Try again with the "
        'table filling the frame, or type the values.',
  LabelScanOutcome.failed =>
    "That photo couldn't be read. Try again, or type the values.",
};
