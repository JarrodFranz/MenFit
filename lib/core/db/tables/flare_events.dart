import 'package:drift/drift.dart';

/// A user-logged flare-up — see `features/wellbeing/domain/flare_event.dart`.
///
/// [day] is stored the same way as `daily_checkins.dart`'s `DailyCheckins`
/// `day` column (ISO-8601 `YYYY-MM-DD`, user-local calendar day), but the
/// index here is **non-unique**: multiple flares can be logged on the same
/// day (see `features/wellbeing/domain/wellbeing_repository.dart#saveFlare`).
///
/// [symptoms] uses the same comma-separated `SymptomType.toStorage()`
/// encoding as `daily_checkins.dart`. [category] is nullable — never
/// required, no diagnosis demanded (`knowledge/product/stage1_audit.md`
/// §5.2).
///
/// S3-tier data, same handling as `daily_checkins.dart`.
@TableIndex(name: 'idx_flare_events_day', columns: {#day})
class FlareEvents extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day. The
  /// **first** day of the flare when [endDay] is set.
  TextColumn get day => text()();

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day; the
  /// **inclusive** last day of a multi-day flare (schema v9).
  ///
  /// `null` means a single-day flare covering only [day] — the shape every
  /// pre-v9 row backfills to, and still the common case. Range queries
  /// therefore read the effective last day as `COALESCE(end_day, day)`
  /// rather than requiring the column to be populated (see
  /// `features/wellbeing/data/drift_wellbeing_repository.dart`).
  TextColumn get endDay => text().nullable()();

  /// Persisted as `'mild'`, `'moderate'`, or `'severe'` (see
  /// `features/wellbeing/domain/flare_event.dart`'s `FlareSeverity`).
  TextColumn get severity => text()();

  /// Comma-separated `SymptomType.toStorage()` keys. Empty string when no
  /// symptoms were logged.
  TextColumn get symptoms => text().withDefault(const Constant(''))();

  /// Persisted as `'none'`, `'reducedTraining'`, or `'unableToTrain'` (see
  /// `FlareImpact`).
  TextColumn get impact => text()();

  /// Persisted as one of `FlareCategory`'s storage keys, or `null` when
  /// left unset ("Prefer not to say") — never required.
  TextColumn get category => text().nullable()();

  TextColumn get notes => text().nullable()();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  /// UTC milliseconds since epoch; null while the row is live. Kept for
  /// column-shape consistency with other tables, but
  /// `DriftWellbeingRepository.deleteFlare` hard-deletes instead (S3, same
  /// reasoning as `cycle_records.dart#deletedAt`) — should always read
  /// `null`.
  IntColumn get deletedAt => integer().nullable()();

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see ADR
  /// 004). Defaults to `'local'`.
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
