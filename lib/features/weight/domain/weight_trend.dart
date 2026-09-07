import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';

/// Smoothing methods this engine can produce a trend with.
///
/// Both are implemented and both are tested; [rollingMedian] is what the
/// app ships ([defaultWeightTrendMethod]) — see that constant for the
/// reasoning.
enum WeightTrendMethod {
  /// Median of every reading in the trailing calendar window.
  rollingMedian,

  /// Exponentially weighted mean of the readings so far, with
  /// `alpha = 2 / (windowDays + 1)`.
  exponentialMovingAverage,
}

/// Which way the smoothed trend moved across the window that was computed.
///
/// Deliberately valence-free: there is no "good" direction here and no
/// "progress". `TASKS_TO_DO.md` task 2.2 exists to take the anxiety out of
/// a number that moves for a dozen reasons a day, and a name like
/// `improving`/`gaining` would smuggle a judgement back in through the
/// type system — presentation would then have somewhere to hang a green
/// arrow. Callers get a direction and nothing else; see
/// `knowledge/domain/womens_health.md`.
enum WeightTrendDirection {
  rising,
  falling,
  steady,

  /// Not enough smoothed points to say anything — fewer than two days
  /// carry a trend value. Not a fourth direction, and callers must render
  /// it as "we can't say yet" rather than as "flat".
  undetermined,
}

/// One calendar day of the series: the day's own reading, plus the
/// smoothed value for that day when one is defined.
class WeightTrendPoint {
  const WeightTrendPoint({
    required this.day,
    required this.weightKg,
    this.trendKg,
  });

  final LocalDate day;

  /// That day's **latest** reading, in canonical kilograms. Days with
  /// several weigh-ins collapse to the last one recorded — see
  /// [latestReadingPerDay].
  final double weightKg;

  /// The smoothed value for this day, or `null` when the window behind
  /// this day holds too few real readings to smooth honestly (see
  /// [computeWeightTrend]).
  final double? trendKg;
}

/// A computed weight series: one point per calendar day that actually has
/// a reading, oldest first.
///
/// **Days without a reading are simply absent.** Nothing here interpolates
/// them, and nothing invents a value to bridge a gap — a chart drawing a
/// straight segment between two points a fortnight apart is a drawing
/// decision, not data, and the engine refuses to make it look like data by
/// materialising the days in between. Consumers that need "how far apart
/// are these two points" read [WeightTrendPoint.day].
class WeightTrendSeries {
  const WeightTrendSeries({
    required this.points,
    required this.method,
    required this.windowDays,
    required this.direction,
    this.trendChangeKg,
  });

  /// Empty series — no readings at all.
  const WeightTrendSeries.empty({
    this.method = defaultWeightTrendMethod,
    this.windowDays = defaultTrendWindowDays,
  }) : points = const [],
       direction = WeightTrendDirection.undetermined,
       trendChangeKg = null;

  /// One entry per day with a reading, oldest first.
  final List<WeightTrendPoint> points;

  final WeightTrendMethod method;
  final int windowDays;

  /// Direction of the smoothed line from its first defined value to its
  /// last, or [WeightTrendDirection.undetermined] when there aren't two.
  final WeightTrendDirection direction;

  /// Signed difference in kilograms between the last and first defined
  /// trend values, or `null` when [direction] is
  /// [WeightTrendDirection.undetermined].
  ///
  /// Exposed because the domain has no business deciding what a screen may
  /// show, but note that the shipped UI renders [direction] only: a
  /// running total presented next to a body-weight chart reads as a
  /// scoreboard, which is exactly what this feature is meant not to be.
  final double? trendChangeKg;

  bool get isEmpty => points.isEmpty;

  /// Whether any day carries a smoothed value. `false` means the caller
  /// should show the readings alone — see [minimumDaysForWeightTrend].
  bool get hasTrend => points.any((point) => point.trendKg != null);

  /// The most recent day with a reading, or `null` when there are none.
  WeightTrendPoint? get latest => points.isEmpty ? null : points.last;
}

