import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/data_export/application/data_import_service.dart';
import 'package:menfit_app/features/data_export/data/drift_data_exporter.dart';
import 'package:menfit_app/features/data_export/data/drift_data_importer.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';

void main() {
  late AppDatabase db;
  late DriftDataImporter importer;
  final instant = DateTime.utc(2026, 1, 1, 8).millisecondsSinceEpoch;
  final row = <String, Object?>{
    'id': 'reading',
    'day': '2026-01-01',
    'type': 'blood',
    'result': '0.50',
    'measured_at': instant,
    'created_at': instant,
    'updated_at': instant,
  };

  DataExportDocument document(
    Map<String, List<Map<String, Object?>>> tables, {
    bool sensitive = true,
  }) => DataExportDocument(
    schemaVersion: db.schemaVersion,
    exportedAt: DateTime.utc(2026, 1, 2),
    includesSensitiveHealthData: sensitive,
    tables: tables,
  );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    importer = DriftDataImporter(db);
    await importer.importDocument(
      document({
        'ketone_readings': [row],
      }),
    );
  });
  tearDown(() => db.close());

  test(
    'default export omits ketones; opt-in restores exact text and method',
    () async {
      final exporter = DriftDataExporter(db);
      expect(
        await exporter.readTables(includeSensitiveHealth: false),
        isNot(contains('ketone_readings')),
      );
      final tables = await exporter.readTables(includeSensitiveHealth: true);
      expect(tables['ketone_readings'], [row]);
      final encoded = document(tables).toBytes();
      await db.delete(db.ketoneReadings).go();
      await importer.importDocument(DataExportDocument.fromBytes(encoded));
      final restored = await db.select(db.ketoneReadings).getSingle();
      expect(restored.result, '0.50');
      expect(restored.type, 'blood');
    },
  );

  test('an older backup omitting ketones leaves readings intact', () async {
    await importer.importDocument(
      document({'nutrition_entries': []}, sensitive: false),
    );
    expect((await db.select(db.ketoneReadings).getSingle()).result, '0.50');
  });

  test('sensitive table cannot be smuggled in without its flag', () async {
    await expectLater(
      importer.importDocument(
        document({'ketone_readings': []}, sensitive: false),
      ),
      throwsA(isA<StorageException>()),
    );
    expect(await db.select(db.ketoneReadings).get(), hasLength(1));
  });

  for (final (index, invalid) in <Map<String, Object?>>[
    {...row, 'result': '-1'},
    {...row, 'result': 'NaN'},
    {...row, 'type': 'other'},
    {...row, 'day': '2026-02-30'},
    {...row, 'measured_at': 'yesterday'},
    {...row, 'updated_at': instant - 1},
  ].indexed) {
    test(
      'invalid reading import preserves all existing data, case $index',
      () async {
        await db.customStatement(
          'INSERT INTO user_profiles '
          '(id,display_name,unit_system,created_at,updated_at) '
          "VALUES ('p','Keep','metric',1,1)",
        );
        await expectLater(
          importer.importDocument(
            document({
              'user_profiles': [],
              'ketone_readings': [invalid],
            }),
          ),
          throwsA(isA<StorageException>()),
        );
        expect(
          (await db.select(db.userProfiles).getSingle()).displayName,
          'Keep',
        );
        expect((await db.select(db.ketoneReadings).getSingle()).result, '0.50');
      },
    );
  }

  test('duplicate reading identities are rejected atomically', () async {
    await expectLater(
      importer.importDocument(
        document({
          'ketone_readings': [row, row],
        }),
      ),
      throwsA(isA<StorageException>()),
    );
    expect(await db.select(db.ketoneReadings).get(), hasLength(1));
  });

  test(
    'malformed rows are rejected instead of becoming a destructive empty table',
    () {
      final json = document({}).toJson()
        ..['tables'] = {
          'ketone_readings': ['bad-row'],
        };
      expect(() => DataExportDocument.fromJson(json), throwsFormatException);
    },
  );

  test(
    'parser errors do not retain sensitive input in message or cause',
    () async {
      final service = DataImportService(
        target: importer,
        decode: (_) async {
          throw const FormatException('PRIVATE_INPUT', 'PRIVATE_INPUT');
        },
      );
      try {
        await service.parseDocument(Uint8List(0));
        fail('expected failure');
      } on StorageException catch (error) {
        expect(error.toString(), isNot(contains('PRIVATE_INPUT')));
        expect(error.cause, isNull);
      }
    },
  );
}
