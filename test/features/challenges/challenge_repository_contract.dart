import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_repository.dart';

import 'challenge_fixtures.dart';

/// Contract every [ChallengeRepository] must satisfy, run against both
/// implementations.
///
/// It exists because of one bug this file is named after: the Drift
/// repository upserted with `insertOnConflictUpdate`, which overwrites
/// every column including `created_at`, while the in-memory fake used by
/// the presentation tests carefully preserved it. The interface documents
/// preservation
/// (`domain/challenge_repository.dart#saveChallenge`), the fake implemented
/// the document, and the real one did not — so the divergence was invisible
/// from either side's own test file. A contract two implementations run is
/// the only shape of test that can see that.
///
/// Cheap on purpose: one function, called from
/// `challenge_repository_test.dart` (Drift) and
/// `fake_challenge_repository_test.dart` (the fake). Add to it only what
/// both implementations genuinely owe their callers.
Future<void> expectSaveChallengeContract(ChallengeRepository repository) async {
  final first = challengeFrom(
    distanceBlueprint(),
    createdAt: DateTime.utc(2026, 8, 30, 9),
  );
  await repository.saveChallenge(first);

  // The second save is what an import does: same id, a buddy snapshot, and
  // a `createdAt` that came from wherever the caller happened to get one.
  await repository.saveChallenge(
    first.copyWith(
      createdAt: DateTime.utc(2027),
      selfDisplayName: 'Alexandra',
      buddy: ChallengeBuddySnapshot(
        displayName: 'Sam',
        progressPercent: 61,
        asOf: LocalDate(2026, 9, 18),
      ),
    ),
  );

  final stored = (await repository.getChallenge(first.id))!;
  expect(
    stored.createdAt,
    DateTime.utc(2026, 8, 30, 9),
    reason:
        'the first save owns createdAt - callers rely on it so a second '
        'join of a challenge they already hold cannot move the moment they '
        'picked it up (domain/challenge_repository.dart#saveChallenge)',
  );
  expect(
    stored.selfDisplayName,
    'Alexandra',
    reason: 'every other column is still overwritten',
  );
  expect(stored.buddy!.displayName, 'Sam');
  expect(await repository.getChallenges(), hasLength(1));
}
