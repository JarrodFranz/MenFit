import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/platform/sharing/share_feedback.dart';
import 'package:menfit_app/core/platform/sharing/sharing_providers.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/core/widgets/share_capture.dart';
import 'package:menfit_app/core/widgets/share_card_style.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/presentation/challenges_copy.dart';

/// The shareable card for the one outcome worth a card: both people
/// reached their own goals.
///
/// Reuses Wave 2's share-card system (`core/widgets/share_card_style.dart`
/// — the same [ShareCardRatio] vocabulary and colors as
/// `features/activity/presentation/widgets/workout_share_dialog.dart` and
/// `features/recaps/presentation/widgets/recap_share_sheet.dart`) rather
/// than inventing a third rendering path.
///
/// Two differences from those two sheets, both deliberate:
///
/// * **There is no cycle-phase toggle, because there is nothing to
///   toggle.** The other two sheets offer an opt-in phase pill; a
///   challenge surface has no phase on it to offer, at any point, under
///   any setting. The card someone sends to the friend they are training
///   with is the last place a phase should be one tap away.
/// * **No percentages.** Both people reached their own goals, and that is
///   the whole statement. Printing 118% beside 103% would invite exactly
///   the reading the feature refuses to support, on the one artefact
///   built to be shown to other people.
///
/// Share hands the OS share sheet the *text* (ADR 011), byte-identical to
/// what Copy writes, and Copy stays beside it as a peer rather than a
/// fallback. The card image is deliberately not shared: it carries both
/// names, and what they have always sent from here is the sentence.
class ChallengeCelebrationSheet extends ConsumerStatefulWidget {
  const ChallengeCelebrationSheet({
    required this.blueprint,
    required this.selfDisplayName,
    required this.buddyDisplayName,
    super.key,
  });

  final ChallengeBlueprint blueprint;
  final String selfDisplayName;
  final String buddyDisplayName;

  static Future<void> show(
    BuildContext context, {
    required ChallengeBlueprint blueprint,
    required String selfDisplayName,
    required String buddyDisplayName,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChallengeCelebrationSheet(
        blueprint: blueprint,
        selfDisplayName: selfDisplayName,
        buddyDisplayName: buddyDisplayName,
      ),
    );
  }

  @override
  ConsumerState<ChallengeCelebrationSheet> createState() =>
      _ChallengeCelebrationSheetState();
}

class _ChallengeCelebrationSheetState
    extends ConsumerState<ChallengeCelebrationSheet> {
  ShareCardRatio _ratio = ShareCardRatio.story;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    // Bottom inset comes from `showAppBottomSheet`; no `SafeArea` here.
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            celebrationSheetTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacingMd),
          Center(
            child: _CelebrationCard(ratio: _ratio, source: widget),
          ),
          SizedBox(height: tokens.spacingLg),
          Text(
            celebrationCardFormatLabel,
            style: theme.textTheme.labelLarge,
          ),
          SizedBox(height: tokens.spacingXs),
          SegmentedButton<ShareCardRatio>(
            key: const Key('celebrationRatioSelector'),
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: ShareCardRatio.story,
                label: Text(celebrationStoryLabel),
              ),
              ButtonSegment(
                value: ShareCardRatio.square,
                label: Text(celebrationSquareLabel),
              ),
            ],
            selected: {_ratio},
            onSelectionChanged: (selection) =>
                setState(() => _ratio = selection.first),
          ),
          SizedBox(height: tokens.spacingMd),
          // The Builder is what gives `sharePositionOrigin` the button's
          // own rect, which is what the iPad popover anchors to.
          Builder(
            builder: (buttonContext) => FilledButton.icon(
              key: const Key('celebrationSystemShareButton'),
              onPressed: () => _share(buttonContext),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text(celebrationSystemShareLabel),
            ),
          ),
          SizedBox(height: tokens.spacingSm),
          OutlinedButton.icon(
            key: const Key('celebrationShareButton'),
            onPressed: _copy,
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text(celebrationShareLabel),
          ),
        ],
      ),
    );
  }

  /// The one sentence both actions send. Two builders would eventually
  /// say two different things on the one artefact built to be shown to
  /// another person.
  String get _shareText => celebrationShareText(
    selfDisplayName: widget.selfDisplayName,
    buddyDisplayName: widget.buddyDisplayName,
    blueprint: widget.blueprint,
  );

  Future<void> _share(BuildContext buttonContext) async {
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await ref
        .read(sharingAdapterProvider)
        .shareText(
          _shareText,
          sharePositionOrigin: shareOriginOf(buttonContext),
        );
    final message = shareOutcomeMessage(outcome);
    if (message == null) return;
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copy() async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: _shareText));
    messenger.showSnackBar(
      const SnackBar(content: Text(celebrationCopiedMessage)),
    );
  }
}

class _CelebrationCard extends StatelessWidget {
  const _CelebrationCard({required this.ratio, required this.source});

  final ShareCardRatio ratio;
  final ChallengeCelebrationSheet source;

  @override
  Widget build(BuildContext context) {
    final isStory = ratio == ShareCardRatio.story;
    final style = ShareCardStyle.forTheme(ShareCardTheme.forgeDark);
    final blueprint = source.blueprint;

    return Container(
      key: const Key('challengeCelebrationCard'),
      width: isStory ? 220 : 260,
      height: isStory ? 390 : 260,
      decoration: style.backgroundDecoration.copyWith(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.celebration_rounded,
                size: 16,
                color: style.accentColor,
              ),
              const SizedBox(width: 6),
              Text(
                'MenFit',
                style: TextStyle(
                  color: style.textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            bothReachedTitle,
            style: TextStyle(
              color: style.accentColor,
              fontWeight: FontWeight.w900,
              fontSize: isStory ? 26 : 22,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            celebrationNamesLine(
              source.selfDisplayName,
              source.buddyDisplayName,
            ),
            style: TextStyle(
              color: style.textColor,
              fontWeight: FontWeight.bold,
              fontSize: isStory ? 16 : 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${challengeTargetLine(blueprint)} · '
            '${challengeActivityLine(blueprint.activityTypes)}',
            style: TextStyle(color: style.subtextColor, fontSize: 12),
          ),
          Text(
            challengeWindowLine(blueprint.windowStart, blueprint.windowEnd),
            style: TextStyle(color: style.subtextColor, fontSize: 12),
          ),
          const Spacer(),
          Text(
            celebrationCardFooter,
            style: TextStyle(
              color: style.subtextColor,
              fontSize: 8,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
