import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';
import 'package:menfit_app/features/cycle/presentation/cycle_records_controller.dart';

/// Modal dialog providing cycle settings (e.g. streak pausing) and FAQs.
class CycleSettingsFaqModal extends ConsumerWidget {
  const CycleSettingsFaqModal({super.key});

  static Future<void> show(BuildContext context) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CycleSettingsFaqModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final streakPausingAsync = ref.watch(streakPausingControllerProvider);
    final streakPausingEnabled = streakPausingAsync.value ?? false;

    // Bottom inset comes from `showAppBottomSheet`; no `SafeArea` here.
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            tokens.spacingMd,
            0,
            tokens.spacingMd,
            tokens.spacingLg,
          ),
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: Text(
                    'Cycle Settings & FAQs',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingLg),

            // Settings Section
            Text(
              'Preferences',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            Card(
              margin: EdgeInsets.zero,
              child: SwitchListTile(
                value: streakPausingEnabled,
                onChanged: (val) async {
                  await ref
                      .read(streakPausingControllerProvider.notifier)
                      .setEnabled(enabled: val);
                },
                title: const Text('Treat period days as recovery days'),
                subtitle: const Text(
                  'Days during your period count as protected recovery — '
                  'your fitness streak stays safe without breaking.',
                ),
              ),
            ),
            SizedBox(height: tokens.spacingLg),

            // FAQs Section
            Text(
              'Frequently Asked Questions',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: tokens.spacingSm),

            const _FaqTile(
              question: 'How do predictions adapt to my body?',
              answer:
                  'Instead of assuming a rigid 28-day schedule, the '
                  'prediction engine calculates your rolling median cycle '
                  'length and bleeding duration using your logged periods. '
                  'As you log more data, the predictions reflect your real '
                  'personal baseline.',
            ),
            const _FaqTile(
              question: 'What if my cycles are irregular?',
              answer:
                  'Irregular cycles are completely normal. When cycle '
                  'lengths vary, the confidence score displays as '
                  '"Moderate" or "Getting started" to remind you that '
                  'predictions are broad estimates. You can always log '
                  'your periods as they happen.',
            ),
            const _FaqTile(
              question: 'Where is my cycle data stored?',
              answer:
                  'Your cycle data is stored locally on your device in '
                  'encrypted app storage. It is never sent to external '
                  'servers, analytics trackers, or third parties.',
            ),
            const _FaqTile(
              question: 'Can I use this app for contraception or fertility?',
              answer:
                  'No. MenFit is an informational lifestyle and fitness '
                  'training tool. It is not a medical device, diagnostic '
                  'tool, or contraceptive method.',
            ),
            SizedBox(height: tokens.spacingLg),

            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacingSm),
      child: ExpansionTile(
        title: Text(
          question,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          tokens.spacingMd,
          0,
          tokens.spacingMd,
          tokens.spacingMd,
        ),
        children: [
          Text(
            answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
