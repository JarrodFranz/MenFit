import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';
import 'package:menfit_app/features/activity/presentation/recording/yoga_runner/yoga_countdown_ring.dart';
import 'package:menfit_app/features/activity/presentation/recording/yoga_sequence_runner_controller.dart';

/// The practice itself: which pose, how long is left of it, what is next,
/// and the four controls.
///
/// The transition phase is drawn in a different colour role and names the
/// pose she is moving *into* — the colour is the redundant channel, the
/// words are the information (same reasoning as the HIIT tracker's phase
/// banner, which is why neither relies on colour alone).
class YogaRunnerActiveView extends StatelessWidget {
  const YogaRunnerActiveView({
    required this.state,
    required this.chimeSilenced,
    required this.onSkipBack,
    required this.onTogglePause,
    required this.onSkipForward,
    required this.onToggleMute,
    super.key,
  });

  final YogaRunnerState state;

  /// Whether a chime would be heard at all: false when the session mute is
  /// on **or** the Settings "Sound cues" switch is off. Drives the caption
  /// only — the decision to play is the cue funnel's.
  final bool chimeSilenced;

  final VoidCallback onSkipBack;
  final VoidCallback onTogglePause;
  final VoidCallback onSkipForward;
  final VoidCallback onToggleMute;

  bool get _isTransition => state.isTransitioning;

  bool get _isPaused => state.phase == YogaRunPhase.paused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final scheme = theme.colorScheme;

    final accent = _isTransition ? scheme.tertiary : scheme.primary;
    final panel = _isTransition
        ? scheme.tertiaryContainer
        : scheme.primaryContainer;
    final onPanel = _isTransition
        ? scheme.onTertiaryContainer
        : scheme.onPrimaryContainer;

    // During a transition the pose she is moving into is the headline; the
    // one she just left is over.
    final headline = state.displayPose?.displayName ?? '';
    final seconds = state.phaseRemaining.inSeconds;

    // Not a ListView: its children mount lazily, so the caption under the
    // controls would not exist below the fold - and this is a dozen widgets,
    // not a list.
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacingLg),
      child: Column(
        children: [
          Text(
            _isTransition
                ? 'Transition'
                : 'Pose ${state.poseNumber} of ${state.poseCount}',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: accent,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacingSm),
          // The one thing a screen reader must speak on every boundary.
          Semantics(
            liveRegion: true,
            child: Text(
              headline,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: onPanel,
              ),
            ),
          ),
          SizedBox(height: tokens.spacingLg),
          Container(
            padding: EdgeInsets.symmetric(vertical: tokens.spacingLg),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(tokens.radiusLg),
            ),
            child: Column(
              children: [
                YogaCountdownRing(
                  fractionRemaining: state.phaseFractionRemaining,
                  secondsRemaining: seconds,
                  color: accent,
                  trackColor: accent.withValues(alpha: 0.2),
                  semanticsLabel: _isPaused
                      ? 'Paused, $seconds seconds left'
                      : '$seconds seconds left',
                ),
                if (_isPaused) ...[
                  SizedBox(height: tokens.spacingSm),
                  Text(
                    'Paused',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: onPanel,
                    ),
                  ),
                ],
                if (!_isTransition &&
                    (state.currentPose?.cue.trim().isNotEmpty ?? false)) ...[
                  SizedBox(height: tokens.spacingSm),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.spacingLg),
                    child: Text(
                      state.currentPose!.cue,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onPanel,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: tokens.spacingMd),
          // Shown only for the tick that crossed more than one boundary —
          // the screen was locked or the isolate suspended long enough to
          // swallow whole poses. It clears itself on the next tick, because
          // by then the countdown on screen is the answer to "where am I?"
          // that this caption exists to give (ADR 014 §3).
          if (state.catchUpOccurred) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                'Skipped ahead to where you are',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(height: tokens.spacingSm),
          ],
          Text(
            _isTransition
                ? 'Coming up'
                : (state.nextPose == null
                      ? 'Last pose'
                      : 'Next: ${state.nextPose!.displayName}'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.spacingMd),
          _TimesRow(
            practised: state.practisedTime,
            elapsed: state.elapsedTime,
          ),
          SizedBox(height: tokens.spacingLg),
          // Wrap, not Row: at 150% text scale on a 320dp screen four 48dp
          // targets do not fit on one line, and controls that overflow are
          // controls she cannot press.
          Wrap(
            alignment: WrapAlignment.center,
            spacing: tokens.spacingSm,
            runSpacing: tokens.spacingSm,
            children: [
              _ControlButton(
                icon: Icons.skip_previous,
                label: 'Previous pose',
                onPressed: onSkipBack,
              ),
              _ControlButton(
                icon: _isPaused ? Icons.play_arrow : Icons.pause,
                label: _isPaused ? 'Resume' : 'Pause',
                onPressed: onTogglePause,
                filled: true,
              ),
              _ControlButton(
                icon: Icons.skip_next,
                label: 'Next pose',
                onPressed: onSkipForward,
              ),
              _ControlButton(
                icon: state.soundMuted ? Icons.volume_off : Icons.volume_up,
                label: state.soundMuted ? 'Unmute chime' : 'Mute chime',
                onPressed: onToggleMute,
              ),
            ],
          ),
          if (chimeSilenced) ...[
            SizedBox(height: tokens.spacingSm),
            Text(
              'Chime muted',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimesRow extends StatelessWidget {
  const _TimesRow({required this.practised, required this.elapsed});

  final Duration practised;
  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 8,
      children: [
        _TimeStat(label: 'Practised', value: formatDuration(practised)),
        _TimeStat(label: 'Elapsed', value: formatDuration(elapsed)),
      ],
    );
  }
}

class _TimeStat extends StatelessWidget {
  const _TimeStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final style = IconButton.styleFrom(
      minimumSize: const Size(48, 48),
    );
    final child = Icon(icon);
    return filled
        ? IconButton.filled(
            onPressed: onPressed,
            icon: child,
            iconSize: 32,
            tooltip: label,
            style: style,
          )
        : IconButton.filledTonal(
            onPressed: onPressed,
            icon: child,
            iconSize: 28,
            tooltip: label,
            style: style,
          );
  }
}
