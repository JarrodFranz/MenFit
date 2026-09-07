import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/domain/weekday.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/profile/domain/profile_repository.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/weight/weight_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_controller.g.dart';

/// Watches the local user's profile and exposes an update operation.
///
/// `null` data means no profile exists yet (before onboarding creates
/// one) - the profile screen and any other consumer must handle that case.
@riverpod
class ProfileController extends _$ProfileController {
  /// Serializes calls to [updateProfile] so two rapid, concurrent updates
  /// (e.g. two form fields saved in quick succession, both issued before
  /// either resolves) never both merge onto the same stale base and clobber
  /// each other - the second waits for the first to actually persist before
  /// it reads its own merge base.
  Future<void> _tail = Future<void>.value();

  @override
  Stream<UserProfile?> build() {
    final repository = ref.watch(profileRepositoryProvider);
    return repository.watchProfile();
  }

  /// Applies the given fields to the current profile - or creates one if
  /// none exists yet - and persists the result.
  ///
  /// Fields left `null` are unchanged. Pass the matching `clear*` flag to
  /// explicitly unset a nullable field, since `null` alone can't distinguish
  /// "leave unchanged" from "clear it" - same convention as the pre-existing
  /// [clearWeeklyActivityGoal]. [trainingDays] doesn't need a clear flag: an
  /// empty set is itself a valid, distinguishable-from-null "set to no
  /// days" value (see `UserProfile.trainingDays`'s doc), so passing `null`
  /// already means "leave unchanged" and passing `<Weekday>{}` already means
  /// "clear it".
  ///
  /// A change to [weightKg] additionally writes a point into the weight
  /// history (`features/weight`) - see [_writeThroughWeightLog] for the
  /// exact conditions and why it is one-way.
  ///
  /// Returns a future that completes (or throws) once this specific update
  /// has been persisted - callers can `await` it and handle failure
  /// per-call, independent of whether other updates are queued behind it.
  Future<void> updateProfile({
    String? displayName,
    UnitSystem? unitSystem,
    int? weeklyActivityGoal,
    bool clearWeeklyActivityGoal = false,
    LocalDate? dateOfBirth,
    bool clearDateOfBirth = false,
    double? heightCm,
    bool clearHeightCm = false,
    double? weightKg,
    bool clearWeightKg = false,
    FitnessGoal? fitnessGoal,
    bool clearFitnessGoal = false,
    Set<FitnessGoal>? fitnessGoals,
    bool clearFitnessGoals = false,
    ExperienceLevel? runningExperience,
    bool clearRunningExperience = false,
    ExperienceLevel? strengthExperience,
    bool clearStrengthExperience = false,
    Set<Weekday>? trainingDays,
  }) {
    final repository = ref.read(profileRepositoryProvider);
    final operation = _tail.then(
      (_) => _apply(
        repository,
        displayName: displayName,
        unitSystem: unitSystem,
        weeklyActivityGoal: weeklyActivityGoal,
        clearWeeklyActivityGoal: clearWeeklyActivityGoal,
        dateOfBirth: dateOfBirth,
        clearDateOfBirth: clearDateOfBirth,
        heightCm: heightCm,
        clearHeightCm: clearHeightCm,
        weightKg: weightKg,
        clearWeightKg: clearWeightKg,
        fitnessGoal: fitnessGoal,
        clearFitnessGoal: clearFitnessGoal,
        fitnessGoals: fitnessGoals,
        clearFitnessGoals: clearFitnessGoals,
        runningExperience: runningExperience,
        clearRunningExperience: clearRunningExperience,
        strengthExperience: strengthExperience,
        clearStrengthExperience: clearStrengthExperience,
        trainingDays: trainingDays,
      ),
    );
    // Chain the *next* call after this one regardless of outcome, so one
    // failed update doesn't wedge every update queued after it - the
    // failure still reaches this call's own caller via `operation` below.
    _tail = operation.then<void>((_) {}, onError: (_) {});
    return operation;
  }

