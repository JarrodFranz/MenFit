import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_haptics.dart';
import 'package:menfit_app/features/achievements/achievements_providers.dart';
import 'package:menfit_app/features/achievements/presentation/achievements_copy.dart';
import 'package:menfit_app/features/achievements/presentation/widgets/badge_celebration_dialog.dart';

/// Heading above the badges a just-finished session happened to cross.
const String postWorkoutBadgeHeading = 'Also earned just now';

/// The badges a just-finished session crossed, shown inside the workout
/// celebration.
///
/// Mounted by
/// `features/activity/presentation/widgets/workout_celebration_dialog.dart`
/// — the single point all five finishing flows (record, strength, HIIT,
/// swim, mindful) pass through — via this feature's UI composition surface
/// `achievements_widgets.dart` (ADR 007).
///
/// Badges and milestones stay two systems: a milestone is about the session
/// just finished, a badge about a lifetime total crossing a line. This
/// strip only exists so a crossing is noticed at the moment it most likely
/// happened, instead of waiting for their next visit to the trophy case.
///
/// It renders **nothing at all** until there is something to say — no
/// heading, no spacing, no "no new badges" line. A celebration that
/// announces the absence of a celebration is a small disappointment
/// delivered at the exact moment they finished a workout.
class PostWorkoutBadgeStrip extends ConsumerStatefulWidget {
  const PostWorkoutBadgeStrip({super.key});

  @override
  ConsumerState<PostWorkoutBadgeStrip> createState() =>
      _PostWorkoutBadgeStripState();
}

class _PostWorkoutBadgeStripState extends ConsumerState<PostWorkoutBadgeStrip> {
  List<CelebratedBadge> _badges = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_detect());
    });
  }

  /// Runs the same detector the trophy case runs, and is idempotent with
  /// it: whichever fires first records the award, and the other finds it
  /// already held and shows nothing.
  ///
  /// Silent on failure — the workout celebration is not the place to
  /// surface a repository error, and the badge will be picked up on the
  /// next visit to the achievements screen regardless.
  Future<void> _detect() async {
    try {
      final progress = await ref.read(badgeProgressProvider.future);
      // Nothing evaluated means nothing can have been crossed, and the
      // detector would only open persistence to be told so. Cheap, but
      // the point is that it keeps a caller with no badge data from
      // touching the database at all.
      if (progress.isEmpty) return;
      final awards = await ref.read(awardDetectorProvider).detect(progress);
      if (!mounted || awards.isEmpty) return;
      final badges = resolveCelebratedBadges(awards);
      if (badges.isEmpty) return;
      setState(() => _badges = badges);
      unawaited(AccessibilityHaptics.mediumImpact(ref));
    } on Object catch (_) {
      // Intentionally silent — see the doc comment.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_badges.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final isFlood = _badges.length > badgeCelebrationFloodThreshold;

    return Padding(
      padding: EdgeInsets.only(top: tokens.spacingMd),
      child: Column(
        key: const Key('postWorkoutBadgeStrip'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            postWorkoutBadgeHeading,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacingSm),
          if (isFlood)
            Text(
              catchUpCelebrationTitle(_badges.length),
              style: theme.textTheme.bodyMedium,
            )
          else
            for (final badge in _badges)
              Padding(
                padding: EdgeInsets.only(bottom: tokens.spacingSm),
                child: BadgeCelebrationRow(badge: badge),
              ),
        ],
      ),
    );
  }
}
