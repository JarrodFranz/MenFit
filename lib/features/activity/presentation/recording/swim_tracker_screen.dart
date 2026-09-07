import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_haptics.dart';
import 'package:menfit_app/features/activity/domain/milestone_evaluator.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/domain/session_duration.dart';
import 'package:menfit_app/features/activity/presentation/recording/swim_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/widgets/workout_celebration_dialog.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/presentation/cycle_records_controller.dart';

/// Interactive swimming workout tracker with large lap tally controls and
/// pool math.
///
/// Backed by persistent [swimTrackerControllerProvider] so lap counts, pool
/// size, and elapsed swimming duration survive navigation across tabs and app
/// switching.
class SwimTrackerScreen extends ConsumerStatefulWidget {
  const SwimTrackerScreen({super.key});

  @override
  ConsumerState<SwimTrackerScreen> createState() => _SwimTrackerScreenState();
}

class _SwimTrackerScreenState extends ConsumerState<SwimTrackerScreen> {
  final List<double> _poolLengths = [25.0, 50.0, 22.86, 33.33];
  final List<String> _strokes = [
    'Freestyle',
    'Breaststroke',
    'Backstroke',
    'Butterfly',
    'Mixed / IM',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(swimTrackerControllerProvider.notifier).startWorkoutIfNeeded();
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  Future<void> _finishWorkout() async {
    final state = ref.read(swimTrackerControllerProvider);
    final startedAt = state.startedAt;

    // A swim left open (phone pocketed poolside, app backgrounded) keeps
    // accruing wall-clock elapsed time with no lap/pool/stroke change logged
    // into it. Saving that silently would misrecord the duration, so once
    // the gap is long enough to be ambiguous the user is asked rather than
    // guessed at - see `domain/session_duration.dart`.
    final looksAbandoned =
        startedAt != null &&
        sessionLooksAbandoned(
          startedAt: startedAt,
          now: DateTime.now().toUtc(),
          idleThreshold: swimIdleThreshold,
          lastInteractionAt: state.lastInteractionAt,
        );

    Duration? elapsedOverride;
    if (looksAbandoned) {
      final trimmed = elapsedToLastInteraction(
        startedAt: startedAt,
        lastInteractionAt: state.lastInteractionAt,
      );

      final choice = await showDialog<_SwimFinishChoice>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Finish Swim?'),
          content: Text(
            'Nothing has been logged for a while, so this swim may have '
            'been left running. Record the full time, or only the '
            '${formatDuration(trimmed)} up to your last logged change?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_SwimFinishChoice.keepSwimming),
              child: const Text('Keep Swimming'),
            ),
            TextButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_SwimFinishChoice.saveToLastInteraction),
              child: Text('Save ${formatDuration(trimmed)}'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_SwimFinishChoice.saveFull),
              child: Text('Save ${formatDuration(state.elapsedDuration)}'),
            ),
          ],
        ),
      );

      if (choice == null ||
          choice == _SwimFinishChoice.keepSwimming ||
          !mounted) {
        return;
      }
      elapsedOverride = choice == _SwimFinishChoice.saveToLastInteraction
          ? trimmed
          : null;
    }

    final laps = state.laps;
    final dist = state.totalDistanceMeters;
    final controller = ref.read(swimTrackerControllerProvider.notifier);
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

    final activity = await controller.finishWorkout(
      elapsedOverride: elapsedOverride,
    );

    if (mounted && activity != null) {
      final milestones = const MilestoneEvaluator().evaluateGenericMilestones(
        newActivity: activity,
        customSubtitle:
            '$laps laps completed (${dist.toStringAsFixed(0)} m) 🏊‍♀️',
        phase: cyclePhase,
      );
      await WorkoutCelebrationDialog.show(
        context,
        activity: activity,
        milestones: milestones,
        phase: cyclePhase,
        primaryMetricLabel: 'Laps',
        primaryMetricValue: '$laps laps',
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(swimTrackerControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF006064), // Deep marine cyan
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Minimize and keep swim active',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Swim Tracker'),
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
        // Fills the viewport when it fits (spaceBetween centres the lap
        // button) and scrolls once large text makes it taller - the audit had
        // it overflowing the bottom by 37-47px at 150%+. Deliberately NOT
        // IntrinsicHeight + Spacer: InputDecorator under-reports its
        // intrinsic height at large scales, which left the column 37px short.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: _buildBody(context, ref, state),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    SwimTrackerState state,
  ) {
    final controller = ref.read(swimTrackerControllerProvider.notifier);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            // Pool & Stroke Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      key: ValueKey('poolLength-${state.poolLengthMeters}'),
                      initialValue: state.poolLengthMeters,
                      // Without isExpanded the button sizes itself to its
                      // widest item + arrow and overflows the Expanded column
                      // at default settings on a 320dp phone (4-144px in the
                      // a11y audit). Expanded + ellipsis lets it yield.
                      isExpanded: true,
                      dropdownColor: const Color(0xFF004D40),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Pool Length',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                      ),
                      items: _poolLengths.map((len) {
                        final isInt = len.truncateToDouble() == len;
                        final label = len == 22.86
                            ? '25 yards'
                            : '${len.toStringAsFixed(isInt ? 0 : 1)} m';
                        return DropdownMenuItem(
                          value: len,
                          child: Text(label, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.setPoolLength(val);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: ValueKey('stroke-${state.stroke}'),
                      initialValue: state.stroke,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF004D40),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Primary Stroke',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                      ),
                      items: _strokes
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) controller.setStroke(val);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Top Stats (Time & Distance). Each stat owns half the row and
            // its number scales down rather than clipping - a clipped
            // duration is a wrong duration (67px right overflow at 320dp/150%
            // before this).
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _SwimStat(
                      label: 'DURATION',
                      value: _formatDuration(state.elapsedDuration.inSeconds),
                      valueColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SwimStat(
                      label: 'DISTANCE',
                      value:
                          '${state.totalDistanceMeters.toStringAsFixed(0)} m',
                      valueColor: const Color(0xFF80DEEA),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Huge Lap Counter Button (Water-Friendly Tap Area)
        GestureDetector(
          onTap: () {
            unawaited(AccessibilityHaptics.mediumImpact(ref));
            controller.incrementLap();
          },
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00838F),
              border: Border.all(color: const Color(0xFF80DEEA), width: 6),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            // The circle is a fixed 240dp wet-hands tap target; its text
            // scales down to stay inside it at large text sizes (the inner
            // column overflowed by 37px at 150% before this).
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'TAP FOR LAP',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${state.laps}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 76,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'LAPS',
                      style: TextStyle(
                        color: Color(0xFF80DEEA),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Decrement Lap Button
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white30),
            ),
            icon: const Icon(Icons.remove_circle_outline),
            label: const Text('Undo Last Lap (-1)'),
            onPressed: () {
              unawaited(AccessibilityHaptics.lightImpact(ref));
              controller.decrementLap();
            },
          ),
        ),
      ],
    );
  }
}

/// One headline stat: a small caps label over a large number that scales
/// down to fit its column instead of clipping.
class _SwimStat extends StatelessWidget {
  const _SwimStat({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              color: valueColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

enum _SwimFinishChoice { keepSwimming, saveToLastInteraction, saveFull }
