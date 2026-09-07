import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';

/// The outcome of [evaluateRecapDue].
sealed class RecapTriggerDecision {
  const RecapTriggerDecision();
}

/// A completed calendar month hasn't had its recap shown yet.
class MonthEndDue extends RecapTriggerDecision {
  const MonthEndDue(this.period);

  final RecapPeriod period;
}

/// Nothing is due right now.
class NothingDue extends RecapTriggerDecision {
  const NothingDue();
}

/// Decides whether a monthly recap (Task 1.3, `TASKS_TO_DO.md`) is due,
/// given [today] and the identity ([RecapPeriod.key]) of the last
/// month-end recap already shown.
///
/// This only decides *which period* is next in line; whether that period
/// actually has enough logged to recap
/// (`RecapBuilder.minSessionsForMonthRecap`) is a separate, later check the
/// caller (`presentation/recap_trigger_controller.dart`) makes by building
/// the recap and finding it `null`.
///
/// Pure and synchronous — no clock read beyond the given [today], no
/// SharedPreferences access. The caller owns fetching [lastShownMonthKey]
/// and persisting a new marker once it actually presents a recap.
RecapTriggerDecision evaluateRecapDue({
  required LocalDate today,
  required String? lastShownMonthKey,
}) {
  final completedMonth = mostRecentCompletedMonth(today);
  if (completedMonth.key != lastShownMonthKey) {
    return MonthEndDue(completedMonth);
  }

  return const NothingDue();
}
