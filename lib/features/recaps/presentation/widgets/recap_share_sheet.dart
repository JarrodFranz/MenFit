import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/platform/sharing/share_feedback.dart';
import 'package:menfit_app/core/platform/sharing/sharing_providers.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/core/widgets/share_capture.dart';
import 'package:menfit_app/core/widgets/share_card_style.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_haptics.dart';
import 'package:menfit_app/features/recaps/domain/month_recap.dart';

/// The recap story's "Save recap card" export sheet — reuses Wave 2's
/// share-card approach (`core/widgets/share_card_style.dart`: the same
/// [ShareCardRatio]/[ShareCardTheme] vocabulary and colors as
/// `features/activity/presentation/widgets/workout_share_dialog.dart`)
/// rather than inventing a second rendering path, per Task 1.3's explicit
/// instruction.
class RecapShareSheet extends ConsumerStatefulWidget {
  const RecapShareSheet({required this.recap, super.key});

  final MonthRecap recap;

  static Future<void> show(BuildContext context, {required MonthRecap recap}) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecapShareSheet(recap: recap),
    );
  }

  @override
  ConsumerState<RecapShareSheet> createState() => _RecapShareSheetState();
}

class _RecapShareSheetState extends ConsumerState<RecapShareSheet> {
  ShareCardRatio _ratio = ShareCardRatio.story;
  ShareCardTheme _theme = ShareCardTheme.forgeDark;

  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _shareButtonKey = GlobalKey();

  /// The card as PNG, captured *before* they tap Share - see the same
  /// field on `activity/presentation/widgets/workout_share_dialog.dart`
  /// for why the capture cannot happen inside the tap handler on the web.
  Uint8List? _cardPng;

  /// Which card [_cardPng] is a picture of.
  String? _capturedCard;

  /// Identity of the card as currently configured - every control that
  /// changes a pixel of it appears here.
  String get _cardSignature => '${_ratio.name}|${_theme.name}';

  /// Guards against the sheet's entrance animation queueing a full-size
  /// raster on every one of its ~15 frames: [build] registers a callback
  /// each time, and a capture already in flight is the answer to all of
  /// them.
  bool _capturing = false;

