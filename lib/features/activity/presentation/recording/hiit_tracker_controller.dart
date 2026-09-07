import 'dart:async';

import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/presentation/recording/tracker_screen_awake.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hiit_tracker_controller.g.dart';

enum HiitPhase { warmup, work, rest, complete }

class HiitTrackerState {
  const HiitTrackerState({
    this.isActive = false,
    this.isRunning = false,
    this.startedAt,
    this.totalElapsedSeconds = 0,
    this.workSeconds = 40,
    this.restSeconds = 20,
    this.totalRounds = 8,
    this.currentRound = 1,
    this.currentPhase = HiitPhase.warmup,
    this.phaseSecondsRemaining = 10,
    this.phaseEndsAt,
    this.savedActivityId,
  });

  final bool isActive;
  final bool isRunning;
  final DateTime? startedAt;
  final int totalElapsedSeconds;
  final int workSeconds;
  final int restSeconds;
  final int totalRounds;
  final int currentRound;
  final HiitPhase currentPhase;
  final int phaseSecondsRemaining;
  final DateTime? phaseEndsAt;
  final String? savedActivityId;

  HiitTrackerState copyWith({
    bool? isActive,
    bool? isRunning,
    DateTime? startedAt,
    int? totalElapsedSeconds,
    int? workSeconds,
    int? restSeconds,
    int? totalRounds,
    int? currentRound,
    HiitPhase? currentPhase,
    int? phaseSecondsRemaining,
    DateTime? phaseEndsAt,
    String? savedActivityId,
    bool clearPhaseEndsAt = false,
  }) {
    return HiitTrackerState(
      isActive: isActive ?? this.isActive,
      isRunning: isRunning ?? this.isRunning,
      startedAt: startedAt ?? this.startedAt,
      totalElapsedSeconds: totalElapsedSeconds ?? this.totalElapsedSeconds,
      workSeconds: workSeconds ?? this.workSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      totalRounds: totalRounds ?? this.totalRounds,
      currentRound: currentRound ?? this.currentRound,
      currentPhase: currentPhase ?? this.currentPhase,
      phaseSecondsRemaining:
          phaseSecondsRemaining ?? this.phaseSecondsRemaining,
      phaseEndsAt: clearPhaseEndsAt ? null : (phaseEndsAt ?? this.phaseEndsAt),
      savedActivityId: savedActivityId ?? this.savedActivityId,
    );
  }
}

/// Global, persistent controller for live HIIT interval tracking.
///
/// `keepAlive: true` deliberately — the interval countdown must survive the
/// user leaving `hiit_tracker_screen.dart` (the active-workout banner resumes
/// it from any tab); only [finishWorkout] or [discardWorkout] end it. A plain
/// `@riverpod` would be autoDispose and would drop the round/phase state and
/// its ticker the moment the screen popped.
@Riverpod(keepAlive: true)
class HiitTrackerController extends _$HiitTrackerController {
  Timer? _ticker;

  /// The screen lock, honouring the HIIT hub's "Keep screen awake" switch
  /// — including a change made while a run of intervals is in progress.
  late final TrackerScreenAwake _screenAwake = TrackerScreenAwake(ref);

  @override
  HiitTrackerState build() {
    ref.onDispose(() {
      _ticker?.cancel();
      _screenAwake.release();
    });
    return const HiitTrackerState();
  }

  void startWorkoutIfNeeded({
    int workSeconds = 40,
    int restSeconds = 20,
    int totalRounds = 8,
  }) {
    if (state.isActive) return;
    final now = DateTime.now().toUtc();
    const warmupSeconds = 10;
    final phaseEndsAt = now.add(const Duration(seconds: warmupSeconds));

    state = HiitTrackerState(
      isActive: true,
      isRunning: true,
      startedAt: now,
      workSeconds: workSeconds,
      restSeconds: restSeconds,
      totalRounds: totalRounds,
      phaseEndsAt: phaseEndsAt,
    );

    _screenAwake.acquireFor(ActivityType.hiit);
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!state.isActive || !state.isRunning || state.startedAt == null) return;
    final now = DateTime.now().toUtc();
    final totalElapsed = now.difference(state.startedAt!).inSeconds;

