import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_codes.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress_engine.dart';
import 'package:menfit_app/features/challenges/presentation/challenge_detail_screen.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/challenge_code_panel.dart';

import '../weight/weight_test_vocabulary.dart' show flushDriftTimers;
import 'challenge_fixtures.dart';
import 'challenges_test_vocabulary.dart';
import 'fake_challenge_repository.dart';

final LocalDate _today = LocalDate(2026, 9, 20);

ChallengeSelfProgress _progressFor(
  ChallengeBlueprint blueprint, {
  double metres = 0,
  Set<LocalDate> protectedDays = const {},
}) {
  return computeSelfProgress(
    challenge: blueprint,
    activities: [
      if (metres > 0) activityOn(blueprint.windowStart, distanceMeters: metres),
    ],
    protectedDays: protectedDays,
  );
}

ChallengeBuddySnapshot _buddy({
  String displayName = 'Sam',
  double percent = 48,
  int day = 12,
}) {
  return ChallengeBuddySnapshot(
    displayName: displayName,
    progressPercent: percent,
    asOf: LocalDate(2026, 9, day),
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

  void useTallWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  String? Function() interceptClipboard(WidgetTester tester) {
    String? captured;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          captured =
              (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return () => captured;
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    required Challenge challenge,
    ChallengeSelfProgress? progress,
  }) async {
    addTearDown(() => flushDriftTimers(tester));
    repository.seed([challenge]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeRepositoryProvider.overrideWithValue(repository),
          challengesTodayProvider.overrideWithValue(_today),
          selfProgressProvider.overrideWith((ref, id) => progress),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: ChallengeDetailScreen(challengeId: challenge.id),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The same screen, but pushed on top of a list, so "pop back to where
  /// she came from" is a thing the test can actually observe.
  Future<void> pumpPushedScreen(
    WidgetTester tester, {
    required Challenge challenge,
    ChallengeSelfProgress? progress,
  }) async {
    addTearDown(() => flushDriftTimers(tester));
    repository.seed([challenge]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeRepositoryProvider.overrideWithValue(repository),
          challengesTodayProvider.overrideWithValue(_today),
          selfProgressProvider.overrideWith((ref, id) => progress),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ChallengeDetailScreen(challengeId: challenge.id),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Every string on screen except the opaque code body, which is base64
  /// of a binary payload rather than copy — see [challengeCodeTextKey].
  List<String> renderedText(WidgetTester tester) => [
    for (final widget in tester.widgetList<Text>(find.byType(Text)))
      ?widget.data,
    for (final widget in tester.widgetList<SelectableText>(
      find.byType(SelectableText),
    ))
      if (widget.key != challengeCodeTextKey) ?widget.data,
  ];

  group('her own progress', () {
    testWidgets('shows where she is against her own target, and not what '
        'she did', (tester) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      await pumpScreen(
        tester,
        challenge: challengeFrom(blueprint),
        progress: _progressFor(blueprint, metres: 25400),
      );

      expect(find.text('100 km'), findsOneWidget);
      expect(find.text(selfLabel), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      expect(find.text(createdOriginLine), findsOneWidget);

      // This assertion used to be its opposite: the screen showed
      // "25.4 km so far" and a comment called the arithmetic an accepted
      // residual. It is not - raw work beside the percentage, the target
      // and the window resolves her protected-day count uniquely, which
      // `challenge_surfaces_privacy_test.dart` now checks on every
      // surface. Her raw distance lives in her activity history.
      expect(find.textContaining('so far'), findsNothing);
      expect(find.textContaining('25.4'), findsNothing);

      await flushDriftTimers(tester);
    });

    testWidgets('renders a percentage over 100 as the plain fact it is', (
      tester,
    ) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      await pumpScreen(
        tester,
        challenge: challengeFrom(blueprint),
        progress: _progressFor(blueprint, metres: 112900),
      );

      expect(find.text('112%'), findsOneWidget);
      expect(find.text(selfReachedLine), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('acknowledges that targets flex, once, and never in '
        'numbers', (tester) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      // Five protected days in a 30-day window: her adjusted target is
      // 83,333 m and her percentage 30 rather than 25.
      final progress = _progressFor(
        blueprint,
        metres: 25000,
        protectedDays: daysFrom(LocalDate(2026, 9, 5), LocalDate(2026, 9, 9)),
      );
      expect(progress.adjustedTarget, closeTo(83333.33, 0.01));
      expect(progress.protectedDaysInWindow, 5);

      await pumpScreen(
        tester,
        challenge: challengeFrom(blueprint),
        progress: progress,
      );

      // Said once, in words.
      expect(find.byKey(const Key('challengeFairnessNote')), findsOneWidget);
      expect(find.text(fairnessNote), findsOneWidget);

      // And never in numbers: the adjusted target is what a screenshot
      // would have to leak for her protected days to be inferable from
      // this screen, so no rendering of it may appear.
      final texts = renderedText(tester);
      for (final text in texts) {
        expect(
          text,
          isNot(contains('83')),
          reason: 'the adjusted target must not be rendered anywhere',
        );
        expect(
          text.toLowerCase(),
          isNot(contains('protect')),
          reason: 'the protected-day count is not this screen to give away',
        );
      }
      // `fairnessNote` is allowed to say targets make room for rest —
      // that is the sentence it exists to be. What it must never do is
      // attach a number to it.
      expect(
        texts.where((t) => t.contains('5 day')),
        isEmpty,
        reason: 'the protected-day count must not appear as a figure',
      );
      // What she *is* shown: the shared target and her own ratio against
      // her own version of it. Not her raw work - see the co-presence rule
      // in `challenge_surfaces_privacy_test.dart`.
      expect(find.text('100 km'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
      expect(find.textContaining('25 km'), findsNothing);

      await flushDriftTimers(tester);
    });
  });

  group('the buddy section', () {
    testWidgets('says nothing pasted yet without making it a problem', (
      tester,
    ) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      await pumpScreen(
        tester,
        challenge: challengeFrom(blueprint),
        progress: _progressFor(blueprint, metres: 25000),
      );

      expect(find.byKey(const Key('buddyEmptyLine')), findsOneWidget);
      expect(find.text(buddyEmptyLine), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('shows her figure and the day it was for', (tester) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      await pumpScreen(
        tester,
        challenge: challengeFrom(blueprint, buddy: _buddy()),
        progress: _progressFor(blueprint, metres: 25000),
      );

      expect(find.text('Sam'), findsOneWidget);
      expect(find.text('48%'), findsOneWidget);
      expect(find.text('as of 12 Sep'), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('applies a newer code and says whose figure moved', (
      tester,
    ) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      final challenge = challengeFrom(blueprint);
      await pumpScreen(
        tester,
        challenge: challenge,
        progress: _progressFor(blueprint, metres: 25000),
      );

      await tapVisible(tester, find.byKey(const Key('pasteBuddyCodeButton')));
      await tester.enterText(
        find.byKey(const Key('buddyCodeField')),
        buddyProgressCode(
          challengeId: challenge.id,
          displayName: 'Sam',
          progressPercent: 61,
          asOf: LocalDate(2026, 9, 18),
        ),
      );
      await tester.tap(find.byKey(const Key('buddyCodeSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text(buddyImportedMessage('Sam')), findsOneWidget);
      expect(find.text('61%'), findsOneWidget);
      expect(find.text('as of 18 Sep'), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('treats an older code as "you already have this one"', (
      tester,
    ) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      final challenge = challengeFrom(blueprint, buddy: _buddy(day: 18));
      await pumpScreen(
        tester,
        challenge: challenge,
        progress: _progressFor(blueprint, metres: 25000),
      );

      await tapVisible(tester, find.byKey(const Key('pasteBuddyCodeButton')));
      await tester.enterText(
        find.byKey(const Key('buddyCodeField')),
        buddyProgressCode(
          challengeId: challenge.id,
          displayName: 'Sam',
          progressPercent: 12,
          asOf: LocalDate(2026, 9, 10),
        ),
      );
      await tester.tap(find.byKey(const Key('buddyCodeSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text(buddyNotNewerMessage), findsOneWidget);
      // The stored snapshot did not move backwards.
      final stored = await repository.getChallenge(challenge.id);
      expect(stored!.buddy!.progressPercent, 48);

      await flushDriftTimers(tester);
    });

    testWidgets('turns her own code away and says what to do with it', (
      tester,
    ) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      final challenge = challengeFrom(blueprint, buddy: _buddy());
      await pumpScreen(
        tester,
        challenge: challenge,
        progress: _progressFor(blueprint, metres: 25000),
      );

      await tapVisible(tester, find.byKey(const Key('pasteBuddyCodeButton')));
      await tester.enterText(
        find.byKey(const Key('buddyCodeField')),
        encodeProgressCode(
          challengeId: challenge.id,
          displayName: challenge.selfDisplayName,
          progressPercent: 91,
          asOf: LocalDate(2026, 9, 19),
          authorTag: selfAuthorTag,
        ),
      );
      await tester.tap(find.byKey(const Key('buddyCodeSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text(buddyOwnCodeMessage), findsOneWidget);
      final stored = await repository.getChallenge(challenge.id);
      expect(
        stored!.buddy!.progressPercent,
        48,
        reason: "her own figure must not land under her buddy's name",
      );

      await flushDriftTimers(tester);
    });

    testWidgets('says so when the code belongs to another challenge', (
      tester,
    ) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      await pumpScreen(
        tester,
        challenge: challengeFrom(blueprint),
        progress: _progressFor(blueprint, metres: 25000),
      );

      await tapVisible(tester, find.byKey(const Key('pasteBuddyCodeButton')));
      await tester.enterText(
        find.byKey(const Key('buddyCodeField')),
        buddyProgressCode(
          challengeId: sessionBlueprint().id,
          displayName: 'Sam',
          progressPercent: 61,
          asOf: LocalDate(2026, 9, 18),
        ),
      );
      await tester.tap(find.byKey(const Key('buddyCodeSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text(buddyUnknownChallengeMessage), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('gives an unreadable code its typed message', (tester) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      await pumpScreen(
        tester,
        challenge: challengeFrom(blueprint),
        progress: _progressFor(blueprint, metres: 25000),
      );

      await tapVisible(tester, find.byKey(const Key('pasteBuddyCodeButton')));
      await tester.enterText(
        find.byKey(const Key('buddyCodeField')),
        'a shopping list',
      );
      await tester.tap(find.byKey(const Key('buddyCodeSubmitButton')));
      await tester.pumpAndSettle();

      expect(
        find.text(progressCodeRejectionMessage(CodeRejection.malformed)),
        findsOneWidget,
      );

      await flushDriftTimers(tester);
    });
  });

  group('leaving a challenge', () {
    testWidgets('asks first, and "keep it" keeps everything', (tester) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      final challenge = challengeFrom(blueprint, buddy: _buddy());
      await pumpPushedScreen(
        tester,
        challenge: challenge,
        progress: _progressFor(blueprint, metres: 25000),
      );

      await tapVisible(tester, find.byKey(const Key('leaveChallengeButton')));

      expect(find.byKey(const Key('leaveChallengeDialog')), findsOneWidget);
      expect(find.text(leaveChallengeBody), findsOneWidget);

      await tester.tap(find.byKey(const Key('leaveChallengeCancelButton')));
      await tester.pumpAndSettle();

      expect(await repository.getChallenge(challenge.id), isNotNull);
      expect(find.byType(ChallengeDetailScreen), findsOneWidget);
      expect(find.text(leftChallengeMessage), findsNothing);

      await flushDriftTimers(tester);
    });

    testWidgets('names what goes, without restating a single number', (
      tester,
    ) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      await pumpPushedScreen(
        tester,
        challenge: challengeFrom(blueprint, buddy: _buddy()),
        progress: _progressFor(blueprint, metres: 25000),
      );

      await tapVisible(tester, find.byKey(const Key('leaveChallengeButton')));

      final dialog = find.byKey(const Key('leaveChallengeDialog'));
      final inDialog = [
        for (final widget in tester.widgetList<Text>(
          find.descendant(of: dialog, matching: find.byType(Text)),
        ))
          ?widget.data,
      ];
      expect(inDialog, isNotEmpty);
      for (final text in inDialog) {
        expect(
          text,
          isNot(matches(RegExp(r'\d'))),
          reason:
              'a confirm dialog is not a place for a target, a percentage '
              'or a date - "$text" carries a figure',
        );
        expectNoForbiddenChallengeVocabulary(
          text,
          source: 'the leave-challenge dialog',
        );
      }

      await flushDriftTimers(tester);
    });

    testWidgets('deletes it for good, pops back and says so', (tester) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      final challenge = challengeFrom(blueprint, buddy: _buddy());
      await pumpPushedScreen(
        tester,
        challenge: challenge,
        progress: _progressFor(blueprint, metres: 25000),
      );

      await tapVisible(tester, find.byKey(const Key('leaveChallengeButton')));
      await tester.tap(find.byKey(const Key('leaveChallengeConfirmButton')));
      await tester.pumpAndSettle();

      expect(
        await repository.getChallenge(challenge.id),
        isNull,
        reason: "a hard delete - the buddy's name does not linger in a row",
      );
      expect(find.byType(ChallengeDetailScreen), findsNothing);
      expect(find.text(leftChallengeMessage), findsOneWidget);

      await flushDriftTimers(tester);
    });

    testWidgets('a challenge that has gone says so, with a way back', (
      tester,
    ) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      final challenge = challengeFrom(blueprint);
      await pumpPushedScreen(
        tester,
        challenge: challenge,
        progress: _progressFor(blueprint, metres: 25000),
      );

      // Wiped from underneath the open screen - "Delete my data" in
      // another tab, or a second window.
      await repository.deleteAllData();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('challengeGoneMessage')), findsOneWidget);
      expect(find.text(challengeGoneLine), findsOneWidget);

      await tester.tap(find.byKey(const Key('challengeGoneBackButton')));
      await tester.pumpAndSettle();
      expect(find.byType(ChallengeDetailScreen), findsNothing);

      await flushDriftTimers(tester);
    });
  });

  group('sharing her progress', () {
    testWidgets('shows a copyable code carrying her percentage and today', (
      tester,
    ) async {
      useTallWindow(tester);
      final copied = interceptClipboard(tester);
      final blueprint = distanceBlueprint();
      final challenge = challengeFrom(blueprint);
      final progress = _progressFor(blueprint, metres: 25000);
      await pumpScreen(
        tester,
        challenge: challenge,
        progress: progress,
      );

      await tapVisible(tester, find.byKey(const Key('shareProgressButton')));

      final expected = encodeProgressCode(
        challengeId: challenge.id,
        displayName: challenge.selfDisplayName,
        progressPercent: progress.percent,
        asOf: _today,
        authorTag: selfAuthorTag,
      );
      final shown = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(shown.data, expected);

      // Decoded back, the code carries four things and no fifth.
      final decoded = (decodeProgressCode(
        expected,
      ) as CodeDecoded<ProgressCodePayload>).value;
      expect(decoded.challengeId, challenge.id);
      expect(decoded.displayName, 'Alex');
      expect(decoded.progressPercent, closeTo(25, 0.05));
      expect(decoded.asOf, _today);

      expect(find.byKey(const Key('progressCodePrivacyNote')), findsOneWidget);

      await tester.tap(find.byKey(const Key('progressCodeCopyButton')));
      await tester.pumpAndSettle();
      expect(copied(), expected);

      await flushDriftTimers(tester);
    });
  });

  group('the mutual celebration', () {
    testWidgets('is absent until both of them reached their own goals', (
      tester,
    ) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      await pumpScreen(
        tester,
        challenge: challengeFrom(blueprint, buddy: _buddy(percent: 118)),
        progress: _progressFor(blueprint, metres: 25000),
      );

      expect(find.byKey(const Key('bothReachedBanner')), findsNothing);
      expect(find.text(celebrationOpenLabel), findsNothing);

      await flushDriftTimers(tester);
    });

    testWidgets('renders a card with both names, no ranking and no '
        'percentages', (tester) async {
      useTallWindow(tester);
      final copied = interceptClipboard(tester);
      final blueprint = distanceBlueprint();
      await pumpScreen(
        tester,
        challenge: challengeFrom(blueprint, buddy: _buddy(percent: 118)),
        progress: _progressFor(blueprint, metres: 104000),
      );

      expect(find.byKey(const Key('bothReachedBanner')), findsOneWidget);
      expect(find.text(bothReachedLine), findsOneWidget);

      await tapVisible(
        tester,
        find.byKey(const Key('openCelebrationCardButton')),
      );

      final card = find.byKey(const Key('challengeCelebrationCard'));
      expect(card, findsOneWidget);
      expect(
        find.descendant(of: card, matching: find.text('Alex & Sam')),
        findsOneWidget,
      );
      // Neither percentage is on the artefact built to be shown to other
      // people: "118% vs 104%" is the reading this feature refuses.
      expect(
        find.descendant(of: card, matching: find.textContaining('%')),
        findsNothing,
      );

      // The square format is offered too, and changes nothing else.
      await tester.tap(find.text(celebrationSquareLabel));
      await tester.pumpAndSettle();
      expect(card, findsOneWidget);
      expect(
        find.descendant(of: card, matching: find.textContaining('%')),
        findsNothing,
      );

      await tester.tap(find.byKey(const Key('celebrationShareButton')));
      await tester.pumpAndSettle();
      expect(copied(), contains('Alex and Sam each reached their own goal'));
      expectNoForbiddenChallengeVocabulary(
        copied()!,
        source: 'the copied celebration text',
      );

      await flushDriftTimers(tester);
    });
  });

  group('the forbidden-vocabulary sweep', () {
    void expectClean(WidgetTester tester, {required String where}) {
      final rendered = <(String, String)>[
        for (final text in renderedText(tester)) ('a Text widget', text),
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
      expect(rendered, isNotEmpty, reason: 'nothing was swept in $where');
      for (final (source, text) in rendered) {
        expectNoForbiddenChallengeVocabulary(text, source: '$source in $where');
      }
    }

    testWidgets('across the detail screen, its dialog and its card', (
      tester,
    ) async {
      useTallWindow(tester);
      final blueprint = distanceBlueprint();
      await pumpScreen(
        tester,
        challenge: challengeFrom(
          blueprint,
          origin: ChallengeOrigin.joined,
          buddy: _buddy(percent: 118),
        ),
        progress: _progressFor(
          blueprint,
          metres: 104000,
          protectedDays: daysFrom(LocalDate(2026, 9, 5), LocalDate(2026, 9, 9)),
        ),
      );
      expectClean(tester, where: 'the challenge detail screen');

      await tapVisible(tester, find.byKey(const Key('pasteBuddyCodeButton')));
      await tester.enterText(
        find.byKey(const Key('buddyCodeField')),
        'not a code',
      );
      await tester.tap(find.byKey(const Key('buddyCodeSubmitButton')));
      await tester.pumpAndSettle();
      expectClean(tester, where: 'the buddy-code dialog with its message');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tapVisible(tester, find.byKey(const Key('shareProgressButton')));
      expectClean(tester, where: 'the progress-code sheet');
      await tester.tap(find.text(doneLabel));
      await tester.pumpAndSettle();

      await tapVisible(
        tester,
        find.byKey(const Key('openCelebrationCardButton')),
      );
      expectClean(tester, where: 'the celebration sheet');

      await flushDriftTimers(tester);
    });
  });
}
