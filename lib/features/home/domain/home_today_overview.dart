/// The "Today" summary the home dashboard closes with: three plain facts
/// about the current day, folded out of what other features already own.
///
/// Pure Dart, no Flutter, no clock - the caller passes `today` so the
/// rollover is testable.
///
/// **Deliberately says nothing about why today is protected.** The
/// recovery banner above this card is explicitly reason-silent
/// (`features/home/presentation/widgets/streak_card.dart`'s S1-2 ruling:
/// protection is multi-source, and naming the source on an always-visible
/// surface both implies a reason on sight and leaks it to anyone glancing
/// at the screen). Naming a source label here would undo that ruling on the
/// same screen it was made for, so `isRecoveryDay` counts **explicit
/// recovery days only** - never a flare.
library;

import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';

/// What the "Today" card states.
class HomeTodayOverview {
  const HomeTodayOverview({
    required this.checkinLogged,
    required this.isRecoveryDay,
    required this.workoutsToday,
  });

  /// Whether a check-in with anything in it exists for today. An empty
  /// check-in row counts as not logged - [DailyCheckin.isEmpty] is the same
  /// test the check-in prompt uses to decide whether to keep asking.
  final bool checkinLogged;

  /// Whether the user has marked today an explicit recovery day. See this
  /// library's dartdoc for why nothing else counts.
  final bool isRecoveryDay;

  /// How many activities started today, in the user's local calendar day.
  final int workoutsToday;
}

/// Folds today's check-in, recovery mark and activity list into the three
/// facts the card shows.
///
/// [activities] may be the whole history; only today's are counted. An
/// activity's UTC [Activity.startedAt] is converted with `.toLocal()` before
/// the day comparison - the same UTC-instant-to-local-day rule the rest of
/// the app uses (`core/domain/local_date.dart`), so an evening run doesn't
/// land on tomorrow for users east of UTC.
HomeTodayOverview buildHomeTodayOverview({
  required LocalDate today,
  required List<Activity> activities,
  required DailyCheckin? checkin,
  required Iterable<RecoveryDayEntry> recoveryDays,
}) {
  var workoutsToday = 0;
  for (final activity in activities) {
    if (LocalDate.fromDateTime(activity.startedAt.toLocal()) == today) {
      workoutsToday++;
    }
  }

  return HomeTodayOverview(
    checkinLogged: checkin != null && !checkin.isEmpty,
    isRecoveryDay: recoveryDays.any((entry) => entry.day == today),
    workoutsToday: workoutsToday,
  );
}
