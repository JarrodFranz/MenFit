import 'package:drift/drift.dart';

/// A user-logged period (menstrual cycle) record — the v1 cycle feature is
/// user-logged period tracking only, no phase estimation or prediction (see
/// `knowledge/domain/womens_health.md`).
///
/// [periodStartDay]/[periodEndDay] are stored as ISO-8601 date strings
/// (`YYYY-MM-DD`, see `core/domain/local_date.dart`), captured in the
/// user's local timezone at logging time — calendar days, not UTC instants
/// (see `knowledge/architecture/data_architecture.md`'s "Calendar-day
/// semantics" section). [periodEndDay] is `null` while the period is
/// ongoing.
///
/// S3-tier data (`knowledge/engineering/security_and_privacy.md`): never
/// logged, never denormalised into other tables — the streak engine joins
/// against this table at query time via
/// `features/cycle/domain/period_days.dart`'s pure functions rather than
/// copying period facts elsewhere.
///
/// Sync columns follow the same ADR 004 convention as
/// `activities.dart`/`user_profiles.dart`.
@TableIndex(
  name: 'idx_cycle_records_period_start_day',
  columns: {#periodStartDay},
)
class CycleRecords extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day.
  TextColumn get periodStartDay => text()();

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day. `null`
  /// while the period is ongoing.
  TextColumn get periodEndDay => text().nullable()();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  /// UTC milliseconds since epoch; null while the row is live. Soft-delete
  /// marker per ADR 004 - kept in the schema for column-shape consistency
  /// with `activities.dart`/`user_profiles.dart`, but
  /// `DriftCycleRepository.deleteRecord` deliberately hard-deletes instead
  /// of setting this column (see that method's dartdoc); nothing else in
  /// this table writes it, so it should always read `null`.
  IntColumn get deletedAt => integer().nullable()();

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see ADR
  /// 004). Defaults to `'local'` — cycle data sync additionally requires
  /// separate explicit consent (see security_and_privacy.md), not
  /// implemented yet.
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
