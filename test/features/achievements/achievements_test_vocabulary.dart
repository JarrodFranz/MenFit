import 'package:flutter_test/flutter_test.dart';

/// The vocabulary no achievement string may contain, in one place.
///
/// A badge exists to celebrate something that already happened. The moment
/// one starts telling the user what she *should* do, implies she is behind,
/// ranks her against anyone, or mentions her body, it has stopped being a
/// celebration and become a demand — and a well-meaning copy edit is
/// exactly how that happens. This list makes such an edit fail the build.
///
/// Same shape and reasoning as
/// `test/features/weight/weight_test_vocabulary.dart` and
/// `test/features/insights/insight_sentence_test.dart`; the two lists are
/// deliberately separate because they guard different risks (that one is
/// ED-specific and bans words that are perfectly fine here, like
/// "congratulations"), but every entry there that applies to *any* copy —
/// body vocabulary, obligation, judgement — is repeated here.
///
/// Kept in its own file, not inside a test's `main`, so the widget-level
/// sweep the presentation half will add can read the same list rather than
/// growing a second one that drifts (the mistake
/// `weight_test_vocabulary.dart` records having already been made once).
///
/// Matching is case-insensitive substring, so entries are lowercase and any
/// that would fire inside an innocent word carry a trailing space.
const List<String> forbiddenAchievementVocabulary = [
  // Body, weight, appearance — no badge is ever about these.
  'weight',
  'gain',
  'loss',
  'lose',
  'losing',
  'fat ',
  'body fat',
  'calorie',
  'burn',
  'bmi',
  'obes',
  'overweight',
  'underweight',
  'diet',
  'slim',
  'toned',
  // Obligation.
  'should',
  'must ',
  'need to',
  'have to',
  'ought',
  'goal',
  'target',
  'quota',
  // Shortfall framing — a quiet week is never a failure, and a rest is
  // never a lapse (knowledge/product/terminology.md).
  'fail',
  'missed',
  'behind',
  'lazy',
  'excuse',
  'skipped',
  'lapse',
  'never miss',
  'every day',
  // Judgement and comparison.
  'better',
  'worse',
  'good',
  'bad ',
  'perfect',
  'leaderboard',
  'competit',
  'rank',
  'beat ',
];

/// Fails if [text] contains any of [forbiddenAchievementVocabulary].
///
/// [source] names where the string came from, so a failure says which badge
/// or label to go and fix.
void expectNoForbiddenAchievementVocabulary(
  String text, {
  required String source,
}) {
  final lowercase = text.toLowerCase();
  for (final word in forbiddenAchievementVocabulary) {
    expect(
      lowercase,
      isNot(contains(word)),
      reason:
          '"$word" in $source turns a celebration into a demand '
          '(see domain/badge_catalogue.dart rules 4 and 5)',
    );
  }
}
