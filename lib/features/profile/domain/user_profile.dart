import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/domain/weekday.dart';

part 'user_profile.freezed.dart';

/// A broad training goal the user can optionally set
/// (`knowledge/product/stage1_audit.md` §5.1). Never required — powers
/// nothing on its own yet (S1-4's nutrition targets and future plan
/// recommendations are the intended consumers).
enum FitnessGoal {
  generalFitness,
  runFurther,
  runFaster,
  getStronger,
  feelBetter;

  static FitnessGoal? fromStorage(String? value) {
    if (value == null) return null;
    return switch (value) {
      'generalFitness' => FitnessGoal.generalFitness,
      'runFurther' => FitnessGoal.runFurther,
      'runFaster' => FitnessGoal.runFaster,
      'getStronger' => FitnessGoal.getStronger,
      'feelBetter' => FitnessGoal.feelBetter,
      _ => null,
    };
  }

  String toStorage() => switch (this) {
    FitnessGoal.generalFitness => 'generalFitness',
    FitnessGoal.runFurther => 'runFurther',
    FitnessGoal.runFaster => 'runFaster',
    FitnessGoal.getStronger => 'getStronger',
    FitnessGoal.feelBetter => 'feelBetter',
  };

  String get label => switch (this) {
    FitnessGoal.generalFitness => 'General fitness',
    FitnessGoal.runFurther => 'Run further',
    FitnessGoal.runFaster => 'Run faster',
    FitnessGoal.getStronger => 'Get stronger',
    FitnessGoal.feelBetter => 'Feel better',
  };
}

/// A self-reported experience level, used independently for running and
/// strength training (`UserProfile.runningExperience`/`strengthExperience`)
/// — someone can be experienced at one and new to the other. Never
/// required.
enum ExperienceLevel {
  newTo,
  occasional,
  regular,
  experienced;

  static ExperienceLevel? fromStorage(String? value) {
    if (value == null) return null;
    return switch (value) {
      'newTo' => ExperienceLevel.newTo,
      'occasional' => ExperienceLevel.occasional,
      'regular' => ExperienceLevel.regular,
      'experienced' => ExperienceLevel.experienced,
      _ => null,
    };
  }

  String toStorage() => switch (this) {
    ExperienceLevel.newTo => 'newTo',
    ExperienceLevel.occasional => 'occasional',
    ExperienceLevel.regular => 'regular',
    ExperienceLevel.experienced => 'experienced',
  };

  String get label => switch (this) {
    ExperienceLevel.newTo => 'New to it',
    ExperienceLevel.occasional => 'Occasional',
    ExperienceLevel.regular => 'Regular',
    ExperienceLevel.experienced => 'Experienced',
  };
}

/// The local user's profile: display name, preferred unit system, an
/// optional weekly activity goal, and the S1-3 fitness-profile fields
/// (`knowledge/product/stage1_audit.md` §5.1) — date of birth, height,
/// weight, fitness goal, running/strength experience, and preferred
/// training days. Every field beyond [id]/[displayName]/[unitSystem] is
/// optional; the spec never forces disclosure.
///
/// [dateOfBirth]/[heightCm]/[weightKg] are S2-tier
/// (`knowledge/engineering/security_and_privacy.md`): never logged, never
/// interpolated into an exception message — see
/// `data/drift_profile_repository.dart`'s class doc.
///
/// Mirrors `core/db/tables/user_profiles.dart` one field at a time; mapping
/// to/from the Drift row happens in `data/drift_profile_repository.dart` so
/// the Drift type never leaks above the data layer (coding_standards.md).
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String displayName,
    required UnitSystem unitSystem,
    required DateTime createdAt,
    required DateTime updatedAt,

    /// Target sessions per week. `null` means no goal set yet.
    int? weeklyActivityGoal,

    /// `null` means never provided. S2-tier — see class doc.
    LocalDate? dateOfBirth,

    /// Canonical metric (centimetres). `null` means never provided.
    /// S2-tier — see class doc.
    double? heightCm,

    /// Canonical metric (kilograms). `null` means never provided.
    /// S2-tier — see class doc.
    double? weightKg,

    /// `null` means never chosen.
    FitnessGoal? fitnessGoal,

    /// Multiple chosen fitness goals. Empty set when none chosen.
    @Default(<FitnessGoal>{}) Set<FitnessGoal> fitnessGoals,

    /// `null` means never chosen.
    ExperienceLevel? runningExperience,

    /// `null` means never chosen.
    ExperienceLevel? strengthExperience,

    /// Preferred training days. An empty set means none chosen — the same
    /// as "not yet asked"; this field carries no tri-state meaning (see
    /// `core/db/tables/user_profiles.dart#trainingDays`'s doc).
    @Default(<Weekday>{}) Set<Weekday> trainingDays,
  }) = _UserProfile;

  const UserProfile._();

  /// All selected fitness goals, falling back to [fitnessGoal] if non-null.
  Set<FitnessGoal> get allFitnessGoals => fitnessGoals.isNotEmpty
      ? fitnessGoals
      : (fitnessGoal != null ? {fitnessGoal!} : const {});

  /// This profile's age in whole years on [today], derived by pure
  /// calendar-date arithmetic from [dateOfBirth] — `null` if
  /// [dateOfBirth] was never provided. Never reads the system clock itself
  /// (`knowledge/architecture/data_architecture.md`'s calendar-day
  /// semantics rule: callers pass `today` explicitly, e.g.
  /// `LocalDate.today()`, so this stays pure and testable).
  ///
  /// A birthday hasn't "happened yet" this year until [today]'s
  /// month/day reaches [dateOfBirth]'s month/day — so for a 29 February
  /// birthday, age doesn't advance until 1 March in a non-leap year (28
  /// February in a non-leap year is treated as one day before the
  /// birthday, not as the birthday itself).
  int? ageOn(LocalDate today) {
    final dob = dateOfBirth;
    if (dob == null) return null;
    var age = today.year - dob.year;
    final hadBirthdayThisYear =
        today.month > dob.month ||
        (today.month == dob.month && today.day >= dob.day);
    if (!hadBirthdayThisYear) age--;
    return age;
  }
}
