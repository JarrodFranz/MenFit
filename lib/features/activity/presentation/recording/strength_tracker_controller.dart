import 'dart:async';

import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/strength_routine.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/presentation/recording/tracker_screen_awake.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'strength_tracker_controller.g.dart';

/// State for an in-progress or completed Strength workout session.
class StrengthTrackerState {
  const StrengthTrackerState({
    this.isActive = false,
    this.startedAt,
    this.lastInteractionAt,
    this.elapsedDuration = Duration.zero,
    this.exercises = const [],
    this.cycleId,
    this.routineId,
    this.routineName,
    this.historicalWeights = const {},
    this.activeExerciseIndex,
    this.activeSetIndex,
    this.activeSetStartedAt,
    this.activeSetElapsedSeconds = 0,
    this.isRestTimerRunning = false,
    this.restEndsAt,
    this.restSecondsRemaining = 0,
    this.savedActivityId,
  });

  final bool isActive;
  final DateTime? startedAt;

  /// UTC time of the last thing the user actually logged (set completed,
  /// exercise added, weight edited). Not touched by the ticker - a workout
  /// left open on screen accrues [elapsedDuration] but no interactions,
  /// which is exactly what
  /// `domain/strength_session_duration.dart`'s `strengthLooksAbandoned`
  /// reads to stop an abandoned session recording the whole gap.
  final DateTime? lastInteractionAt;

  /// Wall-clock time since [startedAt], including any time the workout was
  /// left open untouched. Honest for a session the user is training
  /// through, misleading for one left running - see [lastInteractionAt].
  final Duration elapsedDuration;
  final List<StrengthExercise> exercises;
  final String? cycleId;
  final String? routineId;
  final String? routineName;

  /// Map of lowercase exercise name to the formatted last weight/reps summary (e.g. "40 kg × 8 reps").
  final Map<String, String> historicalWeights;

  final int? activeExerciseIndex;
  final int? activeSetIndex;
  final DateTime? activeSetStartedAt;
  final int activeSetElapsedSeconds;
  final bool isRestTimerRunning;
  final DateTime? restEndsAt;
  final int restSecondsRemaining;
  final String? savedActivityId;

  bool get isSetRunning =>
      activeExerciseIndex != null && activeSetIndex != null;

  double get totalVolumeKg =>
      exercises.fold(0, (sum, e) => sum + e.totalVolumeKg);

  int get totalCompletedSets =>
      exercises.fold(0, (sum, e) => sum + e.completedSetsCount);

  StrengthTrackerState copyWith({
    bool? isActive,
    DateTime? startedAt,
    DateTime? lastInteractionAt,
    Duration? elapsedDuration,
    List<StrengthExercise>? exercises,
    String? cycleId,
    String? routineId,
    String? routineName,
    Map<String, String>? historicalWeights,
    int? activeExerciseIndex,
    int? activeSetIndex,
    DateTime? activeSetStartedAt,
    int? activeSetElapsedSeconds,
    bool? isRestTimerRunning,
    DateTime? restEndsAt,
    int? restSecondsRemaining,
    String? savedActivityId,
    bool clearActiveSet = false,
    bool clearRestTimer = false,
  }) {
    return StrengthTrackerState(
      isActive: isActive ?? this.isActive,
      startedAt: startedAt ?? this.startedAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      exercises: exercises ?? this.exercises,
      cycleId: cycleId ?? this.cycleId,
      routineId: routineId ?? this.routineId,
      routineName: routineName ?? this.routineName,
      historicalWeights: historicalWeights ?? this.historicalWeights,
      activeExerciseIndex: clearActiveSet
          ? null
          : (activeExerciseIndex ?? this.activeExerciseIndex),
      activeSetIndex: clearActiveSet
          ? null
          : (activeSetIndex ?? this.activeSetIndex),
      activeSetStartedAt: clearActiveSet
          ? null
          : (activeSetStartedAt ?? this.activeSetStartedAt),
      activeSetElapsedSeconds: clearActiveSet
          ? 0
          : (activeSetElapsedSeconds ?? this.activeSetElapsedSeconds),
      isRestTimerRunning:
          !clearRestTimer && (isRestTimerRunning ?? this.isRestTimerRunning),
      restEndsAt: clearRestTimer ? null : (restEndsAt ?? this.restEndsAt),
      restSecondsRemaining: clearRestTimer
          ? 0
          : (restSecondsRemaining ?? this.restSecondsRemaining),
      savedActivityId: savedActivityId ?? this.savedActivityId,
    );
  }
}

