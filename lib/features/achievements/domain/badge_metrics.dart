/// Reduces `BadgeInputs` to the scalar quantities the ladders are measured
/// against, and to the set of yes/no facts the one-off badges hang on.
///
/// Pure and deterministic: no clock, no repository, no randomness. Every
/// instant is converted to the user's **local calendar day** before it is
/// bucketed, the same UTC-instant-to-local-day rule used everywhere in this
/// codebase (`core/domain/local_date.dart`).
library;

import 'dart:math' as math;

import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_inputs.dart';
import 'package:menfit_app/features/achievements/domain/weekly_walking_rule.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/progress/domain/weekly_summary.dart'
    show mondayOf;

/// The daily water figure a "well watered" day is counted at.
///
/// Not an invented judgement: this is the same 2,000 ml the hydration card
/// has celebrated since S1-5 (`features/nutrition/presentation/widgets/
/// water_intake_card.dart`). The insights engine refuses to *measure* her
/// against a hydration figure she never chose
/// (`features/insights/domain/evaluators/hydration_output_evaluator.dart`),
/// and that refusal stands — a badge only ever adds a celebration, never a
/// verdict, so counting the days she already gets congratulated for is a
/// different act entirely.
const int badgeWaterTargetMl = 2000;

/// The lowest distance a palindrome badge will look at, in metres — below
/// this the digit strings are too short for the coincidence to be one.
const int palindromeMinimumMetres = 100;

/// Activity types counted as mindful movement, alongside any activity
/// carrying [MindfulWorkoutDetails] whatever its type.
const Set<ActivityType> mindfulActivityTypes = {
  ActivityType.yoga,
  ActivityType.pilates,
};

/// Single-session marks the per-activity-type one-offs fire at.
///
/// Constants rather than literals at the comparison site because the
/// badge copy quotes each of these numbers, and a badge that says 10 km
/// while the code checks 12 km is the one bug in this file a reader cannot
/// see. Every one is a **single session**, never a total: the totals are
/// what the ladders are for.
const double longWalkMetres = 10000;
const double longHikeMetres = 15000;
const double longRideMetres = 25000;
const double longSwimMetres = 1000;

/// Climbing within one session that earns the climb one-off, in metres.
const double bigClimbMetres = 500;

/// Completed rounds within one interval session that earn the rounds
/// one-off. Well clear of the eight-round default a HIIT session is
/// created with, so it marks a session she deliberately made long.
const int longIntervalRounds = 20;

/// How long a single yoga or pilates session runs to earn its hour badge.
const Duration hourLongSession = Duration(hours: 1);

/// The four calendar windows a solstice or equinox falls in.
///
/// Three-day windows rather than fixed dates because the astronomical
/// instants drift across a couple of days with the year and the timezone —
/// pinning a single date would deny the badge to someone who ran on the
/// actual solstice. Deliberately hemisphere-neutral: these are the four
/// days the year pivots on wherever you are, and the badge copy says so
/// rather than naming a season.
const Map<int, Set<int>> seasonalTurnWindows = {
  3: {19, 20, 21},
  6: {20, 21, 22},
  9: {21, 22, 23},
  12: {20, 21, 22},
};

