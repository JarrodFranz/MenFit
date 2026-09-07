import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/insights/domain/personal_insight.dart';
import 'package:menfit_app/features/insights/presentation/insight_sentence.dart';

/// One discovery card: the composed sentence, plus how firmly the data
/// separates and the span it covers.
///
/// Affirming by omission rather than by adjective — there is no "good"
/// or "bad" styling here (no success/warning colour, no up/down arrow),
/// because none of these metrics has a good direction
/// ([InsightMetric]'s dartdoc). A shorter run is not a failure and a higher
/// RPE is not a fault; colouring one side would say otherwise.
class InsightCard extends StatelessWidget {
  const InsightCard({required this.insight, super.key});

  final PersonalInsight insight;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacingSm),
      child: Container(
        padding: EdgeInsets.all(tokens.spacingMd),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _iconFor(insight.kind),
              size: 20,
              color: colorScheme.primary,
            ),
            SizedBox(width: tokens.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    composeInsightSentence(insight),
                    style: textTheme.bodyMedium,
                  ),
                  SizedBox(height: tokens.spacingXs),
                  Text(
                    composeInsightFootnote(insight),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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

  IconData _iconFor(InsightKind kind) {
    return switch (kind) {
      InsightKind.proteinTargetNextDayOutput => Icons.restaurant_outlined,
      InsightKind.sleepScoreSameDayOutput => Icons.bedtime_outlined,
      InsightKind.energyScoreSameDayOutput => Icons.bolt_outlined,
      InsightKind.cyclePhaseExertion ||
      InsightKind.cyclePhaseOutput => Icons.favorite_outline,
      InsightKind.hydrationTargetSameDayOutput => Icons.water_drop_outlined,
    };
  }
}
