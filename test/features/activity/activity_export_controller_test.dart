import 'dart:typed_data';

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
import 'package:menfit_app/features/activity/presentation/activity_export_controller.dart';

/// Records what the save dialog was handed, and answers with [location]
/// (`null` standing in for the user dismissing the dialog).
class _RecordingSaver {
  _RecordingSaver({this.location});

  final Uri? location;

  String? fileName;
  Uint8List? bytes;
  String? mimeType;
  int calls = 0;

  Future<Uri?> save({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    calls++;
    this.fileName = fileName;
    this.bytes = bytes;
    this.mimeType = mimeType;
    return location;
  }
}

Activity _activity({
  ActivityType type = ActivityType.run,
  ActivitySource source = ActivitySource.recorded,
  double distanceMeters = 5000,
  String title = 'Morning Run',
}) {
  final started = DateTime.utc(2026, 9, 1, 8);
  return Activity(
    id: EntityId.generate(),
    activityType: type,
    title: title,
    startedAt: started,
    movingTime: const Duration(minutes: 30),
    elapsedTime: const Duration(minutes: 30),
    distanceMeters: distanceMeters,
    source: source,
    createdAt: started,
    updatedAt: started,
  );
}

ActivitySample _sample(String activityId, int minute, double latitude) {
  return ActivitySample(
    id: EntityId.generate(),
    activityId: activityId,
    timestamp: DateTime.utc(2026, 9, 1, 8, minute),
    latitude: latitude,
    longitude: -0.14,
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

  ActivityExportController controller() =>
      container.read(activityExportControllerProvider.notifier);

  Future<Activity> saveRecordedRun() async {
    final repo = container.read(activityRepositoryProvider);
    final activity = _activity();
    await repo.saveRecordedActivity(activity, [
      _sample(activity.id, 0, 51.5),
      _sample(activity.id, 1, 51.501),
    ]);
    return activity;
  }

  test('the requested format reaches the service — GPX', () async {
    final activity = await saveRecordedRun();
    final saver = _RecordingSaver(location: Uri.parse('file:///out.gpx'));

    final outcome = await controller().export(
      activityId: activity.id,
      format: ActivityExportFormat.gpx,
      saver: saver.save,
    );

    expect(outcome, isA<ActivityExportSaved>());
    expect((outcome as ActivityExportSaved).filename, endsWith('.gpx'));
    expect(saver.calls, 1);
    expect(saver.fileName, endsWith('.gpx'));
    expect(saver.mimeType, 'application/gpx+xml');
    expect(String.fromCharCodes(saver.bytes!), contains('<gpx'));
  });

  test('the requested format reaches the service — TCX', () async {
    final activity = await saveRecordedRun();
    final saver = _RecordingSaver(location: Uri.parse('file:///out.tcx'));

    final outcome = await controller().export(
      activityId: activity.id,
      format: ActivityExportFormat.tcx,
      saver: saver.save,
    );

    expect(outcome, isA<ActivityExportSaved>());
    expect(saver.fileName, endsWith('.tcx'));
    expect(saver.mimeType, 'application/vnd.garmin.tcx+xml');
    expect(
      String.fromCharCodes(saver.bytes!),
      contains('TrainingCenterDatabase'),
    );
  });

  test(
    'a GPX request for a no-GPS activity never reaches the save dialog and '
    "surfaces the exporter's reason",
    () async {
      final repo = container.read(activityRepositoryProvider);
      final activity = _activity(
        type: ActivityType.strength,
        source: ActivitySource.manual,
        distanceMeters: 0,
        title: 'Lower body',
      );
      await repo.saveActivity(activity);
      final saver = _RecordingSaver(location: Uri.parse('file:///out.gpx'));

      final outcome = await controller().export(
        activityId: activity.id,
        format: ActivityExportFormat.gpx,
        saver: saver.save,
      );

      expect(outcome, isA<ActivityExportUnavailable>());
      expect((outcome as ActivityExportUnavailable).message, isNotEmpty);
      expect(
        saver.calls,
        0,
        reason: 'nothing to save, so no dialog is ever opened',
      );
    },
  );

  test('TCX still succeeds for the same activity GPX rejects', () async {
    final repo = container.read(activityRepositoryProvider);
    final activity = _activity(
      type: ActivityType.strength,
      source: ActivitySource.manual,
      distanceMeters: 0,
    );
    await repo.saveActivity(activity);
    final saver = _RecordingSaver(location: Uri.parse('file:///out.tcx'));

    final outcome = await controller().export(
      activityId: activity.id,
      format: ActivityExportFormat.tcx,
      saver: saver.save,
    );

    expect(outcome, isA<ActivityExportSaved>());
    expect(saver.calls, 1);
  });

  test('a dismissed save dialog is a silent cancellation', () async {
    final activity = await saveRecordedRun();
    final saver = _RecordingSaver();

    final outcome = await controller().export(
      activityId: activity.id,
      format: ActivityExportFormat.gpx,
      saver: saver.save,
    );

    expect(outcome, isA<ActivityExportCancelled>());
    expect(saver.calls, 1);
  });

  test(
    'a deleted activity is reported as unavailable, not as a crash',
    () async {
      final saver = _RecordingSaver();

      final outcome = await controller().export(
        activityId: 'does-not-exist',
        format: ActivityExportFormat.tcx,
        saver: saver.save,
      );

      expect(outcome, isA<ActivityExportUnavailable>());
      expect(saver.calls, 0);
    },
  );

  test('a throwing save dialog is reported as a failure', () async {
    final activity = await saveRecordedRun();

    final outcome = await controller().export(
      activityId: activity.id,
      format: ActivityExportFormat.tcx,
      saver: ({required fileName, required bytes, required mimeType}) async =>
          throw StateError('no file system'),
    );

    expect(outcome, isA<ActivityExportFailed>());
    expect((outcome as ActivityExportFailed).error, isA<StateError>());
  });
}
