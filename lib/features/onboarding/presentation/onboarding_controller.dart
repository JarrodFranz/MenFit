import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/domain/weekday.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/features/onboarding/onboarding_providers.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/weight/weight_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.freezed.dart';
part 'onboarding_controller.g.dart';

/// Number of steps in the onboarding flow: welcome, about you, tell us a
/// little more (optional), privacy.
const int onboardingStepCount = 4;

/// Step index of the optional "Tell us a little more" step.
/// `presentation/onboarding_screen.dart` uses this to show a "Skip"
/// affordance specifically on this step.
const int moreAboutYouStepIndex = 2;

/// In-progress state of the onboarding flow.
@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int stepIndex,
    @Default('') String displayName,
    @Default(UnitSystem.metric) UnitSystem unitSystem,

    /// Set on the optional "Tell us a little more" step. `null` (the
    /// default) means never chosen — this step is entirely skippable.
    FitnessGoal? fitnessGoal,

    /// Multiple chosen fitness goals. Empty set when none chosen.
    @Default(<FitnessGoal>{}) Set<FitnessGoal> fitnessGoals,

    /// Set on the optional "Tell us a little more" step. `null` (the
    /// default) means never chosen.
    ExperienceLevel? runningExperience,

    /// Optional profile measurements collected during onboarding.
    LocalDate? dateOfBirth,
    double? heightCm,
    double? weightKg,
    int? weeklyActivityGoal,
    @Default(<Weekday>{}) Set<Weekday> trainingDays,

    /// Optional field validation errors for height/weight.
    String? heightError,
    String? weightError,

    /// Set when [OnboardingController.continueFromCurrentStep] or
    /// [OnboardingController.finish] rejects an empty display name -
    /// validation as a return/state value, not an exception, per
    /// `knowledge/engineering/error_handling.md`.
    String? displayNameError,

    /// User-presentable message set when [OnboardingController.finish]
    /// fails partway through (profile save or onboarding-complete flag both
    /// throw). `null` when there's nothing to show.
    String? submitError,
    @Default(false) bool isSubmitting,
  }) = _OnboardingState;

  const OnboardingState._();

  bool get isFirstStep => stepIndex == 0;

  bool get isLastStep => stepIndex == onboardingStepCount - 1;
}

/// Drives the onboarding flow.
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  OnboardingState build() => const OnboardingState();

  void updateDisplayName(String value) {
    state = state.copyWith(displayName: value, displayNameError: null);
  }

  void updateUnitSystem(UnitSystem value) {
    state = state.copyWith(unitSystem: value);
  }

  /// Sets (or, given `null`, clears) the chosen goal.
  void updateFitnessGoal(FitnessGoal? value) {
    if (value == null) {
      state = state.copyWith(fitnessGoal: null, fitnessGoals: const {});
    } else {
      state = state.copyWith(fitnessGoal: value, fitnessGoals: {value});
    }
  }

  /// Toggles a fitness goal into or out of the selected set.
  void toggleFitnessGoal(FitnessGoal goal) {
    final current = Set<FitnessGoal>.from(state.fitnessGoals);
    if (current.contains(goal)) {
      current.remove(goal);
    } else {
      current.add(goal);
    }
    state = state.copyWith(
      fitnessGoals: current,
      fitnessGoal: current.firstOrNull,
    );
  }

  /// Sets (or, given `null`, clears) the chosen running-experience level.
  void updateRunningExperience(ExperienceLevel? value) {
    state = state.copyWith(runningExperience: value);
  }

  void updateDateOfBirth(LocalDate? dob) {
    state = state.copyWith(dateOfBirth: dob);
  }

  void updateHeight(double? heightCm, {String? error}) {
    state = state.copyWith(heightCm: heightCm, heightError: error);
  }

  void updateWeight(double? weightKg, {String? error}) {
    state = state.copyWith(weightKg: weightKg, weightError: error);
  }

  void updateWeeklyActivityGoal(int? goal) {
    state = state.copyWith(weeklyActivityGoal: goal);
  }

  void toggleTrainingDay(Weekday day) {
    final current = Set<Weekday>.from(state.trainingDays);
    if (current.contains(day)) {
      current.remove(day);
    } else {
      current.add(day);
    }
    state = state.copyWith(trainingDays: current);
  }

  void back() {
    if (state.isFirstStep) return;
    state = state.copyWith(stepIndex: state.stepIndex - 1);
  }

  /// Attempts to advance from the current step. Returns `false` (and sets
  /// [OnboardingState.displayNameError]) when the current step's input is
  /// invalid, instead of throwing.
  bool continueFromCurrentStep() {
    if (state.stepIndex == 1) {
      final validated = _validateDisplayName();
      if (validated == null) return false;
      if (state.heightError != null || state.weightError != null) return false;
    }
    if (state.isLastStep) return true;
    state = state.copyWith(stepIndex: state.stepIndex + 1);
    return true;
  }

  /// Creates (or completes) the profile and marks onboarding complete.
  Future<void> finish() async {
    final trimmedName = _validateDisplayName();
    if (trimmedName == null) {
      state = state.copyWith(stepIndex: 1);
      return;
    }

    state = state.copyWith(isSubmitting: true, submitError: null);
    try {
      final profileRepository = ref.read(profileRepositoryProvider);
      final existing = await profileRepository.getProfile();
      final now = DateTime.now().toUtc();

      final resolvedGoals = state.fitnessGoals.isNotEmpty
          ? state.fitnessGoals
          : (state.fitnessGoal != null
                ? {state.fitnessGoal!}
                : (existing?.allFitnessGoals ?? const {}));

      final profile = UserProfile(
        id: existing?.id ?? EntityId.generate(),
        displayName: trimmedName,
        unitSystem: state.unitSystem,
        weeklyActivityGoal:
            state.weeklyActivityGoal ?? existing?.weeklyActivityGoal,
        fitnessGoal: resolvedGoals.firstOrNull,
        fitnessGoals: resolvedGoals,
        runningExperience:
            state.runningExperience ?? existing?.runningExperience,
        dateOfBirth: state.dateOfBirth ?? existing?.dateOfBirth,
        heightCm: state.heightCm ?? existing?.heightCm,
        weightKg: state.weightKg ?? existing?.weightKg,
        strengthExperience: existing?.strengthExperience,
        trainingDays: state.trainingDays.isNotEmpty
            ? state.trainingDays
            : (existing?.trainingDays ?? const {}),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      await profileRepository.saveProfile(profile);
      if (profile.weightKg != null) {
        try {
          await ref
              .read(weightRepositoryProvider)
              .saveLog(
                WeightLog(
                  id: EntityId.generate(),
                  day: LocalDate.today(),
                  weightKg: profile.weightKg!,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        } on Object catch (_) {
          // WeightLog write-through failure intentionally swallowed
        }
      }
      await ref.read(onboardingStatusProvider.notifier).markComplete();
    } on Object catch (error) {
      state = state.copyWith(submitError: userMessageFor(error));
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  /// Trims and validates the current display name, updating
  /// [OnboardingState.displayNameError] as a side effect. Returns the
  /// trimmed name when valid, `null` otherwise.
  String? _validateDisplayName() {
    final trimmed = state.displayName.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(
        displayNameError: 'Enter your name to continue.',
      );
      return null;
    }
    state = state.copyWith(displayName: trimmed, displayNameError: null);
    return trimmed;
  }
}