/// The method the app ships with.
///
/// **A 7-day rolling median, not an EMA**, despite task 2.2's title naming
/// the EMA. The two behave differently in exactly the situation this
/// feature exists for — a luteal-phase fluid swing of a kilogram or more
/// sitting on top of an otherwise ordinary week:
///
/// - An EMA *absorbs* the swing. With `alpha = 0.25` a single +1.5 kg
///   reading lifts the line by ~0.4 kg immediately and is still visible
///   several days later. The line stays smooth, but it moved because of
///   water, which is the anxiety the feature is supposed to remove.
/// - A rolling median *ignores* it. One outlier in a window of five or
///   more cannot move the midpoint at all. The cost is that the line
///   steps rather than glides, which is cosmetic — and the raw readings
///   are drawn as dots underneath it anyway, so nothing is hidden.
///
/// It is also the consistent choice for this codebase: the insights engine
/// made the same call for the same reason (see
/// `features/insights/domain/insight_statistics.dart`'s library doc — "a
/// mean would let that single day decide what the app tells the user about
/// her own body; a median or a rank statistic cannot"). Two engines
/// reading the same self-logged data should not disagree about how much a
/// single bad number is allowed to matter.
///
/// [WeightTrendMethod.exponentialMovingAverage] remains implemented and
/// tested; switching the default is a one-line change if the product ever
/// wants the glide back.
const WeightTrendMethod defaultWeightTrendMethod =
    WeightTrendMethod.rollingMedian;

/// Length of the trailing window, in **calendar days** — not in readings.
///
/// Seven so the window always spans a whole week: a user who weighs in
/// only on weekdays, or only on Mondays and Thursdays, still gets a window
/// with a fixed real-world meaning instead of one that silently stretches
/// over however many weeks her last seven readings happened to cover.
const int defaultTrendWindowDays = 7;

/// Days-with-a-reading required before any trend value is emitted at all.
///
/// Five. Below that a smoothed line is false confidence: with three points
/// the "trend" is just the middle one, and drawing it invites the user to
/// read a direction out of noise. Under the gate the series still carries
/// every reading — the caller shows the dots and says why there is no line
/// yet.
const int minimumDaysForWeightTrend = 5;

/// Readings that must fall inside a day's trailing window before that day
/// gets a trend value.
///
/// Three. This is what keeps gaps honest: after a fortnight of not
/// weighing in, the first reading back has a window containing only
/// itself, so it gets no trend value, and the line resumes only once
/// enough real readings have accumulated again. Nothing is interpolated
/// across the gap.
const int minimumReadingsInTrendWindow = 3;

/// How far the smoothed line has to move across the window before the
/// direction stops being [WeightTrendDirection.steady], in kilograms.
///
/// Half a kilogram. The smoothing has already removed day-to-day fluid
/// movement, so what is left below this is scale resolution and rounding,
/// not a direction worth naming.
const double trendSteadyThresholdKg = 0.5;

/// Collapses [logs] to at most one reading per calendar day — **the last
/// one recorded on that day**.
///
/// Several weigh-ins a day are allowed by design
/// (`domain/weight_repository.dart`), and a day has to become one point
/// before it can be smoothed. The last reading wins rather than the mean
/// of the day's readings: a mean would blend a post-run reading into a
/// morning one and produce a number the user never saw on her scale.
///
/// Input order is not trusted. The repository documents oldest-first
/// (`day` ASC, `createdAt` ASC, `id` ASC) and this function reproduces
/// exactly that ordering itself before collapsing, so a caller that hands
/// over a reversed or unsorted list still gets the same answer instead of
/// a quietly wrong one.
List<WeightLog> latestReadingPerDay(List<WeightLog> logs) {
  if (logs.isEmpty) return const [];

  final sorted = List<WeightLog>.of(logs)
    ..sort((a, b) {
      final byDay = a.day.compareTo(b.day);
      if (byDay != 0) return byDay;
      final byCreated = a.createdAt.compareTo(b.createdAt);
      if (byCreated != 0) return byCreated;
      return a.id.compareTo(b.id);
    });

  final byDay = <LocalDate, WeightLog>{};
  for (final log in sorted) {
    byDay[log.day] = log;
  }
  return byDay.values.toList(growable: false);
}

