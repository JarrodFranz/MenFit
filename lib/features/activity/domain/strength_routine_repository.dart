import 'package:menfit_app/features/activity/domain/strength_routine.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';

/// Repository interface for Strength Day Routines and multi-day Training
/// Cycles.
abstract class StrengthRoutineRepository {
  /// Watches all active (non-deleted) strength training cycles.
  Stream<List<StrengthCycle>> watchCycles();

  /// Watches all active (non-deleted) day routines.
  Stream<List<StrengthDayRoutine>> watchRoutines();

  /// Gets all active cycles.
  Future<List<StrengthCycle>> getCycles();

  /// Gets all active day routines.
  Future<List<StrengthDayRoutine>> getRoutines();

  /// Gets the currently active training cycle, or null if none is active.
  Future<StrengthCycle?> getActiveCycle();

  /// Saves or updates a day routine.
  Future<void> saveRoutine(StrengthDayRoutine routine);

  /// Soft-deletes a day routine by id.
  Future<void> deleteRoutine(String id);

  /// Saves or updates a strength cycle.
  Future<void> saveCycle(StrengthCycle cycle);

  /// Soft-deletes a strength cycle by id.
  Future<void> deleteCycle(String id);

  /// Sets [cycleId] as the active cycle (and deactivates any other cycle).
  /// Pass `null` to deactivate all cycles.
  Future<void> setActiveCycle(String? cycleId);

  /// Increments completed sessions and advances `currentDayIndex` for the
  /// cycle.
  Future<void> recordCycleSessionCompleted({
    required String cycleId,
    required double volumeKg,
  });

  /// Finds the most recent completed performance of [exerciseName] across
  /// all past strength workouts, returning the exercise with its logged sets.
  Future<StrengthExercise?> getLastExercisePerformance(String exerciseName);

  /// Finds the all-time highest weight completed performance of [exerciseName]
  /// across all past strength workouts.
  Future<StrengthExercise?> getExerciseAllTimeBestPerformance(
    String exerciseName,
  );

  /// Hard-deletes every day routine and every training cycle on this
  /// device — part of the "Delete my data" flow
  /// (`features/settings/presentation/settings_screen.dart`).
  /// Soft-deleted rows go too: a hidden row is not a deleted one (same
  /// reasoning as `features/activity/domain/yoga_sequence_repository.dart
  /// #deleteAllData`).
  Future<void> deleteAllData();
}
