import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';

// Copy rules for every message in this file
// (`knowledge/domain/womens_health.md`, plus the ED-safe stance
// `features/nutrition/domain/nutrition_validation.dart` already states for
// food):
//
// 1. No message praises, shames, or comments on a number. These messages
//    describe what the app can *store*, never what a body should weigh.
// 2. The bounds below are fat-finger guards on a text field — a
//    kilograms-entered-as-pounds mistake, a stray digit — not a statement
//    about any body. That is why the copy names the storable range rather
//    than telling the user her value is wrong.
// 3. S2 (`knowledge/engineering/security_and_privacy.md`): no message
//    interpolates a logged weight. The only numbers quoted are the fixed
//    constants below.

/// Result of validating a weight reading before it is saved.
///
/// A typed result value, not an exception — same convention as
/// `features/profile/domain/profile_validation.dart` and
/// `features/wellbeing/domain/wellbeing_validation.dart`.
class WeightLogValidation {
  const WeightLogValidation({this.weightError, this.dayError, this.notesError});

  final String? weightError;
  final String? dayError;
  final String? notesError;

  bool get isValid =>
      weightError == null && dayError == null && notesError == null;
}

/// Lowest weight this app will store, in kilograms.
///
/// Deliberately the same bound `features/profile/domain/profile_validation.dart`
/// applies to the profile's weight field. The two have to agree: the
/// profile writes through to this history
/// (`features/profile/presentation/profile_controller.dart`), so a value
/// one accepts and the other rejects would produce a history row that its
/// own editor refuses to re-save.
const double minLoggableWeightKg = 25;

/// Highest weight this app will store, in kilograms. Same bound, same
/// reason as [minLoggableWeightKg].
const double maxLoggableWeightKg = 350;

/// Longest note a reading may carry, in characters.
///
/// A note here is context for the reading — "morning, before breakfast",
/// "day after the race", "new scale" — not a journal entry, and the
/// history list has to stay scannable. Nothing is truncated silently: past
/// this the save is refused with the message below.
const int maxWeightNoteLength = 200;

const String _missingWeightMessage = 'Add a number to save this reading.';
const String _notANumberMessage = "That doesn't read as a number.";
const String _futureDayMessage =
    "That hasn't happened yet — pick today or an earlier day.";
const String _noteTooLongMessage =
    'Notes can be up to $maxWeightNoteLength characters.';

/// Validates a reading the user is about to save.
///
/// [weightKg] is canonical metric and `null` means "nothing parseable was
/// typed" — the caller parses at the input boundary and converts from
/// pounds itself (`presentation/weight_format.dart`). [unitSystem] governs
/// only the *wording* of the out-of-range message, so an imperial user is
/// told the bound in pounds rather than in kilograms she never typed —
/// exactly as `profile_validation.dart` does it.
///
/// [rawWeightInput] is the untrimmed text the user typed, used only to
/// tell "she left it blank" apart from "she typed something that isn't a
/// number". It is never echoed back in a message (S2).
WeightLogValidation validateWeightLog({
  required LocalDate today,
  required LocalDate day,
  double? weightKg,
  String? rawWeightInput,
  String? notes,
  UnitSystem unitSystem = UnitSystem.metric,
}) {
  return WeightLogValidation(
    weightError: _weightError(weightKg, rawWeightInput, unitSystem),
    dayError: day.isAfter(today) ? _futureDayMessage : null,
    notesError: (notes != null && notes.trim().length > maxWeightNoteLength)
        ? _noteTooLongMessage
        : null,
  );
}

String? _weightError(
  double? weightKg,
  String? rawInput,
  UnitSystem unitSystem,
) {
  if (weightKg == null) {
    final typedSomething = rawInput != null && rawInput.trim().isNotEmpty;
    return typedSomething ? _notANumberMessage : _missingWeightMessage;
  }
  if (weightKg.isNaN || weightKg.isInfinite) return _notANumberMessage;
  if (weightKg >= minLoggableWeightKg && weightKg <= maxLoggableWeightKg) {
    return null;
  }
  return unitSystem == UnitSystem.imperial
      ? 'Weight readings can be between '
            '${UnitConversions.kgToLb(minLoggableWeightKg).ceil()} and '
            '${UnitConversions.kgToLb(maxLoggableWeightKg).floor()} lb.'
      : 'Weight readings can be between '
            '${minLoggableWeightKg.toStringAsFixed(0)} and '
            '${maxLoggableWeightKg.toStringAsFixed(0)} kg.';
}
