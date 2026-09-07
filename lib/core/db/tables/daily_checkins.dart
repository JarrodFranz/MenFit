import 'package:drift/drift.dart';

/// A user-logged daily wellbeing check-in — see
/// `features/wellbeing/domain/daily_checkin.dart`.
///
/// [day] is stored as an ISO-8601 date string (`YYYY-MM-DD`), captured in
/// the user's local timezone at logging time — calendar days, not UTC
/// instants (see `knowledge/architecture/data_architecture.md`'s
/// "Calendar-day semantics" section). The unique index on [day] backs the
/// "at most one check-in per calendar day" upsert-by-day rule in
/// `features/wellbeing/domain/wellbeing_repository.dart#saveCheckin`.
///
/// [symptoms] is a comma-separated list of `SymptomType.toStorage()` keys —
/// a small closed vocabulary (see `domain/symptom_type.dart`), so a
/// relational join table isn't warranted yet; there are no per-symptom
/// queries today. Revisit if that changes.
///
/// S3-tier data (`knowledge/engineering/security_and_privacy.md`): never
/// logged, hard-deleted (not soft), wiped first in the "Delete my data"
/// flow.
@TableIndex(name: 'idx_daily_checkins_day', columns: {#day}, unique: true)
class DailyCheckins extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day. Unique —
  /// at most one check-in per day.
  TextColumn get day => text()();

  /// 1-5, higher is better. `null` when not answered.
  IntColumn get energy => integer().nullable()();

  /// 1-5, higher is better. `null` when not answered.
  IntColumn get sleep => integer().nullable()();

  /// 1-5, higher is worse (more soreness). `null` when not answered.
  IntColumn get soreness => integer().nullable()();

  /// 1-5, higher is worse (more stress). `null` when not answered.
  IntColumn get stress => integer().nullable()();

  /// 1-5, higher is worse (more pain). `null` when not answered.
  IntColumn get pain => integer().nullable()();

  /// Comma-separated `SymptomType.toStorage()` keys. Empty string when no
  /// symptoms were logged.
  TextColumn get symptoms => text().withDefault(const Constant(''))();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  /// UTC milliseconds since epoch; null while the row is live. Kept for
  /// column-shape consistency with other tables, but
  /// `DriftWellbeingRepository.deleteCheckin` hard-deletes instead (S3: a
  /// "deleted" health row that is still forensically recoverable on-device
  /// is not deleted) — should always read `null`.
  IntColumn get deletedAt => integer().nullable()();

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see ADR
  /// 004). Defaults to `'local'`.
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
