import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/steps/steps_providers.dart';

/// Seven markers, one per day of the last week, each drawn from a real
/// stored step total.
///
/// ## Why this widget exists (truth fix, 2026-09-03)
///
/// The row it replaces on the home "At a Glance" steps card was **hard
/// coded**: indices 0-3 always rendered a filled tick and 4-5 always
/// rendered a grey one, regardless of what the user had actually walked;
/// only today's marker reflected data. Four days a week were reported as
/// target-met to every user on every install, forever. This reads
/// `dailyStepsRangeProvider` and can therefore say three different things
/// where the old row could only say two:
///
/// * **filled tick** — a stored day at or above the target;
/// * **filled dot** — a stored day below the target;
/// * **hollow ring** — no row for that day at all, i.e. nothing was ever
///   synced. It is never a tick, and never a "below target" marker either,
///   because "they walked less than their target" is a claim and "nothing was
///   recorded" is the absence of one;
/// * **dash** — the history has not been read back yet. Its own glyph, so
///   "still loading" is never mistaken for "nothing recorded".
///
/// The three markers differ in *shape* as well as colour, so the
/// distinction survives colour-blindness and forced-colours; each carries
/// its own semantics label.
class StepsWeekStrip extends ConsumerWidget {
  const StepsWeekStrip({this.todaySteps, super.key});

  /// Today's live count from the health snapshot, when the caller has one.
  ///
  /// Today's stored row is written by the periodic sync and is therefore
  /// stale by construction — the day is still accruing. When the caller
  /// already holds a fresher reading it wins for today only; every other
  /// day comes from storage.
  final int? todaySteps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = LocalDate.today();
    final start = today.addDays(-6);
    final target = ref.watch(stepsTargetProvider);
    final rowsAsync = ref.watch(dailyStepsRangeProvider(start, today));
    final rows = rowsAsync.value;

    final stepsByDay = <LocalDate, int>{
      if (rows != null)
        for (final DailySteps row in rows) row.day: row.steps,
    };
    // A day's count only ever accrues, so today is the LARGER of the two
    // readings, never simply the live one. The live snapshot can be a
    // fabricated zero - `health_providers.dart` falls back to
    // `HealthDataSnapshot.empty` when the platform returns null, and the
    // dashboard reads `snapshot?.steps` - so overwriting unconditionally
    // turned a transient adapter failure at 18:00 into a below-target dot
    // on the home card while `/steps` still showed 9,300 for the same day.
    //
    // Deviation from the reviewed `max(stored ?? 0, live)` worth naming: a
    // live zero with NO stored row leaves today absent rather than
    // recording a zero. Nothing has been synced for today in that case, so
    // the zero is the fabricated one, and inventing a measured "0 steps"
    // is exactly what this widget exists not to do.
    final liveToday = todaySteps;
    final storedToday = stepsByDay[today];
    if (liveToday != null && (storedToday != null || liveToday > 0)) {
      stepsByDay[today] = math.max(storedToday ?? 0, liveToday);
    }

    // Seven equal slots rather than `spaceBetween` over natural widths: the
    // strip lives inside the Steps glance card, which is ~108dp wide on a
    // 320dp phone, and at 150% text the seven markers' natural widths sum
    // to half a pixel more than that (found by the Activity 320dp/150%
    // layout guard). Flexible slots can never overflow; each marker centres
    // itself in its slot.
    return Row(
      children: [
        for (var offset = 6; offset >= 0; offset--)
          Expanded(
            child: _DayMarker(
              day: today.addDays(-offset),
              steps: stepsByDay[today.addDays(-offset)],
              target: target,
              isToday: offset == 0,
              // Before the first emission nothing is known yet, which is
              // not the same as "no data" - saying so would be the old
              // row's mistake in a new place.
              isLoading:
                  rows == null && stepsByDay[today.addDays(-offset)] == null,
            ),
          ),
      ],
    );
  }
}

class _DayMarker extends StatelessWidget {
  const _DayMarker({
    required this.day,
    required this.steps,
    required this.target,
    required this.isToday,
    required this.isLoading,
  });

  final LocalDate day;
  final int? steps;
  final int target;
  final bool isToday;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final initial = DateFormat(
      'E',
    ).format(DateTime(day.year, day.month, day.day)).substring(0, 1);

    final (IconData icon, Color color, String state) = switch (steps) {
      // A dash, not a fainter ring: "still reading the database" and
      // "nothing was ever recorded" are different statements, and two
      // rings differing only in opacity is not a distinction anyone can
      // see - least of all at 12dp, in forced colours, or on a card the
      // eye passes over in half a second.
      null when isLoading => (
        Icons.remove,
        colorScheme.outlineVariant,
        'loading',
      ),
      null => (Icons.circle_outlined, colorScheme.outlineVariant, 'no data'),
      final value when value >= target => (
        Icons.check_circle,
        colorScheme.primary,
        'target reached',
      ),
      _ => (
        Icons.circle,
        colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        'below target',
      ),
    };

    final weekday = DateFormat(
      'EEEE',
    ).format(DateTime(day.year, day.month, day.day));

    return Semantics(
      label: '$weekday, $state',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(height: 2),
          Text(
            initial,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
