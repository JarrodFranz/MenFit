import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/cycle/data/drift_cycle_repository.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/presentation/period_entry_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Nit N7 coverage for [PeriodEntryController] directly (no widget/dialog
/// involved) - a real [DriftCycleRepository] over an in-memory database, the
/// same pattern as `cycle_repository_test.dart`, so `save()`'s persistence
/// side effects are asserted against real rows rather than a mock.
void main() {
  late db.AppDatabase database;
  late DriftCycleRepository repository;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftCycleRepository(database, prefs);
    container = ProviderContainer(
      overrides: [cycleRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('a validation failure returns false and persists nothing', () async {
    final provider = periodEntryControllerProvider(
      PeriodEntryMode.logNew,
      null,
    );
    final controller = container.read(provider.notifier);
    final today = LocalDate.today();

    controller.updatePeriodStart(today.addDays(1)); // in the future -> invalid
    final saved = await controller.save(const []);

    expect(saved, isFalse);
    expect(container.read(provider).startError, isNotNull);
    expect(await database.select(database.cycleRecords).get(), isEmpty);
  });

  test(
    'editing a record preserves its id and createdAt through save',
    () async {
      final originalCreatedAt = DateTime.utc(2020);
      final existing = CycleRecord(
        id: 'r1',
        periodStart: LocalDate(2026, 8, 1),
        periodEnd: LocalDate(2026, 8, 5),
        createdAt: originalCreatedAt,
        updatedAt: originalCreatedAt,
      );
      await repository.saveRecord(existing);

      final provider = periodEntryControllerProvider(
        PeriodEntryMode.editPast,
        existing,
      );
      final controller = container.read(provider.notifier)
        ..updatePeriodEnd(LocalDate(2026, 8, 6));

      final saved = await controller.save([existing]);
      expect(saved, isTrue);

      final rows = await database.select(database.cycleRecords).get();
      expect(rows, hasLength(1));
      expect(rows.single.id, 'r1');
      expect(rows.single.createdAt, originalCreatedAt.millisecondsSinceEpoch);
      expect(rows.single.periodEndDay, '2026-08-06');
    },
  );

  test(
    'a start/end error clears as soon as the relevant field is updated',
    () async {
      final provider = periodEntryControllerProvider(
        PeriodEntryMode.logNew,
        null,
      );
      final controller = container.read(provider.notifier);
      final today = LocalDate.today();

      controller.updatePeriodStart(today.addDays(1));
      await controller.save(const []);
      expect(container.read(provider).startError, isNotNull);

      controller.updatePeriodStart(today);
      expect(container.read(provider).startError, isNull);

      // Same for the end date: an overlap sets `endError`, and updating
      // either date clears it again (`updatePeriodStart` clears both;
      // `updatePeriodEnd` clears its own).
      final existing = CycleRecord(
        id: 'other',
        periodStart: LocalDate(2026, 1, 1),
        periodEnd: LocalDate(2026, 1, 5),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      controller
        ..updatePeriodStart(LocalDate(2026, 1, 2))
        ..updatePeriodEnd(LocalDate(2026, 1, 3));
      await controller.save([existing]);
      expect(container.read(provider).endError, isNotNull);

      controller.updatePeriodEnd(LocalDate(2026, 2, 1));
      expect(container.read(provider).endError, isNull);
    },
  );
}
