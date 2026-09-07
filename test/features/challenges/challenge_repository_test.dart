import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/data/drift_challenge_repository.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';

import 'challenge_fixtures.dart';
import 'challenge_repository_contract.dart';

void main() {
  late db.AppDatabase database;
  late DriftChallengeRepository repository;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftChallengeRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('an empty store reads as an empty list, not an error', () async {
    expect(await repository.getChallenges(), isEmpty);
    expect(await repository.getChallenge('nope'), isNull);
  });

  test('a challenge round-trips through storage', () async {
    final challenge = challengeFrom(distanceBlueprint());

    await repository.saveChallenge(challenge);

    final stored = await repository.getChallenge(challenge.id);
    expect(stored, challenge);
    expect(stored!.createdAt.isUtc, isTrue);
  });

  test('an any-type challenge round-trips its empty type set', () async {
    final challenge = challengeFrom(
      sessionBlueprint(activityTypes: const {}),
    );

    await repository.saveChallenge(challenge);

    expect(await repository.getChallenge(challenge.id), challenge);
  });

  test('a multi-type set round-trips whatever order it was built in', () async {
    final challenge = challengeFrom(
      sessionBlueprint(
        activityTypes: const {
          ActivityType.swim,
          ActivityType.run,
          ActivityType.yoga,
        },
      ),
    );

    await repository.saveChallenge(challenge);

    expect(
      (await repository.getChallenge(challenge.id))!.blueprint.activityTypes,
      {ActivityType.swim, ActivityType.run, ActivityType.yoga},
    );
  });

  test('a buddy snapshot round-trips, and its absence reads as null', () async {
    final without = challengeFrom(distanceBlueprint(salt: 1));
    final with_ = challengeFrom(
      distanceBlueprint(salt: 2),
      buddy: ChallengeBuddySnapshot(
        displayName: 'Sam',
        progressPercent: 142.5,
        asOf: LocalDate(2026, 9, 18),
      ),
    );

    await repository.saveChallenge(without);
    await repository.saveChallenge(with_);

    expect((await repository.getChallenge(without.id))!.buddy, isNull);
    final buddy = (await repository.getChallenge(with_.id))!.buddy!;
    expect(buddy.displayName, 'Sam');
    expect(buddy.progressPercent, 142.5);
    expect(buddy.asOf, LocalDate(2026, 9, 18));
  });

  test('saving the same id twice updates rather than duplicating', () async {
    final challenge = challengeFrom(distanceBlueprint());
    await repository.saveChallenge(challenge);

    await repository.saveChallenge(
      challenge.copyWith(
        buddy: ChallengeBuddySnapshot(
          displayName: 'Sam',
          progressPercent: 40,
          asOf: LocalDate(2026, 9, 10),
        ),
      ),
    );

    final all = await repository.getChallenges();
    expect(all, hasLength(1));
    expect(all.single.buddy!.displayName, 'Sam');
  });

  test('the first save owns createdAt, whatever a later one says', () async {
    await expectSaveChallengeContract(repository);
  });

  test('the author tag round-trips and is not part of the id', () async {
    final blueprint = distanceBlueprint();
    final challenge = challengeFrom(blueprint, authorTag: 0xFFFFFFFF);

    await repository.saveChallenge(challenge);

    final stored = (await repository.getChallenge(challenge.id))!;
    expect(stored.authorTag, 0xFFFFFFFF);
    expect(
      stored.id,
      challengeFrom(blueprint, authorTag: 1).id,
      reason:
          'two devices in one challenge hold different tags and the same '
          'id - the tag is local, not shared identity',
    );
  });

  test('a half-written buddy row reads as no buddy at all', () async {
    // The three buddy columns are written together by the repository, so
    // this shape can only come from outside it - a hand-edited database, a
    // future migration, a bug. A snapshot with a name but no date cannot be
    // compared for freshness, so it must read as nothing rather than as a
    // half-known buddy (drift_challenge_repository.dart#_toEntity).
    final challenge = challengeFrom(distanceBlueprint());
    await repository.saveChallenge(challenge);
    await database.customStatement(
      "UPDATE challenges SET buddy_display_name = 'Sam' WHERE id = ?",
      [challenge.id],
    );

    final stored = (await repository.getChallenge(challenge.id))!;

    expect(stored.buddy, isNull);
  });

  test('reads come back newest window first', () async {
    final august = challengeFrom(
      distanceBlueprint(
        windowStart: LocalDate(2026, 8, 1),
        windowEnd: LocalDate(2026, 8, 31),
      ),
    );
    final september = challengeFrom(distanceBlueprint());
    final october = challengeFrom(
      distanceBlueprint(
        windowStart: LocalDate(2026, 10, 1),
        windowEnd: LocalDate(2026, 10, 31),
      ),
    );

    await repository.saveChallenge(september);
    await repository.saveChallenge(october);
    await repository.saveChallenge(august);

    expect(
      (await repository.getChallenges()).map((c) => c.id),
      [october.id, september.id, august.id],
    );
  });

  test('the watch/get twins agree on content and ordering', () async {
    await repository.saveChallenge(challengeFrom(distanceBlueprint(salt: 1)));
    await repository.saveChallenge(
      challengeFrom(
        distanceBlueprint(
          salt: 2,
          windowStart: LocalDate(2026, 10, 1),
          windowEnd: LocalDate(2026, 10, 31),
        ),
      ),
    );

    final watched = await repository.watchChallenges().first;
    expect(watched, await repository.getChallenges());
  });

  test('watchChallenge emits null once its row is deleted', () async {
    final challenge = challengeFrom(distanceBlueprint());
    await repository.saveChallenge(challenge);

    final emissions = <Challenge?>[];
    final subscription = repository
        .watchChallenge(challenge.id)
        .listen(emissions.add);
    await pumpEventQueue();

    await repository.deleteChallenge(challenge.id);
    await pumpEventQueue();
    await subscription.cancel();

    expect(emissions.first, challenge);
    expect(emissions.last, isNull);
  });

  test('deleting a challenge that is not there is a no-op', () async {
    await repository.saveChallenge(challengeFrom(distanceBlueprint()));

    await repository.deleteChallenge('not-a-real-id');

    expect(await repository.getChallenges(), hasLength(1));
  });

  test('deleteAllData is a hard delete - nothing is left hiding', () async {
    await repository.saveChallenge(challengeFrom(distanceBlueprint(salt: 1)));
    await repository.saveChallenge(
      challengeFrom(
        distanceBlueprint(salt: 2),
        buddy: ChallengeBuddySnapshot(
          displayName: 'Sam',
          progressPercent: 50,
          asOf: LocalDate(2026, 9, 10),
        ),
      ),
    );

    await repository.deleteAllData();

    expect(await repository.getChallenges(), isEmpty);
    expect(
      await database.select(database.challenges).get(),
      isEmpty,
      reason: 'there is no soft-delete column for a row to hide behind',
    );
  });
}
