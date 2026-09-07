import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' show AppDatabase;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/strength_routine.dart';

/// Regression: `activeStrengthCycleProvider` used to be a one-shot Future that
/// nothing invalidated, so "Set Active" wrote to the database and neither the
/// launcher sheet nor the Strength Hub ever updated (found on device
/// 2026-09-02). It is now a stream over `watchCycles()` and must follow
/// every activation change without anyone calling `invalidate`.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late ProviderSubscription<AsyncValue<StrengthCycle?>> keepAlive;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    // The provider is auto-dispose: without a live listener a bare `read`
    // creates it, returns AsyncLoading, and lets it be disposed again. Hold
    // one subscription for the whole test, as a mounted widget would.
    keepAlive = container.listen(activeStrengthCycleProvider, (_, _) {});
  });

  tearDown(() async {
    keepAlive.close();
    container.dispose();
    await db.close();
  });

  Future<StrengthCycle?> latest() async {
    await pumpEventQueue();
    return container.read(activeStrengthCycleProvider).value;
  }

  test('follows setActiveCycle without an explicit invalidate', () async {
    final repo = container.read(strengthRoutineRepositoryProvider);
    final upperLower = StrengthCycle.create(
      name: 'Upper / Lower Split',
      routines: [
        StrengthDayRoutine.create(
          name: 'Upper A',
          exercises: const [StrengthExerciseTemplate(name: 'Bench Press')],
        ),
      ],
    );
    await repo.saveCycle(upperLower);

    // Subscribe the way the widgets do.
    final seen = <String?>[];
    container.listen<AsyncValue<StrengthCycle?>>(
      activeStrengthCycleProvider,
      (_, next) => seen.add(next.value?.id),
      fireImmediately: true,
    );

    expect((await latest())?.id, isNull, reason: 'nothing active yet');

    await repo.setActiveCycle(upperLower.id);
    expect(
      (await latest())?.id,
      upperLower.id,
      reason: 'the write alone must surface - this is the bug',
    );

    await repo.setActiveCycle(null);
    expect(await latest(), isNull, reason: 'deactivation surfaces too');

    expect(
      seen,
      contains(upperLower.id),
      reason: 'listeners saw the activation without any invalidate call',
    );
  });

  test('a second cycle set active replaces the first', () async {
    final repo = container.read(strengthRoutineRepositoryProvider);
    final a = StrengthCycle.create(name: 'A');
    final b = StrengthCycle.create(name: 'B');
    await repo.saveCycle(a);
    await repo.saveCycle(b);

    await repo.setActiveCycle(a.id);
    expect((await latest())?.id, a.id);

    await repo.setActiveCycle(b.id);
    expect((await latest())?.id, b.id);
  });
}
