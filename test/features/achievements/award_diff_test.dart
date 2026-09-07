import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/achievements/domain/award_diff.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';

const _ladder = BadgeLadder(
  bronze: 10,
  silver: 20,
  gold: 40,
  platinum: 80,
  diamond: 100,
  diamondProgression: ArithmeticDiamondProgression(50),
);

const _tiered = BadgeDefinition.tiered(
  id: 'test_tiered',
  title: 'Test Ladder',
  description: 'A ladder with round numbers.',
  category: BadgeCategory.movement,
  metric: BadgeMetric.lifetimeSessionCount,
  unit: BadgeMetricUnit.sessions,
  ladder: _ladder,
);

const _otherTiered = BadgeDefinition.tiered(
  id: 'test_other',
  title: 'Other Ladder',
  description: 'A second ladder.',
  category: BadgeCategory.strength,
  metric: BadgeMetric.strengthSessionCount,
  unit: BadgeMetricUnit.sessions,
  ladder: _ladder,
);

const _oneOff = BadgeDefinition.oneOff(
  id: 'test_one_off',
  title: 'Test First',
  description: 'A single award.',
  category: BadgeCategory.movement,
  condition: BadgeCondition.firstActivityLogged,
);

BadgeProgress tieredProgress(BadgeDefinition definition, BadgeTier? tier) {
  return BadgeProgress(
    definition: definition,
    value: tier == null ? 0 : _ladder.thresholdFor(tier),
    isEarned: tier != null,
    earnedTier: tier,
    nextTier: tier == null ? BadgeTier.bronze : tier.next,
  );
}

BadgeProgress oneOffProgress({required bool earned}) {
  return BadgeProgress(
    definition: _oneOff,
    value: earned ? 1 : 0,
    isEarned: earned,
    progressToNext: earned ? 1 : 0,
  );
}

void main() {
  final stamp = DateTime.utc(2026, 9, 1, 12);
  var counter = 0;
  String nextId() => 'award-${counter++}';

  setUp(() => counter = 0);

  List<BadgeAward> diff(
    List<BadgeProgress> progress, {
    List<BadgeAward> existing = const [],
  }) {
    return newlyEarnedAwards(
      progress: progress,
      existingAwards: existing,
      awardedAt: stamp,
      generateId: nextId,
    );
  }

  test('nothing earned yields nothing', () {
    expect(
      diff([tieredProgress(_tiered, null), oneOffProgress(earned: false)]),
      isEmpty,
    );
  });

  test('reaching gold from nothing awards the whole ladder beneath it', () {
    final fresh = diff([tieredProgress(_tiered, BadgeTier.gold)]);
    expect(fresh.map((a) => a.tier), [
      BadgeTier.bronze,
      BadgeTier.silver,
      BadgeTier.gold,
    ]);
    expect(fresh.every((a) => a.badgeId == 'test_tiered'), isTrue);
    expect(fresh.every((a) => a.awardedAt == stamp), isTrue);
  });

  test('tiers already held are not re-awarded', () {
    final existing = [
      BadgeAward(
        id: 'old-1',
        badgeId: 'test_tiered',
        awardedAt: DateTime.utc(2026),
        tier: BadgeTier.bronze,
      ),
      BadgeAward(
        id: 'old-2',
        badgeId: 'test_tiered',
        awardedAt: DateTime.utc(2026),
        tier: BadgeTier.silver,
      ),
    ];
    final fresh = diff(
      [tieredProgress(_tiered, BadgeTier.gold)],
      existing: existing,
    );
    expect(fresh, hasLength(1));
    expect(fresh.single.tier, BadgeTier.gold);
  });

  test('running the diff twice over its own output finds nothing', () {
    final first = diff([
      tieredProgress(_tiered, BadgeTier.platinum),
      oneOffProgress(earned: true),
    ]);
    expect(first, isNotEmpty);
    final second = diff(
      [
        tieredProgress(_tiered, BadgeTier.platinum),
        oneOffProgress(earned: true),
      ],
      existing: first,
    );
    expect(second, isEmpty, reason: 'the diff must be idempotent');
  });

  test('a one-off is awarded once, with a null tier', () {
    final fresh = diff([oneOffProgress(earned: true)]);
    expect(fresh, hasLength(1));
    expect(fresh.single.tier, isNull);
    expect(fresh.single.identity, ('test_one_off', oneOffAwardTierKey));
  });

  test('a held one-off is not awarded again', () {
    final existing = [
      BadgeAward(
        id: 'old',
        badgeId: 'test_one_off',
        awardedAt: DateTime.utc(2026),
      ),
    ];
    expect(diff([oneOffProgress(earned: true)], existing: existing), isEmpty);
  });

  test('the same tier on a different badge is a different award', () {
    final existing = [
      BadgeAward(
        id: 'old',
        badgeId: 'test_tiered',
        awardedAt: DateTime.utc(2026),
        tier: BadgeTier.bronze,
      ),
    ];
    final fresh = diff(
      [
        tieredProgress(_tiered, BadgeTier.bronze),
        tieredProgress(_otherTiered, BadgeTier.bronze),
      ],
      existing: existing,
    );
    expect(fresh, hasLength(1));
    expect(fresh.single.badgeId, 'test_other');
  });

  test('ordering is catalogue order, lowest tier first', () {
    final fresh = diff([
      tieredProgress(_tiered, BadgeTier.silver),
      oneOffProgress(earned: true),
      tieredProgress(_otherTiered, BadgeTier.bronze),
    ]);
    expect(
      fresh.map((a) => '${a.badgeId}/${awardTierKey(a.tier)}').toList(),
      [
        'test_tiered/bronze',
        'test_tiered/silver',
        'test_one_off/once',
        'test_other/bronze',
      ],
    );
  });

  test('ids come from the injected factory and are all distinct', () {
    final fresh = diff([tieredProgress(_tiered, BadgeTier.gold)]);
    expect(fresh.map((a) => a.id), ['award-0', 'award-1', 'award-2']);
  });

  test('a local timestamp is normalised to UTC', () {
    final fresh = newlyEarnedAwards(
      progress: [oneOffProgress(earned: true)],
      existingAwards: const [],
      awardedAt: DateTime(2026, 9, 1, 12),
      generateId: nextId,
    );
    expect(fresh.single.awardedAt.isUtc, isTrue);
  });

  test('a duplicate inside one run is emitted once', () {
    final fresh = diff([
      oneOffProgress(earned: true),
      oneOffProgress(earned: true),
    ]);
    expect(fresh, hasLength(1));
  });
}
