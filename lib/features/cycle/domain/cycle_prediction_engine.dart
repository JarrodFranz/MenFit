import 'dart:math' as math;

import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';

/// The 4 biological phases of a menstrual cycle (plus none/unknown).
enum CyclePhase {
  /// Bleeding days (Days 1–5 typically).
  menstrual,

  /// Post-period estrogen rise leading up to ovulation (Days 6–13 typically).
  follicular,

  /// Peak fertility and egg release (Days 14–16 typically).
  ovulatory,

  /// Post-ovulation progesterone dominance (Days 17–28 typically).
  luteal,

  /// Unknown or between tracked periods.
  none;

  String get label => switch (this) {
    CyclePhase.menstrual => 'Menstrual',
    CyclePhase.follicular => 'Follicular',
    CyclePhase.ovulatory => 'Ovulatory',
    CyclePhase.luteal => 'Luteal',
    CyclePhase.none => 'None',
  };

  String get plainDescription => switch (this) {
    CyclePhase.menstrual =>
      'Your period days. Estrogen and progesterone are at baseline.',
    CyclePhase.follicular =>
      'Energy begins rising as estrogen increases; your body prepares an egg.',
    CyclePhase.ovulatory =>
      'Peak estrogen and LH surge; an egg is released into the fallopian tube.',
    CyclePhase.luteal =>
      'Progesterone rises to support the uterine lining; premenstrual phase.',
    CyclePhase.none => 'No specific phase calculated.',
  };
}

/// Confidence rating for cycle predictions based on history depth.
enum CycleConfidence {
  /// 4+ regular logged cycles with consistent length (std dev <= 3.5 days).
  high,

  /// 2-3 logged cycles, or moderate variability (std dev 3.5 to 6.0 days).
  moderate,

  /// 0-1 logged cycles or high irregularity. Uses population baseline.
  low;

  String get label => switch (this) {
    CycleConfidence.high => 'High confidence',
    CycleConfidence.moderate => 'Moderate confidence',
    CycleConfidence.low => 'Getting started',
  };

  /// The same confidence, worded to be *read out* mid-sentence.
  ///
  /// [label] is written for a card that already says "confidence" beside
  /// it, and its lowest rung is deliberately encouraging ("Getting
  /// started") rather than literal. Spoken as the qualifier on an estimate
  /// — "an estimate, getting started" — that stops meaning anything, so
  /// screen-reader copy states the confidence plainly instead. Same
  /// information, no change to what is shown on screen.
  String get spokenLabel => switch (this) {
    CycleConfidence.high => 'high confidence',
    CycleConfidence.moderate => 'moderate confidence',
    CycleConfidence.low =>
      'low confidence, based on a typical 28-day cycle until more cycles '
          'are logged',
  };

  String get description => switch (this) {
    CycleConfidence.high =>
      'Based on 4+ consistent logged cycles with high regularity.',
    CycleConfidence.moderate => 'Based on 2–3 logged cycles or mild variation.',
    CycleConfidence.low =>
      'Based on population baseline (28-day cycle) until more cycles '
          'are logged.',
  };
}

/// Cycle status for a specific calendar day.
class DayCycleStatus {
  const DayCycleStatus({
    required this.date,
    required this.isLoggedPeriod,
    required this.isPredictedPeriod,
    required this.phase,
    this.cycleDayNumber,
    this.isOvulationDay = false,
    this.associatedRecord,
  });

  final LocalDate date;

  /// Whether the user explicitly logged a period on this day.
  final bool isLoggedPeriod;

  /// Whether this day is predicted to be a period day based on the engine.
  final bool isPredictedPeriod;

  /// Estimated phase for this day.
  final CyclePhase phase;

  /// Day number in the cycle (Day 1 = start of period), or null if untracked.
  final int? cycleDayNumber;

  /// Whether this day is the estimated ovulation midpoint.
  final bool isOvulationDay;

  /// The matching user record if logged.
  final CycleRecord? associatedRecord;
}

/// A predicted future period window.
class PredictedPeriod {
  const PredictedPeriod({
    required this.startDate,
    required this.endDate,
    required this.cycleIndex,
  });

