import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/label_ocr/parsed_nutrition_label.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';
import 'package:menfit_app/features/nutrition/presentation/label_scan_fields.dart';
import 'package:menfit_app/features/nutrition/presentation/nutrition_format.dart';

part 'food_form_seed.freezed.dart';

/// What a provider lookup hands the food form to start from — the
/// review-before-save step ADR 010 requires between a `ProviderFood` and a
/// saved `Food`.
///
/// **Raw text, not parsed numbers**, matching `FoodFormState`: the form's
/// fields hold what is in them, and parsing happens once at save. Seeding
/// with `double`s would mean formatting them twice and disagreeing with
/// whatever the user then types.
///
/// An absent provider number seeds a **blank** string, never `'0'`. This is
/// the whole point of the wave: `ProviderFood` carries nullable macros
/// because a crowd-sourced database omits what nobody entered, and a `0`
/// here would turn that gap into a claim about the food
/// (`domain/provider_food.dart`). Blank fields fail the existing
/// `validateFood` check, which is exactly right — the user supplies them.
///
/// Freezed, and passed through the router as `$extra`, so **family identity
/// is by value**: two lookups of the same product produce equal seeds and
/// therefore share one controller instance rather than silently
/// accumulating one per scan.
///
/// S2-tier once associated with the diary: never logged, never in analytics,
/// never in an exception message.
@freezed
abstract class FoodFormSeed with _$FoodFormSeed {
  const factory FoodFormSeed({
    /// The provider's **echoed** barcode — see [FoodFormSeed.fromProviderFood].
    required String barcode,

    /// Where the *data* in this seed came from, which is what the saved
    /// [Food] must record (ADR 010: provenance records where data came from,
    /// and survives the user editing every number).
    ///
    /// **This is a discriminator, not a decoration.** The form previously
    /// inferred provenance from "was there a seed at all", which made
    /// [FoodFormSeed.forUnknownBarcode] — the provider had no product and
    /// the user typed every figure off the packet herself — save as
    /// `openFoodFacts`. That is a false attribution in both directions: it
    /// credits a database with numbers it never supplied, and it would let a
    /// future sync backend treat a hand-authored row as ODbL-derived. Only a
    /// seed that actually carries provider data says
    /// [FoodSource.openFoodFacts].
    ///
    /// The default is [FoodSource.custom] because the plain constructor is
    /// used for hand-authored and edit-an-existing-food seeds; callers
    /// re-opening an existing food pass that food's own source through, so an
    /// edit never rewrites where the data came from.
    @Default(FoodSource.custom) FoodSource source,
    @Default('') String name,
    @Default('') String brand,
    @Default('') String servingDescription,
    @Default('') String servingGrams,
    @Default('') String servingVolumeMl,
    @Default('') String calories,
    @Default('') String protein,
    @Default('') String carbs,
    @Default('') String fat,
    @Default('') String iron,

    /// The optional nutrients, in the same raw-text form as the four above.
    ///
    /// The provider never supplies these; they exist for
    /// [FoodFormSeed.forEditing]. An edit **overwrites the food's own row**,
    /// so any nutrient the seed leaves blank is one the save would erase —
    /// fibre and sodium a user typed in six months ago have to survive her
    /// correcting the calorie figure.
    ///
    /// Today most of them cannot be erased because they are never stored:
    /// the `foods` table carries energy, the three macros and iron, and
    /// nothing else, so the rest are collected, validated and dropped at the
    /// repository boundary. That gap needs a schema change and is not this
    /// form's to fix — but seeding them here means the day the columns
    /// arrive, the edit path is already correct instead of quietly wiping
    /// them.
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
    @Default('') String calcium,
    @Default('') String vitaminD,
    @Default('') String vitaminC,

    /// The `Food.id` this form is **editing**, or `null` when it will create
    /// a new food.
    ///
    /// Present, the save is an in-place update: `NutritionRepository.saveFood`
    /// upserts by id and reads `createdAt` back off the existing row, so the
    /// food keeps its identity, its creation date and — crucially — every
    /// diary entry's link back to it.
    ///
    /// Absent, the controller generates a fresh id. That used to be the only
    /// behaviour, which meant "Edit food details & macros" silently wrote a
    /// **second catalogue row** every time it was used and left the original
    /// sitting beside it.
    ///
    /// It is also what the duplicate-barcode check compares against, so a
    /// food's own row can never be mistaken for a collision with itself.
    String? existingFoodId,

    /// Where the seeded per-serving numbers came from, or `null` when the
    /// provider had no record at all
    /// ([FoodFormSeed.forUnknownBarcode]). Surfaced on the
    /// review screen so the user knows what she is looking at rather than
    /// meeting three different things all labelled "per serving".
    ServingBasis? servingBasis,

    /// The provider records that this product carries **no** nutrition
    /// information at all — the database asserting there is nothing to
    /// have, which is worth saying out loud instead of showing an empty
    /// form with no explanation.
    @Default(false) bool hasNoNutritionData,

    /// Whether energy and all three macros arrived. `false` means the user
    /// has blanks to fill before she can save.
    @Default(false) bool hasCompleteMacros,

    /// The provider's own 0–1 completeness score for the *record*, when it
    /// publishes one. A statement about how many people have filled the
    /// product in, never about the food.
    double? completeness,
  }) = _FoodFormSeed;

