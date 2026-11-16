import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';

part 'provider_food.freezed.dart';

/// Where a [ProviderFood]'s per-serving numbers came from.
///
/// This is an honesty requirement rather than bookkeeping: "per serving"
/// means three materially different things depending on what the source
/// database actually stated, and the review screen shows the user which one
/// the user is looking at instead of presenting all three as equally
/// authoritative.
enum ServingBasis {
  /// The provider stated per-serving values itself. Authoritative — prefer
  /// this whenever the source has it.
  statedPerServing,

  /// Computed as `per100g × servingGrams / 100`. Arithmetic on the
  /// provider's own numbers, but no better than the serving weight it
  /// leaned on.
  derivedFromPer100g,

  /// No usable serving information at all: the serving *is* 100 g, and
  /// [ProviderFood.servingDescription] says exactly that.
  per100g,

  /// No usable serving information at all for a liquid: the serving *is*
  /// 100 ml, and [ProviderFood.servingDescription] says exactly that.
  per100ml,
}

/// What a [ProviderFoodSummary]'s energy and macro figures are *per*.
///
/// A search hit's numbers are not always per 100 g, however much the field
/// names suggest it. FatSecret answers "Per 1 serving" with no size at all,
/// and a per-serving figure rendered as a per-100 g one is wrong by a factor
/// nobody can see — a 680 g serving shown as per-100 g is 6.8× out. So the
/// basis travels with the numbers instead of being assumed by whatever draws
/// them.
enum SummaryMacroBasis {
  /// Per 100 grams.
  per100g,

  /// Per 100 millilitres — the same shape as [per100g] for a food the
  /// provider states by volume.
  per100ml,

  /// Per the serving [ProviderFoodSummary.servingDescription] names, which
  /// may have no stated size at all. Never scaled.
  perServing,
}

/// One hit from a food provider's text search — enough to render a result
/// row and nothing more.
///
/// Deliberately a different type from [ProviderFood] rather than a
/// partially-filled one, because the two endpoints genuinely return
/// different data: **iron is structurally unavailable in search results**
/// (Open Food Facts' search index carries seven nutriments and iron is not
/// among them), as are per-serving values and any quality signal. A missing
/// iron figure here therefore says nothing whatsoever about the food — it
/// is a property of the endpoint. Anything that needs iron must fetch the
/// full record via `FoodDataProvider.fetchDetails`.
///
/// Every nutrition number is nullable — see [ProviderFood]'s doc for why
/// `null` is never coalesced to `0` — and is per whatever [macroBasis]
/// says, which is per 100 g unless the provider stated otherwise.
@freezed
abstract class ProviderFoodSummary with _$ProviderFoodSummary {
  const factory ProviderFoodSummary({
    /// Which provider produced this specific result.
    ///
    /// Stamped by the mapper that built this summary
    /// (`data/open_food_facts_mapper.dart`, `data/fat_secret_mapper.dart`),
    /// never defaulted: when a composite provider tries a primary and falls
    /// back to a second one (`domain/fallback_food_data_provider.dart`), a
    /// missing source here would be a provenance bug, not a detail to paper
    /// over with a guess.
    required FoodSource source,

    /// The provider's **own key** for this record — what
    /// `FoodDataProvider.fetchDetails` fetches the full record by. A
    /// FatSecret `food_id`, an Open Food Facts product code.
    ///
    /// **Never a barcode by shape.** A FatSecret `food_id` is a run of
    /// digits, and an 8-digit one can pass the EAN-8 check digit
    /// (`27365861` does), so nothing may infer "this is a GTIN" from what
    /// an id looks like. That inference sent search hits down the barcode
    /// path and put the id in the form's barcode field (B23). Whether a
    /// hit has a barcode at all is [barcode]'s job to say.
    required String providerFoodId,

    /// Best available product name; never blank (falls back to the
    /// provider's id when the provider has no usable name).
    required String name,

    /// The product's real GTIN barcode, **only when the provider states
    /// one**, as the provider echoed it back. `null` for a FatSecret search
    /// hit — `foods.search` carries no barcode — and never filled from
    /// [providerFoodId].
    String? barcode,

    /// Brand or maker, when the provider states one.
    String? brand,

    /// Energy per [macroBasis], in kilocalories. `null` means the provider
    /// doesn't state it.
    double? caloriesKcal,

    /// Protein per [macroBasis], in grams. `null` means not stated.
    double? proteinGrams,

    /// Carbohydrate per [macroBasis], in grams. `null` means not stated.
    double? carbsGrams,

    /// Fat per [macroBasis], in grams. `null` means not stated.
    double? fatGrams,

    /// Stated serving description (e.g. "1 bar (45 g)", "250 ml"), when
    /// available.
    String? servingDescription,

    /// Serving weight in grams, when available.
    double? servingGrams,

    /// Serving volume in millilitres, when available.
    double? servingVolumeMl,

    /// Energy per serving in kilocalories, when available.
    double? servingCaloriesKcal,

    /// What [caloriesKcal], [proteinGrams], [carbsGrams] and [fatGrams] are
    /// per: 100 g, 100 ml, or the stated serving — see [SummaryMacroBasis].
    ///
    /// Defaults to [SummaryMacroBasis.per100g] because that is what every
    /// search index answers with unless it says otherwise; a mapper that
    /// knows better sets it, and anything rendering or rescaling these
    /// numbers must read it rather than assume.
    @Default(SummaryMacroBasis.per100g) SummaryMacroBasis macroBasis,
  }) = _ProviderFoodSummary;

  const ProviderFoodSummary._();

  /// Name plus brand when there is one — mirrors `Food.displayName` so a
  /// search result and a saved food read identically in a list.
  String get displayName => brand == null ? name : '$name · $brand';
}

