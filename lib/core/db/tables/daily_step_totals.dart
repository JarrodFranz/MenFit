import 'package:drift/drift.dart';

/// One calendar day's step total, as read from the platform health source —
/// see `features/steps/domain/daily_steps.dart` for the domain entity.
///
/// **Why this table exists at all.** Steps live in Health Connect / Apple
/// HealthKit, and every read of them is a platform-channel call. Without a
/// local copy, drawing a 35-day step chart would mean 35 channel round-trips
/// on every rebuild, and web/Windows — where no health platform exists —
/// could never show history at all, not even history the phone already
/// collected. Keeping per-day totals locally turns the chart into one SQL
/// query, makes the empty state honest ("nothing synced yet" rather than a
/// spinner that never resolves), and is the only way a Windows build can
/// show the same numbers the phone synced. See ADR 013.
///
/// [day] is an ISO-8601 date string (`YYYY-MM-DD`) in the user's local
/// timezone — calendar days, not UTC instants (see
/// `knowledge/architecture/data_architecture.md`'s "Calendar-day semantics"
/// section). Same convention as `weight_logs`, `water_logs`,
/// `nutrition_entries` and `daily_checkins`, and it is what makes the
/// lexical range comparison in `DriftStepsRepository` chronological.
///
/// **[day] is the primary key — exactly one row per day.** That is the
/// difference from `weight_logs`, whose day column is deliberately *not*
/// unique: two weigh-ins in one day are two facts, whereas two step reads
/// for one day are two readings of the *same* accruing fact, and the later
/// one supersedes the earlier one entirely. Making it the key rather than
/// carrying a UUID `id` alongside a UNIQUE constraint is what lets the
/// repository's `insertOnConflictUpdate` resolve "the row for this day"
/// without a conflict target, and it means a re-sync of a day that is still
/// accruing (today, always) overwrites instead of accumulating duplicates.
///
/// Like `badge_awards`' `UNIQUE(badge_id, tier_key)`, this uniqueness is
/// emitted **inside** the `CREATE TABLE` statement, which
/// `Migrator.createTable` guards with `IF NOT EXISTS` — so the v22 migration
/// step is re-entrant on its own and needed no change to any existing
/// `onUpgrade` fixture. A standalone `@TableIndex` would not have been
/// guarded; see `knowledge/troubleshooting/database_migrations.md`.
///
/// **No `id`, no `deleted_at`, no `sync_status`.** There is no backend yet
/// (ADR 004), and a soft-deleted step total would mean nothing: this data is
/// a cache of a fact the health platform owns, so it is either present or it
/// is not. "Delete my data" hard-deletes every row
/// (`features/steps/domain/steps_repository.dart#deleteAllData`), and a
/// re-sync would legitimately fetch it again from the platform if the user
/// still has sync switched on.
///
/// S2-tier data (`knowledge/engineering/security_and_privacy.md`:
/// health-platform data): step counts never enter logs, analytics, or a
/// thrown exception's message, they are wiped by "Delete my data", and they
/// are only ever written while the user's fitness-device sync toggle is on.
class DailyStepTotals extends Table {
  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day. The
  /// primary key — see the class doc for why one row per day.
  TextColumn get day => text()();

  /// Steps accrued on [day], as reported by the health platform. Zero is a
  /// real, honest value (a day she did not carry her phone), which is why a
  /// day with no data has **no row** rather than a zero row.
  IntColumn get steps => integer()();

  /// The health platform's own label for where the count came from
  /// (`'Health Connect'`, `'Apple Health'`, …), or null when the source
  /// could not be named. Never a device identifier — a human-readable
  /// platform label only.
  TextColumn get source => text().nullable()();

  /// UTC milliseconds since epoch — when this row was last read from the
  /// platform. Not when the steps were taken; today's row is re-read
  /// repeatedly while the day is still accruing.
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {day};
}
