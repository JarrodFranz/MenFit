import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/streaks/data/drift_recovery_repository.dart';
import 'package:menfit_app/features/streaks/domain/recovery_day_entry.dart';
import 'package:menfit_app/features/streaks/domain/recovery_repository.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/flare_controller.dart';

/// Coverage for the multi-day half of [FlareController]: the single-day /
/// date-range choice, and the "also mark these as recovery days" tick box.
///
/// Real repositories over an in-memory database (the same pattern as
/// `cycle/period_entry_controller_test.dart`) so `save()`'s persistence side
/// effects are asserted against real rows, not a mock — except where a
/// *failing* recovery write is the thing under test, which needs a fake that
/// can throw.
void main() {
  late db.AppDatabase database;
  late ProviderContainer container;
  late LocalDate today;

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    today = LocalDate.today();
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  /// Fills in the two required fields so `save()` gets past validation.
  void completeRequiredFields(FlareController controller) {
    controller
      ..setSeverity(FlareSeverity.moderate)
      ..setImpact(FlareImpact.reducedTraining);
  }

  FlareEvent flareOver(LocalDate day, {LocalDate? endDay}) {
    return FlareEvent(
      id: 'flare-1',
      day: day,
      endDay: endDay,
      severity: FlareSeverity.mild,
      impact: FlareImpact.none,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  test('a date-range flare persists endDay', () async {
    final controller = container.read(flareControllerProvider(null).notifier);
    completeRequiredFields(controller);
    controller
      ..setRangeMode(isRange: true)
      ..updateDay(today.addDays(-4))
      ..updateEndDay(today.addDays(-2));

    expect(await controller.save(), isTrue);

    final rows = await database.select(database.flareEvents).get();
    expect(rows, hasLength(1));
    expect(rows.single.day, today.addDays(-4).toIso());
    expect(rows.single.endDay, today.addDays(-2).toIso());
  });

  test('a single-day flare persists a null endDay', () async {
    final controller = container.read(flareControllerProvider(null).notifier);
    completeRequiredFields(controller);
    // Pick an end day, then go back to single-day: the stored flare must
    // still be single-day, not silently a range.
    controller
      ..setRangeMode(isRange: true)
      ..updateEndDay(today)
      ..setRangeMode(isRange: false)
      ..updateDay(today.addDays(-1));

    expect(await controller.save(), isTrue);

    final rows = await database.select(database.flareEvents).get();
    expect(rows.single.day, today.addDays(-1).toIso());
    expect(rows.single.endDay, isNull);
  });

  test(
    'ticking the box marks every day of the range as a recovery day, with a '
    'neutral note that carries no symptom or severity detail',
    () async {
      final controller = container.read(flareControllerProvider(null).notifier);
      completeRequiredFields(controller);
      controller
        ..setRangeMode(isRange: true)
        ..updateDay(today.addDays(-2))
        ..updateEndDay(today)
        ..setMarkAsRecovery(value: true);

      expect(await controller.save(), isTrue);

      final rows = await database.select(database.recoveryDays).get();
      expect(
        rows.map((row) => row.day).toSet(),
        {
          today.addDays(-2).toIso(),
          today.addDays(-1).toIso(),
          today.toIso(),
        },
      );
      for (final row in rows) {
        expect(row.note, flareRecoveryDayNote);
        expect(row.note, isNot(contains('moderate')));
      }
    },
  );

  test('unticking the box unmarks every day of the range', () async {
    final start = today.addDays(-2);
    final marked = {start, today.addDays(-1), today};
    await DriftRecoveryRepository(database).markRecoveryDays(start, today);

    final existing = flareOver(start, endDay: today);
    final controller = container.read(
      flareControllerProvider(existing).notifier,
    );
    completeRequiredFields(controller);
    controller.setMarkAsRecovery(value: false);

    expect(await controller.save(markedRecoveryDays: marked), isTrue);
    expect(await database.select(database.recoveryDays).get(), isEmpty);
  });

  test(
    'an already-fully-marked range reads as ticked, a partly-marked one does '
    'not, and saving without touching the box writes nothing',
    () async {
      final start = today.addDays(-2);
      final existing = flareOver(start, endDay: today);
      final controller = container.read(
        flareControllerProvider(existing).notifier,
      );

      // The dialog opens in range mode for a flare that has an endDay.
      expect(container.read(flareControllerProvider(existing)).isRange, isTrue);
      expect(
        controller.rangeFullyMarked({start, today.addDays(-1), today}),
        isTrue,
      );
      expect(controller.rangeFullyMarked({start, today}), isFalse);
      expect(controller.rangeFullyMarked(const {}), isFalse);

      // Untouched box + already-marked range => a no-op, so a note the user
      // set on those days elsewhere survives a plain re-save of the flare.
      await DriftRecoveryRepository(
        database,
      ).markRecoveryDays(start, today, note: 'Sore calves');
      completeRequiredFields(controller);
      expect(
        await controller.save(
          markedRecoveryDays: {start, today.addDays(-1), today},
        ),
        isTrue,
      );

      final rows = await database.select(database.recoveryDays).get();
      expect(rows, hasLength(3));
      expect(rows.every((row) => row.note == 'Sore calves'), isTrue);
    },
  );

  test(
    'a recovery-marking failure after a successful flare save leaves the '
    'flare saved and surfaces the error instead of closing the dialog',
    () async {
      final failing = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          recoveryRepositoryProvider.overrideWithValue(
            _FailingRecoveryRepository(),
          ),
        ],
      );
      addTearDown(failing.dispose);

      final provider = flareControllerProvider(null);
      final controller = failing.read(provider.notifier);
      completeRequiredFields(controller);
      controller
        ..setRangeMode(isRange: true)
        ..updateDay(today.addDays(-1))
        ..updateEndDay(today)
        ..setMarkAsRecovery(value: true);

      expect(await controller.save(), isFalse);

      // The flare is NOT rolled back...
      expect(await database.select(database.flareEvents).get(), hasLength(1));
      // ...the error is surfaced, and the dialog is told to stay open.
      final state = failing.read(provider);
      expect(state.recoveryError, isNotNull);
      expect(state.submitError, isNull);
      expect(state.didSave, isFalse);
      expect(state.isSubmitting, isFalse);

      // Retrying must update the same flare row, never create a second one.
      await controller.save();
      expect(await database.select(database.flareEvents).get(), hasLength(1));
    },
  );

  test('an end day before the start day surfaces endDayError', () async {
    final provider = flareControllerProvider(null);
    final controller = container.read(provider.notifier);
    completeRequiredFields(controller);
    controller
      ..setRangeMode(isRange: true)
      ..updateDay(today.addDays(-1))
      ..updateEndDay(today.addDays(-5));

    expect(await controller.save(), isFalse);

    final state = container.read(provider);
    expect(state.endDayError, isNotNull);
    expect(state.dayError, isNull);
    expect(await database.select(database.flareEvents).get(), isEmpty);
  });

  test('an end day in the future surfaces endDayError', () async {
    final provider = flareControllerProvider(null);
    final controller = container.read(provider.notifier);
    completeRequiredFields(controller);
    controller
      ..setRangeMode(isRange: true)
      ..updateDay(today)
      ..updateEndDay(today.addDays(1));

    expect(await controller.save(), isFalse);

    final state = container.read(provider);
    expect(state.endDayError, isNotNull);
    expect(state.dayError, isNull);
    expect(await database.select(database.flareEvents).get(), isEmpty);
  });
}

/// A [RecoveryRepository] whose writes always fail — stands in for a storage
/// error hitting the recovery step *after* the flare itself saved.
class _FailingRecoveryRepository implements RecoveryRepository {
  @override
  Stream<Set<LocalDate>> watchRecoveryDays() => const Stream.empty();

  @override
  Stream<List<RecoveryDayEntry>> watchRecoveryDayEntries() =>
      const Stream.empty();

  @override
  Future<void> markRecoveryDay(LocalDate day, {String? note}) =>
      markRecoveryDays(day, day, note: note);

  @override
  Future<void> markRecoveryDays(LocalDate from, LocalDate to, {String? note}) {
    throw const StorageException(message: 'Failed to save recovery day');
  }

  @override
  Future<void> unmarkRecoveryDay(LocalDate day) => unmarkRecoveryDays(day, day);

  @override
  Future<void> unmarkRecoveryDays(LocalDate from, LocalDate to) {
    throw const StorageException(message: 'Failed to remove recovery day');
  }

  @override
  Future<void> deleteAllData() async {}
}
