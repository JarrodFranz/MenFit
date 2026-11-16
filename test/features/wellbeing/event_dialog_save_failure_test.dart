import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/wellbeing/data/drift_wellbeing_repository.dart';
import 'package:menfit_app/features/wellbeing/domain/custom_event_store.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/event_dialog.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A store whose `saveTitle` always fails the way the real one does when the
/// platform refuses the write (`CustomWellbeingEventStore.saveTitle` turns
/// `SharedPreferences`' `false` into a [StorageException]).
class _FailingCustomEventStore implements CustomWellbeingEventStore {
  const _FailingCustomEventStore();

  @override
  Future<void> removeTitle(String title) async {}

  @override
  Future<void> clear() async {}

  @override
  List<String> savedTitles() => const [];

  @override
  Future<void> saveTitle(String title) async {
    throw const StorageException(
      message: 'Failed to save the custom event name',
    );
  }
}

/// Counts `saveEvent` calls so "the event was written once" is an assertion
/// about the call, not about a row count that a de-duplicating upsert could
/// flatter.
class _CountingWellbeingRepository extends DriftWellbeingRepository {
  _CountingWellbeingRepository(super._db);

  int saveEventCalls = 0;

  @override
  Future<void> saveEvent(WellbeingEvent event) {
    saveEventCalls++;
    return super.saveEvent(event);
  }
}

void main() {
  testWidgets(
    'a failed event-name save never reports the saved event as failed, and '
    'never leaves the dialog open to be saved a second time',
    (tester) async {
      tester.view
        ..physicalSize = const Size(500, 1600)
        ..devicePixelRatio = 1;
      addTearDown(() {
        tester.view
          ..resetPhysicalSize()
          ..resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final database = db.AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = _CountingWellbeingRepository(database);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            sharedPreferencesProvider.overrideWithValue(preferences),
            wellbeingRepositoryProvider.overrideWithValue(repository),
            customWellbeingEventStoreProvider.overrideWithValue(
              const _FailingCustomEventStore(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => EventDialog.show(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Other'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Event Name'),
        'Beach holiday',
      );
      await tester.tap(find.text('Save event name for future use'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log Event'));
      await tester.pumpAndSettle();

      // The event itself saved, once. The name did not — and that is the
      // only thing that failed, so nothing reports otherwise.
      expect(repository.saveEventCalls, 1);
      expect(find.byType(EventDialog), findsNothing);
      expect(find.textContaining('Failed to save event'), findsNothing);
      expect(find.textContaining('Please try again'), findsNothing);

      // One row, not two: a dialog left open on an already-saved event would
      // mint a fresh id on the next tap and write the same event twice.
      final events = await repository.getEventsOn(LocalDate.today());
      expect(events, hasLength(1));
      expect(events.single.title, 'Beach holiday');
    },
  );
}