  final LocalDate startDate;
  final LocalDate endDate;
  final int cycleIndex;

  int get durationDays => startDate.difference(endDate) + 1;
}

/// High-level cycle prediction summary for the user's dashboard.
class CyclePredictionSummary {
  const CyclePredictionSummary({
    required this.today,
    required this.medianCycleLength,
    required this.medianPeriodDuration,
    required this.confidence,
    required this.currentPhase,
    required this.daysUntilNextPeriod,
    this.currentCycleDay,
    this.nextPeriodStart,
    this.nextPeriodEnd,
    this.isOngoingPeriod = false,
    this.totalLoggedCycles = 0,
    this.stdDevDays = 0.0,
  });

  final LocalDate today;
  final int medianCycleLength;
  final int medianPeriodDuration;
  final CycleConfidence confidence;
  final CyclePhase currentPhase;
  final int? currentCycleDay;
  final LocalDate? nextPeriodStart;
  final LocalDate? nextPeriodEnd;
  final int daysUntilNextPeriod;
  final bool isOngoingPeriod;
  final int totalLoggedCycles;
  final double stdDevDays;
}

/// Extensible interface for optional biometric signal adapters (BBT, LH, HR).
abstract class CycleSignalAdapter {
  String get name;
  Future<CyclePhase?> evaluateSignal({
    required LocalDate date,
    required CyclePredictionSummary summary,
  });
}

/// Pure Dart engine for menstrual cycle length calculation, phase estimation,
/// confidence scoring, and multi-month forward predictions.
class CyclePredictionEngine {
  CyclePredictionEngine({
    this.defaultCycleLength = 28,
    this.defaultPeriodDuration = 5,
    this.signalAdapters = const [],
  });

  final int defaultCycleLength;
  final int defaultPeriodDuration;
  final List<CycleSignalAdapter> signalAdapters;

  /// Plausibility bounds for a cycle length (days between two consecutive
  /// logged period starts).
  ///
  /// An interval outside this range is read as a **gap in logging**, not as
  /// a real cycle: two starts 4 days apart are a corrected/duplicated log,
  /// and two starts 6 months apart mean the user stopped logging. Such an
  /// interval is excluded from the length statistics in [analyze] and is
  /// never phased retrospectively by [getDayStatus].
  static const int minPlausibleCycleLength = 15;
  static const int maxPlausibleCycleLength = 90;

  /// Plausibility bounds for a logged period's duration, in days. Applied
  /// to the same effect as the cycle-length bounds above.
  static const int minPlausiblePeriodDuration = 1;
  static const int maxPlausiblePeriodDuration = 14;

  /// Nominal length of the luteal phase, in days.
  ///
  /// The luteal phase is the physiologically stable part of the cycle — the
  /// corpus luteum has a roughly fixed lifespan, so cycle-to-cycle length
  /// variation lands almost entirely in the follicular phase before
  /// ovulation, not after it. This is why every phase boundary in this
  /// engine is measured **backwards from the next period start** rather
  /// than forwards from the current one. It stays an estimate either way
  /// (see `knowledge/domain/womens_health.md`): only logged bleed days are
  /// facts.
  static const int nominalLutealLength = 14;

