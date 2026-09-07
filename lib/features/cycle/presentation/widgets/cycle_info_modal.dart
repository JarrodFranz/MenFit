import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';

/// Modal dialog explaining cycle prediction calculations, confidence levels,
/// cycle phases in plain non-medical language, and the health disclaimer.
class CycleInfoModal extends StatelessWidget {
  const CycleInfoModal({super.key});

  /// Shows the information modal.
  static Future<void> show(BuildContext context) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CycleInfoModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

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
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: Text(
                    'About Cycle Tracking & Predictions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingLg),

            // Section 1: How It Works
            _SectionCard(
              icon: Icons.calculate_outlined,
              title: 'How Predictions Work',
              color: theme.colorScheme.primaryContainer,
              iconColor: theme.colorScheme.primary,
              content:
                  'Your cycle predictions are personal to you. Rather than '
                  'assuming a standard 28-day cycle for everyone, MenFit '
                  'calculates your rolling median cycle length and bleeding '
                  'duration based on your logged period history.\n\n'
                  'As you log more cycles, the engine adapts to your unique '
                  'rhythm, helping you understand your patterns, energy '
                  'levels, and training capacity.',
            ),
            SizedBox(height: tokens.spacingMd),

            // Section 2: What Your Confidence Means
            _SectionCard(
              icon: Icons.verified_outlined,
              title: 'What Your Confidence Score Means',
              color: theme.colorScheme.secondaryContainer,
              iconColor: theme.colorScheme.secondary,
              content:
                  'Predictions show a confidence indicator based on how much '
                  'data you have logged and how regular your cycles are:\n\n'
                  '• High Confidence: 4+ recent regular cycles logged with '
                  'consistent length (within ±3 days).\n'
                  '• Moderate Confidence: 2–3 cycles logged, or mild '
                  'variation in cycle length.\n'
                  '• Getting Started: 0–1 cycles logged or high cycle '
                  'variation. Uses the standard 28-day baseline until more '
                  'data is logged.',
            ),
            SizedBox(height: tokens.spacingMd),

            // Section 3: Cycle Phases in Simple Language
            Text(
              'Cycle Phases in Simple Language',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacingSm),
            _PhaseCard(
              phase: 'Menstrual Phase (Days 1–5)',
              color: tokens.cyclePhaseMenstrual,
              description:
                  'Bleeding days. Estrogen and progesterone are low. '
                  'Rest and low-intensity movement often feel best.',
            ),
            SizedBox(height: tokens.spacingSm),
            _PhaseCard(
              phase: 'Follicular Phase (Days 6–13)',
              color: tokens.cyclePhaseFollicular,
              description:
                  'Estrogen begins to rise as your body prepares an egg. '
                  'Many people notice rising energy and faster recovery.',
            ),
            SizedBox(height: tokens.spacingSm),
            _PhaseCard(
              phase: 'Ovulatory Phase (Days 14–16)',
              color: tokens.cyclePhaseOvulatory,
              description:
                  'Peak estrogen and an LH surge release an egg. Energy and '
                  'strength are typically at their monthly high.',
            ),
            SizedBox(height: tokens.spacingSm),
            _PhaseCard(
              phase: 'Luteal Phase (Days 17–28)',
              color: tokens.cyclePhaseLuteal,
              description:
                  'Progesterone rises to support the uterine lining. Body '
                  'temperature rises slightly, and you may experience PMS as '
                  'hormones dip before your next period.',
            ),
            SizedBox(height: tokens.spacingLg),

            // Section 4: Medical Disclaimer
            Container(
              padding: EdgeInsets.all(tokens.spacingMd),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.gavel_outlined,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(width: tokens.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medical & Contraception Disclaimer',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                          ),
                        ),
                        SizedBox(height: tokens.spacingXs),
                        Text(
                          'MenFit cycle tracking and phase predictions are '
                          'for general informational and lifestyle planning '
                          'only. This is not medical advice, diagnostic '
                          'software, or a method of contraception or '
                          'fertility planning. Always consult a qualified '
                          'healthcare professional for medical guidance.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.spacingMd),

            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.iconColor,
    required this.content,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Color iconColor;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Card(
      margin: EdgeInsets.zero,
      color: color.withValues(alpha: 0.25),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                SizedBox(width: tokens.spacingSm),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingSm),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({
    required this.phase,
    required this.color,
    required this.description,
  });

  final String phase;
  final Color color;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Container(
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: Text(
                  phase,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacingXs),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
