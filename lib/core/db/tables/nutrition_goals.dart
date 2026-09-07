import 'package:drift/drift.dart';

/// The user's nutrition targets and nutrition-display preferences — see
/// `features/nutrition/domain/nutrition_goals.dart`.
///
/// **Single-row semantics**, the same shape of convention as
/// `user_profiles.dart`: modelled as a table rather than a pile of
/// SharedPreferences keys so multi-profile and sync arrive without a schema
/// change, but only one row is ever expected.
/// `DriftNutritionGoalsRepository` resolves the earliest-created live row
/// and upserts by primary key.
///
/// Every target is nullable: "no target set" is the honest starting state
/// and a perfectly valid steady state. Nothing in this feature requires the
/// user to name a number.
///
/// ## The ED-safety fields
///
/// Two columns exist purely because of the eating-disorder-safe stance in
/// `knowledge/domain/nutrition.md`:
///
/// - [hideCalorieNumbers] lets the user keep the food diary — protein,
///   iron, meals, everything — while never being shown a calorie figure.
///   It is a display preference, not a data switch: calories are still
///   recorded, so turning it back off loses nothing.
/// - [dailyDeficitKcal] is stored alongside [weightGoal] as the user's
///   *request*, never as the resolved answer. The resolved daily calorie
///   target is computed by
///   `features/nutrition/domain/calorie_target.dart`, which refuses to
///   return anything below the user's estimated BMR and reports when it
///   applied that floor. Storing the request rather than the outcome is
///   what lets the app re-explain the floor every time the estimate
///   changes.
///
/// ## No iron target column, deliberately
///
/// Iron is the other first-class adequacy indicator, but unlike calories
/// and macros there is **no user-set iron target here**: a personal iron
/// number is a clinical figure this app is not qualified to ask a user to
/// set, nor to recommend (`knowledge/domain/mens_health.md` rule 1). Iron
/// is surfaced as a logged total only. This paragraph marks the absence
/// deliberately, so a later session doesn't "complete the set".
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`: nutrition
/// and body-metric adjacent): never logged, never in analytics, never
/// interpolated into an exception message, wiped by "Delete my data".
///
/// Sync columns follow the ADR 004 convention.
class NutritionGoals extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  /// Daily energy target in kilocalories. `null` means no target set.
  IntColumn get calorieTargetKcal => integer().nullable()();

  /// Daily protein target in grams. `null` means no target set. Protein is
  /// one of the two first-class adequacy indicators for this audience
  /// (`knowledge/domain/nutrition.md`).
  RealColumn get proteinTargetGrams => real().nullable()();

  /// Daily carbohydrate target in grams. `null` means no target set.
  RealColumn get carbTargetGrams => real().nullable()();

  /// Daily fat target in grams. `null` means no target set.
  RealColumn get fatTargetGrams => real().nullable()();

  /// Which macro representation is authoritative — one of
  /// `MacroTargetMode`'s storage keys (see
  /// `features/nutrition/domain/macro_targets.dart`). Defaults to
  /// `'grams'`, which is what every row written before this column existed
  /// already means, so the v12 migration changes no existing behaviour.
  ///
  /// The grams and percent columns are stored **side by side and
  /// independently**; neither is written from the other. That is what lets
  /// a user switch representation and back without losing the numbers she
  /// typed, and it keeps derived grams out of the database — they are
  /// recomputed from the current energy target instead of going stale
  /// (`knowledge/architecture/data_architecture.md`'s derived-vs-stored
  /// rule).
  TextColumn get macroTargetMode =>
      text().withDefault(const Constant('grams'))();

  /// Daily protein target as a percentage of the day's energy target,
  /// 0-100. `null` means no target set. Authoritative only while
  /// [macroTargetMode] is `'percent'`.
  RealColumn get proteinTargetPercent => real().nullable()();

  /// Daily carbohydrate target as a percentage of the day's energy target,
  /// 0-100. `null` means no target set.
  RealColumn get carbTargetPercent => real().nullable()();

  /// Daily fat target as a percentage of the day's energy target, 0-100.
  /// `null` means no target set.
  RealColumn get fatTargetPercent => real().nullable()();

  /// Which gram targets the user has pinned, as a comma-separated set of
  /// `MacroNutrient` storage keys — `''` (the default, and what every pre-v14
  /// row means) for none, `'protein,fat'` for two. See
  /// `features/nutrition/domain/macro_locks.dart`.
  ///
  /// **One column rather than three booleans**, because this *is* a set: it
  /// round-trips as one, it is read as one ("how many are locked?"), and a
  /// fourth macro would need no migration to join it. Same comma-separated
  /// convention as `user_profiles.training_days`.
  ///
  /// Stored rather than left in the widget, because a lock is a durable
  /// intent: "keep protein at 200 g" has to survive a reopen, or the
  /// promise that the free macro tracks a changed calorie target quietly
  /// breaks. Only meaningful while [macroTargetMode] is `'grams'` — a
  /// percentage split is already fully determined by its own add-to-100
  /// rule — and, like the two macro sets, it is kept rather than cleared
  /// when the user switches away and back.
  TextColumn get macroLocks => text().withDefault(const Constant(''))();

  /// When the user asks the app to hide calorie figures. Purely a display
  /// preference — see the class doc.
  BoolColumn get hideCalorieNumbers =>
      boolean().withDefault(const Constant(false))();

  /// Persisted as one of `ActivityLevel`'s storage keys (see
  /// `features/nutrition/domain/energy_estimate.dart`) — the multiplier the
  /// TDEE estimate applies to the estimated BMR. `null` means the user
  /// hasn't told us, and no TDEE is estimated.
  TextColumn get activityLevel => text().nullable()();

  /// Persisted as one of `WeightGoal`'s storage keys (see
  /// `features/nutrition/domain/nutrition_goals.dart`). Defaults to
  /// `'maintain'` — the app never assumes a user wants to lose weight.
  TextColumn get weightGoal => text().withDefault(const Constant('maintain'))();

  /// The size of the daily energy gap the user asked for, in kilocalories,
  /// as a **magnitude** — [weightGoal] carries the direction. `0` (the
  /// default) means no gap. This is the user's request, not the resolved
  /// target; see the class doc.
  IntColumn get dailyDeficitKcal => integer().withDefault(const Constant(0))();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  /// UTC milliseconds since epoch; null while the row is live. Kept for
  /// column-shape consistency; "Delete my data" hard-deletes the row.
  IntColumn get deletedAt => integer().nullable()();

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see ADR
  /// 004). Defaults to `'local'`.
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
