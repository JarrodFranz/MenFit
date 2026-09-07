import 'package:menfit_app/features/activity/domain/activity.dart';

/// A completed workout session recorded by an external fitness wearable
/// (such as Garmin, Apple Watch, Pixel Watch, or Galaxy Watch) and retrieved
/// via Health Connect or Apple HealthKit.
class HealthWorkoutSession {
  const HealthWorkoutSession({
    required this.externalId,
    required this.activityType,
    required this.title,
    required this.startedAt,
    required this.endedAt,
    this.distanceMeters,
    this.totalEnergyKcal,
    this.avgHeartRate,
    this.sourceName = 'Health Platform',
    this.sourceId,
  });

  /// Unique external session ID or UUID from Health Connect / HealthKit.
  final String externalId;

  /// The mapped FemFit [ActivityType] for this session.
  final ActivityType activityType;

  /// Descriptive title (e.g. "Garmin Outdoor Run", "Apple Watch Walk").
  final String title;

  /// Start timestamp (UTC).
  final DateTime startedAt;

  /// End timestamp (UTC).
  final DateTime endedAt;

  /// Total distance in meters, if recorded.
  final double? distanceMeters;

  /// Total active energy expended in kcal, if recorded.
  final double? totalEnergyKcal;

  /// Average heart rate during workout, if recorded.
  final int? avgHeartRate;

  /// Human-readable source or app package name
  /// (e.g. "Garmin Connect", "Apple Watch").
  final String sourceName;

  /// Platform source identifier (e.g. "com.garmin.android.apps.connectmobile").
  final String? sourceId;

  /// Total workout duration.
  Duration get duration {
    final diff = endedAt.difference(startedAt);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Whether this session was recorded by a Garmin watch.
  bool get isGarmin {
    final name = sourceName.toLowerCase();
    final id = (sourceId ?? '').toLowerCase();
    return name.contains('garmin') || id.contains('garmin');
  }

  /// Whether this session was recorded by an Apple Watch.
  bool get isAppleWatch {
    final name = sourceName.toLowerCase();
    final id = (sourceId ?? '').toLowerCase();
    return name.contains('apple') || id.contains('apple');
  }

  /// Whether this session was recorded by a WearOS / Android watch.
  bool get isWearOs {
    final name = sourceName.toLowerCase();
    final id = (sourceId ?? '').toLowerCase();
    return name.contains('wear') ||
        id.contains('wear') ||
        name.contains('pixel') ||
        name.contains('galaxy') ||
        name.contains('samsung');
  }
}
