import 'package:flutter/services.dart' show PlatformException;
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/ocr/ocr_text.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/platform/ocr/ocr_providers.dart';
import 'package:menfit_app/features/nutrition/domain/barcode.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/nutrition_label_parser.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_validation.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_seed.dart';
import 'package:menfit_app/features/nutrition/presentation/food_form_state.dart';
import 'package:menfit_app/features/nutrition/presentation/label_scan_fields.dart';
import 'package:menfit_app/features/nutrition/presentation/label_scan_merge.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:menfit_app/features/nutrition/presentation/food_form_state.dart';

part 'food_form_controller.g.dart';

@riverpod
class FoodFormController extends _$FoodFormController {
  @override
  FoodFormState build(FoodFormSeed? seed) {
    if (seed == null) return const FoodFormState();

    final isPer100g = seed.servingBasis == ServingBasis.per100g;
    final isPer100ml = seed.servingBasis == ServingBasis.per100ml;
    final isPer100 = isPer100g || isPer100ml;
    final initialBasisMode = isPer100
        ? FoodBasisMode.perReference
        : FoodBasisMode.serving;

    // Editing an existing food opens on its own serving description, not on
    // a gram basis derived from it. `_effectiveServing` round-trips the
    // description/weight pair exactly in this mode, where the 'g' basis
    // would rewrite '1 cup (dry)' as '1 serving (40 g)' — acceptable when
    // that produced a new row, data loss now that the save updates the food
    // itself.
    final editsExistingFood =
        seed.isEditingExistingFood && seed.servingDescription.trim().isNotEmpty;
    final initialBasisAmount = isPer100
        ? '100'
        : (!editsExistingFood && seed.servingGrams.isNotEmpty
              ? seed.servingGrams
              : (!editsExistingFood && seed.servingVolumeMl.isNotEmpty
                    ? seed.servingVolumeMl
                    : '1'));
    final initialBasisUnit = isPer100
        ? (isPer100ml ? 'ml' : 'g')
        : (!editsExistingFood && seed.servingGrams.isNotEmpty
              ? 'g'
              : (!editsExistingFood && seed.servingVolumeMl.isNotEmpty
                    ? 'ml'
                    : 'serving'));

    return FoodFormState(
      name: seed.name,
      brand: seed.brand,
      basisMode: initialBasisMode,
      basisAmount: initialBasisAmount,
      basisUnit: initialBasisUnit,
      servingDescription: seed.servingDescription,
      servingGrams: seed.servingGrams,
      servingVolumeMl: seed.servingVolumeMl,
      calories: seed.calories,
      protein: seed.protein,
      carbs: seed.carbs,
      fat: seed.fat,
      iron: seed.iron,
      saturatedFat: seed.saturatedFat,
      transFat: seed.transFat,
      monounsaturatedFat: seed.monounsaturatedFat,
      polyunsaturatedFat: seed.polyunsaturatedFat,
      fiber: seed.fiber,
      sugars: seed.sugars,
      addedSugars: seed.addedSugars,
      sodium: seed.sodium,
      potassium: seed.potassium,
      cholesterol: seed.cholesterol,
      calcium: seed.calcium,
      vitaminD: seed.vitaminD,
      vitaminC: seed.vitaminC,
      barcode: seed.barcode,
    );
  }

  void updateName(String value) => state = state.copyWith(name: value);

  void updateBrand(String value) => state = state.copyWith(brand: value);

  void updateBasisMode(FoodBasisMode mode) {
    if (mode == FoodBasisMode.perReference) {
      state = state.copyWith(
        basisMode: mode,
        basisAmount: state.basisAmount == '1' ? '100' : state.basisAmount,
        basisUnit: state.basisUnit == 'serving' ? 'g' : state.basisUnit,
      );
    } else {
      state = state.copyWith(basisMode: mode);
    }
  }

  /// Takes the amount field's raw text.
  ///
  /// Setting the amount is how a user answers a per-100 mL label's one
  /// unanswerable question — what does 100 mL of this weigh — so touching
  /// this field is what marks that weight confirmed
  /// (`FoodFormState.needsWeightForVolumeLabel`). A blank entry still
  /// blocks the save; the confirmation is about *whose* number it is, not
  /// about there being one.
  void updateBasisAmount(String value) => state = state.copyWith(
    basisAmount: value,
    labelVolumeWeightConfirmed: true,
  );

