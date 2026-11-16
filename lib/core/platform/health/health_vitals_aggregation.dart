import 'package:menfit_app/core/platform/health/health_vitals_snapshot.dart';

/// Pure aggregation for watch vitals. Plain values in, plain values out — no
/// plugin and no `dart:io`, so every rule here is unit-testable on any host.
/// `health_vitals_reader.dart` turns plugin data points into these inputs.

/// One instantaneous reading (heart rate, SpO2, HRV, respiratory rate).
typedef VitalReading = ({DateTime at, double value});

/// Sleep stage of one sample. Generic "asleep" is a stage-less asleep sample.
enum SleepStageKind { asleep, light, deep, rem, awake }

/// One sleep interval from one source. `stage` null marks a whole session
/// record (Health Connect `SLEEP_SESSION`); HealthKit only has stage samples.
typedef SleepSample = ({
  DateTime start,
  DateTime end,
  String source,
  SleepStageKind? stage,
});

/// Gap between stage samples that still counts as the same night. HealthKit
/// has no session record, so a night is rebuilt from contiguous samples.
const sleepClusterGap = Duration(hours: 1);

/// The reading with the latest timestamp inside `[from, to]`, ignoring
/// non-finite values. Several sources may report the same moment; any of
/// them is a true "latest", so no de-duplication is needed here.
VitalReading? latestReading(
  Iterable<VitalReading> readings, {
  required DateTime from,
  required DateTime to,
}) {
  VitalReading? best;
  for (final r in readings) {
    if (!r.value.isFinite || r.at.isBefore(from) || r.at.isAfter(to)) continue;
    if (best == null || r.at.isAfter(best.at)) best = r;
  }
  return best;
}

/// SpO2 as a 0–100 percentage. Health Connect reports 0–100; HealthKit's
/// `HKUnit.percent()` reports a 0–1 fraction. A real SpO2 of 1 % or less
/// does not exist, so anything ≤ 1 is a fraction.
double normaliseSpo2Percent(double value) => value <= 1 ? value * 100 : value;

