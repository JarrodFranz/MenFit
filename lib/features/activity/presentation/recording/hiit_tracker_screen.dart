import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_haptics.dart';
import 'package:menfit_app/features/activity/domain/milestone_evaluator.dart';
import 'package:menfit_app/features/activity/presentation/recording/hiit_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/widgets/workout_celebration_dialog.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/presentation/cycle_records_controller.dart';

/// Interactive HIIT Interval Tracker with high-contrast work/rest visual phases.
///
/// Backed by persistent [hiitTrackerControllerProvider] so interval countdowns
/// and round progression continue seamlessly when leaving the screen or
/// switching apps.
class HiitTrackerScreen extends ConsumerStatefulWidget {
  const HiitTrackerScreen({
    this.workSeconds = 30,
    this.restSeconds = 15,
    this.totalRounds = 8,
    super.key,
  });

  final int workSeconds;
  final int restSeconds;
  final int totalRounds;

  @override
  ConsumerState<HiitTrackerScreen> createState() => _HiitTrackerScreenState();
}

class _HiitTrackerScreenState extends ConsumerState<HiitTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(hiitTrackerControllerProvider.notifier)
          .startWorkoutIfNeeded(
            workSeconds: widget.workSeconds,
            restSeconds: widget.restSeconds,
            totalRounds: widget.totalRounds,
          );
    });
  }

  Future<void> _finishWorkout() async {
    final state = ref.read(hiitTrackerControllerProvider);
    final totalRounds = state.totalRounds;
    final completed = state.currentRound;
    final controller = ref.read(hiitTrackerControllerProvider.notifier);
    final cycleRecords =
        ref.read(cycleRecordsControllerProvider).value ?? const [];
    final today = LocalDate.today();
    final cyclePhase = cycleRecords.isEmpty
        ? CyclePhase.none
        : CyclePredictionEngine()
              .analyze(
                records: cycleRecords,
                today: today,
              )
              .currentPhase;

    final activity = await controller.finishWorkout();

    if (mounted && activity != null) {
      final milestones = const MilestoneEvaluator().evaluateGenericMilestones(
        newActivity: activity,
        customSubtitle: '$completed of $totalRounds intervals completed 🔥',
        phase: cyclePhase,
      );
      await WorkoutCelebrationDialog.show(
        context,
        activity: activity,
        milestones: milestones,
        phase: cyclePhase,
        primaryMetricLabel: 'Intervals',
        primaryMetricValue: '$completed / $totalRounds',
        onViewDetails: () {
          ActivityDetailRouteData(activity.id).go(context);
        },
        onDone: () {
          Navigator.of(context).maybePop();
        },
      );
    } else if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Color _getPhaseColor(HiitPhase phase) {
    return switch (phase) {
      HiitPhase.warmup => Colors.amber.shade700,
      HiitPhase.work => const Color(0xFFE64A19), // Deep energetic orange
      HiitPhase.rest => const Color(0xFF00897B), // Calming teal
      HiitPhase.complete => const Color(0xFF43A047), // Green
    };
  }

  String _getPhaseTitle(HiitPhase phase) {
    return switch (phase) {
      HiitPhase.warmup => 'GET READY',
      HiitPhase.work => 'WORK!',
      HiitPhase.rest => 'REST',
      HiitPhase.complete => 'WORKOUT COMPLETE!',
    };
  }

  /// Announces an interval boundary through the phone rather than the
  /// screen.
  ///
  /// This is the one place in the app where a haptic is load-bearing: mid
  /// burpee she is not looking at the countdown, and "WORK!" rendered in
  /// 48pt is invisible to her and to anyone using a screen reader. The
  /// pulse is the signal; the colour change is the redundant channel, not
  /// the other way round. Gated on the Haptic Feedback preference like
  /// every other vibration (see [AccessibilityHaptics]).
  ///
  /// Driven from a phase *transition* rather than from the timer, so it
  /// fires exactly once per boundary however the boundary was reached —
  /// the ticker running out, or the user pressing skip.
  void _onPhaseChanged(HiitPhase? previous, HiitPhase next) {
    if (previous == null || previous == next) return;
    switch (next) {
      // Starting work, and finishing the session, are the boundaries that
      // have to cut through: heavy, matching the celebration convention.
      case HiitPhase.work:
      case HiitPhase.complete:
        unawaited(AccessibilityHaptics.heavyImpact(ref));
      // Going into rest is a release, not a call to action.
      case HiitPhase.rest:
        unawaited(AccessibilityHaptics.mediumImpact(ref));
      // Warm-up is entered by starting the workout, not by a transition
      // she needs telling about.
      case HiitPhase.warmup:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hiitTrackerControllerProvider);
    final controller = ref.read(hiitTrackerControllerProvider.notifier);

    ref.listen(hiitTrackerControllerProvider, (previous, next) {
      _onPhaseChanged(previous?.currentPhase, next.currentPhase);
    });

    final phaseColor = _getPhaseColor(state.currentPhase);

    return Scaffold(
      backgroundColor: phaseColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Minimize and keep workout active',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('HIIT Interval Workout'),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Finish'),
            onPressed: _finishWorkout,
          ),
        ],
      ),
      body: SafeArea(
        // Fills the viewport when it fits (spaceBetween centres the countdown)
        // and scrolls when large text or small screens make it taller -
        // preventing the ~47px RenderFlex overflow (deferred item 73).
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: _buildBody(context, ref, state, controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    HiitTrackerState state,
    HiitTrackerController controller,
  ) {
    final totalRounds = state.totalRounds;
    final currentRound = state.currentRound;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top Rounds Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            state.currentPhase == HiitPhase.complete
                ? 'All $totalRounds Rounds Done'
                : 'ROUND $currentRound OF $totalRounds',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),

        // Phase Title & Countdown Digits
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getPhaseTitle(state.currentPhase),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              if (state.currentPhase != HiitPhase.complete)
                Container(
                  width: 200,
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38, width: 8),
                  ),
                  child: Text(
                    '${state.phaseSecondsRemaining}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 84,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.emoji_events_outlined,
                  size: 120,
                  color: Colors.white,
                ),
            ],
          ),
        ),

        // Interval Progress Bar & Controls
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: totalRounds > 0 ? currentRound / totalRounds : 0,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                  minHeight: 10,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(bottom: 32, left: 32, right: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 44,
                    color: Colors.white,
                    icon: Icon(
                      state.isRunning ? Icons.pause_circle : Icons.play_circle,
                    ),
                    onPressed: controller.togglePlayPause,
                  ),
                  if (state.currentPhase != HiitPhase.complete)
                    IconButton(
                      iconSize: 44,
                      color: Colors.white,
                      tooltip: 'Skip to Next Interval',
                      icon: const Icon(Icons.skip_next_rounded),
                      onPressed: controller.skipPhase,
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
