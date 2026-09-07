import 'package:drift/drift.dart';

/// One logged item in the food diary: a quantity of a food, on a meal, on a
/// calendar day — see `features/nutrition/domain/nutrition_entry.dart`.
///
/// [day] is stored as an ISO-8601 date string (`YYYY-MM-DD`), captured in
/// the user's local timezone at logging time — calendar days, not UTC
/// instants, exactly the same convention as `daily_checkins.dart` (see
/// `knowledge/architecture/data_architecture.md`'s "Calendar-day semantics"
/// section). The index on [day] is **non-unique**: a day holds as many
/// entries as the user logs.
///
/// ## The nutrition snapshot is load-bearing
///
/// [caloriesKcal]/[proteinGrams]/[carbsGrams]/[fatGrams]/[ironMg] and the
/// twelve optional nutrients added beside them in schema v21 are a **copy
/// of the referenced food's per-serving numbers as they stood at log
/// time**, not a cache of the current ones. The two tables carry the same
/// eighteen nutrition columns and have to stay that way: a nutrient the
/// food persists but the entry does not is data lost one step later.
///
/// The snapshot is deliberate and it is the reason [foodId] is a plain
/// nullable reference with no foreign key:
///
/// - Editing a food (fixing a typo'd calorie count, correcting a serving
///   size) must change what you log *from now on*, never silently rewrite
///   what you already ate. A diary that retroactively edits itself is a
///   diary the user cannot trust.
/// - S1-5 will re-fetch provider-sourced foods when their upstream record
///   changes. Without the snapshot, a remote correction to a product would
///   rewrite months of the user's history with numbers they never saw.
/// - Deleting a food must not orphan or blank the entries that used it —
///   with the snapshot (and [foodName]), every past entry stays complete and
///   displayable on its own.
///
/// The consequence to keep in mind: reading nutrition for a day is a
/// single-table query with no join, and the food row is only needed for
/// "log this again" affordances.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`: nutrition
/// logs): never logged, never in analytics, never interpolated into an
/// exception message, and wiped by "Delete my data". Unlike `foods`, an
/// entry is **hard-deleted** rather than soft-deleted (same reasoning as
/// `recovery_days.dart`): removing something from your food diary has to
/// actually remove it.
@TableIndex(name: 'idx_nutrition_entries_day', columns: {#day})
class NutritionEntries extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day.
  /// Non-unique — many entries per day.
  TextColumn get day => text()();

  /// Persisted as one of `MealType`'s storage keys (see
  /// `features/nutrition/domain/meal_type.dart`).
  TextColumn get meal => text()();

  /// The `foods.id` this entry was logged from, if that food still needs to
  /// be reachable for "log again". Plain nullable TEXT with **no FK
  /// constraint** — same choice, for the same reason, as
  /// `activities.route_id`: the food may be soft- or hard-deleted
  /// independently and this entry must survive that intact (see the class
  /// doc's snapshot section).
  TextColumn get foodId => text().nullable()();

  /// The food's name as it stood at log time. Snapshotted for the same
  /// reason as the nutrition numbers: an entry must stay displayable
  /// without a join, and without depending on a row that may be gone.
  TextColumn get foodName => text()();

  /// The food's brand as it stood at log time, when it had one.
  TextColumn get foodBrand => text().nullable()();

  /// The food's serving description as it stood at log time, e.g.
  /// `'1 cup (dry)'`. `null` for entries whose source food had none.
  TextColumn get servingDescription => text().nullable()();

  /// How many servings were eaten — the **canonical multiplier**, and the
  /// only quantity column the nutrition arithmetic reads. Always greater
  /// than zero (enforced by
  /// `features/nutrition/domain/nutrition_validation.dart`); fractional
  /// values are normal.
  ///
  /// [quantityAmount]/[quantityUnit] below record how that number was
  /// *expressed*; they never change what it means.
  RealColumn get quantityServings => real()();

  /// The number the user actually typed, in [quantityUnit] — `47` for
  /// "47 g", `1.5` for "1.5 servings".
  ///
  /// Stored alongside [quantityServings] rather than instead of it: the
  /// diary has to be able to show her back what she entered, while every
  /// total keeps multiplying by servings. The two are derived from each
  /// other through `features/nutrition/domain/quantity_unit.dart` and
  /// `NutritionEntry.fromFood` is the only place that derivation happens.
  ///
  /// The default exists for `ALTER TABLE`'s sake — SQLite cannot add a
  /// NOT NULL column without one — and for a fresh insert that omits it.
  /// It is emphatically *not* what pre-v13 rows mean: the v13 migration
  /// step backfills every existing row from `quantity_servings` explicitly
  /// (see `core/db/app_database.dart`), because those rows were all logged
  /// in servings and `1` would silently claim otherwise.
  RealColumn get quantityAmount => real().withDefault(const Constant(1))();

  /// One of `QuantityUnit`'s storage keys (see
  /// `features/nutrition/domain/quantity_unit.dart`), defaulting to
  /// `'serving'`.
  ///
  /// The default is the honest reading of every row written before this
  /// column existed — servings were the only thing that could be logged —
  /// and `QuantityUnit.fromStorage` reads an unrecognised key the same way.
  TextColumn get quantityUnit =>
      text().withDefault(const Constant('serving'))();

  /// Snapshot: the food's grams per serving at log time. `null` when the
  /// food had no recorded serving weight.
  ///
  /// Snapshotted for exactly the reason the nutrition numbers are (see the
  /// class doc): "47 g" only means a serving count *against a particular
  /// serving weight*. Correcting a food's serving weight next month must
  /// not retroactively re-interpret what 47 g meant in an entry logged
  /// today — and re-displaying or editing that entry has to use the weight
  /// it was logged against, not today's.
  ///
  /// `null` is also what `quantity_unit.dart` reads as "weight units are
  /// unavailable for this entry", which is the correct state for every
  /// pre-v13 row: nothing was recorded, so nothing may be assumed.
  RealColumn get servingGrams => real().nullable()();

  /// Snapshot: the food's volume in millilitres per serving at log time.
  /// `null` when the food had no recorded serving volume.
  RealColumn get servingVolumeMl => real().nullable()();

  /// Snapshot: energy per serving at log time, in kilocalories.
  RealColumn get caloriesKcal => real()();

  /// Snapshot: protein per serving at log time, in grams.
  RealColumn get proteinGrams => real()();

  /// Snapshot: carbohydrate per serving at log time, in grams.
  RealColumn get carbsGrams => real()();

  /// Snapshot: fat per serving at log time, in grams.
  RealColumn get fatGrams => real()();

  /// Snapshot: iron per serving at log time, in milligrams. `null` means
  /// the food didn't state iron — never zero (see `foods.dart`'s class
  /// doc).
  RealColumn get ironMg => real().nullable()();

  /// Snapshot: saturated fat per serving at log time, in grams.
  /// `null` means **unknown** — the same rule [ironMg] follows, and the
  /// reason every column below is nullable (see `foods.dart`'s class
  /// doc).
  RealColumn get saturatedFatGrams => real().nullable()();

  /// Snapshot: trans fat per serving at log time, in grams. `null` means
  /// unknown.
  RealColumn get transFatGrams => real().nullable()();

  /// Snapshot: monounsaturated fat per serving at log time, in grams.
  /// `null` means unknown.
  RealColumn get monounsaturatedFatGrams => real().nullable()();

  /// Snapshot: polyunsaturated fat per serving at log time, in grams.
  /// `null` means unknown.
  RealColumn get polyunsaturatedFatGrams => real().nullable()();

  /// Snapshot: dietary fibre per serving at log time, in grams. `null` means
  /// unknown.
  RealColumn get fiberGrams => real().nullable()();

  /// Snapshot: total sugars per serving at log time, in grams. `null` means
  /// unknown.
  RealColumn get sugarsGrams => real().nullable()();

  /// Snapshot: added sugars per serving at log time, in grams. `null` means
  /// unknown.
  RealColumn get addedSugarsGrams => real().nullable()();

  /// Snapshot: sodium per serving at log time, in milligrams. `null` means
  /// unknown.
  RealColumn get sodiumMg => real().nullable()();

  /// Snapshot: potassium per serving at log time, in milligrams. `null` means
  /// unknown.
  RealColumn get potassiumMg => real().nullable()();

  /// Snapshot: cholesterol per serving at log time, in milligrams. `null` means
  /// unknown.
  RealColumn get cholesterolMg => real().nullable()();

  /// Snapshot: calcium per serving at log time, in milligrams. `null` means
  /// unknown.
  RealColumn get calciumMg => real().nullable()();

  /// Snapshot: vitamin D per serving at log time, in micrograms. `null` means
  /// unknown.
  RealColumn get vitaminDMcg => real().nullable()();

  /// Snapshot: vitamin C per serving at log time, in milligrams. `null` means
  /// unknown.
  RealColumn get vitaminCMg => real().nullable()();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  /// UTC milliseconds since epoch; null while the row is live. Kept for
  /// column-shape consistency with other tables, but
  /// `DriftNutritionRepository.deleteEntry` hard-deletes instead (see the
  /// class doc) — should always read `null`.
  IntColumn get deletedAt => integer().nullable()();

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see ADR
  /// 004). Defaults to `'local'`.
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