  /// Analyzes [records] relative to [today] and produces a prediction summary.
  CyclePredictionSummary analyze({
    required List<CycleRecord> records,
    required LocalDate today,
  }) {
    if (records.isEmpty) {
      return CyclePredictionSummary(
        today: today,
        medianCycleLength: defaultCycleLength,
        medianPeriodDuration: defaultPeriodDuration,
        confidence: CycleConfidence.low,
        currentPhase: CyclePhase.none,
        daysUntilNextPeriod: defaultCycleLength,
      );
    }

    final sorted = List<CycleRecord>.from(records)
      ..sort((a, b) => a.periodStart.compareTo(b.periodStart));

    final ongoing = sorted.where((r) => r.isOngoing).firstOrNull;
    final isOngoing = ongoing != null;

    // Calculate historical cycle lengths (days between consecutive starts)
    final cycleLengths = <int>[];
    for (var i = 0; i < sorted.length - 1; i++) {
      final days = sorted[i].periodStart.difference(sorted[i + 1].periodStart);
      if (days >= minPlausibleCycleLength && days <= maxPlausibleCycleLength) {
        cycleLengths.add(days);
      }
    }

    // Calculate historical period durations (start to end inclusive)
    final periodDurations = <int>[];
    for (final r in sorted) {
      if (r.periodEnd != null) {
        final dur = r.periodStart.difference(r.periodEnd!) + 1;
        if (dur >= minPlausiblePeriodDuration &&
            dur <= maxPlausiblePeriodDuration) {
          periodDurations.add(dur);
        }
      }
    }

    final medianCycle = cycleLengths.isNotEmpty
        ? _calculateMedian(cycleLengths)
        : defaultCycleLength;

    final medianPeriod = periodDurations.isNotEmpty
        ? _calculateMedian(periodDurations)
        : defaultPeriodDuration;

    final stdDev = cycleLengths.isNotEmpty
        ? _calculateStdDev(cycleLengths)
        : 0.0;

    final confidence = _determineConfidence(
      cycleCount: cycleLengths.length,
      stdDev: stdDev,
    );

    final mostRecentRecord = sorted.last;
    final daysSinceLastStart = mostRecentRecord.periodStart.difference(today);

    // Current cycle day (1-indexed)
    int? currentCycleDay;
    if (daysSinceLastStart >= 0 && daysSinceLastStart <= medianCycle * 2) {
      currentCycleDay = daysSinceLastStart + 1;
    }

    // Determine current phase
    CyclePhase currentPhase;
    if (isOngoing ||
        (daysSinceLastStart >= 0 && daysSinceLastStart < medianPeriod)) {
      currentPhase = CyclePhase.menstrual;
    } else if (currentCycleDay != null) {
      currentPhase = _estimatePhase(
        cycleDay: currentCycleDay,
        cycleLength: medianCycle,
        periodDuration: medianPeriod,
      ).phase;
    } else {
      currentPhase = CyclePhase.none;
    }

    // Predicted next period start
    LocalDate nextStart;
    if (isOngoing) {
      nextStart = mostRecentRecord.periodStart.addDays(medianCycle);
    } else if (daysSinceLastStart <= medianCycle) {
      nextStart = mostRecentRecord.periodStart.addDays(medianCycle);
    } else {
      // Overdue cycle: project from today or latest cycle interval
      final cyclesMissed = ((daysSinceLastStart - 1) / medianCycle).floor();
      nextStart = mostRecentRecord.periodStart.addDays(
        medianCycle * (cyclesMissed + 1),
      );
    }

    final nextEnd = nextStart.addDays(medianPeriod - 1);
    final daysUntilNext = today.difference(nextStart);

    return CyclePredictionSummary(
      today: today,
      medianCycleLength: medianCycle,
      medianPeriodDuration: medianPeriod,
      confidence: confidence,
      currentPhase: currentPhase,
      currentCycleDay: currentCycleDay,
      nextPeriodStart: nextStart,
      nextPeriodEnd: nextEnd,
      daysUntilNextPeriod: math.max(0, daysUntilNext),
      isOngoingPeriod: isOngoing,
      totalLoggedCycles: cycleLengths.length,
      stdDevDays: stdDev,
    );
  }

  /// Projects upcoming predicted periods for up to [monthsAhead] in future.
  List<PredictedPeriod> projectFuturePeriods({
    required List<CycleRecord> records,
    required LocalDate today,
    int monthsAhead = 6,
  }) {
    if (records.isEmpty) {
      // Generate sample predictions from today
      final predictions = <PredictedPeriod>[];
      var start = today;
      for (var i = 0; i < monthsAhead; i++) {
        final end = start.addDays(defaultPeriodDuration - 1);
        predictions.add(
          PredictedPeriod(startDate: start, endDate: end, cycleIndex: i),
        );
        start = start.addDays(defaultCycleLength);
      }
      return predictions;
    }

    final summary = analyze(records: records, today: today);
    final predictions = <PredictedPeriod>[];
    var currentStart = summary.nextPeriodStart ?? today;

    final horizon = today.addDays(monthsAhead * 31);
    var index = 0;

    while (!currentStart.isAfter(horizon) && index < 12) {
      final end = currentStart.addDays(summary.medianPeriodDuration - 1);
      predictions.add(
        PredictedPeriod(
          startDate: currentStart,
          endDate: end,
          cycleIndex: index,
        ),
      );
      currentStart = currentStart.addDays(summary.medianCycleLength);
      index++;
    }

    return predictions;
  }

