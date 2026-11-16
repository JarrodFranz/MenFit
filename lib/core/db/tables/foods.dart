import 'package:drift/drift.dart';

/// A food definition: the nutrition of **one serving** of something the
/// user can log — see `features/nutrition/domain/food.dart`.
///
/// Per-serving, not per-100g: a user-entered food is described the way the
/// label describes it ("1 bar", "2 slices", "1 cup"), and every logged
/// entry multiplies these numbers by a serving count. [servingGrams] is
/// the optional bridge back to mass for foods whose serving weight is
/// actually known — it is *not* the basis of the nutrition columns.
///
/// [source] is a discriminator, not a provenance log: today every row is
/// `'custom'` (user-entered). S1-5 adds provider-sourced foods (Open Food
/// Facts et al. — `knowledge/domain/nutrition.md`) alongside them, and
/// [barcode] exists now so a scanned product can be matched against
/// already-cached rows rather than re-fetched. Nothing writes a non-custom
/// row yet.
///
/// **Every optional nutrient is nullable on purpose.** Most labels don't
/// state iron, and storing `0` for "not stated" would turn a gap in the
/// data into a claim
/// that the food contains no iron — which matters, because iron is one of
/// the two adequacy indicators this feature treats as first-class
/// (`knowledge/domain/nutrition.md`). `null` means "unknown", and totals
/// report that honestly (see
/// `features/nutrition/domain/nutrition_totals.dart`). The same reasoning
/// governs the twelve nutrients beside it (saturated/trans/mono/poly fat,
/// fibre, sugars, added sugars, sodium, potassium, cholesterol, calcium,
/// vitamin D, vitamin C), added in schema v21 so the food form's optional
/// fields stop being discarded at the repository boundary.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`: nutrition
/// logs): never logged, never in analytics, never interpolated into an
/// exception message, and wiped by "Delete my data".
///
/// Sync columns ([updatedAt], [deletedAt], [syncStatus]) follow the same
/// ADR 004 convention as every other syncable table. Unlike
/// `nutrition_entries`, this table's day-to-day delete is a genuine **soft**
/// delete: a food is a reusable catalogue definition, and hiding it must
/// not disturb the history that referenced it.
@TableIndex(name: 'idx_foods_name', columns: {#name})
@TableIndex(name: 'idx_foods_barcode', columns: {#barcode})
@TableIndex(
  name: 'idx_foods_provider_food_id',
  columns: {#source, #providerFoodId},
)
class Foods extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  /// Catalogue identity, distinct from a retail barcode.
  TextColumn get providerFoodId => text().nullable()();

  /// What the user calls this food, e.g. `'Porridge oats'`.
  TextColumn get name => text()();

  /// Brand or maker, when the user gave one. `null` for generic foods.
  TextColumn get brand => text().nullable()();

  /// Plain-English description of one serving, e.g. `'1 cup (dry)'`. Always
  /// present — every number below is "per one of these".
  TextColumn get servingDescription => text()();

  /// Mass of one serving in grams, when known. `null` for servings with no
  /// meaningful gram weight (a drink measured in ml, an item the user
  /// didn't weigh) — see the class doc.
  RealColumn get servingGrams => real().nullable()();

  /// Volume of one serving in millilitres, when known. `null` for solid foods
  /// or servings where fluid volume is not specified.
  RealColumn get servingVolumeMl => real().nullable()();

  /// Energy per serving, in kilocalories.
  RealColumn get caloriesKcal => real()();

  /// Protein per serving, in grams.
  RealColumn get proteinGrams => real()();

  /// Carbohydrate per serving, in grams.
  RealColumn get carbsGrams => real()();

  /// Fat per serving, in grams.
  RealColumn get fatGrams => real()();

  /// Iron per serving, in milligrams. `null` means **unknown**, never zero
  /// — see the class doc.
  RealColumn get ironMg => real().nullable()();

  /// Saturated fat per serving, in grams. `null` means **unknown** — the
  /// same rule [ironMg] follows, and the reason every column below is
  /// nullable (see the class doc).
  RealColumn get saturatedFatGrams => real().nullable()();

  /// Trans fat per serving, in grams. `null` means unknown.
  RealColumn get transFatGrams => real().nullable()();

  /// Monounsaturated fat per serving, in grams. `null` means unknown.
  RealColumn get monounsaturatedFatGrams => real().nullable()();

  /// Polyunsaturated fat per serving, in grams. `null` means unknown.
  RealColumn get polyunsaturatedFatGrams => real().nullable()();

  /// Dietary fibre per serving, in grams. `null` means unknown.
  RealColumn get fiberGrams => real().nullable()();

  /// Total sugars per serving, in grams. `null` means unknown.
  RealColumn get sugarsGrams => real().nullable()();

  /// Added sugars per serving, in grams. `null` means unknown.
  RealColumn get addedSugarsGrams => real().nullable()();

  /// Sodium per serving, in milligrams. `null` means unknown.
  RealColumn get sodiumMg => real().nullable()();

  /// Potassium per serving, in milligrams. `null` means unknown.
  RealColumn get potassiumMg => real().nullable()();

  /// Cholesterol per serving, in milligrams. `null` means unknown.
  RealColumn get cholesterolMg => real().nullable()();

  /// Calcium per serving, in milligrams. `null` means unknown.
  RealColumn get calciumMg => real().nullable()();

  /// Vitamin D per serving, in micrograms. `null` means unknown.
  RealColumn get vitaminDMcg => real().nullable()();

  /// Vitamin C per serving, in milligrams. `null` means unknown.
  RealColumn get vitaminCMg => real().nullable()();

  /// EAN/UPC barcode, when this food came from (or was matched to) a
  /// scanned product. `null` for hand-entered foods. Deliberately
  /// **non-unique**: the same product can legitimately exist twice once
  /// provider-sourced rows join user-entered ones (S1-5).
  TextColumn get barcode => text().nullable()();

  /// Persisted as one of `FoodSource`'s storage keys (see
  /// `features/nutrition/domain/food.dart`). Defaults to `'custom'` — the
  /// only value anything writes today.
  TextColumn get source => text().withDefault(const Constant('custom'))();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  /// UTC milliseconds since epoch; null while the row is live. A genuine
  /// soft-delete marker per ADR 004 (see the class doc for why this table,
  /// unlike `nutrition_entries`, soft-deletes).
  IntColumn get deletedAt => integer().nullable()();

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see ADR
  /// 004). Defaults to `'local'`.
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
