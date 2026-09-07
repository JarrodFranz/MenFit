import 'package:drift/drift.dart';

/// The local user's profile. Single-user app today, but modelled as a
/// table (not a singleton row in prefs) so multi-profile/handoff scenarios
/// don't require a schema change later.
///
/// Sync columns ([updatedAt], [deletedAt], [syncStatus]) follow the
/// ADR 004 convention applied to every syncable table: soft deletes,
/// last-write-wins by `updated_at`, and a status the outbox pipeline can
/// filter on.
class UserProfiles extends Table {
  /// Client-generated UUIDv7 (see `core/domain/entity_id.dart`).
  TextColumn get id => text()();

  TextColumn get displayName => text()();

  /// Persisted as `'metric'` or `'imperial'` (see `core/domain/units.dart`).
  TextColumn get unitSystem => text()();

  /// Target sessions per week. Nullable: no goal set yet.
  IntColumn get weeklyActivityGoal => integer().nullable()();

  /// ISO-8601 date string (`YYYY-MM-DD`) — see `core/domain/local_date.dart`.
  /// Nullable: never forced (spec §5.1). S2-tier
  /// (`knowledge/engineering/security_and_privacy.md`) — never logged.
  TextColumn get dateOfBirth => text().nullable()();

  /// Canonical metric (centimetres). Nullable: never forced. S2-tier — never
  /// logged. Presentation converts to ft+in for imperial users (see
  /// `core/domain/units.dart#cmToFeetInches`).
  RealColumn get heightCm => real().nullable()();

  /// Canonical metric (kilograms). Nullable: never forced. S2-tier — never
  /// logged. Presentation converts to lb for imperial users.
  RealColumn get weightKg => real().nullable()();

  /// Persisted as one of `FitnessGoal`'s storage keys (see
  /// `features/profile/domain/user_profile.dart`). Nullable: never forced.
  TextColumn get fitnessGoal => text().nullable()();

  /// Persisted as one of `ExperienceLevel`'s storage keys. Nullable: never
  /// forced.
  TextColumn get runningExperience => text().nullable()();

  /// Persisted as one of `ExperienceLevel`'s storage keys. Nullable: never
  /// forced.
  TextColumn get strengthExperience => text().nullable()();

  /// Comma-separated `Weekday.toStorage()` keys (see
  /// `core/domain/weekday.dart`). Empty string when none chosen — same CSV
  /// convention as `daily_checkins.symptoms`/`flare_events.symptoms`, and
  /// `NOT NULL DEFAULT ''` (rather than nullable) for the same reason: "no
  /// training days chosen" and "not yet asked" both read the same way here,
  /// which is fine since this field is purely a preference with no
  /// tri-state meaning to preserve.
  TextColumn get trainingDays => text().withDefault(const Constant(''))();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  /// UTC milliseconds since epoch; null while the row is live. Soft-delete
  /// marker per ADR 004 — rows are never hard-deleted locally so deletions
  /// can propagate through sync.
  IntColumn get deletedAt => integer().nullable()();

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see
  /// ADR 004). Defaults to `'local'` for rows created before any backend
  /// exists.
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
