import 'package:menfit_app/features/activity/domain/activity.dart';

/// Sealed hierarchy of cross-platform messages passed between MenFit (phone)
/// and wearable companions (WearOS, Apple Watch / watchOS).
sealed class WatchMessage {
  const WatchMessage();

  Map<String, dynamic> toJson();

  static WatchMessage? fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'command' => WatchCommand.fromJson(json),
      'telemetry' => WatchTelemetry.fromJson(json),
      'wrist_workout' => WatchWristWorkout.fromJson(json),
      _ => null,
    };
  }
}

/// Commands sent between phone and watch (start, pause, resume, stop, lap).
class WatchCommand extends WatchMessage {
  const WatchCommand({
    required this.action,
    required this.timestamp,
    this.workoutType,
  });

  factory WatchCommand.fromJson(Map<String, dynamic> json) {
    return WatchCommand(
      action: json['action'] as String? ?? 'start',
      timestamp: DateTime.parse(json['timestamp'] as String).toUtc(),
      workoutType: json['workoutType'] != null
          ? ActivityType.fromStorage(json['workoutType'] as String)
          : null,
    );
  }

  /// Action verb: 'start', 'pause', 'resume', 'stop', 'lap'.
  final String action;

  /// UTC timestamp of the command.
  final DateTime timestamp;

  /// Target workout type for 'start' commands.
  final ActivityType? workoutType;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'command',
    'action': action,
    'timestamp': timestamp.toIso8601String(),
    if (workoutType != null) 'workoutType': workoutType!.toStorage(),
  };
}

/// Live telemetry streaming real-time metrics during a workout.
class WatchTelemetry extends WatchMessage {
  const WatchTelemetry({
    required this.timestamp,
    this.heartRate,
    this.cadence,
    this.paceSecondsPerKm,
    this.distanceMeters,
    this.elapsedSeconds,
  });

  factory WatchTelemetry.fromJson(Map<String, dynamic> json) {
    return WatchTelemetry(
      timestamp: DateTime.parse(json['timestamp'] as String).toUtc(),
      heartRate: (json['heartRate'] as num?)?.toInt(),
      cadence: (json['cadence'] as num?)?.toInt(),
      paceSecondsPerKm: (json['paceSecondsPerKm'] as num?)?.toDouble(),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      elapsedSeconds: (json['elapsedSeconds'] as num?)?.toInt(),
    );
  }

  final DateTime timestamp;
  final int? heartRate;
  final int? cadence;
  final double? paceSecondsPerKm;
  final double? distanceMeters;
  final int? elapsedSeconds;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'telemetry',
    'timestamp': timestamp.toIso8601String(),
    if (heartRate != null) 'heartRate': heartRate,
    if (cadence != null) 'cadence': cadence,
    if (paceSecondsPerKm != null) 'paceSecondsPerKm': paceSecondsPerKm,
    if (distanceMeters != null) 'distanceMeters': distanceMeters,
    if (elapsedSeconds != null) 'elapsedSeconds': elapsedSeconds,
  };
}

/// A GPS/HR fix recorded by the watch while running standalone.
class WatchWristSample {
  const WatchWristSample({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.elevationMeters,
    this.heartRate,
  });

  factory WatchWristSample.fromJson(Map<String, dynamic> json) {
    return WatchWristSample(
      timestamp: DateTime.parse(json['timestamp'] as String).toUtc(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      elevationMeters: (json['elevationMeters'] as num?)?.toDouble(),
      heartRate: (json['heartRate'] as num?)?.toInt(),
    );
  }

  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double? elevationMeters;
  final int? heartRate;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    if (elevationMeters != null) 'elevationMeters': elevationMeters,
    if (heartRate != null) 'heartRate': heartRate,
  };
}

/// A completed standalone wrist-recorded workout payload transferred from
/// the watch.
class WatchWristWorkout extends WatchMessage {
  const WatchWristWorkout({
    required this.externalId,
    required this.activityType,
    required this.startedAt,
    required this.endedAt,
    required this.totalDistanceMeters,
    this.caloriesBurnedKcal,
    this.avgHeartRate,
    this.avgCadence,
    this.source = 'Watch Companion',
    this.samples = const [],
  });

  factory WatchWristWorkout.fromJson(Map<String, dynamic> json) {
    final rawSamples = json['samples'] as List<dynamic>? ?? const [];
    return WatchWristWorkout(
      externalId: json['externalId'] as String,
      activityType: ActivityType.fromStorage(
        json['activityType'] as String? ?? 'run',
      ),
      startedAt: DateTime.parse(json['startedAt'] as String).toUtc(),
      endedAt: DateTime.parse(json['endedAt'] as String).toUtc(),
      totalDistanceMeters:
          (json['totalDistanceMeters'] as num?)?.toDouble() ?? 0.0,
      caloriesBurnedKcal: (json['caloriesBurnedKcal'] as num?)?.toDouble(),
      avgHeartRate: (json['avgHeartRate'] as num?)?.toInt(),
      avgCadence: (json['avgCadence'] as num?)?.toInt(),
      source: json['source'] as String? ?? 'Watch Companion',
      samples: rawSamples
          .map((s) => WatchWristSample.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  final String externalId;
  final ActivityType activityType;
  final DateTime startedAt;
  final DateTime endedAt;
  final double totalDistanceMeters;
  final double? caloriesBurnedKcal;
  final int? avgHeartRate;
  final int? avgCadence;
  final String source;
  final List<WatchWristSample> samples;

  Duration get duration => endedAt.difference(startedAt);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'wrist_workout',
    'externalId': externalId,
    'activityType': activityType.toStorage(),
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt.toIso8601String(),
    'totalDistanceMeters': totalDistanceMeters,
    if (caloriesBurnedKcal != null) 'caloriesBurnedKcal': caloriesBurnedKcal,
    if (avgHeartRate != null) 'avgHeartRate': avgHeartRate,
    if (avgCadence != null) 'avgCadence': avgCadence,
    'source': source,
    'samples': samples.map((s) => s.toJson()).toList(),
  };
}
