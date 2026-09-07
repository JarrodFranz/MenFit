import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/strength_routine.dart';
import 'package:menfit_app/features/activity/presentation/recording/hiit_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/hiit_tracker_screen.dart';
import 'package:menfit_app/features/activity/presentation/recording/mindful_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/mindful_tracker_screen.dart';
import 'package:menfit_app/features/activity/presentation/recording/strength_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/strength_tracker_screen.dart';
import 'package:menfit_app/features/activity/presentation/recording/swim_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/swim_tracker_screen.dart';
import 'package:menfit_app/features/activity/presentation/widgets/active_workout_banner.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildApp(Widget screen) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: screen,
      ),
    );
  }

  group('StrengthTrackerScreen', () {
    testWidgets('renders exercises, sets table, and volume stats', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(() {
        container
            .read(strengthTrackerControllerProvider.notifier)
            .discardWorkout();
        container.dispose();
      });

      await container
          .read(strengthTrackerControllerProvider.notifier)
          .startWorkout(
            routine: StrengthDayRoutine.create(
              name: 'Strength Workout',
              exercises: const [
                StrengthExerciseTemplate(
                  name: 'Barbell Squat',
                  targetWeightKg: 40,
                ),
              ],
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const StrengthTrackerScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Strength Workout'), findsWidgets);
      expect(find.text('Barbell Squat'), findsOneWidget);
      expect(find.text('VOLUME'), findsOneWidget);
      expect(find.text('SETS'), findsOneWidget);
      expect(find.text('EXERCISES'), findsOneWidget);

      // Start a set
      final playIcons = find.byIcon(Icons.play_circle_outline);
      expect(playIcons, findsWidgets);
      await tester.tap(playIcons.first);
      await tester.pump();

      // Active set bottom sheet appears
      expect(find.text('Finish Set'), findsOneWidget);

      // Finish set -> rest timer starts
      await tester.tap(find.text('Finish Set'));
      await tester.pump();

      expect(find.textContaining('Rest:'), findsOneWidget);
      expect(find.text('+30s'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Tap skip rest
      await tester.tap(find.text('Skip'));
      await tester.pump();
      expect(find.textContaining('Rest:'), findsNothing);

      container
          .read(strengthTrackerControllerProvider.notifier)
          .discardWorkout();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    test(
      'records the elapsed duration the finish dialog chose, not the '
      'wall clock a left-open workout accrued',
      () async {
        final container = ProviderContainer(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);
        final controller = container.read(
          strengthTrackerControllerProvider.notifier,
        );

        await controller.startWorkout();
        await controller.addExercise('Barbell Squat');
        controller.updateSet(0, 0, isCompleted: true, durationSeconds: 45);

        final state = container.read(strengthTrackerControllerProvider);
        expect(
          state.lastInteractionAt,
          isNotNull,
          reason:
              'logging a set must stamp the interaction that the '
              'abandoned-workout check reads',
        );

        // The screen passes this after the user answered the "left
        // running?" question - see strength_tracker_screen.dart.
        final activity = await controller.finishWorkout(
          elapsedOverride: const Duration(minutes: 42),
        );

        expect(activity, isNotNull);
        expect(activity!.elapsedTime, const Duration(minutes: 42));
        expect(activity.movingTime, const Duration(seconds: 45));
      },
    );
  });

  group('SwimTrackerController', () {
    test(
      'records the elapsed duration the finish dialog chose, not the '
      'wall clock a left-open swim accrued',
      () async {
        final container = ProviderContainer(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);
        final controller =
            container.read(swimTrackerControllerProvider.notifier)
              ..startWorkoutIfNeeded()
              ..incrementLap();

        final state = container.read(swimTrackerControllerProvider);
        expect(
          state.lastInteractionAt,
          isNotNull,
          reason:
              'logging a lap must stamp the interaction that the '
              'abandoned-swim check reads',
        );

        // The screen passes this after the user answered the "left
        // running?" question - see swim_tracker_screen.dart.
        final activity = await controller.finishWorkout(
          elapsedOverride: const Duration(minutes: 18),
        );

        expect(activity, isNotNull);
        expect(activity!.elapsedTime, const Duration(minutes: 18));
      },
    );
  });

  group('HiitTrackerScreen', () {
    // Regression guard for deferred item 73: the HIIT tracker previously used
    // unscrollable Column + Spacer(), which overflowed by ~47px at 150% text
    // scaling or on smaller viewports.
    for (final (label, size, scale) in [
      ('320dp phone at 100%', const Size(320, 640), 1.0),
      ('411dp phone at 150%', const Size(411, 891), 1.5),
      ('320dp phone at 150%', const Size(320, 640), 1.5),
    ]) {
      testWidgets('does not overflow on a $label', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearAllTestValues);

        await tester.pumpWidget(
          buildApp(
            const HiitTrackerScreen(
              totalRounds: 4,
            ),
          ),
        );
        await tester.pump();

        final exception = tester.takeException();
        expect(
          exception,
          isNull,
          reason: exception is FlutterError
              ? exception.diagnostics.map((d) => d.toStringDeep()).join()
              : '$exception',
        );
        expect(find.text('HIIT Interval Workout'), findsOneWidget);
        expect(find.text('GET READY'), findsOneWidget);
      });
    }

    testWidgets('displays high-contrast countdown and transitions phases', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          const HiitTrackerScreen(
            totalRounds: 4,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('HIIT Interval Workout'), findsOneWidget);
      expect(find.text('GET READY'), findsOneWidget);
      expect(find.text('ROUND 1 OF 4'), findsOneWidget);

      // Skip warmup phase directly into WORK phase
      final skipButton = find.byIcon(Icons.skip_next_rounded);
      expect(skipButton, findsOneWidget);
      await tester.tap(skipButton);
      await tester.pump();

      expect(find.text('WORK!'), findsOneWidget);

      // Skip WORK phase into REST phase
      await tester.tap(skipButton);
      await tester.pump();

      expect(find.text('REST'), findsOneWidget);
    });
  });

  group('MindfulTrackerScreen', () {
    testWidgets('renders Yoga styles, focus area chips, and RPE slider', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(const MindfulTrackerScreen()),
      );
      await tester.pump();

      expect(find.text('Yoga Session'), findsOneWidget);
      expect(find.text('Mindful Duration'), findsOneWidget);
      expect(find.text('Vinyasa'), findsOneWidget);
      expect(find.text('Yin'), findsOneWidget);
      expect(find.text('Full Body Flow'), findsOneWidget);

      // Select Yin style
      await tester.tap(find.text('Yin'));
      await tester.pump();

      // Scroll to find RPE and notes
      await tester.scrollUntilVisible(
        find.textContaining('Perceived Exertion'),
        200,
      );
      expect(find.textContaining('Perceived Exertion'), findsOneWidget);

      // Tap Finish button
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();
    });

    testWidgets('the RPE slider starts unrated rather than pre-set to 6', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(const MindfulTrackerScreen()));
      await tester.pump();

      await tester.scrollUntilVisible(
        find.textContaining('Perceived Exertion'),
        200,
      );

      // An unanswered RPE must reach storage as null, so the screen may
      // not show a number she never chose.
      expect(find.text('Not rated'), findsOneWidget);
      expect(find.text('6 / 10'), findsNothing);

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();
    });

    testWidgets(
      'displays abandoned finish dialog with trimmed duration when idle',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              mindfulTrackerControllerProvider.overrideWith(
                _AbandonedMindfulTrackerController.new,
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const MindfulTrackerScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Finish'), findsOneWidget);
        await tester.tap(find.text('Finish'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Finish Yoga Session?'), findsOneWidget);
        expect(find.text('Keep Practising'), findsOneWidget);
        expect(
          find.textContaining('Nothing has been logged for a while'),
          findsOneWidget,
        );

        await tester.tap(find.text('Keep Practising'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    test('mindful RPE state starts null and only a choice fills it in', () {
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        mindfulTrackerControllerProvider.notifier,
      );
      expect(container.read(mindfulTrackerControllerProvider).rpe, isNull);

      notifier.startSessionIfNeeded(ActivityType.yoga);
      expect(
        container.read(mindfulTrackerControllerProvider).rpe,
        isNull,
        reason: 'starting a session is not an answer to the RPE question',
      );

      notifier.setRpe(8);
      expect(container.read(mindfulTrackerControllerProvider).rpe, 8);

      notifier.discardSession();
      expect(container.read(mindfulTrackerControllerProvider).rpe, isNull);
    });

    test(
      'records the elapsed duration the finish dialog chose, not the '
      'wall clock a left-open session accrued',
      () async {
        final container = ProviderContainer(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);
        final controller =
            container.read(mindfulTrackerControllerProvider.notifier)
              ..startSessionIfNeeded(ActivityType.yoga)
              ..setRpe(6);

        final state = container.read(mindfulTrackerControllerProvider);
        expect(
          state.lastInteractionAt,
          isNotNull,
          reason:
              'an RPE change must stamp the interaction that the '
              'abandoned-session check reads',
        );

        // The screen passes this after the user answered the "left
        // running?" question - see mindful_tracker_screen.dart.
        final activity = await controller.finishSession(
          elapsedOverride: const Duration(minutes: 40),
        );

        expect(activity, isNotNull);
        expect(activity!.elapsedTime, const Duration(minutes: 40));
      },
    );
  });

  group('SwimTrackerScreen', () {
    // Regression guard for the 2026-09-02 accessibility audit finding: the
    // pool-length / stroke dropdowns sized themselves to their widest item
    // and overflowed their Expanded columns at DEFAULT settings on a 320dp
    // phone (4px), at 411dp (15px) and by up to 144px at large text scales.
    // Test fonts are fixed-width and wider than Inter, so a pass here is a
    // pass on device.
    for (final (label, size, scale) in [
      ('320dp phone at 100%', const Size(320, 640), 1.0),
      ('411dp phone at 150%', const Size(411, 891), 1.5),
      ('320dp phone at 150%', const Size(320, 640), 1.5),
    ]) {
      testWidgets('pool/stroke dropdowns do not overflow on a $label', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearAllTestValues);

        await tester.pumpWidget(buildApp(const SwimTrackerScreen()));
        await tester.pump();

        final exception = tester.takeException();
        // Full diagnostics in the reason so a failure names the widget.
        expect(
          exception,
          isNull,
          reason: exception is FlutterError
              ? exception.diagnostics.map((d) => d.toStringDeep()).join()
              : '$exception',
        );
        expect(find.text('Pool Length'), findsOneWidget);
        expect(find.text('Primary Stroke'), findsOneWidget);
      });
    }

    testWidgets('increments lap tally, updates distance, and allows finish', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(const SwimTrackerScreen()));
      await tester.pump();

      expect(find.text('Swim Tracker'), findsOneWidget);
      expect(find.text('0'), findsOneWidget); // 0 laps

      // Tap huge lap button
      final lapButton = find.text('TAP FOR LAP');
      expect(lapButton, findsOneWidget);
      await tester.tap(lapButton);
      await tester.pump();

      // 1 lap @ 25m = 25 m
      expect(find.text('1'), findsOneWidget);

      // Tap lap button again
      await tester.tap(lapButton);
      await tester.pump();

      // 2 laps @ 25m = 50 m
      expect(find.text('2'), findsOneWidget);
      expect(find.text('50 m'), findsOneWidget);

      // Undo last lap
      await tester.tap(find.text('Undo Last Lap (-1)'));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets(
      'displays abandoned finish dialog with trimmed duration when idle',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              swimTrackerControllerProvider.overrideWith(
                _AbandonedSwimTrackerController.new,
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const SwimTrackerScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Finish'), findsOneWidget);
        await tester.tap(find.text('Finish'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Finish Swim?'), findsOneWidget);
        expect(find.text('Keep Swimming'), findsOneWidget);
        expect(
          find.textContaining('Nothing has been logged for a while'),
          findsOneWidget,
        );

        await tester.tap(find.text('Keep Swimming'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
      },
    );
  });

  group('ActiveWorkoutSummary and ActiveWorkoutBanner', () {
    testWidgets('ActiveWorkoutBanner appears when strength workout is active', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(
              body: Column(
                children: [
                  Text('Home Screen'),
                  ActiveWorkoutBanner(),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Initially no banner
      expect(find.text('Strength Workout'), findsNothing);
      expect(find.text('Resume'), findsNothing);

      // Start strength workout via controller
      container
          .read(strengthTrackerControllerProvider.notifier)
          .startWorkoutIfNeeded();
      await tester.pump();

      // Banner appears!
      expect(find.text('Strength Workout'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);

      // Finish workout
      await container
          .read(strengthTrackerControllerProvider.notifier)
          .finishWorkout();
      await tester.pump();

      // Banner disappears
      expect(find.text('Resume'), findsNothing);
    });

    testWidgets('ActiveWorkoutBanner appears when HIIT workout is active', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(
              body: Column(
                children: [
                  Text('Nutrition Screen'),
                  ActiveWorkoutBanner(),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Start HIIT workout
      container
          .read(hiitTrackerControllerProvider.notifier)
          .startWorkoutIfNeeded(
            workSeconds: 30,
            restSeconds: 15,
            totalRounds: 5,
          );
      await tester.pump();

      // Banner appears
      expect(find.text('HIIT Workout'), findsOneWidget);
      expect(find.textContaining('Round 1/5'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);

      // Pause HIIT
      container.read(hiitTrackerControllerProvider.notifier).togglePlayPause();
      await tester.pump();
      expect(find.text('PAUSED'), findsOneWidget);

      // Discard
      container.read(hiitTrackerControllerProvider.notifier).discardWorkout();
      await tester.pump();
      expect(find.text('Resume'), findsNothing);
    });

    testWidgets(
      'ActiveWorkoutBanner appears when Yoga/Pilates session is active',
      (
        tester,
      ) async {
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const Scaffold(
                body: Column(
                  children: [
                    Text('Wellbeing Screen'),
                    ActiveWorkoutBanner(),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Start Pilates session
        container
            .read(mindfulTrackerControllerProvider.notifier)
            .startSessionIfNeeded(ActivityType.pilates);
        await tester.pump();

        // Banner appears
        expect(find.text('Mat Pilates'), findsOneWidget);
        expect(find.text('Resume'), findsOneWidget);

        // Discard
        container
            .read(mindfulTrackerControllerProvider.notifier)
            .discardSession();
        await tester.pump();
        expect(find.text('Resume'), findsNothing);
      },
    );

    testWidgets('ActiveWorkoutBanner appears when Swim workout is active', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(
              body: Column(
                children: [
                  Text('Settings Screen'),
                  ActiveWorkoutBanner(),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Start swim workout
      final swimNotifier =
          container.read(swimTrackerControllerProvider.notifier)
            ..startWorkoutIfNeeded()
            ..incrementLap()
            ..incrementLap();
      await tester.pump();

      // Banner appears
      expect(find.text('Swim Workout'), findsOneWidget);
      expect(find.textContaining('2 laps'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);

      // Discard
      swimNotifier.discardWorkout();
      await tester.pump();
      expect(find.text('Resume'), findsNothing);
    });
  });

  // The four tracker controllers are `@Riverpod(keepAlive: true)`. That is
  // load-bearing, not decoration: the screens pop while a session is running
  // (the user checks another tab, the active-workout banner brings her back)
  // and an autoDispose provider would rebuild from `build()` the moment its
  // last listener went away, silently throwing the live session, its ticker
  // and everything logged so far on the floor. Each test below closes the
  // only subscription — exactly what popping the screen does — and then
  // checks the session is still there.
  group('tracker controllers are keepAlive', () {
    ProviderContainer makeContainer() {
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('a strength workout survives its last listener closing', () async {
      final container = makeContainer();
      final sub = container.listen(
        strengthTrackerControllerProvider,
        (_, _) {},
      );

      container
          .read(strengthTrackerControllerProvider.notifier)
          .startWorkoutIfNeeded();
      expect(
        container.read(strengthTrackerControllerProvider).isActive,
        isTrue,
      );

      sub.close();
      await container.pump();

      expect(
        container.read(strengthTrackerControllerProvider).isActive,
        isTrue,
        reason: 'the live strength session must outlive its screen',
      );
      container
          .read(strengthTrackerControllerProvider.notifier)
          .discardWorkout();
    });

    test('a swim survives its last listener closing', () async {
      final container = makeContainer();
      final sub = container.listen(swimTrackerControllerProvider, (_, _) {});

      container.read(swimTrackerControllerProvider.notifier)
        ..startWorkoutIfNeeded()
        ..incrementLap();

      sub.close();
      await container.pump();

      final state = container.read(swimTrackerControllerProvider);
      expect(
        state.isActive,
        isTrue,
        reason: 'the swim must outlive its screen',
      );
      expect(state.laps, 1, reason: 'and keep the laps already tallied');
      container.read(swimTrackerControllerProvider.notifier).discardWorkout();
    });

    test('a mindful session survives its last listener closing', () async {
      final container = makeContainer();
      final sub = container.listen(mindfulTrackerControllerProvider, (_, _) {});

      container.read(mindfulTrackerControllerProvider.notifier)
        ..startSessionIfNeeded(ActivityType.pilates)
        ..setRpe(7);

      sub.close();
      await container.pump();

      final state = container.read(mindfulTrackerControllerProvider);
      expect(
        state.isActive,
        isTrue,
        reason: 'the mindful session must outlive its screen',
      );
      expect(state.rpe, 7, reason: 'and keep the RPE she already chose');
      container
          .read(mindfulTrackerControllerProvider.notifier)
          .discardSession();
    });

    test('a HIIT interval run survives its last listener closing', () async {
      final container = makeContainer();
      final sub = container.listen(hiitTrackerControllerProvider, (_, _) {});

      container
          .read(hiitTrackerControllerProvider.notifier)
          .startWorkoutIfNeeded(totalRounds: 5);

      sub.close();
      await container.pump();

      final state = container.read(hiitTrackerControllerProvider);
      expect(
        state.isActive,
        isTrue,
        reason: 'the interval countdown must outlive its screen',
      );
      expect(state.totalRounds, 5, reason: 'and keep the configured rounds');
      container.read(hiitTrackerControllerProvider.notifier).discardWorkout();
    });
  });
}

class _AbandonedSwimTrackerController extends SwimTrackerController {
  @override
  SwimTrackerState build() {
    final now = DateTime.now().toUtc();
    return SwimTrackerState(
      isActive: true,
      startedAt: now.subtract(const Duration(minutes: 30)),
      lastInteractionAt: now.subtract(const Duration(minutes: 25)),
      elapsedDuration: const Duration(minutes: 30),
      laps: 4,
    );
  }
}

class _AbandonedMindfulTrackerController extends MindfulTrackerController {
  @override
  MindfulTrackerState build() {
    final now = DateTime.now().toUtc();
    return MindfulTrackerState(
      isActive: true,
      startedAt: now.subtract(const Duration(minutes: 60)),
      lastInteractionAt: now.subtract(const Duration(minutes: 50)),
      elapsedDuration: const Duration(minutes: 60),
    );
  }
}
