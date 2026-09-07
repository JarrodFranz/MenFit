import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/data_export/application/data_export_service.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';
import 'package:menfit_app/features/data_export/domain/data_export_result.dart';
import 'package:menfit_app/features/data_export/domain/data_export_source.dart';

class _FixedSource implements DataExportSource {
  @override
  int get schemaVersion => 24;

  @override
  Future<Map<String, List<Map<String, Object?>>>> readTables({
    required bool includeCycleAndWellbeing,
  }) async => {
    'weight_logs': [
      {'id': 'weight-1', 'weight_kg': 63.2},
    ],
  };
}

void main() {
  group('the encoding seam', () {
    test(
      "the result carries the encoder's buffer, not a copy of it",
      () async {
        // A whole-database export is the one buffer in this app big enough for
        // a needless copy to matter, and it is copied nowhere between here and
        // the save dialog.
        final encoded = Uint8List.fromList([1, 2, 3]);
        final service = DataExportService(
          source: _FixedSource(),
          encode: (_) async => encoded,
        );

        final result = await service.export(includeCycleAndWellbeing: false);

        expect(
          identical((result as DataExported).bytes, encoded),
          isTrue,
          reason: 'the bytes must be handed through, not reallocated',
        );
      },
    );

    test('the encoder is handed the plain JSON map, nothing richer', () async {
      // What makes the background isolate legal: everything crossing the
      // boundary is primitives, lists and maps.
      Map<String, Object?>? seen;
      final service = DataExportService(
        source: _FixedSource(),
        clock: () => DateTime.utc(2026, 9, 4, 12),
        encode: (json) async {
          seen = json;
          return Uint8List(0);
        },
      );

      await service.export(includeCycleAndWellbeing: true);

      expect(seen, isNotNull);
      expect(seen!['format'], 'menfit-export');
      expect(seen!['schemaVersion'], 24);
      expect(seen!['includesCycleAndWellbeingData'], isTrue);
      expect(seen!['tables'], isA<Map<String, Object?>>());
    });

    test('filename and summary still come from the document', () async {
      final service = DataExportService(
        source: _FixedSource(),
        clock: () => DateTime.utc(2026, 9, 4, 12),
        encode: (_) async => Uint8List(0),
      );

      final result =
          await service.export(includeCycleAndWellbeing: false) as DataExported;

      expect(result.filename, 'menfit-export-2026-09-04.json');
      expect(result.summary.tableCount, 1);
      expect(result.summary.rowCount, 1);
    });
  });

  group('the production encoder', () {
    test('off the isolate produces exactly what on it does', () async {
      final document = DataExportDocument(
        schemaVersion: 24,
        exportedAt: DateTime.utc(2026, 9, 4, 12),
        includesCycleAndWellbeingData: false,
        tables: const {
          'weight_logs': [
            {'id': 'weight-1', 'weight_kg': 63.2},
          ],
        },
      );

      final viaIsolate = await encodeDataExportInBackground(document.toJson());

      expect(viaIsolate, document.toBytes());
      final decoded = jsonDecode(utf8.decode(viaIsolate));
      expect((decoded! as Map)['format'], 'menfit-export');
    });
  });
}
