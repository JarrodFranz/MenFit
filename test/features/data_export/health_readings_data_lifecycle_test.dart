import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/data_export/application/data_import_service.dart';
import 'package:menfit_app/features/data_export/data/drift_data_exporter.dart';
import 'package:menfit_app/features/data_export/data/drift_data_importer.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';

/// Mirrors `ketone_data_lifecycle_test.dart` for both manual health tables.
void main() {
  late AppDatabase db;
  late DriftDataImporter importer;
  final instant = DateTime.utc(2026, 1, 1, 8).millisecondsSinceEpoch;
  final bpRow = <String, Object?>{
    'id': 'bp',
    'day': '2026-01-01',
    'measured_at': instant,
    'systolic': 131,
    'diastolic': 87,
    'pulse': 64,
    'note': 'after coffee',
    'created_at': instant,
    'updated_at': instant,
  };
  final markerRow = <String, Object?>{
    'id': 'marker',
    'day': '2026-01-01',
    'measured_at': instant,
    'marker': 'glucose',
    'value': 5.4,
    'unit': 'mmol/L',
    'context': 'fasting',
    'note': null,
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

  Future<int> bpCount() async =>
      (await db.select(db.bloodPressureReadings).get()).length;
  Future<int> markerCount() async =>
      (await db.select(db.bloodMarkerReadings).get()).length;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    importer = DriftDataImporter(db);
    await importer.importDocument(
      document({
        'blood_pressure_readings': [bpRow],
        'blood_marker_readings': [markerRow],
      }),
    );
  });
  tearDown(() => db.close());

  test(
    'default export omits both tables; opt-in restores exact values',
    () async {
      final exporter = DriftDataExporter(db);
      final plain = await exporter.readTables(includeSensitiveHealth: false);
      expect(plain, isNot(contains('blood_pressure_readings')));
      expect(plain, isNot(contains('blood_marker_readings')));
      final tables = await exporter.readTables(includeSensitiveHealth: true);
      expect(tables['blood_pressure_readings'], [bpRow]);
      expect(tables['blood_marker_readings'], [markerRow]);
      final encoded = document(tables).toBytes();
      await db.delete(db.bloodPressureReadings).go();
      await db.delete(db.bloodMarkerReadings).go();
      await importer.importDocument(DataExportDocument.fromBytes(encoded));
      final bp = await db.select(db.bloodPressureReadings).getSingle();
      expect(bp.systolic, 131);
      expect(bp.pulse, 64);
      expect(bp.note, 'after coffee');
      final marker = await db.select(db.bloodMarkerReadings).getSingle();
      expect(marker.value, 5.4);
      expect(marker.unit, 'mmol/L');
      expect(marker.context, 'fasting');
    },
  );

  test('a whole-number glucose value decoded as int is accepted', () async {
    await importer.importDocument(
      document({
        'blood_marker_readings': [
          {...markerRow, 'value': 97, 'unit': 'mg/dL'},
        ],
      }),
    );
    expect((await db.select(db.bloodMarkerReadings).getSingle()).value, 97);
  });

  test('an older backup omitting both tables leaves readings intact', () async {
    await importer.importDocument(
      document({'nutrition_entries': []}, sensitive: false),
    );
    expect(await bpCount(), 1);
    expect(await markerCount(), 1);
  });

  for (final table in ['blood_pressure_readings', 'blood_marker_readings']) {
    test('$table cannot be smuggled in without its flag', () async {
      await expectLater(
        importer.importDocument(document({table: []}, sensitive: false)),
        throwsA(isA<StorageException>()),
      );
      expect(await bpCount(), 1);
      expect(await markerCount(), 1);
    });
  }

  final invalidRows = <(String, Map<String, Object?>)>[
    for (final bad in <Map<String, Object?>>[
      {...bpRow, 'systolic': 39},
      {...bpRow, 'systolic': 301},
      {...bpRow, 'diastolic': 19},
      {...bpRow, 'systolic': 80, 'diastolic': 80},
      {...bpRow, 'systolic': 120.5},
      {...bpRow, 'systolic': '120'},
      {...bpRow, 'pulse': 24},
      {...bpRow, 'pulse': 64.0},
      {...bpRow, 'note': 'two\nlines'},
      {...bpRow, 'note': 7},
      {...bpRow, 'day': '2026-02-30'},
      {...bpRow, 'measured_at': 'yesterday'},
      {...bpRow, 'updated_at': instant - 1},
      {...bpRow, 'id': ''},
    ])
      ('blood_pressure_readings', bad),
    for (final bad in <Map<String, Object?>>[
      {...markerRow, 'value': 0.4},
      {...markerRow, 'value': 50.1},
      {...markerRow, 'value': 'NaN'},
      {...markerRow, 'value': '5.4'},
      {...markerRow, 'unit': 'mg/dL'}, // 5.4 mg/dL is below its bound
      {...markerRow, 'unit': 'g/L'},
      {...markerRow, 'marker': 'cholesterol'},
      {...markerRow, 'context': 'sometime'},
      {...markerRow, 'note': 'x\u0000y'},
      {...markerRow, 'day': '2026-02-30'},
      {...markerRow, 'measured_at': 'yesterday'},
      {...markerRow, 'updated_at': instant - 1},
    ])
      ('blood_marker_readings', bad),
  ];

  for (final (index, (table, invalid)) in invalidRows.indexed) {
    test(
      'invalid $table import preserves all existing data, case $index',
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
              table: [invalid],
            }),
          ),
          throwsA(isA<StorageException>()),
        );
        expect(
          (await db.select(db.userProfiles).getSingle()).displayName,
          'Keep',
        );
        expect(
          (await db.select(db.bloodPressureReadings).getSingle()).systolic,
          131,
        );
        expect(
          (await db.select(db.bloodMarkerReadings).getSingle()).value,
          5.4,
        );
      },
    );
  }

  for (final (table, row) in [
    ('blood_pressure_readings', bpRow),
    ('blood_marker_readings', markerRow),
  ]) {
    test('duplicate $table identities are rejected atomically', () async {
      await expectLater(
        importer.importDocument(
          document({
            table: [row, row],
          }),
        ),
        throwsA(isA<StorageException>()),
      );
      expect(await bpCount(), 1);
      expect(await markerCount(), 1);
    });

    test(
      'malformed $table rows are rejected instead of becoming an empty table',
      () {
        final json = document({}).toJson()
          ..['tables'] = {
            table: ['bad-row'],
          };
        expect(() => DataExportDocument.fromJson(json), throwsFormatException);
      },
    );
  }

  test(
    'import errors do not retain sensitive row values in message or cause',
    () async {
      try {
        await importer.importDocument(
          document({
            'blood_pressure_readings': [
              {...bpRow, 'systolic': 98765},
            ],
          }),
        );
        fail('expected failure');
      } on StorageException catch (error) {
        expect(error.toString(), isNot(contains('98765')));
        expect(error.cause, isNull);
      }
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
