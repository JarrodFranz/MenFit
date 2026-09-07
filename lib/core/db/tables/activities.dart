import 'package:drift/drift.dart';

/// A logged run/walk/hike/ride — either entered manually or captured via
/// GPS recording (wave C3 adds recording; [source] distinguishes the two —
/// see `features/activity/domain/activity.dart`'s `ActivityType`/
/// `ActivitySource`).
///
/// Sync columns ([updatedAt], [deletedAt], [syncStatus]) follow the same
/// ADR 004 convention as `user_profiles.dart`: last-write-wins by
/// `updated_at`, soft deletes via `deleted_at`, `sync_status` for the
/// outbox pipeline. Unlike profile, this table's delete is a genuine soft
/// delete (not the documented profile exception) — see
/// `features/activity/domain/activity_repository.dart`.
@TableIndex(name: 'idx_activities_started_at', columns: {#startedAt})
class Activities extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  /// Persisted as `'run'`, `'walk'`, `'hike'`, or `'ride'` (see
  /// `features/activity/domain/activity.dart`'s `ActivityType`).
  TextColumn get activityType => text()();

  TextColumn get title => text()();

  TextColumn get notes => text().nullable()();

  /// UTC milliseconds since epoch.
  IntColumn get startedAt => integer()();

  /// Time actually moving, in milliseconds. Equal to [elapsedTimeMs] for
  /// manually-logged activities, which don't distinguish paused time.
  IntColumn get movingTimeMs => integer()();

  /// Total elapsed time (including any stopped time), in milliseconds.
  IntColumn get elapsedTimeMs => integer()();

  RealColumn get distanceMeters => real()();

  RealColumn get elevationGainMeters => real().nullable()();

  IntColumn get avgHeartRate => integer().nullable()();

  /// Persisted as `'manual'` or `'recorded'` (see
  /// `features/activity/domain/activity.dart`'s `ActivitySource`).
  TextColumn get source => text()();

  /// The saved route (`routes.id`) this activity was started from, if any
  /// (v8; see `core/db/tables/routes.dart`). Plain nullable TEXT, no FK
  /// constraint — the route may be soft- or hard-deleted independently of
  /// the activity, and the activity must survive that.
  TextColumn get routeId => text().nullable()();

  /// Structured JSON metadata for type-specific workouts (v15; e.g. Strength
  /// sets/reps/rest, HIIT intervals, Yoga/Pilates mindfulness, Swim laps).
  TextColumn get metadataJson => text().nullable()();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  /// UTC milliseconds since epoch; null while the row is live. Soft-delete
  /// marker per ADR 004.
  IntColumn get deletedAt => integer().nullable()();

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see
  /// ADR 004). Defaults to `'local'` for rows created before any backend
  /// exists.
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
