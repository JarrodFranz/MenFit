import 'dart:convert';
import 'dart:typed_data';

/// App version written into every export file.
///
/// Kept in step with `pubspec.yaml`'s `version:` by a guard test
/// (`test/features/data_export/data_export_document_test.dart`) rather than
/// read at runtime, for the same reason
/// `features/nutrition/data/open_food_facts_service.dart` does it: reading it
/// properly needs `package_info_plus`, a new dependency that would have to go
/// through the `package-evaluation` workflow to buy one string. Deliberately
/// a second constant rather than a reuse of that one — this feature may not
/// import nutrition's `data/` layer (ADR 007), and the two are only equal by
/// coincidence of both tracking the same pubspec line.
const String dataExportAppVersion = '0.1.0';

/// Value of the file's `format` field. A reader that does not recognise it
/// should refuse the file rather than guess at its shape.
const String dataExportFormatName = 'menfit-export';

/// Version of the *envelope* below — the keys of [DataExportDocument.toJson]
/// and their meaning. Independent of the database's `schemaVersion`, which
/// describes the shape of the rows inside `tables` and moves far more often.
const int dataExportFormatVersion = 1;

/// How much of their data ended up in the file. Not a report — two counts, so
/// the app can say something truthful after saving and a test can assert the
/// export was not silently empty.
class DataExportSummary {
  const DataExportSummary({required this.tableCount, required this.rowCount});

  /// Number of tables written to the file, including any that were empty.
  final int tableCount;

  /// Total rows across all of them.
  final int rowCount;

  @override
  // No setters, every field final - immutable in substance, just not
  // annotated `@immutable` (that lives in `package:meta`, and `domain/`
  // stays dependency-free per architecture_overview.md's layer rules).
  // Same suppression, same reason, as `core/domain/local_date.dart`.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      other is DataExportSummary &&
      other.tableCount == tableCount &&
      other.rowCount == rowCount;

  @override
  // Same reasoning as operator== above.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(tableCount, rowCount);

  @override
  String toString() =>
      'DataExportSummary(tableCount: $tableCount, rowCount: $rowCount)';
}

/// The whole-app export file, as a value.
///
/// **A faithful copy, not a report.** Rows arrive here exactly as the
/// database holds them — Drift's own `toJson()` maps, epoch-millisecond
/// columns still epoch milliseconds, soft-deleted rows still present — and
/// nothing in this class reformats, rounds, derives, or interprets any of
/// them. That is the point: the file has to be able to stand in for the
/// database, and anything this class "helpfully" tidied would be data they
/// could not get back. Presentation formatting belongs to screens.
///
/// Pure Dart with no Drift and no Flutter, so the file's shape is decided
/// (and tested) without a database: the data layer hands in already-converted
/// maps.
class DataExportDocument {
  const DataExportDocument({
    required this.schemaVersion,
    required this.exportedAt,
    required this.includesSensitiveHealthData,
    required this.tables,
  });

  /// Parses an export document from decoded [json].
  ///
  /// Throws [FormatException] if the format is not recognised or required
  /// fields are missing.
  factory DataExportDocument.fromJson(Map<String, Object?> json) {
    final format = json['format'];
    if (format != dataExportFormatName) {
      throw const FormatException(
        'Not a valid MenFit export file: unrecognised format.',
      );
    }

    final schema = json['schemaVersion'];
    if (schema is! int) {
      throw const FormatException('Missing or invalid schemaVersion.');
    }

    final rawExportedAt = json['exportedAt'];
    if (rawExportedAt is! String) {
      throw const FormatException('Missing or invalid exportedAt timestamp.');
    }
    final exportedAt = DateTime.tryParse(rawExportedAt);
    if (exportedAt == null) {
      throw const FormatException('Invalid ISO-8601 exportedAt timestamp.');
    }

    final rawTables = json['tables'];
    if (rawTables is! Map) {
      throw const FormatException('Missing or invalid tables payload.');
    }

    final tables = <String, List<Map<String, Object?>>>{};
    for (final entry in rawTables.entries) {
      final key = entry.key;
      final val = entry.value;
      if (key is! String || val is! List) continue;
      final rows = <Map<String, Object?>>[];
      for (final r in val) {
        if (r is Map) {
          rows.add(Map<String, Object?>.from(r));
        }
      }
      tables[key] = rows;
    }

    return DataExportDocument(
      schemaVersion: schema,
      exportedAt: exportedAt,
      includesSensitiveHealthData: json['includesSensitiveHealthData'] == true,
      tables: tables,
    );
  }