  void _scheduleCardCapture() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _capturing) return;
      final signature = _cardSignature;
      if (_capturedCard == signature) return;
      _capturing = true;
      final Uint8List? bytes;
      try {
        bytes = await captureCardPng(_cardKey);
      } finally {
        _capturing = false;
      }
      if (!mounted || bytes == null) return;
      _cardPng = bytes;
      _capturedCard = signature;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    _scheduleCardCapture();

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(tokens.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: tokens.spacingSm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacingMd,
                vertical: tokens.spacingSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Save Your Recap 🌟',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(tokens.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: _buildCardPreview(context)),
                    SizedBox(height: tokens.spacingLg),
                    Text(
                      'Card Format',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: tokens.spacingXs),
                    SegmentedButton<ShareCardRatio>(
                      segments: const [
                        ButtonSegment(
                          value: ShareCardRatio.story,
                          label: Text('Story (9:16)'),
                          icon: Icon(Icons.stay_current_portrait_rounded),
                        ),
                        ButtonSegment(
                          value: ShareCardRatio.square,
                          label: Text('Square (1:1)'),
                          icon: Icon(Icons.crop_square_rounded),
                        ),
                      ],
                      selected: {_ratio},
                      onSelectionChanged: (selected) =>
                          setState(() => _ratio = selected.first),
                    ),
                    SizedBox(height: tokens.spacingMd),
                    Text(
                      'Theme Aesthetic',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: tokens.spacingXs),
                    SegmentedButton<ShareCardTheme>(
                      segments: const [
                        ButtonSegment(
                          value: ShareCardTheme.forgeDark,
                          label: Text('Dark'),
                        ),
                        ButtonSegment(
                          value: ShareCardTheme.forgeLight,
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: ShareCardTheme.clean,
                          label: Text('Clean'),
                        ),
                      ],
                      selected: {_theme},
                      onSelectionChanged: (selected) =>
                          setState(() => _theme = selected.first),
                    ),
                  ],
                ),
              ),
            ),
            // Two actions, both first-class - same reasoning as the
            // workout share dialog (ADR 011): Windows share fails on some
            // editions and desktop Firefox has no Web Share API, so Copy
            // is a peer of Share rather than its fallback.
            Padding(
              padding: EdgeInsets.all(tokens.spacingMd),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    key: _shareButtonKey,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share card'),
                    onPressed: () => _handleShare(context),
                  ),
                  SizedBox(height: tokens.spacingSm),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy text'),
                    onPressed: () => _handleCopy(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreview(BuildContext context) {
    final isStory = _ratio == ShareCardRatio.story;
    final width = isStory ? 220.0 : 260.0;
    final height = isStory ? 390.0 : 260.0;
    final style = ShareCardStyle.forTheme(_theme);
    final recap = widget.recap;
    final topPr = recap.topPrs.isNotEmpty ? recap.topPrs.first : null;

    // The boundary is what `captureCardPng` rasterises for the native
    // share - the preview they are looking at IS the image that gets sent.
    return RepaintBoundary(
      key: _cardKey,
      child: Container(
        width: width,
        height: height,
        decoration: style.backgroundDecoration.copyWith(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: style.accentColor.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: style.accentColor,
                    ),
                  ),
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
              recap.period.label,
              style: TextStyle(
                color: style.textColor,
                fontWeight: FontWeight.bold,
                fontSize: isStory ? 20 : 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (recap.totalDistanceMeters != null)
              _statLine(
                style,
                isStory,
                '${(recap.totalDistanceMeters! / 1000).toStringAsFixed(2)} km',
                'moved',
              )
            else if (recap.totalTonnageKg != null)
              _statLine(
                style,
                isStory,
                '${recap.totalTonnageKg!.toStringAsFixed(0)} kg',
                'lifted',
              )
            else
              _statLine(style, isStory, '${recap.sessionCount}', 'sessions'),
            if (topPr != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '🏆 ${topPr.label}',
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Text(
              'Built for the work · MenFit',
              style: TextStyle(
                color: style.subtextColor,
                fontSize: 8,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The card's headline stat: a large [value] with a small [label] beside
  /// it.
  ///
  /// The value is unbounded in length — "50.00 km", "10000 kg" — while the
  /// card is a fixed 220 px (story) or 260 px (square) wide, so it is laid
  /// out [Flexible] inside a scale-down [FittedBox]: it shrinks to fit
  /// instead of overflowing the [Row] (an overflow throws in a widget test
  /// and paints the yellow stripe in the app). The [label] stays
  /// inflexible, so a long value never squeezes "sessions" into an
  /// ellipsis; it is short and known, and takes its intrinsic width first.
  ///
  /// In the normal case nothing is scaled at all and the baseline
  /// alignment below is exact.
  Widget _statLine(
    ShareCardStyle style,
    bool isStory,
    String value,
    String label,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                color: style.accentColor,
                fontSize: isStory ? 30 : 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: style.subtextColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Opens the OS share sheet with the recap card and the same text Copy
  /// writes. Nothing is awaited before the platform call when the card
  /// was pre-captured - see [_cardPng].
  Future<void> _handleShare(BuildContext context) async {
    unawaited(AccessibilityHaptics.mediumImpact(ref));

    final adapter = ref.read(sharingAdapterProvider);
    final shareText = _buildShareText();
    final origin = shareOriginOf(_shareButtonKey.currentContext ?? context);

    // Read, never capture: capturing here would both spend the web's
    // user gesture and block the tap on an image encode. A card that has
    // not been captured yet degrades to sharing the text.
    final bytes = _cardPng;
    final outcome = bytes == null
        ? await adapter.shareText(shareText, sharePositionOrigin: origin)
        : await adapter.shareImage(
            pngBytes: bytes,
            fileName: 'menfit-recap-card.png',
            text: shareText,
            sharePositionOrigin: origin,
          );

    if (!context.mounted) return;
    Navigator.of(context).pop();
    final message = shareOutcomeMessage(outcome);
    if (message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _handleCopy(BuildContext context) async {
    await AccessibilityHaptics.mediumImpact(ref);
    await Clipboard.setData(ClipboardData(text: _buildShareText()));

    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recap copied to clipboard! Ready to share 🌟'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// The one recap text both actions use, so Share and Copy never drift
  /// apart.
  String _buildShareText() {
    final recap = widget.recap;
    final lines = <String>['${recap.period.label} on MenFit!'];
    if (recap.totalDistanceMeters != null) {
      lines.add(
        '• Distance: '
        '${(recap.totalDistanceMeters! / 1000).toStringAsFixed(2)} km',
      );
    }
    if (recap.totalTonnageKg != null) {
      lines.add('• Tonnage: ${recap.totalTonnageKg!.toStringAsFixed(0)} kg');
    }
    lines.add('• Sessions: ${recap.sessionCount}');
    for (final pr in recap.topPrs) {
      lines.add('🏆 ${pr.label}: ${pr.valueLabel}');
    }
    lines.add('#MenFit');
    return lines.join('\n');
  }
}
