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
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_milestone.dart';

export 'package:menfit_app/core/widgets/share_card_style.dart'
    show ShareCardRatio, ShareCardTheme;

/// Interactive modal sheet allowing users to customize, preview, and share
/// post-workout accomplishment cards across social platforms
/// (Strava, IG Stories).
class WorkoutShareDialog extends ConsumerStatefulWidget {
  const WorkoutShareDialog({
    required this.activity,
    this.milestones = const [],
    this.primaryMetricLabel,
    this.primaryMetricValue,
    super.key,
  });

  final Activity activity;
  final List<WorkoutMilestone> milestones;
  final String? primaryMetricLabel;
  final String? primaryMetricValue;

  /// Convenience launcher.
  static Future<void> show(
    BuildContext context, {
    required Activity activity,
    List<WorkoutMilestone> milestones = const [],
    String? primaryMetricLabel,
    String? primaryMetricValue,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkoutShareDialog(
        activity: activity,
        milestones: milestones,
        primaryMetricLabel: primaryMetricLabel,
        primaryMetricValue: primaryMetricValue,
      ),
    );
  }

  @override
  ConsumerState<WorkoutShareDialog> createState() => _WorkoutShareDialogState();
}

class _WorkoutShareDialogState extends ConsumerState<WorkoutShareDialog> {
  ShareCardRatio _ratio = ShareCardRatio.story;
  ShareCardTheme _theme = ShareCardTheme.signatureOrchid;

  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _shareButtonKey = GlobalKey();

  /// The card as PNG, captured *before* she taps Share.
  ///
  /// On the web `navigator.share()` needs transient user activation and
  /// an `await` inside the tap handler consumes it, so the capture is
  /// done from a post-frame callback whenever the card changes and the
  /// handler only ever reads the result. If the pre-capture has not
  /// landed (or failed) the handler falls back to capturing inline —
  /// correct everywhere, and on the web the browser's download fallback
  /// takes over instead of a share sheet.
  Uint8List? _cardPng;

  /// Which card [_cardPng] is a picture of, so a toggle she flips after
  /// the capture is not silently shared as the old card.
  String? _capturedCard;

  bool _showMilestones = true;

  /// Chip label for a milestone.
  String _chipLabelFor(WorkoutMilestone m) => m.badgeLabel ?? m.title;

