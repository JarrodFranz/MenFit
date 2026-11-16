import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart'
    as health;
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart'
    as health;
import 'package:menfit_app/features/health/domain/health_reading_validation.dart';
import 'package:menfit_app/features/keto/domain/ketone_reading.dart' as keto;
import 'package:menfit_app/features/keto/domain/ketone_validation.dart';

/// Checks every S3 manual-reading row before the import transaction starts,
/// so a bad row cannot leave a half-replaced database. Each rule set: an
/// absent table leaves current data alone; a present table needs the
/// sensitive flag; every row is type-checked and run through the domain
/// validator; duplicate ids are rejected. Errors are static (no row values).
void validateSensitiveImportRows(DataExportDocument document) {
  _validateKetoneRows(document);
  _validateBloodPressureRows(document);
  _validateBloodMarkerRows(document);
}

List<Map<String, Object?>>? _sensitiveRows(
  DataExportDocument document,
  String table,
) {
  final rows = document.tables[table];
  if (rows != null && !document.includesSensitiveHealthData) {
    throw const FormatException('Sensitive table requires explicit inclusion.');
  }
  return rows;
}

DateTime _utc(Object? ms) =>
    DateTime.fromMillisecondsSinceEpoch(ms! as int, isUtc: true);

bool _hasEnvelope(Map<String, Object?> row) =>
    row['id'] is String &&
    row['day'] is String &&
    row['measured_at'] is int &&
    row['created_at'] is int &&
    row['updated_at'] is int &&
    (row['note'] == null || row['note'] is String);

void _validateKetoneRows(DataExportDocument document) {
  final rows = _sensitiveRows(document, 'ketone_readings');
  if (rows == null) return;
  final ids = <String>{};
  for (final row in rows) {
    if (row['id'] is! String ||
        row['day'] is! String ||
        row['type'] is! String ||
        row['result'] is! String ||
        row['measured_at'] is! int ||
        row['created_at'] is! int ||
        row['updated_at'] is! int) {
      throw const FormatException('Invalid ketone row.');
    }
    final reading = keto.KetoneReading(
      id: row['id']! as String,
      day: LocalDate.parse(row['day']! as String),
      type: keto.KetoneMeasurementType.fromStorage(row['type']! as String),
      result: row['result']! as String,
      measuredAt: _utc(row['measured_at']),
      createdAt: _utc(row['created_at']),
      updatedAt: _utc(row['updated_at']),
    );
    if (!isValidKetoneReading(reading) || !ids.add(reading.id)) {
      throw const FormatException('Invalid ketone row.');
    }
  }
}

void _validateBloodPressureRows(DataExportDocument document) {
  final rows = _sensitiveRows(document, 'blood_pressure_readings');
  if (rows == null) return;
  final ids = <String>{};
  for (final row in rows) {
    if (!_hasEnvelope(row) ||
        row['systolic'] is! int ||
        row['diastolic'] is! int ||
        (row['pulse'] != null && row['pulse'] is! int)) {
      throw const FormatException('Invalid blood pressure row.');
    }
    final reading = health.BloodPressureReading(
      id: row['id']! as String,
      day: LocalDate.parse(row['day']! as String),
      measuredAt: _utc(row['measured_at']),
      systolic: row['systolic']! as int,
      diastolic: row['diastolic']! as int,
      pulse: row['pulse'] as int?,
      note: row['note'] as String?,
      createdAt: _utc(row['created_at']),
      updatedAt: _utc(row['updated_at']),
    );
    if (!isValidBloodPressureReading(reading) || !ids.add(reading.id)) {
      throw const FormatException('Invalid blood pressure row.');
    }
  }
}

void _validateBloodMarkerRows(DataExportDocument document) {
  final rows = _sensitiveRows(document, 'blood_marker_readings');
  if (rows == null) return;
  final ids = <String>{};
  for (final row in rows) {
    // JSON may decode a whole-number REAL as int, so accept any num.
    if (!_hasEnvelope(row) ||
        row['marker'] is! String ||
        row['value'] is! num ||
        row['unit'] is! String ||
        (row['context'] != null && row['context'] is! String)) {
      throw const FormatException('Invalid blood reading row.');
    }
    final context = row['context'] as String?;
    final reading = health.BloodMarkerReading(
      id: row['id']! as String,
      day: LocalDate.parse(row['day']! as String),
      measuredAt: _utc(row['measured_at']),
      marker: health.BloodMarker.fromStorage(row['marker']! as String),
      value: (row['value']! as num).toDouble(),
      unit: health.BloodMarkerUnit.fromStorage(row['unit']! as String),
      context: context == null
          ? null
          : health.GlucoseContext.fromStorage(context),
      note: row['note'] as String?,
      createdAt: _utc(row['created_at']),
      updatedAt: _utc(row['updated_at']),
    );
    if (!isValidBloodMarkerReading(reading) || !ids.add(reading.id)) {
      throw const FormatException('Invalid blood reading row.');
    }
  }
}
