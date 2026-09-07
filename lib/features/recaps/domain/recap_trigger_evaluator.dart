import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';

/// The outcome of [evaluateRecapDue]: at most one recap is ever due at a
/// time (see [evaluateRecapDue]'s precedence rule).
sealed class RecapDue {
  const RecapDue();
}

/// A completed menstrual cycle hasn't had its recap shown yet.
class CycleEndDue extends RecapDue {
  const CycleEndDue(this.period);

  final RecapPeriod period;
}

/// A completed calendar month hasn't had its recap shown yet.
class MonthEndDue extends RecapDue {
  const MonthEndDue(this.period);

  final RecapPeriod period;
}

/// Nothing is due right now.
class NoRecapDue extends RecapDue {
  const NoRecapDue();
}

/// Decides whether a "Your Cycle in Motion" recap is due (Task 1.3,
/// `TASKS_TO_DO.md`), given the user's logged cycles, [today], and the
/// identity ([RecapPeriod.key]) of the last cycle-end and month-end
/// recaps already shown.
///
/// **Precedence (Task 1.3, explicit requirement): cycle-end wins.** When
/// both a completed cycle and a completed month are newly due at once,
/// only [CycleEndDue] is returned — never both, and never
/// [MonthEndDue] — so the caller shows exactly one recap per check. The
/// month recap isn't lost: it stays due (its key is unchanged) and surfaces
/// on the very next evaluation once the cycle-end one has been marked
/// shown.
///
/// Pure and synchronous — no clock read beyond the given [today], no
/// SharedPreferences access. The caller
/// (`presentation/recap_trigger_controller.dart`) owns fetching
/// [cycleRecords] and the two marker keys, and persisting a new marker
/// once it actually presents a recap.
RecapDue evaluateRecapDue({
  required List<CycleRecord> cycleRecords,
  required LocalDate today,
  required String? lastShownCycleKey,
  required String? lastShownMonthKey,
}) {
  final completedCycles = completedCyclePeriods(cycleRecords);
  if (completedCycles.isNotEmpty) {
    // Newest-completed-first: only the most recently completed cycle can
    // ever be "newly due" - older ones were necessarily already due (and,
    // in normal use, already shown) on an earlier check.
    final mostRecent = completedCycles.last;
    if (mostRecent.key != lastShownCycleKey) {
      return CycleEndDue(mostRecent);
    }
  }

  final completedMonth = mostRecentCompletedMonth(today);
  if (completedMonth.key != lastShownMonthKey) {
    return MonthEndDue(completedMonth);
  }

  return const NoRecapDue();
}
