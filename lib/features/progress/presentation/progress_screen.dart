import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_controller.dart';
import 'package:menfit_app/features/achievements/achievements_widgets.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/challenges/challenges_widgets.dart';
import 'package:menfit_app/features/insights/insights_widgets.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/progress/domain/progress_period.dart';
import 'package:menfit_app/features/progress/presentation/progress_overview_controller.dart';
import 'package:menfit_app/features/progress/presentation/widgets/personal_records_section.dart';
import 'package:menfit_app/features/progress/presentation/widgets/progress_activity_card.dart';
import 'package:menfit_app/features/progress/presentation/widgets/progress_nutrition_card.dart';
import 'package:menfit_app/features/progress/presentation/widgets/progress_placeholders_card.dart';
import 'package:menfit_app/features/progress/presentation/widgets/progress_wellbeing_card.dart';
import 'package:menfit_app/features/progress/progress_providers.dart';
import 'package:menfit_app/features/recaps/recaps_widgets.dart';
import 'package:menfit_app/features/streaks/domain/streak_engine.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/weight/weight_widgets.dart';

/// Unified multi-domain Progress & Health Dashboard. Reached at
/// `/home/progress`.
///
/// Combines:
/// - Nutrition: Calorie totals & daily averages, macro breakdown, and logging
///   consistency.
/// - Activity & Exercise: Distance, moving time, workout counts, weekly trends.
/// - Wellbeing & Streaks: Streak consistency, check-in frequency, flare counts.
/// - Weight & Steps: Slots ready for Waves 2 & 4.
/// - Personal Records: Best times and distances.
///
/// Supports **Day**, **Week**, and **Month** views.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    final overviewState = ref.watch(progressOverviewControllerProvider);
    final period = overviewState.period;
    final anchor = overviewState.anchor;
    final range = period.rangeFor(anchor);
    final today = LocalDate.today();

    final unitSystem =
        ref.watch(activityUnitSystemProvider).value ?? UnitSystem.metric;
    final summariesAsync = ref.watch(weeklySummariesProvider);
    final recordsAsync = ref.watch(personalRecordsProvider);
    final activitiesAsync = ref.watch(progressActivitiesProvider);
    final nutritionTotalsAsync = ref.watch(
      rangeNutritionTotalsProvider(start: range.start, end: range.end),
    );
    final nutritionGoals = ref.watch(nutritionGoalsProvider).value;
    final target = ref.watch(dayCalorieTargetProvider);
    final streakResult =
        ref.watch(streakResultProvider).value ??
        const StreakResult(
          currentStreak: 0,
          longestStreak: 0,
          todayStatus: DayStatus.unscheduled,
          todaySatisfied: false,
        );

    final checkinsAsync = ref.watch(
      progressRecentCheckinsProvider(days: 60, today: today),
    );
    final flaresAsync = ref.watch(
      progressRecentFlaresProvider(days: 60, today: today),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: SafeArea(
        // Pinned to the top: a Center around a shrink-wrapping scroll view
        // floats short content mid-screen (seen on device 2026-09-02).
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Segmented Selector (Day | Week | Month)
                  Center(
                    child: SegmentedButton<ProgressPeriod>(
                      segments: [
                        for (final p in ProgressPeriod.values)
                          ButtonSegment(
                            value: p,
                            label: Text(p.label),
                          ),
                      ],
                      selected: {period},
                      onSelectionChanged: (selected) {
                        ref
                            .read(progressOverviewControllerProvider.notifier)
                            .selectPeriod(selected.first);
                      },
                    ),
                  ),
                  SizedBox(height: tokens.spacingSm),

                  // Range Switcher (< Date Title >)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        tooltip: 'Previous ${period.label.toLowerCase()}',
                        onPressed: () {
                          ref
                              .read(progressOverviewControllerProvider.notifier)
                              .previous();
                        },
                      ),
                      Text(
                        period.formatRange(anchor, today),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        tooltip: 'Next ${period.label.toLowerCase()}',
                        onPressed: period.canGoForward(anchor, today)
                            ? () {
                                ref
                                    .read(
                                      progressOverviewControllerProvider
                                          .notifier,
                                    )
                                    .next();
                              }
                            : null,
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spacingMd),

                  // Nutrition Card
                  nutritionTotalsAsync.when(
                    data: (totals) => ProgressNutritionCard(
                      totals: totals,
                      target: target,
                      goals: nutritionGoals,
                      hideCalorieNumbers:
                          nutritionGoals?.hideCalorieNumbers ?? false,
                      period: period,
                    ),
                    loading: () => const _SkeletonBox(height: 180),
                    error: (e, _) => _SectionError(message: userMessageFor(e)),
                  ),
                  SizedBox(height: tokens.spacingMd),

                  // Activity & Exercise Card
                  activitiesAsync.when(
                    data: (activities) => summariesAsync.when(
                      data: (summaries) => ProgressActivityCard(
                        activities: activities,
                        weeklySummaries: summaries,
                        unitSystem: unitSystem,
                        period: period,
                        anchor: anchor,
                        enhancedSemantics: ref
                            .watch(accessibilityControllerProvider)
                            .enhancedSemantics,
                      ),
                      loading: () => const _SkeletonBox(height: 180),
                      error: (e, _) =>
                          _SectionError(message: userMessageFor(e)),
                    ),
                    loading: () => const _SkeletonBox(height: 180),
                    error: (e, _) => _SectionError(message: userMessageFor(e)),
                  ),
                  SizedBox(height: tokens.spacingMd),

                  // Wellbeing & Streaks Card
                  ProgressWellbeingCard(
                    streak: streakResult,
                    checkins: checkinsAsync.value ?? const [],
                    flares: flaresAsync.value ?? const [],
                    period: period,
                    anchor: anchor,
                  ),
                  SizedBox(height: tokens.spacingMd),

                  // Steps Future Integration Card
                  ProgressFutureIntegrationCards(anchor: anchor),
                  SizedBox(height: tokens.spacingMd),

                  // Weight trend + cycle overlay (Task 2.2). Entry point
                  // to the full weight history at `/weight`.
                  const WeightProgressSection(),
                  SizedBox(height: tokens.spacingMd),

                  // "What your data shows" cross-domain discoveries
                  // (Task 1.4) - renders nothing, spacing included, until
                  // the engine finds a pattern that clears its gates.
                  const InsightDiscoverySection(),

                  // "Your Cycle in Motion" recap history (Task 1.3) - only
                  // renders once there's at least one completed period to
                  // revisit.
                  const RecapHistorySection(),
                  SizedBox(height: tokens.spacingMd),

                  // "My Achievements" trophy case (Task 1.8) - entry point
                  // to the full badge catalogue at `/achievements`. Sits
                  // beside Personal records: both are lifetime
                  // celebrations, and neither answers to the Day/Week/Month
                  // selector above.
                  const AchievementsProgressSection(),
                  SizedBox(height: tokens.spacingMd),

                  // Buddy challenges (Task 1.7) - entry point to
                  // `/challenges`. Sits beside Achievements for the same
                  // reason Achievements sits beside Personal records: a
                  // challenge runs over its own calendar window and does
                  // not answer to the Day/Week/Month selector above.
                  const ChallengesProgressSection(),
                  SizedBox(height: tokens.spacingLg),

                  // Personal Records
                  Text('Personal records', style: textTheme.titleMedium),
                  SizedBox(height: tokens.spacingSm),
                  recordsAsync.when(
                    data: (records) => PersonalRecordsSection(
                      records: records,
                      unitSystem: unitSystem,
                    ),
                    loading: () => const _RecordsSkeleton(),
                    error: (error, stackTrace) =>
                        _SectionError(message: userMessageFor(error)),
                  ),
                  SizedBox(height: tokens.spacingLg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({this.height = 48});

  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
    );
  }
}

class _RecordsSkeleton extends StatelessWidget {
  const _RecordsSkeleton();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      children: [
        const _SkeletonBox(height: 56),
        SizedBox(height: tokens.spacingSm),
        const _SkeletonBox(height: 56),
        SizedBox(height: tokens.spacingSm),
        const _SkeletonBox(height: 56),
      ],
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Theme.of(context).extension<AppTokens>()!.spacingMd,
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
