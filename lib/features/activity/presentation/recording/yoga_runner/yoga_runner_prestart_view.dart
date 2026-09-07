import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';

/// What the runner shows before the practice starts: what she is about to
/// do, and one button to begin.
///
/// Deliberately a separate view rather than a countdown that starts itself.
/// Audio on the web only plays if a user gesture led to it, and the gesture
/// that counts is the one on the call stack — so the Start tap is not a
/// nicety here, it is the thing that makes the chime audible at all (see
/// `AudioCuePlayer.preload`).
/// The practice that is already running when she opens a *different*
/// sequence's runner.
///
/// The runner is a single global machine, so starting this sequence ends
/// that one. That is a decision she has to make, not one a Start button may
/// make for her — hence two named ways out and no bare Start.
@immutable
class YogaRunnerConflict {
  const YogaRunnerConflict({
    required this.name,
    required this.isComplete,
    required this.onGoBack,
    required this.onDiscardAndStart,
  });

  /// Name of the sequence already in the runner.
  final String name;

  /// True when that practice has reached its end and is waiting to be
  /// saved — discarding it throws away a finished session, not a partial
  /// one, so it is worth saying so.
  final bool isComplete;

  final VoidCallback onGoBack;
  final VoidCallback onDiscardAndStart;
}

class YogaRunnerPrestartView extends StatelessWidget {
  const YogaRunnerPrestartView({
    required this.sequence,
    required this.onStart,
    this.conflict,
    super.key,
  });

  final YogaSequence sequence;
  final VoidCallback onStart;

  /// Non-null when another practice is already loaded in the runner; the
  /// Start button is replaced by that practice's two options.
  final YogaRunnerConflict? conflict;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final style = sequence.style;

    return ListView(
      padding: EdgeInsets.all(tokens.spacingLg),
      children: [
        Text(sequence.name, style: theme.textTheme.headlineSmall),
        if (sequence.description.trim().isNotEmpty) ...[
          SizedBox(height: tokens.spacingXs),
          Text(
            sequence.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        SizedBox(height: tokens.spacingMd),
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingSm,
          children: [
            _MetaChip(
              icon: Icons.self_improvement,
              label: sequence.poseCount == 1
                  ? '1 pose'
                  : '${sequence.poseCount} poses',
            ),
            _MetaChip(
              icon: Icons.schedule,
              label: formatDuration(sequence.totalDuration),
            ),
            if (style != null && style.trim().isNotEmpty)
              _MetaChip(icon: Icons.spa_outlined, label: style),
            _MetaChip(
              icon: Icons.swap_horiz,
              label: sequence.transitionSeconds == 0
                  ? 'No gap between poses'
                  : '${sequence.transitionSeconds}s between poses',
            ),
          ],
        ),
        SizedBox(height: tokens.spacingLg),
        if (conflict case final running?)
          _ConflictPanel(conflict: running)
        else
          FilledButton.icon(
            key: const Key('yogaStartPracticeButton'),
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start practice'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        SizedBox(height: tokens.spacingLg),
        Text(
          'Poses',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: tokens.spacingXs),
        for (var i = 0; i < sequence.poses.length; i++)
          _PoseRow(
            key: ValueKey('pose-$i'),
            position: i + 1,
            pose: sequence.poses[i],
          ),
      ],
    );
  }
}

class _ConflictPanel extends StatelessWidget {
  const _ConflictPanel({required this.conflict});

  final YogaRunnerConflict conflict;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTokens.light();
    final scheme = theme.colorScheme;

    return Container(
      key: const Key('yogaRunnerConflictPanel'),
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            conflict.isComplete
                ? 'You have a finished practice waiting to be saved: '
                      '${conflict.name}'
                : 'You have a practice running: ${conflict.name}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onTertiaryContainer,
            ),
          ),
          SizedBox(height: tokens.spacingXs),
          Text(
            'Only one practice runs at a time, so starting this one ends '
            'that one.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onTertiaryContainer,
            ),
          ),
          SizedBox(height: tokens.spacingMd),
          FilledButton(
            key: const Key('yogaRunnerGoBackButton'),
            onPressed: conflict.onGoBack,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Go back to it'),
          ),
          SizedBox(height: tokens.spacingSm),
          OutlinedButton(
            key: const Key('yogaRunnerDiscardAndStartButton'),
            onPressed: conflict.onDiscardAndStart,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Discard it and start this one'),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _PoseRow extends StatelessWidget {
  const _PoseRow({required this.position, required this.pose, super.key});

  final int position;
  final YogaPose pose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$position.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(pose.displayName, style: theme.textTheme.bodyLarge),
          ),
          SizedBox(width: tokens.spacingSm),
          Text(
            '${pose.holdSeconds}s',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
