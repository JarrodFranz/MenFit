import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/application/activity_export_service.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';

Activity _activity({
  ActivityType type = ActivityType.run,
  String title = 'Test Activity',
  DateTime? startedAt,
  Duration elapsedTime = const Duration(minutes: 30),
  double distanceMeters = 5000,
  ActivitySource source = ActivitySource.recorded,
}) {
  final started = startedAt ?? DateTime.utc(2026, 9, 1, 8);
  return Activity(
    id: EntityId.generate(),
    activityType: type,
    title: title,
    startedAt: started,
    movingTime: elapsedTime,
    elapsedTime: elapsedTime,
    distanceMeters: distanceMeters,
    source: source,
    createdAt: started,
    updatedAt: started,
  );
}

ActivitySample _sample({
  required String activityId,
  required DateTime timestamp,
  required double latitude,
  required double longitude,
}) {
  return ActivitySample(
    id: EntityId.generate(),
    activityId: activityId,
    timestamp: timestamp,
    latitude: latitude,
    longitude: longitude,
  );
}

void main() {
  late db.AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('returns ActivityNotFoundForExport for an unknown id', () async {
    final service = container.read(activityExportServiceProvider);

    final result = await service.exportActivity(
      'does-not-exist',
      format: ActivityExportFormat.gpx,
    );

    expect(result, isA<ActivityNotFoundForExport>());
  });

  test(
    'exports a recorded run as GPX with a filesystem-safe filename',
    () async {
      final repo = container.read(activityRepositoryProvider);
      final activity = _activity(
        title: 'Park Run / <Fast>!!',
        startedAt: DateTime.utc(2026, 9, 1, 8),
      );
      final samples = [
        _sample(
          activityId: activity.id,
          timestamp: DateTime.utc(2026, 9, 1, 8),
          latitude: 51.5,
          longitude: -0.14,
        ),
        _sample(
          activityId: activity.id,
          timestamp: DateTime.utc(2026, 9, 1, 8, 1),
          latitude: 51.501,
          longitude: -0.14,
        ),
      ];
      await repo.saveRecordedActivity(activity, samples);

      final service = container.read(activityExportServiceProvider);
      final result = await service.exportActivity(
        activity.id,
        format: ActivityExportFormat.gpx,
      );

      expect(result, isA<ActivityExported>());
      final exported = result as ActivityExported;
      expect(utf8.decode(exported.bytes), contains('<gpx'));
      expect(
        exported.filename,
        equals('femfit-run-2026-09-01-park-run-fast.gpx'),
      );
    },
  );

  test(
    'filename generation strips path separators and traversal sequences '
    'from a hostile title',
    () async {
      final repo = container.read(activityRepositoryProvider);
      final activity = _activity(
        type: ActivityType.yoga,
        source: ActivitySource.manual,
        distanceMeters: 0,
        title: r'../../etc/passwd\..\evil.exe',
      );
      await repo.saveActivity(activity);

      final service = container.read(activityExportServiceProvider);
      final result = await service.exportActivity(
        activity.id,
        format: ActivityExportFormat.tcx,
      ) as ActivityExported;

      expect(result.filename, isNot(contains('/')));
      expect(result.filename, isNot(contains(r'\')));
      expect(result.filename, isNot(contains('..')));
      expect(result.filename, endsWith('.tcx'));
    },
  );

  test(
    'returns ActivityNotExportableAsGpx for a manual, no-GPS activity',
    () async {
      final repo = container.read(activityRepositoryProvider);
      final activity = _activity(
        type: ActivityType.strength,
        source: ActivitySource.manual,
        distanceMeters: 0,
      );
      await repo.saveActivity(activity);

      final service = container.read(activityExportServiceProvider);
      final result = await service.exportActivity(
        activity.id,
        format: ActivityExportFormat.gpx,
      );

      expect(result, isA<ActivityNotExportableAsGpx>());
    },
  );

  test(
    'TCX export succeeds for the same no-GPS activity that GPX rejects',
    () async {
      final repo = container.read(activityRepositoryProvider);
      final activity = _activity(
        type: ActivityType.strength,
        source: ActivitySource.manual,
        distanceMeters: 0,
      );
      await repo.saveActivity(activity);

      final service = container.read(activityExportServiceProvider);
      final result = await service.exportActivity(
        activity.id,
        format: ActivityExportFormat.tcx,
      );

      expect(result, isA<ActivityExported>());
      expect((result as ActivityExported).filename, endsWith('.tcx'));
    },
  );
}