/// Every metric in [BadgeMetric], computed from [inputs].
///
/// Every value is finite and `>= 0` — the engine above relies on that to
/// terminate its walk up an open-ended ladder, and a negative distance from
/// a corrupt row must not become negative progress.
Map<BadgeMetric, double> computeBadgeMetrics(BadgeInputs inputs) {
  final activities = inputs.activities;
  final today = inputs.today;

  var runMetres = 0.0;
  var rideMetres = 0.0;
  var walkMetres = 0.0;
  var hikeMetres = 0.0;
  var swimMetres = 0.0;
  var ascentMetres = 0.0;
  var strengthVolumeKg = 0.0;
  var strengthSessions = 0;
  var hiitSessions = 0;
  var yogaSessions = 0;
  var pilatesSessions = 0;
  var mindfulSeconds = 0;
  var earlyBird = 0;
  var nightOwl = 0;

  for (final activity in activities) {
    if (activity.activityType == ActivityType.run) {
      runMetres += activity.distanceMeters;
    }
    if (activity.activityType == ActivityType.ride) {
      rideMetres += activity.distanceMeters;
    }
    if (activity.activityType == ActivityType.walk) {
      walkMetres += activity.distanceMeters;
    }
    if (activity.activityType == ActivityType.hike) {
      hikeMetres += activity.distanceMeters;
    }
    if (activity.activityType == ActivityType.swim) {
      swimMetres += swimDistanceMetres(activity);
    }
    if (activity.activityType == ActivityType.strength) {
      strengthSessions++;
    }
    if (isIntervalSession(activity)) {
      hiitSessions++;
    }
    if (activity.activityType == ActivityType.yoga) {
      yogaSessions++;
    }
    if (activity.activityType == ActivityType.pilates) {
      pilatesSessions++;
    }
    ascentMetres += ascentOf(activity);

    final details = activity.workoutDetails;
    if (details is StrengthWorkoutDetails) {
      // `completedVolumeKg`, never `totalVolumeKg`: a planned-but-unfinished
      // set is not tonnage she lifted (see `workout_details.dart`).
      strengthVolumeKg += details.completedVolumeKg;
    }
    if (_isMindful(activity)) {
      mindfulSeconds += activity.movingTime.inSeconds;
    }

    final startHour = activity.startedAt.toLocal().hour;
    if (startHour < 7) earlyBird++;
    if (startHour >= 20) nightOwl++;
  }

  final waterDays = inputs.waterTotalsByDay.values
      .where((ml) => ml >= badgeWaterTargetMl)
      .length;

  return {
    BadgeMetric.weeklyWalkingTargetWeeks: countWeeklyWalkingTargetWeeks(
      activities: activities,
      protectedDays: inputs.protectedDays,
      today: today,
    ).toDouble(),
    BadgeMetric.lifetimeSessionCount: activities.length.toDouble(),
    BadgeMetric.lifetimeRunDistanceMetres: _clean(runMetres),
    BadgeMetric.lifetimeRideDistanceMetres: _clean(rideMetres),
    BadgeMetric.lifetimeWalkDistanceMetres: _clean(walkMetres),
    BadgeMetric.lifetimeHikeDistanceMetres: _clean(hikeMetres),
    BadgeMetric.lifetimeSwimDistanceMetres: _clean(swimMetres),
    BadgeMetric.lifetimeAscentMetres: _clean(ascentMetres),
    BadgeMetric.lifetimeStrengthVolumeKg: _clean(strengthVolumeKg),
    BadgeMetric.strengthSessionCount: strengthSessions.toDouble(),
    BadgeMetric.hiitSessionCount: hiitSessions.toDouble(),
    BadgeMetric.yogaSessionCount: yogaSessions.toDouble(),
    BadgeMetric.pilatesSessionCount: pilatesSessions.toDouble(),
    BadgeMetric.checkinDayCount: inputs.checkinDays.length.toDouble(),
    BadgeMetric.waterTargetDayCount: waterDays.toDouble(),
    BadgeMetric.mindfulMinutes: _clean(mindfulSeconds / 60),
    BadgeMetric.cycleLoggingMonths: _cycleLoggingMonths(inputs).toDouble(),
    BadgeMetric.earlyBirdSessionCount: earlyBird.toDouble(),
    BadgeMetric.nightOwlSessionCount: nightOwl.toDouble(),
  };
}

