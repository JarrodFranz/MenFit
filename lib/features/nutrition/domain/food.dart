import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';

part 'food.freezed.dart';

/// Where a food definition came from.
///
/// A per-row storage discriminator, not a feature switch — and it carries
/// weight beyond bookkeeping. Open Food Facts data is **ODbL-licensed**,
/// and this marker is what will let a future sync backend (ADR 004)
/// separate provider-derived rows from user-authored ones. ODbL's
/// share-alike obligation triggers on *public use* of a derivative
/// database: an on-device personal food diary is not that, but a
/// server-side catalogue assembled from Open Food Facts rows would be, and
/// by then the rows have to already be distinguishable. Recording the
/// specific provider (rather than a single "external" value) is what makes
/// that separable per source.
///
/// Rows written before S1-5 predate every provider value and read back as
/// [custom]; the named values are stable storage keys, never renamed.
enum FoodSource {
  /// The user typed this food in themselves.
  custom,

  /// The food came from an external food database whose identity wasn't
  /// recorded. No code writes this — it exists because the schema shipped
  /// with it (S1-4) and old rows must still round-trip.
  provider,

  /// The food came from Open Food Facts
  /// (`data/open_food_facts_service.dart`), reviewed and saved by the user
  /// from a barcode scan or a product search.
  openFoodFacts,

  /// The food came from FatSecret (`data/fat_secret_service.dart`), reviewed
  /// and saved by the user from a barcode scan or a product search.
  fatSecret;

  /// Parses the persisted string form, defaulting to [custom] for any
  /// unrecognised value — every row written before S1-5 is a custom food,
  /// so that is the safe reading of an unknown key.
  static FoodSource fromStorage(String value) {
    return switch (value) {
      'provider' => FoodSource.provider,
      'open_food_facts' => FoodSource.openFoodFacts,
      'fat_secret' => FoodSource.fatSecret,
      _ => FoodSource.custom,
    };
  }

  /// The persisted string form of this value.
  String toStorage() => switch (this) {
    FoodSource.custom => 'custom',
    FoodSource.provider => 'provider',
    FoodSource.openFoodFacts => 'open_food_facts',
    FoodSource.fatSecret => 'fat_secret',
  };
}

/// A food definition: what one serving of something contains.
///
/// Mirrors `core/db/tables/foods.dart` one field at a time; mapping to/from
/// the Drift row happens in `data/drift_nutrition_repository.dart` so the
/// Drift type never leaks above the data layer (coding_standards.md).
///
/// A `Food` is a **reusable definition**, never a record of eating: logging
/// is `NutritionEntry`, which snapshots [perServing] at log time so editing
/// a food never rewrites history (see
/// `core/db/tables/nutrition_entries.dart`).
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`): never
/// logged, never in analytics, never in an exception message.
@freezed
abstract class Food with _$Food {
  const factory Food({
    required String id,
    required String name,

    /// Plain-English description of one serving, e.g. `'1 cup (dry)'`.
    required String servingDescription,

    /// The nutrition of exactly one [servingDescription].
    required NutritionFacts perServing,

    /// UTC.
    required DateTime createdAt,

    /// UTC.
    required DateTime updatedAt,

    /// Brand or maker. `null` for generic foods.
    String? brand,

    /// Mass of one serving in grams, when known. `null` when the serving
    /// has no meaningful gram weight or the user simply didn't say.
    double? servingGrams,

    /// Volume of one serving in millilitres, when known. `null` when the
    /// serving has no fluid volume specified.
    double? servingVolumeMl,

    /// EAN/UPC barcode, when known. `null` for hand-entered foods.
    String? barcode,

    /// Source-scoped catalogue key; never a product barcode.
    String? providerFoodId,
    @Default(FoodSource.custom) FoodSource source,
  }) = _Food;

  const Food._();

  /// Name plus brand when there is one — `'Porridge oats'` or
  /// `'Porridge oats · Quaker'`. Lives here rather than in a widget so the
  /// two places that need it (the diary list and the food picker) can't
  /// drift apart.
  String get displayName => brand == null ? name : '$name · $brand';

  /// Energy density in kcal per 100 ml for liquid foods, or `null` when
  /// serving volume is unknown or zero.
  double? get energyDensityKcalPer100Ml {
    if (servingVolumeMl == null || servingVolumeMl! <= 0) return null;
    return (perServing.caloriesKcal / servingVolumeMl!) * 100;
  }

  /// Liquid density in grams per millilitre when both mass and volume are
  /// known, or `null` when either is missing or non-positive.
  double? get liquidDensityGramsPerMl {
    if (servingGrams == null || servingGrams! <= 0) return null;
    if (servingVolumeMl == null || servingVolumeMl! <= 0) return null;
    return servingGrams! / servingVolumeMl!;
  }
}
