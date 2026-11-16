/// Which heart-rate-variability statistic a reading is.
///
/// Health Connect stores RMSSD and HealthKit stores SDNN. They are different
/// statistics and must never be compared or charted together.
enum HrvKind { rmssd, sdnn }

/// The most recent sleep session ending in the read window.
class SleepSummary {
  const SleepSummary({
    required this.start,
    required this.end,
    required this.asleep,
    this.deep,
    this.light,
    this.rem,
    this.awake,
  });

  final DateTime start;
  final DateTime end;

  /// Time asleep. Awake time inside the session is excluded.
  final Duration asleep;

  /// Stage durations; null when the source recorded no stages.
  final Duration? deep;
  final Duration? light;
  final Duration? rem;
  final Duration? awake;

  // S2/S3: never print values.
  @override
  String toString() => 'SleepSummary(<redacted>)';
}

/// Read-on-demand watch metrics. Never persisted. [toString] prints no values.
///
/// Every metric is independently nullable: null means the platform had no
/// reading in its window, or the read failed or was not permitted.
class HealthVitalsSnapshot {
  const HealthVitalsSnapshot({
    required this.readAt,
    this.restingHeartRateBpm,
    this.restingHeartRateAt,
    this.latestHeartRateBpm,
    this.latestHeartRateAt,
    this.bloodOxygenPercent,
    this.bloodOxygenAt,
    this.sleep,
    this.hrvMs,
    this.hrvKind,
    this.hrvAt,
    this.respiratoryRate,
    this.respiratoryRateAt,
    this.source,
  });

  /// When the read was made.
  final DateTime readAt;

  final double? restingHeartRateBpm;
  final DateTime? restingHeartRateAt;

  final double? latestHeartRateBpm;
  final DateTime? latestHeartRateAt;

  /// SpO2 normalised to 0–100 (HealthKit reports a 0–1 fraction).
  final double? bloodOxygenPercent;
  final DateTime? bloodOxygenAt;

  final SleepSummary? sleep;

  /// HRV in milliseconds; read [hrvKind] before showing it.
  final double? hrvMs;
  final HrvKind? hrvKind;
  final DateTime? hrvAt;

  /// Breaths per minute.
  final double? respiratoryRate;
  final DateTime? respiratoryRateAt;

  /// Platform label (`'Health Connect'`, `'Apple Health'`). Never a device id.
  final String? source;

  /// True when every metric is null.
  bool get isEmpty =>
      restingHeartRateBpm == null &&
      latestHeartRateBpm == null &&
      bloodOxygenPercent == null &&
      sleep == null &&
      hrvMs == null &&
      respiratoryRate == null;

  // S2/S3: never print values.
  @override
  String toString() => 'HealthVitalsSnapshot(<redacted>)';
}
