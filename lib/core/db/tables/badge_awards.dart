import 'package:drift/drift.dart';

/// One badge the user has earned — see
/// `features/achievements/domain/badge_award.dart` for the domain entity
/// and `features/achievements/domain/badge_catalogue.dart` for what the
/// [badgeId] values mean.
///
/// **One row per tier crossed, not one row per badge.** Reaching Gold on a
/// tiered badge leaves three rows (bronze, silver, gold), each with its own
/// [awardedAt]. That is what lets the trophy case say *when* a tier was
/// reached rather than only that it was, and it is why [tierKey] is part of
/// the unique key rather than a mutable "current tier" column.
///
/// **[tierKey] is NOT NULL, including for one-off badges**, which store the
/// `'once'` sentinel (`features/achievements/domain/badge_award.dart`'s
/// `oneOffAwardTierKey`). A nullable column would defeat the whole point of
/// the unique key: SQLite treats two NULLs as distinct inside a UNIQUE
/// constraint, so `(badge, NULL)` could be inserted any number of times and
/// "award the same one-off twice" would silently stop being a no-op.
///
/// **No `@TableIndex` on purpose.** The `UNIQUE(badge_id, tier_key)`
/// constraint below is emitted *inside* the `CREATE TABLE` statement, which
/// `Migrator.createTable` guards with `IF NOT EXISTS`; a standalone
/// `createIndex` would not be guarded, and every migration-test fixture in
/// `test/core/db/app_database_test.dart` would then need a
/// `DROP TABLE IF EXISTS badge_awards` before replaying `onUpgrade`
/// (`knowledge/troubleshooting/database_migrations.md`). The constraint
/// also serves as the lookup index for the only query shape this table has
/// (by `badge_id`), so a second index would buy nothing. Keep it that way:
/// adding an index here later means auditing all 29 `onUpgrade` call sites.
///
/// **No `deleted_at`/`sync_status`**, for the same reason `water_logs`,
/// `weight_logs` and the rest of the post-ADR-004 tables omit them: there
/// is no backend yet, and an award is either earned or it is not — there is
/// nothing a soft-deleted award would mean.
///
/// S1-tier data: badge ids and tiers are derived from the user's own logs
/// but contain no health, cycle, or location value themselves. They are
/// still wiped by "Delete my data" with everything else.
@DataClassName('BadgeAwardRow')
class BadgeAwards extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  /// The catalogue id of the badge (see
  /// `features/achievements/domain/badge_catalogue.dart`). Stable forever —
  /// a shipped id is never renamed, or every user loses the award.
  TextColumn get badgeId => text()();

  /// The storage key of the awarded tier (`'bronze'` … `'diamond-3'`), or
  /// `'once'` for a one-off badge. Never null — see the class doc.
  TextColumn get tierKey => text()();

  /// UTC milliseconds since epoch.
  IntColumn get awardedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  /// Awarding the same badge+tier twice is a no-op, enforced by the
  /// database rather than only by the repository — see
  /// `features/achievements/domain/award_repository.dart#recordAward`.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {badgeId, tierKey},
  ];
}
