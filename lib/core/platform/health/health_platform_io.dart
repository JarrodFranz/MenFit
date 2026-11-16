import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:health/health.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/platform/health/health_data_snapshot.dart';
import 'package:menfit_app/core/platform/health/health_platform_adapter.dart';
import 'package:menfit_app/core/platform/health/health_vitals_reader.dart';
import 'package:menfit_app/core/platform/health/health_vitals_snapshot.dart';
import 'package:menfit_app/core/platform/health/health_workout_session.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

HealthPlatformAdapter createDefaultHealthAdapter() => IoHealthPlatformAdapter();

/// Real implementation of [HealthPlatformAdapter] using the `health` plugin
/// for Android (Health Connect) and iOS (Apple HealthKit).
class IoHealthPlatformAdapter implements HealthPlatformAdapter {
  IoHealthPlatformAdapter({Health? healthInstance})
    : _health = healthInstance ?? Health();

  final Health _health;

  static const List<HealthDataType> _commonDataTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.WORKOUT,
  ];

  /// Every type requested, per platform. `DISTANCE_DELTA` is Android-only
  /// (HealthKit has no such type and the plugin throws for it on iOS); on
  /// Android it is mandatory for workouts — see [workoutReadTypes].
  static List<HealthDataType> get _dataTypes => [
    ..._commonDataTypes,
    if (Platform.isAndroid) HealthDataType.DISTANCE_DELTA,
  ];

  /// The types a Health Connect / HealthKit workout read depends on.
  ///
  /// On Android, `health 13.3.2`'s `handleWorkoutData` reads
  /// `DistanceRecord` (plus total calories and steps) inside every
  /// `ExerciseSessionRecord` window, with no permission check: a missing
  /// distance grant throws a `SecurityException`, which the plugin turns
  /// into an **empty list** for the whole WORKOUT query. So workouts are
  /// only readable when all of these are granted.
  @visibleForTesting
  static List<HealthDataType> workoutReadTypes({required bool android}) => [
    HealthDataType.WORKOUT,
    if (android) ...[
      HealthDataType.DISTANCE_DELTA,
      HealthDataType.TOTAL_CALORIES_BURNED,
      HealthDataType.STEPS,
    ],
  ];

  @override
  Future<bool> isSupported() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return false;
    }
    try {
      if (Platform.isAndroid) {
        final status = await _health.getHealthConnectSdkStatus();
        return status == HealthConnectSdkStatus.sdkAvailable;
      }
      return true;
    } on Object catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      // Short-circuiting OR: on Android each term is a real Health Connect
      // round-trip, and the common case (steps granted) answers on the
      // first.
      return await hasStepsPermission() ||
          await _hasReadPermission(HealthDataType.ACTIVE_ENERGY_BURNED) ||
          await _hasReadPermission(HealthDataType.TOTAL_CALORIES_BURNED) ||
          await _hasReadPermission(HealthDataType.WORKOUT);
    } on Object catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasStepsPermission() => _hasReadPermission(HealthDataType.STEPS);

  @override
  Future<bool?> hasWorkoutPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    // HealthKit never discloses read grants; preserve unknown so explicit
    // workout sync can request authorization on its first use.
    if (Platform.isIOS) return null;
    for (final type in workoutReadTypes(android: Platform.isAndroid)) {
      if (!await _hasReadPermission(type)) return false;
    }
    return true;
  }

  /// READ authorization for one data type, with the platform's
  /// "unknown" answer resolved per platform.
  ///
  /// ## Why `null` is treated as granted on iOS, and denied on Android
  ///
  /// `Health.hasPermissions` returns `bool?`. Android (Health Connect)
  /// answers truthfully, so `null` there is an anomaly and the cautious
  /// reading is "not granted".
  ///
  /// **iOS returns `null` for every read query, always** — verified in the
  /// plugin source (`HealthDataOperations.hasPermissions` -> `hasPermission`
  /// returns `nil` for `access == 0`). Apple does not disclose read
  /// authorization, because the answer would itself leak whether the user
  /// has data of that type. So on iOS `null` means *unknown*, not *denied*,
  /// and reading it as denied would make every health feature permanently
  /// unavailable on iOS however many times the user granted access.
  ///
  /// Treating unknown as granted on iOS is safe **because the read itself is
  /// the real gate**: with access denied, `HKStatisticsCollectionQuery`
  /// fails, the plugin returns a `STEPS_ERROR` `FlutterError`, and
  /// `_stepsForDay` turns that into `null` — an **omitted** day. It can
  /// therefore never fabricate a zero for a day the app was not allowed to
  /// read (`knowledge/decisions/013_local_step_history.md`). What it costs
  /// is that on iOS a denied grant and a genuinely empty window are
  /// indistinguishable; the platform makes that unavoidable, and no honest
  /// alternative exists.
  Future<bool> _hasReadPermission(HealthDataType type) async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final granted = await _health.hasPermissions(
        [type],
        permissions: [HealthDataAccess.READ],
      );
      return granted ?? Platform.isIOS;
    } on Object catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final types = _dataTypes;
      final granted = await _health.requestAuthorization(
        types,
        permissions: [for (final _ in types) HealthDataAccess.READ],
      );
      return granted;
    } on Object catch (_) {
      return false;
    }
  }

  @override
  Future<HealthDataSnapshot?> getSnapshotForDate(LocalDate date) async {
    if (!Platform.isAndroid && !Platform.isIOS) return null;

    final startOfDay = DateTime(date.year, date.month, date.day);
    // Next local midnight, built from calendar fields (so it normalises
    // month/year overflow and lands correctly across a DST transition) —
    // the *same* boundary `_stepsForDay` uses for the stored history. It
    // was 23:59:59 here, which silently excluded the final second of the
    // day: today's live snapshot and today's stored row could then disagree
    // over a step taken at 23:59:59.4, and a card and a chart showing
    // different numbers for the same day is exactly the kind of discrepancy
    // nobody can debug later.
    final endOfDay = DateTime(date.year, date.month, date.day + 1);

    try {
      final hasPerm = await hasPermissions();
      if (!hasPerm) return null;

      int? steps;
      try {
        steps = await _health.getTotalStepsInInterval(startOfDay, endOfDay);
      } on Object catch (_) {}

      var totalEnergyKcal = 0.0;
      var hasEnergy = false;
      var isGarmin = false;

      // 1. Try querying Active Energy Burned
      try {
        final activeEnergyData = await _health.getHealthDataFromTypes(
          types: [HealthDataType.ACTIVE_ENERGY_BURNED],
          startTime: startOfDay,
          endTime: endOfDay,
        );
        for (final point in activeEnergyData) {
          final src = point.sourceName.toLowerCase();
          final srcId = point.sourceId.toLowerCase();
          if (src.contains('garmin') || srcId.contains('garmin')) {
            isGarmin = true;
          }
          final value = point.value;
          if (value is NumericHealthValue) {
            totalEnergyKcal += value.numericValue.toDouble();
            hasEnergy = true;
          }
        }
      } on Object catch (_) {}

      // 2. If no active energy was returned, check Total Calories Burned
      if (!hasEnergy) {
        try {
          final totalEnergyData = await _health.getHealthDataFromTypes(
            types: [HealthDataType.TOTAL_CALORIES_BURNED],
            startTime: startOfDay,
            endTime: endOfDay,
          );
          for (final point in totalEnergyData) {
            final src = point.sourceName.toLowerCase();
            final srcId = point.sourceId.toLowerCase();
            if (src.contains('garmin') || srcId.contains('garmin')) {
              isGarmin = true;
            }
            final value = point.value;
            if (value is NumericHealthValue) {
              totalEnergyKcal += value.numericValue.toDouble();
              hasEnergy = true;
            }
          }
        } on Object catch (_) {}
      }

      final platformLabel = isGarmin
          ? 'Garmin Connect'
          : (Platform.isAndroid ? 'Health Connect' : 'Apple Health');

      return HealthDataSnapshot(
        date: date,
        steps: steps ?? 0,
        activeCaloriesKcal: hasEnergy ? totalEnergyKcal : null,
        lastSyncedAt: DateTime.now(),
        source: platformLabel,
      );
    } on Object catch (_) {
      return null;
    }
  }

  /// One step total per calendar day, read **sequentially**, one
  /// `getTotalStepsInInterval` call per day.
  ///
  /// ## Why not the plugin's single ranged call
  ///
  /// `health 13.3.2` does expose one — `getHealthIntervalDataFromTypes(...,
  /// interval: 86400)` — and it really is a single platform-channel call on
  /// both platforms. It is not used, because on both platforms the bucketing
  /// is a **fixed-duration slicer anchored at the range start**, not a
  /// calendar-day grouping: Android builds an
  /// `AggregateGroupByDurationRequest` with
  /// `timeRangeSlicer = Duration.ofSeconds(interval)`, and iOS an
  /// `HKStatisticsCollectionQuery` whose `intervalComponents` sets
  /// `second = interval`. A DST transition anywhere inside the window
  /// therefore shifts every subsequent bucket an hour off the local calendar
  /// day and silently misattributes the steps either side of it — and the
  /// user of this data is a day-by-day chart, where a silent one-hour
  /// smear is exactly the error that would never be noticed. Android's
  /// aggregate path also reports an internal exception as
  /// `result.success(null)`, which reaches Dart as an empty list
  /// indistinguishable from "they took no steps".
  ///
  /// Passing real local midnights (`DateTime(y, m, d)` to
  /// `DateTime(y, m, d + 1)`, which normalises the month/year overflow and
  /// stays correct across DST because it is built from local calendar
  /// fields) makes each day exact, at the cost of one call per day. A 35-day
  /// window is 36 channel round-trips including the permission check, run
  /// one after another — see the adapter contract for why they are never
  /// issued concurrently.
  ///
  /// The permission check happens **once** here rather than once per day, as
  /// it would if this looped over [getSnapshotForDate]; that (plus dropping
  /// the two energy queries per day, which nothing reads over a range) is
  /// what takes the window from ~140 calls to 36.
  @override
  Future<List<DailyStepTotal>> getDailyStepTotals(
    LocalDate start,
    LocalDate end,
  ) async {
    if (!Platform.isAndroid && !Platform.isIOS) return const [];
    if (start.compareTo(end) > 0) return const [];

    try {
      // Steps-specific, not the OR in `hasPermissions`: a user who granted
      // only active energy must not be walked through a month of step
      // queries that can only come back empty.
      if (!await hasStepsPermission()) return const [];
    } on Object catch (_) {
      return const [];
    }

    final sourceLabel = Platform.isAndroid ? 'Health Connect' : 'Apple Health';
    final totals = <DailyStepTotal>[];
    var current = start;

    while (current.compareTo(end) <= 0) {
      final steps = await _stepsForDay(current);
      if (steps != null) {
        totals.add(
          DailyStepTotal(date: current, steps: steps, source: sourceLabel),
        );
      }
      current = current.addDays(1);
    }

    return totals;
  }

  /// Steps between local midnight on [day] and local midnight the next day,
  /// or null if the platform could not answer (which is reported as an
  /// absent day, never as zero).
  Future<int?> _stepsForDay(LocalDate day) async {
    final startOfDay = DateTime(day.year, day.month, day.day);
    // `DateTime(y, m, d + 1)` rather than `.add(Duration(days: 1))`: the
    // former is built from calendar fields and normalises month/year
    // overflow, so it lands on the next local midnight even across a DST
    // transition; the latter adds exactly 24 hours and would land at 23:00
    // or 01:00 on those two days a year.
    final endOfDay = DateTime(day.year, day.month, day.day + 1);
    try {
      return await _health.getTotalStepsInInterval(startOfDay, endOfDay);
    } on Object catch (_) {
      // S2: swallowed without logging - the exception message from a health
      // platform can carry the very values this app must never write down.
      return null;
    }
  }

  @override
  Future<List<HealthWorkoutSession>> getCompletedWorkouts({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) return const [];
    if (start.isAfter(end)) return const [];

    try {
      // Workout-specific, not the OR in `hasPermissions`: with steps granted
      // but exercise/distance not, the read below returns an empty list that
      // is indistinguishable from "no workouts".
      if (await hasWorkoutPermission() == false) return const [];

      final dataPoints = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: start,
        endTime: end,
      );

      final sessions = <HealthWorkoutSession>[];
      for (final dp in dataPoints) {
        final val = dp.value;
        var workoutType = HealthWorkoutActivityType.OTHER;
        double? distance;
        double? energy;

        if (val is WorkoutHealthValue) {
          workoutType = val.workoutActivityType;
          if (val.totalDistance != null) {
            distance = val.totalDistance!.toDouble();
          }
          if (val.totalEnergyBurned != null) {
            energy = val.totalEnergyBurned!.toDouble();
          }
        } else if (dp.workoutSummary != null) {
          final ws = dp.workoutSummary!;
          distance = ws.totalDistance.toDouble();
          energy = ws.totalEnergyBurned.toDouble();
          if (ws.workoutType.isNotEmpty) {
            try {
              workoutType = HealthWorkoutActivityType.values.firstWhere(
                (e) => e.name.toLowerCase() == ws.workoutType.toLowerCase(),
                orElse: () => HealthWorkoutActivityType.OTHER,
              );
            } on Object catch (_) {}
          }
        }

        var mappedType = mapWorkoutActivityType(workoutType);
        if (mappedType == ActivityType.other) {
          mappedType = detectActivityTypeFallback(
            wsType: dp.workoutSummary?.workoutType,
            sourceName: dp.sourceName,
          );
        }
        final sessionTitle = _buildWorkoutTitle(dp.sourceName, mappedType);

        sessions.add(
          HealthWorkoutSession(
            externalId: dp.uuid,
            activityType: mappedType,
            title: sessionTitle,
            startedAt: dp.dateFrom.toUtc(),
            endedAt: dp.dateTo.toUtc(),
            distanceMeters: workoutDistanceMeters(mappedType, distance),
            totalEnergyKcal: energy,
            sourceName: dp.sourceName.isNotEmpty
                ? dp.sourceName
                : (Platform.isAndroid ? 'Health Connect' : 'Apple Health'),
            sourceId: dp.sourceId,
          ),
        );
      }

      sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return sessions;
    } on Object catch (_) {
      return const [];
    }
  }

  @override
  Future<bool?> hasVitalsPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    // HealthKit never discloses read grants: unknown, not denied.
    if (Platform.isIOS) return null;
    // An OR, like [hasPermissions]: a partial grant still has data to show.
    for (final type in HealthVitalsReader.androidPermissionCheckTypes) {
      if (await _hasReadPermission(type)) return true;
    }
    return false;
  }

  @override
  Future<bool> requestVitalsPermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final types = HealthVitalsReader.requestTypes(
        android: Platform.isAndroid,
      );
      return await _health.requestAuthorization(
        types,
        permissions: [for (final _ in types) HealthDataAccess.READ],
      );
    } on Object catch (_) {
      return false;
    }
  }

  @override
  Future<HealthVitalsSnapshot?> getVitals({required DateTime now}) async {
    if (!Platform.isAndroid && !Platform.isIOS) return null;
    try {
      if (!await isSupported()) return null;
      return await HealthVitalsReader(
        _health,
        android: Platform.isAndroid,
      ).read(now);
    } on Object catch (_) {
      // S2: swallowed without logging; see `_stepsForDay`.
      return HealthVitalsSnapshot(readAt: now);
    }
  }

  @visibleForTesting
  static ActivityType mapWorkoutActivityType(HealthWorkoutActivityType type) {
    return switch (type) {
      HealthWorkoutActivityType.RUNNING ||
      HealthWorkoutActivityType.RUNNING_TREADMILL => ActivityType.run,
      HealthWorkoutActivityType.WALKING ||
      HealthWorkoutActivityType.WALKING_TREADMILL => ActivityType.walk,
      HealthWorkoutActivityType.HIKING => ActivityType.hike,
      HealthWorkoutActivityType.BIKING ||
      HealthWorkoutActivityType.BIKING_STATIONARY => ActivityType.ride,
      HealthWorkoutActivityType.SWIMMING ||
      HealthWorkoutActivityType.SWIMMING_OPEN_WATER ||
      HealthWorkoutActivityType.SWIMMING_POOL => ActivityType.swim,
      HealthWorkoutActivityType.YOGA => ActivityType.yoga,
      HealthWorkoutActivityType.PILATES => ActivityType.pilates,
      HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING =>
        ActivityType.hiit,
      HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING ||
      HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING ||
      HealthWorkoutActivityType.STRENGTH_TRAINING ||
      HealthWorkoutActivityType.WEIGHTLIFTING ||
      HealthWorkoutActivityType.CALISTHENICS => ActivityType.strength,
      _ => ActivityType.other,
    };
  }

  @visibleForTesting
  static ActivityType detectActivityTypeFallback({
    String? wsType,
    String? sourceName,
  }) {
    final lowerWs = (wsType ?? '').toLowerCase();
    if (lowerWs.contains('strength') ||
        lowerWs.contains('weight') ||
        lowerWs.contains('lift') ||
        lowerWs.contains('gym')) {
      return ActivityType.strength;
    }
    if (lowerWs.contains('run') || lowerWs.contains('jog')) {
      return ActivityType.run;
    }
    if (lowerWs.contains('walk')) {
      return ActivityType.walk;
    }
    if (lowerWs.contains('bike') ||
        lowerWs.contains('cycl') ||
        lowerWs.contains('ride')) {
      return ActivityType.ride;
    }
    if (lowerWs.contains('swim')) {
      return ActivityType.swim;
    }
    if (lowerWs.contains('yoga')) {
      return ActivityType.yoga;
    }
    if (lowerWs.contains('pilates')) {
      return ActivityType.pilates;
    }
    if (lowerWs.contains('hiit') || lowerWs.contains('interval')) {
      return ActivityType.hiit;
    }
    if (lowerWs.contains('hike')) {
      return ActivityType.hike;
    }
    return ActivityType.other;
  }

  @visibleForTesting
  static double? workoutDistanceMeters(ActivityType type, double? rawMeters) {
    if (!type.tracksDistance) return null;
    if (rawMeters == null || !rawMeters.isFinite || rawMeters <= 0) return null;
    return rawMeters;
  }

  static String _buildWorkoutTitle(String sourceName, ActivityType type) {
    final lower = sourceName.toLowerCase();
    final cleanSource = lower.contains('garmin')
        ? 'Garmin'
        : (lower.contains('apple')
              ? 'Apple Watch'
              : (lower.contains('wear') ||
                        lower.contains('pixel') ||
                        lower.contains('galaxy')
                    ? 'WearOS'
                    : ''));
    final typeLabel = type.label;
    return cleanSource.isNotEmpty ? '$cleanSource $typeLabel' : typeLabel;
  }
}