    if (state.currentPhase == HiitPhase.complete) {
      state = state.copyWith(totalElapsedSeconds: totalElapsed);
      return;
    }

    if (state.phaseEndsAt != null) {
      final remaining = state.phaseEndsAt!.difference(now).inSeconds;
      if (remaining <= 0) {
        _advancePhase(now);
      } else {
        state = state.copyWith(
          totalElapsedSeconds: totalElapsed,
          phaseSecondsRemaining: remaining,
        );
      }
    } else {
      if (state.phaseSecondsRemaining <= 1) {
        _advancePhase(now);
      } else {
        state = state.copyWith(
          totalElapsedSeconds: totalElapsed,
          phaseSecondsRemaining: state.phaseSecondsRemaining - 1,
        );
      }
    }
  }

  void _advancePhase([DateTime? nowTime]) {
    final now = nowTime ?? DateTime.now().toUtc();
    switch (state.currentPhase) {
      case HiitPhase.warmup:
        state = state.copyWith(
          currentPhase: HiitPhase.work,
          phaseSecondsRemaining: state.workSeconds,
          phaseEndsAt: now.add(Duration(seconds: state.workSeconds)),
        );
      case HiitPhase.work:
        if (state.currentRound >= state.totalRounds) {
          state = state.copyWith(
            currentPhase: HiitPhase.complete,
            phaseSecondsRemaining: 0,
            clearPhaseEndsAt: true,
          );
        } else {
          state = state.copyWith(
            currentPhase: HiitPhase.rest,
            phaseSecondsRemaining: state.restSeconds,
            phaseEndsAt: now.add(Duration(seconds: state.restSeconds)),
          );
        }
      case HiitPhase.rest:
        state = state.copyWith(
          currentRound: state.currentRound + 1,
          currentPhase: HiitPhase.work,
          phaseSecondsRemaining: state.workSeconds,
          phaseEndsAt: now.add(Duration(seconds: state.workSeconds)),
        );
      case HiitPhase.complete:
        break;
    }
  }

  void togglePlayPause() {
    final now = DateTime.now().toUtc();
    if (state.isRunning) {
      // Pause
      state = state.copyWith(
        isRunning: false,
        clearPhaseEndsAt: true,
      );
    } else {
      // Resume
      final endsAt = now.add(Duration(seconds: state.phaseSecondsRemaining));
      state = state.copyWith(
        isRunning: true,
        phaseEndsAt: endsAt,
      );
    }
  }

  void skipPhase() {
    _advancePhase();
  }

  Future<Activity?> finishWorkout() async {
    if (!state.isActive || state.startedAt == null) return null;
    _ticker?.cancel();
    // Released before the write, not after it: the intervals are over
    // either way, and a save that throws must not leave the lock held.
    _screenAwake.release();

    final now = DateTime.now().toUtc();
    final completed = state.currentPhase == HiitPhase.complete
        ? state.totalRounds
        : state.currentRound;

    final details = HiitWorkoutDetails(
      workSeconds: state.workSeconds,
      restSeconds: state.restSeconds,
      totalRounds: state.totalRounds,
      completedRounds: completed,
    );

    final activity = Activity(
      id: EntityId.generate(),
      activityType: ActivityType.hiit,
      title: 'HIIT Workout',
      startedAt: state.startedAt!,
      movingTime: Duration(seconds: details.totalWorkTimeSeconds),
      elapsedTime: Duration(seconds: state.totalElapsedSeconds),
      distanceMeters: 0,
      source: ActivitySource.recorded,
      workoutDetails: details,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(activityRepositoryProvider).saveActivity(activity);

    state = const HiitTrackerState();
    return activity;
  }

  void discardWorkout() {
    _ticker?.cancel();
    _screenAwake.release();
    state = const HiitTrackerState();
  }
}