  /// Identity of the card as currently configured — every control that
  /// changes a pixel of it appears here.
  String get _cardSignature => '${_ratio.name}|${_theme.name}|$_showMilestones';

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
      // No setState: nothing on screen depends on this, and rebuilding
      // here would queue another capture behind it.
      _cardPng = bytes;
      _capturedCard = signature;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
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
            // Drag handle
            Container(
              margin: EdgeInsets.only(top: tokens.spacingSm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
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
                    'Share Your Win 🌟',
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
                    // Live Card Preview
                    Center(
                      child: _buildCardPreview(context),
                    ),
                    SizedBox(height: tokens.spacingLg),

                    // Format Controls
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
                      onSelectionChanged: (selected) {
                        setState(() => _ratio = selected.first);
                      },
                    ),
                    SizedBox(height: tokens.spacingMd),

                    // Theme Controls
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
                          value: ShareCardTheme.signatureOrchid,
                          label: Text('Orchid'),
                        ),
                        ButtonSegment(
                          value: ShareCardTheme.obsidianDark,
                          label: Text('Obsidian'),
                        ),
                        ButtonSegment(
                          value: ShareCardTheme.cleanLight,
                          label: Text('Light'),
                        ),
                      ],
                      selected: {_theme},
                      onSelectionChanged: (selected) {
                        setState(() => _theme = selected.first);
                      },
                    ),
                    SizedBox(height: tokens.spacingMd),

                    // Toggles
                    if (widget.milestones.isNotEmpty)
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Include Achievements & PRs',
                          style: textTheme.bodyMedium,
                        ),
                        value: _showMilestones,
                        onChanged: (val) =>
                            setState(() => _showMilestones = val),
                      ),
                  ],
                ),
              ),
            ),
            // Two actions, both first-class. Copy is not a fallback for
            // Share: Windows share fails on some editions and desktop
            // Firefox has no Web Share API at all (ADR 011), and the one
            // combined "Share Card / Copy Text" button used to promise a
            // share sheet while only ever writing to the clipboard.
            //
            // Stacked rather than side by side so neither label has to
            // survive an icon plus a large text scale in half a phone
            // width.
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
    final backgroundDecoration = style.backgroundDecoration;
    final textColor = style.textColor;
    final subtextColor = style.subtextColor;
    final accentColor = style.accentColor;

    final distanceKm = (widget.activity.distanceMeters / 1000).toStringAsFixed(
      2,
    );
    final durationStr = _formatDuration(widget.activity.movingTime);

    // The boundary is what `captureCardPng` rasterises for the native
    // share — the preview she is looking at IS the image that gets sent.
    return RepaintBoundary(
      key: _cardKey,
      child: Container(
        width: width,
        height: height,
        decoration: backgroundDecoration.copyWith(
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
            // Header: Brand & Emblem
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.directions_run_rounded,
                      size: 14,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'MenFit',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Main Workout Metric
            Text(
              widget.activity.title.isNotEmpty
                  ? widget.activity.title
                  : '${widget.activity.activityType.label} Session',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: isStory ? 16 : 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Primary metric row
            if (widget.primaryMetricValue != null)
              Text(
                widget.primaryMetricValue!,
                style: TextStyle(
                  color: accentColor,
                  fontSize: isStory ? 28 : 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              )
            else if (widget.activity.distanceMeters > 0)
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    distanceKm,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: isStory ? 32 : 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'km',
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              Text(
                durationStr,
                style: TextStyle(
                  color: accentColor,
                  fontSize: isStory ? 28 : 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

            const SizedBox(height: 6),

            // Stats pills
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildStatPill(
                  Icons.timer_outlined,
                  durationStr,
                  subtextColor,
                  textColor,
                ),
                _buildStatPill(
                  Icons.fitness_center_rounded,
                  widget.activity.activityType.label,
                  subtextColor,
                  textColor,
                ),
              ],
            ),

            // Milestones / PR chips
            if (_showMilestones && widget.milestones.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: widget.milestones.take(2).map((m) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '🏆 ${_chipLabelFor(m)}',
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const Spacer(),

            // Bottom Tagline
            Text(
              'Tuned to her rhythm · MenFit',
              style: TextStyle(
                color: subtextColor,
                fontSize: 8,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(
    IconData icon,
    String text,
    Color subtextColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: subtextColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: subtextColor),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the OS share sheet with the card image and the same summary
  /// text Copy writes.
  ///
  /// Nothing is awaited before the share call when the card was
  /// pre-captured: on the web that first `await` would spend the user
  /// gesture `navigator.share()` requires. Hence the unawaited haptic and
  /// the `??` — `_cardPng` non-null means no suspension at all between
  /// her tap and the platform call.
  Future<void> _handleShare(BuildContext context) async {
    unawaited(AccessibilityHaptics.mediumImpact(ref));

    final adapter = ref.read(sharingAdapterProvider);
    final shareText = _buildShareText();
    final origin = shareOriginOf(
      _shareButtonKey.currentContext ?? context,
    );

    // Read, never capture: capturing here would both spend the web's
    // user gesture and block the tap on an image encode. A card that has
    // not been captured yet degrades to sharing the text.
    final bytes = _cardPng;
    final outcome = bytes == null
        ? await adapter.shareText(shareText, sharePositionOrigin: origin)
        : await adapter.shareImage(
            pngBytes: bytes,
            fileName: 'menfit-workout-card.png',
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
        content: Text('Workout summary copied to clipboard! Ready to share 🌟'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// The one summary text both actions use.
  ///
  /// Share and Copy must produce byte-identical text: the milestone toggle
  /// above the preview is the only consent either surface has, and two
  /// builders would eventually gate it two different ways
  /// (`knowledge/engineering/security_and_privacy.md`).
  String _buildShareText() {
    final distanceKm = (widget.activity.distanceMeters / 1000).toStringAsFixed(
      2,
    );
    final durationStr = _formatDuration(widget.activity.movingTime);
    final shareableMilestones = widget.milestones;
    final prText = _showMilestones && shareableMilestones.isNotEmpty
        ? ' (${shareableMilestones.first.title})'
        : '';
    final distText = widget.activity.distanceMeters > 0
        ? '• Distance: $distanceKm km\n'
        : '';
    final metricText = widget.primaryMetricValue != null
        ? '• ${widget.primaryMetricLabel ?? "Metric"}: '
              '${widget.primaryMetricValue}\n'
        : '';

    final typeLabel = widget.activity.activityType.label;
    return 'Completed a $typeLabel on MenFit!\n'
        '• Time: $durationStr\n'
        '$distText'
        '$metricText'
        '$prText\n'
        '#MenFit #WomensFitness';
  }

  String _formatDuration(Duration duration) {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    if (m >= 60) {
      final h = m ~/ 60;
      final remM = m % 60;
      return '${h}h ${remM}m';
    }
    return '${m}m ${s}s';
  }
}
