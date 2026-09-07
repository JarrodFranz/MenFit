import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/progress/domain/weekly_summary.dart';

/// The aggregation period for the Progress / Health Overview screen.
enum ProgressPeriod {
  day,
  week,
  month;

  String get label => switch (this) {
    ProgressPeriod.day => 'Day',
    ProgressPeriod.week => 'Week',
    ProgressPeriod.month => 'Month',
  };

  /// Computes the start and end [LocalDate] inclusive for [anchor].
  ({LocalDate start, LocalDate end}) rangeFor(LocalDate anchor) {
    return switch (this) {
      ProgressPeriod.day => (start: anchor, end: anchor),
      ProgressPeriod.week => () {
        final monday = mondayOf(anchor);
        return (start: monday, end: monday.addDays(6));
      }(),
      ProgressPeriod.month => () {
        final start = LocalDate(anchor.year, anchor.month, 1);
        final lastDay = DateTime.utc(anchor.year, anchor.month + 1, 0).day;
        final end = LocalDate(anchor.year, anchor.month, lastDay);
        return (start: start, end: end);
      }(),
    };
  }

  /// Steps one period backward from [anchor].
  LocalDate previous(LocalDate anchor) {
    return switch (this) {
      ProgressPeriod.day => anchor.addDays(-1),
      ProgressPeriod.week => anchor.addDays(-7),
      ProgressPeriod.month => () {
        final prevMonth = anchor.month == 1 ? 12 : anchor.month - 1;
        final prevYear = anchor.month == 1 ? anchor.year - 1 : anchor.year;
        final maxDay = DateTime.utc(prevYear, prevMonth + 1, 0).day;
        final clampedDay = anchor.day.clamp(1, maxDay);
        return LocalDate(prevYear, prevMonth, clampedDay);
      }(),
    };
  }

  /// Steps one period forward from [anchor], clamped so it doesn't exceed
  /// [today].
  LocalDate next(LocalDate anchor, LocalDate today) {
    final candidate = switch (this) {
      ProgressPeriod.day => anchor.addDays(1),
      ProgressPeriod.week => anchor.addDays(7),
      ProgressPeriod.month => () {
        final nextMonth = anchor.month == 12 ? 1 : anchor.month + 1;
        final nextYear = anchor.month == 12 ? anchor.year + 1 : anchor.year;
        final maxDay = DateTime.utc(nextYear, nextMonth + 1, 0).day;
        final clampedDay = anchor.day.clamp(1, maxDay);
        return LocalDate(nextYear, nextMonth, clampedDay);
      }(),
    };

    return candidate.isAfter(today) ? today : candidate;
  }

  /// Whether the next period from [anchor] is allowed (i.e. not already in the
  /// current period).
  bool canGoForward(LocalDate anchor, LocalDate today) {
    final currentRange = rangeFor(anchor);
    final todayRange = rangeFor(today);
    return currentRange.start.isBefore(todayRange.start);
  }

  /// Formats the range for display in the period header.
  String formatRange(LocalDate anchor, LocalDate today) {
    final range = rangeFor(anchor);
    final todayRange = rangeFor(today);

    switch (this) {
      case ProgressPeriod.day:
        if (anchor == today) return 'Today';
        if (anchor == today.addDays(-1)) return 'Yesterday';
        final dt = DateTime(anchor.year, anchor.month, anchor.day);
        return DateFormat('EEE, d MMM yyyy').format(dt);

      case ProgressPeriod.week:
        if (range.start == todayRange.start) return 'This Week';
        final lastWeekMonday = todayRange.start.addDays(-7);
        if (range.start == lastWeekMonday) return 'Last Week';
        final s = DateTime(
          range.start.year,
          range.start.month,
          range.start.day,
        );
        final e = DateTime(range.end.year, range.end.month, range.end.day);
        final sFmt = DateFormat('d MMM').format(s);
        final eFmt = DateFormat('d MMM yyyy').format(e);
        return '$sFmt – $eFmt';

      case ProgressPeriod.month:
        if (anchor.year == today.year && anchor.month == today.month) {
          return 'This Month';
        }
        final dt = DateTime(anchor.year, anchor.month);
        return DateFormat('MMMM yyyy').format(dt);
    }
  }
}