  /// Evaluates the status of a specific calendar [date].
  ///
  /// Resolution order, most-grounded first:
  ///
  /// 1. **Logged period days** — a fact the user entered, not an estimate.
  /// 2. **Predicted future period days** — a forward projection.
  /// 3. **Retrospective phasing inside a completed cycle** — [date] sits
  ///    between two consecutive logged period starts, so the cycle's real
  ///    length is known and the phases are estimated backwards from the
  ///    known next start (see [_estimatePhase] and [nominalLutealLength]).
  /// 4. **The current cycle** — [date] is on or after the most recent
  ///    logged start, so the phases are estimated from the user's median
  ///    cycle length, which is the assumption step 3 does not have to make.
  /// 5. Otherwise [CyclePhase.none], meaning *no phase is known for this
  ///    day* — it is not a fifth phase, and callers must treat it as
  ///    "unknown" rather than render it. Days before the earliest logged
  ///    period start land here, as do days inside an implausible gap
  ///    between two logged starts (see [minPlausibleCycleLength]).
  ///
  /// Everything past step 1 is an **estimate**. Cycle phase here is
  /// training context only — it is not a fertility, ovulation-timing, or
  /// contraception signal, and carries no medical claim
  /// (`knowledge/domain/womens_health.md`).
  DayCycleStatus getDayStatus({
    required LocalDate date,
    required List<CycleRecord> records,
    required LocalDate today,
  }) {
    return _dayStatus(
      date: date,
      records: records,
      today: today,
      futurePeriods: projectFuturePeriods(records: records, today: today),
      summary: analyze(records: records, today: today),
      sortedRecords: List<CycleRecord>.from(records)
        ..sort((a, b) => a.periodStart.compareTo(b.periodStart)),
    );
  }

  /// The estimated [CyclePhase] of every day in `[start, end]` — inclusive
  /// on both ends — in one pass.
  ///
  /// Exactly [getDayStatus]'s resolution order and exactly its answers (both
  /// call the same private evaluator), but the three things that do not vary
  /// by day — [analyze], [projectFuturePeriods], and the sort of [records] —
  /// are computed once for the whole window instead of once per day. Calling
  /// [getDayStatus] in a loop re-sorts and re-analyzes [records] on every
  /// iteration, which turns painting a year of chart background into
  /// hundreds of redundant analyses; this is that loop written once, here,
  /// where the redundancy is visible.
  ///
  /// Days the engine cannot phase are **absent from the map** rather than
  /// present as [CyclePhase.none]: `none` means "no phase is known", and an
  /// absent key is how consumers in this codebase spell unknown. A [start]
  /// after [end] yields an empty map.
  ///
  /// Every value is an estimate on the same terms as [getDayStatus] — no
  /// fertility, ovulation-timing, or contraception claim
  /// (`knowledge/domain/womens_health.md`).
  Map<LocalDate, CyclePhase> phaseRange({
    required LocalDate start,
    required LocalDate end,
    required List<CycleRecord> records,
    required LocalDate today,
  }) {
    if (start.isAfter(end)) return const {};

    final futurePeriods = projectFuturePeriods(records: records, today: today);
    final summary = analyze(records: records, today: today);
    final sortedRecords = List<CycleRecord>.from(records)
      ..sort((a, b) => a.periodStart.compareTo(b.periodStart));

    final phases = <LocalDate, CyclePhase>{};
    for (var day = start; !day.isAfter(end); day = day.addDays(1)) {
      final phase = _dayStatus(
        date: day,
        records: records,
        today: today,
        futurePeriods: futurePeriods,
        summary: summary,
        sortedRecords: sortedRecords,
      ).phase;
      if (phase != CyclePhase.none) phases[day] = phase;
    }
    return phases;
  }

