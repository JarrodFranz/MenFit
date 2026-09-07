import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';

/// Result of validating the S1-3 fitness-profile fields being edited.
///
/// A typed result value, not an exception — same convention as
/// `features/wellbeing/domain/wellbeing_validation.dart`'s
/// `CheckinValidation`/`FlareValidation`.
class ProfileValidation {
  const ProfileValidation({
    this.dateOfBirthError,
    this.heightError,
    this.weightError,
  });

  final String? dateOfBirthError;
  final String? heightError;
  final String? weightError;

  bool get isValid =>
      dateOfBirthError == null && heightError == null && weightError == null;
}

/// The earliest date of birth accepted — not a real constraint on human
/// age, just a sanity bound against fat-fingered input (e.g. a typo'd
/// year), per the spec's "wide, non-judgemental bounds" instruction.
final LocalDate _earliestDateOfBirth = LocalDate(1900, 1, 1);

const double _minHeightCm = 90;
const double _maxHeightCm = 250;
const double _minWeightKg = 25;
const double _maxWeightKg = 350;

/// Validates the optional fitness-profile fields:
///
/// - [dateOfBirth], when present, must not be in the future relative to
///   [today] and must be on or after 1 January 1900.
/// - [heightCm]/[weightKg], when present, must fall within wide,
///   non-judgemental bounds (spec §5.1) — these exist only to catch
///   fat-fingered input (e.g. a unit-conversion mistake at the input
///   boundary), not to gatekeep any particular body size.
///
/// Values are always passed in canonical metric units; [unitSystem] governs
/// only the *wording* of the resulting message, so an imperial user is told
/// the bound in ft/in and lb rather than in cm and kg they never typed.
///
/// All three fields are optional — passing `null` for any of them is
/// always valid (the app never forces disclosure).
ProfileValidation validateProfileFields({
  required LocalDate today,
  LocalDate? dateOfBirth,
  double? heightCm,
  double? weightKg,
  UnitSystem unitSystem = UnitSystem.metric,
}) {
  return ProfileValidation(
    dateOfBirthError: _dateOfBirthError(dateOfBirth, today),
    heightError: _heightError(heightCm, unitSystem),
    weightError: _weightError(weightKg, unitSystem),
  );
}

String? _dateOfBirthError(LocalDate? dateOfBirth, LocalDate today) {
  if (dateOfBirth == null) return null;
  if (dateOfBirth.isAfter(today)) {
    return "That hasn't happened yet — pick a date that's today or earlier.";
  }
  if (dateOfBirth.isBefore(_earliestDateOfBirth)) {
    return 'Pick a date after 1 January 1900.';
  }
  return null;
}

String? _heightError(double? heightCm, UnitSystem unitSystem) {
  if (heightCm == null) return null;
  if (heightCm >= _minHeightCm && heightCm <= _maxHeightCm) return null;
  final low = _feetInchesLabel(_minHeightCm, round: _Round.inwardUp);
  final high = _feetInchesLabel(_maxHeightCm, round: _Round.inwardDown);
  return unitSystem == UnitSystem.imperial
      ? 'Height should be between $low and $high.'
      : 'Height should be between ${_minHeightCm.toStringAsFixed(0)} and '
            '${_maxHeightCm.toStringAsFixed(0)} cm.';
}

String? _weightError(double? weightKg, UnitSystem unitSystem) {
  if (weightKg == null) return null;
  if (weightKg >= _minWeightKg && weightKg <= _maxWeightKg) return null;
  // "can be", never "should be": this field is now an entry point into the
  // weight history (the profile writes through to a log — see
  // `presentation/profile_controller.dart`), so it inherits that feature's
  // copy rules. "Should" states what a body ought to weigh; "can" states
  // what this app is able to store, which is the only thing a fat-finger
  // bound is about. Same wording as
  // `features/weight/domain/weight_validation.dart`, deliberately.
  return unitSystem == UnitSystem.imperial
      ? 'Weight can be between '
            '${UnitConversions.kgToLb(_minWeightKg).ceil()} and '
            '${UnitConversions.kgToLb(_maxWeightKg).floor()} lb.'
      : 'Weight can be between ${_minWeightKg.toStringAsFixed(0)} and '
            '${_maxWeightKg.toStringAsFixed(0)} kg.';
}

/// Which way to round a bound when restating it in whole imperial units.
///
/// Always *inward* (towards the accepted range), so the number quoted back
/// to the user is itself accepted — rounding 90 cm outward to `2 ft 11 in`
/// would name a height the validator then rejects.
enum _Round { inwardUp, inwardDown }

String _feetInchesLabel(double cm, {required _Round round}) {
  // Round the *total* inches, not the remainder, so the ft/in pair stays
  // consistent (rounding 35.4 in up to 36 must read "3 ft 0 in", never
  // "2 ft 12 in").
  final exactInches = UnitConversions.cmToInches(cm);
  final wholeInches = round == _Round.inwardUp
      ? exactInches.ceil()
      : exactInches.floor();
  return '${wholeInches ~/ 12} ft ${wholeInches % 12} in';
}
