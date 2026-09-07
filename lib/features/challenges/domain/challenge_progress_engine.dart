import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_progress.dart';

/// Computes the user's own standing in [challenge] from her activity log
/// and her protected days.
///
/// Pure: no clock, no repositories, no providers — the caller hands over
/// already-loaded lists (`challenges_providers.dart#selfProgress` does the
/// fetching), so this is unit-testable in plain Dart
/// (`knowledge/engineering/testing_strategy.md`).
///
/// ## The fairness rule, stated precisely
///
/// The challenge's nominal target is what it asks of a person with no
/// protected days. Each participant's *personal* target is that figure
/// pro-rated to the days that were actually hers to use:
///
/// * `activeDays = windowDays - protectedDaysInWindow`
/// * `adjustedTarget = nominalTarget × activeDays / windowDays`
/// * a window every day of which was protected (`activeDays == 0`) asks
///   for **nothing**, and reads as 100% with nothing logged at all —
///   there were no days to train on, so there is nothing to fall short of.
///
/// This is the same pro-ration, and the same philosophy, as the weekly
/// walking ladder (`features/achievements/domain/weekly_walking_rule.dart`),
/// and it inherits that rule's hard-won correction verbatim:
///
/// * **Protection only ever lowers the ask.** Every protected day in the
///   window is deducted, whether or not she also trained on it.
/// * **Training on a protected day only ever helps.** All of her activity
///   inside the window counts, wherever in the window it fell —
///   including on protected days. An earlier draft of the walking rule
///   deducted only protected days she had *not* trained on, which made
///   moving on a flare day strictly worse than resting. That was an error
///   and it is not repeated here.
///
/// The consequence worth stating plainly, and pinned by a monotonicity
/// test: **adding an activity can never lower her percentage, and marking
/// a day protected can never raise her target.**
///
/// ## Why each side is pro-rated privately
///
/// Both participants compute their own adjusted target from their own
/// protected days, on their own device, and neither ever learns the
/// other's. What crosses the gap is one percentage measured against a
/// target only its owner knows — which is precisely why the percentage
/// cannot be run backwards into "how many days did she rest".
/// `challenge_codes.dart` holds the full invariant.
///
/// [protectedDays] must come from `streaks`' single decision source
/// (`features/streaks/domain/streak_assembly.dart#assembleProtectedDays`,
/// exposed as `protectedDaysProvider`) — never a re-derivation. Days
/// outside the window are ignored here, so the caller may pass the whole
/// set.
ChallengeSelfProgress computeSelfProgress({
  required ChallengeBlueprint challenge,
  required List<Activity> activities,
  required Set<LocalDate> protectedDays,
}) {
  final windowDays = challenge.windowDays;

  var protectedInWindow = 0;
  for (final day in protectedDays) {
    if (challenge.containsDay(day)) protectedInWindow++;
  }

  var rawValue = 0.0;
  for (final activity in activities) {
    final day = LocalDate.fromDateTime(activity.startedAt.toLocal());
    if (!challenge.containsDay(day)) continue;
    if (!challenge.countsType(activity.activityType)) continue;
    switch (challenge.kind) {
      case ChallengeKind.totalDistance:
        // Clamped exactly as `badge_metrics.dart` clamps every lifetime
        // metric: one corrupt row carrying a NaN must not poison the
        // total (NaN makes every later comparison false, which would
        // silently read as "no progress at all").
        final metres = activity.distanceMeters;
        if (metres.isFinite && metres > 0) rawValue += metres;
      case ChallengeKind.sessionCount:
        rawValue += 1;
    }
  }

  final nominalTarget = challenge.target;
  final activeDays = windowDays - protectedInWindow;
  final adjustedTarget = activeDays <= 0
      ? 0.0
      : nominalTarget * activeDays / windowDays;

  // A zero ask is met by definition - see the fairness rule above. This
  // is the only branch that can report 100% with nothing logged, and it
  // is the branch where nothing *could* have been logged.
  final percent = adjustedTarget <= 0 ? 100.0 : rawValue / adjustedTarget * 100;

  return ChallengeSelfProgress(
    rawValue: rawValue,
    nominalTarget: nominalTarget,
    adjustedTarget: adjustedTarget,
    protectedDaysInWindow: protectedInWindow,
    windowDays: windowDays,
    percent: percent,
  );
}
