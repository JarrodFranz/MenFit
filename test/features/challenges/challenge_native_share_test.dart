import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/sharing/share_feedback.dart';
import 'package:menfit_app/core/platform/sharing/sharing_adapter.dart';
import 'package:menfit_app/core/platform/sharing/sharing_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/challenge_celebration_sheet.dart';
import 'package:menfit_app/features/challenges/presentation/widgets/challenge_code_panel.dart';

import '../../core/platform/sharing/fake_sharing_adapter.dart';
import 'challenge_fixtures.dart';
import 'challenges_test_vocabulary.dart';

/// Share is offered beside Copy on both challenge surfaces, and hands over
/// **exactly** the bytes Copy writes.
///
/// That equality is the whole privacy argument: the code's contents are
/// justified byte by byte in `domain/challenge_codes.dart` and pinned by
/// `challenge_codes_privacy_test.dart`, and the celebration sentence by
/// the co-presence rule in `challenge_surfaces_privacy_test.dart`. A share
/// path that assembled its own text would be a second, unguarded copy of
/// both arguments.
void main() {
  const code = 'FC1abcdefghijklmnop';

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

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    required FakeSharingAdapter sharing,
  }) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharingAdapterProvider.overrideWithValue(sharing)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: Center(child: child)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the code panel', () {
    testWidgets('offers Share and Copy as peers, each saying what it does', (
      tester,
    ) async {
      await pump(
        tester,
        const ChallengeCodePanel(code: code),
        sharing: FakeSharingAdapter(),
      );

      expect(find.text(shareCodeLabel), findsOneWidget);
      expect(find.text(copyCodeLabel), findsOneWidget);
    });

    testWidgets('Share hands over the code and nothing else', (tester) async {
      final sharing = FakeSharingAdapter();
      final copied = interceptClipboard(tester);
      await pump(
        tester,
        const ChallengeCodePanel(code: code),
        sharing: sharing,
      );

      await tester.tap(find.text(shareCodeLabel));
      await tester.pumpAndSettle();

      expect(sharing.textShares.single.text, code);
      expect(sharing.imageShares, isEmpty);
      expect(copied(), isNull);
    });

    testWidgets('the shared code is byte-identical to the copied code', (
      tester,
    ) async {
      final sharing = FakeSharingAdapter();
      final copied = interceptClipboard(tester);
      await pump(
        tester,
        const ChallengeCodePanel(code: code),
        sharing: sharing,
      );

      await tester.tap(find.text(shareCodeLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(copyCodeLabel));
      await tester.pumpAndSettle();

      expect(sharing.textShares.single.text, copied());
    });

    testWidgets('Copy still copies, and still says so', (tester) async {
      final copied = interceptClipboard(tester);
      await pump(
        tester,
        const ChallengeCodePanel(code: code),
        sharing: FakeSharingAdapter(),
      );

      await tester.tap(find.text(copyCodeLabel));
      await tester.pumpAndSettle();

      expect(copied(), code);
      expect(find.text(codeCopiedMessage), findsOneWidget);
    });

    testWidgets('a share the platform cannot confirm is not called done', (
      tester,
    ) async {
      // Windows and the web always land here.
      final sharing = FakeSharingAdapter(
        outcome: ShareOutcome.unavailable,
        supportsShareResult: false,
      );
      await pump(
        tester,
        const ChallengeCodePanel(code: code),
        sharing: sharing,
      );

      await tester.tap(find.text(shareCodeLabel));
      await tester.pumpAndSettle();

      expect(find.text(shareHandedToSystemMessage), findsOneWidget);
      expect(find.text(shareSharedMessage), findsNothing);
    });

    testWidgets('a failed share says the clipboard caught it', (tester) async {
      final sharing = FakeSharingAdapter(
        outcome: ShareOutcome.fellBackToClipboard,
      );
      await pump(
        tester,
        const ChallengeCodePanel(code: code),
        sharing: sharing,
      );

      await tester.tap(find.text(shareCodeLabel));
      await tester.pumpAndSettle();

      expect(find.text(shareCopiedInsteadMessage), findsOneWidget);
    });

    testWidgets('a dismissed sheet says nothing', (tester) async {
      final sharing = FakeSharingAdapter(outcome: ShareOutcome.dismissed);
      await pump(
        tester,
        const ChallengeCodePanel(code: code),
        sharing: sharing,
      );

      await tester.tap(find.text(shareCodeLabel));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('the celebration sheet', () {
    final blueprint = distanceBlueprint();

    Widget sheet() => ChallengeCelebrationSheet(
      blueprint: blueprint,
      selfDisplayName: 'Alex',
      buddyDisplayName: 'Sam',
    );

    testWidgets('offers Share and Copy as peers', (tester) async {
      await pump(tester, sheet(), sharing: FakeSharingAdapter());

      expect(find.text(celebrationSystemShareLabel), findsOneWidget);
      expect(find.text(celebrationShareLabel), findsOneWidget);
    });

    testWidgets('shares the text, never the card image', (tester) async {
      final sharing = FakeSharingAdapter();
      await pump(tester, sheet(), sharing: sharing);

      await tester.tap(find.text(celebrationSystemShareLabel));
      await tester.pumpAndSettle();

      // The card carries both names; what she has always sent from here
      // is the sentence, and that is what Share sends.
      expect(sharing.imageShares, isEmpty);
      expect(
        sharing.textShares.single.text,
        celebrationShareText(
          selfDisplayName: 'Alex',
          buddyDisplayName: 'Sam',
          blueprint: blueprint,
        ),
      );
    });

    testWidgets('the shared sentence is byte-identical to the copied one', (
      tester,
    ) async {
      final sharing = FakeSharingAdapter();
      final copied = interceptClipboard(tester);
      await pump(tester, sheet(), sharing: sharing);

      await tester.tap(find.text(celebrationSystemShareLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(celebrationShareLabel));
      await tester.pumpAndSettle();

      expect(sharing.textShares.single.text, copied());
    });

    testWidgets('the shared sentence clears the challenge vocabulary gate', (
      tester,
    ) async {
      final sharing = FakeSharingAdapter();
      await pump(tester, sheet(), sharing: sharing);

      await tester.tap(find.text(celebrationSystemShareLabel));
      await tester.pumpAndSettle();

      expectNoForbiddenChallengeVocabulary(
        sharing.textShares.single.text,
        source: 'challenge_celebration_sheet.dart shared text',
      );
    });

    testWidgets('an unconfirmable share is not announced as done', (
      tester,
    ) async {
      final sharing = FakeSharingAdapter(
        outcome: ShareOutcome.unavailable,
        supportsShareResult: false,
      );
      await pump(tester, sheet(), sharing: sharing);

      await tester.tap(find.text(celebrationSystemShareLabel));
      await tester.pumpAndSettle();

      expect(find.text(shareHandedToSystemMessage), findsOneWidget);
      expect(find.text(shareSharedMessage), findsNothing);
    });
  });
}
