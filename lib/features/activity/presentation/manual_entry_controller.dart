import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/workout_details.dart';
import 'package:menfit_app/features/activity/presentation/mindful_style_options.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manual_entry_controller.freezed.dart';
part 'manual_entry_controller.g.dart';

/// In-progress state of the manual-activity-entry form.
@freezed
abstract class ManualEntryState with _$ManualEntryState {
  const factory ManualEntryState({
    required DateTime startedAt,
    @Default(ActivityType.run) ActivityType activityType,
    @Default(0) int hours,
    @Default(0) int minutes,
    @Default(0) int seconds,

    /// Raw text as typed, in whatever unit ([UnitSystem]) the caller
    /// passes to [ManualEntryController.save] / pre-fills via
    /// [ManualEntryController.loadForEdit] - parsed (and converted to
    /// canonical metres) only at save time.
    @Default('') String distanceInput,
    @Default('') String elevationInput,
    @Default('') String title,
    @Default('') String notes,

    // Strength fields
    @Default('') String strengthRoutineName,
    @Default([]) List<StrengthExercise> strengthExercises,

    // HIIT fields
    @Default(40) int hiitWorkSeconds,
    @Default(20) int hiitRestSeconds,
    @Default(8) int hiitTotalRounds,
    @Default(7) int hiitRpe,

    // Mindful (Yoga/Pilates) fields
    @Default('Vinyasa') String mindfulStyle,
    @Default('Full Body Flow') String mindfulFocusArea,
    @Default(6) int mindfulRpe,

    // Swim fields
    @Default(25.0) double swimPoolLengthMeters,
    @Default(0) int swimLaps,
    @Default('Freestyle') String swimStroke,

    String? dateTimeError,
    String? durationError,
    String? distanceError,
    @Default(false) bool isSubmitting,
    String? submitError,

    /// Flips to `true` once [ManualEntryController.save] persists
    /// successfully - the screen listens for this to navigate away,
    /// exactly once, instead of the controller navigating itself.
    @Default(false) bool didSave,
  }) = _ManualEntryState;
}

/// Drives the manual-activity-entry form (`/activity/log`,
/// `/activity/:id/edit`).
@riverpod
class ManualEntryController extends _$ManualEntryController {
  String? _editingActivityId;
  DateTime? _editingCreatedAt;

  /// The mindful RPE the edited activity already carried, or `null` for a
  /// new entry.
  ///
  /// The form has **no RPE control** — nothing calls [updateMindfulRpe] —
  /// so [ManualEntryState.mindfulRpe] cannot tell "they chose 6" from "they
  /// were never asked", and `MindfulWorkoutDetails.rpe` must be `null` in
  /// that case rather than a fabricated number. What [save] writes
  /// therefore comes from here: whatever the activity being edited
  /// already stored, preserved untouched. If an RPE control is ever added
  /// to this form, make the state field `int?` (a codegen change) and
  /// read it in [save] instead of this.
  int? _editingMindfulRpe;

  @override
  ManualEntryState build() => ManualEntryState(startedAt: DateTime.now());

  void setInitialType(ActivityType type) {
    state = _movedToType(type);
  }

  void updateActivityType(ActivityType value) {
    state = _movedToType(value);
  }

  /// The state under [type], with a mindful style that belonged to the type
  /// they have just left cleared — see [mindfulStyleAfterTypeChange].
  ManualEntryState _movedToType(ActivityType type) {
    return state.copyWith(
      activityType: type,
      mindfulStyle: mindfulStyleAfterTypeChange(
        current: state.mindfulStyle,
        from: state.activityType,
        to: type,
      ),
    );
  }

  void updateStartedAt(DateTime value) {
    state = state.copyWith(startedAt: value, dateTimeError: null);
  }

  void updateHours(int value) {
    state = state.copyWith(hours: value.clamp(0, 99), durationError: null);
  }

  void updateMinutes(int value) {
    state = state.copyWith(minutes: value.clamp(0, 59), durationError: null);
  }

  void updateSeconds(int value) {
    state = state.copyWith(seconds: value.clamp(0, 59), durationError: null);
  }

  void updateDistanceInput(String value) {
    state = state.copyWith(distanceInput: value, distanceError: null);
  }

