import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/keto/data/drift_ketone_repository.dart';
import 'package:menfit_app/features/keto/domain/ketone_reading.dart';

void main() {
  late db.AppDatabase database;
  late DriftKetoneRepository repository;
  final day = LocalDate(2026, 1, 1);
  final stamp = DateTime.utc(2026, 1, 1, 10);

  KetoneReading reading(
    String id, {
    KetoneMeasurementType type = KetoneMeasurementType.blood,
    String result = '0.10',
    DateTime? at,
    DateTime? createdAt,
  }) => KetoneReading(
    id: id,
    day: day,
    measuredAt: at ?? stamp,
    type: type,
    result: result,
    createdAt: createdAt ?? stamp,
    updatedAt: createdAt ?? stamp,
  );

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftKetoneRepository(database);
  });

  tearDown(() => database.close());

  test('round trips every method, unit text and numeric precision', () async {
    final samples = [
      reading('a'),
      reading(
        'b',
        type: KetoneMeasurementType.urine,
        result: 'Trace (5 mg/dL)',
      ),
      reading('c', type: KetoneMeasurementType.breath, result: 'HI'),
    ];
    for (final sample in samples) {
      await repository.saveReading(sample);
    }
    final stored = await repository.watchReadingsForDay(day).first;
    expect(stored.map((r) => r.result), ['0.10', 'Trace (5 mg/dL)', 'HI']);
    expect(stored.map((r) => r.type), samples.map((r) => r.type));
    expect(
      stored.every(
        (r) => r.measuredAt.isUtc && r.createdAt.isUtc && r.updatedAt.isUtc,
      ),
      isTrue,
    );
    expect(stored.map((r) => r.day).toSet(), {day});
  });

  test('orders multiple readings by measurement, creation, then id', () async {
    for (final sample in [
      reading('b'),
      reading('a'),
      reading('c', at: stamp.subtract(const Duration(hours: 1))),
      reading('d', createdAt: stamp.subtract(const Duration(minutes: 1))),
    ]) {
      await repository.saveReading(sample);
    }
    expect((await repository.watchReadingsForDay(day).first).map((r) => r.id), [
      'c',
      'd',
      'a',
      'b',
    ]);
    expect(await repository.watchReadingsForDay(day.addDays(1)).first, isEmpty);
  });

  test(
    'editing preserves creation time and moves reading between days',
    () async {
      await repository.saveReading(reading('a'));
      final later = stamp.add(const Duration(hours: 1));
      await repository.saveReading(
        reading(
          'a',
          result: 'LO',
          createdAt: later,
        ).copyWith(day: day.addDays(-1)),
      );
      expect(await repository.watchReadingsForDay(day).first, isEmpty);
      final edited =
          (await repository.watchReadingsForDay(day.addDays(-1)).first).single;
      expect(edited.createdAt, stamp);
      expect(edited.updatedAt.isAfter(stamp), isTrue);
      expect(edited.result, 'LO');
    },
  );

  test('deletes individual reading and all data permanently', () async {
    await repository.saveReading(reading('a'));
    await repository.saveReading(reading('b'));
    await repository.deleteReading('a');
    expect(
      (await database.select(database.ketoneReadings).get()).single.id,
      'b',
    );
    await repository.deleteAllData();
    expect(await database.select(database.ketoneReadings).get(), isEmpty);
  });

  test(
    'clock correction preserves creation time and editable chronology',
    () async {
      final future = DateTime.utc(2099);
      await repository.saveReading(reading('a', createdAt: future));
      final first = (await repository.watchReadingsForDay(day).first).single;
      await repository.saveReading(first.copyWith(result: 'LO'));
      final edited = (await repository.watchReadingsForDay(day).first).single;
      expect(edited.createdAt, future);
      expect(edited.updatedAt.isBefore(future), isFalse);
      expect(edited.result, 'LO');
    },
  );

  test('rejects invalid input before storage', () async {
    await expectLater(
      repository.saveReading(reading('a', result: 'NaN')),
      throwsA(isA<ValidationException>()),
    );
    expect(await database.select(database.ketoneReadings).get(), isEmpty);
  });

  test('corrupt stored method becomes a scrubbed storage error', () async {
    await repository.saveReading(reading('a'));
    await database.customStatement(
      "UPDATE ketone_readings SET type = 'private-value'",
    );
    await expectLater(
      repository.watchReadingsForDay(day).first,
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

  test('SQL failures never retain raw exceptions with bound values', () async {
    await repository.saveReading(reading('a'));
    await database.customStatement('DROP TABLE ketone_readings');
    await expectLater(
      repository.saveReading(reading('b')),
      throwsA(isA<StorageException>().having((e) => e.cause, 'cause', isNull)),
    );
  });
}
