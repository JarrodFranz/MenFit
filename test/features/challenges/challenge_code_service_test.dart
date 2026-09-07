import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/application/challenge_code_service.dart';
import 'package:menfit_app/features/challenges/data/drift_challenge_repository.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_codes.dart';

import 'challenge_fixtures.dart';

void main() {
  late db.AppDatabase database;
  late DriftChallengeRepository repository;
  late ChallengeCodeService service;

  final today = LocalDate(2026, 9, 10);
  final createdAt = DateTime.utc(2026, 9, 10, 8);

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftChallengeRepository(database);
    service = ChallengeCodeService(
      repository,
      clock: () => createdAt,
      generateSalt: () => 0x5BE30C8A,
      generateAuthorTag: () => selfAuthorTag,
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<ChallengeCreated> create({
    ChallengeKind kind = ChallengeKind.totalDistance,
    Set<ActivityType> activityTypes = const {ActivityType.run},
    int targetUnits = 1000,
    String displayName = 'Alex',
  }) async {
    final result = await service.createChallenge(
      kind: kind,
      activityTypes: activityTypes,
      targetUnits: targetUnits,
      windowStart: septemberStart,
      windowEnd: septemberEnd,
      displayName: displayName,
      today: today,
    );
    return result as ChallengeCreated;
  }

  group('createChallenge', () {
    test('persists the challenge and hands back a shareable code', () async {
      final result = await create();

      expect(result.code.startsWith('FC1.'), isTrue);
      expect(result.challenge.origin, ChallengeOrigin.created);
      expect(result.challenge.selfDisplayName, 'Alex');
      expect(result.challenge.createdAt, createdAt);
      expect(result.challenge.buddy, isNull);
      expect(result.challenge.authorTag, selfAuthorTag);
      expect(await repository.getChallenge(result.challenge.id), isNotNull);
    });

    test('the author tag is stamped on the row and survives storage', () async {
      final result = await create();

      expect(
        (await repository.getChallenge(result.challenge.id))!.authorTag,
        selfAuthorTag,
      );
    });

    test('the code decodes to exactly the challenge that was stored', () async {
      final result = await create();

      final decoded = decodeChallengeCode(result.code).valueOrNull!;
      expect(decoded, result.challenge.blueprint);
    });

    test('the display name is trimmed before it is stored', () async {
      final result = await create(displayName: '  Alex  ');

      expect(result.challenge.selfDisplayName, 'Alex');
    });

    test('an invalid request stores nothing and reports every field', () async {
      final result = await service.createChallenge(
        kind: ChallengeKind.totalDistance,
        activityTypes: const {ActivityType.run},
        targetUnits: 0,
        windowStart: septemberStart,
        windowEnd: LocalDate(2027, 9, 30),
        displayName: '',
        today: today,
      );

      expect(result, isA<ChallengeNotCreated>());
      final validation = (result as ChallengeNotCreated).validation;
      expect(validation.targetError, isNotNull);
      expect(validation.windowError, isNotNull);
      expect(validation.displayNameError, isNotNull);
      expect(await repository.getChallenges(), isEmpty);
    });

    test(
      'two identical requests with different salts are two challenges',
      () async {
        final first = await create();
        final second =
            await ChallengeCodeService(
                  repository,
                  clock: () => createdAt,
                  generateSalt: () => 0x0A1B2C3D,
                ).createChallenge(
                  kind: ChallengeKind.totalDistance,
                  activityTypes: const {ActivityType.run},
                  targetUnits: 1000,
                  windowStart: septemberStart,
                  windowEnd: septemberEnd,
                  displayName: 'Alex',
                  today: today,
                )
                as ChallengeCreated;

        expect(second.challenge.id, isNot(first.challenge.id));
        expect(await repository.getChallenges(), hasLength(2));
      },
    );
  });

  group('joinFromCode', () {
    test('joins a challenge from the initiator’s code', () async {
      final code = encodeChallengeCode(distanceBlueprint());

      final result = await service.joinFromCode(
        code,
        displayName: 'Sam',
        today: today,
      );

      expect(result, isA<ChallengeJoined>());
      final joined = (result as ChallengeJoined).challenge;
      expect(joined.origin, ChallengeOrigin.joined);
      expect(joined.selfDisplayName, 'Sam');
      expect(joined.authorTag, selfAuthorTag);
      expect(joined.blueprint, distanceBlueprint());
      expect(await repository.getChallenge(joined.id), isNotNull);
    });

    test('both sides arrive at the same challenge id from one code', () async {
      final created = await create();

      final joined = await service.joinFromCode(
        created.code,
        displayName: 'Sam',
        today: today,
      ) as ChallengeAlreadyJoined;

      expect(
        joined.challenge.id,
        created.challenge.id,
        reason: 'the id is derived from the code, so it cannot diverge',
      );
    });

    test(
      'joining twice is graceful and does not overwrite local state',
      () async {
        final code = encodeChallengeCode(distanceBlueprint());
        await service.joinFromCode(code, displayName: 'Sam', today: today);
        // Something happened locally in between: a progress code landed.
        final stored = (await repository.getChallenges()).single;
        await repository.saveChallenge(
          stored.copyWith(
            buddy: ChallengeBuddySnapshot(
              displayName: 'Alex',
              progressPercent: 55,
              asOf: LocalDate(2026, 9, 9),
            ),
          ),
        );

        final result = await service.joinFromCode(
          code,
          displayName: 'A Different Name',
          today: today,
        );

        expect(result, isA<ChallengeAlreadyJoined>());
        final existing = (result as ChallengeAlreadyJoined).challenge;
        expect(existing.selfDisplayName, 'Sam');
        expect(existing.buddy!.progressPercent, 55);
        expect(await repository.getChallenges(), hasLength(1));
      },
    );

    test(
      'a corrupt code is rejected with its reason and stores nothing',
      () async {
        final code = encodeChallengeCode(distanceBlueprint());
        final tampered =
            'FC1.${code[4] == 'A' ? 'B' : 'A'}${code.substring(5)}';

        final result = await service.joinFromCode(
          tampered,
          displayName: 'Sam',
          today: today,
        );

        expect(
          result,
          isA<ChallengeCodeUnusable>().having(
            (r) => r.reason,
            'reason',
            CodeRejection.checksumFailed,
          ),
        );
        expect(await repository.getChallenges(), isEmpty);
      },
    );

    test('a progress code pasted into the join box says so', () async {
      final progressCode = buddyProgressCode(
        challengeId: distanceBlueprint().id,
        displayName: 'Sam',
        progressPercent: 40,
        asOf: today,
      );

      final result = await service.joinFromCode(
        progressCode,
        displayName: 'Sam',
        today: today,
      );

      expect(
        result,
        isA<ChallengeCodeUnusable>().having(
          (r) => r.reason,
          'reason',
          CodeRejection.wrongCodeKind,
        ),
      );
    });

    test('a valid code with a name she cannot use is a validation result, '
        'not a code failure', () async {
      final result = await service.joinFromCode(
        encodeChallengeCode(distanceBlueprint()),
        displayName: '',
        today: today,
      );

      expect(result, isA<ChallengeJoinRejected>());
      expect(
        (result as ChallengeJoinRejected).validation.displayNameError,
        isNotNull,
      );
      expect(await repository.getChallenges(), isEmpty);
    });

    test(
      'a code whose window this build considers absurd is rejected',
      () async {
        final ancient = encodeChallengeCode(
          distanceBlueprint(
            windowStart: LocalDate(2021, 1, 1),
            windowEnd: LocalDate(2021, 1, 31),
          ),
        );

        final result = await service.joinFromCode(
          ancient,
          displayName: 'Sam',
          today: today,
        );

        expect(result, isA<ChallengeJoinRejected>());
        expect(await repository.getChallenges(), isEmpty);
      },
    );
  });

  group('progressCodeFor', () {
    test('exports the challenge id and her chosen name', () async {
      final created = await create();

      final code = service.progressCodeFor(
        created.challenge,
        progressPercent: 64.2,
        asOf: LocalDate(2026, 9, 18),
      );

      final payload = decodeProgressCode(code).valueOrNull!;
      expect(payload.challengeId, created.challenge.id);
      expect(payload.displayName, 'Alex');
      expect(payload.progressPercent, closeTo(64.2, 0.05));
      expect(payload.asOf, LocalDate(2026, 9, 18));
      expect(
        payload.authorTag,
        selfAuthorTag,
        reason: 'the code she sends carries this device tag, not a fresh one',
      );
    });
  });

  group('importProgressCode', () {
    Future<Challenge> joinedChallenge() async {
      final result = await service.joinFromCode(
        encodeChallengeCode(distanceBlueprint()),
        displayName: 'Sam',
        today: today,
      ) as ChallengeJoined;
      return result.challenge;
    }

    String buddyCode(
      String challengeId,
      double percent,
      LocalDate asOf, {
      String displayName = 'Alex',
    }) {
      return buddyProgressCode(
        challengeId: challengeId,
        displayName: displayName,
        progressPercent: percent,
        asOf: asOf,
      );
    }

    test('a first snapshot lands on the matching challenge', () async {
      final challenge = await joinedChallenge();

      final result = await service.importProgressCode(
        buddyCode(challenge.id, 42.5, LocalDate(2026, 9, 12)),
      );

      expect(result, isA<BuddyProgressImported>());
      final buddy = (await repository.getChallenge(challenge.id))!.buddy!;
      expect(buddy.displayName, 'Alex');
      expect(buddy.progressPercent, closeTo(42.5, 0.05));
      expect(buddy.asOf, LocalDate(2026, 9, 12));
    });

    test('a newer snapshot replaces an older one', () async {
      final challenge = await joinedChallenge();
      await service.importProgressCode(
        buddyCode(challenge.id, 42.5, LocalDate(2026, 9, 12)),
      );

      await service.importProgressCode(
        buddyCode(challenge.id, 71, LocalDate(2026, 9, 18)),
      );

      final buddy = (await repository.getChallenge(challenge.id))!.buddy!;
      expect(buddy.progressPercent, closeTo(71, 0.05));
      expect(buddy.asOf, LocalDate(2026, 9, 18));
    });

    test('an older code pasted late cannot regress the snapshot', () async {
      // The ordering case this exists for: codes travel through chat
      // threads, so Monday's can perfectly well arrive after Wednesday's.
      final challenge = await joinedChallenge();
      await service.importProgressCode(
        buddyCode(challenge.id, 71, LocalDate(2026, 9, 18)),
      );

      final result = await service.importProgressCode(
        buddyCode(challenge.id, 42.5, LocalDate(2026, 9, 12)),
      );

      expect(result, isA<BuddyProgressNotNewer>());
      final buddy = (await repository.getChallenge(challenge.id))!.buddy!;
      expect(
        buddy.progressPercent,
        closeTo(71, 0.05),
        reason: "her buddy's progress must never appear to fall",
      );
      expect(buddy.asOf, LocalDate(2026, 9, 18));
    });

    test(
      're-pasting the identical code is idempotent, not a downgrade',
      () async {
        final challenge = await joinedChallenge();
        final code = buddyCode(challenge.id, 71, LocalDate(2026, 9, 18));
        await service.importProgressCode(code);

        final result = await service.importProgressCode(code);

        expect(result, isA<BuddyProgressNotNewer>());
        final buddy = (await repository.getChallenge(challenge.id))!.buddy!;
        expect(buddy.progressPercent, closeTo(71, 0.05));
      },
    );

    test('a second code for the same day is applied, not refused', () async {
      // She trained twice on Friday and sent two codes. The one her buddy
      // pasted last is the one her buddy chose to paste, and refusing it
      // would leave the morning's figure on screen all weekend.
      final challenge = await joinedChallenge();
      await service.importProgressCode(
        buddyCode(challenge.id, 71, LocalDate(2026, 9, 18)),
      );

      final result = await service.importProgressCode(
        buddyCode(challenge.id, 78.5, LocalDate(2026, 9, 18)),
      );

      expect(result, isA<BuddyProgressImported>());
      final buddy = (await repository.getChallenge(challenge.id))!.buddy!;
      expect(buddy.progressPercent, closeTo(78.5, 0.05));
      expect(buddy.asOf, LocalDate(2026, 9, 18));
    });

    test('a same-day code that only renames her is applied too', () async {
      final challenge = await joinedChallenge();
      await service.importProgressCode(
        buddyCode(challenge.id, 71, LocalDate(2026, 9, 18)),
      );

      final result = await service.importProgressCode(
        buddyCode(
          challenge.id,
          71,
          LocalDate(2026, 9, 18),
          displayName: 'Alexandra',
        ),
      );

      expect(result, isA<BuddyProgressImported>());
      expect(
        (await repository.getChallenge(challenge.id))!.buddy!.displayName,
        'Alexandra',
      );
    });

    test('her own code pasted back is refused, and changes nothing', () async {
      // The self-import the author tag exists for: without it this code
      // would land under the buddy's name carrying the user's own figure -
      // a wrong number about someone else that looks like a right one.
      final challenge = await joinedChallenge();
      await service.importProgressCode(
        buddyCode(challenge.id, 42.5, LocalDate(2026, 9, 12)),
      );

      final result = await service.importProgressCode(
        service.progressCodeFor(
          challenge,
          progressPercent: 91,
          asOf: LocalDate(2026, 9, 18),
        ),
      );

      expect(result, isA<BuddyProgressIsYourOwn>());
      final buddy = (await repository.getChallenge(challenge.id))!.buddy!;
      expect(buddy.displayName, 'Alex');
      expect(
        buddy.progressPercent,
        closeTo(42.5, 0.05),
        reason: "her own percentage must never land under her buddy's name",
      );
      expect(buddy.asOf, LocalDate(2026, 9, 12));
    });

    test('her own code is refused even when nothing is stored yet', () async {
      final challenge = await joinedChallenge();

      final result = await service.importProgressCode(
        service.progressCodeFor(
          challenge,
          progressPercent: 91,
          asOf: LocalDate(2026, 9, 18),
        ),
      );

      expect(result, isA<BuddyProgressIsYourOwn>());
      expect((await repository.getChallenge(challenge.id))!.buddy, isNull);
    });

    test(
      'the buddy device draws its own tag, so her codes still land',
      () async {
        // Both sides run the same code path: the joiner's tag is drawn on
        // her device, the creator's on hers, and neither ever sees the
        // other's until a code arrives.
        final challenge = await joinedChallenge();
        final herDevice = ChallengeCodeService(
          repository,
          clock: () => createdAt,
          generateSalt: () => 0x5BE30C8A,
          generateAuthorTag: () => buddyAuthorTag,
        );

        final result = await service.importProgressCode(
          herDevice.progressCodeFor(
            challenge.copyWith(
              selfDisplayName: 'Alex',
              authorTag: buddyAuthorTag,
            ),
            progressPercent: 64,
            asOf: LocalDate(2026, 9, 18),
          ),
        );

        expect(result, isA<BuddyProgressImported>());
        expect(
          (await repository.getChallenge(challenge.id))!.buddy!.progressPercent,
          closeTo(64, 0.05),
        );
      },
    );

    test('a code for a challenge this device does not hold says so', () async {
      await joinedChallenge();

      final result = await service.importProgressCode(
        buddyCode(sessionBlueprint().id, 50, LocalDate(2026, 9, 12)),
      );

      expect(result, isA<BuddyProgressUnknownChallenge>());
    });

    test('a corrupt progress code is rejected with its reason', () async {
      final challenge = await joinedChallenge();
      final code = buddyCode(challenge.id, 50, LocalDate(2026, 9, 12));
      final tampered = 'FP1.${code[4] == 'A' ? 'B' : 'A'}${code.substring(5)}';

      final result = await service.importProgressCode(tampered);

      expect(
        result,
        isA<BuddyProgressUnusable>().having(
          (r) => r.reason,
          'reason',
          CodeRejection.checksumFailed,
        ),
      );
      expect((await repository.getChallenge(challenge.id))!.buddy, isNull);
    });

    test('a challenge code pasted into the progress box says so', () async {
      await joinedChallenge();

      final result = await service.importProgressCode(
        encodeChallengeCode(distanceBlueprint()),
      );

      expect(
        result,
        isA<BuddyProgressUnusable>().having(
          (r) => r.reason,
          'reason',
          CodeRejection.wrongCodeKind,
        ),
      );
    });

    test('importing touches only the buddy fields', () async {
      final challenge = await joinedChallenge();

      await service.importProgressCode(
        buddyCode(challenge.id, 42.5, LocalDate(2026, 9, 12)),
      );

      final stored = (await repository.getChallenge(challenge.id))!;
      expect(stored.blueprint, challenge.blueprint);
      expect(stored.selfDisplayName, 'Sam');
      expect(stored.origin, ChallengeOrigin.joined);
      expect(stored.createdAt, challenge.createdAt);
    });
  });
}
