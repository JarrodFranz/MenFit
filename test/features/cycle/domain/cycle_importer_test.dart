import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/domain/import_export/cycle_exporter.dart';
import 'package:menfit_app/features/cycle/domain/import_export/cycle_importer.dart';

void main() {
  group('CsvCycleImporter', () {
    const importer = CsvCycleImporter();

    test('parses standard start/end date CSV with ISO format', () async {
      const csv = '''
Period Start,Period End,Duration
2026-05-01,2026-05-05,5
2026-05-29,2026-06-02,5
2026-06-26,2026-06-30,5
''';

      final result = await importer.parse(csv);

      expect(result.isSuccess, isTrue);
      expect(result.records.length, 3);
      expect(result.records[0].periodStart, LocalDate(2026, 5, 1));
      expect(result.records[0].periodEnd, LocalDate(2026, 5, 5));
      expect(result.records[1].periodStart, LocalDate(2026, 5, 29));
      expect(result.records[2].periodStart, LocalDate(2026, 6, 26));
    });

    test('groups consecutive single date logs into period spans', () async {
      const csv = '''
Date,Flow
2026-07-01,Heavy
2026-07-02,Medium
2026-07-03,Medium
2026-07-04,Light
2026-07-05,Spotting
2026-07-29,Heavy
2026-07-30,Medium
2026-07-31,Light
''';

      final result = await importer.parse(csv);

      expect(result.isSuccess, isTrue);
      expect(result.records.length, 2);
      expect(result.records[0].periodStart, LocalDate(2026, 7, 1));
      expect(result.records[0].periodEnd, LocalDate(2026, 7, 5));
      expect(result.records[1].periodStart, LocalDate(2026, 7, 29));
      expect(result.records[1].periodEnd, LocalDate(2026, 7, 31));
    });

    test('skips duplicates against existing records', () async {
      final existing = [
        CycleRecord(
          id: '1',
          periodStart: LocalDate(2026, 5, 1),
          periodEnd: LocalDate(2026, 5, 5),
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      ];

      const csv = '''
Period Start,Period End
2026-05-01,2026-05-05
2026-06-01,2026-06-05
''';

      final result = await importer.parse(csv, existingRecords: existing);

      expect(result.isSuccess, isTrue);
      expect(result.records.length, 1);
      expect(result.skippedDuplicates, 1);
      expect(result.records.first.periodStart, LocalDate(2026, 6, 1));
    });
  });

  group('JsonCycleImporter & CycleDataExporter', () {
    const jsonImporter = JsonCycleImporter();
    const exporter = CycleDataExporter();

    test('exports to JSON and round-trips via JsonCycleImporter', () async {
      final now = DateTime.utc(2026, 8, 29);
      final records = [
        CycleRecord(
          id: 'c1',
          periodStart: LocalDate(2026, 5, 1),
          periodEnd: LocalDate(2026, 5, 5),
          createdAt: now,
          updatedAt: now,
        ),
        CycleRecord(
          id: 'c2',
          periodStart: LocalDate(2026, 5, 29),
          periodEnd: LocalDate(2026, 6, 2),
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final jsonStr = exporter.exportToJson(records);
      final importResult = await jsonImporter.parse(jsonStr);

      expect(importResult.isSuccess, isTrue);
      expect(importResult.records.length, 2);
      expect(importResult.records[0].periodStart, LocalDate(2026, 5, 1));
      expect(importResult.records[1].periodStart, LocalDate(2026, 5, 29));
    });

    test('exports to CSV properly', () {
      final now = DateTime.utc(2026, 8, 29);
      final records = [
        CycleRecord(
          id: 'c1',
          periodStart: LocalDate(2026, 5, 1),
          periodEnd: LocalDate(2026, 5, 5),
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final csvStr = exporter.exportToCsv(records);
      expect(csvStr.contains('2026-05-01,2026-05-05,5,Completed'), isTrue);
    });
  });
}