  const FoodFormSeed._();

  /// Seeds the form from a product the provider had.
  ///
  /// [ProviderFood.barcode] is used rather than whatever was scanned or
  /// typed: providers normalise codes server-side, and the saved `Food`
  /// must key on the same string the provider would echo next time
  /// (`domain/provider_food.dart`).
  ///
  /// [source] always comes from [food] itself, never a caller-supplied
  /// default: with a fallback provider live (ADR 016) a single build can
  /// answer with either catalogue, and only the result records which one
  /// actually produced it.
  factory FoodFormSeed.fromProviderFood(ProviderFood food) => FoodFormSeed(
    barcode: food.barcode,
    source: food.source,
    name: food.name,
    brand: food.brand ?? '',
    servingDescription: food.servingDescription,
    servingGrams: formatNutritionField(food.servingGrams),
    servingVolumeMl: formatNutritionField(food.servingVolumeMl),
    calories: formatNutritionField(food.caloriesKcal),
    protein: formatNutritionField(food.proteinGrams),
    carbs: formatNutritionField(food.carbsGrams),
    fat: formatNutritionField(food.fatGrams),
    iron: formatNutritionField(food.ironMg),
    saturatedFat: formatNutritionField(food.saturatedFatGrams),
    fiber: formatNutritionField(food.fiberGrams),
    sodium: formatNutritionField(food.sodiumMg),
    potassium: formatNutritionField(food.potassiumMg),
    calcium: formatNutritionField(food.calciumMg),
    vitaminD: formatNutritionField(food.vitaminDMcg),
    vitaminC: formatNutritionField(food.vitaminCMg),
    servingBasis: food.servingBasis,
    hasNoNutritionData: food.hasNoNutritionData,
    hasCompleteMacros: food.hasCompleteMacros,
    completeness: food.completeness,
  );

  /// Seeds the form with **only** the barcode, for a product the provider
  /// has never heard of.
  ///
  /// Not a failure state: adding a food by hand already works, and this is
  /// that form with the one thing we do know already filled in. Saving it
  /// puts the product in the catalogue, where the next scan finds it
  /// locally and makes no request at all.
  ///
  /// [source] stays [FoodSource.custom]: the provider supplied **nothing**
  /// here but a "no such product", so every figure on the resulting food is
  /// the user's own reading of the packet. See the [source] field.
  factory FoodFormSeed.forUnknownBarcode(String barcode) =>
      FoodFormSeed(barcode: barcode);

  /// Seeds a **fresh** form from a photographed nutrition panel (ADR 012).
  ///
  /// For an entry point that opens the form *on* a scan — from the food
  /// picker, say — rather than scanning into a form already on screen. The
  /// in-form path does not use this: it merges into whatever the user has
  /// already typed (`label_scan_merge.dart`), which a seed cannot express.
  /// Both read the panel through the same [mapParsedLabel], so the two
  /// entry points can never disagree about which column a value came from.
  ///
  /// [source] stays [FoodSource.custom]: every figure here came off a
  /// packet through the user's own camera, and no database supplied any of
  /// it — the same reasoning as [FoodFormSeed.forUnknownBarcode], and the
  /// provenance rule ADR 010 exists to protect.
  ///
  /// **A per-100 mL panel arrives with no amount**, because a millilitre is
  /// not a mass (`knowledge/domain/nutrition.md`). The values seed the
  /// form and [servingBasis] stays null, so the user is asked for the
  /// weight rather than being handed "100 g" for a figure printed per
  /// 100 mL. A caller of this factory must surface
  /// [ParsedNutritionLabel.warnings] the way the in-form banner does; the
  /// seed carries the numbers, not the cautions.
  factory FoodFormSeed.fromParsedLabel(
    ParsedNutritionLabel label, {
    String? barcode,
  }) {
    final fields = mapParsedLabel(label);
    String value(String field) => fields.values[field] ?? '';
    return FoodFormSeed(
      barcode: barcode ?? '',
      servingDescription: fields.servingDescription,
      servingGrams: fields.servingGrams,
      servingVolumeMl: formatNutritionField(label.serving?.millilitres),
      calories: value(ScanField.calories),
      protein: value(ScanField.protein),
      carbs: value(ScanField.carbs),
      fat: value(ScanField.fat),
      iron: value(ScanField.iron),
      saturatedFat: value(ScanField.saturatedFat),
      transFat: value(ScanField.transFat),
      fiber: value(ScanField.fiber),
      sugars: value(ScanField.sugars),
      addedSugars: value(ScanField.addedSugars),
      sodium: value(ScanField.sodium),
      potassium: value(ScanField.potassium),
      cholesterol: value(ScanField.cholesterol),
      calcium: value(ScanField.calcium),
      vitaminD: value(ScanField.vitaminD),
      vitaminC: value(ScanField.vitaminC),
      servingBasis: fields.basis == LabelScanBasis.per100g
          ? ServingBasis.per100g
          : null,
      hasCompleteMacros:
          value(ScanField.calories).isNotEmpty &&
          value(ScanField.protein).isNotEmpty &&
          value(ScanField.carbs).isNotEmpty &&
          value(ScanField.fat).isNotEmpty,
    );
  }

