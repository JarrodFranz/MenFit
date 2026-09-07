import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_validation.dart';

part 'food_form_state.freezed.dart';

enum FoodBasisMode {
  serving,
  perReference,
}

/// In-progress state of the custom-food form.
///
/// Split out of `food_form_controller.dart` so that the pure merge in
/// `label_scan_merge.dart` can take and return one without importing the
/// controller (and the controller can import the merge). The controller
/// re-exports this file, so `import 'food_form_controller.dart'` still
/// hands you [FoodFormState] and [FoodBasisMode].
@freezed
abstract class FoodFormState with _$FoodFormState {
  const factory FoodFormState({
    @Default('') String name,
    @Default('') String brand,
    @Default(FoodBasisMode.serving) FoodBasisMode basisMode,
    @Default('1') String basisAmount,
    @Default('serving') String basisUnit,
    @Default('') String servingDescription,
    @Default('') String servingGrams,
    @Default('') String servingVolumeMl,
    @Default('') String calories,
    @Default('') String protein,
    @Default('') String carbs,
    @Default('') String fat,
    @Default('') String saturatedFat,
    @Default('') String transFat,
    @Default('') String monounsaturatedFat,
    @Default('') String polyunsaturatedFat,
    @Default('') String fiber,
    @Default('') String sugars,
    @Default('') String addedSugars,
    @Default('') String sodium,
    @Default('') String potassium,
    @Default('') String cholesterol,
    @Default('') String iron,
    @Default('') String calcium,
    @Default('') String vitaminD,
    @Default('') String vitaminC,

    /// Raw digits as typed or scanned, `''` when the food has none.
    ///
    /// Held as typed rather than as a parsed `Barcode` for the same reason
    /// every other field here is a string: the field holds what is in it, and
    /// parsing happens once, at save.
    ///
    /// S2 — a barcode names a product the user is about to eat. Nothing here
    /// or downstream logs it, and no message repeats it.
    @Default('') String barcode,

    /// `null` until a save attempt rejects the barcode. The text comes from
    /// `validateBarcode`, whose copy rules forbid interpolating the input.
    String? barcodeError,

    /// A live catalogue food that already carries the barcode about to be
    /// saved, set when `FoodFormController.save` refuses to create a second
    /// row for the same product. The screen turns this into a choice; it is
    /// cleared at the start of every save attempt.
    Food? duplicateBarcodeMatch,

    /// Whether a nutrition label has been photographed into this form.
    ///
    /// Drives the review banner, which is shown for the rest of the form's
    /// life once it is set: ADR 012's mandatory review is a property of
    /// where the numbers came from, not of how recently they arrived.
    @Default(false) bool labelScanApplied,

    /// The `ScanField` names whose reading scored below
    /// `labelScanCheckThreshold`, so the field can be marked "check this".
    ///
    /// A field the user then edits themselves is **not** removed from the set;
    /// it is only ever recomputed by another scan. The marker says "this
    /// number came off a photo and was not read cleanly", which stays true
    /// of the row until they save.
    @Default(<String>{}) Set<String> lowConfidenceFields,

    /// Cautions to list under the review banner: the parser's own
    /// (`domain/label_ocr/label_warnings.dart`, fixed strings) plus the
    /// merge's "kept your value" notes.
    ///
    /// S2, and the one place in this feature where a recognised value is
    /// interpolated into a message — see `label_scan_merge.dart`. Display
    /// only: never logged, never in an exception.
    @Default(<String>[]) List<String> labelWarnings,

    /// A scanned panel was per 100 **mL**, so no weight could be derived
    /// from it and one is required before saving.
    ///
    /// A stored flag rather than a guess from an empty amount: a per-100 g
    /// scan also fills the amount, and if the user cleared *that* field the
    /// form would otherwise show them a message about millilitres.
    ///
    /// **Sticky.** Once a per-volume panel has been read, this stays true
    /// for the life of the form: the numbers in the fields are still per
    /// 100 mL however many times they scan afterwards.
    @Default(false) bool labelIsPerVolume,

    /// Whether the user has set the amount **since** the per-volume scan.
    ///
    /// A weight they typed before scanning was not about this label's basis
    /// — they were defining a food by weight and then photographed a drink
    /// printed per 100 mL. Saving that pair records "these macros are per
    /// 250 g" about figures printed per 100 mL, which is false, so the form
    /// asks again rather than accepting the coincidence.
    @Default(false) bool labelVolumeWeightConfirmed,

    /// `null` until the first save attempt — the form doesn't mark fields
    /// wrong before the user has finished with them.
    FoodValidation? validation,
    @Default(false) bool isSubmitting,
    String? submitError,
  }) = _FoodFormState;

  const FoodFormState._();

  bool get hasAnyOptionalNutrient =>
      saturatedFat.isNotEmpty ||
      transFat.isNotEmpty ||
      monounsaturatedFat.isNotEmpty ||
      polyunsaturatedFat.isNotEmpty ||
      fiber.isNotEmpty ||
      sugars.isNotEmpty ||
      addedSugars.isNotEmpty ||
      sodium.isNotEmpty ||
      potassium.isNotEmpty ||
      cholesterol.isNotEmpty ||
      iron.isNotEmpty ||
      calcium.isNotEmpty ||
      vitaminD.isNotEmpty ||
      vitaminC.isNotEmpty;

  /// Whether the save must wait for a weight the user has to supply.
  ///
  /// A per-100 mL panel gives numbers and no mass. Blank is *not* 100 here
  /// — `_effectiveServing` reads an empty amount as 100, which for this
  /// panel would silently record "per 100 g" for a figure printed per
  /// 100 mL, the exact class of silent-wrong-number
  /// `knowledge/domain/nutrition.md` withdrew the `ml` unit over.
  ///
  /// Two gates, and both are needed. An **unconfirmed** weight is one they
  /// typed before the scan, which said nothing about this label. A
  /// **blank** amount is the one the scan itself left behind — and it stays
  /// a blocker even after they have confirmed once, because clearing the
  /// field again puts the same silent 100 back.
  bool get needsWeightForVolumeLabel =>
      labelIsPerVolume &&
      (!labelVolumeWeightConfirmed || basisAmount.trim().isEmpty);
}
