import 'package:flutter_test/flutter_test.dart';

import 'challenge_repository_contract.dart';
import 'fake_challenge_repository.dart';

/// The fake the presentation tests run against, held to the same contract
/// as the real one.
///
/// Worth its own file for one reason: the fake used to be the *only*
/// implementation that honoured `saveChallenge`'s createdAt promise, and
/// because nothing checked both, the screens were tested against a
/// repository that behaved better than the one they ship with. A fake that
/// is kinder than the real thing is a fake that hides bugs
/// (`challenge_repository_contract.dart`).
void main() {
  test('the fake honours the same saveChallenge contract', () async {
    final repository = FakeChallengeRepository();
    addTearDown(repository.dispose);

    await expectSaveChallengeContract(repository);
  });
}