/// The [BadgeCondition]s [inputs] satisfies. Anything absent is simply not
/// earned yet — there is no "failed" state.
Set<BadgeCondition> computeBadgeConditions(BadgeInputs inputs) {
  final satisfied = <BadgeCondition>{};
  final activities = inputs.activities;

  if (activities.isNotEmpty) {
    satisfied.add(BadgeCondition.firstActivityLogged);
  }
  if (inputs.bestEffortDistancesMetres.contains(5000)) {
    satisfied.add(BadgeCondition.firstFiveKilometreEffort);
  }
  if (inputs.cycleRecords.any((record) => record.periodEnd != null)) {
    satisfied.add(BadgeCondition.firstCompletedCycleRecord);
  }
  if (inputs.waterTotalsByDay.values.any((ml) => ml >= badgeWaterTargetMl)) {
    satisfied.add(BadgeCondition.firstWaterTargetDay);
  }
  if (_hasFullCheckinWeek(inputs.checkinDays)) {
    satisfied.add(BadgeCondition.fullCheckinWeek);
  }

  final types = <ActivityType>{};
  final seasons = <int>{};
  for (final activity in activities) {
    types.add(activity.activityType);
    if (activity.activityType == ActivityType.strength) {
      satisfied.add(BadgeCondition.firstStrengthSession);
    }
    if (_isMindful(activity)) {
      satisfied.add(BadgeCondition.firstMindfulSession);
    }

    _addActivityTypeConditions(activity, satisfied);

    final day = LocalDate.fromDateTime(activity.startedAt.toLocal());
    seasons.add(_seasonIndex(day.month));
    if (seasonalTurnWindows[day.month]?.contains(day.day) ?? false) {
      satisfied.add(BadgeCondition.seasonalTurnSession);
    }
    if (_isPalindromeDistance(activity.distanceMeters)) {
      satisfied.add(BadgeCondition.palindromeDistance);
    }
  }
  if (types.length >= 5) satisfied.add(BadgeCondition.fiveMovementKinds);
  if (seasons.length == 4) satisfied.add(BadgeCondition.everySeasonActive);

  return satisfied;
}

/// Clamps a computed quantity to a finite, non-negative double.
double _clean(double value) => value.isFinite ? math.max(0, value) : 0;

bool _isMindful(Activity activity) =>
    mindfulActivityTypes.contains(activity.activityType) ||
    activity.workoutDetails is MindfulWorkoutDetails;

/// Whether [activity] counts as an interval session.
///
/// Type **or** details, the same rule mindful movement already uses: a run
/// logged with interval structure attached to it is an interval session by
/// any reading, and refusing it would make the badge a fact about which
/// button she pressed rather than about what she did.
bool isIntervalSession(Activity activity) =>
    activity.activityType == ActivityType.hiit ||
    activity.workoutDetails is HiitWorkoutDetails;

/// The distance of a swim, in metres.
///
/// The logged distance where there is one — manual entry already stores
/// laps × pool length into it
/// (`features/activity/presentation/manual_entry_controller.dart`), and a
/// watch-recorded swim carries a measured distance with no lap detail at
/// all. The lap fallback is for the third case: details entered but the
/// distance left at zero. Deliberately not a sum of the two, which would
/// double every manually-logged swim.
double swimDistanceMetres(Activity activity) {
  final logged = activity.distanceMeters;
  if (logged.isFinite && logged > 0) return logged;
  final details = activity.workoutDetails;
  if (details is SwimWorkoutDetails) {
    final calculated = details.calculatedDistanceMeters;
    if (calculated.isFinite && calculated > 0) return calculated;
  }
  return 0;
}

/// The climbing recorded on [activity], in metres, or `0`.
///
/// **Absence is a zero here, and only here.** Elevation is written by GPS
/// recording (`features/activity/domain/recording_session.dart`) and by
/// file import, and manual entry has no field for it at all today — so
/// most logged sessions carry `null`, and every one of them must simply
/// contribute nothing rather than break the sum or drop the session. A
/// negative or non-finite stored value is treated the same way: a corrupt
/// row cannot take away climbing she did.
double ascentOf(Activity activity) {
  final climbed = activity.elevationGainMeters;
  if (climbed == null || !climbed.isFinite || climbed <= 0) return 0;
  return climbed;
}