  void updateBasisUnit(String value) =>
      state = state.copyWith(basisUnit: value);

  void updateServingDescription(String value) =>
      state = state.copyWith(servingDescription: value);

  void updateServingGrams(String value) =>
      state = state.copyWith(servingGrams: value);

  void updateServingVolumeMl(String value) =>
      state = state.copyWith(servingVolumeMl: value);

  void updateCalories(String value) => state = state.copyWith(calories: value);

  void updateProtein(String value) => state = state.copyWith(protein: value);

  void updateCarbs(String value) => state = state.copyWith(carbs: value);

  void updateFat(String value) => state = state.copyWith(fat: value);

  void updateSaturatedFat(String value) =>
      state = state.copyWith(saturatedFat: value);

  void updateTransFat(String value) => state = state.copyWith(transFat: value);

  void updateMonounsaturatedFat(String value) =>
      state = state.copyWith(monounsaturatedFat: value);

  void updatePolyunsaturatedFat(String value) =>
      state = state.copyWith(polyunsaturatedFat: value);

  void updateFiber(String value) => state = state.copyWith(fiber: value);

  void updateSugars(String value) => state = state.copyWith(sugars: value);

  void updateAddedSugars(String value) =>
      state = state.copyWith(addedSugars: value);

  void updateSodium(String value) => state = state.copyWith(sodium: value);

  void updatePotassium(String value) =>
      state = state.copyWith(potassium: value);

  void updateCholesterol(String value) =>
      state = state.copyWith(cholesterol: value);

  void updateIron(String value) => state = state.copyWith(iron: value);

  void updateCalcium(String value) => state = state.copyWith(calcium: value);

  void updateVitaminD(String value) => state = state.copyWith(vitaminD: value);

  void updateVitaminC(String value) => state = state.copyWith(vitaminC: value);

  /// Takes the barcode field's raw text.
  ///
  /// Clears [FoodFormState.barcodeError] as they type, so the field stops
  /// arguing with a barcode that is only half entered — the same rule
  /// `presentation/barcode_entry_dialog.dart` follows.
  void updateBarcode(String value) =>
      state = state.copyWith(barcode: value, barcodeError: null);

  /// Forgets a duplicate-barcode prompt the user backed out of, so the next
  /// save starts from a clean state rather than re-showing a stale match.
  void dismissDuplicateBarcode() =>
      state = state.copyWith(duplicateBarcodeMatch: null);

  /// Photographs a nutrition panel and merges what it says into the form.
  ///
  /// The whole flow lives here rather than in the widget because every step
  /// of it is a decision: a cancel is not a failure, a denied camera is not
  /// a cancel, an unreadable photo is not an error, and a panel that *was*
  /// read still may not overwrite a single thing the user typed
  /// (`label_scan_merge.dart`). The widget gets a [LabelScanOutcome] and
  /// turns it into words.
  ///
  /// Nothing is saved and nothing is persisted: this fills fields, and the
  /// existing [save] path — validation included — is untouched. ADR 012's
  /// review step is that gap, and it is the point of the feature.
  ///
  /// **Nothing about the photo or its contents is logged.** The captured
  /// file is deleted by `LabelCaptureService` before this returns; the
  /// error object from a failed capture can carry its path, so it is
  /// classified and dropped, never printed and never put in a message.
  Future<LabelScanOutcome> scanLabel() async {
    final OcrResult? ocr;
    try {
      ocr = await ref
          .read(labelCaptureServiceProvider)
          .captureAndRecognizeLabel();
    } on PlatformException catch (error) {
      // `camera_access_denied` on iOS and Android; the photo-library codes
      // follow the same shape and mean the same thing to the user.
      return error.code.contains('access_denied')
          ? LabelScanOutcome.cameraDenied
          : LabelScanOutcome.failed;
    } on Object {
      return LabelScanOutcome.failed;
    }

    if (ocr == null) return LabelScanOutcome.cancelled;
    if (ocr.isUnsupported) return LabelScanOutcome.unsupported;

    final label = const NutritionLabelParser().parse(ocr);
    // `isEmpty` only. An unrecognised *standard* is not an unreadable
    // panel: a tightly framed shot that crops the "Nutrition Information"
    // heading still yields a clean two-column table, and refusing it would
    // tell the user their perfectly good photo could not be read. The parser
    // already says so through `warnUnknownFormat`, which the review banner
    // renders — a caution to check every value, not a dead end.
    if (label.isEmpty) return LabelScanOutcome.notRecognised;

    state = applyLabelScan(state, mapParsedLabel(label), parsedLabel: label);
    return LabelScanOutcome.applied;
  }

