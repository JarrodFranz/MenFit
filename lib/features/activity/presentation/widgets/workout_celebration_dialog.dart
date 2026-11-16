import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_haptics.dart';
import 'package:menfit_app/features/achievements/achievements_widgets.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_milestone.dart';
import 'package:menfit_app/features/activity/presentation/widgets/workout_share_dialog.dart';

/// Celebratory modal dialog presented immediately upon completing a workout.
///
/// Features celebratory haptics, metrics breakdown, and prominently highlighted
/// personal records and consistency milestone badges.
class WorkoutCelebrationDialog extends ConsumerStatefulWidget {
  const WorkoutCelebrationDialog({
    required this.activity,
    required this.milestones,
    this.onViewDetails,
    this.onDone,
    this.primaryMetricLabel,
    this.primaryMetricValue,
    this.rpe,
    super.key,
  });

  final Activity activity;
  final List<WorkoutMilestone> milestones;
  final VoidCallback? onViewDetails;
  final VoidCallback? onDone;
  final String? primaryMetricLabel;
  final String? primaryMetricValue;

  /// Rating of Perceived Exertion to surface in the stat strip, 1-10.
  /// Defaults to [activity]'s own [Activity.rpe] when omitted, so every
  /// finishing flow gets this for free without passing it explicitly.
  /// `null` (the default for activity types that never asked, or for an
  /// unanswered question) hides the tile entirely — never rendered as
  /// "Not rated" or a fabricated number.
  final int? rpe;

  /// Helper to launch the celebration dialog seamlessly.
  static Future<void> show(
    BuildContext context, {
    required Activity activity,
    required List<WorkoutMilestone> milestones,
    VoidCallback? onViewDetails,
    VoidCallback? onDone,
    String? primaryMetricLabel,
    String? primaryMetricValue,
    int? rpe,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WorkoutCelebrationDialog(
        activity: activity,
        milestones: milestones,
        onViewDetails: onViewDetails,
        onDone: onDone,
        primaryMetricLabel: primaryMetricLabel,
        primaryMetricValue: primaryMetricValue,
        rpe: rpe,
      ),
    );
  }

  @override
  ConsumerState<WorkoutCelebrationDialog> createState() =>
      _WorkoutCelebrationDialogState();
}

