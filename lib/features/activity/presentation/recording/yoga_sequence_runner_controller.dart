import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_sound.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';
import 'package:menfit_app/features/activity/presentation/recording/tracker_screen_awake.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'yoga_sequence_runner_controller.g.dart';

/// Where a practice is in the sequence.
///
/// [paused] replaces the underlying phase rather than sitting beside it, so
/// no surface can render "holding Warrior II" while the countdown is
/// stopped; the phase to come back to is kept in
/// [YogaRunnerState.pausedPhase].
enum YogaRunPhase { idle, pose, transition, paused, complete }

/// A live run of one [YogaSequence].
///
/// Plain immutable class with a hand-written `copyWith`, matching
/// `HiitTrackerState` and `MindfulTrackerState` — the trackers in this
/// folder are deliberately uniform, and freezed buys nothing for a state
/// object that is never serialised.
@immutable
class YogaRunnerState {
  const YogaRunnerState({
    this.sequence,
    this.phase = YogaRunPhase.idle,
    this.pausedPhase,
    this.poseIndex = 0,
    this.phaseEndsAt,
    this.phaseDuration = Duration.zero,
    this.phaseRemaining = Duration.zero,
    this.pausedRemaining,
    this.startedAt,
    this.practisedTime = Duration.zero,
    this.elapsedTime = Duration.zero,
    this.soundMuted = false,
    this.catchUpOccurred = false,
  });

  /// The sequence being practised, or null when nothing is running.
  final YogaSequence? sequence;

  final YogaRunPhase phase;

  /// The phase `resume()` returns to. Non-null only while [phase] is
  /// [YogaRunPhase.paused].
  final YogaRunPhase? pausedPhase;

  /// Index of the pose being held, or — during [YogaRunPhase.transition] —
  /// of the pose that just ended. The pose being moved *into* is always
  /// [nextPose].
  final int poseIndex;

  /// UTC instant the current phase runs out. Null while paused, idle or
  /// complete. The single source of truth for the countdown: the ticker
  /// recomputes from it and never counts its own ticks, so a throttled or
  /// missed tick cannot make the sequence drift.
  final DateTime? phaseEndsAt;

  /// Full length of the current phase, for the countdown ring.
  final Duration phaseDuration;

  /// What is left of the current phase as of the last tick.
  final Duration phaseRemaining;

  /// What was left of the phase when `pause()` was pressed. Non-null
  /// only while paused.
  final Duration? pausedRemaining;

  final DateTime? startedAt;

  /// Time actually spent **holding poses**: transitions, pauses and the
  /// remainder of a pose they skipped out of are all excluded.
  ///
  /// This is what reaches `Activity.movingTime`, with wall-clock
  /// [elapsedTime] as `elapsedTime` — the same moving/elapsed split a run
  /// gets, where the gaps between efforts are real time that is not effort.
  final Duration practisedTime;

  /// Wall clock since [startedAt], pauses included.
  final Duration elapsedTime;

  /// Session-level chime mute. Independent of the Settings "Sound cues"
  /// preference: this one is "not right now", that one is "not ever", and
  /// either silences the chime.
  final bool soundMuted;

  /// True when the last tick crossed **more than one** phase boundary —
  /// the screen was locked, or the isolate was suspended, long enough to
  /// swallow whole poses.
  ///
  /// The state is snapped to the right phase in one step, so the UI sees a
  /// single change and fires a single cue rather than a burst of chimes
  /// for boundaries that went by unheard (ADR 014 §3).
  final bool catchUpOccurred;

  /// Whether a practice is on screen-resumable: running, transitioning or
  /// paused. Idle and complete are not — complete still has a sequence, but
  /// there is nothing left to resume into.
  bool get isActive =>
      phase == YogaRunPhase.pose ||
      phase == YogaRunPhase.transition ||
      phase == YogaRunPhase.paused;

  List<YogaPose> get _poses => sequence?.poses ?? const [];

  /// The pose being held, or the one that just ended during a transition.
  YogaPose? get currentPose =>
      poseIndex >= 0 && poseIndex < _poses.length ? _poses[poseIndex] : null;

  /// The pose after [currentPose], or null on the last one.
  YogaPose? get nextPose =>
      poseIndex + 1 < _poses.length ? _poses[poseIndex + 1] : null;

  /// Whether the practice is between poses — including while paused in the
  /// middle of a transition, which is still a transition.
  bool get isTransitioning =>
      phase == YogaRunPhase.transition ||
      pausedPhase == YogaRunPhase.transition;

