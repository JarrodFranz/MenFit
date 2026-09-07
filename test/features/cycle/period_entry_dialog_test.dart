import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/cycle/data/drift_cycle_repository.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/cycle/domain/cycle_repository.dart';
import 'package:menfit_app/features/cycle/presentation/period_entry_controller.dart';
import 'package:menfit_app/features/cycle/presentation/widgets/period_entry_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// B1 + S1 coverage for [PeriodEntryDialog]'s `logNew` mode: the new
/// optional end-date field (S1) and the "no error can be invisible" rule
/// (B1). Dates are driven directly through [PeriodEntryController] (rather
/// than through the native date picker, which widget tests can't easily
/// drive) - the dialog widget is a plain [ConsumerWidget] reading the same
/// provider instance, so this exercises exactly the same save() path a
/// real picker interaction would.
void main() {
  late db.AppDatabase database;
  late DriftCycleRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftCycleRepository(database, prefs);
  });

  tearDown(() async {
    await database.close();
  });

  CycleRecord existingAugRecord() => CycleRecord(
    id: 'existing',
    periodStart: LocalDate(2026, 8, 10),
    periodEnd: LocalDate(2026, 8, 14),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  /// Opens the real `logNew` dialog (via [PeriodEntryDialog.show], exactly
  /// as `CycleScreen` does) and returns the [ProviderContainer] backing it,
  /// so the test can drive [PeriodEntryController] directly.
  Future<ProviderContainer> openLogNewDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cycleRepositoryProvider.overrideWithValue(repository),
          appDatabaseProvider.overrideWithValue(database),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => PeriodEntryDialog.show(
                  context,
                  mode: PeriodEntryMode.logNew,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(
      tester.element(find.byType(PeriodEntryDialog)),
    );
  }

  testWidgets(
    'S1: the optional end date field is present in logNew, showing '
    '"Ongoing" until a date is picked',
    (tester) async {
      await openLogNewDialog(tester);

      expect(
        find.text('End date (leave empty if ongoing)'),
        findsOneWidget,
      );
      expect(find.text('Ongoing'), findsOneWidget);

      await _flushPendingTimers(tester);
    },
  );

  testWidgets(
    'S1 backfill: a completed past period saves alongside an existing '
    'record, with an explicit end date',
    (tester) async {
      await repository.saveRecord(existingAugRecord());

      final container = await openLogNewDialog(tester);
      container.read(
          periodEntryControllerProvider(PeriodEntryMode.logNew, null).notifier,
        )
        ..updatePeriodStart(LocalDate(2026, 7, 20))
        ..updatePeriodEnd(LocalDate(2026, 7, 25));
      await tester.pump();

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Log period'),
        ),
      );
      await tester.pumpAndSettle();

      // The dialog closed (save succeeded) and both records now exist.
      expect(find.byType(PeriodEntryDialog), findsNothing);
      final rows = await database.select(database.cycleRecords).get();
      expect(rows, hasLength(2));
      final backfilled = rows.firstWhere(
        (r) => r.periodStartDay == '2026-07-20',
      );
      expect(backfilled.periodEndDay, '2026-07-25');

      await _flushPendingTimers(tester);
    },
  );

  testWidgets(
    'B1: an overlap on logNew surfaces a visible error message in the tree, '
    'and the dialog stays open',
    (tester) async {
      await repository.saveRecord(existingAugRecord());

      final container = await openLogNewDialog(tester);
      // Overlaps the existing Aug 10-14 record.
      container.read(
          periodEntryControllerProvider(PeriodEntryMode.logNew, null).notifier,
        )
        ..updatePeriodStart(LocalDate(2026, 8, 12))
        ..updatePeriodEnd(LocalDate(2026, 8, 13));
      await tester.pump();

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Log period'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining("overlaps with a period you've already logged"),
        findsOneWidget,
      );
      // A validation failure must never close the dialog.
      expect(find.byType(AlertDialog), findsOneWidget);

      final rows = await database.select(database.cycleRecords).get();
      expect(rows, hasLength(1)); // nothing new was persisted

      await _flushPendingTimers(tester);
    },
  );

  testWidgets(
    'nit N2: the save button is disabled with a loading tooltip while '
    'cycle history is still loading',
    (tester) async {
      // A repository whose `watchRecords()` never emits - the loading
      // state persists for the whole test.
      final neverLoads = _NeverEmittingCycleRepository(repository);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cycleRepositoryProvider.overrideWithValue(neverLoads),
            appDatabaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => PeriodEntryDialog.show(
                    context,
                    mode: PeriodEntryMode.logNew,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final saveButtonFinder = find.widgetWithText(FilledButton, 'Log period');
      final button = tester.widget<FilledButton>(saveButtonFinder);
      expect(button.onPressed, isNull);
      expect(find.byTooltip('Loading your history…'), findsOneWidget);

      await _flushPendingTimers(tester);
    },
  );
}

/// Drift's query-stream cleanup schedules a zero-duration `Timer` when an
/// autoDispose stream provider (`cycleRecordsControllerProvider`, backed by
/// a real [DriftCycleRepository] in every test above) loses its last
/// listener - flushing it here avoids a false "Timer is still pending"
/// failure at `flutter_test`'s end-of-test teardown (see `flutter
/// development knowledge/testing-pitfalls.md`).
Future<void> _flushPendingTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

/// Wraps a real [DriftCycleRepository] but never emits from
/// `watchRecords()`, for the nit N2 loading-state test.
class _NeverEmittingCycleRepository implements CycleRepository {
  _NeverEmittingCycleRepository(this._delegate);

  final DriftCycleRepository _delegate;

  @override
  Stream<List<CycleRecord>> watchRecords() =>
      const Stream<List<CycleRecord>>.empty();

  @override
  Future<List<CycleRecord>> getRecords() => _delegate.getRecords();

  @override
  Future<void> saveRecord(CycleRecord record) => _delegate.saveRecord(record);

  @override
  Future<void> saveRecords(List<CycleRecord> records) =>
      _delegate.saveRecords(records);

  @override
  Future<void> deleteRecord(String id) => _delegate.deleteRecord(id);

  @override
  Stream<bool> watchStreakPausingEnabled() =>
      _delegate.watchStreakPausingEnabled();

  @override
  Future<void> setStreakPausingEnabled({required bool enabled}) =>
      _delegate.setStreakPausingEnabled(enabled: enabled);

  @override
  Future<void> deleteAllData() => _delegate.deleteAllData();

  @override
  Future<void> clearStreakPausingPreference() =>
      _delegate.clearStreakPausingPreference();
}