/// Global, persistent controller for live Strength tracking.
///
/// `keepAlive: true` deliberately — a session must survive the user leaving
/// `strength_tracker_screen.dart` (the active-workout banner resumes it from
/// any tab); only [finishWorkout] or [discardWorkout] end it. A plain
/// `@riverpod` would be autoDispose and would drop the live session, its
/// ticker and its logged sets the moment the screen popped.
@Riverpod(keepAlive: true)
class StrengthTrackerController extends _$StrengthTrackerController {
  Timer? _ticker;

  /// The screen lock, honouring the Strength hub's "Keep screen awake"
  /// switch — including a change made mid-workout.
  late final TrackerScreenAwake _screenAwake = TrackerScreenAwake(ref);

  @override
  StrengthTrackerState build() {
    ref.onDispose(() {
      _ticker?.cancel();
      _screenAwake.release();
    });
    return const StrengthTrackerState();
  }

  /// Starts a strength workout session. If [routine] is provided, loads its
  /// planned exercises; otherwise starts with a clean, empty exercise list.
  Future<void> startWorkout({
    StrengthDayRoutine? routine,
    String? cycleId,
  }) async {
    final now = DateTime.now().toUtc();

    var initialExercises = <StrengthExercise>[];
    if (routine != null) {
      initialExercises = routine.exercises.map((template) {
        final sets = List.generate(
          template.targetSets,
          (i) => StrengthSet(
            setNumber: i + 1,
            reps: template.targetReps,
            weightKg: template.targetWeightKg,
            isCompleted: false,
          ),
        );
        return StrengthExercise(
          name: template.name,
          notes: template.notes,
          sets: sets,
        );
      }).toList();
    }

    state = StrengthTrackerState(
      isActive: true,
      startedAt: now,
      lastInteractionAt: now,
      exercises: initialExercises,
      cycleId: cycleId,
      routineId: routine?.id,
      routineName: routine?.name,
    );

    // The one funnel: `startWorkoutIfNeeded` delegates here, so acquiring
    // in this method covers both entry points.
    _screenAwake.acquireFor(ActivityType.strength);
    _startTicker();

    if (initialExercises.isNotEmpty) {
      await _loadHistoryForExercises(
        initialExercises.map((e) => e.name).toList(),
      );
    }
  }

