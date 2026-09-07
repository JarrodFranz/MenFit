import 'package:flutter_test/flutter_test.dart';

/// The vocabulary no buddy-challenge string may contain, in one place.
///
/// Two rules are load-bearing here, and both are the kind that a
/// well-meaning copy edit breaks without anyone noticing:
///
/// 1. **No ranking is expressible, so none may be implied.** The domain
///    layer cannot say who is ahead
///    (`lib/features/challenges/domain/challenge_progress.dart`: a
///    participant has a name, a percentage and "did she reach her own
///    goal", and there is no ordering, no delta and no leader). A single
///    sentence saying "you're winning" would put back what the model was
///    shaped to refuse.
/// 2. **Nothing cycle-related appears on a challenge surface, ever.**
///    These are the screens most likely to be shown to another person —
///    that is the premise of the feature — so a phase name, a period, or
///    a flare on one of them hands over S3 data
///    (`knowledge/engineering/security_and_privacy.md`) to the one person
///    best placed to notice it.
///
/// Same shape and reasoning as
/// `test/features/weight/weight_test_vocabulary.dart` and
/// `test/features/achievements/achievements_test_vocabulary.dart`, and
/// kept in its own file for the same reason: several gates read this one
/// list — `challenges_copy_test.dart` over the string constants and every
/// validation message, and the widget-level sweeps in
/// `challenges_screen_test.dart` and `challenge_detail_screen_test.dart`
/// over what the assembled screens actually render. One list means a word
/// added here fails every gate at once.
///
/// **"goal" and "target" are deliberately absent**, unlike in the
/// achievements list. A challenge *is* a shared target, saying so is
/// honest, and `fairnessNote` — the one sentence allowed to acknowledge
/// that each target flexes — needs the word. What that list guards
/// against (a celebration turning into a demand) is guarded here by the
/// obligation entries instead.
///
/// **One string on these screens is exempt: the code body itself**
/// (`presentation/widgets/challenge_code_panel.dart#challengeCodeTextKey`).
/// It is base64url of a binary payload rather than copy, and a random
/// 58-character body contains a three-letter entry from this list — "pms",
/// "bmi" — about once in a few hundred codes. Sweeping it would have made
/// every one of these gates intermittently red for no gain, and a flaky
/// privacy gate is a privacy gate somebody eventually deletes. The labels
/// around it, including the privacy notes, are swept as usual.
///
/// Matching is case-insensitive substring, so entries are lowercase and
/// any that would fire inside an innocent word carry a trailing space.
const List<String> forbiddenChallengeVocabulary = [
  // Ranking. The whole point.
  'winner',
  'winning',
  'win ',
  'won the',
  'loser',
  'losing',
  'lost',
  'ahead',
  'behind',
  'beat ',
  'beating',
  'versus',
  ' vs',
  'rank',
  'leaderboard',
  'leader',
  'compet',
  'outpac',
  'overtak',
  'catch up',
  'catching up',
  'defeat',
  'against her',
  'first place',
  'second place',
  // Obligation.
  'should',
  'must ',
  'need to',
  'have to',
  'ought',
  // Shortfall framing — a quiet week is never a failure and a rest is
  // never a lapse (knowledge/product/terminology.md).
  'fail',
  'missed',
  'lazy',
  'excuse',
  'skipped',
  'lapse',
  'slack',
  // Judgement.
  'better',
  'worse',
  'good',
  'bad ',
  'perfect',
  // Body and appearance — a challenge is about what she did, never about
  // her body.
  'weight',
  'calorie',
  'burn',
  'diet',
  'fat ',
  'bmi',
  'slim',
  'toned',
  // Cycle vocabulary. Never, on any challenge surface, under any setting.
  'period',
  'cycle',
  'menstrual',
  'luteal',
  'follicular',
  'ovulat',
  'flare',
  'hormone',
  'pms',
];

/// Fails if [text] contains any of [forbiddenChallengeVocabulary].
///
/// [source] names where the string came from, so a failure says which
/// widget or constant to go and fix.
void expectNoForbiddenChallengeVocabulary(
  String text, {
  required String source,
}) {
  final lowercase = text.toLowerCase();
  for (final word in forbiddenChallengeVocabulary) {
    expect(
      lowercase,
      isNot(contains(word)),
      reason:
          '"$word" in $source either implies a ranking this feature cannot '
          'express, or puts cycle data on a screen built to be shown to '
          'someone else (see the copy rules on '
          'lib/features/challenges/presentation/challenges_copy.dart)',
    );
  }
}