  void updateElevationInput(String value) {
    state = state.copyWith(elevationInput: value);
  }

  void updateTitle(String value) {
    state = state.copyWith(title: value);
  }

  void updateNotes(String value) {
    state = state.copyWith(notes: value);
  }

  // --- Strength Methods ---
  void updateStrengthRoutineName(String name) {
    state = state.copyWith(strengthRoutineName: name);
  }

  void addStrengthExercise(String name) {
    final updated = List<StrengthExercise>.from(state.strengthExercises)
      ..add(
        StrengthExercise(
          name: name,
          sets: const [
            StrengthSet(setNumber: 1, reps: 10, weightKg: 20),
            StrengthSet(setNumber: 2, reps: 10, weightKg: 20),
            StrengthSet(setNumber: 3, reps: 10, weightKg: 20),
          ],
        ),
      );
    state = state.copyWith(strengthExercises: updated);
  }

  void removeStrengthExercise(int index) {
    if (index < 0 || index >= state.strengthExercises.length) return;
    final updated = List<StrengthExercise>.from(state.strengthExercises)
      ..removeAt(index);
    state = state.copyWith(strengthExercises: updated);
  }

  void addStrengthSet(
    int exerciseIndex, {
    int reps = 10,
    double weightKg = 20,
  }) {
    if (exerciseIndex < 0 || exerciseIndex >= state.strengthExercises.length) {
      return;
    }
    final exercise = state.strengthExercises[exerciseIndex];
    final newSet = StrengthSet(
      setNumber: exercise.sets.length + 1,
      reps: reps,
      weightKg: weightKg,
    );
    final updatedSets = List<StrengthSet>.from(exercise.sets)..add(newSet);
    final updatedExercises = List<StrengthExercise>.from(
      state.strengthExercises,
    )..[exerciseIndex] = exercise.copyWith(sets: updatedSets);
    state = state.copyWith(strengthExercises: updatedExercises);
  }