  /// The pose every surface should name right now.
  ///
  /// During a transition that is the pose they are moving *into*: [poseIndex]
  /// still points at the one that ended, so naming [currentPose] there tells
  /// them to hold a pose they have already left. The runner screen and the
  /// active-workout banner both read this, so they cannot disagree.
  YogaPose? get displayPose => isTransitioning ? nextPose : currentPose;

  /// Human position of [currentPose] in the sequence, 1-based.
  int get poseNumber => poseIndex + 1;

  int get poseCount => _poses.length;

  /// Fraction of the current phase still to run, 1 → 0, for the ring.
  double get phaseFractionRemaining {
    final total = phaseDuration.inMilliseconds;
    if (total <= 0) return 0;
    final left = phaseRemaining.inMilliseconds / total;
    return left.clamp(0.0, 1.0);
  }

  YogaRunnerState copyWith({
    YogaSequence? sequence,
    YogaRunPhase? phase,
    YogaRunPhase? pausedPhase,
    int? poseIndex,
    DateTime? phaseEndsAt,
    Duration? phaseDuration,
    Duration? phaseRemaining,
    Duration? pausedRemaining,
    DateTime? startedAt,
    Duration? practisedTime,
    Duration? elapsedTime,
    bool? soundMuted,
    bool? catchUpOccurred,
    bool clearPhaseEndsAt = false,
    bool clearPausedRemaining = false,
    bool clearPausedPhase = false,
  }) {
    return YogaRunnerState(
      sequence: sequence ?? this.sequence,
      phase: phase ?? this.phase,
      pausedPhase: clearPausedPhase ? null : (pausedPhase ?? this.pausedPhase),
      poseIndex: poseIndex ?? this.poseIndex,
      phaseEndsAt: clearPhaseEndsAt ? null : (phaseEndsAt ?? this.phaseEndsAt),
      phaseDuration: phaseDuration ?? this.phaseDuration,
      phaseRemaining: phaseRemaining ?? this.phaseRemaining,
      pausedRemaining: clearPausedRemaining
          ? null
          : (pausedRemaining ?? this.pausedRemaining),
      startedAt: startedAt ?? this.startedAt,
      practisedTime: practisedTime ?? this.practisedTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      soundMuted: soundMuted ?? this.soundMuted,
      catchUpOccurred: catchUpOccurred ?? this.catchUpOccurred,
    );
  }
}

/// Runs a saved [YogaSequence] pose by pose, on the wall clock.
///
/// `keepAlive: true` for the same reason as every other tracker here: the
/// practice must survive the user leaving `yoga_sequence_runner_screen.dart`
/// (the active-workout banner resumes it from any tab). Only [finish] or
/// [discard] end it.
///
/// **Nothing in here logs.** Pose and sequence names are activity data
/// (S1, `knowledge/engineering/security_and_privacy.md`).
@Riverpod(keepAlive: true)
class YogaSequenceRunnerController extends _$YogaSequenceRunnerController {
  Timer? _ticker;

  /// UTC instant [YogaRunnerState.practisedTime] has been counted up to.
  /// Only advances while a pose is being held.
  DateTime? _accruedTo;

  /// The screen lock, honouring the Yoga hub's "Keep screen awake" switch
  /// — including a change made while a practice is already running.
  late final TrackerScreenAwake _screenAwake = TrackerScreenAwake(ref);

  /// True from the moment [finish] starts writing until the write settles.
  ///
  /// A save is one `await` long and the button that starts it stays on
  /// screen for all of it; without this a double tap writes the practice
  /// twice, under two ids, and both rows survive.
  bool _saving = false;

  /// Whether the one-second ticker is running.
  ///
  /// A test seam: the ticker is the thing that must stop at [finish] and at
  /// the end of the sequence, and nothing else about the state says whether
  /// it did.
  @visibleForTesting
  bool get isTicking => _ticker?.isActive ?? false;

  /// Time source for the phase machine.
  ///
  /// Injectable for the same reason as `StepsSync.clock`: with
  /// `DateTime.now` hard-coded, a test can watch a second tick by but never
  /// a three-minute suspension, so the catch-up branch — the one that only
  /// ever runs on a real locked phone — would be the one branch no test
  /// could reach.
  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  @override
  YogaRunnerState build() {
    ref.onDispose(() {
      _ticker?.cancel();
      _screenAwake.release();
    });
    return const YogaRunnerState();
  }

  DateTime get _now => clock().toUtc();

