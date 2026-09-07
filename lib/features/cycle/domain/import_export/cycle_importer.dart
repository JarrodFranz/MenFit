import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';

/// Result of an import operation.
class CycleImportResult {
  const CycleImportResult({
    required this.records,
    this.skippedDuplicates = 0,
    this.warnings = const [],
    this.errorMessage,
  });

  final List<CycleRecord> records;
  final int skippedDuplicates;
  final List<String> warnings;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null && records.isNotEmpty;
  int get importedCount => records.length;
}

/// Abstract contract for modular cycle data importers.
abstract class CycleDataImporter {
  String get formatName;
  String get fileExtension;

  Future<CycleImportResult> parse(
    String content, {
    List<CycleRecord> existingRecords = const [],
  });
}

/// Guided CSV importer supporting FemFit, Clue, Flo, and Apple Health CSVs.
class CsvCycleImporter implements CycleDataImporter {
  const CsvCycleImporter({
    this.startDateColumnIndex,
    this.endDateColumnIndex,
    this.dateFormatPattern,
  });

  final int? startDateColumnIndex;
  final int? endDateColumnIndex;
  final String? dateFormatPattern;

  @override
  String get formatName => 'CSV (Spreadsheet)';

  @override
  String get fileExtension => '.csv';

  @override
  Future<CycleImportResult> parse(
    String content, {
    List<CycleRecord> existingRecords = const [],
  }) async {
    final lines = const LineSplitter()
        .convert(content)
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return const CycleImportResult(
        records: [],
        errorMessage: 'The CSV file is empty.',
      );
    }

    final now = DateTime.now().toUtc();
    final headerRow = _splitCsvLine(lines.first)
        .map((c) => c.toLowerCase().trim())
        .toList();

    var startCol = startDateColumnIndex;
    var endCol = endDateColumnIndex;

    if (startCol == null) {
      // Auto-detect start date column
      for (var i = 0; i < headerRow.length; i++) {
        final h = headerRow[i];
        if (h.contains('start') ||
            h.contains('period_start') ||
            h == 'date' ||
            h.contains('start_date')) {
          startCol = i;
          break;
        }
      }
      startCol ??= 0; // Fallback to first column
    }

    if (endCol == null) {
      // Auto-detect end date column
      for (var i = 0; i < headerRow.length; i++) {
        final h = headerRow[i];
        if (h.contains('end') ||
            h.contains('period_end') ||
            h.contains('end_date')) {
          endCol = i;
          break;
        }
      }
    }

    final rawPeriods = <_RawPeriodSpan>[];
    final singleDates = <LocalDate>[];
    final warnings = <String>[];
    var skipped = 0;

    // Process data rows
    final dataRows = (lines.length > 1 && _isHeader(headerRow))
        ? lines.sublist(1)
        : lines;

    for (var rowIdx = 0; rowIdx < dataRows.length; rowIdx++) {
      final cols = _splitCsvLine(dataRows[rowIdx]);
      if (cols.length <= startCol) continue;

      final startStr = cols[startCol].trim();
      final startDate = _parseDate(startStr, dateFormatPattern);
      if (startDate == null) continue;

      LocalDate? endDate;
      if (endCol != null && endCol < cols.length) {
        final endStr = cols[endCol].trim();
        if (endStr.isNotEmpty) {
          endDate = _parseDate(endStr, dateFormatPattern);
        }
      }

      if (endDate != null) {
        if (endDate.isBefore(startDate)) {
          warnings.add(
            'Row ${rowIdx + 1}: End date is before start date; swapped.',
          );
          final temp = startDate;
          rawPeriods.add(_RawPeriodSpan(start: endDate, end: temp));
        } else {
          rawPeriods.add(_RawPeriodSpan(start: startDate, end: endDate));
        }
      } else {
        singleDates.add(startDate);
      }
    }

    // Group consecutive single dates into period spans
    if (singleDates.isNotEmpty) {
      singleDates.sort();
      var spanStart = singleDates.first;
      var prevDate = singleDates.first;

      for (var i = 1; i < singleDates.length; i++) {
        final curr = singleDates[i];
        if (curr == prevDate) continue; // duplicate day

        final daysDiff = prevDate.difference(curr);
        if (daysDiff == 1) {
          // Consecutive day
          prevDate = curr;
        } else {
          // Gap -> end current period span
          rawPeriods.add(_RawPeriodSpan(start: spanStart, end: prevDate));
          spanStart = curr;
          prevDate = curr;
        }
      }
      rawPeriods.add(_RawPeriodSpan(start: spanStart, end: prevDate));
    }