  /// [getDayStatus]'s body, with the per-window computations passed in so a
  /// caller phasing many days pays for them once. Not public: callers use
  /// [getDayStatus] for one day or [phaseRange] for a window, and neither
  /// can construct an inconsistent set of these arguments.
  DayCycleStatus _dayStatus({
    required LocalDate date,
    required List<CycleRecord> records,
    required LocalDate today,
    required List<PredictedPeriod> futurePeriods,
    required CyclePredictionSummary summary,
    required List<CycleRecord> sortedRecords,
  }) {
    // 1. Check if date falls in a logged period
    for (final r in records) {
      final end = r.periodEnd ?? (r.isOngoing ? today : r.periodStart);
      if (!date.isBefore(r.periodStart) && !date.isAfter(end)) {
        final dayNum = r.periodStart.difference(date) + 1;
        return DayCycleStatus(
          date: date,
          isLoggedPeriod: true,
          isPredictedPeriod: false,
          phase: CyclePhase.menstrual,
          cycleDayNumber: dayNum,
          associatedRecord: r,
        );
      }
    }

    // 2. Check future predictions
    for (final p in futurePeriods) {
      if (!date.isBefore(p.startDate) && !date.isAfter(p.endDate)) {
        final dayNum = p.startDate.difference(date) + 1;
        return DayCycleStatus(
          date: date,
          isLoggedPeriod: false,
          isPredictedPeriod: true,
          phase: CyclePhase.menstrual,
          cycleDayNumber: dayNum,
        );
      }
    }

    // 3. Retrospective phase estimation inside a completed cycle.
    final retrospective = _retrospectiveDayStatus(
      date: date,
      sortedRecords: sortedRecords,
      fallbackPeriodDuration: summary.medianPeriodDuration,
    );
    if (retrospective != null) {
      return retrospective;
    }

    // 4. Phase estimation for the current (ongoing) cycle.
    LocalDate? cycleAnchor;
    if (sortedRecords.isNotEmpty) {
      final lastStart = sortedRecords.last.periodStart;
      if (!date.isBefore(lastStart)) {
        cycleAnchor = lastStart;
      }
    }

    if (cycleAnchor != null) {
      final daysFromAnchor = cycleAnchor.difference(date);
      final cycleDay = (daysFromAnchor % summary.medianCycleLength) + 1;
      final estimate = _estimatePhase(
        cycleDay: cycleDay,
        cycleLength: summary.medianCycleLength,
        periodDuration: summary.medianPeriodDuration,
      );

      return DayCycleStatus(
        date: date,
        isLoggedPeriod: false,
        isPredictedPeriod: false,
        phase: estimate.phase,
        cycleDayNumber: cycleDay,
        isOvulationDay: estimate.isOvulationDay,
      );
    }

    // 5. No phase is known for this day.
    return DayCycleStatus(
      date: date,
      isLoggedPeriod: false,
      isPredictedPeriod: false,
      phase: CyclePhase.none,
    );
  }

