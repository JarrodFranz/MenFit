import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/keto/domain/ketone_reading.dart';
import 'package:menfit_app/features/keto/domain/ketone_repository.dart';
import 'package:menfit_app/features/keto/keto_providers.dart';
import 'package:menfit_app/features/keto/presentation/keto_screen.dart';
import 'package:menfit_app/features/keto/presentation/ketone_reading_dialog.dart';
import 'package:menfit_app/features/nutrition/domain/calorie_target.dart';
import 'package:menfit_app/features/nutrition/domain/macro_targets.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_facts.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_goals.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_totals.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';

void main() {
  final day = LocalDate.today();
  final stamp = DateTime.utc(2026);
  final existing = KetoneReading(
    id: 'reading',
    day: day,
    measuredAt: stamp,
    type: KetoneMeasurementType.blood,
    result: '0.10',
    createdAt: stamp,
    updatedAt: stamp,
  );
  late _Repository repository;

  setUp(() => repository = _Repository());

  Future<void> pumpEditor(WidgetTester tester, {KetoneReading? reading}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [ketoneRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => KetoneReadingDialog.show(
                  context,
                  day: day,
                  existing: reading,
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
  }

  testWidgets('method switch clears unsaved text and saves urine verbatim', (
    tester,
  ) async {
    await pumpEditor(tester);
    await tester.enterText(find.byType(TextFormField), '0.10');
    await tester.tap(
      find.byType(DropdownButtonFormField<KetoneMeasurementType>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Urine').last);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      isEmpty,
    );
    await tester.enterText(find.byType(TextFormField), 'Trace (5 mg/dL)');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.saved.single.type, KetoneMeasurementType.urine);
    expect(repository.saved.single.result, 'Trace (5 mg/dL)');
    expect(repository.saved.single.measuredAt.isUtc, isTrue);
  });

  testWidgets('editing preserves exact result and measurement instant', (
    tester,
  ) async {
    await pumpEditor(tester, reading: existing);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.saved.single.id, existing.id);
    expect(repository.saved.single.result, '0.10');
    expect(repository.saved.single.measuredAt, stamp);
    expect(repository.saved.single.createdAt, stamp);
  });

  testWidgets('invalid numeric text never reaches repository', (tester) async {
    await pumpEditor(tester);
    await tester.enterText(find.byType(TextFormField), '-2');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.saved, isEmpty);
    expect(find.text('Enter a non-negative number, LO or HI.'), findsOneWidget);
  });

  testWidgets('clock correction leaves an unchanged reading editable', (
    tester,
  ) async {
    final future = DateTime.utc(2099);
    await pumpEditor(
      tester,
      reading: existing.copyWith(
        measuredAt: future,
        createdAt: future,
        updatedAt: future,
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'LO');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.saved.single.measuredAt, future);
    expect(repository.saved.single.createdAt, future);
    expect(repository.saved.single.updatedAt, future);
  });

  testWidgets('delete is visible and requires confirmation', (tester) async {
    await pumpEditor(tester, reading: existing);
    await tester.ensureVisible(find.text('Delete reading'));
    await tester.tap(find.text('Delete reading'));
    await tester.pumpAndSettle();
    expect(repository.deleted, isEmpty);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(repository.deleted, isEmpty);
    await tester.tap(find.text('Delete reading'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(repository.deleted, ['reading']);
    expect(find.byType(KetoneReadingDialog), findsNothing);
  });

  testWidgets('save failure leaves editor and result available', (
    tester,
  ) async {
    repository.failSave = true;
    await pumpEditor(tester, reading: existing);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(KetoneReadingDialog), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      '0.10',
    );
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
          .onPressed,
      isNotNull,
    );
  });

  for (final width in [320.0, 1400.0]) {
    testWidgets('diary macros and percentage targets at width $width', (
      tester,
    ) async {
      tester.view
        ..physicalSize = Size(width, 1800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ketoneRepositoryProvider.overrideWithValue(repository),
            dayNutritionTotalsProvider.overrideWith(
              (ref, day) => Stream.value(
                const DayNutritionTotals(
                  total: NutritionTotals(
                    facts: NutritionFacts(
                      caloriesKcal: 999,
                      proteinGrams: 30,
                      carbsGrams: 50,
                      fatGrams: 20,
                      fiberGrams: 10,
                    ),
                    entryCount: 1,
                  ),
                  byMeal: {},
                ),
              ),
            ),
            nutritionGoalsProvider.overrideWith(
              (ref) => Stream.value(
                NutritionGoals(
                  id: 'goals',
                  createdAt: stamp,
                  updatedAt: stamp,
                  macroTargetMode: MacroTargetMode.percent,
                  proteinTargetPercent: 20,
                  carbTargetPercent: 10,
                  fatTargetPercent: 70,
                  hideCalorieNumbers: true,
                ),
              ),
            ),
            dayCalorieTargetProvider.overrideWithValue(
              const DayCalorieTarget(targetKcal: 2000),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(width == 320 ? 2 : 1)),
              child: child!,
            ),
            home: const KetoScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Recorded carbs: 50.0 g · current target 50.0 g'),
        findsOneWidget,
      );
      expect(
        find.text('Protein: 30.0 g · current target 100.0 g'),
        findsOneWidget,
      );
      expect(find.textContaining('999'), findsNothing);
      expect(find.textContaining('2000'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

class _Repository implements KetoneRepository {
  final saved = <KetoneReading>[];
  final deleted = <String>[];
  bool failSave = false;

  @override
  Stream<List<KetoneReading>> watchReadingsForDay(LocalDate day) =>
      Stream.value([]);

  @override
  Future<void> saveReading(KetoneReading reading) async {
    if (failSave) throw const StorageException(message: 'Could not save');
    saved.add(reading);
  }

  @override
  Future<void> deleteReading(String id) async => deleted.add(id);

  @override
  Future<void> deleteAllData() async => saved.clear();
}