  /// Switches the basis for a scanned label between Per Serving and Per 100g/mL.
  void switchLabelBasis(LabelScanBasis targetBasis) {
    state = switchScannedLabelBasis(state, targetBasis);
  }

  /// A live catalogue food already keyed on [canonicalBarcode] that is **not
  /// the food this form is editing**, or `null` when there is no collision.
  ///
  /// The comparison is on id, not on the barcode the form opened with. A
  /// food's own row is never a duplicate of itself, however many times it is
  /// re-saved; but a barcode typed onto an existing food that lands on a
  /// *different* food is exactly the collision worth stopping, and a
  /// barcode-based exemption would wave that one through.
  ///
  /// Creating a new food ([FoodFormSeed.existingFoodId] null) compares
  /// against nothing, so every match counts.
  ///
  /// A repository failure here is swallowed on purpose: the check exists to
  /// stop a duplicate, and letting a flaky read block a save the user is
  /// entitled to make would be the worse failure. Nothing is logged — the
  /// error object could carry the code.
  Future<Food?> _duplicateFor(String canonicalBarcode) async {
    final Food? match;
    try {
      match = await ref
          .read(nutritionRepositoryProvider)
          .getFoodByBarcode(canonicalBarcode);
    } on Object {
      return null;
    }
    if (match == null || match.id == seed?.existingFoodId) return null;
    return match;
  }

  (String description, double? grams, double? volumeMl) _effectiveServing() {
    if (state.basisMode == FoodBasisMode.perReference) {
      final amount = state.basisAmount.trim().isEmpty
          ? '100'
          : state.basisAmount.trim();
      final unit = state.basisUnit;
      final desc = 'Per $amount $unit';
      final parsedAmount = parseNutritionNumber(amount);
      final double? grams;
      final double? volumeMl;
      switch (unit) {
        case 'oz':
          grams = parsedAmount == null ? null : parsedAmount * 28.3495;
          volumeMl = null;
        case 'ml':
          grams = null;
          volumeMl = parsedAmount;
        case 'fl oz':
          grams = null;
          volumeMl = parsedAmount == null ? null : parsedAmount * 29.5735295625;
        default:
          grams = parsedAmount;
          volumeMl = null;
      }
      return (desc, grams, volumeMl);
    }

    // Serving mode
    if (state.basisUnit == 'g') {
      final amount = state.basisAmount.trim().isEmpty
          ? '100'
          : state.basisAmount.trim();
      final parsedAmount = parseNutritionNumber(amount);
      final volumeMl = parseNutritionNumber(state.servingVolumeMl);
      final desc = volumeMl != null
          ? '1 serving ($amount g, ${formatNutritionField(volumeMl)} ml)'
          : '1 serving ($amount g)';
      return (desc, parsedAmount, volumeMl);
    } else if (state.basisUnit == 'oz') {
      final amount = state.basisAmount.trim().isEmpty
          ? '1'
          : state.basisAmount.trim();
      final parsedAmount = parseNutritionNumber(amount);
      final grams = parsedAmount == null ? null : parsedAmount * 28.3495;
      final volumeMl = parseNutritionNumber(state.servingVolumeMl);
      final desc = volumeMl != null
          ? '1 serving ($amount oz, ${formatNutritionField(volumeMl)} ml)'
          : '1 serving ($amount oz)';
      return (desc, grams, volumeMl);
    } else if (state.basisUnit == 'ml') {
      final amount = state.basisAmount.trim().isEmpty
          ? '100'
          : state.basisAmount.trim();
      final parsedAmount = parseNutritionNumber(amount);
      final grams = parseNutritionNumber(state.servingGrams);
      final desc = grams != null
          ? '1 serving (${formatNutritionField(grams)} g, $amount ml)'
          : '1 serving ($amount ml)';
      return (desc, grams, parsedAmount);
    } else if (state.basisUnit == 'fl oz') {
      final amount = state.basisAmount.trim().isEmpty
          ? '1'
          : state.basisAmount.trim();
      final parsedAmount = parseNutritionNumber(amount);
      final volumeMl = parsedAmount == null
          ? null
          : parsedAmount * 29.5735295625;
      final grams = parseNutritionNumber(state.servingGrams);
      final desc = grams != null
          ? '1 serving (${formatNutritionField(grams)} g, $amount fl oz)'
          : '1 serving ($amount fl oz)';
      return (desc, grams, volumeMl);
    } else {
      // Unit is 'serving' or custom
      final desc = state.servingDescription.trim().isNotEmpty
          ? state.servingDescription.trim()
          : (state.basisAmount.trim() == '1' || state.basisAmount.trim().isEmpty
                ? '1 serving'
                : '${state.basisAmount.trim()} servings');
      final grams = parseNutritionNumber(state.servingGrams);
      final volumeMl = parseNutritionNumber(state.servingVolumeMl);
      return (desc, grams, volumeMl);
    }
  }

