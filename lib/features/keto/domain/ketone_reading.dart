import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';

part 'ketone_reading.freezed.dart';

/// Distinct measurement methods; values must never be converted between them.
enum KetoneMeasurementType {
  blood,
  urine,
  breath;

  String toStorage() => name;

  static KetoneMeasurementType fromStorage(String value) => switch (value) {
    'blood' => blood,
    'urine' => urine,
    'breath' => breath,
    _ => throw const FormatException('Unknown ketone measurement method.'),
  };

  String get label => switch (this) {
    blood => 'Blood',
    urine => 'Urine',
    breath => 'Breath',
  };

  String get unit => switch (this) {
    blood => 'mmol/L',
    urine => 'as printed',
    breath => 'ppm',
  };
}

/// An uninterpreted, manual S3 reading. Text preserves precision and LO/HI.
/// [day] retains the chosen calendar day; timestamps are UTC instants.
@Freezed(toStringOverride: false)
abstract class KetoneReading with _$KetoneReading {
  const factory KetoneReading({
    required String id,
    required LocalDate day,
    required DateTime measuredAt,
    required KetoneMeasurementType type,
    required String result,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _KetoneReading;
}