  /// Backward-compatible start if screen is opened without explicit start.
  void startWorkoutIfNeeded() {
    if (state.isActive) return;
    unawaited(startWorkout());
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// Stamps "the user just logged something" onto the session.
  ///
  /// Deliberately NOT called from [_tick]: a workout sitting on screen with
  /// a set timer running and no button pressed for half an hour is the
  /// abandonment case, not evidence of training. See
  /// [StrengthTrackerState.lastInteractionAt].
  void _markInteraction() {
    if (!state.isActive) return;
    state = state.copyWith(lastInteractionAt: DateTime.now().toUtc());
  }

  void _tick() {
    if (!state.isActive || state.startedAt == null) return;
    final now = DateTime.now().toUtc();
    final elapsed = now.difference(state.startedAt!);

    var activeSetSec = 0;
    if (state.activeSetStartedAt != null) {
      activeSetSec = now.difference(state.activeSetStartedAt!).inSeconds;
    }

    var restRunning = state.isRestTimerRunning;
    var restRemaining = 0;
    if (state.isRestTimerRunning && state.restEndsAt != null) {
      final diff = state.restEndsAt!.difference(now).inSeconds;
      if (diff <= 0) {
        restRunning = false;
        restRemaining = 0;
      } else {
        restRemaining = diff;
      }
    }

    state = state.copyWith(
      elapsedDuration: elapsed,
      activeSetElapsedSeconds: activeSetSec,
      isRestTimerRunning: restRunning,
      restSecondsRemaining: restRemaining,
    );
  }

  /// Adds an exercise to the active workout. Queries history to prefill weights/reps.
  Future<void> addExercise(
    String name, {
    int targetSets = 3,
    int defaultReps = 10,
    double defaultWeightKg = 0.0,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    _markInteraction();

    final repo = ref.read(strengthRoutineRepositoryProvider);
    final past = await repo.getLastExercisePerformance(trimmedName);

    var initialReps = defaultReps;
    var initialWeight = defaultWeightKg;

    if (past != null && past.sets.isNotEmpty) {
      final completed = past.sets.where((s) => s.isCompleted).toList();
      if (completed.isNotEmpty) {
        initialReps = completed.first.reps;
        initialWeight = completed.first.weightKg;
      }
    }

    final sets = List.generate(
      targetSets,
      (i) => StrengthSet(
        setNumber: i + 1,
        reps: initialReps,
        weightKg: initialWeight,
        isCompleted: false,
      ),
    );

    final newExercises = List<StrengthExercise>.from(state.exercises)
      ..add(StrengthExercise(name: trimmedName, sets: sets));

    final history = Map<String, String>.from(state.historicalWeights);
    if (past != null && past.sets.any((s) => s.isCompleted)) {
      final comp = past.sets.firstWhere((s) => s.isCompleted);
      final wtStr = comp.weightKg.truncateToDouble() == comp.weightKg
          ? comp.weightKg.toInt().toString()
          : comp.weightKg.toStringAsFixed(1);
      history[trimmedName.toLowerCase()] = '$wtStr kg × ${comp.reps} reps';
    }

    state = state.copyWith(
      exercises: newExercises,
      historicalWeights: history,
    );
  }

  Future<void> _loadHistoryForExercises(List<String> names) async {
    final repo = ref.read(strengthRoutineRepositoryProvider);
    final history = Map<String, String>.from(state.historicalWeights);

    for (final name in names) {
      final key = name.trim().toLowerCase();
      if (history.containsKey(key)) continue;

      final past = await repo.getLastExercisePerformance(name);
      if (past != null && past.sets.any((s) => s.isCompleted)) {
        final comp = past.sets.firstWhere((s) => s.isCompleted);
        final wtStr = comp.weightKg.truncateToDouble() == comp.weightKg
            ? comp.weightKg.toInt().toString()
            : comp.weightKg.toStringAsFixed(1);
        history[key] = '$wtStr kg × ${comp.reps} reps';
      }
    }

    state = state.copyWith(historicalWeights: history);
  }

  void removeExercise(int index) {
    if (index < 0 || index >= state.exercises.length) return;
    _markInteraction();
    final newExercises = List<StrengthExercise>.from(state.exercises)
      ..removeAt(index);
    final clearActive = state.activeExerciseIndex == index;
    state = state.copyWith(
      exercises: newExercises,
      clearActiveSet: clearActive,
    );
  }

  void addSet(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= state.exercises.length) return;
    _markInteraction();
    final exercise = state.exercises[exerciseIndex];
    final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;
    final newSet = StrengthSet(
      setNumber: exercise.sets.length + 1,
      reps: lastSet?.reps ?? 10,
      weightKg: lastSet?.weightKg ?? 20,
      isCompleted: false,
    );

    final updatedExercise = exercise.copyWith(
      sets: [...exercise.sets, newSet],
    );

    final newExercises = List<StrengthExercise>.from(state.exercises);
    newExercises[exerciseIndex] = updatedExercise;
    state = state.copyWith(exercises: newExercises);
  }

  void removeSet(int exerciseIndex, int setIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= state.exercises.length) return;
    final exercise = state.exercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;
    _markInteraction();

    final updatedSets = List<StrengthSet>.from(exercise.sets)
      ..removeAt(setIndex);
    // Renumber
    for (var i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    final newExercises = List<StrengthExercise>.from(state.exercises);
    newExercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);
    final clearActive =
        state.activeExerciseIndex == exerciseIndex &&
        state.activeSetIndex == setIndex;

    state = state.copyWith(
      exercises: newExercises,
      clearActiveSet: clearActive,
    );
  }

