import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// `hide`: Drift generates a row class of the same name from the
// `yoga_sequences` table, and the domain entity is the one under test.
import 'package:menfit_app/core/db/app_database.dart' show AppDatabase;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/platform/audio/audio_cue_providers.dart';
import 'package:menfit_app/core/platform/wakelock/screen_awake_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/achievements/achievements_providers.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';
import 'package:menfit_app/features/activity/presentation/recording/yoga_sequence_runner_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/yoga_sequence_runner_screen.dart';

import '../../../../core/platform/audio/fake_audio_cue_player.dart';
import '../../../../core/platform/wakelock/fake_screen_awake.dart';
import '../../fake_activity_repository.dart';

/// The runner screen, with the two channels a practice actually relies on
/// wired to doubles: the chime (`FakeAudioCuePlayer`) and the haptic (the
/// platform-channel spy, same trick as
/// `test/features/activity/hiit_interval_haptics_test.dart`).
///
/// The countdown is *not* under test here — the clock-driven phase machine
/// has its own test — so the runner's clock is frozen and every boundary is
/// reached by pressing skip. That is deliberate: a cue must fire once per
/// boundary however the boundary was reached.
void main() {
  late AppDatabase db;
  late FakeActivityRepository activities;
  late FakeAudioCuePlayer player;
  late FakeScreenAwake screenAwake;
  late List<String> haptics;
  late DateTime now;

  const sequenceId = 'seq-1';

  final sequence = YogaSequence(
    id: sequenceId,
    name: 'Morning flow',
    description: 'A short standing sequence.',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    style: 'Vinyasa',
    // transitionSeconds left at defaultTransitionSeconds (5).
    poses: const [
      YogaPose(name: 'Mountain', holdSeconds: 30),
      YogaPose(name: 'Warrior II', holdSeconds: 40, side: YogaPoseSide.left),
      YogaPose(name: 'Tree', holdSeconds: 30),
    ],
  );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    activities = FakeActivityRepository();
    player = FakeAudioCuePlayer();
    screenAwake = FakeScreenAwake();
    haptics = [];
    now = DateTime.utc(2026, 9, 4, 7);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add('${call.arguments}');
          }
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    await activities.dispose();
    await db.close();
  });

  Future<ProviderContainer> pumpRunner(
    WidgetTester tester, {
    double? width,
    double textScale = 1,
  }) async {
    if (width != null) {
      tester.view
        ..physicalSize = Size(width, 780)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        // The practice is written through this: a fake, so the save
        // can be made to fail and the attempts counted.
        activityRepositoryProvider.overrideWithValue(activities),
        // The celebration dialog reads it; nothing here is about
        // badges.
        badgeProgressProvider.overrideWith((ref) async => const []),
        audioCuePlayerProvider.overrideWithValue(player),
        screenAwakeProvider.overrideWithValue(screenAwake),
      ],
    );
    await container.read(yogaSequenceRepositoryProvider).saveSequence(sequence);
    // Frozen: nothing in this file is about the countdown, and a live one
    // would race the assertions.
    container.read(yogaSequenceRunnerControllerProvider.notifier).clock = () =>
        now;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const YogaSequenceRunnerScreen(sequenceId: sequenceId),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    );
    // Let the Drift-backed sequence stream deliver its first row.
    await tester.pumpAndSettle();
    return container;
  }

  /// Tears the tree down *inside* the test body.
  ///
  /// Does the job of both `flushDriftTimers` and the HIIT tracker's
  /// `disposeTracker`: the runner holds a one-second ticker cancelled by
  /// its `ref.onDispose`, and the sequence stream holds Drift's, and
  /// `TestWidgetsFlutterBinding` checks "no pending timers" the moment the
  /// body returns — before any `addTearDown` runs.
  ///
  /// **Call it as the last statement of the test body.**
  Future<void> flushDriftTimers(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump(const Duration(milliseconds: 1));
  }

  /// Ends the current phase and lets the screen react — the same
  /// `_advanceAt` the countdown would have run, without waiting on it.
  Future<void> skipPhase(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    container.read(yogaSequenceRunnerControllerProvider.notifier).skipForward();
    await tester.pump();
  }

  /// Presses Start and lets the first pose render.
  Future<void> startPractice(WidgetTester tester) async {
    // Scrolled into view first: at 150% text scale on a 320dp screen the
    // button sits below the fold, and a tap on an off-screen widget is a
    // test failure rather than a layout one.
    await tester.ensureVisible(find.text('Start practice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start practice'));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('offers the sequence before it starts, and does not start it', (
    tester,
  ) async {
    final container = await pumpRunner(tester);

    expect(find.text('Morning flow'), findsWidgets);
    expect(find.text('3 poses'), findsOneWidget);
    expect(find.text('Start practice'), findsOneWidget);
    // Nothing is cued, locked or played until they ask for it.
    expect(screenAwake.acquireCount, 0);
    expect(player.preloadCount, 0);
    expect(haptics, isEmpty);

    await flushDriftTimers(tester, container);
  });

  testWidgets('Start opens the first pose and cues it exactly once', (
    tester,
  ) async {
    final container = await pumpRunner(tester);

    await startPractice(tester);

    expect(find.text('Mountain'), findsOneWidget);
    expect(find.text('Pose 1 of 3'), findsOneWidget);
    expect(find.text('Next: Warrior II, left'), findsOneWidget);
    expect(find.text('Start practice'), findsNothing);

    expect(player.preloadCount, 1);
    expect(screenAwake.held, isTrue);
    expect(player.chimeCount, 1);
    expect(haptics, ['HapticFeedbackType.heavyImpact']);

    await flushDriftTimers(tester, container);
  });

  testWidgets('each boundary fires one cue, whether or not time ran out', (
    tester,
  ) async {
    final container = await pumpRunner(tester);
    await startPractice(tester);

    await skipPhase(tester, container); // -> transition
    expect(find.text('Transition'), findsOneWidget);
    expect(player.chimeCount, 2);
    expect(haptics.last, 'HapticFeedbackType.mediumImpact');

    await skipPhase(tester, container); // -> pose 2
    expect(find.text('Warrior II, left'), findsWidgets);
    expect(player.chimeCount, 3);
    expect(haptics.last, 'HapticFeedbackType.heavyImpact');
    expect(haptics, hasLength(3));

    await flushDriftTimers(tester, container);
  });

  testWidgets('pausing and resuming is not a boundary and cues nothing', (
    tester,
  ) async {
    final container = await pumpRunner(tester);
    await startPractice(tester);

    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    expect(find.text('Paused'), findsOneWidget);

    await tester.tap(find.byTooltip('Resume'));
    await tester.pump();

    expect(player.chimeCount, 1, reason: 'only the Start cue');
    expect(haptics, hasLength(1));

    await flushDriftTimers(tester, container);
  });

  testWidgets('mute silences the chime but never the haptic', (tester) async {
    final container = await pumpRunner(tester);
    await startPractice(tester);

    await tester.tap(find.byTooltip('Mute chime'));
    await tester.pump();
    expect(find.text('Chime muted'), findsOneWidget);

    container.read(yogaSequenceRunnerControllerProvider.notifier).skipForward();
    await tester.pump();

    expect(player.chimeCount, 1, reason: 'still just the Start cue');
    // The pulse is the channel that survives a silenced phone; muting the
    // sound must not take it away too.
    expect(haptics, hasLength(2));
    expect(haptics.last, 'HapticFeedbackType.mediumImpact');

    await flushDriftTimers(tester, container);
  });

  testWidgets('reaching the end offers the practised time and a save', (
    tester,
  ) async {
    final container = await pumpRunner(tester);
    await startPractice(tester);

    for (var i = 0; i < 5; i++) {
      await skipPhase(tester, container);
    }

    expect(find.text('Sequence complete'), findsOneWidget);
    expect(find.text('Save practice'), findsOneWidget);
    expect(haptics.last, 'HapticFeedbackType.heavyImpact');

    await flushDriftTimers(tester, container);
  });

  testWidgets('lays out at 320dp and 150% text without overflowing', (
    tester,
  ) async {
    final container = await pumpRunner(tester, width: 320, textScale: 1.5);

    expect(tester.takeException(), isNull);

    await startPractice(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Mountain'), findsOneWidget);

    await flushDriftTimers(tester, container);
  });

  /// Reaches the end of the sequence the way this file always does: by
  /// skipping, not by waiting.
  Future<void> practiseToTheEnd(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    await startPractice(tester);
    for (var i = 0; i < 5; i++) {
      await skipPhase(tester, container);
    }
    expect(find.text('Sequence complete'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('yogaRunnerSaveButton')));
    await tester.pumpAndSettle();
  }

  testWidgets('two rapid taps on Save write one activity', (tester) async {
    final container = await pumpRunner(tester);
    await practiseToTheEnd(tester, container);

    // Both taps land in the same frame - no pump between them - which is
    // exactly what a double tap is.
    await tester.tap(find.byKey(const Key('yogaRunnerSaveButton')));
    await tester.tap(
      find.byKey(const Key('yogaRunnerSaveButton')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(activities.saveAttempts, 1);
    expect(activities.saved, hasLength(1));

    await flushDriftTimers(tester, container);
  });

  testWidgets('a save that fails says so and keeps the practice', (
    tester,
  ) async {
    final container = await pumpRunner(tester);
    await practiseToTheEnd(tester, container);
    activities.failSaves = true;

    await tester.tap(find.byKey(const Key('yogaRunnerSaveButton')));
    await tester.pumpAndSettle();

    expect(
      find.text('Something went wrong saving your data. Please try again.'),
      findsOneWidget,
    );
    // Still here, still complete, still saveable - they have not been popped
    // out of a practice that was never stored.
    expect(find.text('Sequence complete'), findsOneWidget);
    expect(find.text('Save practice'), findsOneWidget);
    expect(screenAwake.held, isFalse);

    activities.failSaves = false;
    await tester.tap(find.byKey(const Key('yogaRunnerSaveButton')));
    await tester.pumpAndSettle();

    expect(activities.saved, hasLength(1));

    await flushDriftTimers(tester, container);
  });

  testWidgets('a suspension that swallowed poses says so, for one tick', (
    tester,
  ) async {
    final container = await pumpRunner(tester);
    await startPractice(tester);

    // 30s hold, 5s gap, 40s hold, 5s gap: 80 seconds of locked screen
    // lands at the top of the third pose, four boundaries later.
    now = now.add(const Duration(seconds: 80));
    container.read(yogaSequenceRunnerControllerProvider.notifier).tick();
    await tester.pump();

    expect(find.text('Tree'), findsOneWidget);
    expect(find.text('Skipped ahead to where you are'), findsOneWidget);

    now = now.add(const Duration(seconds: 1));
    container.read(yogaSequenceRunnerControllerProvider.notifier).tick();
    await tester.pump();

    expect(
      find.text('Skipped ahead to where you are'),
      findsNothing,
      reason: 'The countdown on screen answers it from here on.',
    );

    await flushDriftTimers(tester, container);
  });

  group('another sequence already running', () {
    final other = YogaSequence(
      id: 'seq-2',
      name: 'Wind down',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      poses: const [YogaPose(name: 'Legs Up the Wall', holdSeconds: 300)],
    );

    testWidgets('offers a way back and an explicit discard, not Start', (
      tester,
    ) async {
      final container = await pumpRunner(tester);
      container
          .read(yogaSequenceRunnerControllerProvider.notifier)
          .start(other);
      await tester.pump();

      expect(
        find.text('You have a practice running: Wind down'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('yogaRunnerGoBackButton')), findsOneWidget);
      expect(
        find.byKey(const Key('yogaRunnerDiscardAndStartButton')),
        findsOneWidget,
      );
      // The bare Start button is gone: it would have destroyed the other
      // practice without saying so.
      expect(find.byKey(const Key('yogaStartPracticeButton')), findsNothing);

      await flushDriftTimers(tester, container);
    });

    testWidgets('discarding it starts this one and leaks no wakelock', (
      tester,
    ) async {
      final container = await pumpRunner(tester);
      container
          .read(yogaSequenceRunnerControllerProvider.notifier)
          .start(other);
      await tester.pump();

      await tester.ensureVisible(
        find.byKey(const Key('yogaRunnerDiscardAndStartButton')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('yogaRunnerDiscardAndStartButton')),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Mountain'), findsOneWidget);
      expect(find.text('Pose 1 of 3'), findsOneWidget);
      // One lock outstanding, not two.
      expect(screenAwake.acquireCount, 2);
      expect(screenAwake.releaseCount, 1);
      expect(screenAwake.held, isTrue);

      await flushDriftTimers(tester, container);
    });
  });
}
