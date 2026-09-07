import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/core/utils/polyline_codec.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/routes/domain/geo_point.dart';
import 'package:menfit_app/features/routes/domain/route_repository.dart';
import 'package:menfit_app/features/routes/domain/saved_route.dart';

/// [RouteRepository] backed by the `routes` Drift table.
///
/// The geometry TEXT column holds a polyline-5 encoding
/// (`core/utils/polyline_codec.dart`); encode/decode happens here at the
/// repository boundary so nothing above data/ ever sees the encoding. The
/// generated Drift row class is named `Route` — which would collide with
/// Flutter's `Route` in presentation code — another reason the row type
/// must never leak above this file (`db` import prefix, same convention as
/// `drift_activity_repository.dart`).
///
/// The provider for this repository lives in `../routes_providers.dart`
/// (ADR 007), not here.
class DriftRouteRepository implements RouteRepository {
  const DriftRouteRepository(this._db);

  final db.AppDatabase _db;

  @override
  Stream<List<SavedRoute>> watchRoutes() {
    final query = _db.select(_db.routes)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    return query
        .watch()
        .map((rows) => rows.map(_toEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch routes',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Stream<SavedRoute?> watchRoute(String id) {
    final query = _db.select(_db.routes)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());

    return query
        .watchSingleOrNull()
        .map((row) => row == null ? null : _toEntity(row))
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch route',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<SavedRoute?> getRoute(String id) async {
    try {
      final query = _db.select(_db.routes)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
      final row = await query.getSingleOrNull();
      return row == null ? null : _toEntity(row);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to fetch route',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveRoute(SavedRoute route) async {
    final now = DateTime.now().toUtc();
    try {
      await _db.transaction(() async {
        // Read-then-write so `createdAt` is preserved across an update
        // regardless of what the caller passed in (same reasoning as
        // `DriftActivityRepository.saveActivity`).
        final existing = await (_db.select(
          _db.routes,
        )..where((t) => t.id.equals(route.id))).getSingleOrNull();
        final createdAtMillis =
            existing?.createdAt ??
            route.createdAt.toUtc().millisecondsSinceEpoch;

        await _db
            .into(_db.routes)
            .insertOnConflictUpdate(
              db.RoutesCompanion.insert(
                id: route.id,
                name: route.name,
                distanceMeters: route.distanceMeters,
                estimatedDurationSeconds: Value(
                  route.estimatedDuration?.inSeconds,
                ),
                ascentMeters: Value(route.ascentMeters),
                descentMeters: Value(route.descentMeters),
                geometry: encodePolyline([
                  for (final point in route.points)
                    (latitude: point.latitude, longitude: point.longitude),
                ]),
                activityType: route.activityType.toStorage(),
                source: Value(route.source.toStorage()),
                createdAt: createdAtMillis,
                updatedAt: now.millisecondsSinceEpoch,
              ),
            );
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save route',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteRoute(String id) async {
    final nowMillis = DateTime.now().toUtc().millisecondsSinceEpoch;
    try {
      await (_db.update(_db.routes)..where((t) => t.id.equals(id))).write(
        db.RoutesCompanion(
          deletedAt: Value(nowMillis),
          updatedAt: Value(nowMillis),
        ),
      );
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete route',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _db.delete(_db.routes).go();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete route data',
        cause: e,
        stackTrace: st,
      );
    }
  }

  SavedRoute _toEntity(db.Route row) {
    return SavedRoute(
      id: row.id,
      name: row.name,
      activityType: ActivityType.fromStorage(row.activityType),
      distanceMeters: row.distanceMeters,
      points: [
        for (final point in decodePolyline(row.geometry))
          GeoPoint(latitude: point.latitude, longitude: point.longitude),
      ],
      source: RouteSource.fromStorage(row.source),
      estimatedDuration: row.estimatedDurationSeconds == null
          ? null
          : Duration(seconds: row.estimatedDurationSeconds!),
      ascentMeters: row.ascentMeters,
      descentMeters: row.descentMeters,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAt,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row.updatedAt,
        isUtc: true,
      ),
    );
  }
}