/// A **candidate** food fetched from an external food database — not a
/// `Food`, and deliberately not convertible into one.
///
/// Every nutrition number here is nullable, including calories and the
/// macros. That is the crux of provider-sourced data: a crowd-sourced
/// database omits whatever no contributor entered, and coalescing an
/// absent value to `0` would turn a gap in someone else's database into a
/// factual claim about a food — the exact mistake
/// `domain/nutrition_facts.dart` already refuses to make for iron. `Food`
/// requires non-null macros precisely because a saved food is a definition
/// the user stands behind; the gap between the two is closed by the user on
/// a review screen, not by this layer inventing zeros.
///
/// There is intentionally **no `toFood()`** on this type. Building a `Food`
/// takes a decision about every missing number, and that decision belongs
/// to the person who is going to eat the thing.
///
/// S2-tier data once it is associated with the user's diary
/// (`knowledge/engineering/security_and_privacy.md`): never logged, never
/// in analytics, never in an exception message — a barcode identifies a
/// specific product a specific person is about to eat.
@freezed
abstract class ProviderFood with _$ProviderFood {
  const factory ProviderFood({
    /// Which provider produced this result — see
    /// [ProviderFoodSummary.source], which carries the same requirement for
    /// the same reason.
    required FoodSource source,

    /// The product's real GTIN barcode, **as the provider echoed it back**,
    /// or `null` when this record was reached without one (a FatSecret
    /// record fetched by its `food_id` from a search hit).
    ///
    /// Providers normalise codes server-side (leading zeros, EAN-8 to
    /// EAN-13), so this can differ from the scanned string. Anything keyed
    /// on a barcode — a cache, a saved `Food.barcode` — keys on this, and
    /// only on this: a provider's record id is never a barcode (B23, see
    /// [ProviderFoodSummary.providerFoodId]).
    required String? barcode,

    /// Best available product name; never blank (falls back to the
    /// barcode or the provider's id when the provider has no usable name).
    required String name,

    /// Free-text description of one serving, exactly as the provider
    /// states it (`'3/4 cup (28 g)'`), or `'100 g'` when
    /// [servingBasis] is [ServingBasis.per100g].
    ///
    /// Displayed, never parsed: providers do not normalise this field and
    /// malformed values are common in practice.
    required String servingDescription,

    /// Where the per-serving numbers below came from. Shown to the user —
    /// see [ServingBasis].
    required ServingBasis servingBasis,

    /// Brand or maker, when the provider states one.
    String? brand,

    /// The provider's own key for this record (a FatSecret `food_id`, an
    /// Open Food Facts product code), when known — see
    /// [ProviderFoodSummary.providerFoodId]. Identity only; never a barcode.
    String? providerFoodId,

    /// Mass of one serving in grams, when a usable one is known. `100`
    /// when [servingBasis] is [ServingBasis.per100g].
    double? servingGrams,

    /// Volume of one serving in millilitres, when a usable one is known.
    double? servingVolumeMl,

    /// Energy per serving, in kilocalories. `null` means **not stated** —
    /// see the class doc.
    double? caloriesKcal,

    /// Protein per serving, in grams. `null` means not stated.
    double? proteinGrams,

    /// Carbohydrate per serving, in grams. `null` means not stated.
    double? carbsGrams,

    /// Fat per serving, in grams. `null` means not stated.
    double? fatGrams,

    /// Iron per serving, in **milligrams**. `null` means not stated.
    ///
    /// Providers commonly express iron in grams; converting to the
    /// milligrams this app uses happens at the data layer, so everything
    /// above it sees one unit.
    double? ironMg,

    /// Calcium per serving, in milligrams. `null` means not stated.
    double? calciumMg,

    /// Vitamin D per serving, in micrograms. `null` means not stated.
    double? vitaminDMcg,

    /// Vitamin C per serving, in milligrams. `null` means not stated.
    double? vitaminCMg,

    /// Dietary fiber per serving, in grams. `null` means not stated.
    double? fiberGrams,

    /// Sodium per serving, in milligrams. `null` means not stated.
    double? sodiumMg,

    /// Potassium per serving, in milligrams. `null` means not stated.
    double? potassiumMg,

    /// Saturated fat per serving, in grams. `null` means not stated.
    double? saturatedFatGrams,

    /// The provider's own 0–1 completeness score for the product record,
    /// when it publishes one. A signal about the *record*, not about the
    /// food — a low score means "few people have filled this in".
    double? completeness,

    /// Whether the provider marks this product's nutrition facts as
    /// complete. Stronger than [completeness], which counts photos and
    /// categories too.
    @Default(false) bool hasCompleteNutritionFacts,

    /// Whether the provider records that this product carries **no**
    /// nutrition information at all (an unlabelled loose product, say).
    ///
    /// Distinct from "we have no numbers for it": this is the database
    /// asserting there is nothing to have, which the review screen can say
    /// out loud instead of showing an empty form.
    @Default(false) bool hasNoNutritionData,
  }) = _ProviderFood;

  const ProviderFood._();

  /// Name plus brand when there is one — mirrors `Food.displayName`.
  String get displayName => brand == null ? name : '$name · $brand';

  /// Whether energy and all three macros are stated, i.e. whether a
  /// review screen could pre-fill every field `Food` requires.
  bool get hasCompleteMacros =>
      caloriesKcal != null &&
      proteinGrams != null &&
      carbsGrams != null &&
      fatGrams != null;

  /// Whether iron is stated. `false` means unknown, never zero — the same
  /// distinction `NutritionFacts.hasIron` carries.
  bool get hasIron => ironMg != null;
}
