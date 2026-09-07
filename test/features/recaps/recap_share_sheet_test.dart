import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/sharing/sharing_adapter.dart';
import 'package:menfit_app/core/platform/sharing/sharing_providers.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/recaps/domain/cycle_recap.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/recaps/domain/recap_pr_highlight.dart';
import 'package:menfit_app/features/recaps/presentation/widgets/recap_share_sheet.dart';

import '../../core/platform/sharing/fake_sharing_adapter.dart';

/// Lets the sheet's pre-capture of the card actually finish.
///
/// `ui.Image.toByteData` completes on the engine, and the fake-async test
/// binding never pumps it - inside [WidgetTester.runAsync] the real event
/// loop runs and the pending PNG lands. Without this the sheet has no
/// bytes at tap time and honestly degrades to sharing the text, which is
/// the behaviour, not a flake.
Future<void> settleCardCapture(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pump();
}

/// The text of the last share, whichever kind it was.
String? lastSharedText(FakeSharingAdapter sharing) =>
    sharing.imageShares.isNotEmpty
    ? sharing.imageShares.last.text
    : sharing.textShares.last.text;

final RecapPeriod _july = RecapPeriod.forMonth(LocalDate(2026, 7, 1));

const String _toggleLabel = 'Include cycle phase context';

RecapPrHighlight _pr({CyclePhase? phase}) => RecapPrHighlight(
  type: RecapPrType.bestEffort,
  label: '5 km best effort',
  valueLabel: '24:12',
  achievedAt: DateTime.utc(2026, 7, 12),
  phase: phase,
);

/// By default carries neither distance nor tonnage, so the preview card's
/// headline stat is the short "12 sessions" line — the phase-toggle tests
/// below are about consent, not typography.
///
/// Pass [totalDistanceMeters] or [totalTonnageKg] for the headline-overflow
/// group: under `flutter_test`'s fixed-width test font every glyph is a
/// full em box, so a "50.00 km" headline at the card's 30px display size is
/// ~240px wide inside a 220px card. That used to overflow the stat [Row]
/// (which throws in a widget test and paints the yellow stripe in the app);
/// `_statLine` now scales the value down instead.
CycleRecap _recap({
  List<RecapPrHighlight> prs = const [],
  double? totalDistanceMeters,
  double? totalTonnageKg,
}) => CycleRecap(
  period: _july,
  sessionCount: 12,
  consistencyRatio: 12 / 31,
  totalDistanceMeters: totalDistanceMeters,
  totalTonnageKg: totalTonnageKg,
  topPrs: prs,
);