/// The most recent sleep session ending in the 24 h before [now], or null.
///
/// De-duplication: when several sources (watch, phone, a sleep app) record
/// the same night, only one source is used — on Health Connect the session
/// whose source recorded asleep stages, then the one with the most asleep
/// time; on HealthKit the source with the most asleep time — so
/// overlapping nights are never added together. Within that source,
/// asleep time is the union of asleep intervals, so overlapping samples are
/// not double-counted either. Awake time is never counted as asleep.
SleepSummary? summariseSleep(
  List<SleepSample> samples, {
  required DateTime now,
}) {
  final windowStart = now.subtract(const Duration(hours: 24));
  bool endsInWindow(SleepSample s) =>
      s.end.isAfter(windowStart) && !s.end.isAfter(now);

  final sessions = [
    for (final s in samples)
      if (s.stage == null && endsInWindow(s) && s.end.isAfter(s.start)) s,
  ];
  final stages = [
    for (final s in samples)
      if (s.stage != null && s.end.isAfter(s.start)) s,
  ];

  DateTime start;
  DateTime end;
  List<SleepSample> used;
  if (sessions.isNotEmpty) {
    // Among the sessions of the most recent night, prefer a source that
    // recorded asleep stages (a watch) over a stage-less one (a phone's
    // "in bed" span), then the most asleep time — the same one-source rule
    // as the HealthKit path below.
    SleepSample? best;
    var bestUsed = const <SleepSample>[];
    var bestStaged = false;
    var bestAsleep = Duration.zero;
    for (final session in _latestCluster(sessions)) {
      final sessionStages = [
        for (final s in stages)
          if (s.source == session.source &&
              s.end.isAfter(session.start) &&
              s.start.isBefore(session.end))
            _clip(s, session.start, session.end),
      ];
      final stagedAsleep = _asleepUnion(sessionStages);
      final staged = stagedAsleep > Duration.zero;
      final asleep = staged
          ? stagedAsleep
          : session.end.difference(session.start);
      if (best == null ||
          (staged && !bestStaged) ||
          (staged == bestStaged && asleep > bestAsleep)) {
        best = session;
        bestUsed = sessionStages;
        bestStaged = staged;
        bestAsleep = asleep;
      }
    }
    start = best!.start;
    end = best.end;
    used = bestUsed;
  } else {
    final cluster = _latestCluster(stages.where(endsInWindow).toList());
    if (cluster.isEmpty) return null;
    final bySource = <String, List<SleepSample>>{};
    for (final s in cluster) {
      (bySource[s.source] ??= []).add(s);
    }
    used = bySource.values.reduce(
      (a, b) => _asleepUnion(b) > _asleepUnion(a) ? b : a,
    );
    start = used.map((s) => s.start).reduce((a, b) => b.isBefore(a) ? b : a);
    end = used.map((s) => s.end).reduce((a, b) => b.isAfter(a) ? b : a);
  }

  var asleep = _asleepUnion(used);
  if (asleep == Duration.zero) {
    // A Health Connect session with no stages at all: the session is the
    // only statement the source made, so its length is the sleep time.
    if (sessions.isEmpty || used.isNotEmpty) return null;
    asleep = end.difference(start);
  }

  Duration? sumOf(SleepStageKind kind) {
    final matching = used.where((s) => s.stage == kind);
    if (matching.isEmpty) return null;
    return matching.fold<Duration>(
      Duration.zero,
      (total, s) => total + s.end.difference(s.start),
    );
  }

  final hasStages = used.any(
    (s) =>
        s.stage == SleepStageKind.light ||
        s.stage == SleepStageKind.deep ||
        s.stage == SleepStageKind.rem,
  );
  return SleepSummary(
    start: start,
    end: end,
    asleep: asleep,
    deep: hasStages ? sumOf(SleepStageKind.deep) ?? Duration.zero : null,
    light: hasStages ? sumOf(SleepStageKind.light) ?? Duration.zero : null,
    rem: hasStages ? sumOf(SleepStageKind.rem) ?? Duration.zero : null,
    awake: sumOf(SleepStageKind.awake),
  );
}

SleepSample _clip(SleepSample s, DateTime start, DateTime end) => (
  start: s.start.isBefore(start) ? start : s.start,
  end: s.end.isAfter(end) ? end : s.end,
  source: s.source,
  stage: s.stage,
);

/// Samples belonging to the night that ends latest: walk back from the
/// latest-ending sample, joining any sample within [sleepClusterGap].
List<SleepSample> _latestCluster(List<SleepSample> samples) {
  if (samples.isEmpty) return const [];
  final sorted = [...samples]..sort((a, b) => b.end.compareTo(a.end));
  var clusterStart = sorted.first.start;
  final cluster = <SleepSample>[];
  for (final s in sorted) {
    if (s.end.isBefore(clusterStart.subtract(sleepClusterGap))) break;
    cluster.add(s);
    if (s.start.isBefore(clusterStart)) clusterStart = s.start;
  }
  return cluster;
}

/// Total length of the union of asleep-kind intervals (awake excluded).
Duration _asleepUnion(List<SleepSample> samples) {
  final asleep = [
    for (final s in samples)
      if (s.stage != null && s.stage != SleepStageKind.awake) s,
  ]..sort((a, b) => a.start.compareTo(b.start));
  var total = Duration.zero;
  DateTime? runStart;
  DateTime? runEnd;
  for (final s in asleep) {
    if (runEnd == null || s.start.isAfter(runEnd)) {
      if (runStart != null) total += runEnd!.difference(runStart);
      runStart = s.start;
      runEnd = s.end;
    } else if (s.end.isAfter(runEnd)) {
      runEnd = s.end;
    }
  }
  if (runStart != null) total += runEnd!.difference(runStart);
  return total;
}
