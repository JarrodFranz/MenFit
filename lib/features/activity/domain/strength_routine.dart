import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:meta/meta.dart';

/// Target plan/template for an individual exercise within a routine.
@immutable
class StrengthExerciseTemplate {
  const StrengthExerciseTemplate({
    required this.name,
    this.targetSets = 3,
    this.targetReps = 10,
    this.targetWeightKg = 0.0,
    this.targetRestSeconds = 60,
    this.notes = '',
  });

  factory StrengthExerciseTemplate.fromJson(Map<String, dynamic> json) {
    return StrengthExerciseTemplate(
      name: json['name'] as String? ?? 'Exercise',
      targetSets: (json['targetSets'] as num?)?.toInt() ?? 3,
      targetReps: (json['targetReps'] as num?)?.toInt() ?? 10,
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble() ?? 0.0,
      targetRestSeconds: (json['targetRestSeconds'] as num?)?.toInt() ?? 60,
      notes: json['notes'] as String? ?? '',
    );
  }

  final String name;
  final int targetSets;
  final int targetReps;
  final double targetWeightKg;
  final int targetRestSeconds;
  final String notes;

  Map<String, dynamic> toJson() => {
    'name': name,
    'targetSets': targetSets,
    'targetReps': targetReps,
    'targetWeightKg': targetWeightKg,
    'targetRestSeconds': targetRestSeconds,
    'notes': notes,
  };

  StrengthExerciseTemplate copyWith({
    String? name,
    int? targetSets,
    int? targetReps,
    double? targetWeightKg,
    int? targetRestSeconds,
    String? notes,
  }) {
    return StrengthExerciseTemplate(
      name: name ?? this.name,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      targetRestSeconds: targetRestSeconds ?? this.targetRestSeconds,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrengthExerciseTemplate &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          targetSets == other.targetSets &&
          targetReps == other.targetReps &&
          targetWeightKg == other.targetWeightKg &&
          targetRestSeconds == other.targetRestSeconds &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
    name,
    targetSets,
    targetReps,
    targetWeightKg,
    targetRestSeconds,
    notes,
  );
}

/// A structured single-day workout routine (e.g. "Upper Body A", "Leg Day").
@immutable
class StrengthDayRoutine {
  const StrengthDayRoutine({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.exercises = const [],
    this.estimatedDurationMinutes = 45,
  });

