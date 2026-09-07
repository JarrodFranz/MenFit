import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/activity/domain/strength_routine.dart';
import 'package:menfit_app/features/activity/domain/strength_routine_repository.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';

/// Drift implementation of [StrengthRoutineRepository].
class DriftStrengthRoutineRepository implements StrengthRoutineRepository {
  const DriftStrengthRoutineRepository(this._db);

  final db.AppDatabase _db;

  @override
  Stream<List<StrengthCycle>> watchCycles() {
    final query = _db.select(_db.strengthCycles)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    return query
        .watch()
        .map((rows) => rows.map(_toCycleEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch strength cycles',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Stream<List<StrengthDayRoutine>> watchRoutines() {
    final query = _db.select(_db.strengthRoutines)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    return query
        .watch()
        .map((rows) => rows.map(_toRoutineEntity).toList())
        .handleError((Object error, StackTrace stackTrace) {
          throw StorageException(
            message: 'Failed to watch strength routines',
            cause: error,
            stackTrace: stackTrace,
          );
        });
  }

  @override
  Future<List<StrengthCycle>> getCycles() async {
    try {
      final query = _db.select(_db.strengthCycles)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
      final rows = await query.get();
      return rows.map(_toCycleEntity).toList();
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to get strength cycles',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<List<StrengthDayRoutine>> getRoutines() async {
    try {
      final query = _db.select(_db.strengthRoutines)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
      final rows = await query.get();
      return rows.map(_toRoutineEntity).toList();
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to get strength routines',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<StrengthCycle?> getActiveCycle() async {
    try {
      final query = _db.select(_db.strengthCycles)
        ..where((t) => t.deletedAt.isNull() & t.isActive.equals(true))
        ..limit(1);
      final row = await query.getSingleOrNull();
      return row == null ? null : _toCycleEntity(row);
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to get active strength cycle',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveRoutine(StrengthDayRoutine routine) async {
    try {
      await _db
          .into(_db.strengthRoutines)
          .insertOnConflictUpdate(
            db.StrengthRoutinesCompanion(
              id: Value(routine.id),
              name: Value(routine.name),
              description: Value(routine.description),
              exercisesJson: Value(
                jsonEncode(routine.exercises.map((e) => e.toJson()).toList()),
              ),
              estimatedDurationMinutes: Value(routine.estimatedDurationMinutes),
              createdAt: Value(
                routine.createdAt.toUtc().millisecondsSinceEpoch,
              ),
              updatedAt: Value(
                routine.updatedAt.toUtc().millisecondsSinceEpoch,
              ),
              deletedAt: const Value(null),
            ),
          );
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to save strength routine',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteRoutine(String id) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (_db.update(
        _db.strengthRoutines,
      )..where((t) => t.id.equals(id))).write(
        db.StrengthRoutinesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to delete strength routine',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> saveCycle(StrengthCycle cycle) async {
    try {
      await _db
          .into(_db.strengthCycles)
          .insertOnConflictUpdate(
            db.StrengthCyclesCompanion(
              id: Value(cycle.id),
              name: Value(cycle.name),
              description: Value(cycle.description),
              routinesJson: Value(
                jsonEncode(cycle.routines.map((r) => r.toJson()).toList()),
              ),
              currentDayIndex: Value(cycle.currentDayIndex),
              totalSessionsCompleted: Value(cycle.totalSessionsCompleted),
              totalVolumeLiftedKg: Value(cycle.totalVolumeLiftedKg),
              isActive: Value(cycle.isActive),
              startedAt: Value(
                cycle.startedAt?.toUtc().millisecondsSinceEpoch,
              ),
              lastCompletedAt: Value(
                cycle.lastCompletedAt?.toUtc().millisecondsSinceEpoch,
              ),
              createdAt: Value(cycle.createdAt.toUtc().millisecondsSinceEpoch),
              updatedAt: Value(cycle.updatedAt.toUtc().millisecondsSinceEpoch),
              deletedAt: const Value(null),
            ),
          );
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to save strength cycle',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteCycle(String id) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (_db.update(
        _db.strengthCycles,
      )..where((t) => t.id.equals(id))).write(
        db.StrengthCyclesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to delete strength cycle',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> setActiveCycle(String? cycleId) async {
    try {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await _db.transaction(() async {
        // Deactivate all cycles first
        await (_db.update(
          _db.strengthCycles,
        )..where((t) => t.deletedAt.isNull())).write(
          db.StrengthCyclesCompanion(
            isActive: const Value(false),
            updatedAt: Value(now),
          ),
        );

        if (cycleId != null) {
          await (_db.update(
            _db.strengthCycles,
          )..where((t) => t.id.equals(cycleId))).write(
            db.StrengthCyclesCompanion(
              isActive: const Value(true),
              startedAt: Value(now),
              updatedAt: Value(now),
            ),
          );
        }
      });
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to set active strength cycle',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> recordCycleSessionCompleted({
    required String cycleId,
    required double volumeKg,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      final nowMillis = now.millisecondsSinceEpoch;
      final cycleRow = await (_db.select(
        _db.strengthCycles,
      )..where((t) => t.id.equals(cycleId))).getSingleOrNull();
      if (cycleRow == null) return;

      final cycle = _toCycleEntity(cycleRow);
      final nextIndex = cycle.routines.isEmpty
          ? 0
          : (cycle.currentDayIndex + 1) % cycle.routines.length;

      await (_db.update(
        _db.strengthCycles,
      )..where((t) => t.id.equals(cycleId))).write(
        db.StrengthCyclesCompanion(
          currentDayIndex: Value(nextIndex),
          totalSessionsCompleted: Value(cycle.totalSessionsCompleted + 1),
          totalVolumeLiftedKg: Value(cycle.totalVolumeLiftedKg + volumeKg),
          lastCompletedAt: Value(nowMillis),
          updatedAt: Value(nowMillis),
        ),
      );
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to update cycle session metrics',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<StrengthExercise?> getLastExercisePerformance(
    String exerciseName,
  ) async {
    try {
      final normalizedQuery = exerciseName.trim().toLowerCase();
      if (normalizedQuery.isEmpty) return null;

      final activitiesQuery = _db.select(_db.activities)
        ..where(
          (t) =>
              t.activityType.equals('strength') &
              t.deletedAt.isNull() &
              t.metadataJson.isNotNull(),
        )
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
        ..limit(50);

      final rows = await activitiesQuery.get();

      for (final row in rows) {
        final details = WorkoutDetails.fromStorage(row.metadataJson);
        if (details is StrengthWorkoutDetails) {
          for (final exercise in details.exercises) {
            if (exercise.name.trim().toLowerCase() == normalizedQuery &&
                exercise.sets.any((s) => s.isCompleted)) {
              return exercise;
            }
          }
        }
      }
      return null;
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to look up past exercise performance',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<StrengthExercise?> getExerciseAllTimeBestPerformance(
    String exerciseName,
  ) async {
    final normalizedQuery = exerciseName.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return null;

    try {
      final rows =
          await (_db.select(_db.activities)
                ..where((t) => t.activityType.equals('strength'))
                ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
              .get();

      StrengthExercise? bestExercise;
      var maxWeight = -1.0;
      var maxRepsAtMaxWeight = 0;

      for (final row in rows) {
        final details = WorkoutDetails.fromStorage(row.metadataJson);
        if (details is StrengthWorkoutDetails) {
          for (final exercise in details.exercises) {
            if (exercise.name.trim().toLowerCase() == normalizedQuery) {
              for (final s in exercise.sets) {
                if (s.isCompleted &&
                    (s.weightKg > maxWeight ||
                        (s.weightKg == maxWeight &&
                            s.reps > maxRepsAtMaxWeight))) {
                  maxWeight = s.weightKg;
                  maxRepsAtMaxWeight = s.reps;
                  bestExercise = exercise;
                }
              }
            }
          }
        }
      }
      return bestExercise;
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to look up all-time exercise best performance',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteAllData() async {
    try {
      // Hard delete, soft-deleted rows included: a hidden row is not a
      // deleted one (see `settings_screen.dart`'s "Delete my data" flow,
      // and `drift_yoga_sequence_repository.dart#deleteAllData`, which
      // this mirrors). Both tables in one transaction since they are wiped
      // as one unit.
      await _db.transaction(() async {
        await _db.delete(_db.strengthRoutines).go();
        await _db.delete(_db.strengthCycles).go();
      });
    } on Object catch (e, st) {
      throw StorageException(
        message: 'Failed to delete strength routines and cycles',
        cause: e,
        stackTrace: st,
      );
    }
  }

  static StrengthDayRoutine _toRoutineEntity(db.StrengthRoutine row) {
    var exercises = <StrengthExerciseTemplate>[];
    try {
      final decoded = jsonDecode(row.exercisesJson);
      if (decoded is List) {
        exercises = decoded
            .map(
              (e) =>
                  StrengthExerciseTemplate.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
    } on Object catch (_) {}

    return StrengthDayRoutine(
      id: row.id,
      name: row.name,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAt,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row.updatedAt,
        isUtc: true,
      ),
      description: row.description,
      exercises: exercises,
      estimatedDurationMinutes: row.estimatedDurationMinutes,
    );
  }

  static StrengthCycle _toCycleEntity(db.StrengthCycle row) {
    var routines = <StrengthDayRoutine>[];
    try {
      final decoded = jsonDecode(row.routinesJson);
      if (decoded is List) {
        routines = decoded
            .map((r) => StrengthDayRoutine.fromJson(r as Map<String, dynamic>))
            .toList();
      }
    } on Object catch (_) {}

    return StrengthCycle(
      id: row.id,
      name: row.name,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAt,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row.updatedAt,
        isUtc: true,
      ),
      description: row.description,
      routines: routines,
      currentDayIndex: row.currentDayIndex,
      totalSessionsCompleted: row.totalSessionsCompleted,
      totalVolumeLiftedKg: row.totalVolumeLiftedKg,
      isActive: row.isActive,
      startedAt: row.startedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.startedAt!, isUtc: true),
      lastCompletedAt: row.lastCompletedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              row.lastCompletedAt!,
              isUtc: true,
            ),
    );
  }
}
