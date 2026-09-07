import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_catalogue.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress_engine.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';
import 'package:menfit_app/features/achievements/presentation/badge_display.dart';

/// The merge that makes "awards are never revoked" true on screen.
///
/// The engine answers what the data earns *today*; the awards table records
/// what she has been given. They can disagree — the cycle-pausing toggle
/// changes the walking ladder's pro-rated ask, a deleted activity lowers a
/// lifetime total — and when they do, the badge she holds wins.
void main() {
  final awardedAt = DateTime.utc(2026, 9, 1, 12);

  BadgeAward award(String badgeId, BadgeTier? tier) => BadgeAward(
    id: 'award-$badgeId-${awardTierKey(tier)}',
    badgeId: badgeId,
    awardedAt: awardedAt,
    tier: tier,
  );

  /// The whole catalogue evaluated against hand-written metrics, so every
  /// assertion below runs through the real ladders.
  List<BadgeProgress> progressFor({
    Map<BadgeMetric, double> metrics = const {},
    Set<BadgeCondition> conditions = const {},
  }) {
    return [
      for (final definition in badgeCatalogue)
        evaluateBadge(
          definition: definition,
          metrics: metrics,
          conditions: conditions,
        ),
    ];
  }

  BadgeProgress badge(List<BadgeProgress> progress, String id) =>
      progress.firstWhere((entry) => entry.definition.id == id);

  group('displayedBadgeProgress', () {
    test('with no awards the engine answer is passed straight through', () {
      final progress = progressFor(
        metrics: {BadgeMetric.lifetimeRunDistanceMetres: 88000},
      );
      expect(
        displayedBadgeProgress(progress: progress, awards: const []),
        same(progress),
      );
    });

    test('a held rung survives the data falling below it', () {
      // Silver was awarded at 100 km; the data now reads 30 km, which is
      // only Bronze. This is the vanishing-badge case: without the merge
      // the tile would drop to Bronze while the award row still stood.
      final display = displayedBadgeProgress(
        progress: progressFor(
          metrics: {BadgeMetric.lifetimeRunDistanceMetres: 30000},
        ),
        awards: [
          award('run_distance', BadgeTier.bronze),
          award('run_distance', BadgeTier.silver),
        ],
      );

      final run = badge(display, 'run_distance');
      expect(run.isEarned, isTrue);
      expect(run.earnedTier, BadgeTier.silver);
      expect(
        run.earnedTiers,
        [BadgeTier.bronze, BadgeTier.silver],
        reason: 'the ladder under a held rung is held too',
      );
    });

    test('the bar runs from the held rung to the one above it, at zero', () {
      final display = displayedBadgeProgress(
        progress: progressFor(
          metrics: {BadgeMetric.lifetimeRunDistanceMetres: 30000},
        ),
        awards: [award('run_distance', BadgeTier.silver)],
      );

      final run = badge(display, 'run_distance');
      expect(run.nextTier, BadgeTier.gold, reason: 'the rung above Silver');
      expect(run.currentThreshold, 100000);
      expect(run.nextThreshold, 400000);
      expect(
        run.progressToNext,
        0,
        reason: 'behind the held rung is no progress, never a negative bar',
      );
      expect(run.remainingToNext, 370000);
    });

    test('the value line still says what the data says', () {
      final display = displayedBadgeProgress(
        progress: progressFor(
          metrics: {BadgeMetric.lifetimeRunDistanceMetres: 30000},
        ),
        awards: [award('run_distance', BadgeTier.silver)],
      );

      expect(
        badge(display, 'run_distance').value,
        30000,
        reason: 'the badge is hers; the kilometres are not retconned',
      );
    });

    test('the data wins when it is ahead of what is recorded', () {
      // The ordinary case: a rung crossed moments ago, not yet detected.
      final progress = progressFor(
        metrics: {BadgeMetric.lifetimeRunDistanceMetres: 450000},
      );
      final display = displayedBadgeProgress(
        progress: progress,
        awards: [award('run_distance', BadgeTier.bronze)],
      );

      final run = badge(display, 'run_distance');
      expect(run.earnedTier, BadgeTier.gold);
      expect(run, badge(progress, 'run_distance'));
    });

    test('an equal reading is left exactly as the engine produced it', () {
      final progress = progressFor(
        metrics: {BadgeMetric.lifetimeRunDistanceMetres: 120000},
      );
      final display = displayedBadgeProgress(
        progress: progress,
        awards: [award('run_distance', BadgeTier.silver)],
      );
      expect(badge(display, 'run_distance'), badge(progress, 'run_distance'));
    });

    test('a held one-off stays earned when its condition stops firing', () {
      final display = displayedBadgeProgress(
        progress: progressFor(),
        awards: [award('first_activity', null)],
      );

      final oneOff = badge(display, 'first_activity');
      expect(oneOff.isEarned, isTrue);
      expect(oneOff.value, 1, reason: "a one-off's value restates isEarned");
      expect(oneOff.progressToNext, 1);
      expect(oneOff.earnedTier, isNull, reason: 'a one-off has no tier');
    });

    test('badges with no award of their own are untouched', () {
      final progress = progressFor();
      final display = displayedBadgeProgress(
        progress: progress,
        awards: [award('run_distance', BadgeTier.gold)],
      );

      expect(display, hasLength(progress.length));
      for (var i = 0; i < progress.length; i++) {
        if (progress[i].definition.id == 'run_distance') continue;
        expect(display[i], progress[i]);
      }
    });

    test('an award for a badge no longer in the catalogue changes nothing', () {
      final progress = progressFor();
      final display = displayedBadgeProgress(
        progress: progress,
        awards: [award('retired_badge', BadgeTier.gold)],
      );
      expect(display, progress);
    });

    test('the highest held rung wins over the lower ones', () {
      final display = displayedBadgeProgress(
        progress: progressFor(),
        awards: [
          award('run_distance', BadgeTier.bronze),
          award('run_distance', BadgeTier.gold),
          award('run_distance', BadgeTier.silver),
        ],
      );
      expect(badge(display, 'run_distance').earnedTier, BadgeTier.gold);
    });

    test('a held Diamond level past the named tiers resolves its ladder', () {
      final display = displayedBadgeProgress(
        progress: progressFor(),
        awards: [award('run_distance', BadgeTier.diamond(2))],
      );

      final run = badge(display, 'run_distance');
      expect(run.earnedTier, BadgeTier.diamond(2));
      expect(run.nextTier, BadgeTier.diamond(3));
      // Diamond I 2,500 km, +1,500 km a level.
      expect(run.currentThreshold, 4000000);
      expect(run.nextThreshold, 5500000);
    });

    test('every badge in the catalogue survives the merge, in order', () {
      final progress = progressFor();
      final display = displayedBadgeProgress(
        progress: progress,
        awards: [
          for (final definition in badgeCatalogue)
            award(
              definition.id,
              definition.kind == BadgeKind.tiered ? BadgeTier.platinum : null,
            ),
        ],
      );

      expect(
        display.map((entry) => entry.definition.id),
        progress.map((entry) => entry.definition.id),
      );
      expect(display.every((entry) => entry.isEarned), isTrue);
    });
  });

  group('earnedBadgeCount', () {
    test('counts nothing when nothing is held or earned', () {
      expect(earnedBadgeCount(progress: progressFor()), 0);
      expect(earnedBadgeCount(), 0);
    });

    test('the merged list and the awards alone agree once recorded', () {
      // What the two surfaces each know: the trophy case has the merged
      // list, the Progress card has only the award rows.
      final awards = [
        award('run_distance', BadgeTier.bronze),
        award('run_distance', BadgeTier.silver),
        award('first_activity', null),
      ];
      final display = displayedBadgeProgress(
        progress: progressFor(),
        awards: awards,
      );

      expect(
        earnedBadgeCount(progress: display),
        2,
        reason: 'two badges, not three rungs',
      );
      expect(earnedBadgeCount(awards: awards), 2);
    });

    test('a badge that is data-earned but not yet recorded still counts', () {
      final display = displayedBadgeProgress(
        progress: progressFor(
          conditions: {BadgeCondition.firstActivityLogged},
        ),
        awards: const [],
      );
      expect(earnedBadgeCount(progress: display), 1);
    });

    test('an award for a badge the catalogue no longer defines is not '
        'counted - there is no tile to point at', () {
      expect(earnedBadgeCount(awards: [award('retired_badge', null)]), 0);
    });
  });
}
