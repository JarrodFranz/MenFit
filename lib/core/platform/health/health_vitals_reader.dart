import 'package:health/health.dart';
import 'package:menfit_app/core/platform/health/health_vitals_aggregation.dart';
import 'package:menfit_app/core/platform/health/health_vitals_snapshot.dart';

/// Reads watch vitals through the `health` plugin. io-only: imported by
/// `health_platform_io.dart`, never by web-reachable code.
///
/// Every type is queried in its **own** call and its own `try`:
/// `getHealthDataFromTypes` loops over its types and one failure (a missing
/// grant, a type the device lacks) would otherwise blank every metric.
/// Errors are swallowed without logging — health platform exception text
/// can carry the very values this app must never write down.
class HealthVitalsReader {
  HealthVitalsReader(this._health, {required this.android});

  final Health _health;

  /// Health Connect when true, HealthKit when false.
  final bool android;

  /// The vitals types requested, READ only, in one authorisation batch.
  /// All sleep types map to one platform grant (`READ_SLEEP` / HealthKit
  /// sleep analysis); listing them is harmless and keeps each one readable.
  static List<HealthDataType> requestTypes({required bool android}) => [
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.RESPIRATORY_RATE,
    if (android) HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    if (!android) HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    if (android) HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_AWAKE,
  ];

  /// One type per distinct Health Connect permission, for the grant check.
  static const List<HealthDataType> androidPermissionCheckTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.SLEEP_SESSION,
  ];

  static const Map<HealthDataType, SleepStageKind> _sleepStageTypes = {
    HealthDataType.SLEEP_ASLEEP: SleepStageKind.asleep,
    HealthDataType.SLEEP_LIGHT: SleepStageKind.light,
    HealthDataType.SLEEP_DEEP: SleepStageKind.deep,
    HealthDataType.SLEEP_REM: SleepStageKind.rem,
    HealthDataType.SLEEP_AWAKE: SleepStageKind.awake,
  };

  /// Reads every metric for [now]. Never throws.
  Future<HealthVitalsSnapshot> read(DateTime now) async {
    const day = Duration(hours: 24);
    const twoDays = Duration(hours: 48);
    final hrvType = android
        ? HealthDataType.HEART_RATE_VARIABILITY_RMSSD
        : HealthDataType.HEART_RATE_VARIABILITY_SDNN;

    // Sequential on purpose — see the adapter contract on channel calls.
    // Heart rate tries the last hour first: a watch can write thousands of
    // samples a day and the latest one is all that is shown.
    final hr = await _latest(HealthDataType.HEART_RATE, now, [
      const Duration(hours: 1),
      day,
    ]);
    final resting = await _latest(HealthDataType.RESTING_HEART_RATE, now, [
      twoDays,
    ]);
    final spo2 = await _latest(HealthDataType.BLOOD_OXYGEN, now, [day]);
    final rr = await _latest(HealthDataType.RESPIRATORY_RATE, now, [day]);
    final hrv = await _latest(hrvType, now, [twoDays]);
    final sleep = summariseSleep(await _sleepSamples(now), now: now);

    return HealthVitalsSnapshot(
      readAt: now,
      latestHeartRateBpm: hr?.value,
      latestHeartRateAt: hr?.at,
      restingHeartRateBpm: resting?.value,
      restingHeartRateAt: resting?.at,
      bloodOxygenPercent: spo2 == null
          ? null
          : normaliseSpo2Percent(spo2.value),
      bloodOxygenAt: spo2?.at,
      respiratoryRate: rr?.value,
      respiratoryRateAt: rr?.at,
      hrvMs: hrv?.value,
      hrvKind: hrv == null ? null : (android ? HrvKind.rmssd : HrvKind.sdnn),
      hrvAt: hrv?.at,
      sleep: sleep,
      source: android ? 'Health Connect' : 'Apple Health',
    );
  }

  /// Latest reading of [type], trying each lookback in turn until one has
  /// data.
  Future<VitalReading?> _latest(
    HealthDataType type,
    DateTime now,
    List<Duration> lookbacks,
  ) async {
    for (final lookback in lookbacks) {
      final from = now.subtract(lookback);
      final points = await _points(type, from, now);
      final latest = latestReading(
        [
          for (final p in points)
            if (p.value case final NumericHealthValue v)
              (at: p.dateTo, value: v.numericValue.toDouble()),
        ],
        from: from,
        to: now,
      );
      if (latest != null) return latest;
    }
    return null;
  }

  /// Sleep sessions (Health Connect) and stage samples (both) that could
  /// end in the last 24 h. The query starts 36 h back so a session that
  /// began the previous evening is returned whole.
  Future<List<SleepSample>> _sleepSamples(DateTime now) async {
    final from = now.subtract(const Duration(hours: 36));
    final samples = <SleepSample>[];
    void addAll(List<HealthDataPoint> points, SleepStageKind? stage) {
      for (final p in points) {
        samples.add((
          // Interval from the timestamps: HealthKit's `value` is a
          // category code, not a duration.
          start: p.dateFrom,
          end: p.dateTo,
          // Health Connect sends an empty source id and the package name
          // as source name, for sessions and stages alike.
          source: p.sourceId.isNotEmpty ? p.sourceId : p.sourceName,
          stage: stage,
        ));
      }
    }

    if (android) {
      addAll(await _points(HealthDataType.SLEEP_SESSION, from, now), null);
      addAll(
        await _points(HealthDataType.SLEEP_AWAKE_IN_BED, from, now),
        SleepStageKind.awake,
      );
    }
    for (final entry in _sleepStageTypes.entries) {
      addAll(await _points(entry.key, from, now), entry.value);
    }
    return samples;
  }

  Future<List<HealthDataPoint>> _points(
    HealthDataType type,
    DateTime from,
    DateTime to,
  ) async {
    try {
      return await _health.getHealthDataFromTypes(
        types: [type],
        startTime: from,
        endTime: to,
      );
    } on Object catch (_) {
      return const [];
    }
  }
}
