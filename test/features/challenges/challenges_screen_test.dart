import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress_engine.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_screen.dart';

import '../weight/weight_test_vocabulary.dart' show flushDriftTimers;
import 'challenge_fixtures.dart';
import 'challenges_test_vocabulary.dart';
import 'fake_challenge_repository.dart';

/// A day inside the September fixtures' window, so those challenges are
/// active and one dated July is not.
final LocalDate _today = LocalDate(2026, 9, 20);

/// Her standing in the challenge, through the real engine — so a percentage
/// on screen is one the engine would actually produce rather than a
/// hand-faked figure that agrees with the assertion by construction.
ChallengeSelfProgress _progressFor(
  ChallengeBlueprint blueprint, {
  double metres = 0,
  int sessions = 0,
  Set<LocalDate> protectedDays = const {},
}) {
  return computeSelfProgress(
    challenge: blueprint,
    activities: [
      if (metres > 0) activityOn(blueprint.windowStart, distanceMeters: metres),
      for (var i = 0; i < sessions; i++)
        activityOn(
          blueprint.windowStart.addDays(i),
          type: sessionBlueprint().activityTypes.first,
        ),
    ],
    protectedDays: protectedDays,
  );
}

void main() {
  late FakeChallengeRepository repository;

  setUp(() {
    repository = FakeChallengeRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    Map<String, ChallengeSelfProgress> progress = const {},
  }) async {
    // Registered here rather than per test so no test can forget it — the
    // pattern `weight_test_vocabulary.dart#flushDriftTimers` documents.
    addTearDown(() => flushDriftTimers(tester));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeRepositoryProvider.overrideWithValue(repository),
          challengesTodayProvider.overrideWithValue(_today),
          selfProgressProvider.overrideWith((ref, id) => progress[id]),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ChallengesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder cardFor(Challenge challenge) =>
      find.byKey(Key('challengeCard_${challenge.id}'));

  Finder textIn(Challenge challenge, String text) =>
      find.descendant(of: cardFor(challenge), matching: find.text(text));

  group('the list', () {
    testWidgets('invites without nagging when there is nothing on the go', (
      tester,
    ) async {
      await pumpScreen(tester);

      expect(find.byKey(const Key('challengesEmptyLine')), findsOneWidget);
      expect(find.text(challengesEmptyLine), findsOneWidget);
      expect(find.byType(Card), findsNothing);
      // Both ways in are offered from the empty state.
      expect(find.text(startChallengeLabel), findsOneWidget);
      expect(find.text(joinChallengeLabel), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('renders an active challenge with her own progress', (
      tester,
    ) async {
      final blueprint = distanceBlueprint();
      final challenge = challengeFrom(blueprint);
      repository.seed([challenge]);

      await pumpScreen(
        tester,
        progress: {challenge.id: _progressFor(blueprint, metres: 25000)},
      );

      expect(find.text(activeChallengesHeading), findsOneWidget);
      expect(textIn(challenge, '100 km'), findsOneWidget);
      expect(textIn(challenge, 'Run · 1 Sep – 30 Sep 2026'), findsOneWidget);
      expect(textIn(challenge, selfLabel), findsOneWidget);
      expect(textIn(challenge, '25%'), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('shows the buddy with her name, her figure and its date', (
      tester,
    ) async {
      final blueprint = distanceBlueprint();
      final challenge = challengeFrom(
        blueprint,
        buddy: ChallengeBuddySnapshot(
          displayName: 'Sam',
          progressPercent: 48,
          asOf: LocalDate(2026, 9, 12),
        ),
      );
      repository.seed([challenge]);

      await pumpScreen(
        tester,
        progress: {challenge.id: _progressFor(blueprint, metres: 25000)},
      );

      expect(
        textIn(challenge, buddyCardLine('Sam', 48, LocalDate(2026, 9, 12))),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: cardFor(challenge),
          matching: find.byType(LinearProgressIndicator),
        ),
        findsOneWidget,
        reason:
            'her buddy is a sentence, not a second bar: two bars are a '
            'comparison whatever the copy says, and the two percentages '
            'are measured against different private targets (see the class '
            'doc on challenge_card.dart)',
      );

      await flushDriftTimers(tester);
    });

    testWidgets('does not celebrate when only one of them reached her goal', (
      tester,
    ) async {
      final blueprint = distanceBlueprint();
      final challenge = challengeFrom(
        blueprint,
        buddy: ChallengeBuddySnapshot(
          displayName: 'Sam',
          progressPercent: 104,
          asOf: LocalDate(2026, 9, 12),
        ),
      );
      repository.seed([challenge]);

      await pumpScreen(
        tester,
        progress: {challenge.id: _progressFor(blueprint, metres: 25000)},
      );

      // One of them arriving is not an outcome this feature has a card
      // for - a card that fired here would mean "and the other did not".
      expect(find.byKey(const Key('bothReachedBanner')), findsNothing);

      await flushDriftTimers(tester);
    });

    testWidgets('celebrates when both reached their own goals', (
      tester,
    ) async {
      final blueprint = distanceBlueprint();
      final challenge = challengeFrom(
        blueprint,
        buddy: ChallengeBuddySnapshot(
          displayName: 'Sam',
          progressPercent: 104,
          asOf: LocalDate(2026, 9, 12),
        ),
      );
      repository.seed([challenge]);

      await pumpScreen(
        tester,
        progress: {challenge.id: _progressFor(blueprint, metres: 112000)},
      );

      expect(find.byKey(const Key('bothReachedBanner')), findsOneWidget);
      expect(find.text(bothReachedTitle), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('renders a percentage over 100 without capping it', (
      tester,
    ) async {
      final blueprint = distanceBlueprint();
      final challenge = challengeFrom(blueprint);
      repository.seed([challenge]);

      await pumpScreen(
        tester,
        progress: {challenge.id: _progressFor(blueprint, metres: 112400)},
      );

      expect(textIn(challenge, '112%'), findsOneWidget);

      await flushDriftTimers(tester);
    });
  });

  group('the finished section', () {
    final finishedBlueprint = distanceBlueprint(
      salt: 7,
      windowStart: LocalDate(2026, 7, 1),
      windowEnd: LocalDate(2026, 7, 31),
    );

    testWidgets('is secondary: collapsed until she asks for it', (
      tester,
    ) async {
      final active = challengeFrom(distanceBlueprint());
      final finished = challengeFrom(finishedBlueprint);
      repository.seed([active, finished]);

      await pumpScreen(
        tester,
        progress: {
          active.id: _progressFor(active.blueprint, metres: 25000),
          finished.id: _progressFor(finished.blueprint, metres: 100000),
        },
      );

      expect(cardFor(active), findsOneWidget);
      expect(cardFor(finished), findsNothing);
      expect(find.text(finishedChallengesHeading), findsOneWidget);

      await tester.tap(find.text(finishedChallengesHeading));
      await tester.pumpAndSettle();

      expect(cardFor(finished), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('is absent entirely when nothing has finished', (
      tester,
    ) async {
      repository.seed([challengeFrom(distanceBlueprint())]);
      await pumpScreen(tester);

      expect(find.byKey(const Key('finishedChallengesSection')), findsNothing);

      await flushDriftTimers(tester);
    });
  });

  group('the forbidden-vocabulary sweep', () {
    /// Every string a user can currently read or hear on this screen: the
    /// visible text, the tooltips, and the semantics handed to a screen
    /// reader for the progress bars (which are not `Text`, and are the
    /// half most likely to drift).
    List<(String, String)> readableCopy(WidgetTester tester) {
      return [
        for (final widget in tester.widgetList<Text>(find.byType(Text)))
          if (widget.data != null) ('a Text widget', widget.data!),
        for (final widget in tester.widgetList<Tooltip>(find.byType(Tooltip)))
          if (widget.message != null) ('a Tooltip', widget.message!),
        for (final widget in tester.widgetList<Semantics>(
          find.byType(Semantics),
        )) ...[
          if (widget.properties.label case final label?)
            ('a semantics label', label),
          if (widget.properties.value case final value?)
            ('a semantics value', value),
        ],
      ];
    }

    void expectClean(WidgetTester tester, {required String where}) {
      final rendered = readableCopy(tester);
      expect(rendered, isNotEmpty, reason: 'nothing was swept in $where');
      for (final (source, text) in rendered) {
        expectNoForbiddenChallengeVocabulary(text, source: '$source in $where');
      }
    }

    testWidgets('across the empty list', (tester) async {
      await pumpScreen(tester);
      expectClean(tester, where: 'the empty challenge list');
      await flushDriftTimers(tester);
    });

    testWidgets('across a list with a buddy, a celebration and a finish', (
      tester,
    ) async {
      final active = challengeFrom(
        distanceBlueprint(),
        buddy: ChallengeBuddySnapshot(
          displayName: 'Sam',
          progressPercent: 118,
          asOf: LocalDate(2026, 9, 12),
        ),
      );
      final finished = challengeFrom(
        sessionBlueprint(
          windowStart: LocalDate(2026, 7, 1),
          windowEnd: LocalDate(2026, 7, 31),
        ),
        origin: ChallengeOrigin.joined,
      );
      repository.seed([active, finished]);

      await pumpScreen(
        tester,
        progress: {
          active.id: _progressFor(active.blueprint, metres: 104000),
          finished.id: _progressFor(finished.blueprint, sessions: 12),
        },
      );
      await tester.tap(find.text(finishedChallengesHeading));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('bothReachedBanner')), findsOneWidget);
      expectClean(tester, where: 'a populated challenge list');

      await flushDriftTimers(tester);
    });
  });
}