  Future<void> _apply(
    ProfileRepository repository, {
    required String? displayName,
    required UnitSystem? unitSystem,
    required int? weeklyActivityGoal,
    required bool clearWeeklyActivityGoal,
    required LocalDate? dateOfBirth,
    required bool clearDateOfBirth,
    required double? heightCm,
    required bool clearHeightCm,
    required double? weightKg,
    required bool clearWeightKg,
    required FitnessGoal? fitnessGoal,
    required bool clearFitnessGoal,
    required Set<FitnessGoal>? fitnessGoals,
    required bool clearFitnessGoals,
    required ExperienceLevel? runningExperience,
    required bool clearRunningExperience,
    required ExperienceLevel? strengthExperience,
    required bool clearStrengthExperience,
    required Set<Weekday>? trainingDays,
  }) async {
    // Always a fresh read, not `state.value` - the merge base must reflect
    // whatever the previous queued update (if any) just persisted, not a
    // value captured before this call was even queued.
    final current = await repository.getProfile();
    final now = DateTime.now().toUtc();

    final resolvedGoals = clearFitnessGoals
        ? const <FitnessGoal>{}
        : (fitnessGoals ??
              (fitnessGoal != null
                  ? {fitnessGoal}
                  : (clearFitnessGoal
                        ? const <FitnessGoal>{}
                        : (current?.allFitnessGoals ??
                              const <FitnessGoal>{}))));

    final next = current == null
        ? UserProfile(
            id: EntityId.generate(),
            displayName: displayName ?? '',
            unitSystem: unitSystem ?? UnitSystem.metric,
            weeklyActivityGoal: clearWeeklyActivityGoal
                ? null
                : weeklyActivityGoal,
            dateOfBirth: clearDateOfBirth ? null : dateOfBirth,
            heightCm: clearHeightCm ? null : heightCm,
            weightKg: clearWeightKg ? null : weightKg,
            fitnessGoal: resolvedGoals.firstOrNull,
            fitnessGoals: resolvedGoals,
            runningExperience: clearRunningExperience
                ? null
                : runningExperience,
            strengthExperience: clearStrengthExperience
                ? null
                : strengthExperience,
            trainingDays: trainingDays ?? const <Weekday>{},
            createdAt: now,
            updatedAt: now,
          )
        : current.copyWith(
            displayName: displayName ?? current.displayName,
            unitSystem: unitSystem ?? current.unitSystem,
            weeklyActivityGoal: clearWeeklyActivityGoal
                ? null
                : (weeklyActivityGoal ?? current.weeklyActivityGoal),
            dateOfBirth: clearDateOfBirth
                ? null
                : (dateOfBirth ?? current.dateOfBirth),
            heightCm: clearHeightCm ? null : (heightCm ?? current.heightCm),
            weightKg: clearWeightKg ? null : (weightKg ?? current.weightKg),
            fitnessGoal: resolvedGoals.firstOrNull,
            fitnessGoals: resolvedGoals,
            runningExperience: clearRunningExperience
                ? null
                : (runningExperience ?? current.runningExperience),
            strengthExperience: clearStrengthExperience
                ? null
                : (strengthExperience ?? current.strengthExperience),
            trainingDays: trainingDays ?? current.trainingDays,
            updatedAt: now,
          );

    await repository.saveProfile(next);
    await _writeThroughWeightLog(
      previousWeightKg: current?.weightKg,
      next: next,
      now: now,
    );
  }

  /// Records a weight-history entry when — and only when — this update
  /// actually changed the profile's weight.
  ///
  /// One-way, profile -> log: the profile column stays the app's "current
  /// weight" (several features read it), and every change to it becomes a
  /// point in the history that `features/weight` owns. Nothing writes back
  /// the other way, so there is no loop to reason about.
  ///
  /// Guarded on a real change so that saving an unrelated field — a
  /// display name, a training day — can't quietly stamp a duplicate
  /// weigh-in, and so that re-saving the same number is a no-op rather
  /// than a second identical point that would flatten a trend line.
  /// Clearing the weight (`clearWeightKg`) records nothing: "they removed
  /// the value" is not a measurement.
  ///
  /// Multiple genuine changes on the same day each get their own row —
  /// that is the point of allowing several logs per day (see
  /// `features/weight/domain/weight_repository.dart`).
  ///
  /// **A failure here is swallowed, deliberately.** By the time this runs
  /// the profile has already been saved, so letting a [StorageException]
  /// out would surface a successful save as a failed one and invite the
  /// user to redo an edit that in fact landed. The profile row is the
  /// authoritative "current weight" and it is correct; what is lost is one
  /// point in a history that exists to show a trend, and the next weight
  /// edit writes its own point, so the omission self-heals rather than
  /// compounding. Nothing is logged either — the failure would carry the
  /// value, and body weight is S2 data
  /// (`knowledge/engineering/security_and_privacy.md`).
  Future<void> _writeThroughWeightLog({
    required double? previousWeightKg,
    required UserProfile next,
    required DateTime now,
  }) async {
    final weightKg = next.weightKg;
    if (weightKg == null || weightKg == previousWeightKg) return;

    try {
      await ref
          .read(weightRepositoryProvider)
          .saveLog(
            WeightLog(
              id: EntityId.generate(),
              // The day they entered it, in their own timezone - the profile
              // has no measurement date to carry over.
              day: LocalDate.today(),
              weightKg: weightKg,
              createdAt: now,
              updatedAt: now,
            ),
          );
    } on StorageException {
      // Intentionally silent — see this method's doc comment.
    }
  }
}
