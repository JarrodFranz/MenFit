import 'dart:async';

import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/presentation/recording/tracker_screen_awake.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mindful_tracker_controller.g.dart';

class MindfulTrackerState {
  const MindfulTrackerState({
    this.isActive = false,
    this.startedAt,
    this.lastInteractionAt,
    this.elapsedDuration = Duration.zero,
    this.activityType = ActivityType.yoga,
    this.style = 'Vinyasa',
    this.focusArea = 'Full Body Flow',
    this.rpe,
    this.notes = '',
    this.savedActivityId,
  });

  final bool isActive;
  final DateTime? startedAt;

  /// UTC time of the last thing the user actually did (style/focus/RPE/notes
  /// changed, or the session started). Not touched by the ticker - a session
  /// left open on screen accrues [elapsedDuration] but no interactions,
  /// which is exactly what `domain/session_duration.dart`'s
  /// `sessionLooksAbandoned` reads to stop an abandoned session recording
  /// the whole gap. Deliberately generous (see `mindfulIdleThreshold`) since
  /// sitting still for a long stretch is often the point of the practice.
  final DateTime? lastInteractionAt;

  /// Wall-clock time since [startedAt], including any time the session was
  /// left open untouched. Honest for a session the user is practising
  /// through, misleading for one left running - see [lastInteractionAt].
  final Duration elapsedDuration;
  final ActivityType activityType;
  final String style;
  final String focusArea;

  /// The RPE she has actually chosen, or `null` while the slider has
  /// never been touched. Starts unset so an untouched session stores no
  /// exertion at all rather than a fabricated 6 — see
  /// `activity/domain/workout_details.dart`'s `MindfulWorkoutDetails.rpe`.
  final int? rpe;
  final String notes;
  final String? savedActivityId;

  MindfulTrackerState copyWith({
    bool? isActive,
    DateTime? startedAt,
    DateTime? lastInteractionAt,
    Duration? elapsedDuration,
    ActivityType? activityType,
    String? style,
    String? focusArea,
    int? rpe,
    String? notes,
    String? savedActivityId,
  }) {
    return MindfulTrackerState(
      isActive: isActive ?? this.isActive,
      startedAt: startedAt ?? this.startedAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      activityType: activityType ?? this.activityType,
      style: style ?? this.style,
      focusArea: focusArea ?? this.focusArea,
      rpe: rpe ?? this.rpe,
      notes: notes ?? this.notes,
      savedActivityId: savedActivityId ?? this.savedActivityId,
    );
  }
}

/// Global, persistent controller for live Yoga/Pilates tracking.
///
/// `keepAlive: true` deliberately — a session must survive the user leaving
/// `mindful_tracker_screen.dart` (the active-workout banner resumes it from
/// any tab); only [finishSession] or [discardSession] end it. A plain
/// `@riverpod` would be autoDispose and would drop the session, its ticker
/// and the notes typed so far the moment the screen popped.
@Riverpod(keepAlive: true)
class MindfulTrackerController extends _$MindfulTrackerController {
  Timer? _ticker;

  /// The screen lock, honouring the hub switch of whichever type the
  /// session is — Yoga and Pilates each have their own — including a
  /// change made while the session is running.
  late final TrackerScreenAwake _screenAwake = TrackerScreenAwake(ref);

  @override
  MindfulTrackerState build() {
    ref.onDispose(() {
      _ticker?.cancel();
      _screenAwake.release();
    });
    return const MindfulTrackerState();
  }

  void startSessionIfNeeded(ActivityType type) {
    if (state.isActive) return;
    final now = DateTime.now().toUtc();
    final defaultStyle = type == ActivityType.pilates
        ? 'Mat Pilates'
        : 'Vinyasa';
    final defaultArea = type == ActivityType.pilates
        ? 'Core & Pelvic Floor'
        : 'Full Body Flow';

    state = MindfulTrackerState(
      isActive: true,
      startedAt: now,
      lastInteractionAt: now,
      activityType: type,
      style: defaultStyle,
      focusArea: defaultArea,
    );

    _screenAwake.acquireFor(type);
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// Stamps "the user just did something" onto the session.
  ///
  /// Deliberately NOT called from [_tick]: a session sitting on screen with
  /// no style/focus/RPE/notes change is ambiguous between abandoned and a
  /// long, legitimately still practice - `mindfulIdleThreshold` in
  /// `domain/session_duration.dart` is sized to tell those apart. See
  /// [MindfulTrackerState.lastInteractionAt].
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

  void setStyle(String style) {
    _markInteraction();
    state = state.copyWith(style: style);
  }

  void setFocusArea(String area) {
    _markInteraction();
    state = state.copyWith(focusArea: area);
  }

  void setRpe(int rpe) {
    _markInteraction();
    state = state.copyWith(rpe: rpe);
  }

  void setNotes(String notes) {
    _markInteraction();
    state = state.copyWith(notes: notes);
  }

  /// Finishes and persists the session.
  ///
  /// [elapsedOverride] records that duration instead of the wall-clock
  /// [MindfulTrackerState.elapsedDuration] - the screen passes it when the
  /// user has been asked about a long idle gap and chose to record only the
  /// time up to their last interaction (see `domain/session_duration.dart`).
  /// Nothing else may shorten the duration on the user's behalf.
  Future<Activity?> finishSession({Duration? elapsedOverride}) async {
    if (!state.isActive || state.startedAt == null) return null;
    _ticker?.cancel();
    // Released before the write, not after it: the session is over either
    // way, and a save that throws must not leave the lock held.
    _screenAwake.release();

    final now = DateTime.now().toUtc();
    final elapsed = elapsedOverride ?? state.elapsedDuration;

    final details = MindfulWorkoutDetails(
      style: state.style,
      focusArea: state.focusArea,
      rpe: state.rpe,
      notes: state.notes.trim(),
    );

    final activity = Activity(
      id: EntityId.generate(),
      activityType: state.activityType,
      title: '${state.style} ${state.activityType.label}',
      startedAt: state.startedAt!,
      movingTime: elapsed,
      elapsedTime: elapsed,
      distanceMeters: 0,
      source: ActivitySource.recorded,
      workoutDetails: details,
      notes: state.notes.trim().isNotEmpty ? state.notes.trim() : null,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(activityRepositoryProvider).saveActivity(activity);

    state = const MindfulTrackerState();
    return activity;
  }

  void discardSession() {
    _ticker?.cancel();
    _screenAwake.release();
    state = const MindfulTrackerState();
  }
}
