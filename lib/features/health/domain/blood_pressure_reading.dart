import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/domain/local_date.dart';

part 'blood_pressure_reading.freezed.dart';

/// A manual S3 blood-pressure measurement in mmHg (pulse in bpm).
/// [day] retains the chosen calendar day; timestamps are UTC instants.
@Freezed(toStringOverride: false)
abstract class BloodPressureReading with _$BloodPressureReading {
  const factory BloodPressureReading({
    required String id,
    required LocalDate day,
    required DateTime measuredAt,
    required int systolic,
    required int diastolic,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? pulse,
    String? note,
  }) = _BloodPressureReading;
}
