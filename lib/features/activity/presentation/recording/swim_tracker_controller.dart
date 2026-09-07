import 'dart:async';

import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/presentation/recording/tracker_screen_awake.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swim_tracker_controller.g.dart';

class SwimTrackerState {
  const SwimTrackerState({
    this.isActive = false,
    this.startedAt,
    this.lastInteractionAt,
    this.elapsedDuration = Duration.zero,
    this.poolLengthMeters = 25.0,
    this.stroke = 'Freestyle',
    this.laps = 0,
    this.savedActivityId,
  });

  final bool isActive;
  final DateTime? startedAt;

  /// UTC time of the last thing the user actually did (a lap logged, the
  /// pool length or stroke changed). Not touched by the ticker - a swim left
  /// open on screen accrues [elapsedDuration] but no interactions, which is
  /// exactly what `domain/session_duration.dart`'s `sessionLooksAbandoned`
  /// reads to stop an abandoned session recording the whole gap.
  final DateTime? lastInteractionAt;

  /// Wall-clock time since [startedAt], including any time the swim was left
  /// open untouched. Honest for a session the user is swimming through,
  /// misleading for one left running - see [lastInteractionAt].
  final Duration elapsedDuration;
  final double poolLengthMeters;
  final String stroke;
  final int laps;
  final String? savedActivityId;

  double get totalDistanceMeters => laps * poolLengthMeters;

  SwimTrackerState copyWith({
    bool? isActive,
    DateTime? startedAt,
    DateTime? lastInteractionAt,
    Duration? elapsedDuration,
    double? poolLengthMeters,
    String? stroke,
    int? laps,
    String? savedActivityId,
  }) {
    return SwimTrackerState(
      isActive: isActive ?? this.isActive,
      startedAt: startedAt ?? this.startedAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      poolLengthMeters: poolLengthMeters ?? this.poolLengthMeters,
      stroke: stroke ?? this.stroke,
      laps: laps ?? this.laps,
      savedActivityId: savedActivityId ?? this.savedActivityId,
    );
  }
}

/// Global, persistent controller for live Swim tracking.
///
/// `keepAlive: true` deliberately — a swim must survive the user leaving
/// `swim_tracker_screen.dart` (the active-workout banner resumes it from any
/// tab); only [finishWorkout] or [discardWorkout] end it. A plain `@riverpod`
/// would be autoDispose and would drop the lap tally and ticker the moment
/// the screen popped.
@Riverpod(keepAlive: true)
class SwimTrackerController extends _$SwimTrackerController {
  Timer? _ticker;

  /// The screen lock, honouring the Swim hub's "Keep screen awake" switch
  /// — including a change made while a swim is in progress.
  late final TrackerScreenAwake _screenAwake = TrackerScreenAwake(ref);

  @override
  SwimTrackerState build() {
    ref.onDispose(() {
      _ticker?.cancel();
      _screenAwake.release();
    });
    return const SwimTrackerState();
  }

  void startWorkoutIfNeeded() {
    if (state.isActive) return;
    final now = DateTime.now().toUtc();
    state = SwimTrackerState(
      isActive: true,
      startedAt: now,
      lastInteractionAt: now,
    );
    _screenAwake.acquireFor(ActivityType.swim);
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// Stamps "the user just did something" onto the session.
  ///
  /// Deliberately NOT called from [_tick]: a swim sitting on screen with no
  /// lap/pool/stroke change for 20+ minutes is the abandonment case, not
  /// evidence of swimming. See [SwimTrackerState.lastInteractionAt].
  void _markInteraction() {
    if (!state.isActive) return;
    state = state.copyWith(lastInteractionAt: DateTime.now().toUtc());
  }

  void _tick() {
    if (!state.isActive || state.startedAt == null) return;
    final now = DateTime.now().toUtc();
    state = state.copyWith(
      elapsedDuration: now.difference(state.startedAt!),
    );
  }

  void setPoolLength(double meters) {
    _markInteraction();
    state = state.copyWith(poolLengthMeters: meters);
  }

  void setStroke(String stroke) {
    _markInteraction();
    state = state.copyWith(stroke: stroke);
  }

  void incrementLap() {
    _markInteraction();
    state = state.copyWith(laps: state.laps + 1);
  }

  void decrementLap() {
    if (state.laps > 0) {
      _markInteraction();
      state = state.copyWith(laps: state.laps - 1);
    }
  }

  /// Finishes and persists the swim.
  ///
  /// [elapsedOverride] records that duration instead of the wall-clock
  /// [SwimTrackerState.elapsedDuration] - the screen passes it when the user
  /// has been asked about a long idle gap and chose to record only the time
  /// up to their last interaction (see `domain/session_duration.dart`).
  /// Nothing else may shorten the duration on the user's behalf.
  Future<Activity?> finishWorkout({Duration? elapsedOverride}) async {
    if (!state.isActive || state.startedAt == null) return null;
    _ticker?.cancel();
    // Released before the write, not after it: the swim is over either
    // way, and a save that throws must not leave the lock held.
    _screenAwake.release();

    final now = DateTime.now().toUtc();
    final elapsed = elapsedOverride ?? state.elapsedDuration;

    final details = SwimWorkoutDetails(
      poolLengthMeters: state.poolLengthMeters,
      laps: state.laps,
      stroke: state.stroke,
    );

    final activity = Activity(
      id: EntityId.generate(),
      activityType: ActivityType.swim,
      title: 'Swim Workout',
      startedAt: state.startedAt!,
      movingTime: elapsed,
      elapsedTime: elapsed,
      distanceMeters: state.totalDistanceMeters,
      source: ActivitySource.recorded,
      workoutDetails: details,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(activityRepositoryProvider).saveActivity(activity);

    state = const SwimTrackerState();
    return activity;
  }

  void discardWorkout() {
    _ticker?.cancel();
    _screenAwake.release();
    state = const SwimTrackerState();
  }
}
