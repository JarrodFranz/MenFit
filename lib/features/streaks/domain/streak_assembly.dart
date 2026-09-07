import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/domain/period_days.dart';
import 'package:menfit_app/features/streaks/domain/streak_engine.dart';

/// Assembles a [StreakResult] from raw source data — the pure "glue"
/// between the repository-shaped inputs (`streaks_providers.dart` watches
/// these as streams) and [computeStreaks]'s day-set inputs.
///
/// Deliberately a pure function taking already-loaded lists/sets rather
/// than reading providers/repositories itself, so it's unit-testable
/// without Riverpod or Drift (`knowledge/engineering/testing_strategy.md`'s
/// pyramid: pure Dart tests are the bulk).
///
/// **Protection assembly (S1-2, `knowledge/product/stage1_audit.md`'s
/// `DayStatus` evolution):** `protectedDays` — the set [computeStreaks]
/// treats as protected recovery — is the union of three independent,
/// voluntary sources, none of which require the others:
///
/// a) **Explicit recovery days** ([recoveryDays]) — the user directly
///    marking a day as recovery (streak card action, or the wellbeing
///    check-in flow's recovery prompt). Always protects, regardless of the
///    period-pausing toggle below — it's a separate voluntary act.
/// b) **Flare impact** ([flareProtectedDays]) — any day with a logged flare
///    whose impact is `unableToTrain` protects. This is the user's own
///    explicit statement ("I couldn't train") — no proof demanded, and
///    deliberately narrower than a `reducedTraining` impact: reduced
///    training is still training, so it does *not* auto-protect (a flare
///    severe enough to fully stop training is a materially different claim
///    than one that just made a session harder). The impact filtering
///    itself already happened upstream — see
///    `wellbeing/domain/wellbeing_repository.dart#watchProtectingFlareDays`'s
///    dartdoc — so this function only ever sees days that already qualify,
///    and (F1) that source is deliberately unwindowed: a flare logged a
///    year ago still protects its day today, unlike this function's other
///    two sources, which are bounded by [today]/`earliest` only because
///    their own upstream queries already are.
/// c) **Logged period days** ([records]), but only when [pausingEnabled] is
///    true — unchanged mechanics from the pre-S1-2 engine
///    (`domain/period_days.dart`'s ongoing-period-capped-at-today range),
///    now folded into the same union rather than being the only protection
///    source. See `features/cycle/data/drift_cycle_repository.dart`'s
///    dartdoc for the S1-2 default-flip ruling on this toggle (opt-in,
///    now off by default for new users).
///
/// Cross-feature note (ADR 007): this lives in `streaks/domain/`, which is
/// allowed to import `activity/domain/` and `cycle/domain/` directly per
/// `architecture_overview.md` rule 2 (any feature may depend on another
/// feature's `domain/`) — only `streaks_providers.dart` needs to reach
/// those features' repositories, and it does so exclusively through their
/// `<name>_providers.dart` composition surfaces, never their `data/`.
/// [flareProtectedDays] is already pre-filtered by impact upstream (see its
/// own doc above), so this function has no need to import
/// `wellbeing/domain/` at all for a full flare-event-shaped parameter.
StreakResult assembleStreakResult({
  required List<Activity> activities,
  required Set<LocalDate> recoveryDays,
  required Set<LocalDate> flareProtectedDays,
  required List<CycleRecord> records,
  required bool pausingEnabled,
  required LocalDate today,
}) {
  // Instant -> user-local calendar day: convert the UTC-stored instant to
  // local time first, then read its date fields (see
  // `core/domain/local_date.dart`'s `fromDateTime` doc and
  // `data_architecture.md`'s calendar-day semantics section).
  final activeDays = activities
      .map((activity) => LocalDate.fromDateTime(activity.startedAt.toLocal()))
      .toSet();

  // Fast path: nothing from any source has ever been logged - there is
  // nothing to compute a streak from.
  if (activeDays.isEmpty &&
      recoveryDays.isEmpty &&
      flareProtectedDays.isEmpty &&
      records.isEmpty) {
    return const StreakResult(
      currentStreak: 0,
      longestStreak: 0,
      todayStatus: DayStatus.unscheduled,
      todaySatisfied: false,
    );
  }

  return computeStreaks(
    activeDays: activeDays,
    protectedDays: assembleProtectedDays(
      recoveryDays: recoveryDays,
      flareProtectedDays: flareProtectedDays,
      records: records,
      pausingEnabled: pausingEnabled,
      today: today,
    ),
    today: today,
  );
}

/// The union of every protection source for the days up to [today] — the
/// set [assembleStreakResult] hands [computeStreaks] as its
/// `protectedDays`, extracted so it is reachable on its own.
///
/// **This is the single decision source for "is this day protected".** It
/// was extracted from [assembleStreakResult] when the achievements feature
/// needed the same answer for its cycle-aware consistency ladder
/// (`features/achievements/domain/weekly_walking_rule.dart`): two
/// implementations of "protected" would eventually disagree, and the day
/// they did, a period week would start voiding a consistency week — the
/// exact outcome protected recovery exists to prevent. Anything that needs
/// the set calls this (or `streaks_providers.dart`'s `protectedDays`
/// provider, which watches the sources and feeds it); nothing re-derives
/// it.
///
/// The three sources, and why each is what it is, are documented on
/// [assembleStreakResult] above — this function is the same union, with no
/// behaviour of its own beyond it.
///
/// The lower bound handed to [periodDaysInRange] is the earliest day any
/// source mentions, or [today] when they mention none. It does not consider
/// activities, unlike [assembleStreakResult]'s own earliest-day walk, and
/// does not need to: period days can only exist from the earliest
/// [CycleRecord.periodStart] onwards, and that start is already in the
/// minimum. A bound earlier than that would widen the range without
/// admitting a single extra day.
Set<LocalDate> assembleProtectedDays({
  required Set<LocalDate> recoveryDays,
  required Set<LocalDate> flareProtectedDays,
  required List<CycleRecord> records,
  required bool pausingEnabled,
  required LocalDate today,
}) {
  if (!pausingEnabled || records.isEmpty) {
    return <LocalDate>{...recoveryDays, ...flareProtectedDays};
  }

  var earliest = today;
  for (final day in recoveryDays) {
    if (day.isBefore(earliest)) earliest = day;
  }
  for (final day in flareProtectedDays) {
    if (day.isBefore(earliest)) earliest = day;
  }
  for (final record in records) {
    if (record.periodStart.isBefore(earliest)) earliest = record.periodStart;
  }

  return <LocalDate>{
    ...recoveryDays,
    ...flareProtectedDays,
    ...periodDaysInRange(earliest, today, records, today),
  };
}