  factory StrengthDayRoutine.create({
    required String name,
    String description = '',
    List<StrengthExerciseTemplate> exercises = const [],
    int estimatedDurationMinutes = 45,
  }) {
    final now = DateTime.now().toUtc();
    return StrengthDayRoutine(
      id: EntityId.generate(),
      name: name,
      description: description,
      exercises: exercises,
      estimatedDurationMinutes: estimatedDurationMinutes,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory StrengthDayRoutine.fromJson(Map<String, dynamic> json) {
    return StrengthDayRoutine(
      id: json['id'] as String? ?? EntityId.generate(),
      name: json['name'] as String? ?? 'Day Routine',
      description: json['description'] as String? ?? '',
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map(
                (e) => StrengthExerciseTemplate.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      estimatedDurationMinutes:
          (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 45,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now().toUtc(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now().toUtc(),
    );
  }

  final String id;
  final String name;
  final String description;
  final List<StrengthExerciseTemplate> exercises;
  final int estimatedDurationMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'estimatedDurationMinutes': estimatedDurationMinutes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  StrengthDayRoutine copyWith({
    String? id,
    String? name,
    String? description,
    List<StrengthExerciseTemplate>? exercises,
    int? estimatedDurationMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StrengthDayRoutine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrengthDayRoutine &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A multi-day strength training program / mesocycle (e.g. "4-Week
/// Hypertrophy").
@immutable
class StrengthCycle {
  const StrengthCycle({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.routines = const [],
    this.currentDayIndex = 0,
    this.totalSessionsCompleted = 0,
    this.totalVolumeLiftedKg = 0,
    this.isActive = false,
    this.startedAt,
    this.lastCompletedAt,
  });

  factory StrengthCycle.create({
    required String name,
    String description = '',
    List<StrengthDayRoutine> routines = const [],
    bool isActive = false,
  }) {
    final now = DateTime.now().toUtc();
    return StrengthCycle(
      id: EntityId.generate(),
      name: name,
      description: description,
      routines: routines,
      isActive: isActive,
      startedAt: isActive ? now : null,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory StrengthCycle.fromJson(Map<String, dynamic> json) {
    return StrengthCycle(
      id: json['id'] as String? ?? EntityId.generate(),
      name: json['name'] as String? ?? 'Training Cycle',
      description: json['description'] as String? ?? '',
      routines:
          (json['routines'] as List<dynamic>?)
              ?.map(
                (r) => StrengthDayRoutine.fromJson(r as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      currentDayIndex: (json['currentDayIndex'] as num?)?.toInt() ?? 0,
      totalSessionsCompleted:
          (json['totalSessionsCompleted'] as num?)?.toInt() ?? 0,
      totalVolumeLiftedKg:
          (json['totalVolumeLiftedKg'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? false,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      lastCompletedAt: json['lastCompletedAt'] != null
          ? DateTime.parse(json['lastCompletedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now().toUtc(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now().toUtc(),
    );
  }

  final String id;
  final String name;
  final String description;
  final List<StrengthDayRoutine> routines;
  final int currentDayIndex;
  final int totalSessionsCompleted;
  final double totalVolumeLiftedKg;
  final bool isActive;
  final DateTime? startedAt;
  final DateTime? lastCompletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// The next scheduled routine in this cycle, or null if empty.
  StrengthDayRoutine? get nextRoutine {
    if (routines.isEmpty) return null;
    final index = currentDayIndex % routines.length;
    return routines[index];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'routines': routines.map((r) => r.toJson()).toList(),
    'currentDayIndex': currentDayIndex,
    'totalSessionsCompleted': totalSessionsCompleted,
    'totalVolumeLiftedKg': totalVolumeLiftedKg,
    'isActive': isActive,
    'startedAt': startedAt?.toIso8601String(),
    'lastCompletedAt': lastCompletedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  StrengthCycle copyWith({
    String? id,
    String? name,
    String? description,
    List<StrengthDayRoutine>? routines,
    int? currentDayIndex,
    int? totalSessionsCompleted,
    double? totalVolumeLiftedKg,
    bool? isActive,
    DateTime? startedAt,
    DateTime? lastCompletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StrengthCycle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      routines: routines ?? this.routines,
      currentDayIndex: currentDayIndex ?? this.currentDayIndex,
      totalSessionsCompleted:
          totalSessionsCompleted ?? this.totalSessionsCompleted,
      totalVolumeLiftedKg: totalVolumeLiftedKg ?? this.totalVolumeLiftedKg,
      isActive: isActive ?? this.isActive,
      startedAt: startedAt ?? this.startedAt,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrengthCycle &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Curated starter templates so users can immediately jump into popular splits.
abstract final class StrengthCycleStarters {
  static List<StrengthCycle> get starterCycles => [
    StrengthCycle.create(
      name: 'Upper / Lower Split',
      description:
          'A balanced 3-day split balancing upper body strength with lower '
          'body power and core stability.',
      routines: [
        StrengthDayRoutine.create(
          name: 'Day 1: Upper Body Power',
          description: 'Chest, back, and shoulders focus.',
          exercises: const [
            StrengthExerciseTemplate(
              name: 'Bench Press',
              targetReps: 8,
              targetWeightKg: 30,
              targetRestSeconds: 90,
            ),
            StrengthExerciseTemplate(
              name: 'Barbell Row',
              targetWeightKg: 25,
              targetRestSeconds: 75,
            ),
            StrengthExerciseTemplate(
              name: 'Overhead Shoulder Press',
              targetWeightKg: 20,
            ),
            StrengthExerciseTemplate(
              name: 'Pull Up / Lat Pulldown',
              targetWeightKg: 35,
            ),
          ],
        ),
        StrengthDayRoutine.create(
          name: 'Day 2: Lower Body & Glutes',
          description: 'Quads, hamstrings, glutes, and calves.',
          exercises: const [
            StrengthExerciseTemplate(
              name: 'Barbell Squat',
              targetReps: 8,
              targetWeightKg: 40,
              targetRestSeconds: 90,
            ),
            StrengthExerciseTemplate(
              name: 'Hip Thrust',
              targetReps: 12,
              targetWeightKg: 45,
              targetRestSeconds: 75,
            ),
            StrengthExerciseTemplate(
              name: 'Romanian Deadlift (RDL)',
              targetWeightKg: 35,
              targetRestSeconds: 75,
            ),
            StrengthExerciseTemplate(
              name: 'Dumbbell Walking Lunge',
              targetReps: 12,
              targetWeightKg: 10,
            ),
          ],
        ),
        StrengthDayRoutine.create(
          name: 'Day 3: Full Body & Conditioning',
          description: 'Compound lifts and functional core work.',
          exercises: const [
            StrengthExerciseTemplate(
              name: 'Deadlift',
              targetReps: 6,
              targetWeightKg: 50,
              targetRestSeconds: 120,
            ),
            StrengthExerciseTemplate(
              name: 'Push Up',
              targetReps: 12,
            ),
            StrengthExerciseTemplate(
              name: 'Dumbbell Lateral Raise',
              targetReps: 12,
              targetWeightKg: 6,
              targetRestSeconds: 45,
            ),
            StrengthExerciseTemplate(
              name: 'Plank (Core)',
              targetReps: 1,
              notes: 'Hold for 45-60 seconds',
            ),
          ],
        ),
      ],
    ),
  ];
}