void main() {
  /// Gives the sheet a window tall enough to lay every control out.
  void useTallWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Starts recording clipboard writes; the returned getter reads the
  /// latest capture. See the identical helper in
  /// `test/features/activity/workout_share_dialog_test.dart` for why the
  /// platform channel has to be stubbed to see the shared text at all.
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

  /// Mounts the sheet from scratch, unmounting anything already there.
  ///
  /// Both actions close the sheet (`Navigator.pop`), and in these tests the
  /// sheet IS the only route - so after a tap the navigator's history is
  /// empty. Pumping the same tree again does not bring it back:
  /// `pumpWidget` reuses the live `Navigator` element along with its
  /// popped history, and the second half of a two-action test then finds
  /// no buttons at all. Pumping something else first unmounts that
  /// navigator, so the next pump builds a genuinely new one.
  Future<void> pumpSheet(
    WidgetTester tester,
    CycleRecap recap, {
    FakeSharingAdapter? sharing,
  }) async {
    useTallWindow(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (sharing != null)
            sharingAdapterProvider.overrideWithValue(sharing),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: RecapShareSheet(recap: recap)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('RecapShareSheet phase toggle', () {
    testWidgets('defaults off, so the card carries no phase until she asks', (
      tester,
    ) async {
      await pumpSheet(tester, _recap(prs: [_pr(phase: CyclePhase.luteal)]));

      final toggle = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, _toggleLabel),
      );
      expect(toggle.value, isFalse);
      expect(find.text('🏆 5 km best effort'), findsOneWidget);
      expect(find.textContaining('Luteal'), findsNothing);
    });

    testWidgets('turning it on puts the phase on the card', (tester) async {
      await pumpSheet(tester, _recap(prs: [_pr(phase: CyclePhase.luteal)]));

      await tester.tap(find.text(_toggleLabel));
      await tester.pumpAndSettle();

      expect(find.text('🏆 5 km best effort · Luteal'), findsOneWidget);
    });

    testWidgets('is not offered at all when no PR carries a phase', (
      tester,
    ) async {
      await pumpSheet(tester, _recap(prs: [_pr()]));

      expect(find.text(_toggleLabel), findsNothing);
      expect(find.text('🏆 5 km best effort'), findsOneWidget);
    });

    testWidgets('treats CyclePhase.none as no phase — no toggle, no pill', (
      tester,
    ) async {
      // `CyclePredictionEngine.getDayStatus` resolves an unknown day to
      // `none`, which is not a fifth phase: rendering it produced the
      // meaningless "None phase" on every completed-cycle recap.
      await pumpSheet(tester, _recap(prs: [_pr(phase: CyclePhase.none)]));

      expect(find.text(_toggleLabel), findsNothing);
      expect(find.textContaining('None'), findsNothing);
      expect(find.text('🏆 5 km best effort'), findsOneWidget);
    });

    testWidgets('offers the toggle when only some PRs carry a phase', (
      tester,
    ) async {
      await pumpSheet(
        tester,
        _recap(
          prs: [
            _pr(phase: CyclePhase.none),
            _pr(phase: CyclePhase.luteal),
          ],
        ),
      );

      expect(find.text(_toggleLabel), findsOneWidget);
    });
  });

  group('RecapShareSheet card headline fits', () {
    /// Switches the preview to the 1:1 card. Story (9:16) is the default,
    /// so the two ratios together cover both card widths (220 / 260).
    Future<void> selectSquare(WidgetTester tester) async {
      await tester.tap(find.text('Square (1:1)'));
      await tester.pumpAndSettle();
    }

    testWidgets('a long distance headline never overflows the stat row', (
      tester,
    ) async {
      await pumpSheet(tester, _recap(totalDistanceMeters: 50000));

      expect(find.text('50.00 km'), findsOneWidget);
      expect(find.text('moved'), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: 'a RenderFlex overflow is reported as an exception in tests',
      );

      await selectSquare(tester);

      expect(find.text('50.00 km'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a five-figure tonnage headline never overflows either', (
      tester,
    ) async {
      // Falls back to tonnage only when there is no distance at all —
      // `_buildCardPreview`'s if/else-if order.
      await pumpSheet(tester, _recap(totalTonnageKg: 10000));

      expect(find.text('10000 kg'), findsOneWidget);
      expect(find.text('lifted'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await selectSquare(tester);

      expect(find.text('10000 kg'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the short session-count headline still renders unscaled', (
      tester,
    ) async {
      await pumpSheet(tester, _recap());

      expect(find.text('12'), findsOneWidget);
      expect(find.text('sessions'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('RecapShareSheet shared text', () {
    testWidgets('omits the phase while the toggle is off', (tester) async {
      final copied = interceptClipboard(tester);
      await pumpSheet(tester, _recap(prs: [_pr(phase: CyclePhase.luteal)]));

      await tester.tap(find.text('Copy text'));
      await tester.pumpAndSettle();

      expect(copied(), isNotNull);
      expect(copied(), contains('🏆 5 km best effort: 24:12'));
      expect(copied(), isNot(contains('Luteal')));
      expect(copied(), isNot(contains('phase')));
    });

    testWidgets('carries the phase once the toggle is on', (tester) async {
      final copied = interceptClipboard(tester);
      await pumpSheet(tester, _recap(prs: [_pr(phase: CyclePhase.luteal)]));

      await tester.tap(find.text(_toggleLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy text'));
      await tester.pumpAndSettle();

      expect(copied(), contains('🏆 5 km best effort: 24:12 (Luteal phase)'));
    });

    testWidgets('never writes "None phase" for an unknown-phase PR', (
      tester,
    ) async {
      final copied = interceptClipboard(tester);
      await pumpSheet(tester, _recap(prs: [_pr(phase: CyclePhase.none)]));

      await tester.tap(find.text('Copy text'));
      await tester.pumpAndSettle();

      expect(copied(), contains('🏆 5 km best effort: 24:12'));
      expect(copied(), isNot(contains('None')));
    });
  });

  group('RecapShareSheet native share', () {
    testWidgets('Share hands the rendered card and the recap text to the OS', (
      tester,
    ) async {
      final sharing = FakeSharingAdapter();
      final copied = interceptClipboard(tester);
      await pumpSheet(
        tester,
        _recap(prs: [_pr(phase: CyclePhase.luteal)]),
        sharing: sharing,
      );
      await settleCardCapture(tester);

      await tester.tap(find.text('Share card'));
      await tester.pumpAndSettle();

      expect(sharing.shareCount, 1);
      final shared = sharing.imageShares.single;
      expect(shared.fileName, 'femfit-recap-card.png');
      expect(shared.pngBytes.take(4), [0x89, 0x50, 0x4e, 0x47]);
      expect(shared.text, contains('🏆 5 km best effort: 24:12'));
      // The phase toggle is off, and it gates the share as it gates the
      // copy (knowledge/engineering/security_and_privacy.md).
      expect(shared.text, isNot(contains('Luteal')));
      expect(copied(), isNull);
    });

    testWidgets('Share and Copy produce byte-identical text', (tester) async {
      final sharing = FakeSharingAdapter();
      final copied = interceptClipboard(tester);
      final recap = _recap(prs: [_pr(phase: CyclePhase.luteal)]);

      await pumpSheet(tester, recap, sharing: sharing);
      await tester.tap(find.text('Share card'));
      await tester.pumpAndSettle();

      await pumpSheet(tester, recap, sharing: sharing);
      await tester.tap(find.text('Copy text'));
      await tester.pumpAndSettle();

      expect(lastSharedText(sharing), copied());
    });

    testWidgets('the phase toggle gates the shared text too', (tester) async {
      final sharing = FakeSharingAdapter();
      await pumpSheet(
        tester,
        _recap(prs: [_pr(phase: CyclePhase.luteal)]),
        sharing: sharing,
      );

      await tester.tap(find.text(_toggleLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share card'));
      await tester.pumpAndSettle();

      expect(lastSharedText(sharing), contains('(Luteal phase)'));
    });

    testWidgets('an unconfirmable share is never announced as done', (
      tester,
    ) async {
      final sharing = FakeSharingAdapter(
        outcome: ShareOutcome.unavailable,
        supportsShareResult: false,
      );
      await pumpSheet(tester, _recap(), sharing: sharing);

      await tester.tap(find.text('Share card'));
      await tester.pumpAndSettle();

      // The sheet closes on share, so `findsNothing` on the snackbar would
      // pass on an empty tree and prove nothing - that assertion lives on
      // the challenge surfaces, which stay mounted.
      expect(sharing.shareCount, 1);
      expect(find.text('Share card'), findsNothing);
    });
  });
}
