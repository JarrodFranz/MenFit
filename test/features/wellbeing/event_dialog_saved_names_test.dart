import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' show AppDatabase;
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/wellbeing/data/custom_event_store.dart';
import 'package:menfit_app/features/wellbeing/data/drift_wellbeing_repository.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/event_dialog.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FailingRemovalStore extends SharedPreferencesCustomWellbeingEventStore {
  const _FailingRemovalStore(super._preferences);

  @override
  Future<void> removeTitle(String title) async =>
      throw StateError('private text');
}

class _FailingDeleteRepository extends DriftWellbeingRepository {
  _FailingDeleteRepository(super._db);

  @override
  Future<void> deleteEvent(String id) async => throw StateError('private text');
}

void main() {
  final day = LocalDate(2026, 11, 16);
  final event = WellbeingEvent(
    id: EntityId.generate(),
    day: day,
    type: WellbeingEventType.other,
    title: 'Physio visit',
    isCustomSaved: true,
    createdAt: DateTime.utc(2026, 11, 16),
    updatedAt: DateTime.utc(2026, 11, 16),
  );
  late SharedPreferences preferences;
  late WellbeingEvent persistedEvent;

  Future<DriftWellbeingRepository> open(
    WidgetTester tester, {
    bool failRemoval = false,
    bool failDelete = false,
    bool editing = false,
  }) async {
    tester.view
      ..physicalSize = const Size(500, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    SharedPreferences.setMockInitialValues({
      'saved_custom_wellbeing_events': ['Physio visit', 'Beach holiday'],
    });
    preferences = await SharedPreferences.getInstance();
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = failDelete
        ? _FailingDeleteRepository(database)
        : DriftWellbeingRepository(database);
    await repository.saveEvent(event);
    persistedEvent = (await repository.getEventsOn(day)).single;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          wellbeingRepositoryProvider.overrideWithValue(repository),
          if (failRemoval)
            customWellbeingEventStoreProvider.overrideWithValue(
              _FailingRemovalStore(preferences),
            ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => EventDialog.show(
                  context,
                  initialDay: day,
                  existing: editing ? event : null,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    if (!editing) {
      await tester.tap(find.widgetWithText(ChoiceChip, 'Other'));
      await tester.pumpAndSettle();
    }
    return repository;
  }

  testWidgets(
    'saved names fill the name and removal preserves recorded events',
    (
      tester,
    ) async {
      final repository = await open(tester);
      final chip = find.widgetWithText(InputChip, 'Physio visit');
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.widgetWithText(TextField, 'Event Name'))
            .controller!
            .text,
        'Physio visit',
      );
      await tester.tap(
        find.descendant(
          of: chip,
          matching: find.byTooltip('Remove saved name'),
        ),
      );
      await tester.pumpAndSettle();
      expect(chip, findsNothing);
      expect(preferences.getStringList('saved_custom_wellbeing_events'), [
        'Beach holiday',
      ]);
      expect((await repository.getEventsOn(day)).single, persistedEvent);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Other'));
      await tester.pumpAndSettle();
      expect(chip, findsNothing);
    },
  );

  testWidgets('saving an edit does not restore the suggestion just removed', (
    tester,
  ) async {
    final repository = await open(tester, editing: true);
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(InputChip, 'Physio visit'),
        matching: find.byTooltip('Remove saved name'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isFalse,
    );
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(preferences.getStringList('saved_custom_wellbeing_events'), [
      'Beach holiday',
    ]);
    final events = await repository.getEventsOn(day);
    expect(events, hasLength(1));
    expect(events.single.id, event.id);
    expect(events.single.title, event.title);
  });

  testWidgets('reopening a historical event does not restore a removed name', (
    tester,
  ) async {
    final repository = await open(tester, editing: true);
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isTrue,
    );
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(InputChip, 'Physio visit'),
        matching: find.byTooltip('Remove saved name'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect((await repository.getEventsOn(day)).single.isCustomSaved, isTrue);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isFalse,
    );
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(preferences.getStringList('saved_custom_wellbeing_events'), [
      'Beach holiday',
    ]);
    final events = await repository.getEventsOn(day);
    expect(events, hasLength(1));
    expect(events.single.id, event.id);
    expect(events.single.title, event.title);
  });

  testWidgets(
    'removing a saved name failure keeps it visible without raw error',
    (
      tester,
    ) async {
      await open(tester, failRemoval: true);
      final chip = find.widgetWithText(InputChip, 'Physio visit');
      await tester.tap(
        find.descendant(
          of: chip,
          matching: find.byTooltip('Remove saved name'),
        ),
      );
      await tester.pumpAndSettle();
      expect(chip, findsOneWidget);
      expect(find.text('Could not remove saved name.'), findsOneWidget);
      expect(find.textContaining('private text'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('delete failure leaves the event available to retry safely', (
    tester,
  ) async {
    final repository = await open(tester, failDelete: true, editing: true);
    await tester.tap(find.byTooltip('Delete event'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(EventDialog), findsOneWidget);
    expect(
      find.text('Failed to delete event. Please try again.'),
      findsOneWidget,
    );
    expect((await repository.getEventsOn(day)).single, persistedEvent);
    expect(find.textContaining('private text'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
