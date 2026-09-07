import 'package:menfit_app/core/domain/local_date.dart';

/// A snapshot of health data read from a connected fitness device / health
/// platform.
class HealthDataSnapshot {
  const HealthDataSnapshot({
    required this.date,
    required this.steps,
    required this.lastSyncedAt,
    this.activeCaloriesKcal,
    this.source = 'Fitness Tracker',
  });

  /// Empty / zero snapshot when no data is present.
  HealthDataSnapshot.empty(this.date)
    : steps = 0,
      activeCaloriesKcal = null,
      lastSyncedAt = DateTime.now(),
      source = 'Fitness Tracker';

  /// The calendar date for this snapshot.
  final LocalDate date;

  /// Aggregate step count for the date.
  final int steps;

  /// Active calories burned in kcal (if reported by the health platform).
  final double? activeCaloriesKcal;

  /// Timestamp when data was retrieved from the health platform.
  final DateTime lastSyncedAt;

  /// Device / platform source label (e.g. "Health Connect", "Apple Health").
  final String source;
}

/// One calendar day's step total as reported by the health platform.
///
/// Deliberately **steps only**, replacing the earlier `DailyHealthRecord`
/// (which carried active calories too and was never read by anything). The
/// reason is cost, not tidiness: reading energy for a day takes two further
/// platform-channel calls on top of the step query, so a 35-day window would
/// have cost ~105 round-trips to populate a step chart. The one caller of a
/// ranged read is the step-history sync
/// (`features/steps/steps_providers.dart`); today's energy figure still
/// comes from [HealthDataSnapshot], which is a single day.
class DailyStepTotal {
  const DailyStepTotal({
    required this.date,
    required this.steps,
    this.source,
  });

  /// The user-local calendar day.
  final LocalDate date;

  /// Steps accrued on [date]. Zero is a real reported value; a day the
  /// platform could not answer for is **omitted** from the result list
  /// rather than reported as zero.
  final int steps;

  /// The platform's human-readable source label (`'Health Connect'`,
  /// `'Apple Health'`), or null when it could not be named. Never a device
  /// identifier.
  final String? source;
}