  /// Seeds the form to **edit [food] in place**.
  ///
  /// The one supported way to open `FoodFormScreen` on an existing catalogue
  /// food, from anywhere — the log dialog's "Edit food details & macros", a
  /// manage-foods list, or anything added later. Hand-building a seed for an
  /// existing food is how the two bugs below happened; there is now exactly
  /// one code path and it carries all three of the things that are easy to
  /// forget:
  ///
  /// - **[existingFoodId]**, so the save updates the food rather than
  ///   creating a near-identical twin beside it.
  /// - **[source]**, so provenance is not rewritten by an edit (ADR 010).
  /// - **Every optional nutrient**, because an in-place update writes the
  ///   whole row: anything the seed omits is erased on save. (Most of them
  ///   are not persisted at all yet — see the fields' own dartdoc.)
  ///
  /// [servingDescription] and [servingGrams] come through as themselves
  /// rather than being re-derived, so a food described as `'1 cup (dry)'`
  /// still says that after an edit that only touched its calories.
  factory FoodFormSeed.forEditing(Food food) => FoodFormSeed(
    existingFoodId: food.id,
    barcode: food.barcode ?? '',
    source: food.source,
    name: food.name,
    brand: food.brand ?? '',
    servingDescription: food.servingDescription,
    servingGrams: formatNutritionField(food.servingGrams),
    servingVolumeMl: formatNutritionField(food.servingVolumeMl),
    calories: formatNutritionField(food.perServing.caloriesKcal),
    protein: formatNutritionField(food.perServing.proteinGrams),
    carbs: formatNutritionField(food.perServing.carbsGrams),
    fat: formatNutritionField(food.perServing.fatGrams),
    iron: formatNutritionField(food.perServing.ironMg),
    saturatedFat: formatNutritionField(food.perServing.saturatedFatGrams),
    transFat: formatNutritionField(food.perServing.transFatGrams),
    monounsaturatedFat: formatNutritionField(
      food.perServing.monounsaturatedFatGrams,
    ),
    polyunsaturatedFat: formatNutritionField(
      food.perServing.polyunsaturatedFatGrams,
    ),
    fiber: formatNutritionField(food.perServing.fiberGrams),
    sugars: formatNutritionField(food.perServing.sugarsGrams),
    addedSugars: formatNutritionField(food.perServing.addedSugarsGrams),
    sodium: formatNutritionField(food.perServing.sodiumMg),
    potassium: formatNutritionField(food.perServing.potassiumMg),
    cholesterol: formatNutritionField(food.perServing.cholesterolMg),
    calcium: formatNutritionField(food.perServing.calciumMg),
    vitaminD: formatNutritionField(food.perServing.vitaminDMcg),
    vitaminC: formatNutritionField(food.perServing.vitaminCMg),
    hasCompleteMacros: true,
  );

  /// Whether this seed edits a food that already exists.
  bool get isEditingExistingFood => existingFoodId != null;

  /// Whether the provider actually had a record for this barcode.
  ///
  /// Both halves are needed. [servingBasis] alone said "these numbers are
  /// per something the provider told us", which was true of exactly one
  /// seed until a photographed label became another: a per-100 g panel also
  /// carries a basis, and reading that as "found in the database" would put
  /// the Open Food Facts notes and the ODbL attribution under a food nobody
  /// but the user has ever seen. [source] is the discriminator that already
  /// records where the data came from (ADR 010), so it decides here too.
  bool get foundInDatabase =>
      servingBasis != null &&
      (source == FoodSource.openFoodFacts || source == FoodSource.fatSecret);
}
