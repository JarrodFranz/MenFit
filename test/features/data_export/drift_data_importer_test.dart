import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/features/data_export/data/drift_data_exporter.dart';
import 'package:menfit_app/features/data_export/data/drift_data_importer.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';

class _NoNetwork extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    fail('The data import must never make a network request');
  }
}

void main() {
  late db.AppDatabase sourceDb;
  late db.AppDatabase targetDb;
  late DriftDataExporter exporter;
  late DriftDataImporter importer;

  final now = DateTime.utc(2026, 9, 4, 10).millisecondsSinceEpoch;

  setUp(() {
    HttpOverrides.global = _NoNetwork();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    sourceDb = db.AppDatabase.forTesting(NativeDatabase.memory());
    targetDb = db.AppDatabase.forTesting(NativeDatabase.memory());
    exporter = DriftDataExporter(sourceDb);
    importer = DriftDataImporter(targetDb);
  });

  tearDown(() async {
    HttpOverrides.global = null;
    await sourceDb.close();
    await targetDb.close();
  });

  Future<void> seedSourceDb() async {
    await sourceDb
        .into(sourceDb.activities)
        .insert(
          db.ActivitiesCompanion.insert(
            id: 'activity-1',
            activityType: 'run',
            title: 'Morning Run',
            startedAt: now,
            movingTimeMs: 1800000,
            elapsedTimeMs: 1800000,
            distanceMeters: 5000,
            source: 'gps',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await sourceDb
        .into(sourceDb.activitySamples)
        .insert(
          db.ActivitySamplesCompanion.insert(
            id: 'sample-1',
            activityId: 'activity-1',
            timestampMs: now,
            latitude: -37.8136,
            longitude: 144.9631,
            elevationMeters: const Value(25),
            horizontalAccuracyMeters: const Value(3),
            heartRate: const Value(145),
            isPaused: const Value(false),
          ),
        );

    await sourceDb
        .into(sourceDb.foods)
        .insert(
          db.FoodsCompanion.insert(
            id: 'food-1',
            name: 'Greek Yogurt',
            servingDescription: '150g',
            caloriesKcal: 130,
            proteinGrams: 15,
            carbsGrams: 6,
            fatGrams: 5,
            source: const Value('custom'),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await sourceDb
        .into(sourceDb.waterLogs)
        .insert(
          db.WaterLogsCompanion.insert(
            id: 'water-1',
            day: '2026-09-04',
            milliliters: 500,
            createdAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
          ),
        );

    await sourceDb
        .into(sourceDb.weightLogs)
        .insert(
          db.WeightLogsCompanion.insert(
            id: 'weight-1',
            day: '2026-09-04',
            weightKg: 64.2,
            createdAt: now,
            updatedAt: now,
          ),
        );

    await sourceDb
        .into(sourceDb.cycleRecords)
        .insert(
          db.CycleRecordsCompanion.insert(
            id: 'cycle-1',
            periodStartDay: '2026-09-01',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  group('DriftDataImporter', () {
    test('round-trips all tables and rows faithfully', () async {
      await seedSourceDb();

      final tables = await exporter.readTables(includeCycleAndWellbeing: true);
      final document = DataExportDocument(
        schemaVersion: exporter.schemaVersion,
        exportedAt: DateTime.utc(2026, 9, 4, 10),
        includesCycleAndWellbeingData: true,
        tables: tables,
      );

      final summary = await importer.importDocument(document);

      expect(summary.rowCount, 6);
      expect(summary.tableCount, tables.length);

      // Verify records in targetDb
      final activities = await targetDb.select(targetDb.activities).get();
      expect(activities.length, 1);
      expect(activities.first.title, 'Morning Run');
      expect(activities.first.distanceMeters, 5000);

      final samples = await targetDb.select(targetDb.activitySamples).get();
      expect(samples.length, 1);
      expect(samples.first.activityId, 'activity-1');
      expect(samples.first.latitude, -37.8136);

      final foods = await targetDb.select(targetDb.foods).get();
      expect(foods.length, 1);
      expect(foods.first.name, 'Greek Yogurt');

      final water = await targetDb.select(targetDb.waterLogs).get();
      expect(water.length, 1);
      expect(water.first.milliliters, 500);

      final weights = await targetDb.select(targetDb.weightLogs).get();
      expect(weights.length, 1);
      expect(weights.first.weightKg, 64.2);

      final cycles = await targetDb.select(targetDb.cycleRecords).get();
      expect(cycles.length, 1);
      expect(cycles.first.periodStartDay, '2026-09-01');
    });

    test('replaces existing rows in imported tables cleanly', () async {
      // Seed targetDb with older row
      await targetDb
          .into(targetDb.weightLogs)
          .insert(
            db.WeightLogsCompanion.insert(
              id: 'old-weight',
              day: '2026-08-01',
              weightKg: 66,
              createdAt: now - 10000,
              updatedAt: now - 10000,
            ),
          );

      final document = DataExportDocument(
        schemaVersion: 24,
        exportedAt: DateTime.utc(2026, 9, 4),
        includesCycleAndWellbeingData: false,
        tables: {
          'weight_logs': [
            {
              'id': 'new-weight',
              'day': '2026-09-04',
              'weight_kg': 63.5,
              'created_at': now,
              'updated_at': now,
            },
          ],
        },
      );

      await importer.importDocument(document);

      final weights = await targetDb.select(targetDb.weightLogs).get();
      expect(weights.length, 1);
      expect(weights.first.id, 'new-weight');
      expect(weights.first.weightKg, 63.5);
    });

    test('safely ignores unrecognised tables and unknown columns', () async {
      final document = DataExportDocument(
        schemaVersion: 24,
        exportedAt: DateTime.utc(2026, 9, 4),
        includesCycleAndWellbeingData: false,
        tables: {
          'future_table': [
            {'id': 'future-1', 'title': 'Future thing'},
          ],
          'weight_logs': [
            {
              'id': 'weight-with-extra-col',
              'day': '2026-09-04',
              'weight_kg': 63.5,
              'future_column_99': 'ignored',
              'created_at': now,
              'updated_at': now,
            },
          ],
        },
      );

      final summary = await importer.importDocument(document);

      expect(summary.rowCount, 1);
      final weights = await targetDb.select(targetDb.weightLogs).get();
      expect(weights.length, 1);
      expect(weights.first.id, 'weight-with-extra-col');
    });
  });
}
