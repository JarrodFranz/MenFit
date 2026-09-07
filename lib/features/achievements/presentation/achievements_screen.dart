import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/achievements/achievements_providers.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/presentation/achievements_copy.dart';
import 'package:menfit_app/features/achievements/presentation/badge_display.dart';
import 'package:menfit_app/features/achievements/presentation/widgets/achievements_summary_header.dart';
import 'package:menfit_app/features/achievements/presentation/widgets/badge_celebration_dialog.dart';
import 'package:menfit_app/features/achievements/presentation/widgets/badge_tile.dart';

/// The trophy case: every badge they hold, every badge on offer, and how
/// far the next rung is — the three things Task 1.8 asks to be visible at
/// once.
///
/// Reached at `/achievements` from the Progress screen's Achievements card.
///
/// ## The empty state is the screen
///
/// A new user sees exactly what an established user sees: all 23 badges,
/// each at zero with Bronze as its next rung. There is no separate "you
/// have no achievements yet" screen, because there is nothing missing —
/// the whole catalogue is on offer from the first minute, and saying so
/// with the badges themselves is warmer than saying it with a paragraph.
///
/// ## Detection runs here
///
/// Opening the screen is the catch-all trigger described on `AwardDetector`
/// (`application/award_detector.dart`):
/// anything crossed while the app was elsewhere is recorded now and
/// celebrated once. See `_runDetection` below for the first-run flood rule.
///
/// ## Two readings of the same badge
///
/// The case renders [badgeDisplayProgressProvider] — the engine's read of
/// the data with every persisted award folded in, so a rung they were awarded
/// never disappears from a tile because the data behind it moved
/// (`presentation/badge_display.dart`). Detection below deliberately keeps
/// reading the un-merged [badgeProgressProvider]: it is asking what the
/// *data* earns, which is the only question `award_diff.dart` can answer
/// honestly.
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    // After the first frame, so the case is already on screen behind the
    // celebration rather than appearing underneath it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runDetection());
    });
  }

  /// Records anything newly earned and celebrates it exactly once.
  ///
  /// Flood control lives in [BadgeCelebrationDialog]: a first run on an
  /// established install can legitimately return many awards at once, and
  /// they arrive as one summary rather than a queue of modals.
  ///
  /// Failure is silent on purpose. The detector needs the whole history to
  /// evaluate; when that read fails the screen already shows the error
  /// through [badgeProgressProvider], and a second interruption saying the
  /// same thing helps nobody.
  Future<void> _runDetection() async {
    try {
      final progress = await ref.read(badgeProgressProvider.future);
      // Nothing evaluated means nothing can have been crossed, and the
      // detector would only open persistence to be told so. Cheap, but
      // the point is that it keeps a caller with no badge data from
      // touching the database at all.
      if (progress.isEmpty) return;
      final awards = await ref.read(awardDetectorProvider).detect(progress);
      if (!mounted || awards.isEmpty) return;
      await BadgeCelebrationDialog.show(context, awards: awards);
    } on Object catch (_) {
      // Intentionally silent — see the doc comment.
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final progressAsync = ref.watch(badgeDisplayProgressProvider);
    final awards = ref.watch(badgeAwardsProvider).value ?? const <BadgeAward>[];

    return Scaffold(
      appBar: AppBar(title: const Text(achievementsScreenTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: progressAsync.when(
              data: (progress) => _TrophyCase(
                progress: progress,
                awardedAt: awardDatesByBadge(awards),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Padding(
                padding: EdgeInsets.all(tokens.spacingMd),
                child: Center(child: Text(userMessageFor(error))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrophyCase extends StatelessWidget {
  const _TrophyCase({required this.progress, required this.awardedAt});

  final List<BadgeProgress> progress;
  final Map<String, Map<String, DateTime>> awardedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AchievementsSummaryHeader(progress: progress),
          SizedBox(height: tokens.spacingMd),
          for (final (category, badges) in groupBadgesByCategory(progress)) ...[
            Padding(
              padding: EdgeInsets.only(
                top: tokens.spacingSm,
                bottom: tokens.spacingSm,
              ),
              child: Text(
                category.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            for (final badge in badges)
              BadgeTile(
                key: Key('badge_${badge.definition.id}'),
                progress: badge,
                awardedAtByTierKey: awardedAt[badge.definition.id] ?? const {},
              ),
          ],
          SizedBox(height: tokens.spacingLg),
        ],
      ),
    );
  }
}

/// [progress] split into sections, in the order the categories first appear
/// in the catalogue.
///
/// Derived from the list rather than from `BadgeCategory.values` so the
/// catalogue stays the single place badge order is decided, and a category
/// that has no badges yet produces no empty heading.
List<(BadgeCategory, List<BadgeProgress>)> groupBadgesByCategory(
  List<BadgeProgress> progress,
) {
  final sections = <BadgeCategory, List<BadgeProgress>>{};
  for (final badge in progress) {
    (sections[badge.definition.category] ??= []).add(badge);
  }
  return [for (final entry in sections.entries) (entry.key, entry.value)];
}

/// The awards indexed as `badgeId -> tierKey -> awardedAt`, which is how
/// the tiles ask for them.
///
/// Awards arrive newest first and are idempotent per `(badgeId, tierKey)`,
/// so a duplicate cannot occur; the last write wins regardless.
Map<String, Map<String, DateTime>> awardDatesByBadge(List<BadgeAward> awards) {
  final byBadge = <String, Map<String, DateTime>>{};
  for (final award in awards) {
    (byBadge[award.badgeId] ??= {})[awardTierKey(award.tier)] = award.awardedAt;
  }
  return byBadge;
}