  void updateSet(
    int exerciseIndex,
    int setIndex, {
    int? reps,
    double? weightKg,
    bool? isCompleted,
    int? durationSeconds,
  }) {
    if (exerciseIndex < 0 || exerciseIndex >= state.exercises.length) return;
    final exercise = state.exercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;
    _markInteraction();

    final currentSet = exercise.sets[setIndex];
    final updatedSet = currentSet.copyWith(
      reps: reps ?? currentSet.reps,
      weightKg: weightKg ?? currentSet.weightKg,
      isCompleted: isCompleted ?? currentSet.isCompleted,
      durationSeconds: durationSeconds ?? currentSet.durationSeconds,
    );

    final updatedSets = List<StrengthSet>.from(exercise.sets);
    updatedSets[setIndex] = updatedSet;

    final newExercises = List<StrengthExercise>.from(state.exercises);
    newExercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);
    state = state.copyWith(exercises: newExercises);
  }

  void startActiveSet(int exerciseIndex, int setIndex) {
    _markInteraction();
    final now = DateTime.now().toUtc();
    state = state.copyWith(
      activeExerciseIndex: exerciseIndex,
      activeSetIndex: setIndex,
      activeSetStartedAt: now,
      activeSetElapsedSeconds: 0,
      clearRestTimer: true,
    );
  }

  void finishActiveSet() {
    if (state.activeExerciseIndex == null || state.activeSetIndex == null) {
      return;
    }
    _markInteraction();
    final exerciseIdx = state.activeExerciseIndex!;
    final setIdx = state.activeSetIndex!;
    final durationSec = state.activeSetElapsedSeconds;

    updateSet(
      exerciseIdx,
      setIdx,
      isCompleted: true,
      durationSeconds: durationSec > 0 ? durationSec : 30,
    );

    final now = DateTime.now().toUtc();
    final restEndsAt = now.add(const Duration(seconds: 90));

    state = state.copyWith(
      clearActiveSet: true,
      isRestTimerRunning: true,
      restEndsAt: restEndsAt,
      restSecondsRemaining: 90,
    );
  }

  void addRestSeconds(int seconds) {
    if (!state.isRestTimerRunning || state.restEndsAt == null) return;
    _markInteraction();
    final newEndsAt = state.restEndsAt!.add(Duration(seconds: seconds));
    final now = DateTime.now().toUtc();
    state = state.copyWith(
      restEndsAt: newEndsAt,
      restSecondsRemaining: newEndsAt.difference(now).inSeconds,
    );
  }

  void stopRestTimer() {
    _markInteraction();
    state = state.copyWith(clearRestTimer: true);
  }

  /// Saves the current workout exercises as a reusable Day Routine.
  Future<StrengthDayRoutine> saveAsRoutine(
    String routineName, {
    String description = '',
  }) async {
    final templates = state.exercises.map((e) {
      final count = e.sets.isNotEmpty ? e.sets.length : 3;
      final avgReps = e.sets.isNotEmpty
          ? (e.sets.fold<int>(0, (sum, s) => sum + s.reps) / e.sets.length)
                .round()
          : 10;
      final maxWeight = e.sets.isNotEmpty
          ? e.sets.fold<double>(
              0,
              (max, s) => s.weightKg > max ? s.weightKg : max,
            )
          : 0.0;

      return StrengthExerciseTemplate(
        name: e.name,
        targetSets: count,
        targetReps: avgReps > 0 ? avgReps : 10,
        targetWeightKg: maxWeight,
        notes: e.notes,
      );
    }).toList();

    final routine = StrengthDayRoutine.create(
      name: routineName,
      description: description,
      exercises: templates,
      estimatedDurationMinutes: state.elapsedDuration.inMinutes.clamp(15, 120),
    );

    await ref.read(strengthRoutineRepositoryProvider).saveRoutine(routine);
    return routine;
  }

  /// Finishes and persists the workout.
  ///
  /// [elapsedOverride] records that duration instead of the wall-clock
  /// [StrengthTrackerState.elapsedDuration] - the screen passes it when the
  /// user has been asked about a long idle gap and chose to record only the
  /// time up to their last logged set (see
  /// `domain/strength_session_duration.dart`). Nothing else may shorten the
  /// duration on the user's behalf.
  Future<Activity?> finishWorkout({Duration? elapsedOverride}) async {
    if (!state.isActive || state.startedAt == null) return null;
    _ticker?.cancel();
    // Released before the write, not after it: the workout is over either
    // way, and a save that throws must not leave the lock held.
    _screenAwake.release();

    final now = DateTime.now().toUtc();
    final elapsed = elapsedOverride ?? state.elapsedDuration;
    final movingSec = state.exercises
        .expand((e) => e.sets)
        .where((s) => s.isCompleted)
        .fold(0, (sum, s) => sum + s.durationSeconds);

    final details = StrengthWorkoutDetails(
      exercises: state.exercises,
    );

    final activityTitle = state.routineName ?? 'Strength Workout';
    final activityId = EntityId.generate();
    final activity = Activity(
      id: activityId,
      activityType: ActivityType.strength,
      title: activityTitle,
      startedAt: state.startedAt!,
      movingTime: Duration(
        seconds: movingSec > 0 ? movingSec : elapsed.inSeconds,
      ),
      elapsedTime: elapsed,
      distanceMeters: 0,
      source: ActivitySource.recorded,
      workoutDetails: details,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(activityRepositoryProvider).saveActivity(activity);

    // If part of an active training cycle, advance cycle progress
    if (state.cycleId != null) {
      await ref
          .read(strengthRoutineRepositoryProvider)
          .recordCycleSessionCompleted(
            cycleId: state.cycleId!,
            volumeKg: state.totalVolumeKg,
          );
    }

    state = const StrengthTrackerState();
    return activity;
  }

  void discardWorkout() {
    _ticker?.cancel();
    _screenAwake.release();
    state = const StrengthTrackerState();
  }
}
