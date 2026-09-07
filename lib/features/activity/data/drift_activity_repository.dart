import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_repository.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';

/// [ActivityRepository] backed by the `activities`/`activity_samples`
/// Drift tables.
///
/// The generated Drift row class for the activities table is also named
/// `Activity`, so this file imports `app_database.dart` with the `db`
/// prefix throughout to keep it distinct from the freezed domain entity of
/// the same name (same convention as
/// `features/profile/data/drift_profile_repository.dart`).
///
/// The provider for this repository lives in `../activity_providers.dart`
/// (ADR 007), not here.
class DriftActivityRepository implements ActivityRepository {
  const DriftActivityRepository(this._db);

  final db.AppDatabase _db;

  @override
  Stream<List<Activity>> watchActivities() {
    final query = _db.select(_db.activities)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);

    return query
        .watch()
        .map((rows) => rows.map(_toEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          // Rethrowing from an error handler replaces the stream's error
          // event with this one - a raw platform exception must never
          // cross the repository boundary (error_handling.md).
          throw StorageException(
            message: 'Failed to watch activities',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<List<Activity>> getActivities() async {
    try {
      final query = _db.select(_db.activities)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
      final rows = await query.get();
      return rows.map(_toEntity).toList();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to get activities',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Stream<Activity?> watchActivity(String id) {
    final query = _db.select(_db.activities)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());

    return query
        .watchSingleOrNull()
        .map((row) => row == null ? null : _toEntity(row))
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch activity',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<Activity?> getActivity(String id) async {
    try {
      final query = _db.select(_db.activities)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
      final row = await query.getSingleOrNull();
      return row == null ? null : _toEntity(row);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to get activity',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveActivity(Activity activity) async {
    try {
      await _db.transaction(() => _writeActivity(activity));
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save activity',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveRecordedActivity(
    Activity activity,
    List<ActivitySample> samples,
  ) async {
    try {
      // ONE transaction spanning both writes - see the interface dartdoc:
      // a process death between two separately-committed writes would leave
      // a recorded activity with no GPS track and no way to recover it.
      await _db.transaction(() async {
        await _writeActivity(activity);
        await _writeSamples(samples);
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save recorded activity',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Upserts [activity]. Assumes an enclosing transaction and lets raw
  /// errors escape — callers wrap both.
  Future<void> _writeActivity(Activity activity) async {
    final now = DateTime.now().toUtc();
    // Read-then-write so `createdAt` is preserved across an update
    // regardless of what the caller passed in (same reasoning as
    // `DriftProfileRepository.saveProfile`).
    final existing = await (_db.select(
      _db.activities,
    )..where((t) => t.id.equals(activity.id))).getSingleOrNull();
    final createdAtMillis =
        existing?.createdAt ??
        activity.createdAt.toUtc().millisecondsSinceEpoch;

    await _db
        .into(_db.activities)
        .insertOnConflictUpdate(
          db.ActivitiesCompanion.insert(
            id: activity.id,
            activityType: activity.activityType.toStorage(),
            title: activity.title,
            notes: Value(activity.notes),
            startedAt: activity.startedAt.toUtc().millisecondsSinceEpoch,
            movingTimeMs: activity.movingTime.inMilliseconds,
            elapsedTimeMs: activity.elapsedTime.inMilliseconds,
            distanceMeters: activity.distanceMeters,
            elevationGainMeters: Value(activity.elevationGainMeters),
            avgHeartRate: Value(activity.avgHeartRate),
            source: activity.source.toStorage(),
            routeId: Value(activity.routeId),
            metadataJson: Value(activity.workoutDetails?.toStorage()),
            createdAt: createdAtMillis,
            updatedAt: now.millisecondsSinceEpoch,
          ),
        );
  }

  @override
  Future<void> deleteActivity(String id) async {
    final nowMillis = DateTime.now().toUtc().millisecondsSinceEpoch;
    try {
      await _db.transaction(() async {
        await (_db.update(
          _db.activities,
        )..where((t) => t.id.equals(id))).write(
          db.ActivitiesCompanion(
            deletedAt: Value(nowMillis),
            updatedAt: Value(nowMillis),
          ),
        );
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete activity',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> insertSamples(List<ActivitySample> samples) async {
    try {
      await _writeSamples(samples);
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to save activity samples',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Batch-inserts [samples]. Lets raw errors escape — callers wrap them.
  /// Safe to call inside an enclosing transaction (drift runs a batch on
  /// the ambient executor).
  Future<void> _writeSamples(List<ActivitySample> samples) async {
    if (samples.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAll(
        _db.activitySamples,
        samples
            .map(
              (s) => db.ActivitySamplesCompanion.insert(
                id: s.id,
                activityId: s.activityId,
                timestampMs: s.timestamp.toUtc().millisecondsSinceEpoch,
                latitude: s.latitude,
                longitude: s.longitude,
                elevationMeters: Value(s.elevationMeters),
                horizontalAccuracyMeters: Value(s.horizontalAccuracyMeters),
                heartRate: Value(s.heartRate),
                isPaused: Value(s.isPaused),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Stream<List<ActivitySample>> watchSamples(String activityId) {
    final query = _db.select(_db.activitySamples)
      ..where((t) => t.activityId.equals(activityId))
      ..orderBy([(t) => OrderingTerm.asc(t.timestampMs)]);

    return query
        .watch()
        .map((rows) => rows.map(_toSampleEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch activity samples',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<List<ActivitySample>> getSamples(String activityId) async {
    try {
      final query = _db.select(_db.activitySamples)
        ..where((t) => t.activityId.equals(activityId))
        ..orderBy([(t) => OrderingTerm.asc(t.timestampMs)]);
      final rows = await query.get();
      return rows.map(_toSampleEntity).toList();
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to fetch activity samples',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Maximum activity ids bound into a single `activity_id IN (...)`
  /// query. SQLite's compiled ceiling on bound variables is 999 on builds
  /// older than 3.32 and 32766 after it; which one applies depends on the
  /// bundled `sqlite3` per platform (and on web, the WASM build), so the
  /// ids are chunked comfortably under the lowest rather than trusting the
  /// host's.
  static const int _maxIdsPerSampleQuery = 500;

  @override
  Future<Map<String, List<ActivitySample>>> getSamplesForActivities(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return const {};
    try {
      // De-duplicated first: a repeated id would otherwise land its rows in
      // the same list twice once it spans two chunks.
      final uniqueIds = ids.toSet().toList();
      final grouped = <String, List<ActivitySample>>{};

      for (
        var offset = 0;
        offset < uniqueIds.length;
        offset += _maxIdsPerSampleQuery
      ) {
        final end = offset + _maxIdsPerSampleQuery;
        final chunk = uniqueIds.sublist(
          offset,
          end < uniqueIds.length ? end : uniqueIds.length,
        );
        final query = _db.select(_db.activitySamples)
          ..where((t) => t.activityId.isIn(chunk))
          // One ordering across the whole chunk is enough: rows arrive
          // globally timestamp-ascending, so appending them in row order
          // leaves every per-activity list ascending too - the ordering
          // `getSamples` promises, which this method must match exactly.
          ..orderBy([(t) => OrderingTerm.asc(t.timestampMs)]);

        for (final row in await query.get()) {
          (grouped[row.activityId] ??= <ActivitySample>[]).add(
            _toSampleEntity(row),
          );
        }
      }
      return grouped;
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to fetch activity samples',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      await _db.transaction(() async {
        // Samples first: no FK cascade is configured (see
        // `core/db/tables/activity_samples.dart`), so deleting activities
        // first would leave orphaned sample rows behind if this ever ran
        // outside a transaction. Order doesn't matter for correctness given
        // the transaction, but samples-then-activities mirrors the
        // parent/child deletion order used elsewhere in this codebase.
        await _db.delete(_db.activitySamples).go();
        await _db.delete(_db.activities).go();
      });
    } catch (e, st) {
      throw StorageException(
        message: 'Failed to delete activity data',
        cause: e,
        stackTrace: st,
      );
    }
  }

  Activity _toEntity(db.Activity row) {
    return Activity(
      id: row.id,
      activityType: ActivityType.fromStorage(row.activityType),
      title: row.title,
      notes: row.notes,
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        row.startedAt,
        isUtc: true,
      ),
      movingTime: Duration(milliseconds: row.movingTimeMs),
      elapsedTime: Duration(milliseconds: row.elapsedTimeMs),
      distanceMeters: row.distanceMeters,
      elevationGainMeters: row.elevationGainMeters,
      avgHeartRate: row.avgHeartRate,
      source: ActivitySource.fromStorage(row.source),
      routeId: row.routeId,
      workoutDetails: WorkoutDetails.fromStorage(row.metadataJson),
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

  ActivitySample _toSampleEntity(db.ActivitySample row) {
    return ActivitySample(
      id: row.id,
      activityId: row.activityId,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        row.timestampMs,
        isUtc: true,
      ),
      latitude: row.latitude,
      longitude: row.longitude,
      elevationMeters: row.elevationMeters,
      horizontalAccuracyMeters: row.horizontalAccuracyMeters,
      heartRate: row.heartRate,
      isPaused: row.isPaused,
    );
  }
}
