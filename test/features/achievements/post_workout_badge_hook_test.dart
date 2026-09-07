import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/achievements/achievements_providers.dart';
import 'package:menfit_app/features/achievements/domain/badge_catalogue.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress.dart';
import 'package:menfit_app/features/achievements/domain/badge_progress_engine.dart';
import 'package:menfit_app/features/achievements/presentation/achievements_copy.dart';
import 'package:menfit_app/features/achievements/presentation/widgets/post_workout_badge_strip.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/widgets/workout_celebration_dialog.dart';

import '../weight/weight_test_vocabulary.dart' show flushDriftTimers;
import 'achievement_fixtures.dart';
import 'achievements_test_vocabulary.dart';
import 'award_detector_test.dart' show FakeAwardRepository;

/// The single point all five finishing flows (record, strength, HIIT, swim,
/// mindful) pass through: none of them shares a helper, but every one of
/// them calls [WorkoutCelebrationDialog.show]. Hooking the badge detector
/// into the dialog itself is what makes one wiring cover all five, so this
/// is the level the hook is tested at.
void main() {
  late FakeAwardRepository repository;

  setUp(() {
    resetFixtureIds();
    repository = FakeAwardRepository();
  });

  List<BadgeProgress> progressFor({
    Map<BadgeMetric, double> metrics = const {},
    Set<BadgeCondition> conditions = const {},
  }) {
    return [
      for (final definition in badgeCatalogue)
        evaluateBadge(
          definition: definition,
          metrics: metrics,
          conditions: conditions,
        ),
    ];
  }

  Future<void> showCelebration(
    WidgetTester tester, {
    required List<BadgeProgress> progress,
  }) async {
    addTearDown(() => flushDriftTimers(tester));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          awardRepositoryProvider.overrideWithValue(repository),
          badgeProgressProvider.overrideWith((ref) async => progress),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => unawaited(
                  WorkoutCelebrationDialog.show(
                    context,
                    activity: activityFixture(
                      type: ActivityType.run,
                      startedAt: DateTime(2026, 9, 1, 8),
                      distanceMeters: 5000,
                    ),
                    milestones: const [],
                  ),
                ),
                child: const Text('finish'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('finish'));
    await tester.pumpAndSettle();
  }

  testWidgets('a badge crossed by the workout celebrates alongside the '
      'milestone dialog', (tester) async {
    await showCelebration(
      tester,
      progress: progressFor(
        conditions: {BadgeCondition.firstActivityLogged},
      ),
    );

    // The detector ran, recorded, and the crossing is shown inside the
    // celebration she is already looking at - not in a second modal.
    expect(repository.awards, hasLength(1));
    expect(repository.awards.single.badgeId, 'first_activity');
    expect(find.byKey(const Key('postWorkoutBadgeStrip')), findsOneWidget);
    expect(find.text(postWorkoutBadgeHeading), findsOneWidget);
    expect(find.text('First One Logged'), findsOneWidget);
    // Still the workout celebration, not a badge takeover.
    expect(find.text('Workout Complete!'), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('says nothing at all when the workout crossed nothing', (
    tester,
  ) async {
    await showCelebration(tester, progress: progressFor());

    expect(repository.awards, isEmpty);
    expect(find.byKey(const Key('postWorkoutBadgeStrip')), findsNothing);
    expect(find.text(postWorkoutBadgeHeading), findsNothing);
    expect(find.text('Workout Complete!'), findsOneWidget);

    await flushDriftTimers(tester);
  });

  testWidgets('a first run over an established history collapses into one '
      'line rather than a wall of crests', (tester) async {
    await showCelebration(
      tester,
      progress: progressFor(
        // Gold on the running ladder is three rungs at once; the first
        // session is a fourth award.
        metrics: {BadgeMetric.lifetimeRunDistanceMetres: 450000},
        conditions: {BadgeCondition.firstActivityLogged},
      ),
    );

    expect(repository.awards, hasLength(4));
    expect(find.text(catchUpCelebrationTitle(4)), findsOneWidget);
    expect(find.text('The Road So Far'), findsNothing);

    await flushDriftTimers(tester);
  });

  testWidgets('the strip carries no forbidden vocabulary', (tester) async {
    await showCelebration(
      tester,
      progress: progressFor(
        conditions: {BadgeCondition.firstActivityLogged},
      ),
    );

    final strip = find.byKey(const Key('postWorkoutBadgeStrip'));
    final texts = tester.widgetList<Text>(
      find.descendant(of: strip, matching: find.byType(Text)),
    );
    expect(texts, isNotEmpty);
    for (final text in texts) {
      final data = text.data;
      if (data == null) continue;
      expectNoForbiddenAchievementVocabulary(
        data,
        source: 'the post-workout badge strip',
      );
    }

    await flushDriftTimers(tester);
  });
}
