import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database.dart' show AppDatabase;
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/wellbeing/data/drift_wellbeing_repository.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_event.dart';
import 'package:menfit_app/features/wellbeing/presentation/event_dialog.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final day = LocalDate(2026, 10, 8);

  Future<DriftWellbeingRepository> openDialog(
    WidgetTester tester, {
    WellbeingEvent? existing,
  }) async {
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
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftWellbeingRepository(database);
    if (existing != null) await repository.saveEvent(existing);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          wellbeingRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => EventDialog.show(
                  context,
                  existing: existing,
                  initialDay: day,
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
    return repository;
  }

  testWidgets('new event requires a type even when a name is entered', (
    tester,
  ) async {
    final repository = await openDialog(tester);
    expect(
      tester
          .widgetList<ChoiceChip>(find.byType(ChoiceChip))
          .every(
            (chip) => !chip.selected,
          ),
      isTrue,
    );
    final name = find.widgetWithText(TextField, 'Event Name');
    expect(tester.widget<TextField>(name).controller!.text, isEmpty);
    final save = find.widgetWithText(FilledButton, 'Log Event');
    expect(tester.widget<FilledButton>(save).onPressed, isNull);

    await tester.enterText(name, 'A life event');
    await tester.pump();
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.byType(EventDialog), findsOneWidget);
    expect(await repository.getEventsOn(day), isEmpty);
  });

  for (final type in WellbeingEventType.values) {
    testWidgets('selecting ${type.name} enables saving with that type', (
      tester,
    ) async {
      final repository = await openDialog(tester);
      await tester.tap(
        find.widgetWithText(
          ChoiceChip,
          type == WellbeingEventType.other ? 'Other' : type.defaultTitle,
        ),
      );
      await tester.pumpAndSettle();
      final name = find.widgetWithText(TextField, 'Event Name');
      if (type == WellbeingEventType.other) {
        expect(tester.widget<TextField>(name).controller!.text, isEmpty);
        await tester.enterText(name, 'A life event');
      } else {
        expect(
          tester.widget<TextField>(name).controller!.text,
          type.defaultTitle,
        );
      }
      final save = find.widgetWithText(FilledButton, 'Log Event');
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.byType(EventDialog), findsNothing);
      final events = await repository.getEventsOn(day);
      expect(events, hasLength(1));
      expect(events.single.type, type);
      expect(
        events.single.title,
        type == WellbeingEventType.other ? 'A life event' : type.defaultTitle,
      );
    });
  }

  testWidgets('editing retains the saved type and name', (tester) async {
    final now = DateTime.utc(2026, 10, 8);
    final existing = WellbeingEvent(
      id: EntityId.generate(),
      day: day,
      type: WellbeingEventType.injury,
      title: 'Sprained ankle',
      createdAt: now,
      updatedAt: now,
    );
    final repository = await openDialog(tester, existing: existing);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Injury'))
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<TextField>(find.widgetWithText(TextField, 'Event Name'))
          .controller!
          .text,
      'Sprained ankle',
    );
    final save = find.widgetWithText(FilledButton, 'Save Changes');
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    await tester.tap(save);
    await tester.pumpAndSettle();
    final events = await repository.getEventsOn(day);
    expect(events, hasLength(1));
    expect(events.single.id, existing.id);
    expect(events.single.type, existing.type);
    expect(events.single.title, existing.title);
  });
}
