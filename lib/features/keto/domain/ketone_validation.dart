import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/keto/domain/ketone_reading.dart';

/// Storage/input bounds, not physiological limits or clinical thresholds.
const maxKetoneResultLength = 40;

final _controlCharacters = RegExp(
  r'[\x00-\x1f\x7f-\x9f\u200b-\u200f\u2028-\u202e\u2060-\u206f\ufeff]',
);
final _numericResult = RegExp(r'^\+?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$');

/// Validates without normalising or echoing sensitive result text.
String? ketoneResultError(KetoneMeasurementType type, String result) {
  if (result.isEmpty || result.trim() != result) {
    return 'Enter the result shown by your device or strip.';
  }
  if (result.length > maxKetoneResultLength ||
      _controlCharacters.hasMatch(result)) {
    return 'Use a short, single-line result (up to 40 characters).';
  }
  if (type == KetoneMeasurementType.urine) return null;
  if (result == 'LO' || result == 'HI') return null;
  final number = double.tryParse(result);
  if (!_numericResult.hasMatch(result) ||
      number == null ||
      !number.isFinite ||
      number < 0) {
    return 'Enter a non-negative number, LO or HI.';
  }
  return null;
}

/// Shared strict boundary check for persistence and backup import.
/// Does not compare [KetoneReading.day] with the current timezone: travel
/// must not change the calendar day originally chosen by the user.
/// Device clock corrections must not make archived readings uneditable.
bool isValidKetoneReading(KetoneReading reading) {
  if (reading.id.isEmpty ||
      reading.id.length > 128 ||
      reading.id.trim() != reading.id ||
      _controlCharacters.hasMatch(reading.id)) {
    return false;
  }
  try {
    if (reading.day.year < 1 ||
        LocalDate.parse(reading.day.toIso()) != reading.day) {
      return false;
    }
  } on FormatException {
    return false;
  }
  for (final stamp in [
    reading.measuredAt,
    reading.createdAt,
    reading.updatedAt,
  ]) {
    if (!stamp.isUtc || stamp.year < 1 || stamp.year > 9999) return false;
  }
  return !reading.updatedAt.isBefore(reading.createdAt) &&
      ketoneResultError(reading.type, reading.result) == null;
}
