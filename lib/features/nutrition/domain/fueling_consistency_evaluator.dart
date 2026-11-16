import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_entry.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:meta/meta.dart';

/// Result of evaluating a user's 7-day fueling and nutrition consistency.
@immutable
class FuelingConsistencyResult {
  const FuelingConsistencyResult({
    required this.daysLoggedCount,
    required this.proteinGoalsMetCount,
    required this.isMilestoneAchieved,
    this.milestoneTitle,
    this.milestoneSubtitle,
    this.badgeLabel,
  });

  /// Total days with nutrition logged out of the 7-day window.
  final int daysLoggedCount;

  /// Total days where the protein goal was successfully reached.
  final int proteinGoalsMetCount;

  /// Whether a motivational consistency milestone was unlocked.
  final bool isMilestoneAchieved;

  /// Celebration title.
  final String? milestoneTitle;

  /// Celebration subtitle.
  final String? milestoneSubtitle;

  /// Badge chip label.
  final String? badgeLabel;
}

/// Pure evaluation service that detects 7-day nutrition and protein consistency
/// achievements without calorie shaming or restrictive moralizing.
class FuelingConsistencyEvaluator {
  const FuelingConsistencyEvaluator();

  /// Evaluates the 7-day window from [today.minusDays(6)] to [today].
  ///
  /// [basisKcal] is the day's resolved energy basis (see
  /// `nutrition/domain/nutrition_goals.dart#macroTargetGramsFor`) — required
  /// to turn a percent-mode protein target into grams. Never read
  /// [goals]'s `proteinTargetGrams` directly: that field is only populated
  /// in gram mode, so a percent-mode goal read that way would never be
  /// achievable. When [basisKcal] is absent (or [goals] has no target at
  /// all), the protein axis of the milestone is simply unreachable for the
  /// window — the honest "no target" answer, not an inflated "target of
  /// zero" that every day would trivially pass.
  FuelingConsistencyResult evaluate({
    required List<NutritionEntry> entries,
    required NutritionGoals? goals,
    required LocalDate today,
    required int? basisKcal,
  }) {
    final windowStart = today.addDays(-6);

    // Group entries by date within the 7-day window
    final entriesByDate = <LocalDate, List<NutritionEntry>>{};
    for (final entry in entries) {
      if (!entry.day.isBefore(windowStart) && !entry.day.isAfter(today)) {
        entriesByDate.putIfAbsent(entry.day, () => []).add(entry);
      }
    }

    var daysLogged = 0;
    var proteinGoalsMet = 0;
    final targetProtein = goals?.macroTargetGramsFor(basisKcal).protein;

    for (var i = 0; i < 7; i++) {
      final day = windowStart.addDays(i);
      final dayEntries = entriesByDate[day];
      if (dayEntries != null && dayEntries.isNotEmpty) {
        final totals = computeDayTotals(dayEntries).total;
        // Day counts as logged if non-zero nutrients logged
        if (totals.caloriesKcal > 0 || totals.proteinGrams > 0) {
          daysLogged++;
        }

        // Protein goal met (within 85% threshold of target). `null` means
        // no target — grams mode with nothing set, or percent mode with no
        // calorie basis to derive from — so it can never be met.
        if (targetProtein != null &&
            targetProtein > 0 &&
            totals.proteinGrams >= (targetProtein * 0.85)) {
          proteinGoalsMet++;
        }
      }
    }

    final isMilestone = proteinGoalsMet >= 4 || daysLogged >= 5;

    if (isMilestone) {
      final title = proteinGoalsMet >= 4
          ? 'Protein & Fueling Champion 🥑💪'
          : 'Consistent Fueling Milestone ✨';
      final subtitle = proteinGoalsMet >= 4
          ? 'You nourished your body and hit your protein target on '
                '$proteinGoalsMet of the last 7 days!'
          : 'Logged your meals on $daysLogged of the last 7 days. '
                'Consistency builds strength!';
      final badge = proteinGoalsMet >= 4
          ? '$proteinGoalsMet/7 Protein'
          : '$daysLogged/7 Fueling';

      return FuelingConsistencyResult(
        daysLoggedCount: daysLogged,
        proteinGoalsMetCount: proteinGoalsMet,
        isMilestoneAchieved: true,
        milestoneTitle: title,
        milestoneSubtitle: subtitle,
        badgeLabel: badge,
      );
    }

    return FuelingConsistencyResult(
      daysLoggedCount: daysLogged,
      proteinGoalsMetCount: proteinGoalsMet,
      isMilestoneAchieved: false,
    );
  }
}