/// The per-activity-type conditions [activity] satisfies, added to
/// [satisfied].
///
/// Split out of [computeBadgeConditions]' loop rather than inlined because
/// there are now four types' worth of them and the loop had one job before
/// this; the behaviour is identical to writing them in place.
void _addActivityTypeConditions(
  Activity activity,
  Set<BadgeCondition> satisfied,
) {
  switch (activity.activityType) {
    case ActivityType.walk:
      satisfied.add(BadgeCondition.firstWalkSession);
      if (activity.distanceMeters >= longWalkMetres) {
        satisfied.add(BadgeCondition.tenKilometreWalk);
      }
    case ActivityType.hike:
      satisfied.add(BadgeCondition.firstHikeSession);
      if (activity.distanceMeters >= longHikeMetres) {
        satisfied.add(BadgeCondition.fifteenKilometreHike);
      }
    case ActivityType.ride:
      satisfied.add(BadgeCondition.firstRideSession);
      if (activity.distanceMeters >= longRideMetres) {
        satisfied.add(BadgeCondition.twentyFiveKilometreRide);
      }
    case ActivityType.swim:
      satisfied.add(BadgeCondition.firstSwimSession);
      if (swimDistanceMetres(activity) >= longSwimMetres) {
        satisfied.add(BadgeCondition.oneKilometreSwim);
      }
    case ActivityType.yoga:
      if (activity.movingTime >= hourLongSession) {
        satisfied.add(BadgeCondition.hourLongYogaSession);
      }
    case ActivityType.pilates:
      if (activity.movingTime >= hourLongSession) {
        satisfied.add(BadgeCondition.hourLongPilatesSession);
      }
    case ActivityType.run:
    case ActivityType.strength:
    case ActivityType.hiit:
    case ActivityType.other:
      break;
  }

  if (isIntervalSession(activity)) {
    satisfied.add(BadgeCondition.firstHiitSession);
    final details = activity.workoutDetails;
    if (details is HiitWorkoutDetails &&
        details.completedRounds >= longIntervalRounds) {
      satisfied.add(BadgeCondition.twentyIntervalRounds);
    }
  }

  if (ascentOf(activity) >= bigClimbMetres) {
    satisfied.add(BadgeCondition.fiveHundredMetreClimb);
  }
}

/// Distinct calendar months in which a period was logged as **starting**.
///
/// Counting the start day rather than every day the period covered is
/// deliberate: an ongoing record with no end date is treated by
/// `features/cycle/domain/period_days.dart` as running up to today, so
/// counting covered days would let one stale un-ended record inflate this
/// by a month for every month it was left open. A start is a thing she
/// actually logged. Future-dated starts are ignored.
int _cycleLoggingMonths(BadgeInputs inputs) {
  final months = <int>{};
  for (final record in inputs.cycleRecords) {
    final start = record.periodStart;
    if (start.isAfter(inputs.today)) continue;
    months.add(start.year * 12 + start.month);
  }
  return months.length;
}

/// Whether any Monday-start week has a check-in on all seven of its days.
bool _hasFullCheckinWeek(Set<LocalDate> checkinDays) {
  final weekStarts = <LocalDate>{
    for (final day in checkinDays) mondayOf(day),
  };
  for (final weekStart in weekStarts) {
    var complete = true;
    for (var offset = 0; offset < 7; offset++) {
      if (!checkinDays.contains(weekStart.addDays(offset))) {
        complete = false;
        break;
      }
    }
    if (complete) return true;
  }
  return false;
}

/// 0 for Dec-Feb, 1 for Mar-May, 2 for Jun-Aug, 3 for Sep-Nov — four equal
/// quarters of the year, never named, so the badge reads the same in either
/// hemisphere.
int _seasonIndex(int month) => (month % 12) ~/ 3;

/// Whether [distanceMeters], rounded to whole metres, reads the same
/// backwards. A trailing zero can never form a palindrome, so round
/// distances like 5,000 m are excluded by the arithmetic rather than by a
/// special case.
bool _isPalindromeDistance(double distanceMeters) {
  if (!distanceMeters.isFinite) return false;
  final metres = distanceMeters.round();
  if (metres < palindromeMinimumMetres) return false;
  final digits = metres.toString();
  for (var i = 0, j = digits.length - 1; i < j; i++, j--) {
    if (digits[i] != digits[j]) return false;
  }
  return true;
}
