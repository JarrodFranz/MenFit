import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/weight/data/drift_weight_repository.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/weight/domain/weight_validation.dart';
import 'package:menfit_app/features/weight/presentation/weight_history_providers.dart';
import 'package:menfit_app/features/weight/presentation/widgets/weight_log_dialog.dart';
import 'package:menfit_app/features/weight/weight_providers.dart';

void main() {
  late db.AppDatabase database;
  late DriftWeightRepository repository;

  final today = LocalDate(2026, 9, 1);

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftWeightRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> openDialog(
    WidgetTester tester, {
    UnitSystem unitSystem = UnitSystem.metric,
    WeightLog? existing,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weightRepositoryProvider.overrideWithValue(repository),
          weightTodayProvider.overrideWithValue(today),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => WeightLogDialog.show(
                  context,
                  unitSystem: unitSystem,
                  existing: existing,
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
  }

  Future<void> enterWeight(WidgetTester tester, String value) async {
    await tester.enterText(
      find.byKey(const Key('weightLogWeightField')),
      value,
    );
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('weightLogSaveButton')));
    await tester.pumpAndSettle();
  }

  testWidgets('saves a reading through the repository', (tester) async {
    await openDialog(tester);
    await enterWeight(tester, '63.5');
    await save(tester);

    final stored = await repository.getLatestLog();
    expect(stored, isNotNull);
    expect(stored!.weightKg, 63.5);
    expect(stored.day, today);
    expect(stored.notes, isNull);
    expect(stored.source, WeightLogSource.manual);
    expect(find.byType(WeightLogDialog), findsNothing);
  });

  testWidgets('accepts a comma as the decimal separator', (tester) async {
    await openDialog(tester);
    await enterWeight(tester, '63,5');
    await save(tester);

    expect((await repository.getLatestLog())!.weightKg, 63.5);
  });

  testWidgets('converts a pound entry to canonical kilograms', (tester) async {
    await openDialog(tester, unitSystem: UnitSystem.imperial);
    await enterWeight(tester, '140');
    await save(tester);

    expect(
      (await repository.getLatestLog())!.weightKg,
      closeTo(UnitConversions.lbToKg(140), 1e-9),
    );
  });

  testWidgets('labels the field in their own unit', (tester) async {
    await openDialog(tester, unitSystem: UnitSystem.imperial);

    expect(find.text('Weight (lb)'), findsOneWidget);
    expect(find.text('Weight (kg)'), findsNothing);
  });

  testWidgets('stores a note, and null when none was typed', (tester) async {
    await openDialog(tester);
    await enterWeight(tester, '63.5');
    await tester.enterText(
      find.byKey(const Key('weightLogNoteField')),
      '  morning, before breakfast  ',
    );
    await save(tester);

    expect(
      (await repository.getLatestLog())!.notes,
      'morning, before breakfast',
    );
  });

  group('validation', () {
    testWidgets('refuses a blank field and saves nothing', (tester) async {
      await openDialog(tester);
      await save(tester);

      expect(await repository.getLatestLog(), isNull);
      expect(find.byType(WeightLogDialog), findsOneWidget);
      expect(find.text('Add a number to save this reading.'), findsOneWidget);
    });

    testWidgets('refuses something that is not a number', (tester) async {
      await openDialog(tester);
      await enterWeight(tester, 'sixty');
      await save(tester);

      expect(await repository.getLatestLog(), isNull);
      expect(find.textContaining("doesn't read as a number"), findsOneWidget);
    });

    testWidgets('refuses a value outside the storable range', (tester) async {
      await openDialog(tester);
      await enterWeight(tester, '900');
      await save(tester);

      expect(await repository.getLatestLog(), isNull);
      expect(find.textContaining('can be between'), findsOneWidget);
    });

    testWidgets('accepts both ends of the range', (tester) async {
      await openDialog(tester);
      await enterWeight(tester, '$minLoggableWeightKg');
      await save(tester);

      expect((await repository.getLatestLog())!.weightKg, minLoggableWeightKg);
    });

    testWidgets('refuses a note past the length limit', (tester) async {
      await openDialog(tester);
      await enterWeight(tester, '63.5');
      await tester.enterText(
        find.byKey(const Key('weightLogNoteField')),
        'x' * (maxWeightNoteLength + 1),
      );
      await save(tester);

      expect(await repository.getLatestLog(), isNull);
      expect(find.textContaining('Notes can be up to'), findsOneWidget);
    });
  });

  group('editing', () {
    final existing = WeightLog(
      id: 'existing',
      day: LocalDate(2026, 8, 20),
      weightKg: 61,
      notes: 'old note',
      source: WeightLogSource.profileMigration,
      createdAt: DateTime.utc(2026, 8, 20, 7),
      updatedAt: DateTime.utc(2026, 8, 20, 7),
    );

    testWidgets('prefills the reading being edited', (tester) async {
      await repository.saveLog(existing);
      await openDialog(tester, existing: existing);

      expect(find.text('Edit reading'), findsOneWidget);
      expect(find.text('61.0'), findsOneWidget);
      expect(find.text('old note'), findsOneWidget);
    });

    testWidgets('updates in place rather than adding a second row', (
      tester,
    ) async {
      await repository.saveLog(existing);
      await openDialog(tester, existing: existing);
      await enterWeight(tester, '62.5');
      await save(tester);

      final stored = await repository.getLogsForRange(
        LocalDate(2026, 8, 20),
        LocalDate(2026, 8, 20),
      );
      expect(stored, hasLength(1));
      expect(stored.single.id, 'existing');
      expect(stored.single.weightKg, 62.5);
    });

    testWidgets('keeps the provenance of the row it edits', (tester) async {
      await repository.saveLog(existing);
      await openDialog(tester, existing: existing);
      await enterWeight(tester, '62.5');
      await save(tester);

      final stored = await repository.getLatestLog();
      expect(stored!.source, WeightLogSource.profileMigration);
    });

    testWidgets('clears the note when it is emptied', (tester) async {
      await repository.saveLog(existing);
      await openDialog(tester, existing: existing);
      await tester.enterText(
        find.byKey(const Key('weightLogNoteField')),
        '',
      );
      await save(tester);

      expect((await repository.getLatestLog())!.notes, isNull);
    });
  });
}
