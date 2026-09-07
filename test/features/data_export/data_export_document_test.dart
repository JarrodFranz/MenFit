import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';

DataExportDocument _document({
  int schemaVersion = 24,
  DateTime? exportedAt,
  bool includesCycleAndWellbeingData = false,
  Map<String, List<Map<String, Object?>>>? tables,
}) {
  return DataExportDocument(
    schemaVersion: schemaVersion,
    exportedAt: exportedAt ?? DateTime.utc(2026, 9, 4, 10, 30),
    includesCycleAndWellbeingData: includesCycleAndWellbeingData,
    tables:
        tables ??
        {
          'weight_logs': [
            {'id': 'weight-1', 'day': '2026-01-02', 'weight_kg': 63.2},
          ],
          'foods': const <Map<String, Object?>>[],
        },
  );
}

void main() {
  group('envelope', () {
    test('names the app, the format and both versions', () {
      final json = _document().toJson();

      expect(json['app'], 'FemFit');
      expect(json['format'], 'femfit-export');
      expect(json['formatVersion'], 1);
      expect(json['appVersion'], dataExportAppVersion);
      expect(json['schemaVersion'], 24);
    });

    test('exportedAt is ISO-8601 in UTC even when built from a local time', () {
      // A local DateTime with a non-zero offset would serialise without a
      // `Z` and read as a different instant to whoever opens the file.
      final local = DateTime(2026, 9, 4, 10, 30);
      final json = _document(exportedAt: local).toJson();

      expect(json['exportedAt'], local.toUtc().toIso8601String());
      expect(json['exportedAt'], endsWith('Z'));
    });

    test(
      'says whether cycle and wellbeing data is in it, both ways round',
      () {
        expect(
          _document().toJson()['includesCycleAndWellbeingData'],
          isFalse,
        );
        expect(
          _document(
            includesCycleAndWellbeingData: true,
          ).toJson()['includesCycleAndWellbeingData'],
          isTrue,
        );
      },
    );

    test('rows are carried through untouched, epoch millis included', () {
      final json = _document(
        tables: {
          'activities': [
            {
              'id': 'activity-1',
              'started_at': 1767225600000,
              'distance_meters': 4000.5,
              'deleted_at': null,
            },
          ],
        },
      ).toJson();

      final tables = json['tables']! as Map<String, Object?>;
      final rows = tables['activities']! as List<Object?>;
      final row = rows.single! as Map<String, Object?>;

      // Not reformatted into a date, not rounded, not dropped for being
      // null: this is a copy of the database, not a report about it.
      expect(row['started_at'], 1767225600000);
      expect(row['distance_meters'], 4000.5);
      expect(row.containsKey('deleted_at'), isTrue);
      expect(row['deleted_at'], isNull);
    });
  });

  group('summary', () {
    test('counts every table, including empty ones, and every row', () {
      final summary = _document(
        tables: {
          'a': [
            {'id': '1'},
            {'id': '2'},
          ],
          'b': const <Map<String, Object?>>[],
          'c': [
            {'id': '3'},
          ],
        },
      ).summary;

      expect(summary.tableCount, 3);
      expect(summary.rowCount, 3);
      expect(summary, const DataExportSummary(tableCount: 3, rowCount: 3));
    });
  });

  group('filename', () {
    test('is dated by exportedAt in UTC', () {
      expect(
        _document(exportedAt: DateTime.utc(2026, 9, 4, 10, 30))
            .suggestedFilename,
        'femfit-export-2026-09-04.json',
      );
    });

    test('uses the UTC date, not the local one, so it matches the file', () {
      // 2026-09-04 23:30 UTC is already the 5th in some zones and still the
      // 4th in others; the name has to agree with `exportedAt` inside.
      final document = _document(exportedAt: DateTime.utc(2026, 9, 4, 23, 30));
      expect(document.suggestedFilename, 'femfit-export-2026-09-04.json');
      expect(
        document.toJson()['exportedAt'],
        startsWith('2026-09-04'),
      );
    });
  });

  group('bytes', () {
    test('are UTF-8 JSON that parses back to the same document', () {
      final document = _document();
      final decoded =
          jsonDecode(utf8.decode(document.toBytes())) as Map<String, Object?>;

      expect(decoded['app'], 'FemFit');
      expect(decoded['schemaVersion'], 24);
      final tables = decoded['tables']! as Map<String, Object?>;
      expect(tables.keys, containsAll(<String>['weight_logs', 'foods']));
    });

    test('are pretty-printed so she can read the file without the app', () {
      final text = utf8.decode(_document().toBytes());

      expect(text, contains('\n'));
      expect(text, contains('  "app": "FemFit"'));
    });

    test('survive non-ASCII text in a row', () {
      final text = utf8.decode(
        _document(
          tables: {
            'foods': [
              {'name': 'Crème fraîche — 200g'},
            ],
          },
        ).toBytes(),
      );

      expect(text, contains('Crème fraîche — 200g'));
    });
  });

  test('the advertised app version matches pubspec.yaml', () {
    // Guard test for a hand-maintained constant that ships inside every
    // export file, where a stale value is worse than none: it tells whoever
    // reads the file the wrong thing about which app wrote it. Same pattern
    // as `openFoodFactsClientVersion` in
    // `test/features/nutrition/open_food_facts_service_test.dart`.
    final versionLine = File(
      'pubspec.yaml',
    ).readAsLinesSync().firstWhere((line) => line.startsWith('version:'));
    final version = versionLine.split(':').last.trim().split('+').first;

    expect(dataExportAppVersion, version);
  });

  group('deserialisation', () {
    test('round-trips through toJson -> fromJson losslessly', () {
      final original = _document(
        includesCycleAndWellbeingData: true,
        tables: {
          'activities': [
            {'id': 'act-1', 'title': 'Morning Run', 'distance_meters': 5000.0},
          ],
        },
      );

      final decoded = DataExportDocument.fromJson(original.toJson());
      expect(decoded.schemaVersion, original.schemaVersion);
      expect(decoded.exportedAt, original.exportedAt);
      expect(
        decoded.includesCycleAndWellbeingData,
        original.includesCycleAndWellbeingData,
      );
      expect(decoded.tables.length, 1);
      expect(decoded.tables['activities']!.first['title'], 'Morning Run');
      expect(decoded.summary.rowCount, 1);
      expect(decoded.summary.tableCount, 1);
    });

    test('round-trips through toBytes -> fromBytes', () {
      final original = _document();
      final bytes = original.toBytes();
      final decoded = DataExportDocument.fromBytes(bytes);

      expect(decoded.schemaVersion, original.schemaVersion);
      expect(decoded.suggestedFilename, original.suggestedFilename);
      expect(decoded.summary.rowCount, original.summary.rowCount);
    });

    test('rejects unexpected format', () {
      final json = _document().toJson()..['format'] = 'other-app-export';
      expect(
        () => DataExportDocument.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects missing or invalid schemaVersion', () {
      final json = _document().toJson()..remove('schemaVersion');
      expect(
        () => DataExportDocument.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects missing or invalid exportedAt', () {
      final json = _document().toJson()..['exportedAt'] = 'not-a-date';
      expect(
        () => DataExportDocument.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects invalid tables payload', () {
      final json = _document().toJson()..['tables'] = 'not-a-map';
      expect(
        () => DataExportDocument.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects bytes that are not a JSON object', () {
      final bytes = Uint8List.fromList(utf8.encode('[1, 2, 3]'));
      expect(
        () => DataExportDocument.fromBytes(bytes),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