/// Builds the smoothed series for [logs].
///
/// Steps, in order:
///
/// 1. Collapse to one reading per day ([latestReadingPerDay]).
/// 2. Refuse to smooth at all when fewer than [minimumDaysForTrend] days
///    carry a reading — every point comes back with a `null`
///    [WeightTrendPoint.trendKg] and [WeightTrendSeries.hasTrend] is
///    `false`.
/// 3. Otherwise smooth each day from the readings in its trailing
///    [windowDays]-day calendar window, leaving [WeightTrendPoint.trendKg]
///    `null` on any day whose window holds fewer than
///    [minimumReadingsInWindow] real readings.
///
/// The window is a *calendar* window, so a gap in logging shrinks it
/// rather than reaching further back in time. **No missing day is ever
/// filled in** — not with the previous reading, not with a straight line
/// between neighbours, not with a group mean. A gap is information (she
/// didn't weigh in), and inventing values across it would put numbers she
/// never measured into a chart of her own body.
///
/// [WeightTrendMethod.exponentialMovingAverage] additionally **restarts**
/// after a gap longer than [windowDays]: carrying a month-old average into
/// today's reading would present a stale number as a current one. The
/// median has no state to carry, so it needs no equivalent rule.
///
/// Pure: no clock, no I/O, no Flutter. `today` is not a parameter because
/// nothing here depends on when it is run — the same logs always give the
/// same series.
WeightTrendSeries computeWeightTrend({
  required List<WeightLog> logs,
  WeightTrendMethod method = defaultWeightTrendMethod,
  int windowDays = defaultTrendWindowDays,
  int minimumDaysForTrend = minimumDaysForWeightTrend,
  int minimumReadingsInWindow = minimumReadingsInTrendWindow,
  double steadyThresholdKg = trendSteadyThresholdKg,
}) {
  final daily = latestReadingPerDay(logs);
  if (daily.isEmpty) {
    return WeightTrendSeries.empty(method: method, windowDays: windowDays);
  }

  final days = [for (final log in daily) log.day];
  final values = [for (final log in daily) log.weightKg];

  if (daily.length < minimumDaysForTrend) {
    return WeightTrendSeries(
      points: [
        for (var i = 0; i < daily.length; i++)
          WeightTrendPoint(day: days[i], weightKg: values[i]),
      ],
      method: method,
      windowDays: windowDays,
      direction: WeightTrendDirection.undetermined,
    );
  }

  final smoothed = switch (method) {
    WeightTrendMethod.rollingMedian => _rollingMedian(
      days: days,
      values: values,
      windowDays: windowDays,
      minimumReadingsInWindow: minimumReadingsInWindow,
    ),
    WeightTrendMethod.exponentialMovingAverage => _exponentialMovingAverage(
      days: days,
      values: values,
      windowDays: windowDays,
      minimumReadingsInWindow: minimumReadingsInWindow,
    ),
  };

  final points = [
    for (var i = 0; i < daily.length; i++)
      WeightTrendPoint(day: days[i], weightKg: values[i], trendKg: smoothed[i]),
  ];

  final defined = smoothed.whereType<double>().toList(growable: false);
  if (defined.length < 2) {
    return WeightTrendSeries(
      points: points,
      method: method,
      windowDays: windowDays,
      direction: WeightTrendDirection.undetermined,
    );
  }

  final change = defined.last - defined.first;
  final direction = change.abs() < steadyThresholdKg
      ? WeightTrendDirection.steady
      : (change > 0
            ? WeightTrendDirection.rising
            : WeightTrendDirection.falling);

  return WeightTrendSeries(
    points: points,
    method: method,
    windowDays: windowDays,
    direction: direction,
    trendChangeKg: change,
  );
}

/// Index of the earliest day still inside the trailing window ending at
/// `days[end]`. Linear scan backwards — the windows are days long and the
/// series is at most a year, so this is cheaper than any index structure
/// would be to maintain.
int _windowStart(List<LocalDate> days, int end, int windowDays) {
  final earliest = days[end].addDays(-(windowDays - 1));
  var start = end;
  while (start > 0 && !days[start - 1].isBefore(earliest)) {
    start--;
  }
  return start;
}

List<double?> _rollingMedian({
  required List<LocalDate> days,
  required List<double> values,
  required int windowDays,
  required int minimumReadingsInWindow,
}) {
  final out = List<double?>.filled(values.length, null);
  for (var i = 0; i < values.length; i++) {
    final start = _windowStart(days, i, windowDays);
    final window = values.sublist(start, i + 1);
    if (window.length < minimumReadingsInWindow) continue;
    out[i] = _median(window);
  }
  return out;
}

double _median(List<double> window) {
  final sorted = List<double>.of(window)..sort();
  final mid = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[mid];
  return (sorted[mid - 1] + sorted[mid]) / 2;
}

List<double?> _exponentialMovingAverage({
  required List<LocalDate> days,
  required List<double> values,
  required int windowDays,
  required int minimumReadingsInWindow,
}) {
  final alpha = 2 / (windowDays + 1);
  final out = List<double?>.filled(values.length, null);
  double? average;

  for (var i = 0; i < values.length; i++) {
    final restart =
        i == 0 ||
        days[i - 1].difference(days[i]) > windowDays ||
        average == null;
    average = restart ? values[i] : alpha * values[i] + (1 - alpha) * average;

    final start = _windowStart(days, i, windowDays);
    if (i + 1 - start < minimumReadingsInWindow) continue;
    out[i] = average;
  }
  return out;
}
