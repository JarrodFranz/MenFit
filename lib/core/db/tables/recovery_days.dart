import 'package:drift/drift.dart';

/// A user-logged protected recovery day — an explicit voluntary act of
/// declaring a day as recovery, independent of any flare or period
/// (`knowledge/product/terminology.md`'s "Protected Recovery": "maintains
/// the streak; requires no proof").
///
/// **Data-architecture note (S1-2):** `knowledge/architecture/
/// data_architecture.md`'s "Derived vs stored" section says streaks are
/// derived, never stored — and that's still true of the *streak result*
/// itself (`features/streaks/streaks_providers.dart#streakResultProvider`
/// remains a pure recompute with no cache table). This table is a
/// different thing: it's the user's own explicit record of "I chose this
/// day as recovery," exactly analogous to `cycle_records.dart`'s
/// `CycleRecords` (also a user-logged fact the streak engine joins against
/// at query time, not a derived cache) or `daily_checkins.dart`. It lives
/// under `features/streaks/` — the first `data/` layer that feature has —
/// because "mark a recovery day" is a streaks-feature action (surfaced from
/// the home streak card and the wellbeing check-in flow's recovery
/// prompt), not a wellbeing or cycle fact.
///
/// [day] is stored as an ISO-8601 date string (`YYYY-MM-DD`), captured in
/// the user's local timezone at logging time — calendar days, not UTC
/// instants (see `data_architecture.md`'s "Calendar-day semantics"
/// section). The unique index backs the upsert-by-day rule in
/// `domain/recovery_repository.dart#markRecoveryDay`: at most one recovery
/// record per calendar day.
///
/// Health-adjacent data (same S2/S3-flavoured handling as
/// `cycle_records.dart`/`daily_checkins.dart` — never logged, hard-deleted
/// rather than soft-deleted, wiped first in the "Delete my data" flow): see
/// `features/streaks/data/drift_recovery_repository.dart`.
@TableIndex(name: 'idx_recovery_days_day', columns: {#day}, unique: true)
class RecoveryDays extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day. Unique —
  /// at most one recovery record per day.
  TextColumn get day => text()();

  /// Optional free-text note the user attached when marking the day —
  /// never required (`knowledge/product/terminology.md`'s "Protected
  /// Recovery": "requires no proof").
  TextColumn get note => text().nullable()();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  /// UTC milliseconds since epoch; null while the row is live. Kept for
  /// column-shape consistency with other tables, but
  /// `DriftRecoveryRepository.unmarkRecoveryDay` hard-deletes instead (same
  /// reasoning as `cycle_records.dart#deletedAt`) — should always read
  /// `null`.
  IntColumn get deletedAt => integer().nullable()();

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see ADR
  /// 004). Defaults to `'local'`.
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
