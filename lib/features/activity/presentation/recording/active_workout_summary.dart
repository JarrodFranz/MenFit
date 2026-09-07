import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/recording/hiit_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/mindful_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/recording_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/strength_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/swim_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/yoga_sequence_runner_controller.dart';

/// Lightweight summary model representing any active, in-progress workout
/// session.
class ActiveWorkoutSummary {
  const ActiveWorkoutSummary({
    required this.activityType,
    required this.title,
    required this.elapsedDuration,
    required this.keyMetricLabel,
    required this.routePath,
    this.isPaused = false,
  });

  final ActivityType activityType;
  final String title;
  final Duration elapsedDuration;
  final String keyMetricLabel;
  final String routePath;
  final bool isPaused;
}

/// Global provider watching all active tracker controllers and emitting
/// an [ActiveWorkoutSummary] if any live session is currently in progress.
final activeWorkoutSummaryProvider = Provider<ActiveWorkoutSummary?>((ref) {
  // 1. Check GPS Live Recording
  final recordingState = ref.watch(recordingControllerProvider);
  final isGpsActive =
      recordingState.lifecycle == RecordingLifecycle.recording ||
      recordingState.lifecycle == RecordingLifecycle.paused ||
      recordingState.lifecycle == RecordingLifecycle.autoPaused ||
      recordingState.lifecycle == RecordingLifecycle.waitingForSignal;

  if (isGpsActive) {
    final type = recordingState.activityType ?? ActivityType.run;
    final km = (recordingState.distanceMeters / 1000).toStringAsFixed(2);
    return ActiveWorkoutSummary(
      activityType: type,
      title: 'GPS ${type.label}',
      elapsedDuration: recordingState.elapsedTime,
      keyMetricLabel: '$km km',
      routePath: '/activity/record',
      isPaused:
          recordingState.lifecycle == RecordingLifecycle.paused ||
          recordingState.lifecycle == RecordingLifecycle.autoPaused,
    );
  }

  // 2. Check Strength Tracker
  final strengthState = ref.watch(strengthTrackerControllerProvider);
  if (strengthState.isActive) {
    final sets = strengthState.totalCompletedSets;
    final vol = strengthState.totalVolumeKg.toStringAsFixed(0);
    return ActiveWorkoutSummary(
      activityType: ActivityType.strength,
      title: 'Strength Workout',
      elapsedDuration: strengthState.elapsedDuration,
      keyMetricLabel: '$sets sets · $vol kg',
      routePath: '/activity/track/strength',
    );
  }

  // 3. Check HIIT Tracker
  final hiitState = ref.watch(hiitTrackerControllerProvider);
  if (hiitState.isActive) {
    final round = hiitState.currentRound;
    final total = hiitState.totalRounds;
    final phase = switch (hiitState.currentPhase) {
      HiitPhase.warmup => 'Warmup',
      HiitPhase.work => 'Work',
      HiitPhase.rest => 'Rest',
      HiitPhase.complete => 'Done',
    };
    return ActiveWorkoutSummary(
      activityType: ActivityType.hiit,
      title: 'HIIT Workout',
      elapsedDuration: Duration(seconds: hiitState.totalElapsedSeconds),
      keyMetricLabel: 'Round $round/$total · $phase',
      routePath: '/activity/track/hiit',
      isPaused: !hiitState.isRunning,
    );
  }

  // 4. Check Mindful (Yoga / Pilates) Tracker
  final mindfulState = ref.watch(mindfulTrackerControllerProvider);
  if (mindfulState.isActive) {
    final typeLabel = mindfulState.activityType.label;
    final title =
        mindfulState.style.toLowerCase().contains(typeLabel.toLowerCase())
        ? mindfulState.style
        : '${mindfulState.style} $typeLabel';
    return ActiveWorkoutSummary(
      activityType: mindfulState.activityType,
      title: title,
      elapsedDuration: mindfulState.elapsedDuration,
      keyMetricLabel: mindfulState.focusArea,
      routePath: '/activity/track/mindful',
    );
  }

  // 5. Check Yoga Sequence Runner
  //
  // After the mindful tracker, not before it: the two cannot both be
  // active in practice, and the free-form yoga session is the older, more
  // common entry point, so it keeps its position in the order.
  final yogaRunnerState = ref.watch(yogaSequenceRunnerControllerProvider);
  final yogaSequence = yogaRunnerState.sequence;
  // `complete` counts here even though it is not `isActive`: a sequence
  // that ran out while they were on another tab is finished but *not saved*,
  // and dropping it from the banner would leave the only route back to the
  // Save button a lucky guess.
  final yogaFinished = yogaRunnerState.phase == YogaRunPhase.complete;
  if ((yogaRunnerState.isActive || yogaFinished) && yogaSequence != null) {
    return ActiveWorkoutSummary(
      activityType: ActivityType.yoga,
      title: 'Yoga sequence · ${yogaSequence.name}',
      elapsedDuration: yogaRunnerState.elapsedTime,
      keyMetricLabel: yogaFinished
          ? 'Ready to save'
          // `displayPose`, not `currentPose`: mid-transition the banner
          // must name the pose they are moving into, exactly as the runner
          // screen does.
          : (yogaRunnerState.displayPose?.displayName ?? ''),
      routePath: '/activity/track/yoga-sequence/${yogaSequence.id}',
      isPaused: yogaRunnerState.phase == YogaRunPhase.paused,
    );
  }

  // 6. Check Swim Tracker
  final swimState = ref.watch(swimTrackerControllerProvider);
  if (swimState.isActive) {
    final laps = swimState.laps;
    final dist = swimState.totalDistanceMeters.toStringAsFixed(0);
    return ActiveWorkoutSummary(
      activityType: ActivityType.swim,
      title: 'Swim Workout',
      elapsedDuration: swimState.elapsedDuration,
      keyMetricLabel: '$laps laps · ${dist}m',
      routePath: '/activity/track/swim',
    );
  }

  return null;
});
