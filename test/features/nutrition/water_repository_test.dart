import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/nutrition/data/drift_water_repository.dart';

void main() {
  late db.AppDatabase database;
  late DriftWaterRepository repository;
  final day = LocalDate(2026, 8, 29);

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftWaterRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('watchWaterForDay starts with 0', () async {
    final stream = repository.watchWaterForDay(day);
    expect(await stream.first, 0);
  });

  test('logWater increases total milliliters', () async {
    await repository.logWater(day: day, milliliters: 250);
    await repository.logWater(day: day, milliliters: 500);

    final total = await repository.watchWaterForDay(day).first;
    expect(total, 750);
  });

  test('removeWater decreases total milliliters', () async {
    await repository.logWater(day: day, milliliters: 500);
    await repository.removeWater(day: day, milliliters: 250);

    final total = await repository.watchWaterForDay(day).first;
    expect(total, 250);
  });

  test('resetWaterForDay clears all entries for day', () async {
    await repository.logWater(day: day, milliliters: 500);
    await repository.resetWaterForDay(day);

    final total = await repository.watchWaterForDay(day).first;
    expect(total, 0);
  });

  group('getWaterTotalsForRange', () {
    test('omits days with no logged water entirely', () async {
      final totals = await repository.getWaterTotalsForRange(
        day,
        day.addDays(2),
      );
      expect(totals, isEmpty);
    });

    test('sums multiple logs per day and only includes logged days', () async {
      await repository.logWater(day: day, milliliters: 500);
      await repository.logWater(day: day, milliliters: 300);
      await repository.logWater(day: day.addDays(2), milliliters: 2000);

      final totals = await repository.getWaterTotalsForRange(
        day,
        day.addDays(2),
      );

      expect(totals, {
        day: 800,
        day.addDays(2): 2000,
      });
      expect(totals.containsKey(day.addDays(1)), isFalse);
    });

    test('excludes logs outside the requested range', () async {
      await repository.logWater(day: day.addDays(-1), milliliters: 250);
      await repository.logWater(day: day.addDays(10), milliliters: 250);
      await repository.logWater(day: day, milliliters: 400);

      final totals = await repository.getWaterTotalsForRange(
        day,
        day.addDays(2),
      );

      expect(totals, {day: 400});
    });
  });
}