  /// Begins [sequence] from its first pose, replacing anything already
  /// running.
  ///
  /// Deliberately synchronous and deliberately *not* awaiting the preload:
  /// browsers only allow audio that a user gesture led to, and the gesture
  /// that counts is the one still on the call stack. Called straight from
  /// the Start button's `onPressed`, `preload()` is issued inside the
  /// gesture; awaited first, the first chime would be silently dropped.
  void start(YogaSequence sequence) {
    if (sequence.poses.isEmpty) return;

    // Whatever was running is over as of this call, so its ticker goes
    // with it.
    _ticker?.cancel();

    unawaited(AccessibilitySound.preloadFor(ref));
    _screenAwake.acquireFor(ActivityType.yoga);

    final now = _now;
    _accruedTo = now;
    state = _enterPose(
      YogaRunnerState(
        sequence: sequence,
        startedAt: now,
        soundMuted: state.soundMuted,
      ),
      0,
      now,
    );
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  /// Stops the countdown once the sequence has run out.
  ///
  /// [YogaRunPhase.complete] has no `phaseEndsAt`, so every further tick is
  /// a no-op that still wakes the isolate once a second while the Save
  /// screen sits there. `skipBack` out of complete starts it again.
  void _stopTickerIfComplete() {
    if (state.phase == YogaRunPhase.complete) _stopTicker();
  }

  /// Recomputes the phase from the clock.
  ///
  /// The ticker's only job, and public so a test can move the injected
  /// [clock] and step the machine without waiting on real time.
  @visibleForTesting
  void tick() {
    final current = state;
    if (current.sequence == null || current.startedAt == null) return;
    final now = _now;

    if (current.phase == YogaRunPhase.paused) {
      state = current.copyWith(elapsedTime: now.difference(current.startedAt!));
      return;
    }
    if (current.phase != YogaRunPhase.pose &&
        current.phase != YogaRunPhase.transition) {
      return;
    }

    // Every boundary that has already gone by is crossed here, in one
    // assignment to `state`, so listeners see a single change however many
    // poses the suspension swallowed (ADR 014 §3).
    var next = current;
    var practised = current.practisedTime;
    var accruedTo = _accruedTo ?? now;
    var boundaries = 0;

    while ((next.phase == YogaRunPhase.pose ||
            next.phase == YogaRunPhase.transition) &&
        next.phaseEndsAt != null &&
        !next.phaseEndsAt!.isAfter(now)) {
      final boundary = next.phaseEndsAt!;
      if (next.phase == YogaRunPhase.pose && boundary.isAfter(accruedTo)) {
        practised += boundary.difference(accruedTo);
      }
      accruedTo = boundary;
      next = _advanceAt(next, boundary);
      boundaries++;
    }

    if (next.phase == YogaRunPhase.pose && now.isAfter(accruedTo)) {
      practised += now.difference(accruedTo);
    }
    _accruedTo = now;

    state = next.copyWith(
      practisedTime: practised,
      elapsedTime: now.difference(current.startedAt!),
      phaseRemaining: _remainingAt(next, now),
      catchUpOccurred: boundaries > 1,
    );
    _stopTickerIfComplete();
  }

  /// The phase that follows [s] when its current one ends at [boundary].
  ///
  /// Anchored to the boundary rather than to "now" so a late tick does not
  /// stretch the sequence: each phase still starts where the schedule said
  /// it would.
  YogaRunnerState _advanceAt(YogaRunnerState s, DateTime boundary) {
    final sequence = s.sequence!;
    switch (s.phase) {
      case YogaRunPhase.pose:
        // No transition after the last pose, and none at all in a
        // single-pose sequence — YogaSequence.totalDuration counts the same
        // way.
        if (s.poseIndex >= sequence.poses.length - 1) return _complete(s);
        if (sequence.transitionSeconds <= 0) {
          return _enterPose(s, s.poseIndex + 1, boundary);
        }
        return _enterTransition(s, boundary);
      case YogaRunPhase.transition:
        return _enterPose(s, s.poseIndex + 1, boundary);
      case YogaRunPhase.idle:
      case YogaRunPhase.paused:
      case YogaRunPhase.complete:
        return s;
    }
  }

  YogaRunnerState _enterPose(YogaRunnerState s, int index, DateTime at) {
    // A hold below a second would make the catch-up loop unbounded; the
    // editor enforces `minPoseHoldSeconds`, this guards a row written by a
    // future version that does not.
    final seconds = math.max(1, s.sequence!.poses[index].holdSeconds);
    final duration = Duration(seconds: seconds);
    return s.copyWith(
      phase: YogaRunPhase.pose,
      poseIndex: index,
      phaseDuration: duration,
      phaseRemaining: duration,
      phaseEndsAt: at.add(duration),
      clearPausedRemaining: true,
      clearPausedPhase: true,
      catchUpOccurred: false,
    );
  }

  YogaRunnerState _enterTransition(YogaRunnerState s, DateTime at) {
    final duration = Duration(
      seconds: math.max(1, s.sequence!.transitionSeconds),
    );
    return s.copyWith(
      phase: YogaRunPhase.transition,
      phaseDuration: duration,
      phaseRemaining: duration,
      phaseEndsAt: at.add(duration),
      clearPausedRemaining: true,
      clearPausedPhase: true,
      catchUpOccurred: false,
    );
  }

  YogaRunnerState _complete(YogaRunnerState s) {
    return s.copyWith(
      phase: YogaRunPhase.complete,
      phaseRemaining: Duration.zero,
      clearPhaseEndsAt: true,
      clearPausedRemaining: true,
      clearPausedPhase: true,
      catchUpOccurred: false,
    );
  }

  Duration _remainingAt(YogaRunnerState s, DateTime now) {
    final endsAt = s.phaseEndsAt;
    if (endsAt == null) return Duration.zero;
    final left = endsAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  /// Stops the countdown, keeping the practice resumable.
  void pause() {
    final current = state;
    if (current.phase != YogaRunPhase.pose &&
        current.phase != YogaRunPhase.transition) {
      return;
    }
    final now = _now;
    state = _pausedFrom(current, now).copyWith(
      practisedTime: _accruedThrough(current, now),
      elapsedTime: now.difference(current.startedAt!),
    );
    _accruedTo = now;
  }

  /// Re-anchors the current phase to now and starts counting again.
  void resume() {
    final current = state;
    if (current.phase != YogaRunPhase.paused) return;
    final now = _now;
    final remaining = current.pausedRemaining ?? Duration.zero;
    _accruedTo = now;
    state = current.copyWith(
      phase: current.pausedPhase ?? YogaRunPhase.pose,
      phaseEndsAt: now.add(remaining),
      phaseRemaining: remaining,
      elapsedTime: now.difference(current.startedAt!),
      clearPausedRemaining: true,
      clearPausedPhase: true,
      catchUpOccurred: false,
    );
    _startTicker();
  }

  /// Ends the current phase now and moves to the next one.
  ///
  /// The unspent remainder of a skipped pose is **not** credited to
  /// [YogaRunnerState.practisedTime] — the point of recording practised
  /// time is that it is time they practised.
  void skipForward() {
    final current = state;
    if (!current.isActive) return;
    final now = _now;
    final running = _runningPhaseOf(current);
    state = _reapplyPause(
      current,
      _advanceAt(running, now).copyWith(
        practisedTime: _accruedThrough(current, now),
        elapsedTime: now.difference(current.startedAt!),
      ),
      now,
    );
    _accruedTo = now;
    _stopTickerIfComplete();
  }

  /// Goes back one step: to the top of the current pose from a transition
  /// or from the first pose, to the previous pose otherwise, and back into
  /// the last pose from [YogaRunPhase.complete].
  void skipBack() {
    final current = state;
    if (current.phase == YogaRunPhase.idle || current.sequence == null) return;
    final now = _now;
    final running = _runningPhaseOf(current);

    final target = switch (running.phase) {
      YogaRunPhase.transition => running.poseIndex,
      YogaRunPhase.complete => running.poseIndex,
      _ => running.poseIndex > 0 ? running.poseIndex - 1 : 0,
    };

    final resumed = _enterPose(running, target, now).copyWith(
      practisedTime: _accruedThrough(current, now),
      elapsedTime: now.difference(current.startedAt!),
    );
    state = _reapplyPause(current, resumed, now);
    _accruedTo = now;
    if (current.phase == YogaRunPhase.complete) _startTicker();
  }

  /// Silences the chime for this practice only.
  void toggleMute() {
    state = state.copyWith(soundMuted: !state.soundMuted);
  }

  /// Saves the practice as a yoga [Activity] and clears the runner.
  ///
  /// `movingTime` is the practised time (holds only), `elapsedTime` the
  /// wall clock. RPE is left null — they were never asked — and the pose list
  /// is finally what `MindfulWorkoutDetails.poses` was always for.
  ///
  /// Returns null when there is nothing to save (or a save is already in
  /// flight), and **rethrows** whatever the repository threw. A failed
  /// write leaves the practice exactly as it was — same phase, same
  /// sequence, same practised time — so pressing Save again is a real
  /// second attempt rather than a lost session.
  static int _reachedPoseCount(YogaRunnerState current, YogaSequence sequence) {
    if (current.phase == YogaRunPhase.complete) return sequence.poses.length;
    return (current.poseIndex + 1).clamp(0, sequence.poses.length);
  }

  Future<Activity?> finish() async {
    final current = state;
    final sequence = current.sequence;
    final startedAt = current.startedAt;
    if (sequence == null || startedAt == null) return null;
    if (_saving) return null;
    _saving = true;

    _stopTicker();
    final now = _now;
    final practised = _accruedThrough(current, now);
    final elapsed = now.difference(startedAt);

    final details = MindfulWorkoutDetails(
      // Both left blank rather than defaulted when the sequence carries
      // none: an invented "Vinyasa" is indistinguishable from a chosen one,
      // the same trap `MindfulWorkoutDetails.rpe` documents.
      style: sequence.style ?? '',
      focusArea: '',
      // Only the poses they reached: a practice finished at pose 6 of 8
      // did not practise 8 poses (seen on device - the celebration said
      // so). A transition counts the pose it just left; complete = all.
      poses: sequence.poses
          .take(_reachedPoseCount(current, sequence))
          .map((pose) => pose.displayName)
          .toList(),
    );

    final name = sequence.name.trim();
    final activity = Activity(
      id: EntityId.generate(),
      activityType: ActivityType.yoga,
      title: name.isEmpty ? 'Yoga Sequence' : name,
      startedAt: startedAt,
      movingTime: practised,
      elapsedTime: elapsed,
      distanceMeters: 0,
      source: ActivitySource.recorded,
      workoutDetails: details,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await ref.read(activityRepositoryProvider).saveActivity(activity);
    } on Object catch (_) {
      // Nothing here logs the failure: the message that reaches the user is
      // `userMessageFor`'s, and the activity carries pose names (S1).
      //
      // A save attempted mid-practice leaves it running — the countdown
      // starts again and the screen stays awake, because they are still on
      // the mat. One attempted at the end has nothing left to count, so the
      // lock goes: the practice is over either way and an unreleased
      // wakelock is a flat battery.
      if (state.phase == YogaRunPhase.pose ||
          state.phase == YogaRunPhase.transition) {
        _startTicker();
      } else {
        _screenAwake.release();
      }
      rethrow;
    } finally {
      _saving = false;
    }

    _reset();
    return activity;
  }

  /// Abandons the practice without saving anything.
  void discard() => _reset();

  void _reset() {
    _stopTicker();
    _accruedTo = null;
    _screenAwake.release();
    state = YogaRunnerState(soundMuted: state.soundMuted);
  }

  /// [s] as it would be if it were not paused, so one phase machine serves
  /// both cases.
  YogaRunnerState _runningPhaseOf(YogaRunnerState s) {
    if (s.phase != YogaRunPhase.paused) return s;
    return s.copyWith(
      phase: s.pausedPhase ?? YogaRunPhase.pose,
      phaseRemaining: s.pausedRemaining ?? Duration.zero,
      clearPausedPhase: true,
      clearPausedRemaining: true,
    );
  }

  /// Puts [next] back into a paused state when [before] was paused, so a
  /// skip taken while paused lands on the new phase and stays stopped.
  YogaRunnerState _reapplyPause(
    YogaRunnerState before,
    YogaRunnerState next,
    DateTime now,
  ) {
    if (before.phase != YogaRunPhase.paused) return next;
    if (next.phase == YogaRunPhase.complete) return next;
    return _pausedFrom(next, now);
  }

  YogaRunnerState _pausedFrom(YogaRunnerState s, DateTime now) {
    final remaining = _remainingAt(s, now);
    return s.copyWith(
      phase: YogaRunPhase.paused,
      pausedPhase: s.phase,
      pausedRemaining: remaining,
      phaseRemaining: remaining,
      clearPhaseEndsAt: true,
      catchUpOccurred: false,
    );
  }

  /// [s]'s practised time brought up to [now], counting only a pose that is
  /// currently being held.
  Duration _accruedThrough(YogaRunnerState s, DateTime now) {
    final from = _accruedTo;
    if (s.phase != YogaRunPhase.pose || from == null || !now.isAfter(from)) {
      return s.practisedTime;
    }
    return s.practisedTime + now.difference(from);
  }
}
