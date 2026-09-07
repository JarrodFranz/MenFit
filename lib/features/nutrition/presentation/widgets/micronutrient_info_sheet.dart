import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';

/// Modal educational sheet explaining the evidence and rationale behind male
/// micronutrient reference intakes, endurance-training physiology, and
/// partial label data.
class MicronutrientInfoSheet extends StatelessWidget {
  const MicronutrientInfoSheet({super.key});

  /// Opens the sheet via the root navigator.
  static Future<void> show(BuildContext context) {
    return showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const MicronutrientInfoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: tokens.spacingMd,
        right: tokens.spacingMd,
        top: tokens.spacingMd,
        bottom: tokens.spacingLg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Micronutrients & Recovery',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('micronutrientInfoCloseButton'),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingMd),
            const _Section(
              title: 'Iron & Endurance Training',
              body:
                  'Adult men need a baseline iron intake of 8 mg/day. '
                  'Endurance training raises losses through repetitive '
                  'foot-strike impact (hemolysis), sweat, and '
                  'exercise-induced hepcidin surges that can blunt '
                  'absorption for a day or two after a hard session. '
                  'Pairing plant-based (non-heme) iron foods with Vitamin C '
                  'can substantially improve absorption.',
            ),
            SizedBox(height: tokens.spacingMd),
            const _Section(
              title: 'Calcium & Vitamin D Synergy',
              body:
                  'Calcium (1,000 mg/day) and Vitamin D (15 mcg / 600 IU) '
                  'work synergistically to preserve bone mineral density. '
                  'Adequate intake provides a crucial defense against bone '
                  'stress injuries (such as stress fractures) in runners, '
                  'especially when training volume increases.',
            ),
            SizedBox(height: tokens.spacingMd),
            const _Section(
              title: 'Understanding "Partial Reports"',
              body:
                  'Packaged food nutrition panels in many regions only '
                  'mandate macronutrient reporting. When you log foods that '
                  'do not list iron, calcium, or vitamin D, MenFit treats '
                  'those values as unknown rather than assuming zero. The '
                  'reported number represents a minimum floor—your actual '
                  'intake may be higher.',
            ),
            SizedBox(height: tokens.spacingLg),
            Container(
              padding: EdgeInsets.all(tokens.spacingMd),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Not medical advice. Dietary reference intakes are '
                      'general scientific benchmarks for healthy adult '
                      'men. They do not constitute clinical diagnosis '
                      'or personal prescriptions. Consult a sports dietitian '
                      'or healthcare provider for individual guidance.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: tokens.spacingXs),
        Text(body, style: textTheme.bodyMedium),
      ],
    );
  }
}
