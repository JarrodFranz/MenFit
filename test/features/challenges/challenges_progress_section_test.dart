import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/challenges_widgets.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';

import '../weight/weight_test_vocabulary.dart' show flushDriftTimers;
import 'challenge_fixtures.dart';
import 'challenges_test_vocabulary.dart';
import 'fake_challenge_repository.dart';

final LocalDate _today = LocalDate(2026, 9, 20);

void main() {
  late FakeChallengeRepository repository;

  /// How many times the card caused `selfProgress` to run.
  ///
  /// **Counted, not thrown.** This override used to throw a `StateError`,
  /// which a `FutureProvider` turns into an `AsyncError` that
  /// `ref.watch(...).value` reads as `null` — exactly what the card does
  /// with a loading state. The guard could not have failed: the card would
  /// have walked the activity log once per challenge on every visit to the
  /// Progress screen and the test would still have passed. A counter
  /// cannot be swallowed.
  var selfProgressRuns = 0;

  setUp(() {
    repository = FakeChallengeRepository();
    selfProgressRuns = 0;
  });

  tearDown(() async {
    await repository.dispose();
  });

  Future<void> pumpCard(WidgetTester tester) async {
    addTearDown(() => flushDriftTimers(tester));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeRepositoryProvider.overrideWithValue(repository),
          challengesTodayProvider.overrideWithValue(_today),
          // The card is not allowed to walk the activity log: reading a
          // per-challenge progress figure here would pay that cost once
          // per challenge on every visit to a dashboard the card merely
          // sits on.
          selfProgressProvider.overrideWith((ref, id) {
            selfProgressRuns++;
            return null;
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: ChallengesProgressSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('invites with nothing on the go', (tester) async {
    await pumpCard(tester);

    expect(find.text(challengesSectionTitle), findsOneWidget);
    expect(find.text(challengesEmptyLine), findsOneWidget);
    expect(
      find.byKey(const Key('challengesSectionOpenButton')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await flushDriftTimers(tester);
  });

  testWidgets('counts what is running without computing any of it', (
    tester,
  ) async {
    repository.seed([
      challengeFrom(distanceBlueprint(salt: 1)),
      challengeFrom(sessionBlueprint(salt: 2)),
      // Finished in July, so it is not "on the go".
      challengeFrom(
        distanceBlueprint(
          salt: 3,
          windowStart: LocalDate(2026, 7, 1),
          windowEnd: LocalDate(2026, 7, 31),
        ),
      ),
    ]);

    await pumpCard(tester);

    expect(find.text(activeChallengeCountLine(2)), findsOneWidget);
    expect(find.text(challengesEmptyLine), findsNothing);
    expect(
      selfProgressRuns,
      0,
      reason:
          'three challenges are stored and the card computed none of them - '
          'it counts what is running, it does not walk the activity log',
    );
    expect(tester.takeException(), isNull);

    await flushDriftTimers(tester);
  });

  testWidgets('says nothing that implies a ranking or names a cycle', (
    tester,
  ) async {
    repository.seed([challengeFrom(distanceBlueprint())]);
    await pumpCard(tester);

    for (final widget in tester.widgetList<Text>(find.byType(Text))) {
      if (widget.data case final text?) {
        expectNoForbiddenChallengeVocabulary(
          text,
          source: 'the Progress screen challenges card',
        );
      }
    }

    await flushDriftTimers(tester);
  });
}