  /// Estimates the phase of [date] when it falls inside a **completed**
  /// logged cycle — between two consecutive logged period starts in
  /// [sortedRecords] (ascending by [CycleRecord.periodStart]). Returns
  /// `null` when [date] is in no such cycle, leaving the caller to fall
  /// through to its own handling.
  ///
  /// A completed cycle is better grounded than a forward prediction: its
  /// real length is known, so no median has to be assumed, and the two
  /// endpoints that matter are both logged facts. Because the follicular
  /// phase absorbs nearly all cycle-length variation while the luteal
  /// phase holds near [nominalLutealLength] days, the boundaries are
  /// anchored backwards from the *next* logged start rather than forwards
  /// from this one — see [_estimatePhase], which is the same function the
  /// current-cycle path uses, so the two paths agree exactly on a cycle
  /// whose real length equals the predicted one.
  ///
  /// Two guards keep bad data from producing confident-looking phases:
  ///
  /// * An interval outside [minPlausibleCycleLength] to
  ///   [maxPlausibleCycleLength] is a logging gap, not a cycle, so nothing
  ///   in it is phased beyond its logged period days (which the caller has
  ///   already resolved).
  /// * The menstrual boundary uses the period's own **logged** duration
  ///   where there is one, so the estimate never contradicts a logged
  ///   period end by extending bleeding past it.
  ///
  /// Every day this resolves is still an estimate, and none of it is a
  /// fertility or ovulation-timing signal — see [getDayStatus].
  DayCycleStatus? _retrospectiveDayStatus({
    required LocalDate date,
    required List<CycleRecord> sortedRecords,
    required int fallbackPeriodDuration,
  }) {
    for (var i = 0; i < sortedRecords.length - 1; i++) {
      final record = sortedRecords[i];
      final start = record.periodStart;
      final nextStart = sortedRecords[i + 1].periodStart;

      // Half-open [start, nextStart): the next start belongs to the next
      // cycle, and these windows never overlap, so at most one matches.
      if (date.isBefore(start) || !date.isBefore(nextStart)) {
        continue;
      }

      final cycleLength = start.difference(nextStart);
      if (cycleLength < minPlausibleCycleLength ||
          cycleLength > maxPlausibleCycleLength) {
        return null;
      }

      final loggedEnd = record.periodEnd;
      final loggedDuration = loggedEnd == null
          ? null
          : start.difference(loggedEnd) + 1;
      final periodDuration =
          loggedDuration != null &&
              loggedDuration >= minPlausiblePeriodDuration &&
              loggedDuration <= maxPlausiblePeriodDuration
          ? loggedDuration
          : fallbackPeriodDuration;

      final cycleDay = start.difference(date) + 1;
      final estimate = _estimatePhase(
        cycleDay: cycleDay,
        cycleLength: cycleLength,
        periodDuration: periodDuration,
      );

      return DayCycleStatus(
        date: date,
        isLoggedPeriod: false,
        isPredictedPeriod: false,
        phase: estimate.phase,
        cycleDayNumber: cycleDay,
        isOvulationDay: estimate.isOvulationDay,
      );
    }
    return null;
  }

  /// The single phase-boundary model, shared by every estimating path so
  /// they cannot drift apart: [cycleDay] is 1-indexed from the period
  /// start, in a cycle of [cycleLength] days whose period lasted
  /// [periodDuration] days.
  ///
  /// The pivot is `max(periodDuration, cycleLength - nominalLutealLength)`,
  /// which is measured from the *end* of the cycle: the estimate places
  /// the phase turn about [nominalLutealLength] days before the next
  /// period, because that stretch is the physiologically stable one while
  /// the days before it stretch and shrink with cycle length. The `max`
  /// keeps the pivot from landing inside the period itself on a very short
  /// cycle.
  ///
  /// Every value returned here is an estimate, phrased for training
  /// context only — see [getDayStatus].
  ({CyclePhase phase, bool isOvulationDay}) _estimatePhase({
    required int cycleDay,
    required int cycleLength,
    required int periodDuration,
  }) {
    final pivotDay =
        math.max(periodDuration, cycleLength - nominalLutealLength) + 1;

    final CyclePhase phase;
    if (cycleDay <= periodDuration) {
      phase = CyclePhase.menstrual;
    } else if (cycleDay < pivotDay - 1) {
      phase = CyclePhase.follicular;
    } else if (cycleDay <= pivotDay + 1) {
      phase = CyclePhase.ovulatory;
    } else {
      phase = CyclePhase.luteal;
    }

    return (phase: phase, isOvulationDay: cycleDay == pivotDay);
  }

  int _calculateMedian(List<int> values) {
    if (values.isEmpty) return defaultCycleLength;
    final sorted = List<int>.from(values)..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[middle];
    } else {
      return ((sorted[middle - 1] + sorted[middle]) / 2).round();
    }
  }

  double _calculateStdDev(List<int> values) {
    if (values.length <= 1) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final sumSquaredDiffs = values.fold<double>(
      0,
      (sum, val) => sum + math.pow(val - mean, 2),
    );
    return math.sqrt(sumSquaredDiffs / values.length);
  }

  CycleConfidence _determineConfidence({
    required int cycleCount,
    required double stdDev,
  }) {
    if (cycleCount >= 4 && stdDev <= 3.5) {
      return CycleConfidence.high;
    } else if (cycleCount >= 2 && stdDev <= 6.0) {
      return CycleConfidence.moderate;
    } else {
      return CycleConfidence.low;
    }
  }
}
