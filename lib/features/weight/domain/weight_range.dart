import 'package:menfit_app/core/domain/local_date.dart';

/// The time spans the weight chart can be shown over.
///
/// Pure domain (no Flutter) so the window arithmetic is unit-testable and
/// so the controller, the providers and the chart all agree on what "3M"
/// means instead of each computing its own start date.
enum WeightRange {
  oneMonth('1M', 30),
  threeMonths('3M', 90),
  sixMonths('6M', 180),
  oneYear('1Y', 365),

  /// Everything ever logged. [days] is `null` — see [startFor].
  all('All', null);

  const WeightRange(this.label, this.days);

  /// Segmented-control label. Short on purpose: five segments have to fit
  /// at compact width.
  final String label;

  /// Length of the window in days, **inclusive of today** (so
  /// [oneMonth] covers `today - 29 .. today`), or `null` for [all].
  final int? days;

  /// The first day of this range relative to [today].
  ///
  /// [all] returns 1 January 1900 rather than a computed offset: the
  /// repository's range reads are inclusive and cheap (the `day` column is
  /// indexed), and a fixed floor is honest about "everything" in a way
  /// that an arbitrary "25 years back" constant is not.
  LocalDate startFor(LocalDate today) {
    final span = days;
    return span == null ? LocalDate(1900, 1, 1) : today.addDays(-(span - 1));
  }
}

/// What the chart draws.
enum WeightSeriesMode {
  /// Smoothed line plus the individual readings as dots.
  readingsAndTrend,

  /// Smoothed line only — for a user who would rather not look at the
  /// day-to-day numbers at all. Deliberately offered: the raw dots are the
  /// part of this screen most likely to be read as a verdict, and hiding
  /// them is a legitimate way to use the feature.
  trendOnly,
}