  /// Parses an export document from raw UTF-8 [bytes].
  factory DataExportDocument.fromBytes(Uint8List bytes) =>
      DataExportDocument.fromJson(decodeDataExportJson(bytes));

  /// `AppDatabase.schemaVersion` at the moment of export. Recorded because
  /// the rows below are that version's column shapes; a later reader needs it
  /// to know what it is looking at.
  final int schemaVersion;

  /// When the export was produced. Written as ISO-8601 in UTC, so a file made
  /// at 23:30 in one timezone and one made at 00:30 in another sort correctly
  /// against each other.
  final DateTime exportedAt;

  /// Whether the S3-tier tables in `sensitiveHealthTables` are included.
  ///
  /// Stated in the file itself rather than left to be inferred from the
  /// presence of the keys: absent-because-they-said-no and
  /// absent-because-they-logged-none are different facts, and a person
  /// deciding whether a file is safe to hand to someone should not have to
  /// tell them apart by squinting at it.
  final bool includesSensitiveHealthData;

  /// SQL table name -> that table's rows, each row a Drift `toJson()` map.
  final Map<String, List<Map<String, Object?>>> tables;

  DataExportSummary get summary => DataExportSummary(
    tableCount: tables.length,
    rowCount: tables.values.fold(0, (total, rows) => total + rows.length),
  );

  /// `menfit-export-2026-09-04.json` — dated by [exportedAt] in UTC, to match
  /// the `exportedAt` field inside the file. No time component and no id: a
  /// second export on the same day should visibly be the same day's export,
  /// and the OS save dialog already deals with a name that is taken.
  String get suggestedFilename {
    final date = exportedAt.toUtc().toIso8601String().substring(0, 10);
    return 'menfit-export-$date.json';
  }

  Map<String, Object?> toJson() => {
    'app': 'MenFit',
    'format': dataExportFormatName,
    'formatVersion': dataExportFormatVersion,
    'appVersion': dataExportAppVersion,
    'schemaVersion': schemaVersion,
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'includesSensitiveHealthData': includesSensitiveHealthData,
    'tables': tables,
  };

  /// UTF-8 bytes of the file, encoded on the calling isolate.
  ///
  /// Convenient for tests and for anything already off the UI thread. The
  /// app itself goes through [encodeDataExportJson] on a background isolate
  /// instead — see `application/data_export_service.dart`.
  Uint8List toBytes() => encodeDataExportJson(toJson());
}

/// Decodes an export file's UTF-8 [bytes] to a JSON map.
///
/// Top-level on purpose so `compute` can run it off the main UI isolate.
Map<String, Object?> decodeDataExportJson(Uint8List bytes) {
  final decoded = jsonDecode(utf8.decode(bytes));
  if (decoded is! Map) {
    throw const FormatException('Export file does not contain a JSON object.');
  }
  return Map<String, Object?>.from(decoded);
}

/// Encodes an export document's [json] to the file's UTF-8 bytes.
///
/// **Top-level on purpose**: this is the half of the export that costs real
/// time on a full database (a JSON encode of every row, then a UTF-8 encode
/// of the result), and `compute` can only run a top-level or static
/// function. Its argument is the plain map [DataExportDocument.toJson]
/// produces — numbers, strings, bools, lists and maps — so it crosses an
/// isolate boundary without anything special.
///
/// Pretty-printed with a two-space indent on purpose. This file is the one
/// artefact of the app they can open and read without the app, and a
/// megabyte on one line is technically the same data and practically not
/// theirs at all.
Uint8List encodeDataExportJson(Map<String, Object?> json) =>
    utf8.encode(const JsonEncoder.withIndent('  ').convert(json));
