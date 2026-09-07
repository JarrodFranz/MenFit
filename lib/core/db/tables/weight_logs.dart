import 'package:drift/drift.dart';

/// A single recorded body-weight measurement — see
/// `features/weight/domain/weight_log.dart`.
///
/// This is the *history* behind `user_profiles.weight_kg`, which stays put
/// as the profile's current single value (several features read it: energy
/// estimates, activity-energy MET maths, the progress card). The profile
/// column is not derived from this table and this table is not derived from
/// it; the migration seeds one row from the profile so the history starts
/// non-empty.
///
/// [day] is stored as an ISO-8601 date string (`YYYY-MM-DD`), captured in
/// the user's local timezone at logging time — calendar days, not UTC
/// instants (see `knowledge/architecture/data_architecture.md`'s
/// "Calendar-day semantics" section). Same convention as `water_logs`,
/// `nutrition_entries` and `daily_checkins`.
///
/// **Multiple rows per day are allowed.** The index on [day] is
/// deliberately *not* unique, unlike `daily_checkins`/`recovery_days`:
/// weighing in morning and evening is a real thing people do, and a
/// unique-by-day table would have to silently discard one of the two
/// readings. The trend layer resolves a single value per day when it needs
/// one (see `features/weight/domain/weight_repository.dart`, which
/// documents the ordering that makes "latest reading of the day" well
/// defined).
///
/// **No `deleted_at`/`sync_status`**, unlike most tables here (ADR 004's
/// column convention) and for the same reason `water_logs` omits them:
/// there is no backend yet, and body weight is S3 data that is
/// **hard-deleted** — a weigh-in the user deletes must actually be gone,
/// not linger as a hidden row. Add the sync columns when ADR 004's outbox
/// lands and they mean something.
///
/// S3-tier data (`knowledge/engineering/security_and_privacy.md`): weight
/// values and [notes] never enter logs, analytics, or exception messages.
@TableIndex(name: 'idx_weight_logs_day', columns: {#day})
class WeightLogs extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day. Not
  /// unique — see the class doc.
  TextColumn get day => text()();

  /// Canonical metric (kilograms). Presentation converts to lb for
  /// imperial users.
  RealColumn get weightKg => real()();

  /// Free-text note the user attached to this weigh-in. Nullable: nothing
  /// is ever required here. S3 — wiped by "Delete my data" with the rest
  /// of the row.
  TextColumn get notes => text().nullable()();

  /// One of `WeightLogSource`'s storage keys — `'manual'`,
  /// `'profile-migration'`, or `'health-sync'` (see
  /// `features/weight/domain/weight_log.dart`). Defaults to `'manual'`.
  TextColumn get source => text().withDefault(const Constant('manual'))();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
