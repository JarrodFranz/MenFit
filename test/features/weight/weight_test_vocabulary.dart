import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The judgement vocabulary the weight feature must never say, in one
/// place.
///
/// Body weight is the most eating-disorder-sensitive surface in the app
/// (`knowledge/domain/mens_health.md`), and the cheapest way to stop a
/// well-meaning edit turning a description into a verdict is to make the
/// verdict vocabulary fail the build. Two gates read this one list:
///
/// * `weight_copy_test.dart` runs it over every string in
///   `presentation/weight_copy.dart` and every message
///   `domain/weight_validation.dart` can produce;
/// * `weight_screen_test.dart` runs it over what the assembled screen
///   actually renders — including the copy that lives in widgets rather
///   than in `weight_copy.dart`.
///
/// It is one list on purpose. It used to be two, and they had drifted:
/// the widget-level copy was checked against twelve words while the string
/// constants were checked against twenty-six, so a widget could legally
/// say "target" or "should". A word added here now fails both gates.
///
/// Matching is case-insensitive substring, so entries are lowercase and
/// the ones that would otherwise fire inside an innocent word carry a
/// trailing space (`'bad '` must not match "badge").
const List<String> forbiddenWeightVocabulary = [
  'gain',
  'loss',
  'lose',
  'losing',
  'progress',
  'goal',
  'target',
  'ideal',
  'healthy weight',
  'overweight',
  'underweight',
  'obes',
  'bmi',
  'should',
  'must ',
  'congrat',
  'well done',
  'keep it up',
  'on track',
  'off track',
  'good',
  'bad ',
  'better',
  'worse',
  'burn',
  'excess',
];

/// Fails if [text] contains any of [forbiddenWeightVocabulary].
///
/// [source] names where the string came from, so a failure says which
/// widget or constant to go and fix.
void expectNoJudgementVocabulary(String text, {required String source}) {
  final lowercase = text.toLowerCase();
  for (final word in forbiddenWeightVocabulary) {
    expect(
      lowercase,
      isNot(contains(word)),
      reason:
          '"$word" in $source turns a measurement into a judgement '
          '(knowledge/domain/mens_health.md)',
    );
  }
}

/// Tears the tree down and pumps once so live Drift stream timers fire and
/// cancel instead of being reported as pending.
///
/// Without it, a widget test that mounts an autoDispose provider over a
/// Drift `watch` query ends with "A Timer is still pending even after the
/// widget tree was disposed": drift's `StreamQueryStore` schedules a
/// zero-duration cleanup timer when a query stream loses its last
/// listener, and flutter_test's own end-of-test unmount pumps without
/// advancing fake time, so the timer is still on the queue when the
/// invariant is checked. Same helper, same reason, as the copies in
/// `test/features/nutrition/nutrition_day_screen_test.dart` and
/// `test/features/progress/progress_screen_test.dart`; see the 2026-08-26
/// entry in the central `testing-pitfalls.md`.
///
/// **Call it as the last statement of the test body.**
/// `TestWidgetsFlutterBinding._runTestBody` verifies its invariants
/// immediately after the body returns and *before* any `addTearDown`
/// callback runs, so registering this as a teardown cannot stop the
/// assertion — it is too late by construction.
///
/// Registering it as a teardown as *well* is still worth doing, and the
/// pump helpers in this suite do. It does not prevent the failure, but it
/// contains it: without it, the failed invariant leaves the drift executor
/// mid-flight and every later test in the file wedges at zero CPU with
/// `--timeout` never firing (the 2026-09-01 entry in the same document).
/// With it, one forgotten call is one ordinary red test instead of a dead
/// suite.
Future<void> flushDriftTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}
