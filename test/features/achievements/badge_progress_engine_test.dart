import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/achievements/domain/badge_catalogue.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_inputs.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress_engine.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

import 'achievement_fixtures.dart';

/// A ladder with round numbers, so the arithmetic in these tests can be
/// done in the head rather than trusted from the catalogue.
const _testLadder = BadgeLadder(
  bronze: 10,
  silver: 20,
  gold: 40,
  platinum: 80,
  diamond: 100,
  diamondProgression: ArithmeticDiamondProgression(50),
);

const _tieredBadge = BadgeDefinition.tiered(
  id: 'test_tiered',
  title: 'Test Ladder',
  description: 'A ladder with round numbers.',
  category: BadgeCategory.movement,
  metric: BadgeMetric.lifetimeSessionCount,
  unit: BadgeMetricUnit.sessions,
  ladder: _testLadder,
);

const _oneOffBadge = BadgeDefinition.oneOff(
  id: 'test_one_off',
  title: 'Test First',
  description: 'A single award.',
  category: BadgeCategory.movement,
  condition: BadgeCondition.firstActivityLogged,
);

void main() {
  final today = LocalDate(2026, 9, 1);

  setUp(resetFixtureIds);

  BadgeProgress tieredAt(double value) => evaluateBadge(
    definition: _tieredBadge,
    metrics: {BadgeMetric.lifetimeSessionCount: value},
    conditions: const {},
  );

  group('tier resolution', () {
    test('below bronze earns nothing but still reports the next rung', () {
      final progress = tieredAt(4);
      expect(progress.isEarned, isFalse);
      expect(progress.earnedTier, isNull);
      expect(progress.earnedTiers, isEmpty);
      expect(progress.nextTier, BadgeTier.bronze);
      expect(progress.currentThreshold, 0);
      expect(progress.nextThreshold, 10);
      expect(progress.remainingToNext, 6);
      expect(progress.progressToNext, closeTo(0.4, 1e-12));
    });

    test('exactly at a threshold earns that tier with zero progress on', () {
      final progress = tieredAt(20);
      expect(progress.earnedTier, BadgeTier.silver);
      expect(progress.nextTier, BadgeTier.gold);
      expect(progress.currentThreshold, 20);
      expect(progress.nextThreshold, 40);
      expect(progress.progressToNext, 0);
      expect(progress.remainingToNext, 20);
    });

    test('one below a threshold stays on the tier beneath it', () {
      expect(tieredAt(19.999).earnedTier, BadgeTier.bronze);
    });

    test('progress runs from the earned tier to the next, not from zero', () {
      // 30 is halfway from Silver (20) to Gold (40).
      final progress = tieredAt(30);
      expect(progress.earnedTier, BadgeTier.silver);
      expect(progress.progressToNext, closeTo(0.5, 1e-12));
      expect(progress.remainingToNext, 10);
    });

    test('earnedTiers lists the whole ladder up to the tier reached', () {
      expect(tieredAt(100).earnedTiers, [
        BadgeTier.bronze,
        BadgeTier.silver,
        BadgeTier.gold,
        BadgeTier.platinum,
        BadgeTier.diamond(1),
      ]);
    });
  });

  group('diamond levels', () {
    test('the arithmetic rule resolves the level exactly', () {
      expect(tieredAt(100).earnedTier, BadgeTier.diamond(1));
      expect(tieredAt(149).earnedTier, BadgeTier.diamond(1));
      expect(tieredAt(150).earnedTier, BadgeTier.diamond(2));
      expect(tieredAt(500).earnedTier, BadgeTier.diamond(9));
      expect(tieredAt(550).earnedTier, BadgeTier.diamond(10));
    });

    test('the next diamond threshold is reported for the UI', () {
      final progress = tieredAt(175);
      expect(progress.earnedTier, BadgeTier.diamond(2));
      expect(progress.nextTier, BadgeTier.diamond(3));
      expect(progress.nextThreshold, 200);
      expect(progress.progressToNext, closeTo(0.5, 1e-12));
    });

    test('a geometric rule doubles rather than steps', () {
      const geometric = BadgeDefinition.tiered(
        id: 'test_geometric',
        title: 'Test Doubling',
        description: 'A ladder that doubles past Diamond.',
        category: BadgeCategory.strength,
        metric: BadgeMetric.lifetimeStrengthVolumeKg,
        unit: BadgeMetricUnit.kilograms,
        ladder: BadgeLadder(
          bronze: 10,
          silver: 20,
          gold: 40,
          platinum: 80,
          diamond: 100,
          diamondProgression: GeometricDiamondProgression(2),
        ),
      );
      BadgeTier? tierAt(double value) => evaluateBadge(
        definition: geometric,
        metrics: {BadgeMetric.lifetimeStrengthVolumeKg: value},
        conditions: const {},
      ).earnedTier;
      expect(tierAt(100), BadgeTier.diamond(1));
      expect(tierAt(199), BadgeTier.diamond(1));
      expect(tierAt(200), BadgeTier.diamond(2));
      expect(tierAt(800), BadgeTier.diamond(4));
    });
  });

  group('progress bounds', () {
    test('never negative and never above one, at any value', () {
      for (final value in <double>[0, 1, 9.99, 10, 55, 99.999, 100, 12345]) {
        final progress = tieredAt(value);
        expect(
          progress.progressToNext,
          greaterThanOrEqualTo(0),
          reason: '$value',
        );
        expect(progress.progressToNext, lessThanOrEqualTo(1), reason: '$value');
        expect(progress.remainingToNext, greaterThanOrEqualTo(0));
      }
    });

    test('an absent metric reads as zero rather than throwing', () {
      final progress = evaluateBadge(
        definition: _tieredBadge,
        metrics: const {},
        conditions: const {},
      );
      expect(progress.value, 0);
      expect(progress.earnedTier, isNull);
    });
  });

  group('one-off badges', () {
    test('unearned is zero progress with no tier anywhere', () {
      final progress = evaluateBadge(
        definition: _oneOffBadge,
        metrics: const {},
        conditions: const {},
      );
      expect(progress.isEarned, isFalse);
      expect(progress.value, 0);
      expect(progress.progressToNext, 0);
      expect(progress.earnedTier, isNull);
      expect(progress.nextTier, isNull);
      expect(progress.nextThreshold, isNull);
      expect(progress.remainingToNext, isNull);
      expect(progress.earnedTiers, isEmpty);
    });

    test('earned is complete, with no partial credit for a first', () {
      final progress = evaluateBadge(
        definition: _oneOffBadge,
        metrics: const {},
        conditions: const {BadgeCondition.firstActivityLogged},
      );
      expect(progress.isEarned, isTrue);
      expect(progress.value, 1);
      expect(progress.progressToNext, 1);
      expect(progress.earnedTier, isNull);
    });
  });

  group('evaluateBadges over the real catalogue', () {
    test('empty history yields one zero-progress entry per badge', () {
      final progress = evaluateBadges(inputs: BadgeInputs(today: today));
      expect(progress, hasLength(badgeCatalogue.length));
      expect(
        progress.map((p) => p.definition.id),
        badgeCatalogue.map((badge) => badge.id),
        reason: 'catalogue order, so the screen can render it straight',
      );
      for (final entry in progress) {
        expect(entry.isEarned, isFalse, reason: entry.definition.id);
        expect(entry.progressToNext, 0, reason: entry.definition.id);
        if (entry.definition.kind == BadgeKind.tiered) {
          expect(entry.nextTier, BadgeTier.bronze);
          expect(
            entry.nextThreshold,
            entry.definition.ladder!.bronze,
            reason: entry.definition.id,
          );
        }
      }
    });

    test('a first logged session earns exactly what it should', () {
      final progress = evaluateBadges(
        inputs: BadgeInputs(
          today: today,
          activities: [
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 5, 4, 10),
              distanceMeters: 3000,
            ),
          ],
        ),
      );
      final earned = progress
          .where((p) => p.isEarned)
          .map((p) => p.definition.id)
          .toSet();
      expect(earned, {'first_activity'});
    });

    test('the engine is deterministic for the same inputs', () {
      final inputs = BadgeInputs(
        today: today,
        activities: [
          for (var i = 0; i < 30; i++)
            activityFixture(
              type: ActivityType.run,
              startedAt: DateTime(2026, 5, 1, 10).add(Duration(days: i)),
              distanceMeters: 5000,
            ),
        ],
      );
      expect(evaluateBadges(inputs: inputs), evaluateBadges(inputs: inputs));
    });
  });
}
