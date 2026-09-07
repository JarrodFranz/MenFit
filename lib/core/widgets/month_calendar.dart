import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/tokens.dart';

/// One day slot handed to a [MonthCalendar]'s cell builder.
class MonthCalendarDay {
  const MonthCalendarDay({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
  });

  final LocalDate date;

  /// Whether [date] belongs to the month being displayed, as opposed to
  /// being one of the leading/trailing days that pad the grid out to whole
  /// weeks.
  final bool isCurrentMonth;

  final bool isToday;
}

/// What a caller draws inside one day cell.
///
/// [child] is the day's visual only — [MonthCalendar] supplies the tap
/// target and (when [semanticsLabel] is non-null) the semantics wrapper
/// around it, so every calendar in the app gets the same hit area and the
/// same screen-reader shape.
class MonthCalendarCell {
  const MonthCalendarCell({required this.child, this.semanticsLabel});

  final Widget child;

  /// The day's spoken description. `null` leaves the cell announcing
  /// whatever [child] itself exposes (in practice the bare day number),
  /// which is the right default for a grid where most days carry nothing
  /// worth a sentence.
  final String? semanticsLabel;
}

typedef MonthCalendarCellBuilder = MonthCalendarCell Function(
  MonthCalendarDay day,
);

/// The month grid the wellbeing calendar is built on: a
/// month/year header with previous/next arrows and a jump-to-today button,
/// a weekday header row, and a six-row (or five-row) grid of tappable day
/// cells with horizontal-swipe month navigation.
///
/// **Controlled, not self-managing:** the displayed [month] is owned by the
/// caller and changes are reported through [onMonthChanged]. A calendar
/// whose contents come from a per-month query needs to know which month is
/// showing in order to fetch it, and a widget that hid that inside its own
/// [State] would force every such caller to mirror it back out again.
///
/// Everything about the geometry is deliberate and load-bearing:
///
/// - Cells carry **no inter-cell spacing**; the 2dp gap lives *inside* each
///   cell as padding around the caller's visual, so the drawn calendar
///   looks unchanged while each cell's tappable box grows by the spacing it
///   would otherwise have given away (46.1dp -> 49.5dp at the 411dp
///   reference width).
/// - A seven-column month grid **cannot** reach a 48dp-wide cell below
///   roughly 400dp of usable width. That is arithmetic, not layout, and no
///   accessibility preference can change it; below that width cells stay
///   square and as large as the width allows, and the day detail sheet each
///   cell opens is the accessible path in.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    required this.month,
    required this.today,
    required this.cellBuilder,
    required this.onMonthChanged,
    required this.onDayTap,
    this.latestMonth,
    super.key,
  });

  /// The month on display. Only the year and month are read.
  final DateTime month;

  final LocalDate today;

  final MonthCalendarCellBuilder cellBuilder;

  /// Called with the first-of-month [DateTime] the user navigated to.
  final ValueChanged<DateTime> onMonthChanged;

  final ValueChanged<LocalDate> onDayTap;

  /// The furthest month forward navigation may reach, inclusive. `null`
  /// (the default) leaves navigation unbounded — a calendar of predictions
  /// legitimately runs into the future; one of logged records does not.
  final DateTime? latestMonth;

  bool get _canGoForward {
    final latest = latestMonth;
    if (latest == null) return true;
    return month.year < latest.year ||
        (month.year == latest.year && month.month < latest.month);
  }

  void _previousMonth() =>
      onMonthChanged(DateTime(month.year, month.month - 1));

  void _nextMonth() {
    if (!_canGoForward) return;
    onMonthChanged(DateTime(month.year, month.month + 1));
  }

  void _jumpToToday() => onMonthChanged(DateTime(today.year, today.month));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    final isCurrentMonth =
        month.year == today.year && month.month == today.month;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous Month',
              onPressed: _previousMonth,
            ),
            Expanded(
              child: Text(
                DateFormat('MMMM yyyy').format(month),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next Month',
              onPressed: _canGoForward ? _nextMonth : null,
            ),
            if (!isCurrentMonth) ...[
              SizedBox(width: tokens.spacingXs),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: _jumpToToday,
                child: const Text('Today'),
              ),
            ],
          ],
        ),
        SizedBox(height: tokens.spacingSm),
        const MonthCalendarWeekdayHeader(),
        SizedBox(height: tokens.spacingSm),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            final vel = details.primaryVelocity;
            if (vel == null) return;
            if (vel < -200) {
              _nextMonth();
            } else if (vel > 200) {
              _previousMonth();
            }
          },
          child: _buildGrid(tokens),
        ),
      ],
    );
  }

  Widget _buildGrid(AppTokens tokens) {
    final year = month.year;
    final monthNumber = month.month;
    final (:leadingDays, :totalCells) = monthCalendarGridMetrics(month);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // See the class dartdoc: the inter-cell gap deliberately lives inside
      // each cell instead of between them.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayOffset = index - leadingDays;
        final cellDateTime = DateTime(year, monthNumber, 1 + dayOffset);
        final date = LocalDate(
          cellDateTime.year,
          cellDateTime.month,
          cellDateTime.day,
        );

        final day = MonthCalendarDay(
          date: date,
          isCurrentMonth:
              cellDateTime.year == year && cellDateTime.month == monthNumber,
          isToday: date == today,
        );

        return _cellFor(cellBuilder(day), day, tokens);
      },
    );
  }

  /// Wraps a day's visual in the cell's full-bleed tap target.
  ///
  /// The [InkWell] takes the whole grid cell and the day's visual is inset
  /// inside it, rather than the visual being the tap target with dead
  /// gutters between cells — same drawing, a bigger thing to hit.
  Widget _cellFor(
    MonthCalendarCell cell,
    MonthCalendarDay day,
    AppTokens tokens,
  ) {
    void handleTap() => onDayTap(day.date);

    final tappable = InkWell(
      onTap: handleTap,
      borderRadius: BorderRadius.circular(tokens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: cell.child,
      ),
    );

    final label = cell.semanticsLabel;
    if (label == null) return tappable;

    // `excludeSemantics` replaces the bare day number rather than reading
    // the description *and then* the number, which is how a screen reader
    // would otherwise announce every labelled cell twice. It also drops the
    // `InkWell`'s own node, tap action included, so the action has to be
    // restated here — a day that announces beautifully and cannot be
    // opened is a worse screen-reader experience than the bare number was.
    return Semantics(
      label: label,
      button: true,
      onTap: handleTap,
      excludeSemantics: true,
      child: tappable,
    );
  }
}

