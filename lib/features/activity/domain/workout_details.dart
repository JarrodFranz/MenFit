import 'dart:convert';

/// Sealed hierarchy representing rich, type-specific metadata for workouts.
sealed class WorkoutDetails {
  const WorkoutDetails();

  Map<String, dynamic> toJson();

  String toStorage() => jsonEncode(toJson());

  static WorkoutDetails? fromStorage(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) return null;
      return fromJson(map);
    } on Object catch (_) {
      return null;
    }
  }

  static WorkoutDetails? fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'strength' => StrengthWorkoutDetails.fromJson(json),
      'hiit' => HiitWorkoutDetails.fromJson(json),
      'mindful' => MindfulWorkoutDetails.fromJson(json),
      'swim' => SwimWorkoutDetails.fromJson(json),
      'general' => GeneralWorkoutDetails.fromJson(json),
      'wearable' => WearableWorkoutDetails.fromJson(json),
      _ => null,
    };
  }
}

/// A single set in a strength exercise.
class StrengthSet {
  const StrengthSet({
    required this.setNumber,
    required this.reps,
    this.weightKg = 0.0,
    this.durationSeconds = 0,
    this.restSeconds = 0,
    this.isWarmup = false,
    this.isCompleted = true,
  });

  factory StrengthSet.fromJson(Map<String, dynamic> json) {
    return StrengthSet(
      setNumber: (json['setNumber'] as num?)?.toInt() ?? 1,
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 0,
      isWarmup: json['isWarmup'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? true,
    );
  }

  final int setNumber;
  final int reps;
  final double weightKg;
  final int durationSeconds;
  final int restSeconds;
  final bool isWarmup;
  final bool isCompleted;

  /// Volume contribution for this set in kilograms (reps * weightKg).
  double get volumeKg => reps * weightKg;

  Map<String, dynamic> toJson() => {
    'setNumber': setNumber,
    'reps': reps,
    'weightKg': weightKg,
    'durationSeconds': durationSeconds,
    'restSeconds': restSeconds,
    'isWarmup': isWarmup,
    'isCompleted': isCompleted,
  };

  StrengthSet copyWith({
    int? setNumber,
    int? reps,
    double? weightKg,
    int? durationSeconds,
    int? restSeconds,
    bool? isWarmup,
    bool? isCompleted,
  }) {
    return StrengthSet(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      isWarmup: isWarmup ?? this.isWarmup,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// An individual exercise containing multiple sets in a strength workout.
class StrengthExercise {
  const StrengthExercise({
    required this.name,
    this.notes = '',
    this.sets = const [],
  });

  factory StrengthExercise.fromJson(Map<String, dynamic> json) {
    return StrengthExercise(
      name: json['name'] as String? ?? 'Exercise',
      notes: json['notes'] as String? ?? '',
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((s) => StrengthSet.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  final String name;
  final String notes;
  final List<StrengthSet> sets;

  /// Total volume lifted across all sets in this exercise, **including
  /// sets that were planned but never completed** — see
  /// [completedVolumeKg] for the "what she actually lifted" figure.
  double get totalVolumeKg => sets.fold(0, (sum, s) => sum + s.volumeKg);

  /// Volume from completed sets only ([StrengthSet.isCompleted]).
  double get completedVolumeKg =>
      sets.where((s) => s.isCompleted).fold(0, (sum, s) => sum + s.volumeKg);

  /// Number of completed sets.
  int get completedSetsCount => sets.where((s) => s.isCompleted).length;

  /// Total reps across completed sets.
  int get totalReps =>
      sets.where((s) => s.isCompleted).fold(0, (sum, s) => sum + s.reps);

  Map<String, dynamic> toJson() => {
    'name': name,
    'notes': notes,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  StrengthExercise copyWith({
    String? name,
    String? notes,
    List<StrengthSet>? sets,
  }) {
    return StrengthExercise(
      name: name ?? this.name,
      notes: notes ?? this.notes,
      sets: sets ?? this.sets,
    );
  }
}

/// Rich metadata for Strength workouts.
class StrengthWorkoutDetails extends WorkoutDetails {
  const StrengthWorkoutDetails({
    this.exercises = const [],
    this.notes = '',
  });

  factory StrengthWorkoutDetails.fromJson(Map<String, dynamic> json) {
    return StrengthWorkoutDetails(
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map((e) => StrengthExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      notes: json['notes'] as String? ?? '',
    );
  }

  final List<StrengthExercise> exercises;
  final String notes;

  /// Total volume lifted across all exercises (kg), **including sets that
  /// were planned but never completed** — the live-tracker figure, which
  /// is what a session in progress should show.
  ///
  /// Any surface that reports what she *actually* lifted — a recap, an
  /// insight comparison — must use [completedVolumeKg] instead.
  double get totalVolumeKg =>
      exercises.fold(0, (sum, e) => sum + e.totalVolumeKg);

  /// Volume across **completed** sets only (kg), the single definition of
  /// "tonnage lifted" shared by
  /// `features/recaps/domain/recap_builder.dart` and
  /// `features/insights/application/insight_observation_mapper.dart#completedTonnageKg`.
  ///
  /// Lives here rather than in either consumer so the two can never
  /// disagree about what she lifted: a planned-but-unfinished set carries
  /// a weight and a rep count, and counting it would report work she did
  /// not do back to her as fact.
  double get completedVolumeKg =>
      exercises.fold(0, (sum, e) => sum + e.completedVolumeKg);

  /// Total completed sets across all exercises.
  int get totalSets =>
      exercises.fold(0, (sum, e) => sum + e.completedSetsCount);

  /// Total reps across all exercises.
  int get totalReps => exercises.fold(0, (sum, e) => sum + e.totalReps);

  /// Average rest time in seconds between completed sets.
  double get avgRestSeconds {
    final setsWithRest = exercises
        .expand((e) => e.sets)
        .where((s) => s.isCompleted && s.restSeconds > 0)
        .toList();
    if (setsWithRest.isEmpty) return 0;
    final totalRest = setsWithRest.fold(0, (sum, s) => sum + s.restSeconds);
    return totalRest / setsWithRest.length;
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'strength',
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'notes': notes,
  };
}

/// Metadata for High-Intensity Interval Training (HIIT) workouts.
class HiitWorkoutDetails extends WorkoutDetails {
  const HiitWorkoutDetails({
    required this.workSeconds,
    required this.restSeconds,
    required this.totalRounds,
    required this.completedRounds,
    this.warmupSeconds = 0,
    this.cooldownSeconds = 0,
    this.intervalExercises = const [],
    this.notes = '',
  });

  factory HiitWorkoutDetails.fromJson(Map<String, dynamic> json) {
    return HiitWorkoutDetails(
      workSeconds: (json['workSeconds'] as num?)?.toInt() ?? 40,
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 20,
      totalRounds: (json['totalRounds'] as num?)?.toInt() ?? 8,
      completedRounds: (json['completedRounds'] as num?)?.toInt() ?? 8,
      warmupSeconds: (json['warmupSeconds'] as num?)?.toInt() ?? 0,
      cooldownSeconds: (json['cooldownSeconds'] as num?)?.toInt() ?? 0,
      intervalExercises:
          (json['intervalExercises'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      notes: json['notes'] as String? ?? '',
    );
  }

  final int workSeconds;
  final int restSeconds;
  final int totalRounds;
  final int completedRounds;
  final int warmupSeconds;
  final int cooldownSeconds;
  final List<String> intervalExercises;
  final String notes;

  int get totalWorkTimeSeconds => completedRounds * workSeconds;
  int get totalRestTimeSeconds =>
      completedRounds > 1 ? (completedRounds - 1) * restSeconds : 0;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'hiit',
    'workSeconds': workSeconds,
    'restSeconds': restSeconds,
    'totalRounds': totalRounds,
    'completedRounds': completedRounds,
    'warmupSeconds': warmupSeconds,
    'cooldownSeconds': cooldownSeconds,
    'intervalExercises': intervalExercises,
    'notes': notes,
  };
}

/// Metadata for Yoga and Pilates sessions.
class MindfulWorkoutDetails extends WorkoutDetails {
  const MindfulWorkoutDetails({
    this.style = 'Vinyasa',
    this.focusArea = 'Full Body Flow',
    this.rpe,
    this.poses = const [],
    this.notes = '',
  });

  factory MindfulWorkoutDetails.fromJson(Map<String, dynamic> json) {
    return MindfulWorkoutDetails(
      style: json['style'] as String? ?? 'Vinyasa',
      focusArea: json['focusArea'] as String? ?? 'Full Body Flow',
      // Deliberately no `?? 6`: an absent key means she was never asked,
      // and coalescing it would fabricate an answer (see [rpe]).
      rpe: (json['rpe'] as num?)?.toInt(),
      poses:
          (json['poses'] as List<dynamic>?)
              ?.map((p) => p.toString())
              .toList() ??
          const [],
      notes: json['notes'] as String? ?? '',
    );
  }

  final String style;
  final String focusArea;

  /// Rating of Perceived Exertion, 1-10, **as the user actually stated
  /// it** — `null` when she was never asked or did not answer.
  ///
  /// Nullable rather than defaulted on purpose: a stored `6` used to be
  /// indistinguishable from an unanswered question, which is why
  /// `features/insights/application/insight_observation_mapper.dart`
  /// could not map exertion at all. Never coalesce this to a number;
  /// surfaces render an em dash (or omit the stat) instead.
  final int? rpe;
  final List<String> poses;
  final String notes;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mindful',
    'style': style,
    'focusArea': focusArea,
    if (rpe != null) 'rpe': rpe,
    'poses': poses,
    'notes': notes,
  };
}

/// Metadata for Swimming workouts.
class SwimWorkoutDetails extends WorkoutDetails {
  const SwimWorkoutDetails({
    this.poolLengthMeters = 25.0,
    this.laps = 0,
    this.stroke = 'Freestyle',
    this.notes = '',
  });

  factory SwimWorkoutDetails.fromJson(Map<String, dynamic> json) {
    return SwimWorkoutDetails(
      poolLengthMeters: (json['poolLengthMeters'] as num?)?.toDouble() ?? 25.0,
      laps: (json['laps'] as num?)?.toInt() ?? 0,
      stroke: json['stroke'] as String? ?? 'Freestyle',
      notes: json['notes'] as String? ?? '',
    );
  }

  final double poolLengthMeters;
  final int laps;
  final String stroke; // Freestyle, Breaststroke, Backstroke, Butterfly, Mixed
  final String notes;

  double get calculatedDistanceMeters => laps * poolLengthMeters;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'swim',
    'poolLengthMeters': poolLengthMeters,
    'laps': laps,
    'stroke': stroke,
    'notes': notes,
  };
}

/// Generic / Other custom workouts.
class GeneralWorkoutDetails extends WorkoutDetails {
  const GeneralWorkoutDetails({
    this.activityName = 'Workout',
    this.rpe,
    this.notes = '',
  });

  factory GeneralWorkoutDetails.fromJson(Map<String, dynamic> json) {
    return GeneralWorkoutDetails(
      activityName: json['activityName'] as String? ?? 'Workout',
      // No `?? 6` — see [MindfulWorkoutDetails.rpe].
      rpe: (json['rpe'] as num?)?.toInt(),
      notes: json['notes'] as String? ?? '',
    );
  }

  final String activityName;

  /// Rating of Perceived Exertion, 1-10, as stated — `null` when
  /// unanswered. Same contract as [MindfulWorkoutDetails.rpe].
  final int? rpe;
  final String notes;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'general',
    'activityName': activityName,
    if (rpe != null) 'rpe': rpe,
    'notes': notes,
  };
}

/// Metadata for workouts synced or imported from external fitness wearables
/// (Garmin Connect, Apple Watch, WearOS, etc.).
class WearableWorkoutDetails extends WorkoutDetails {
  const WearableWorkoutDetails({
    required this.wearableSource,
    this.externalId,
    this.cyclePhase,
    this.caloriesBurnedKcal,
    this.avgCadence,
    this.maxHeartRate,
    this.rpe,
    this.notes = '',
  });

  factory WearableWorkoutDetails.fromJson(Map<String, dynamic> json) {
    return WearableWorkoutDetails(
      wearableSource: json['wearableSource'] as String? ?? 'Garmin Connect',
      externalId: json['externalId'] as String?,
      cyclePhase: json['cyclePhase'] as String?,
      caloriesBurnedKcal: (json['caloriesBurnedKcal'] as num?)?.toDouble(),
      avgCadence: (json['avgCadence'] as num?)?.toInt(),
      maxHeartRate: (json['maxHeartRate'] as num?)?.toInt(),
      rpe: (json['rpe'] as num?)?.toInt(),
      notes: json['notes'] as String? ?? '',
    );
  }

  final String wearableSource;
  final String? externalId;
  final String? cyclePhase;
  final double? caloriesBurnedKcal;
  final int? avgCadence;
  final int? maxHeartRate;
  final int? rpe;
  final String notes;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'wearable',
    'wearableSource': wearableSource,
    if (externalId != null) 'externalId': externalId,
    if (cyclePhase != null) 'cyclePhase': cyclePhase,
    if (caloriesBurnedKcal != null) 'caloriesBurnedKcal': caloriesBurnedKcal,
    if (avgCadence != null) 'avgCadence': avgCadence,
    if (maxHeartRate != null) 'maxHeartRate': maxHeartRate,
    if (rpe != null) 'rpe': rpe,
    if (notes.isNotEmpty) 'notes': notes,
  };
}
