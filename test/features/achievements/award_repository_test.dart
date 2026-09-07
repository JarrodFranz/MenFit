import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/features/achievements/data/drift_award_repository.dart';
import 'package:menfit_app/features/achievements/domain/badge_award.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';

void main() {
  late db.AppDatabase database;
  late DriftAwardRepository repository;

  final stamp = DateTime.utc(2026, 9, 1, 12);

  // `tier` is required rather than defaulted so every call site says
  // which rung it means - including the one-off cases, where `null` is
  // the point of the test.
  BadgeAward award({
    required String id,
    required BadgeTier? tier,
    String badgeId = 'run_distance',
    DateTime? at,
  }) {
    return BadgeAward(
      id: id,
      badgeId: badgeId,
      awardedAt: at ?? stamp,
      tier: tier,
    );
  }

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftAwardRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('an empty store reads as an empty list, not an error', () async {
    expect(await repository.getAwards(), isEmpty);
  });

  test('an award round-trips through storage', () async {
    await repository.recordAward(
      award(id: 'a1', tier: BadgeTier.gold),
    );
    final rows = await repository.getAwards();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'a1');
    expect(rows.single.badgeId, 'run_distance');
    expect(rows.single.tier, BadgeTier.gold);
    expect(rows.single.awardedAt, stamp);
    expect(rows.single.awardedAt.isUtc, isTrue);
  });

  test('a one-off award round-trips with a null tier', () async {
    await repository.recordAward(
      award(id: 'a1', tier: null, badgeId: 'first_activity'),
    );
    final rows = await repository.getAwards();
    expect(rows.single.tier, isNull);
    expect(rows.single.identity, ('first_activity', oneOffAwardTierKey));
  });

  test('a high diamond level survives the round trip', () async {
    await repository.recordAward(
      award(id: 'a1', tier: BadgeTier.diamond(7)),
    );
    expect((await repository.getAwards()).single.tier, BadgeTier.diamond(7));
  });

  group('idempotency', () {
    test('recording the same badge and tier twice is a no-op', () async {
      await repository.recordAward(award(id: 'first', tier: BadgeTier.bronze));
      await repository.recordAward(
        award(id: 'second', tier: BadgeTier.bronze, at: DateTime.utc(2027)),
      );

      final rows = await repository.getAwards();
      expect(rows, hasLength(1));
      expect(rows.single.id, 'first', reason: 'the first award stands');
      expect(
        rows.single.awardedAt,
        stamp,
        reason: 'the moment they earned it must not move',
      );
    });

    test('recording the same one-off twice is a no-op', () async {
      // The sentinel tier key exists precisely so this holds: with a NULL
      // tier column SQLite would treat the two rows as distinct.
      await repository.recordAward(
        award(id: 'first', tier: null, badgeId: 'first_activity'),
      );
      await repository.recordAward(
        award(id: 'second', tier: null, badgeId: 'first_activity'),
      );
      expect(await repository.getAwards(), hasLength(1));
    });

    test('a duplicate in a LATER batch does not abort that batch', () async {
      await repository.recordAwards([
        award(id: 'a1', tier: BadgeTier.bronze),
        award(id: 'a2', tier: BadgeTier.silver),
      ]);
      await repository.recordAwards([
        award(id: 'a3', tier: BadgeTier.bronze),
        award(id: 'a4', tier: BadgeTier.gold),
      ]);
      final tiers = (await repository.getAwards()).map((a) => a.tier).toSet();
      expect(tiers, {BadgeTier.bronze, BadgeTier.silver, BadgeTier.gold});
    });

    test(
      'a duplicate WITHIN one batch is dropped, and the rest land',
      () async {
        // The case the earlier test's name claimed but did not cover: the
        // conflict resolved inside a single `insertAll`, where an aborting
        // batch would take the *other* awards down with the duplicate.
        await repository.recordAwards([
          award(id: 'a1', tier: BadgeTier.bronze),
          award(id: 'a2', tier: BadgeTier.bronze),
          award(id: 'a3', tier: BadgeTier.silver),
        ]);

        final rows = await repository.getAwards();
        expect(rows, hasLength(2));
        expect(rows.map((a) => a.tier).toSet(), {
          BadgeTier.bronze,
          BadgeTier.silver,
        });
        expect(
          rows.map((a) => a.id),
          isNot(contains('a2')),
          reason: 'the first of the pair stands, as it does across batches',
        );
      },
    );

    test('different tiers of one badge coexist', () async {
      await repository.recordAwards([
        award(id: 'a1', tier: BadgeTier.bronze),
        award(id: 'a2', tier: BadgeTier.silver),
        award(id: 'a3', tier: BadgeTier.gold),
      ]);
      expect(await repository.getAwards(), hasLength(3));
    });

    test('the same tier on different badges coexists', () async {
      await repository.recordAwards([
        award(id: 'a1', tier: BadgeTier.bronze),
        award(id: 'a2', tier: BadgeTier.bronze, badgeId: 'ride_distance'),
      ]);
      expect(await repository.getAwards(), hasLength(2));
    });

    test('recording an empty list is a no-op', () async {
      await repository.recordAwards(const []);
      expect(await repository.getAwards(), isEmpty);
    });
  });

  test('awards come back newest first', () async {
    await repository.recordAwards([
      award(id: 'old', tier: BadgeTier.bronze, at: DateTime.utc(2026)),
      award(id: 'new', tier: BadgeTier.silver, at: DateTime.utc(2026, 6)),
      award(id: 'mid', tier: BadgeTier.gold, at: DateTime.utc(2026, 3)),
    ]);
    expect(
      (await repository.getAwards()).map((a) => a.id),
      ['new', 'mid', 'old'],
    );
  });

  test('watchAwards emits the same shape as getAwards', () async {
    await repository.recordAwards([
      award(id: 'a1', tier: BadgeTier.bronze, at: DateTime.utc(2026)),
      award(id: 'a2', tier: BadgeTier.silver, at: DateTime.utc(2026, 6)),
    ]);
    final watched = await repository.watchAwards().first;
    expect(watched.map((a) => a.id), ['a2', 'a1']);
    expect(watched, await repository.getAwards());
  });

  test('deleteAllData removes every award', () async {
    await repository.recordAwards([
      award(id: 'a1', tier: BadgeTier.bronze),
      award(id: 'a2', tier: null, badgeId: 'first_activity'),
    ]);
    await repository.deleteAllData();
    expect(await repository.getAwards(), isEmpty);
    expect(await database.select(database.badgeAwards).get(), isEmpty);
  });

  test('deleting an empty store is a no-op', () async {
    await repository.deleteAllData();
    expect(await repository.getAwards(), isEmpty);
  });

  test(
    'an unrecognised stored tier key reads as no tier, not a crash',
    () async {
      // A row written by a newer build than this one. An old app meeting it
      // must render a trophy case, not throw.
      await database
          .into(database.badgeAwards)
          .insert(
            db.BadgeAwardsCompanion.insert(
              id: 'future',
              badgeId: 'run_distance',
              tierKey: 'titanium',
              awardedAt: stamp.millisecondsSinceEpoch,
            ),
          );
      expect((await repository.getAwards()).single.tier, isNull);
    },
  );
}