    // Deduplicate against existing records
    final importedRecords = <CycleRecord>[];
    for (final raw in rawPeriods) {
      final isDuplicate = existingRecords.any(
        (existing) =>
            existing.periodStart == raw.start &&
            (existing.periodEnd == raw.end ||
                (existing.periodEnd == null && raw.end == null)),
      );

      if (isDuplicate) {
        skipped++;
      } else {
        importedRecords.add(
          CycleRecord(
            id: EntityId.generate(),
            periodStart: raw.start,
            periodEnd: raw.end,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }

    // Sort chronologically
    importedRecords.sort((a, b) => a.periodStart.compareTo(b.periodStart));

    if (importedRecords.isEmpty && skipped == 0) {
      return const CycleImportResult(
        records: [],
        errorMessage: 'Could not find valid period dates in the CSV file.',
      );
    }

    return CycleImportResult(
      records: importedRecords,
      skippedDuplicates: skipped,
      warnings: warnings,
    );
  }

  bool _isHeader(List<String> row) {
    return row.any(
      (c) =>
          c.contains('date') ||
          c.contains('start') ||
          c.contains('period') ||
          c.contains('end'),
    );
  }

  LocalDate? _parseDate(String raw, String? explicitPattern) {
    var cleaned = raw.replaceAll('"', '').replaceAll("'", '').trim();
    if (cleaned.contains('T')) cleaned = cleaned.split('T')[0];
    if (cleaned.contains(' ')) cleaned = cleaned.split(' ')[0];

    if (explicitPattern != null) {
      try {
        final dt = DateFormat(explicitPattern).parseLoose(cleaned);
        return LocalDate(dt.year, dt.month, dt.day);
      } on Object catch (_) {}
    }

    // Common patterns
    final patterns = [
      'yyyy-MM-dd',
      'yyyy/MM/dd',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'd/M/yyyy',
      'M/d/yyyy',
      'yyyy.MM.dd',
    ];

    for (final p in patterns) {
      try {
        final dt = DateFormat(p).parseLoose(cleaned);
        return LocalDate(dt.year, dt.month, dt.day);
      } on Object catch (_) {}
    }

    return null;
  }

  List<String> _splitCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    result.add(buffer.toString());
    return result;
  }
}

/// JSON cycle importer supporting standard FemFit JSON and generic arrays.
class JsonCycleImporter implements CycleDataImporter {
  const JsonCycleImporter();

  @override
  String get formatName => 'JSON Format';

  @override
  String get fileExtension => '.json';

  @override
  Future<CycleImportResult> parse(
    String content, {
    List<CycleRecord> existingRecords = const [],
  }) async {
    try {
      final dynamic decoded = jsonDecode(content);
      List<dynamic> items;

      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map<String, dynamic> &&
          decoded['records'] is List) {
        items = decoded['records'] as List<dynamic>;
      } else if (decoded is Map<String, dynamic> && decoded['cycles'] is List) {
        items = decoded['cycles'] as List<dynamic>;
      } else {
        return const CycleImportResult(
          records: [],
          errorMessage:
              'Invalid JSON structure: expected an array of cycle records.',
        );
      }

      final now = DateTime.now().toUtc();
      final imported = <CycleRecord>[];
      var skipped = 0;

      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;

        final startStr =
            (item['periodStart'] ??
                    item['start'] ??
                    item['startDate'] ??
                    item['date'])
                ?.toString();
        final endStr = (item['periodEnd'] ?? item['end'] ?? item['endDate'])
            ?.toString();

        if (startStr == null || startStr.isEmpty) continue;

        try {
          final startDate = LocalDate.parse(startStr.split('T')[0]);
          final endDate = (endStr != null && endStr.isNotEmpty)
              ? LocalDate.parse(endStr.split('T')[0])
              : null;

          final isDuplicate = existingRecords.any(
            (e) =>
                e.periodStart == startDate &&
                (e.periodEnd == endDate ||
                    (e.periodEnd == null && endDate == null)),
          );

          if (isDuplicate) {
            skipped++;
          } else {
            imported.add(
              CycleRecord(
                id: item['id']?.toString() ?? EntityId.generate(),
                periodStart: startDate,
                periodEnd: endDate,
                createdAt: now,
                updatedAt: now,
              ),
            );
          }
        } on Object catch (_) {
          continue;
        }
      }

      imported.sort((a, b) => a.periodStart.compareTo(b.periodStart));

      return CycleImportResult(
        records: imported,
        skippedDuplicates: skipped,
      );
    } on Object catch (e) {
      return CycleImportResult(
        records: [],
        errorMessage: 'JSON parse error: $e',
      );
    }
  }
}

class _RawPeriodSpan {
  const _RawPeriodSpan({required this.start, this.end});
  final LocalDate start;
  final LocalDate? end;
}