/// How many leading blanks a [MonthCalendar] grid for [month] needs, and
/// how many cells it draws in total (a whole number of weeks).
///
/// Public so [monthCalendarGridRange] and the grid itself compute the shape
/// exactly once — a caller querying one span while the grid drew another is
/// precisely the drift this avoids.
({int leadingDays, int totalCells}) monthCalendarGridMetrics(DateTime month) {
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  // weekday is 1..7 (Mon=1, Sun=7).
  final leadingDays = DateTime(month.year, month.month).weekday - 1;
  return (
    leadingDays: leadingDays,
    totalCells: ((leadingDays + daysInMonth) / 7).ceil() * 7,
  );
}

/// The inclusive first and last calendar day a [MonthCalendar] grid for
/// [month] actually draws — the leading and trailing neighbouring-month
/// cells included.
///
/// A caller whose cells come from a per-day query must fetch over THIS
/// range, not over the month: a record on 1 October is drawn by the
/// September grid too, and querying only September would leave that cell
/// blank while the day it opens shows the record.
({LocalDate first, LocalDate last}) monthCalendarGridRange(DateTime month) {
  final (:leadingDays, :totalCells) = monthCalendarGridMetrics(month);
  final first = DateTime(month.year, month.month, 1 - leadingDays);
  final last = DateTime(month.year, month.month, totalCells - leadingDays);
  return (
    first: LocalDate(first.year, first.month, first.day),
    last: LocalDate(last.year, last.month, last.day),
  );
}

/// The Mon-Sun column headings above a [MonthCalendar]'s grid.
class MonthCalendarWeekdayHeader extends StatelessWidget {
  const MonthCalendarWeekdayHeader({super.key});

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _weekdays.map((day) {
        return Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }
}
