import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart';

// Plausibility limits that reject typos; not clinical judgements. Source:
// knowledge/research/blood_pressure_classification.md. One place to change.
const minSystolic = 40;
const maxSystolic = 300;
const minDiastolic = 20;
const maxDiastolic = 200;
const minPulse = 25;
const maxPulse = 250;
const maxHealthNoteLength = 280;

typedef _Bounds = ({double min, double max, String text});

/// Null when [unit] is not one of [marker]'s units.
_Bounds? _valueBounds(BloodMarker marker, BloodMarkerUnit unit) {
  if (!marker.units.contains(unit)) return null;
  return switch ((marker, unit)) {
    (BloodMarker.glucose, BloodMarkerUnit.mmolPerL) => (
      min: 0.5,
      max: 50.0,
      text: '0.5 to 50 mmol/L',
    ),
    (BloodMarker.glucose, BloodMarkerUnit.mgPerDl) => (
      min: 9.0,
      max: 900.0,
      text: '9 to 900 mg/dL',
    ),
  };
}

final _controlCharacters = RegExp(
  r'[\x00-\x1f\x7f-\x9f\u200b-\u200f\u2028-\u202e\u2060-\u206f\ufeff]',
);
final _wholeNumber = RegExp(r'^\d{1,4}$');
final _decimal = RegExp(r'^(?:\d{1,5}(?:\.\d{0,4})?|\.\d{1,4})$');

int? _parseWhole(String input) =>
    _wholeNumber.hasMatch(input) ? int.parse(input) : null;

bool _inRange(int? value, int min, int max) =>
    value != null && value >= min && value <= max;

bool _valueInRange(BloodMarker marker, BloodMarkerUnit unit, double value) {
  final bounds = _valueBounds(marker, unit);
  return bounds != null &&
      value.isFinite &&
      value >= bounds.min &&
      value <= bounds.max;
}

// The error functions below never echo the input (S3).

String? systolicError(String input) =>
    _inRange(_parseWhole(input), minSystolic, maxSystolic)
    ? null
    : 'Enter the top number (systolic) as a whole number from '
          '$minSystolic to $maxSystolic.';

String? diastolicError(String input) =>
    _inRange(_parseWhole(input), minDiastolic, maxDiastolic)
    ? null
    : 'Enter the bottom number (diastolic) as a whole number from '
          '$minDiastolic to $maxDiastolic.';

/// Empty is valid: pulse is optional.
String? pulseError(String input) =>
    input.isEmpty || _inRange(_parseWhole(input), minPulse, maxPulse)
    ? null
    : 'Enter pulse as a whole number from $minPulse to $maxPulse, '
          'or leave it blank.';

String? bloodPressurePairError(int systolic, int diastolic) =>
    systolic > diastolic
    ? null
    : 'The top number (systolic) must be higher than the bottom number '
          '(diastolic).';

String? bloodMarkerValueError(
  BloodMarker marker,
  BloodMarkerUnit unit,
  String input,
) {
  final bounds = _valueBounds(marker, unit);
  if (bounds == null) return 'Choose a unit for this reading.';
  final value = _decimal.hasMatch(input) ? double.tryParse(input) : null;
  if (value == null || !_valueInRange(marker, unit, value)) {
    return 'Enter a number from ${bounds.text}.';
  }
  return null;
}

/// Empty is valid: the note is optional. Single line only.
String? healthNoteError(String input) =>
    input.length > maxHealthNoteLength || _controlCharacters.hasMatch(input)
    ? 'Use a single-line note of up to $maxHealthNoteLength characters.'
    : null;

/// Id, calendar-day and UTC-timestamp sanity shared by both readings; same
/// rules as `isValidKetoneReading`. Future measurement times are rejected
/// at the dialog, not here, so clock corrections never strand a row.
bool _validEnvelope(
  String id,
  LocalDate day,
  DateTime measuredAt,
  DateTime createdAt,
  DateTime updatedAt,
  String? note,
) {
  if (id.isEmpty ||
      id.length > 128 ||
      id.trim() != id ||
      _controlCharacters.hasMatch(id)) {
    return false;
  }
  try {
    if (day.year < 1 || LocalDate.parse(day.toIso()) != day) return false;
  } on FormatException {
    return false;
  }
  for (final stamp in [measuredAt, createdAt, updatedAt]) {
    if (!stamp.isUtc || stamp.year < 1 || stamp.year > 9999) return false;
  }
  return !updatedAt.isBefore(createdAt) &&
      (note == null || healthNoteError(note) == null);
}

/// Shared strict boundary check for persistence and backup import.
bool isValidBloodPressureReading(BloodPressureReading r) =>
    _validEnvelope(
      r.id,
      r.day,
      r.measuredAt,
      r.createdAt,
      r.updatedAt,
      r.note,
    ) &&
    _inRange(r.systolic, minSystolic, maxSystolic) &&
    _inRange(r.diastolic, minDiastolic, maxDiastolic) &&
    (r.pulse == null || _inRange(r.pulse, minPulse, maxPulse)) &&
    bloodPressurePairError(r.systolic, r.diastolic) == null;

/// Shared strict boundary check for persistence and backup import. The unit
/// must belong to the marker and a context is only meaningful for glucose.
bool isValidBloodMarkerReading(BloodMarkerReading r) =>
    _validEnvelope(
      r.id,
      r.day,
      r.measuredAt,
      r.createdAt,
      r.updatedAt,
      r.note,
    ) &&
    _valueInRange(r.marker, r.unit, r.value) &&
    (r.context == null || r.marker == BloodMarker.glucose);
