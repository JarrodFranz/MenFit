import 'package:drift/drift.dart';

/// A saved route: a closed-loop (or point-to-point, later) course the user
/// can preview and start an activity along — produced by the route-suggest
/// flow (`features/routes/`) or, in the future, extracted from a recorded
/// activity.
///
/// Routes are S2-tier location data (start points are typically
/// home-adjacent — `knowledge/engineering/security_and_privacy.md`): never
/// logged, wiped by "Delete my data", and only ever persisted when the user
/// explicitly saves one.
///
/// Sync columns ([updatedAt], [deletedAt], [syncStatus]) follow the ADR 004
/// convention; day-to-day deletes are soft ([deletedAt]) because routes are
/// shareable-later artifacts.
class Routes extends Table {
  /// Client-generated UUIDv7.
  TextColumn get id => text()();

  TextColumn get name => text()();

  RealColumn get distanceMeters => real()();

  IntColumn get estimatedDurationSeconds => integer().nullable()();

  RealColumn get ascentMeters => real().nullable()();

  /// Total descent in metres; null when the source had no elevation data.
  RealColumn get descentMeters => real().nullable()();

  /// The route's geometry as a Google polyline-5 encoded string (see
  /// `core/utils/polyline_codec.dart`) — read back whole for drawing, never
  /// queried per point, so a compact TEXT blob beats a relational point
  /// table here (unlike `activity_samples`, which analytics query per
  /// point).
  TextColumn get geometry => text()();

  /// Persisted as `'run'`, `'walk'`, `'hike'`, or `'ride'` (see
  /// `features/activity/domain/activity.dart`'s `ActivityType`).
  TextColumn get activityType => text()();

  /// Where the route came from. `'suggested'` for routes produced by the
  /// route-suggestion service; future values (e.g. `'extracted'`) arrive
  /// with their features.
  TextColumn get source => text().withDefault(const Constant('suggested'))();

  /// UTC milliseconds since epoch.
  IntColumn get createdAt => integer()();

  /// UTC milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  /// UTC milliseconds since epoch; null while the row is live. Soft-delete
  /// marker per ADR 004.
  IntColumn get deletedAt => integer().nullable()();

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see
  /// ADR 004).
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
