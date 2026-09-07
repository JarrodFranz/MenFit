import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/progress/domain/weekly_summary.dart'
    show mondayOf;

/// How much walking (walk + hike) makes a week count towards the
/// `weekly_walking_weeks` badge, before any recovery adjustment.
const double weeklyWalkingTargetMetres = 15000;

/// The activity types that count as walking for this badge.
const Set<ActivityType> walkingActivityTypes = {
  ActivityType.walk,
  ActivityType.hike,
};

/// Whether a single Monday-start week counts, given how far they walked in
/// it and how many of its days were protected recovery.
///
/// This is the **cycle-aware fairness rule**, and it is the whole reason
/// this file exists separately from the rest of the metric layer.
///
/// The plain reading of a weekly badge — "walk 15 km every week" — quietly
/// punishes a period week, a flare week, or any week they marked as
/// recovery. The app's protected-recovery design says a rest is never a
/// lapse (`knowledge/product/terminology.md`, `knowledge/domain/mens_health.md`),
/// so the week's ask is **pro-rated to the days that were actually theirs to
/// use**:
///
/// * `activeDays = 7 - protectedDays`
/// * the week counts when `walkedMetres >= target × activeDays / 7`
/// * a week whose every day was protected (`activeDays == 0`) **counts
///   unconditionally** — there were no days to walk on, so there is nothing
///   to fall short of, and that holds with nothing walked at all.
///
/// A five-day period week therefore asks for `15 × 2/7 ≈ 4.3 km`, not 15,
/// and a seven-day one asks for nothing at all. A period week can never
/// void a week of this ladder, which is the binding rule, stated precisely.
///
/// **Protection alone lowers the ask — walking on a protected day never
/// raises it.** [protectedDays] counts every protected day in the week,
/// whether or not they walked on it, and *all* the metres they walked count
/// towards the pro-rated figure wherever in the week they fell. An earlier
/// draft of this rule deducted only protected days they had *not* walked on,
/// which made walking on a flare day strictly worse than resting: one
/// kilometre on a protected day turned an unconditional week into a
/// 2,142.9 m ask. A rule that can punish them for moving on a bad day is
/// exactly the rule protected recovery exists to prevent, so the ask now
/// depends only on how many days were theirs to use.
///
/// The consequence worth stating plainly: adding a walk to a week can only
/// ever help. Nothing they log can un-qualify a week that already counted.
///
/// Comparison is `>=`, so a week landing exactly on the (possibly
/// pro-rated) figure counts.
bool weeklyWalkingWeekQualifies({
  required double walkedMetres,
  required int protectedDays,
  double targetMetres = weeklyWalkingTargetMetres,
}) {
  final activeDays = 7 - protectedDays;
  if (activeDays <= 0) return true;
  return walkedMetres >= targetMetres * activeDays / 7;
}

/// Counts the **completed** Monday-start weeks that satisfy
/// [weeklyWalkingWeekQualifies].
///
/// The week containing [today] is deliberately excluded: an in-progress
/// week is not a week they fell short in, and judging it would make the
/// badge's own progress bar slide backwards every Monday. Weeks need not be
/// consecutive — this is a tally, never a streak, so a quiet month costs
/// nothing already earned.
///
/// Iteration is bounded by the data: it starts at the earliest week holding
/// either a walk or a protected day and stops at the last completed week.
/// With neither, the answer is `0` without looping at all.
int countWeeklyWalkingTargetWeeks({
  required List<Activity> activities,
  required Set<LocalDate> protectedDays,
  required LocalDate today,
  double targetMetres = weeklyWalkingTargetMetres,
}) {
  final lastCompleteWeekStart = mondayOf(today).addDays(-7);

  final metresByWeek = <LocalDate, double>{};
  LocalDate? earliestWeek;

  void noteWeek(LocalDate weekStart) {
    final current = earliestWeek;
    if (current == null || weekStart.isBefore(current)) {
      earliestWeek = weekStart;
    }
  }

  for (final activity in activities) {
    if (!walkingActivityTypes.contains(activity.activityType)) continue;
    final day = LocalDate.fromDateTime(activity.startedAt.toLocal());
    if (day.isAfter(lastCompleteWeekStart.addDays(6))) continue;
    final weekStart = mondayOf(day);
    // Clamped exactly as `badge_metrics.dart#_clean` clamps every lifetime
    // metric: a corrupt row carrying a NaN or a negative distance must not
    // poison a whole week's total (NaN would make every comparison false
    // and silently void the week).
    final metres = activity.distanceMeters;
    final clean = metres.isFinite && metres > 0 ? metres : 0.0;
    metresByWeek.update(
      weekStart,
      (total) => total + clean,
      ifAbsent: () => clean,
    );
    noteWeek(weekStart);
  }

  for (final day in protectedDays) {
    if (day.isAfter(lastCompleteWeekStart.addDays(6))) continue;
    noteWeek(mondayOf(day));
  }

  final start = earliestWeek;
  if (start == null) return 0;

  var count = 0;
  var weekStart = start;
  while (!weekStart.isAfter(lastCompleteWeekStart)) {
    var protectedInWeek = 0;
    for (var offset = 0; offset < 7; offset++) {
      if (protectedDays.contains(weekStart.addDays(offset))) {
        protectedInWeek++;
      }
    }
    if (weeklyWalkingWeekQualifies(
      walkedMetres: metresByWeek[weekStart] ?? 0,
      protectedDays: protectedInWeek,
      targetMetres: targetMetres,
    )) {
      count++;
    }
    weekStart = weekStart.addDays(7);
  }
  return count;
}
