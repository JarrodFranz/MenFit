import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/challenges/challenges_widgets.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress_engine.dart';
import 'package:menfit_app/features/challenges/presentation/challenge_detail_screen.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_screen.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/challenge_code_panel.dart';

import '../weight/weight_test_vocabulary.dart' show flushDriftTimers;
import 'challenge_fixtures.dart';
import 'fake_challenge_repository.dart';

/// The co-presence rule, swept across every challenge surface.
///
/// ## What the rule is, and why it is about four numbers rather than one
///
/// Her adjusted target and her protected-day count are private
/// (`domain/challenge_progress.dart`), and no surface renders either. That
/// is not enough on its own, because both are recoverable by arithmetic
/// from figures that are individually harmless:
///
/// ```text
/// adjustedTarget = raw ÷ (percent ÷ 100)
/// protectedDays  = windowDays − round(windowDays × adjustedTarget ÷ target)
/// ```
///
/// So a surface showing **her raw work**, **her adjusted percentage**, the
/// **nominal target** and the **window** states her protected days exactly
/// — 42.3 km at 50% of 100 km over 30 days is five, and nothing else. The
/// detail screen used to do precisely that, with a comment describing it
/// as an accepted residual. It is not accepted any more, and this file is
/// what makes that structural rather than remembered: any one of the four
/// may appear, any three may appear together, and all four together on one
/// surface is a failure.
///
/// The fixture is a woman with five protected days, because a rule tested
/// against someone with none cannot fail.
///
/// The percentage stays, deliberately: the pro-rated experience *is* the
/// feature, and hiding her own standing from her to protect her from her
/// own screenshot would be a worse app. The raw figure is the one of the
/// four with somewhere else to live — her activity history, on a screen
/// that says nothing about a challenge.
void main() {
  final blueprint = distanceBlueprint();
  final today = LocalDate(2026, 9, 20);

  /// 25.4 km logged, five protected days in a 30-day window: her adjusted
  /// target is 83,333 m and she reads 30%, not 25%.
  final progress = computeSelfProgress(
    challenge: blueprint,
    activities: [activityOn(LocalDate(2026, 9, 3), distanceMeters: 25400)],
    protectedDays: daysFrom(LocalDate(2026, 9, 5), LocalDate(2026, 9, 9)),
  );

  final buddy = ChallengeBuddySnapshot(
    displayName: 'Sam',
    progressPercent: 118,
    asOf: LocalDate(2026, 9, 12),
  );

  /// The two shared figures, as this app renders them. The two personal
  /// ones are derived per-fixture below, because they move with her.
  ///
  /// Written as the strings a reader would see rather than as numbers,
  /// because it is the rendering that leaks: a percentage nobody prints is
  /// not on the screen.
  const targetFragment = '100 km';
  const windowFragment = '30 Sep 2026';

  /// Her raw work as any surface would have to print it — kilometres,
  /// floored to the tenth, which is the form the deleted "42.3 km so far"
  /// line used and the form any replacement would take.
  String kmFragment(double metres) =>
      ((metres / 100).floor() / 10).toStringAsFixed(1);

  late FakeChallengeRepository repository;

  setUp(() {
    repository = FakeChallengeRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  /// Every string a reader can see or hear, minus the opaque code body
  /// ([challengeCodeTextKey]) — base64 of a binary payload is not copy,
  /// and sweeping it makes the gate flaky for no gain. The labels around
  /// it are still swept, here and in the vocabulary gates.
  List<String> readable(WidgetTester tester) => [
    for (final widget in tester.widgetList<Text>(find.byType(Text)))
      ?widget.data,
    for (final widget in tester.widgetList<SelectableText>(
      find.byType(SelectableText),
    ))
      if (widget.key != challengeCodeTextKey) ?widget.data,
    for (final widget in tester.widgetList<Semantics>(
      find.byType(Semantics),
    )) ...[?widget.properties.label, ?widget.properties.value],
  ];

  /// Fails if all four figures are on one surface; returns which of them
  /// were found, so a caller can prove the sweep was looking at the right
  /// screen rather than at an empty one.
  List<String> expectNoSolvableQuartet(
    WidgetTester tester, {
    required String where,
    required ChallengeSelfProgress self,
  }) {
    final texts = readable(tester);
    expect(texts, isNotEmpty, reason: 'nothing was swept in $where');

    final rawFragment = kmFragment(self.rawValue);
    final percentFragment = formatPercent(self.percent);
    bool shows(String fragment) => texts.any((t) => t.contains(fragment));

    final present = <String>[
      if (shows(rawFragment)) 'her raw work ($rawFragment)',
      if (shows(percentFragment)) 'her adjusted percent ($percentFragment)',
      if (shows(targetFragment)) 'the nominal target ($targetFragment)',
      if (shows(windowFragment)) 'the window ($windowFragment)',
    ];

    expect(
      present,
      hasLength(lessThan(4)),
      reason:
          '$where renders all four of ${present.join(', ')} - together they '
          "resolve her protected-day count exactly (see this file's doc). "
          'Take the raw figure off this surface; it belongs in her '
          'activity history.',
    );

    // Neither derived figure may be printed outright either, in any
    // rounding: 83,333 m adjusted target, 5 protected days.
    for (final text in texts) {
      expect(
        text,
        isNot(contains('83')),
        reason: 'the adjusted target is rendered in $where',
      );
      expect(
        text.toLowerCase(),
        isNot(contains('protect')),
        reason: 'the protected-day count is not $where to give away',
      );
    }

    return present;
  }

  Widget host(Widget child, {Challenge? seed}) {
    if (seed != null) repository.seed([seed]);
    return ProviderScope(
      overrides: [
        challengeRepositoryProvider.overrideWithValue(repository),
        challengesTodayProvider.overrideWithValue(today),
        selfProgressProvider.overrideWith(
          (ref, id) => id == seed?.id ? progress : null,
        ),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: child),
    );
  }

  void useTallWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('the fixture is a woman with protected days', (tester) async {
    expect(progress.protectedDaysInWindow, 5);
    expect(progress.adjustedTarget, closeTo(83333.33, 0.01));
    expect(formatPercent(progress.percent), '30%');
    expect(kmFragment(progress.rawValue), '25.4');
    expect(
      challengeTargetLine(blueprint),
      targetFragment,
      reason: 'the four fragments must be the ones this app really renders',
    );
    expect(
      challengeWindowLine(blueprint.windowStart, blueprint.windowEnd),
      endsWith(windowFragment),
    );
  });

  testWidgets('the list card does not state the solvable quartet', (
    tester,
  ) async {
    useTallWindow(tester);
    addTearDown(() => flushDriftTimers(tester));
    final challenge = challengeFrom(blueprint, buddy: buddy);

    await tester.pumpWidget(host(const ChallengesScreen(), seed: challenge));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('challengeCard_${challenge.id}')), findsOneWidget);
    final present = expectNoSolvableQuartet(
      tester,
      where: 'the challenge list card',
      self: progress,
    );
    expect(
      present,
      hasLength(3),
      reason:
          'the card is one figure short of solvable, and the missing one is '
          'her raw work - if this drops to two the sweep has stopped '
          'looking at the card it thinks it is looking at',
    );

    await flushDriftTimers(tester);
  });

  testWidgets('the Progress-screen card does not either', (tester) async {
    useTallWindow(tester);
    addTearDown(() => flushDriftTimers(tester));

    await tester.pumpWidget(
      host(
        const Scaffold(body: ChallengesProgressSection()),
        seed: challengeFrom(blueprint, buddy: buddy),
      ),
    );
    await tester.pumpAndSettle();

    expectNoSolvableQuartet(
      tester,
      where: 'the Progress screen card',
      self: progress,
    );

    await flushDriftTimers(tester);
  });

  testWidgets('the detail screen, its sheets and its dialogs do not', (
    tester,
  ) async {
    useTallWindow(tester);
    addTearDown(() => flushDriftTimers(tester));
    final challenge = challengeFrom(blueprint, buddy: buddy);

    await tester.pumpWidget(
      host(ChallengeDetailScreen(challengeId: challenge.id), seed: challenge),
    );
    await tester.pumpAndSettle();
    final present = expectNoSolvableQuartet(
      tester,
      where: 'the challenge detail screen',
      self: progress,
    );
    // The positive control for the whole file: this screen genuinely
    // renders three of the four, and used to render the fourth. A sweep
    // that found none of them would pass for the wrong reason forever.
    expect(present, hasLength(3));
    expect(present.any((p) => p.startsWith('her raw work')), isFalse);

    Future<void> tapVisible(Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    await tapVisible(find.byKey(const Key('pasteBuddyCodeButton')));
    expectNoSolvableQuartet(
      tester,
      where: 'the buddy-code dialog',
      self: progress,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tapVisible(find.byKey(const Key('shareProgressButton')));
    expectNoSolvableQuartet(
      tester,
      where: 'the progress-code sheet',
      self: progress,
    );
    await tester.tap(find.text(doneLabel));
    await tester.pumpAndSettle();

    await tapVisible(find.byKey(const Key('leaveChallengeButton')));
    expectNoSolvableQuartet(
      tester,
      where: 'the leave-challenge dialog',
      self: progress,
    );
    await tester.tap(find.byKey(const Key('leaveChallengeCancelButton')));
    await tester.pumpAndSettle();

    await flushDriftTimers(tester);
  });

  testWidgets('nor does the celebration both of them can see', (tester) async {
    useTallWindow(tester);
    addTearDown(() => flushDriftTimers(tester));
    // She has reached her own goal too, so the card is available - and the
    // card is the one artefact here built to be shown to other people.
    final reached = computeSelfProgress(
      challenge: blueprint,
      activities: [activityOn(LocalDate(2026, 9, 3), distanceMeters: 91400)],
      protectedDays: daysFrom(LocalDate(2026, 9, 5), LocalDate(2026, 9, 9)),
    );
    final challenge = challengeFrom(blueprint, buddy: buddy);
    repository.seed([challenge]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeRepositoryProvider.overrideWithValue(repository),
          challengesTodayProvider.overrideWithValue(today),
          selfProgressProvider.overrideWith((ref, id) => reached),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: ChallengeDetailScreen(challengeId: challenge.id),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final open = find.byKey(const Key('openCelebrationCardButton'));
    await tester.ensureVisible(open);
    await tester.pumpAndSettle();
    await tester.tap(open);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('challengeCelebrationCard')), findsOneWidget);
    expectNoSolvableQuartet(
      tester,
      where: 'the celebration sheet',
      self: reached,
    );

    await flushDriftTimers(tester);
  });
}
