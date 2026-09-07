import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/achievements/achievements_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/domain/workout_milestone.dart';
import 'package:menfit_app/features/activity/presentation/widgets/workout_celebration_dialog.dart';
import 'package:menfit_app/features/activity/presentation/widgets/workout_share_dialog.dart';

void main() {
  final testActivity = Activity(
    id: 'act-123',
    activityType: ActivityType.run,
    title: 'Morning 5k',
    startedAt: DateTime.utc(2026, 2, 1, 8),
    movingTime: const Duration(minutes: 25, seconds: 30),
    elapsedTime: const Duration(minutes: 26),
    distanceMeters: 5000,
    source: ActivitySource.recorded,
    createdAt: DateTime.utc(2026, 2, 1, 8),
    updatedAt: DateTime.utc(2026, 2, 1, 8),
  );

  Widget buildTestDialog({
    required Activity activity,
    required List<WorkoutMilestone> milestones,
    VoidCallback? onDone,
    VoidCallback? onViewDetails,
  }) {
    return ProviderScope(
      // The dialog mounts `PostWorkoutBadgeStrip`, which would otherwise
      // reach for the real award repository (and through it the real
      // database) to see whether this workout crossed a badge. Stubbing
      // the one provider it starts from keeps this a pure UI test of the
      // celebration itself; the badge hook has its own coverage in
      // `test/features/achievements/post_workout_badge_hook_test.dart`.
      overrides: [
        badgeProgressProvider.overrideWith((ref) async => const []),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  unawaited(
                    WorkoutCelebrationDialog.show(
                      context,
                      activity: activity,
                      milestones: milestones,
                      onDone: onDone,
                      onViewDetails: onViewDetails,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('renders celebration dialog with milestones and metrics', (
    tester,
  ) async {
    final milestones = [
      const WorkoutMilestone(
        type: WorkoutMilestoneType.longestDistance,
        title: 'New Longest Distance!',
        subtitle: '5.00 km completed',
        badgeLabel: 'Distance PR',
        isPersonalRecord: true,
      ),
      const WorkoutMilestone(
        type: WorkoutMilestoneType.weeklyConsistency,
        title: '3 Workouts This Week! 🔥',
        subtitle: 'Consistency is your greatest superpower',
        badgeLabel: '3× Week',
      ),
    ];

    await tester.pumpWidget(
      buildTestDialog(
        activity: testActivity,
        milestones: milestones,
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('New Personal Record!'), findsOneWidget);
    expect(find.text('New Longest Distance!'), findsOneWidget);
    expect(find.text('3 Workouts This Week! 🔥'), findsOneWidget);
    expect(find.text('Distance PR'), findsOneWidget);
    expect(find.text('3× Week'), findsOneWidget);
    expect(find.text('5.00 km'), findsOneWidget);
    expect(find.text('Awesome!'), findsOneWidget);
  });

  testWidgets('tapping Awesome! invokes onDone callback', (tester) async {
    var doneCalled = false;
    final milestones = [
      const WorkoutMilestone(
        type: WorkoutMilestoneType.sessionCompleted,
        title: 'Run Completed!',
        subtitle: '5.00 km in 25m 30s',
      ),
    ];

    await tester.pumpWidget(
      buildTestDialog(
        activity: testActivity,
        milestones: milestones,
        onDone: () => doneCalled = true,
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Awesome!'));
    await tester.pumpAndSettle();

    expect(doneCalled, isTrue);
    expect(find.byType(WorkoutCelebrationDialog), findsNothing);
  });

  testWidgets('tapping View Details invokes onViewDetails callback', (
    tester,
  ) async {
    var detailsCalled = false;
    final milestones = [
      const WorkoutMilestone(
        type: WorkoutMilestoneType.sessionCompleted,
        title: 'Run Completed!',
        subtitle: '5.00 km in 25m 30s',
      ),
    ];

    await tester.pumpWidget(
      buildTestDialog(
        activity: testActivity,
        milestones: milestones,
        onViewDetails: () => detailsCalled = true,
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Workout Details'));
    await tester.pumpAndSettle();

    expect(detailsCalled, isTrue);
    expect(find.byType(WorkoutCelebrationDialog), findsNothing);
  });

  testWidgets('tapping Share Win opens WorkoutShareDialog', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final milestones = [
      const WorkoutMilestone(
        type: WorkoutMilestoneType.sessionCompleted,
        title: 'Run Completed!',
        subtitle: '5.00 km in 25m 30s',
      ),
    ];

    await tester.pumpWidget(
      buildTestDialog(
        activity: testActivity,
        milestones: milestones,
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Share Win'), findsOneWidget);
    await tester.tap(find.text('Share Win'));
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutShareDialog), findsOneWidget);
    expect(find.text('Share Your Win 🌟'), findsOneWidget);
  });

  group('RPE stat tile', () {
    final milestones = [
      const WorkoutMilestone(
        type: WorkoutMilestoneType.sessionCompleted,
        title: 'Session Complete!',
        subtitle: '40m mindful session',
      ),
    ];

    testWidgets('shows the RPE tile when the activity carries a rating', (
      tester,
    ) async {
      final mindfulActivity = testActivity.copyWith(
        activityType: ActivityType.yoga,
        workoutDetails: const MindfulWorkoutDetails(rpe: 7),
      );

      await tester.pumpWidget(
        buildTestDialog(
          activity: mindfulActivity,
          milestones: milestones,
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('RPE'), findsOneWidget);
      expect(find.text('7 / 10'), findsOneWidget);
    });

    testWidgets(
      'hides the RPE tile entirely when the activity has no rating',
      (tester) async {
        final unratedActivity = testActivity.copyWith(
          activityType: ActivityType.yoga,
          // No `rpe` passed: the mindful tracker's "Not rated" case.
          workoutDetails: const MindfulWorkoutDetails(),
        );

        await tester.pumpWidget(
          buildTestDialog(
            activity: unratedActivity,
            milestones: milestones,
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('RPE'), findsNothing);
        expect(find.textContaining('Not rated'), findsNothing);
      },
    );

    testWidgets('hides the RPE tile for activity types that never ask', (
      tester,
    ) async {
      // testActivity is a plain run with no workoutDetails at all — the
      // common case for the vast majority of finishing flows.
      await tester.pumpWidget(
        buildTestDialog(
          activity: testActivity,
          milestones: milestones,
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('RPE'), findsNothing);
    });

    testWidgets(
      'does not overflow with all four stat tiles at 320dp/150% text scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearAllTestValues);

        final mindfulActivity = testActivity.copyWith(
          activityType: ActivityType.yoga,
          workoutDetails: const MindfulWorkoutDetails(rpe: 9),
        );

        await tester.pumpWidget(
          buildTestDialog(
            activity: mindfulActivity,
            milestones: milestones,
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        final exception = tester.takeException();
        expect(
          exception,
          isNull,
          reason: exception is FlutterError
              ? exception.diagnostics.map((d) => d.toStringDeep()).join()
              : '$exception',
        );
        expect(find.text('RPE'), findsOneWidget);
        expect(find.text('9 / 10'), findsOneWidget);
      },
    );
  });
}
