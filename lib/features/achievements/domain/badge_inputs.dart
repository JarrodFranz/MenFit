import 'package:freezed_annotation/freezed_annotation.dart' show immutable;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

/// How many days of history the achievement engine is fed from the
/// repositories that only offer a *windowed* read (check-ins, water
/// totals).
///
/// Ten years, which is not a real limit so much as the absence of one: it
/// is longer than any install this app can plausibly have, and the tables
/// behind those reads are day-keyed and small. Activities are read
/// genuinely unwindowed (its repository offers it), so the only thing this
/// constant bounds is how far back a check-in or a water day can count
/// towards a lifetime badge. If an install ever outlives it, the fix is an
/// unwindowed one-shot read on that repository, not a bigger number here.
const int badgeHistoryWindowDays = 3660;

/// Everything the badge engine reads, pre-fetched.
///
/// Pure data: the engine and the metric layer below it never touch a
/// repository, a clock, or a provider — `achievements_providers.dart`
/// assembles this from the owning features' composition surfaces (ADR 007)
/// and hands it over. That is what makes the whole evaluation deterministic
/// and testable against hand-written fixtures, the same seam
/// `features/insights/application/insight_observation_mapper.dart` uses.
///
/// [today] is injected rather than read from the system clock for the same
/// reason: a test that cannot pin "today" cannot pin a weekly boundary, a
/// season, or an early-morning hour.
///
/// ## Absence is not a zero
///
/// [waterTotalsByDay] omits days with nothing logged rather than carrying a
/// manufactured `0` (see
/// `features/nutrition/domain/water_repository.dart#getWaterTotalsForRange`),
/// and [checkinDays] holds only days that actually have a check-in. The
/// engine counts what is there and never infers anything from what is not.
///
/// S2/S3 data throughout (`knowledge/engineering/security_and_privacy.md`):
/// nothing here — protected days especially — is ever logged or sent to
/// analytics, and no badge string derived from it names a date.
@immutable
class BadgeInputs {
  const BadgeInputs({
    required this.today,
    this.activities = const [],
    this.bestEffortDistancesMetres = const {},
    this.checkinDays = const {},
    this.waterTotalsByDay = const {},
    this.protectedDays = const {},
  });

  /// The user's local calendar day the evaluation is made against.
  final LocalDate today;

  /// Every logged activity, unwindowed, in any order.
  final List<Activity> activities;

  /// The standard effort distances (metres) for which a best effort has
  /// been recorded — from `activity`'s `personalRecordsProvider`, so the
  /// sample-scanning stays in the feature that owns it.
  final Set<double> bestEffortDistancesMetres;

  /// Days with a logged wellbeing check-in.
  final Set<LocalDate> checkinDays;

  /// Total logged millilitres per day. Days with nothing logged are absent,
  /// never present as `0`.
  final Map<LocalDate, int> waterTotalsByDay;

  /// The days the streak engine considers protected recovery — the union
  /// of explicit recovery days, protecting flares, and (when the user has
  /// opted in) logged period days.
  ///
  /// **Taken from `streaks`' own decision source**, not recomputed here:
  /// `features/streaks/domain/streak_assembly.dart#assembleProtectedDays`
  /// is the single function that decides what "protected" means, and both
  /// the streak card and this engine read it. A second implementation
  /// would eventually disagree with the first, and the day it did, a
  /// period week would start voiding a consistency week — the exact
  /// outcome the protected-recovery design exists to prevent.
  final Set<LocalDate> protectedDays;
}
