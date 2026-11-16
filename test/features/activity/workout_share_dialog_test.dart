import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/sharing/sharing_adapter.dart';
import 'package:menfit_app/core/platform/sharing/sharing_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_milestone.dart';
import 'package:menfit_app/features/activity/presentation/widgets/workout_share_dialog.dart';

import '../../core/platform/sharing/fake_sharing_adapter.dart';
import '../achievements/achievements_test_vocabulary.dart';

/// Lets the sheet's pre-capture of the card actually finish.
///
/// `ui.Image.toByteData` completes on the engine, and the fake-async test
/// binding never pumps it - inside [WidgetTester.runAsync] the real event
/// loop runs and the pending PNG lands. Without this the sheet has no
/// bytes at tap time and honestly degrades to sharing the text, which is
/// the behaviour, not a flake.
Future<void> settleCardCapture(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
}

/// The text of the last share, whichever kind it was.
String? lastSharedText(FakeSharingAdapter sharing) =>
    sharing.imageShares.isNotEmpty
    ? sharing.imageShares.last.text
    : sharing.textShares.last.text;

void main() {
  final testActivity = Activity(
    id: 'act-share-1',
    activityType: ActivityType.run,
    title: 'Morning 5k Tempo',
    startedAt: DateTime.utc(2026, 2, 6, 7),
    movingTime: const Duration(minutes: 26, seconds: 14),
    elapsedTime: const Duration(minutes: 26, seconds: 14),
    distanceMeters: 5000,
    source: ActivitySource.recorded,
    createdAt: DateTime.utc(2026, 2, 6, 7),
    updatedAt: DateTime.utc(2026, 2, 6, 7),
  );

  final testMilestones = [
    const WorkoutMilestone(
      type: WorkoutMilestoneType.longestDistance,
      title: 'New Distance PR',
      subtitle: '26:14 — 5 km',
      badgeLabel: '5k PR',
      isPersonalRecord: true,
    ),
  ];

  Widget buildTestWidget({FakeSharingAdapter? sharing, Activity? activity}) {
    return ProviderScope(
      overrides: [
        if (sharing != null) sharingAdapterProvider.overrideWithValue(sharing),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: WorkoutShareDialog(
            activity: activity ?? testActivity,
            milestones: activity == null ? testMilestones : const [],
          ),
        ),
      ),
    );
  }

  /// Gives the sheet a window tall enough to lay every control out without
  /// scrolling.
  void useTallWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Mounts the sheet from scratch, unmounting anything already there.
  ///
  /// Both actions close the sheet (`Navigator.pop`), and in these tests the
  /// sheet IS the only route - so after a tap the navigator's history is
  /// empty. Pumping the same tree again does not bring it back: `pumpWidget`
  /// reuses the live `Navigator` element along with its popped history, and
  /// the second half of a two-action test then finds no buttons at all.
  /// Pumping something else first unmounts that navigator, so the next pump
  /// builds a genuinely new one.
  Future<void> mountDialog(WidgetTester tester, Widget dialog) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(dialog);
    await tester.pumpAndSettle();
  }

  /// Starts recording whatever the sheet writes to the clipboard; the
  /// returned getter reads the latest capture.
  ///
  /// `Clipboard.setData` is a `SystemChannels.platform` method call that
  /// nothing answers in a widget test. Stubbing it is the only way to
  /// assert on what a share actually put on the user's clipboard.
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

  testWidgets('renders share card generator with previews, formats, and '
      'toggles', (tester) async {
    useTallWindow(tester);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    await settleCardCapture(tester);

    // Verify title and brand watermark
    expect(find.text('Share Your Win 🌟'), findsOneWidget);
    expect(find.text('MenFit'), findsWidgets);
    expect(find.text('Morning 5k Tempo'), findsOneWidget);
    expect(find.text('5.00'), findsOneWidget); // Distance km
    expect(find.text('km'), findsOneWidget);
    expect(find.text('🏆 5k PR'), findsOneWidget);

    // Verify Format Segmented buttons
    expect(find.text('Story (9:16)'), findsOneWidget);
    expect(find.text('Square (1:1)'), findsOneWidget);

    // Switch format to Square
    await tester.tap(find.text('Square (1:1)'));
    await tester.pumpAndSettle();
    await settleCardCapture(tester);

    // Switch theme to Forge Light
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    await settleCardCapture(tester);

    // Both actions are offered, each saying what it actually does.
    expect(find.text('Share card'), findsOneWidget);
    expect(find.text('Copy text'), findsOneWidget);
    await tester.tap(find.text('Copy text'));
    await tester.pumpAndSettle();
  });

  group('native share', () {
    /// The card image and the summary text go together, and neither the
    /// share nor the copy may say more than the toggles allow.
    testWidgets('Share hands the rendered card and the summary to the OS', (
      tester,
    ) async {
      useTallWindow(tester);
      final sharing = FakeSharingAdapter();
      final copied = interceptClipboard(tester);

      await tester.pumpWidget(buildTestWidget(sharing: sharing));
      await tester.pumpAndSettle();
      await settleCardCapture(tester);

      await tester.tap(find.text('Share card'));
      await tester.pumpAndSettle();

      expect(sharing.shareCount, 1);
      final shared = sharing.imageShares.single;
      expect(shared.fileName, 'menfit-workout-card.png');
      // The PNG magic number: proof the RepaintBoundary actually
      // rasterised rather than the handler falling through to text.
      expect(shared.pngBytes.take(4), [0x89, 0x50, 0x4e, 0x47]);
      expect(shared.text, contains('Completed a Run on MenFit!'));
      // Share is not a copy in disguise - the clipboard is untouched.
      expect(copied(), isNull);
    });

    testWidgets('strength share omits incidental distance from card and text', (
      tester,
    ) async {
      useTallWindow(tester);
      final copied = interceptClipboard(tester);
      await mountDialog(
        tester,
        buildTestWidget(
          activity: testActivity.copyWith(
            activityType: ActivityType.strength,
            distanceMeters: 130,
          ),
        ),
      );
      expect(find.textContaining('0.13'), findsNothing);
      expect(find.text('Distance'), findsNothing);
      await tester.tap(find.text('Copy text'));
      await tester.pumpAndSettle();
      expect(copied(), isNot(contains('Distance:')));
      expect(copied(), contains('Strength'));
    });

    testWidgets('Share and Copy produce byte-identical text', (tester) async {
      useTallWindow(tester);
      final sharing = FakeSharingAdapter();
      final copied = interceptClipboard(tester);

      await mountDialog(tester, buildTestWidget(sharing: sharing));
      await tester.tap(find.text('Share card'));
      await tester.pumpAndSettle();

      await mountDialog(tester, buildTestWidget(sharing: sharing));
      await tester.tap(find.text('Copy text'));
      await tester.pumpAndSettle();

      // One builder, two buttons. Two builders would eventually gate the
      // milestones toggle two different ways
      // (knowledge/engineering/security_and_privacy.md).
      expect(lastSharedText(sharing), copied());
    });

    testWidgets('the shared summary clears the achievements vocabulary gate', (
      tester,
    ) async {
      useTallWindow(tester);
      final sharing = FakeSharingAdapter();

      await tester.pumpWidget(buildTestWidget(sharing: sharing));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share card'));
      await tester.pumpAndSettle();

      // The card carries PR and milestone titles, so it is held to the
      // achievements list - the one that bans goal/target/completion
      // framing. Deliberately not the challenges or weight list: three
      // separate lists guard three different risks
      // (knowledge/engineering/security_and_privacy.md).
      expectNoForbiddenAchievementVocabulary(
        lastSharedText(sharing)!,
        source: 'workout_share_dialog.dart shared text',
      );
    });

    testWidgets('an unconfirmable share is never announced as done', (
      tester,
    ) async {
      useTallWindow(tester);
      // What Windows and the web always return.
      final sharing = FakeSharingAdapter(
        outcome: ShareOutcome.unavailable,
        supportsShareResult: false,
      );

      await mountDialog(tester, buildTestWidget(sharing: sharing));
      await tester.tap(find.text('Share card'));
      await tester.pumpAndSettle();

      // The sheet closes on share, so `findsNothing` here would pass on an
      // empty tree and prove nothing. What this surface can assert is that
      // the share happened and the sheet closed; that the snackbar never
      // says "Shared." is asserted where the surface stays mounted -
      // `test/features/challenges/challenge_native_share_test.dart` and
      // `test/core/platform/sharing/share_feedback_test.dart`.
      expect(sharing.shareCount, 1);
      expect(find.text('Share card'), findsNothing);
    });
  });
}