class _WorkoutCelebrationDialogState
    extends ConsumerState<WorkoutCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();

    _triggerCelebratoryHaptics();
  }

  void _triggerCelebratoryHaptics() {
    unawaited(AccessibilityHaptics.mediumImpact(ref));
    Timer(const Duration(milliseconds: 180), () {
      if (mounted) {
        unawaited(AccessibilityHaptics.heavyImpact(ref));
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final colorScheme = theme.colorScheme;
    final hasPr = widget.milestones.any((m) => m.isPersonalRecord);
    final effectiveRpe = widget.rpe ?? widget.activity.rpe;

    final durationText = _formatDuration(
      widget.activity.movingTime.inSeconds > 0
          ? widget.activity.movingTime
          : widget.activity.elapsedTime,
    );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacingLg,
          vertical: tokens.spacingXl,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top glowing icon badge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: hasPr
                        ? [const Color(0xFFFFB703), const Color(0xFFFB8500)]
                        : [const Color(0xFFD84A1B), const Color(0xFFFF8A5B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (hasPr
                                  ? const Color(0xFFFFB703)
                                  : const Color(0xFFD84A1B))
                              .withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  hasPr
                      ? Icons.emoji_events_rounded
                      : Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              SizedBox(height: tokens.spacingMd),

              // Title
              Text(
                hasPr ? 'New Personal Record!' : 'Workout Complete!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: tokens.spacingXs),

              // Empowering affirmation
              Text(
                hasPr
                    ? 'Incredible work! You just set a new personal milestone.'
                    : 'Showing up for yourself is the ultimate '
                          'consistency win.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: tokens.spacingLg),

              // Summary Metrics Strip
              Container(
                padding: EdgeInsets.all(tokens.spacingMd),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  runSpacing: tokens.spacingSm,
                  children: [
                    _MetricColumn(
                      label: 'Duration',
                      value: durationText,
                      icon: Icons.timer_outlined,
                    ),
                    if (widget.primaryMetricValue != null)
                      _MetricColumn(
                        label: widget.primaryMetricLabel ?? 'Distance',
                        value: widget.primaryMetricValue!,
                        icon: Icons.straighten_rounded,
                      )
                    else if (widget.activity.hasDistance)
                      _MetricColumn(
                        label: 'Distance',
                        value: () {
                          final km = widget.activity.distanceMeters / 1000;
                          return '${km.toStringAsFixed(2)} km';
                        }(),
                        icon: Icons.straighten_rounded,
                      ),
                    _MetricColumn(
                      label: 'Type',
                      value: widget.activity.activityType.label,
                      icon: Icons.fitness_center_rounded,
                    ),
                    // Deliberately only rendered when non-null — an
                    // unanswered RPE must never show as "Not rated" or a
                    // fabricated default here (see [Activity.rpe]).
                    if (effectiveRpe != null)
                      _MetricColumn(
                        label: 'RPE',
                        value: '$effectiveRpe / 10',
                        icon: Icons.bolt_rounded,
                      ),
                  ],
                ),
              ),

              // Milestones list
              if (widget.milestones.isNotEmpty) ...[
                SizedBox(height: tokens.spacingMd),
                ...widget.milestones.map((milestone) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: tokens.spacingSm),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacingMd,
                        vertical: tokens.spacingSm + 2,
                      ),
                      decoration: BoxDecoration(
                        color: milestone.isPersonalRecord
                            ? const Color(0xFFFFF9E6)
                            : colorScheme.primaryContainer.withValues(
                                alpha: 0.35,
                              ),
                        borderRadius: BorderRadius.circular(tokens.radiusMd),
                        border: Border.all(
                          color: milestone.isPersonalRecord
                              ? const Color(0xFFFFD166)
                              : colorScheme.primary.withValues(alpha: 0.3),
                          width: milestone.isPersonalRecord ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            milestone.isPersonalRecord
                                ? Icons.military_tech_rounded
                                : Icons.local_fire_department_rounded,
                            color: milestone.isPersonalRecord
                                ? const Color(0xFFE65100)
                                : colorScheme.primary,
                            size: 24,
                          ),
                          SizedBox(width: tokens.spacingSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  milestone.title,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: milestone.isPersonalRecord
                                        ? const Color(0xFF7F3700)
                                        : null,
                                  ),
                                ),
                                Text(
                                  milestone.subtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: milestone.isPersonalRecord
                                        ? const Color(0xFF9E4700)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (milestone.badgeLabel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: milestone.isPersonalRecord
                                    ? const Color(0xFFFFB703)
                                    : colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                milestone.badgeLabel!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              // Badges this session happened to cross, if any. Renders
              // nothing at all when there are none - see
              // `features/achievements`'s `PostWorkoutBadgeStrip`. This is
              // the single hook point for all five finishing flows
              // (record, strength, HIIT, swim, mindful): none of them
              // shares a helper, but every one of them shows this dialog.
              const PostWorkoutBadgeStrip(),

              SizedBox(height: tokens.spacingLg),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share Win'),
                      onPressed: () {
                        unawaited(
                          WorkoutShareDialog.show(
                            context,
                            activity: widget.activity,
                            milestones: widget.milestones,
                            primaryMetricLabel: widget.primaryMetricLabel,
                            primaryMetricValue: widget.primaryMetricValue,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: tokens.spacingSm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onDone?.call();
                      },
                      child: const Text('Awesome!'),
                    ),
                  ),
                ],
              ),
              if (widget.onViewDetails != null) ...[
                SizedBox(height: tokens.spacingXs),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onViewDetails?.call();
                  },
                  child: const Text('View Workout Details'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    if (duration.inHours > 0) {
      final h = duration.inHours;
      final remM = m % 60;
      return '${h}h ${remM}m';
    }
    return '${m}m ${s}s';
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
