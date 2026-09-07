import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/activity/application/activity_import_service.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

final class _FakePlatformFile extends PlatformFile {
  _FakePlatformFile({
    required this.name,
    required this.bytes,
  });

  @override
  final String name;

  final Uint8List bytes;

  @override
  Uri get uri => Uri.parse('file:///$name');

  @override
  Never get xFile => throw UnimplementedError();

  @override
  Future<int> length() async => bytes.length;

  @override
  Future<Uint8List> readAsBytes() async => bytes;

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(bytes);
}

void main() {
  late db.AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test(
    'pickAndImportFile saves parsed GPX activity and samples to database',
    () async {
      const gpxContent = '''

<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Garmin Forerunner">
  <trk>
    <name>Park Run</name>
    <type>running</type>
    <trkseg>
      <trkpt lat="51.5000" lon="-0.1400"><ele>10.0</ele><time>2026-08-29T08:00:00Z</time></trkpt>
      <trkpt lat="51.5010" lon="-0.1400"><ele>12.0</ele><time>2026-08-29T08:01:00Z</time></trkpt>
    </trkseg>
  </trk>
</gpx>''';

      final bytes = Uint8List.fromList(utf8.encode(gpxContent));
      final mockFile = _FakePlatformFile(
        name: 'park_run.gpx',
        bytes: bytes,
      );

      final service = container.read(activityImportServiceProvider);

      final imported = await service.pickAndImportFile(mockFile: mockFile);

      expect(imported, isNotNull);
      expect(imported!.activity.title, equals('Park Run'));
      expect(imported.activity.activityType, equals(ActivityType.run));

      // Verify activity persisted in database
      final activityRows = await database.select(database.activities).get();
      expect(activityRows.length, equals(1));
      expect(activityRows.first.title, equals('Park Run'));

      // Verify samples persisted in database
      final sampleRows = await database.select(database.activitySamples).get();
      expect(sampleRows.length, equals(2));
      expect(sampleRows.first.latitude, equals(51.5));
    },
  );

  test(
    'pickAndImportFile returns null when user cancels file picker',
    () async {
      final service = container.read(activityImportServiceProvider);
      final imported = await service.pickAndImportFile(
        customPicker: () async => null,
      );

      expect(imported, isNull);
    },
  );
}
