import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';

part 'streak_engine.freezed.dart';

/// Per-day streak state (`knowledge/product/terminology.md`'s "DayStatus"
/// entry, 2026-08-27 spec).
///
/// Only the three statuses this engine can actually produce today are
/// modelled here. `completedPlannedWorkout`, `plannedRecovery`, and
/// `missedPlannedWorkout` are spec'd but activate only once Stage 2 plans
/// exist (a "planned workout" concept the app doesn't have yet) — adding
/// them now would be speculative cases [computeStreaks] could never
/// produce, so they're deliberately deferred rather than added as
/// dead/unreachable enum members.
enum DayStatus {
  /// The day has at least one logged activity.
  completedActivity,

  /// The day is protected recovery — bridges the streak without counting
  /// against it. Never "excused/failed/skipped"
  /// (`knowledge/product/terminology.md`).
  protectedRecovery,

  /// Neither of the above — for a past day, this is a genuine gap; for
  /// [computeStreaks]'s `today` argument specifically, it means "still
  /// pending" (see rule 3 below).
  unscheduled,
}

/// The result of evaluating a user's engagement streak against their
/// logged activity days and their protected-recovery days.
@freezed
abstract class StreakResult with _$StreakResult {
  const factory StreakResult({
    required int currentStreak,
    required int longestStreak,
    required DayStatus todayStatus,
    required bool todaySatisfied,
  }) = _StreakResult;

  const StreakResult._();

  /// Whether today is protected recovery — a thin, readable alias over
  /// `todayStatus == DayStatus.protectedRecovery` for callers (mainly
  /// presentation code) that only care about the yes/no question, not the
  /// full status.
  bool get isProtectedToday => todayStatus == DayStatus.protectedRecovery;
}

/// Which of the day-state sets a given day falls into — the engine's
/// internal three-way classification that [DayStatus] is derived from for
/// [StreakResult.todayStatus].
enum _DayState {
  /// The day has at least one activity — always wins over
  /// [_DayState.protected] (rule 2).
  satisfied,

  /// The day is protected recovery and not [_DayState.satisfied].
  protected,

  /// Neither of the above.
  empty,
}

_DayState _stateOf(
  LocalDate day,
  Set<LocalDate> activeDays,
  Set<LocalDate> protectedDays,
) {
  if (activeDays.contains(day)) return _DayState.satisfied;
  if (protectedDays.contains(day)) return _DayState.protected;
  return _DayState.empty;
}

/// Computes a user's streak from the set of days that satisfy it
/// ([activeDays]) and the set of days that are protected recovery
/// ([protectedDays]), as of [today].
///
/// This is the entire product decision for "protected recovery" streaks
/// (the named, signature feature — see `knowledge/product/product_vision.md`
/// and `knowledge/domain/mens_health.md`), implemented precisely as
/// specified:
///
/// 1. A day is **satisfied** if it's in [activeDays] (the caller has
///    already reduced "≥1 activity that day" down to a set of days before
///    calling this — see `domain/streak_assembly.dart`).
/// 2. A day is **protected** if it's in [protectedDays] AND NOT satisfied.
///    **Satisfied takes precedence** — working out on a day you've also
///    marked as recovery (or that's otherwise protected) still extends
///    your streak; it is never "wasted" by also being protected. This is
///    why [_stateOf] checks [_DayState.satisfied] first.
/// 3. **Current streak** walks backward from [today]:
///    - [today] itself: satisfied → counts and the walk continues;
///      protected → skipped (neither counts nor breaks) and the walk
///      continues; neither → [today] is still *pending* (the user may yet
///      work out today), so it's skipped **without breaking** the walk.
///    - Every earlier day: satisfied → counts and continues; protected →
///      skipped and continues (protected days *bridge* the streak across a
///      recovery stretch); the first earlier day that is neither satisfied
///      nor protected **breaks** the walk. `currentStreak` is the count of
///      satisfied days seen before the break (or before the days run out).
/// 4. **Longest streak** walks forward across the *entire* relevant
///    history — from the earliest day appearing in either [activeDays] or
///    [protectedDays] up to and including [today] — tracking the longest
///    run of satisfied days, where protected days bridge a run (leave it
///    unchanged) and any other empty day resets the run to zero. [today]
///    gets the same "pending, does not reset" treatment as in rule 3, so
///    `longestStreak` is never smaller than `currentStreak` purely because
///    the user hasn't logged anything *yet today*. Both sets empty → `0`.
/// 5. [StreakResult.todayStatus] reflects [today]'s [_DayState] directly:
///    satisfied → [DayStatus.completedActivity]; protected →
///    [DayStatus.protectedRecovery]; empty → [DayStatus.unscheduled]. Note
///    [DayStatus.protectedRecovery] is only ever produced when the caller
///    actually populated [protectedDays] for today —
///    `domain/streak_assembly.dart` assembles that set from every
///    protection source (explicit recovery days and flare impact), so
///    "today is protected" falls out of this precondition rather than
///    needing a separate flag here.
///    [StreakResult.todaySatisfied] is true iff [today] is in
///    [activeDays].
/// 6. Retroactivity needs no special handling: this is a pure recompute
///    over whatever [activeDays]/[protectedDays] the caller currently has —
///    logging a flare or recovery day after the fact just changes the
///    input sets on the next call.
StreakResult computeStreaks({
  required Set<LocalDate> activeDays,
  required Set<LocalDate> protectedDays,
  required LocalDate today,
}) {
  return StreakResult(
    currentStreak: _currentStreak(activeDays, protectedDays, today),
    longestStreak: _longestStreak(activeDays, protectedDays, today),
    todayStatus: _dayStatusOf(_stateOf(today, activeDays, protectedDays)),
    todaySatisfied: activeDays.contains(today),
  );
}

DayStatus _dayStatusOf(_DayState state) {
  return switch (state) {
    _DayState.satisfied => DayStatus.completedActivity,
    _DayState.protected => DayStatus.protectedRecovery,
    _DayState.empty => DayStatus.unscheduled,
  };
}

int _currentStreak(
  Set<LocalDate> activeDays,
  Set<LocalDate> protectedDays,
  LocalDate today,
) {
  var current = 0;
  var cursor = today;
  var isToday = true;

  while (true) {
    switch (_stateOf(cursor, activeDays, protectedDays)) {
      case _DayState.satisfied:
        current++;
      case _DayState.protected:
        // Bridges the streak — neither counts nor breaks.
        break;
      case _DayState.empty:
        if (isToday) {
          // Today is still pending — skip without breaking (rule 3).
        } else {
          return current;
        }
    }
    isToday = false;
    cursor = cursor.addDays(-1);
  }
}

int _longestStreak(
  Set<LocalDate> activeDays,
  Set<LocalDate> protectedDays,
  LocalDate today,
) {
  if (activeDays.isEmpty && protectedDays.isEmpty) return 0;

  var earliest = today;
  for (final day in activeDays) {
    if (day.isBefore(earliest)) earliest = day;
  }
  for (final day in protectedDays) {
    if (day.isBefore(earliest)) earliest = day;
  }

  var run = 0;
  var longest = 0;
  var cursor = earliest;
  while (!cursor.isAfter(today)) {
    final isToday = cursor == today;
    switch (_stateOf(cursor, activeDays, protectedDays)) {
      case _DayState.satisfied:
        run++;
        if (run > longest) longest = run;
      case _DayState.protected:
        // Bridges the run — leaves it unchanged.
        break;
      case _DayState.empty:
        if (!isToday) run = 0;
    }
    cursor = cursor.addDays(1);
  }
  return longest;
}
