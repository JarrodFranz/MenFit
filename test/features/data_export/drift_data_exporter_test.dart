import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show LazyDatabase, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/features/data_export/application/data_export_service.dart';
import 'package:menfit_app/features/data_export/data/drift_data_exporter.dart';
import 'package:menfit_app/features/data_export/domain/data_export_result.dart';
import 'package:menfit_app/features/data_export/domain/data_export_source.dart';
import 'package:menfit_app/features/data_export/domain/data_export_tables.dart';

/// Fails any attempt to open a socket. The export is a promise that nothing
/// leaves the device; the cheapest way to keep testing that promise is to
/// make leaving impossible while the export runs.
class _NoNetwork extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    fail('The data export must never make a network request');
  }
}

void main() {
  late db.AppDatabase database;
  late DataExportSource exporter;

  final now = DateTime.utc(2026).millisecondsSinceEpoch;

  setUp(() {
    HttpOverrides.global = _NoNetwork();
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    exporter = DriftDataExporter(database);
  });

  tearDown(() async {
    HttpOverrides.global = null;
    await database.close();
  });

  Future<void> seedNonSensitive() async {
    await database
        .into(database.activities)
        .insert(
          db.ActivitiesCompanion.insert(
            id: 'activity-live',
            activityType: 'run',
            title: 'Morning run',
            startedAt: now,
            movingTimeMs: 600000,
            elapsedTimeMs: 600000,
            distanceMeters: 4000,
            source: 'manual',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.weightLogs)
        .insert(
          db.WeightLogsCompanion.insert(
            id: 'weight-1',
            day: '2026-01-02',
            weightKg: 63.2,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.foods)
        .insert(
          db.FoodsCompanion.insert(
            id: 'food-1',
            name: 'Porridge oats',
            servingDescription: '1 cup (dry)',
            caloriesKcal: 300,
            proteinGrams: 10,
            carbsGrams: 54,
            fatGrams: 5,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> seedSensitiveHealth() async {
    await database
        .into(database.dailyCheckins)
        .insert(
          db.DailyCheckinsCompanion.insert(
            id: 'checkin-1',
            day: '2026-01-02',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.flareEvents)
        .insert(
          db.FlareEventsCompanion.insert(
            id: 'flare-1',
            day: '2026-01-02',
            severity: 'moderate',
            impact: 'reducedTraining',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.recoveryDays)
        .insert(
          db.RecoveryDaysCompanion.insert(
            id: 'recovery-1',
            day: '2026-01-02',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  group('table coverage', () {
    test('reads every non-opt-in table, empty ones included', () async {
      await seedNonSensitive();

      final tables = await exporter.readTables(
        includeSensitiveHealth: false,
      );

      final expected = database.allTables
          .map((t) => t.actualTableName)
          .where((name) => !sensitiveHealthTables.contains(name))
          .toSet();
      expect(tables.keys.toSet(), expected);
      // An empty table is present as an empty list, not absent: "you have
      // logged no yoga sequences" is a fact worth being able to read off
      // the file.
      expect(tables['yoga_sequences'], isEmpty);
    });

    test('seeded rows arrive with their stored column values', () async {
      await seedNonSensitive();

      final tables = await exporter.readTables(
        includeSensitiveHealth: false,
      );

      final activity = tables['activities']!.single;
      expect(activity['id'], 'activity-live');
      expect(activity['title'], 'Morning run');
      // Epoch milliseconds as stored — no reformatting anywhere on this path.
      expect(activity['started_at'], now);
      expect(tables['weight_logs']!.single['weight_kg'], 63.2);
      expect(tables['foods']!.single['name'], 'Porridge oats');
    });
  });

  group('the S3 opt-in', () {
    test('leaves the four health check-in tables out by default', () async {
      await seedNonSensitive();
      await seedSensitiveHealth();

      final tables = await exporter.readTables(
        includeSensitiveHealth: false,
      );

      for (final name in sensitiveHealthTables) {
        expect(
          tables.containsKey(name),
          isFalse,
          reason: '"$name" is S3 data and must not be exported unopted-in',
        );
      }
      // ...and nothing else was lost in the process.
      expect(tables['activities'], hasLength(1));
    });

    test('their rows are nowhere in the bytes either', () async {
      await seedSensitiveHealth();

      final service = DataExportService(
        source: exporter,
        clock: () => DateTime.utc(2026, 9, 4),
      );
      final result = await service.export(includeSensitiveHealth: false);
      final text = utf8.decode((result as DataExported).bytes);

      // Not just the table keys: the row ids seeded above must not appear
      // anywhere in the file, including inside some other table's column.
      for (final name in sensitiveHealthTables) {
        expect(text, isNot(contains(name)));
      }
      for (final id in ['checkin-1', 'flare-1', 'recovery-1']) {
        expect(text, isNot(contains(id)));
      }
      expect(text, contains('"includesSensitiveHealthData": false'));
    });

    test('includes all four when the user opts in', () async {
      await seedNonSensitive();
      await seedSensitiveHealth();

      final tables = await exporter.readTables(includeSensitiveHealth: true);

      expect(tables.keys.toSet(), containsAll(sensitiveHealthTables));
      expect(tables['daily_checkins']!.single['id'], 'checkin-1');
      expect(tables['flare_events']!.single['id'], 'flare-1');
      expect(tables['recovery_days']!.single['id'], 'recovery-1');
      expect(
        tables.keys.toSet(),
        database.allTables.map((t) => t.actualTableName).toSet(),
      );
    });
  });

  test('soft-deleted rows are included — they are still her data', () async {
    await database
        .into(database.activities)
        .insert(
          db.ActivitiesCompanion.insert(
            id: 'activity-deleted',
            activityType: 'run',
            title: 'Deleted run',
            startedAt: now,
            movingTimeMs: 600000,
            elapsedTimeMs: 600000,
            distanceMeters: 4000,
            source: 'manual',
            createdAt: now,
            updatedAt: now,
            deletedAt: Value(now),
          ),
        );

    final tables = await exporter.readTables(includeSensitiveHealth: false);

    final activity = tables['activities']!.single;
    expect(activity['id'], 'activity-deleted');
    expect(activity['deleted_at'], now);
  });

  test('the schema version comes from the database itself', () {
    expect(exporter.schemaVersion, database.schemaVersion);
  });

  test(
    'a closed database fails as a StorageException with no content',
    () async {
      // Its own database, closed on purpose: closing the shared one would
      // leave `tearDown` closing it a second time.
      // A closed in-memory NativeDatabase does not reject queries, so a
      // lazily-failing executor stands in for "the store is unusable".
      final doomed = db.AppDatabase.forTesting(
        LazyDatabase(() async => throw StateError('store unavailable')),
      );
      final doomedExporter = DriftDataExporter(doomed);

      Object? thrown;
      try {
        await doomedExporter.readTables(includeSensitiveHealth: false);
      } on Object catch (error) {
        thrown = error;
      }

      expect(thrown, isA<StorageException>());
      final exception = thrown! as StorageException;
      expect(exception.message, 'Failed to read local data for export');
      // The message is static: no table name, no row, nothing that could
      // carry her data into a log (security_and_privacy.md rule 3).
      expect(exception.message, isNot(contains('activities')));
      expect(exception.message, isNot(contains('Morning run')));

      // Its own user-message key, not the generic storage one: this failure
      // read nothing and changed nothing, and the copy has to say so rather
      // than imply a save went wrong.
      expect(exception.userMessageKey, 'error.exportRead');
      expect(
        userMessageFor(exception),
        'Something went wrong reading your data for the export. Nothing was '
        'changed. Please try again.',
      );
      expect(
        userMessageFor(exception),
        isNot(userMessageFor(const StorageException(message: 'other'))),
        reason:
            'a failed export read must not be worded as a failed save - the '
            'whole point of giving it its own key',
      );
      // Still content-free, like every message in that map.
      expect(userMessageFor(exception), isNot(contains('activities')));
    },
  );

  group('end to end through the service', () {
    test('produces pretty JSON that parses back, with the envelope', () async {
      await seedNonSensitive();
      final service = DataExportService(
        source: exporter,
        clock: () => DateTime.utc(2026, 9, 4, 12),
      );

      final result = await service.export(includeSensitiveHealth: false);

      expect(result, isA<DataExported>());
      final exported = result as DataExported;
      expect(exported.filename, 'menfit-export-2026-09-04.json');

      final text = utf8.decode(exported.bytes);
      expect(text, contains('\n  '));
      final decoded = jsonDecode(text) as Map<String, Object?>;
      expect(decoded['format'], 'menfit-export');
      expect(decoded['schemaVersion'], database.schemaVersion);

      final tables = decoded['tables']! as Map<String, Object?>;
      expect(exported.summary.tableCount, tables.length);
      expect(exported.summary.rowCount, 3);
    });
  });
}
