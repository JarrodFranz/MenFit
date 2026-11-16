import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';

part 'blood_marker_reading.freezed.dart';

/// The kinds of blood result that can be logged. Only glucose for now; a new
/// marker is a new value here, not a new table.
enum BloodMarker {
  glucose;

  String toStorage() => name;

  static BloodMarker fromStorage(String value) => switch (value) {
    'glucose' => glucose,
    _ => throw const FormatException('Unknown blood marker.'),
  };

  String get label => switch (this) {
    glucose => 'Glucose',
  };

  /// Units a value of this marker may be entered in.
  List<BloodMarkerUnit> get units => switch (this) {
    glucose => const [BloodMarkerUnit.mmolPerL, BloodMarkerUnit.mgPerDl],
  };
}

enum BloodMarkerUnit {
  mmolPerL('mmol/L'),
  mgPerDl('mg/dL');

  const BloodMarkerUnit(this.label);

  final String label;

  String toStorage() => label;

  static BloodMarkerUnit fromStorage(String value) => switch (value) {
    'mmol/L' => mmolPerL,
    'mg/dL' => mgPerDl,
    _ => throw const FormatException('Unknown blood marker unit.'),
  };
}

/// When a glucose reading was taken. Meaningless for other markers.
enum GlucoseContext {
  fasting,
  beforeMeal,
  afterMeal,
  bedtime,
  other;

  String toStorage() => name;

  static GlucoseContext fromStorage(String value) => switch (value) {
    'fasting' => fasting,
    'beforeMeal' => beforeMeal,
    'afterMeal' => afterMeal,
    'bedtime' => bedtime,
    'other' => other,
    _ => throw const FormatException('Unknown glucose context.'),
  };

  String get label => switch (this) {
    fasting => 'Fasting',
    beforeMeal => 'Before a meal',
    afterMeal => 'After a meal (2 h or more)',
    bedtime => 'Bedtime',
    other => 'Other',
  };
}

/// A manual S3 blood result, stored as entered with its unit (no silent
/// conversion). [day] retains the chosen calendar day; timestamps are UTC.
@Freezed(toStringOverride: false)
abstract class BloodMarkerReading with _$BloodMarkerReading {
  const factory BloodMarkerReading({
    required String id,
    required LocalDate day,
    required DateTime measuredAt,
    required BloodMarker marker,
    required double value,
    required BloodMarkerUnit unit,
    required DateTime createdAt,
    required DateTime updatedAt,
    GlucoseContext? context,
    String? note,
  }) = _BloodMarkerReading;
}

/// mg/dL per mmol/L for glucose.
const glucoseMgPerDlPerMmolPerL = 18.016;

/// Converts a glucose [value] in [from] to [target]. Presentation only:
/// stored values are never converted.
double glucoseIn(BloodMarkerUnit target, double value, BloodMarkerUnit from) {
  if (target == from) return value;
  return switch (target) {
    BloodMarkerUnit.mgPerDl => value * glucoseMgPerDlPerMmolPerL,
    BloodMarkerUnit.mmolPerL => value / glucoseMgPerDlPerMmolPerL,
  };
}
