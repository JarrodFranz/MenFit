import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/core/widgets/month_calendar.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/wellbeing/domain/daily_checkin.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/wellbeing_day_semantics.dart';
import 'package:menfit_app/features/wellbeing/presentation/wellbeing_watch_providers.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_calendar_cells.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_day_sheet.dart';
import 'package:menfit_app/features/wellbeing/presentation/widgets/wellbeing_load_failure.dart';

/// A month at a glance on the Wellbeing tab: which days carry a check-in,
/// a flare-up, or a marked recovery day, with the list of entries still
/// below it.
///
/// Each day draws up to three **distinct glyphs**
/// (`widgets/wellbeing_glyphs.dart`) — never colour alone, which is the
/// standing finding against the cycle calendar's day dots
/// (`knowledge/engineering/accessibility.md`). The glyphs are the same
/// ones the history cards use, so the vocabulary is learned once.
///
/// Forward navigation stops at the current month: nothing can be logged on
/// a day that has not happened, so a calendar of logged records has nothing
/// to show past it (unlike the cycle calendar, whose predictions are the
/// reason to look ahead). Future days *within* the current month still
/// render — they are part of the month — but carry no markers.
///
/// Importing `streaks`' composition surface for the recovery days is
/// ADR-007-legal, the same import `wellbeing_screen.dart` already makes.
class WellbeingCalendar extends ConsumerStatefulWidget {
  const WellbeingCalendar({super.key});

  @override
  ConsumerState<WellbeingCalendar> createState() => _WellbeingCalendarState();
}

class _WellbeingCalendarState extends ConsumerState<WellbeingCalendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final today = LocalDate.today();

    // The grid's OWN span, leading and trailing neighbouring-month cells
    // included — not the calendar month. A flare running 30 September to
    // 2 October is drawn by both grids, and querying only the month would
    // leave September's trailing 1-2 October cells blank while the sheet
    // they open showed the flare.
    final (first: from, last: to) = monthCalendarGridRange(_displayedMonth);

    // A month whose data hasn't arrived yet renders as an unmarked month
    // rather than a spinner: the grid itself is meaningful immediately, and
    // swapping it for a progress indicator on every month change would make
    // paging back through history flicker. A FAILED read is different — see
    // `failed` below.
    final checkinsAsync = ref.watch(checkinsForRangeProvider(from, to));
    final flaresAsync = ref.watch(flaresForRangeProvider(from, to));
    final eventsAsync = ref.watch(eventsForRangeProvider(from, to));
    // Unwindowed by design (`recoveryDayEntriesProvider`'s dartdoc) — the
    // set stays small, so the grid's days are filtered out of it here
    // rather than asking for a second, windowed query.
    final recoveryAsync = ref.watch(recoveryDayEntriesProvider);

    // An empty grid and a grid that could not be read look identical, and
    // for health data that is the wrong thing to let happen: "nothing
    // logged" is a claim about her records, not about the query.
    final failed =
        checkinsAsync.hasError ||
        flaresAsync.hasError ||
        eventsAsync.hasError ||
        recoveryAsync.hasError;

    final checkins = checkinsAsync.value ?? const <DailyCheckin>[];
    final flares = flaresAsync.value ?? const <FlareEvent>[];
    final events = eventsAsync.value ?? const <WellbeingEvent>[];
    final recoveryEntries = recoveryAsync.value ?? const <RecoveryDayEntry>[];

    final checkinDays = <LocalDate>{
      for (final checkin in checkins)
        if (!checkin.isEmpty) checkin.day,
    };
    final flareDays = <LocalDate>{
      // A flare overlapping the grid may start or end outside it; the days
      // outside simply never get looked up.
      for (final flare in flares) ...flare.days,
    };
    final recoveryDays = <LocalDate>{
      for (final entry in recoveryEntries) entry.day,
    };
    final eventsByDay = <LocalDate, List<WellbeingEventType>>{};
    for (final event in events) {
      eventsByDay.putIfAbsent(event.day, () => []).add(event.type);
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacingMd),
        child: Column(
          children: [
            MonthCalendar(
              month: _displayedMonth,
              today: today,
              latestMonth: DateTime(today.year, today.month),
              onMonthChanged: (month) =>
                  setState(() => _displayedMonth = month),
              onDayTap: (date) => WellbeingDaySheet.show(context, day: date),
              cellBuilder: (day) {
                // Markers are drawn on leading/trailing cells too: those
                // days are real days, the query covered them, and the
                // sheet they open shows the same records. The dimmed day
                // number is what keeps them readable as another month's.
                final hasCheckin = checkinDays.contains(day.date);
                final hasFlare = flareDays.contains(day.date);
                final isRecoveryDay = recoveryDays.contains(day.date);
                final dayEvents = eventsByDay[day.date] ?? const [];
                return MonthCalendarCell(
                  semanticsLabel: wellbeingDaySemanticLabel(
                    date: day.date,
                    isToday: day.isToday,
                    hasCheckin: hasCheckin,
                    hasFlare: hasFlare,
                    isRecoveryDay: isRecoveryDay,
                  ),
                  child: WellbeingDayCell(
                    dayNumber: day.date.day,
                    isCurrentMonth: day.isCurrentMonth,
                    isToday: day.isToday,
                    hasCheckin: hasCheckin,
                    hasFlare: hasFlare,
                    isRecoveryDay: isRecoveryDay,
                    events: dayEvents,
                  ),
                );
              },
            ),
            SizedBox(height: tokens.spacingMd),
            const Divider(height: 1),
            SizedBox(height: tokens.spacingSm),
            if (failed) ...[
              const WellbeingLoadFailure(text: "Couldn't load this month."),
              SizedBox(height: tokens.spacingSm),
            ],
            const WellbeingCalendarLegend(),
          ],
        ),
      ),
    );
  }
}