  /// Validates, and on success persists a new [Food] and returns it.
  ///
  /// Returns `null` for every outcome that is not a saved food, with the
  /// reason on the state: field errors on [FoodFormState.validation], a
  /// rejected barcode on [FoodFormState.barcodeError], a catalogue collision
  /// on [FoodFormState.duplicateBarcodeMatch], and a persistence failure on
  /// [FoodFormState.submitError]. The screen reads those rather than being
  /// handed a reason to interpret, which keeps the decisions here.
  ///
  /// [allowDuplicateBarcode] is the user's answer to the collision prompt —
  /// "save as a new food anyway". Nothing else may set it: silently skipping
  /// the check is what produces a catalogue with one row per scan.
  Future<Food?> save({bool allowDuplicateBarcode = false}) async {
    state = state.copyWith(duplicateBarcodeMatch: null);

    // A per-100 mL panel supplies numbers and no mass, and `_effectiveServing`
    // reads a blank amount as 100 — which would file figures printed per
    // 100 mL as "per 100 g" without anybody being told. The one thing the
    // app cannot work out is the one thing it asks for.
    if (state.needsWeightForVolumeLabel) {
      state = state.copyWith(submitError: labelScanPerVolumeWarning);
      return null;
    }

    final (effectiveDesc, effectiveGrams, effectiveVolumeMl) =
        _effectiveServing();

    final validation = validateFood(
      name: state.name,
      servingDescription: effectiveDesc,
      caloriesKcal: parseNutritionNumber(state.calories),
      proteinGrams: parseNutritionNumber(state.protein),
      carbsGrams: parseNutritionNumber(state.carbs),
      fatGrams: parseNutritionNumber(state.fat),
      saturatedFatGrams: parseNutritionNumber(state.saturatedFat),
      transFatGrams: parseNutritionNumber(state.transFat),
      monounsaturatedFatGrams: parseNutritionNumber(state.monounsaturatedFat),
      polyunsaturatedFatGrams: parseNutritionNumber(state.polyunsaturatedFat),
      fiberGrams: parseNutritionNumber(state.fiber),
      sugarsGrams: parseNutritionNumber(state.sugars),
      addedSugarsGrams: parseNutritionNumber(state.addedSugars),
      sodiumMg: parseNutritionNumber(state.sodium),
      potassiumMg: parseNutritionNumber(state.potassium),
      cholesterolMg: parseNutritionNumber(state.cholesterol),
      ironMg: parseNutritionNumber(state.iron),
      calciumMg: parseNutritionNumber(state.calcium),
      vitaminDMcg: parseNutritionNumber(state.vitaminD),
      vitaminCMg: parseNutritionNumber(state.vitaminC),
      servingGrams: effectiveGrams,
      servingVolumeMl: effectiveVolumeMl,
    );

    // The barcode is validated alongside the nutrition fields rather than
    // before them, so one save attempt reports everything that is wrong
    // instead of making the user find the problems one at a time.
    final typedBarcode = state.barcode.trim();
    // A barcode that arrived with the seed and hasn't been touched is
    // exempt: a legacy row saved before check-digit validation existed (or
    // imported some other way) can otherwise never be saved again, because
    // every edit — even one that has nothing to do with the barcode —
    // re-validates a code that was always going to fail. Anything they
    // actually typed, including re-entering the same digits by hand, is
    // still validated normally; "unchanged" is byte-identical to
    // [FoodFormSeed.barcode], not merely digit-equivalent.
    final seedBarcode = seed?.barcode.trim() ?? '';
    final barcodeIsUntouched =
        seedBarcode.isNotEmpty && typedBarcode == seedBarcode;
    final barcodeValidation = typedBarcode.isEmpty || barcodeIsUntouched
        ? const BarcodeValidation()
        : validateBarcode(typedBarcode);

    if (!validation.isValid || !barcodeValidation.isValid) {
      state = state.copyWith(
        validation: validation,
        barcodeError: barcodeValidation.error,
      );
      return null;
    }

    final canonicalBarcode = barcodeIsUntouched
        ? (typedBarcode.isEmpty ? null : typedBarcode)
        : barcodeValidation.barcode?.digits;

    // Check for collision with another catalogue food before saving, unless
    // the user has already seen the match and said to save anyway.
    if (!allowDuplicateBarcode && canonicalBarcode != null) {
      final duplicate = await _duplicateFor(canonicalBarcode);
      if (duplicate != null) {
        state = state.copyWith(duplicateBarcodeMatch: duplicate);
        return null;
      }
    }

    state = state.copyWith(isSubmitting: true, submitError: null);

    final now = DateTime.now().toUtc();
    final brand = state.brand.trim();
    try {
      final food = Food(
        // Editing keeps the food's identity, which is what makes this an
        // update rather than a twin: `saveFood` upserts by id and reads
        // `createdAt` back off the existing row, and every diary entry's
        // `foodId` still resolves.
        id: seed?.existingFoodId ?? EntityId.generate(),
        name: state.name.trim(),
        brand: brand.isEmpty ? null : brand,
        servingDescription: effectiveDesc,
        servingGrams: effectiveGrams,
        servingVolumeMl: effectiveVolumeMl,
        perServing: NutritionFacts(
          caloriesKcal: parseNutritionNumber(state.calories)!,
          proteinGrams: parseNutritionNumber(state.protein)!,
          carbsGrams: parseNutritionNumber(state.carbs)!,
          fatGrams: parseNutritionNumber(state.fat)!,
          saturatedFatGrams: parseNutritionNumber(state.saturatedFat),
          transFatGrams: parseNutritionNumber(state.transFat),
          monounsaturatedFatGrams: parseNutritionNumber(
            state.monounsaturatedFat,
          ),
          polyunsaturatedFatGrams: parseNutritionNumber(
            state.polyunsaturatedFat,
          ),
          fiberGrams: parseNutritionNumber(state.fiber),
          sugarsGrams: parseNutritionNumber(state.sugars),
          addedSugarsGrams: parseNutritionNumber(state.addedSugars),
          sodiumMg: parseNutritionNumber(state.sodium),
          potassiumMg: parseNutritionNumber(state.potassium),
          cholesterolMg: parseNutritionNumber(state.cholesterol),
          ironMg: parseNutritionNumber(state.iron),
          calciumMg: parseNutritionNumber(state.calcium),
          vitaminDMcg: parseNutritionNumber(state.vitaminD),
          vitaminCMg: parseNutritionNumber(state.vitaminC),
        ),
        barcode: canonicalBarcode,
        // Provenance comes from the seed's own discriminator, never from
        // "was there a seed at all": a food the provider had never heard of
        // is typed off the packet by the user and is `custom`, and a food
        // re-opened for editing keeps whatever it already was. See
        // `presentation/food_form_seed.dart#source` and ADR 010.
        source: seed?.source ?? FoodSource.custom,
        providerFoodId: seed?.providerFoodId,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(nutritionRepositoryProvider).saveFood(food);
      state = state.copyWith(isSubmitting: false);
      return food;
    } on Object catch (error) {
      state = state.copyWith(
        submitError: userMessageFor(error),
        isSubmitting: false,
      );
      return null;
    }
  }
}

/// Reads one numeric field: `null` when blank, and **NaN** when non-numeric.
double? parseNutritionNumber(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  return double.tryParse(trimmed.replaceAll(',', '.')) ?? double.nan;
}
