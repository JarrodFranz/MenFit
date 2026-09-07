import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/insights/domain/insight_thresholds.dart';
import 'package:menfit_app/features/insights/insights_providers.dart';
import 'package:menfit_app/features/insights/presentation/widgets/insight_card.dart';

/// "What your data shows" — the discovery surface for
/// `domain/insight_engine.dart`'s findings (Task 1.4).
///
/// ## Renders nothing when there is nothing
///
/// No insights, still loading, or an error: the widget occupies zero
/// space, including its own spacing. Deliberately **no** placeholder card
/// and **no** "keep logging to unlock this!" prompt — an empty state here
/// would turn a discovery into a chore and would nag a user for data about
/// her own body she may have chosen not to log. Most users will see
/// nothing here most of the time, and that is the designed outcome, not a
/// gap to fill.
///
/// Because the widget owns its own bottom spacing, callers place it in a
/// column **without** a trailing `SizedBox` — otherwise an empty state
/// would leave a visible gap where the section isn't.
///
/// [maxInsights] caps what is shown below the engine's own cap
/// (`InsightThresholds.maxSimultaneousInsights`); Home passes 1, Progress
/// takes the default. It can only ever narrow the list, never widen it.
class InsightDiscoverySection extends ConsumerWidget {
  const InsightDiscoverySection({
    this.maxInsights = InsightThresholds.maxSimultaneousInsights,
    super.key,
  });

  final int maxInsights;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(personalInsightsProvider);
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final insights = insightsAsync.value ?? const [];
    if (insights.isEmpty) return const SizedBox.shrink();

    final shown = insights.take(maxInsights).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacingMd),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'What your data shows',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.insights_outlined,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
              SizedBox(height: tokens.spacingSm),
              for (final insight in shown)
                InsightCard(
                  key: ValueKey(insight.kind),
                  insight: insight,
                ),
              // Says what these are and, just as importantly, what they
              // are not (`knowledge/domain/womens_health.md` rules 1 and
              // 3) - cycle-phase findings can surface here.
              Text(
                'Patterns in your own logs. Descriptive only — '
                'not medical advice.',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
