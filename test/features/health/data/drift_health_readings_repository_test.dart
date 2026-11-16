import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/health/data/drift_health_readings_repository.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart';

void main() {
  late db.AppDatabase database;
  late DriftHealthReadingsRepository repository;
  final day = LocalDate(2026, 1, 1);
  final stamp = DateTime.utc(2026, 1, 1, 10);

  BloodPressureReading bp(
    String id, {
    int systolic = 120,
    DateTime? at,
    DateTime? createdAt,
    int? pulse,
    String? note,
  }) => BloodPressureReading(
    id: id,
    day: day,
    measuredAt: at ?? stamp,
    systolic: systolic,
    diastolic: 80,
    pulse: pulse,
    note: note,
    createdAt: createdAt ?? stamp,
    updatedAt: createdAt ?? stamp,
  );

  BloodMarkerReading glucose(
    String id, {
    double value = 5.4,
    BloodMarkerUnit unit = BloodMarkerUnit.mmolPerL,
    GlucoseContext? context,
    DateTime? at,
    DateTime? createdAt,
  }) => BloodMarkerReading(
    id: id,
    day: day,
    measuredAt: at ?? stamp,
    marker: BloodMarker.glucose,
    value: value,
    unit: unit,
    context: context,
    createdAt: createdAt ?? stamp,
    updatedAt: createdAt ?? stamp,
  );

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftHealthReadingsRepository(database);
  });

  tearDown(() => database.close());

  group('blood pressure', () {
    test('round trips every field including optional ones', () async {
      await repository.saveBloodPressure(
        bp('a', systolic: 131, pulse: 64, note: 'after coffee'),
      );
      await repository.saveBloodPressure(bp('b'));
      final stored = await repository.watchBloodPressure().first;
      final a = stored.firstWhere((r) => r.id == 'a');
      expect(a.systolic, 131);
      expect(a.diastolic, 80);
      expect(a.pulse, 64);
      expect(a.note, 'after coffee');
      expect(a.day, day);
      final b = stored.firstWhere((r) => r.id == 'b');
      expect(b.pulse, isNull);
      expect(b.note, isNull);
      expect(
        stored.every(
          (r) => r.measuredAt.isUtc && r.createdAt.isUtc && r.updatedAt.isUtc,
        ),
        isTrue,
      );
    });

    test('orders newest first by measurement, creation, then id', () async {
      for (final sample in [
        bp('a'),
        bp('b'),
        bp('c', at: stamp.subtract(const Duration(hours: 1))),
        bp('d', createdAt: stamp.subtract(const Duration(minutes: 1))),
        bp('e', at: stamp.add(const Duration(hours: 1))),
      ]) {
        await repository.saveBloodPressure(sample);
      }
      expect((await repository.watchBloodPressure().first).map((r) => r.id), [
        'e',
        'b',
        'a',
        'd',
        'c',
      ]);
    });

    test('since keeps readings measured at or after it', () async {
      await repository.saveBloodPressure(bp('old', at: stamp));
      await repository.saveBloodPressure(
        bp('new', at: stamp.add(const Duration(days: 1))),
      );
      expect(
        (await repository.watchBloodPressure(since: stamp).first).map(
          (r) => r.id,
        ),
        ['new', 'old'],
      );
      expect(
        (await repository
                .watchBloodPressure(
                  since: stamp.add(const Duration(milliseconds: 1)),
                )
                .first)
            .map((r) => r.id),
        ['new'],
      );
    });

    test('editing preserves creation time', () async {
      await repository.saveBloodPressure(bp('a'));
      await repository.saveBloodPressure(
        bp('a', systolic: 140, createdAt: stamp.add(const Duration(hours: 1))),
      );
      final edited = (await repository.watchBloodPressure().first).single;
      expect(edited.createdAt, stamp);
      expect(edited.updatedAt.isAfter(stamp), isTrue);
      expect(edited.systolic, 140);
    });

    test('clock correction keeps chronology editable', () async {
      final future = DateTime.utc(2099);
      await repository.saveBloodPressure(bp('a', createdAt: future));
      final first = (await repository.watchBloodPressure().first).single;
      await repository.saveBloodPressure(first.copyWith(systolic: 125));
      final edited = (await repository.watchBloodPressure().first).single;
      expect(edited.createdAt, future);
      expect(edited.updatedAt.isBefore(future), isFalse);
    });

    test('deletes one reading permanently', () async {
      await repository.saveBloodPressure(bp('a'));
      await repository.saveBloodPressure(bp('b'));
      await repository.deleteBloodPressure('a');
      expect(
        (await database.select(database.bloodPressureReadings).get()).single.id,
        'b',
      );
    });

    test('rejects invalid input before storage', () async {
      await expectLater(
        repository.saveBloodPressure(bp('a', systolic: 70)),
        throwsA(isA<ValidationException>()),
      );
      expect(
        await database.select(database.bloodPressureReadings).get(),
        isEmpty,
      );
    });

    test('corrupt stored row becomes a scrubbed storage error', () async {
      await repository.saveBloodPressure(bp('a'));
      await database.customStatement(
        'UPDATE blood_pressure_readings SET systolic = 98765',
      );
      await expectLater(
        repository.watchBloodPressure().first,
        throwsA(
          isA<StorageException>()
              .having((e) => e.cause, 'cause', isNull)
              .having((e) => e.toString(), 'message', isNot(contains('98765'))),
        ),
      );
    });
  });

  group('blood markers', () {
    test('round trips value, unit and context exactly as entered', () async {
      await repository.saveBloodMarker(
        glucose('a', value: 97, unit: BloodMarkerUnit.mgPerDl),
      );
      await repository.saveBloodMarker(
        glucose(
          'b',
          context: GlucoseContext.afterMeal,
          at: stamp.add(const Duration(hours: 1)),
        ),
      );
      final stored = await repository
          .watchBloodMarker(BloodMarker.glucose)
          .first;
      expect(stored.map((r) => r.id), ['b', 'a']);
      expect(stored[0].value, 5.4);
      expect(stored[0].unit, BloodMarkerUnit.mmolPerL);
      expect(stored[0].context, GlucoseContext.afterMeal);
      expect(stored[1].value, 97);
      expect(stored[1].unit, BloodMarkerUnit.mgPerDl);
      expect(stored[1].context, isNull);
    });

    test('orders newest first and applies since', () async {
      for (final sample in [
        glucose('a'),
        glucose('b'),
        glucose('c', at: stamp.subtract(const Duration(hours: 1))),
        glucose('d', createdAt: stamp.subtract(const Duration(minutes: 1))),
      ]) {
        await repository.saveBloodMarker(sample);
      }
      expect(
        (await repository.watchBloodMarker(BloodMarker.glucose).first).map(
          (r) => r.id,
        ),
        ['b', 'a', 'd', 'c'],
      );
      expect(
        (await repository
                .watchBloodMarker(BloodMarker.glucose, since: stamp)
                .first)
            .map((r) => r.id),
        ['b', 'a', 'd'],
      );
    });

    test('editing preserves creation time; delete is permanent', () async {
      await repository.saveBloodMarker(glucose('a'));
      await repository.saveBloodMarker(
        glucose(
          'a',
          value: 6.1,
          createdAt: stamp.add(const Duration(hours: 1)),
        ),
      );
      final edited =
          (await repository.watchBloodMarker(BloodMarker.glucose).first).single;
      expect(edited.createdAt, stamp);
      expect(edited.value, 6.1);
      await repository.deleteBloodMarker('a');
      expect(
        await database.select(database.bloodMarkerReadings).get(),
        isEmpty,
      );
    });

    test('rejects invalid input before storage', () async {
      for (final invalid in [
        glucose('a', value: double.nan),
        glucose('a', value: 97), // mg/dL magnitude labelled mmol/L
      ]) {
        await expectLater(
          repository.saveBloodMarker(invalid),
          throwsA(isA<ValidationException>()),
        );
      }
      expect(
        await database.select(database.bloodMarkerReadings).get(),
        isEmpty,
      );
    });

    test('corrupt stored unit becomes a scrubbed storage error', () async {
      await repository.saveBloodMarker(glucose('a'));
      await database.customStatement(
        "UPDATE blood_marker_readings SET unit = 'private-value'",
      );
      await expectLater(
        repository.watchBloodMarker(BloodMarker.glucose).first,
        throwsA(
          isA<StorageException>()
              .having((e) => e.cause, 'cause', isNull)
              .having(
                (e) => e.toString(),
                'message',
                isNot(contains('private-value')),
              ),
        ),
      );
    });
  });

  test('deleteAllData empties both tables', () async {
    await repository.saveBloodPressure(bp('a'));
    await repository.saveBloodMarker(glucose('b'));
    await repository.deleteAllData();
    expect(
      await database.select(database.bloodPressureReadings).get(),
      isEmpty,
    );
    expect(await database.select(database.bloodMarkerReadings).get(), isEmpty);
  });

  test('SQL failures never retain raw exceptions with bound values', () async {
    await database.customStatement('DROP TABLE blood_pressure_readings');
    await database.customStatement('DROP TABLE blood_marker_readings');
    await expectLater(
      repository.saveBloodPressure(bp('a')),
      throwsA(isA<StorageException>().having((e) => e.cause, 'cause', isNull)),
    );
    await expectLater(
      repository.saveBloodMarker(glucose('a')),
      throwsA(isA<StorageException>().having((e) => e.cause, 'cause', isNull)),
    );
  });
}
