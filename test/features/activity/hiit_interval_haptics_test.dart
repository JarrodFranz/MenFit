import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/accessibility/data/accessibility_repository.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';
import 'package:menfit_app/features/activity/presentation/recording/hiit_tracker_controller.dart';
import 'package:menfit_app/features/activity/presentation/recording/hiit_tracker_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The interval timer is the one screen where a haptic carries information
/// rather than decorating it: mid-interval they are not looking at the phone,
/// so "WORK!" in 48pt white type reaches nobody — the pulse is the signal.
/// These tests hold both halves of the promise the Haptic Feedback switch
/// makes: the pulses exist, and they stop when they turn them off.
void main() {
  late List<String> haptics;

  setUp(() {
    haptics = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add('${call.arguments}');
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<ProviderContainer> pumpTracker(
    WidgetTester tester, {
    required bool hapticFeedback,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await AccessibilityRepository(
      preferences,
    ).setPreferences(AccessibilityPreferences(hapticFeedback: hapticFeedback));

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HiitTrackerScreen(
            workSeconds: 5,
            restSeconds: 5,
            totalRounds: 3,
          ),
        ),
      ),
    );
    // The controller starts from a post-frame callback.
    await tester.pump();
    await tester.pump();
    return container;
  }

  /// Tears the tracker down *inside* the test body.
  ///
  /// `HiitTrackerController` runs a one-second periodic ticker that its
  /// `ref.onDispose` cancels, and `TestWidgetsFlutterBinding` checks its
  /// "no pending timers" invariant the moment the body returns — before
  /// any `addTearDown` runs — so disposing the container in a teardown is
  /// too late by construction (same reasoning as
  /// `test/features/weight/weight_test_vocabulary.dart#flushDriftTimers`).
  ///
  /// **Call it as the last statement of the test body.**
  Future<void> disposeTracker(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump(const Duration(milliseconds: 1));
  }

  /// Drives the controller across a boundary without waiting out the real
  /// clock: `skipPhase` is the same `_advancePhase` the ticker calls, and
  /// the screen listens to the phase, not to the timer.
  void advance(ProviderContainer container) {
    container.read(hiitTrackerControllerProvider.notifier).skipPhase();
  }

  testWidgets('pulses at each work/rest boundary when haptics are on', (
    tester,
  ) async {
    final container = await pumpTracker(tester, hapticFeedback: true);

    expect(haptics, isEmpty, reason: 'entering warm-up is not a boundary');

    advance(container); // warm-up -> work
    await tester.pump();
    expect(haptics, ['HapticFeedbackType.heavyImpact']);

    advance(container); // work -> rest
    await tester.pump();
    expect(haptics.last, 'HapticFeedbackType.mediumImpact');

    advance(container); // rest -> work (round 2)
    await tester.pump();
    expect(haptics.last, 'HapticFeedbackType.heavyImpact');
    expect(haptics, hasLength(3));

    await disposeTracker(tester, container);
  });

  testWidgets('marks the end of the session', (tester) async {
    final container = await pumpTracker(tester, hapticFeedback: true);

    for (var i = 0; i < 6; i++) {
      advance(container);
      await tester.pump();
    }

    expect(
      container.read(hiitTrackerControllerProvider).currentPhase,
      HiitPhase.complete,
    );
    expect(haptics.last, 'HapticFeedbackType.heavyImpact');

    await disposeTracker(tester, container);
  });

  testWidgets('stays silent when the preference is off', (tester) async {
    final container = await pumpTracker(tester, hapticFeedback: false);

    for (var i = 0; i < 4; i++) {
      advance(container);
      await tester.pump();
    }

    expect(haptics, isEmpty);

    await disposeTracker(tester, container);
  });
}
