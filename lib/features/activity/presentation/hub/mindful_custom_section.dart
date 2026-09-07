import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/mindful_styles.dart';
import 'package:menfit_app/features/activity/presentation/recording/mindful_tracker_controller.dart';

/// One neutral sentence per offered style, describing *the practice* — never
/// what it is supposed to do to a body.
///
/// Public so `mindful_styles_source_of_truth_test.dart` can assert its key
/// set is exactly `MindfulStyles.yogaStyles + pilatesStyles`. That is what
/// keeps this from becoming the fourth copy of the style list: it is a map
/// *keyed by* the source of truth, checked against it.
///
/// No benefit, therapeutic or outcome claims ("releases fascia", "tones",
/// "detoxes"): `knowledge/domain/womens_health.md` gates any health claim on
/// evidence, and none of these would clear it. A style with no entry falls
/// back to [_fallbackStyleDescription], so adding a label to
/// [MindfulStyles] can never leave the dialog empty.
const Map<String, String> mindfulStyleDescriptions = {
  // Yoga
  'Vinyasa': 'Poses linked into a continuous flow, moving with the breath.',
  'Yin': 'Seated and lying poses held for several minutes at a time.',
  'Hatha': 'A slower practice, one pose at a time with a pause between.',
  'Ashtanga': 'A set series of poses, practised in the same order each time.',
  'Power Yoga': 'A brisk, strength-led flow with fewer pauses.',
  'Restorative': 'Slow holds and long breaths, with props for support.',
  'Kundalini': 'Repeated movements combined with breathwork and chanting.',
  // Pilates
  'Mat Pilates': 'Mat-based exercises using your own body weight.',
  'Reformer Pilates': 'Exercises on a reformer, against spring resistance.',
  'Classical': 'The original Pilates exercises, worked through in order.',
  'Contemporary': 'Pilates adapted with a wider range of exercises and props.',
  'Core Power': 'Faster-paced work centred on the trunk.',
};

const String _fallbackStyleDescription =
    'A mindful practice. Start the timer and log it your own way.';

/// Style chips for Yoga / Pilates on the exercise hub.
///
/// Every style in [MindfulStyles.stylesFor] gets a chip (yoga: 7,
/// pilates: 5) and the label it shows is *exactly* the string handed to
/// `setStyle`, so the tracker's own chip for that style is already selected
/// when it opens. Before ADR 014 §5 this card hard-coded three chips whose
/// labels ("Restorative / Yin") and payloads ("Restorative Yin") matched
/// neither each other nor the tracker's list, so arriving from here always
/// left the tracker with nothing selected.
class MindfulCustomSection extends ConsumerWidget {
  const MindfulCustomSection({required this.type, super.key});

  final ActivityType type;

  void _showMindfulStyleDialog(
    BuildContext context,
    WidgetRef ref, {
    required String styleName,
  }) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: Text(styleName),
          content: Text(
            mindfulStyleDescriptions[styleName] ?? _fallbackStyleDescription,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                ref
                    .read(mindfulTrackerControllerProvider.notifier)
                    .startSessionIfNeeded(type);
                ref
                    .read(mindfulTrackerControllerProvider.notifier)
                    .setStyle(styleName);
                unawaited(
                  MindfulTrackerRouteData(
                    type: type == ActivityType.pilates ? 'pilates' : 'yoga',
                  ).push<void>(context),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Flow'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.light();
    final styles = MindfulStyles.stylesFor(type);

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: themedCardShape(
        context,
        radius: 16,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${type.label} Style Focus',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            // `Wrap` bounds each chip to the card width, so a long label
            // wraps inside its own chip rather than overflowing the row at
            // 320dp / 150% text.
            Wrap(
              spacing: tokens.spacingSm,
              runSpacing: tokens.spacingSm,
              children: [
                for (final style in styles)
                  ActionChip(
                    key: ValueKey('mindfulStyleChip_$style'),
                    avatar: Icon(_styleIcon(type), size: 16),
                    label: Text(style),
                    onPressed: () => _showMindfulStyleDialog(
                      context,
                      ref,
                      styleName: style,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _styleIcon(ActivityType type) => type == ActivityType.pilates
      ? Icons.accessibility_new
      : Icons.self_improvement;
}