  void removeStrengthSet(int exerciseIndex, int setIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= state.strengthExercises.length) {
      return;
    }
    final exercise = state.strengthExercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;
    final updatedSets = List<StrengthSet>.from(exercise.sets)
      ..removeAt(setIndex);
    final renumberedSets = [
      for (var i = 0; i < updatedSets.length; i++)
        updatedSets[i].copyWith(setNumber: i + 1),
    ];
    final updatedExercises = List<StrengthExercise>.from(
      state.strengthExercises,
    )..[exerciseIndex] = exercise.copyWith(sets: renumberedSets);
    state = state.copyWith(strengthExercises: updatedExercises);
  }

  void updateStrengthSet(
    int exerciseIndex,
    int setIndex, {
    int? reps,
    double? weightKg,
  }) {
    if (exerciseIndex < 0 || exerciseIndex >= state.strengthExercises.length) {
      return;
    }
    final exercise = state.strengthExercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;
    final targetSet = exercise.sets[setIndex];
    final updatedSet = targetSet.copyWith(
      reps: reps ?? targetSet.reps,
      weightKg: weightKg ?? targetSet.weightKg,
    );
    final updatedSets = List<StrengthSet>.from(exercise.sets)
      ..[setIndex] = updatedSet;
    final updatedExercises = List<StrengthExercise>.from(
      state.strengthExercises,
    )..[exerciseIndex] = exercise.copyWith(sets: updatedSets);
    state = state.copyWith(strengthExercises: updatedExercises);
  }

  // --- HIIT Methods ---
  void updateHiitWork(int seconds) {
    state = state.copyWith(hiitWorkSeconds: seconds.clamp(5, 300));
  }

  void updateHiitRest(int seconds) {
    state = state.copyWith(hiitRestSeconds: seconds.clamp(0, 300));
  }

  void updateHiitRounds(int rounds) {
    state = state.copyWith(hiitTotalRounds: rounds.clamp(1, 50));
  }

  void updateHiitRpe(int rpe) {
    state = state.copyWith(hiitRpe: rpe.clamp(1, 10));
  }

  // --- Mindful Methods ---
  void updateMindfulStyle(String style) {
    state = state.copyWith(mindfulStyle: style);
  }

  void updateMindfulFocusArea(String focus) {
    state = state.copyWith(mindfulFocusArea: focus);
  }

  /// Currently unused: no widget in the manual-entry form offers an RPE
  /// control, and [save] deliberately does **not** read
  /// [ManualEntryState.mindfulRpe] (see [_editingMindfulRpe]). Wiring a
  /// control to this alone would not persist anything.
  void updateMindfulRpe(int rpe) {
    state = state.copyWith(mindfulRpe: rpe.clamp(1, 10));
  }

  // --- Swim Methods ---
  void updateSwimPoolLength(double meters) {
    state = state.copyWith(swimPoolLengthMeters: meters);
  }

  void updateSwimLaps(int laps) {
    state = state.copyWith(swimLaps: laps.clamp(0, 500));
  }

  void updateSwimStroke(String stroke) {
    state = state.copyWith(swimStroke: stroke);
  }

  /// Populates the form from an existing [activity] for editing.
  void loadForEdit(Activity activity, UnitSystem unitSystem) {
    _editingActivityId = activity.id;
    _editingCreatedAt = activity.createdAt;
    final distanceInKmOrMi = unitSystem == UnitSystem.imperial
        ? UnitConversions.kmToMi(activity.distanceMeters / 1000)
        : activity.distanceMeters / 1000;

    final elevation = activity.elevationGainMeters;
    final elevationStr = elevation != null && elevation > 0
        ? elevation.toStringAsFixed(0)
        : '';

    var newState = state.copyWith(
      activityType: activity.activityType,
      startedAt: activity.startedAt.toLocal(),
      hours: activity.movingTime.inHours,
      minutes: activity.movingTime.inMinutes.remainder(60),
      seconds: activity.movingTime.inSeconds.remainder(60),
      distanceInput: distanceInKmOrMi > 0
          ? distanceInKmOrMi.toStringAsFixed(2)
          : '',
      elevationInput: elevationStr,
      title: activity.title,
      notes: activity.notes ?? '',
    );

    // Hydrate metadata if present
    final metadata = activity.workoutDetails;
    if (metadata is StrengthWorkoutDetails) {
      newState = newState.copyWith(
        strengthExercises: metadata.exercises,
      );
    } else if (metadata is HiitWorkoutDetails) {
      newState = newState.copyWith(
        hiitWorkSeconds: metadata.workSeconds,
        hiitRestSeconds: metadata.restSeconds,
        hiitTotalRounds: metadata.totalRounds,
      );
    } else if (metadata is MindfulWorkoutDetails) {
      _editingMindfulRpe = metadata.rpe;
      newState = newState.copyWith(
        mindfulStyle: metadata.style,
        mindfulFocusArea: metadata.focusArea,
      );
    } else if (metadata is SwimWorkoutDetails) {
      newState = newState.copyWith(
        swimPoolLengthMeters: metadata.poolLengthMeters,
        swimLaps: metadata.laps,
        swimStroke: metadata.stroke,
      );
    }

    state = newState;
  }

  /// Validates the form and, if valid, saves it.
  Future<bool> save(UnitSystem unitSystem) async {
    if (!_validate()) return false;

    state = state.copyWith(isSubmitting: true, submitError: null);
    try {
      final repository = ref.read(activityRepositoryProvider);
      final now = DateTime.now().toUtc();
      final duration = Duration(
        hours: state.hours,
        minutes: state.minutes,
        seconds: state.seconds,
      );

      var distanceMeters = 0.0;
      WorkoutDetails? details;

      switch (state.activityType) {
        case ActivityType.run:
        case ActivityType.walk:
        case ActivityType.hike:
        case ActivityType.ride:
          distanceMeters = _parsedDistanceMeters(unitSystem) ?? 0.0;
        case ActivityType.strength:
          distanceMeters = 0.0;
          if (state.strengthExercises.isNotEmpty) {
            details = StrengthWorkoutDetails(
              exercises: state.strengthExercises,
              notes: state.notes,
            );
          }
        case ActivityType.hiit:
          distanceMeters = 0.0;
          details = HiitWorkoutDetails(
            workSeconds: state.hiitWorkSeconds,
            restSeconds: state.hiitRestSeconds,
            totalRounds: state.hiitTotalRounds,
            completedRounds: state.hiitTotalRounds,
            notes: state.notes,
          );
        case ActivityType.yoga:
        case ActivityType.pilates:
          distanceMeters = 0.0;
          details = MindfulWorkoutDetails(
            style: state.mindfulStyle,
            focusArea: state.mindfulFocusArea,
            // Never `state.mindfulRpe` — see [_editingMindfulRpe].
            rpe: _editingMindfulRpe,
            notes: state.notes,
          );
        case ActivityType.swim:
          final swim = SwimWorkoutDetails(
            poolLengthMeters: state.swimPoolLengthMeters,
            laps: state.swimLaps,
            stroke: state.swimStroke,
            notes: state.notes,
          );
          distanceMeters = swim.calculatedDistanceMeters;
          details = swim;
        case ActivityType.other:
          distanceMeters = _parsedDistanceMeters(unitSystem) ?? 0.0;
      }

      final trimmedTitle = state.title.trim();
      final title = trimmedTitle.isEmpty
          ? _defaultTitle(state.activityType, state.startedAt)
          : trimmedTitle;
      final trimmedNotes = state.notes.trim();

      double? elevationGain;
      final trimmedElevation = state.elevationInput.trim();
      if (trimmedElevation.isNotEmpty) {
        elevationGain = double.tryParse(trimmedElevation);
      }

      final activity = Activity(
        id: _editingActivityId ?? EntityId.generate(),
        activityType: state.activityType,
        title: title,
        notes: trimmedNotes.isEmpty ? null : trimmedNotes,
        startedAt: state.startedAt.toUtc(),
        movingTime: duration,
        elapsedTime: duration,
        distanceMeters: distanceMeters,
        elevationGainMeters: elevationGain,
        workoutDetails: details,
        source: ActivitySource.manual,
        createdAt: _editingCreatedAt ?? now,
        updatedAt: now,
      );

      await repository.saveActivity(activity);
      state = state.copyWith(didSave: true, isSubmitting: false);
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        submitError: userMessageFor(error),
        isSubmitting: false,
      );
      return false;
    }
  }

  /// Validates every field, updating the corresponding `*Error` state.
  bool _validate() {
    String? dateTimeError;
    if (state.startedAt.isAfter(DateTime.now())) {
      dateTimeError = "That hasn't happened yet - pick a time in the past.";
    }

    String? durationError;
    final totalDuration = Duration(
      hours: state.hours,
      minutes: state.minutes,
      seconds: state.seconds,
    );
    if (totalDuration <= Duration.zero) {
      durationError = 'Enter a duration greater than zero.';
    }

    String? distanceError;
    final isDistanceOptional =
        state.activityType == ActivityType.strength ||
        state.activityType == ActivityType.yoga ||
        state.activityType == ActivityType.hiit ||
        state.activityType == ActivityType.pilates ||
        state.activityType == ActivityType.swim ||
        state.activityType == ActivityType.other;

    if (!isDistanceOptional) {
      final trimmedDistance = state.distanceInput.trim();
      if (trimmedDistance.isEmpty) {
        distanceError = 'Enter a valid distance.';
      } else {
        final parsed = double.tryParse(trimmedDistance);
        if (parsed == null || !parsed.isFinite || parsed <= 0) {
          distanceError = 'Enter a valid distance.';
        }
      }
    }

    state = state.copyWith(
      dateTimeError: dateTimeError,
      durationError: durationError,
      distanceError: distanceError,
    );
    return dateTimeError == null &&
        durationError == null &&
        distanceError == null;
  }

  double? _parsedDistanceMeters(UnitSystem unitSystem) {
    final trimmedDistance = state.distanceInput.trim();
    if (trimmedDistance.isEmpty) return 0;
    final parsed = double.tryParse(trimmedDistance);
    if (parsed == null || !parsed.isFinite || parsed < 0) return null;
    final km = unitSystem == UnitSystem.imperial
        ? UnitConversions.miToKm(parsed)
        : parsed;
    return km * 1000;
  }
}

String _defaultTitle(ActivityType type, DateTime startedAtLocal) {
  final hour = startedAtLocal.hour;
  final timeOfDay = switch (hour) {
    >= 5 && < 12 => 'Morning',
    >= 12 && < 17 => 'Afternoon',
    >= 17 && < 21 => 'Evening',
    _ => 'Night',
  };
  return '$timeOfDay ${type.label}';
}
