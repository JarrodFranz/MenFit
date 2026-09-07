import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/achievements/application/award_detector.dart';
import 'package:menfit_app/features/achievements/domain/award_repository.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';

/// An in-memory [AwardRepository] with the same idempotency contract as the
/// Drift one, so this test exercises the detector's behaviour without a
/// database. The Drift implementation's own idempotency is pinned
/// separately in `award_repository_test.dart` — the two must agree, which
/// is why this fake enforces the same unique key rather than accepting
/// anything.
class FakeAwardRepository implements AwardRepository {
  final List<BadgeAward> awards = [];
  int getCallCount = 0;

  @override
  Future<List<BadgeAward>> getAwards() async {
    getCallCount++;
    return List.of(awards.reversed);
  }

  @override
  Stream<List<BadgeAward>> watchAwards() =>
      Stream.value(List.of(awards.reversed));

  @override
  Future<void> recordAward(BadgeAward award) => recordAwards([award]);

  @override
  Future<void> recordAwards(List<BadgeAward> incoming) async {
    for (final award in incoming) {
      final held = awards.any((a) => a.identity == award.identity);
      if (!held) awards.add(award);
    }
  }

  @override
  Future<void> deleteAllData() async => awards.clear();
}

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

const _oneOff = BadgeDefinition.oneOff(
  id: 'test_one_off',
  title: 'Test First',
  description: 'A single award.',
  category: BadgeCategory.movement,
  condition: BadgeCondition.firstActivityLogged,
);

BadgeProgress tieredAt(BadgeTier? tier) => BadgeProgress(
  definition: _tiered,
  value: tier == null ? 0 : _ladder.thresholdFor(tier),
  isEarned: tier != null,
  earnedTier: tier,
  nextTier: tier == null ? BadgeTier.bronze : tier.next,
);

BadgeProgress oneOffAt({required bool earned}) => BadgeProgress(
  definition: _oneOff,
  value: earned ? 1 : 0,
  isEarned: earned,
  progressToNext: earned ? 1 : 0,
);

void main() {
  late FakeAwardRepository repository;
  late AwardDetector detector;
  var idCounter = 0;

  setUp(() {
    repository = FakeAwardRepository();
    idCounter = 0;
    detector = AwardDetector(
      repository,
      clock: () => DateTime.utc(2026, 9, 1, 12),
      generateId: () => 'award-${idCounter++}',
    );
  });

  test('nothing earned records nothing and returns nothing', () async {
    expect(
      await detector.detect([tieredAt(null), oneOffAt(earned: false)]),
      isEmpty,
    );
    expect(repository.awards, isEmpty);
  });

  test('new crossings are recorded and returned', () async {
    final fresh = await detector.detect([
      tieredAt(BadgeTier.silver),
      oneOffAt(earned: true),
    ]);
    expect(fresh.map((a) => '${a.badgeId}/${awardTierKey(a.tier)}'), [
      'test_tiered/bronze',
      'test_tiered/silver',
      'test_one_off/once',
    ]);
    expect(repository.awards, hasLength(3));
  });

  test('a second run over unchanged progress returns nothing new', () async {
    final progress = [tieredAt(BadgeTier.silver), oneOffAt(earned: true)];
    expect(await detector.detect(progress), hasLength(3));
    expect(
      await detector.detect(progress),
      isEmpty,
      reason:
          'the detector runs on screen-open and after every workout, so a '
          'duplicate here would be the same badge celebrated twice',
    );
    expect(repository.awards, hasLength(3));
  });

  test('only the newly crossed tier comes back on the next run', () async {
    await detector.detect([tieredAt(BadgeTier.silver)]);
    final fresh = await detector.detect([tieredAt(BadgeTier.gold)]);
    expect(fresh, hasLength(1));
    expect(fresh.single.tier, BadgeTier.gold);
    expect(repository.awards, hasLength(3));
  });

  test('two tiers crossed between runs both come back, lowest first', () async {
    await detector.detect([tieredAt(BadgeTier.bronze)]);
    final fresh = await detector.detect([tieredAt(BadgeTier.platinum)]);
    expect(fresh.map((a) => a.tier), [
      BadgeTier.silver,
      BadgeTier.gold,
      BadgeTier.platinum,
    ]);
  });

  test('an award already held is never re-dated', () async {
    await detector.detect([oneOffAt(earned: true)]);
    final firstStamp = repository.awards.single.awardedAt;

    final later = AwardDetector(
      repository,
      clock: () => DateTime.utc(2027),
      generateId: () => 'later',
    );
    expect(await later.detect([oneOffAt(earned: true)]), isEmpty);
    expect(repository.awards.single.awardedAt, firstStamp);
  });

  test('a badge whose data was later deleted keeps its award', () async {
    await detector.detect([tieredAt(BadgeTier.gold)]);
    expect(repository.awards, hasLength(3));
    // Progress collapses to nothing (she deleted the sessions).
    expect(await detector.detect([tieredAt(null)]), isEmpty);
    expect(
      repository.awards,
      hasLength(3),
      reason: 'an award is never revoked - the moment happened',
    );
  });

  test('the repository is read once per run', () async {
    await detector.detect([tieredAt(BadgeTier.bronze)]);
    expect(repository.getCallCount, 1);
  });

  test('awards are stamped in UTC even from a local clock', () async {
    final local = AwardDetector(
      repository,
      clock: () => DateTime(2026, 9, 1, 12),
      generateId: () => 'a',
    );
    final fresh = await local.detect([oneOffAt(earned: true)]);
    expect(fresh.single.awardedAt.isUtc, isTrue);
  });
}
