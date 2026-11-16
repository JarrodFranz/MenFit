import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart';
import 'package:menfit_app/features/health/domain/health_reading_validation.dart';
import 'package:menfit_app/features/health/domain/health_readings_repository.dart';
import 'package:menfit_app/features/health/health_providers.dart';
import 'package:menfit_app/features/health/presentation/blood_marker_copy.dart';
import 'package:menfit_app/features/health/presentation/blood_marker_dialog.dart';

void main() {
  const mmol = BloodMarkerUnit.mmolPerL;
  const mg = BloodMarkerUnit.mgPerDl;
  final stamp = DateTime.utc(2026, 11, 1, 7);
  final existing = BloodMarkerReading(
    id: 'reading',
    day: LocalDate(2026, 11, 1),
    measuredAt: stamp,
    marker: BloodMarker.glucose,
    value: 94,
    unit: mg,
    context: GlucoseContext.afterMeal,
    note: 'Lunch',
    createdAt: stamp,
    updatedAt: stamp,
  );
  late _Repository repository;

  setUp(() => repository = _Repository());

  final value = find.byType(TextFormField).first;
  final note = find.widgetWithText(TextFormField, 'Note (optional)');

  String textOf(WidgetTester tester, Finder finder) =>
      tester.widget<TextFormField>(finder).controller!.text;

  Future<void> pumpEditor(
    WidgetTester tester, {
    BloodMarkerReading? reading,
    BloodMarkerUnit defaultUnit = mmol,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthReadingsRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => BloodMarkerDialog.show(
                  context,
                  existing: reading,
                  defaultUnit: defaultUnit,
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

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  Future<void> chooseUnit(WidgetTester tester, BloodMarkerUnit unit) async {
    await tester.tap(find.widgetWithText(ChoiceChip, unit.label));
    await tester.pumpAndSettle();
  }

  String? mmolError(String input) =>
      bloodMarkerValueError(BloodMarker.glucose, mmol, input);
  String? mgError(String input) =>
      bloodMarkerValueError(BloodMarker.glucose, mg, input);

  testWidgets('blank value is rejected', (tester) async {
    await pumpEditor(tester);
    await save(tester);
    expect(find.text(mmolError('')!), findsOneWidget);
    expect(repository.saved, isEmpty);
  });

  testWidgets('validation follows the unit; switching re-validates', (
    tester,
  ) async {
    await pumpEditor(tester);
    await tester.enterText(value, '94');
    await save(tester);
    expect(find.text(mmolError('94')!), findsOneWidget);
    await chooseUnit(tester, mg);
    expect(find.text(mmolError('94')!), findsNothing);
    expect(textOf(tester, value), '94');
    await tester.enterText(value, '5');
    await save(tester);
    expect(find.text(mgError('5')!), findsOneWidget);
    expect(repository.saved, isEmpty);
  });

  testWidgets('comma is accepted as a decimal separator', (tester) async {
    await pumpEditor(tester);
    await tester.enterText(value, '5,4');
    await save(tester);
    expect(repository.saved.single.value, 5.4);
  });

  testWidgets('letters are filtered out', (tester) async {
    await pumpEditor(tester);
    await tester.enterText(value, '5a.2');
    expect(textOf(tester, value), '5.2');
  });

  testWidgets('unit defaults to the given latest unit', (tester) async {
    await pumpEditor(tester, defaultUnit: mg);
    expect(find.text('Glucose (mg/dL)'), findsOneWidget);
    await tester.enterText(value, '100');
    await save(tester);
    expect(repository.saved.single.unit, mg);
  });

  testWidgets('context is optional and starts unselected', (tester) async {
    await pumpEditor(tester);
    expect(find.text(glucoseContextHint), findsOneWidget);
    await tester.enterText(value, '5.2');
    await save(tester);
    expect(repository.saved.single.context, isNull);
  });

  testWidgets('save writes a valid UTC reading with all fields', (
    tester,
  ) async {
    await pumpEditor(tester);
    await tester.enterText(value, '5.2');
    await tester.tap(find.text(glucoseContextHint));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fasting').last);
    await tester.pumpAndSettle();
    await tester.enterText(note, '  Before training  ');
    await save(tester);
    final saved = repository.saved.single;
    expect(saved.value, 5.2);
    expect(saved.unit, mmol);
    expect(saved.marker, BloodMarker.glucose);
    expect(saved.context, GlucoseContext.fasting);
    expect(saved.note, 'Before training');
    expect(saved.measuredAt.isUtc, isTrue);
    expect(saved.createdAt.isUtc, isTrue);
    expect(saved.day, LocalDate.fromDateTime(saved.measuredAt.toLocal()));
    expect(isValidBloodMarkerReading(saved), isTrue);
    expect(find.byType(BloodMarkerDialog), findsNothing);
  });

  testWidgets('edit prefills and keeps id, unit, instant and createdAt', (
    tester,
  ) async {
    await pumpEditor(tester, reading: existing);
    expect(textOf(tester, value), '94');
    expect(textOf(tester, note), 'Lunch');
    expect(find.text('Glucose (mg/dL)'), findsOneWidget);
    expect(find.text(GlucoseContext.afterMeal.label), findsOneWidget);
    await save(tester);
    final saved = repository.saved.single;
    expect(saved.id, 'reading');
    expect(saved.value, 94);
    expect(saved.unit, mg);
    expect(saved.context, GlucoseContext.afterMeal);
    expect(saved.measuredAt, stamp);
    expect(saved.createdAt, stamp);
  });

  testWidgets('a changed time in the future is rejected', (tester) async {
    // Seconds make any re-picked time differ from the stored instant.
    final future = DateTime(2099, 1, 1, 7, 30, 15).toUtc();
    await pumpEditor(
      tester,
      reading: existing.copyWith(
        day: LocalDate(2099, 1, 1),
        measuredAt: future,
        createdAt: future,
        updatedAt: future,
      ),
    );
    await tester.ensureVisible(find.textContaining('Time:'));
    await tester.tap(find.textContaining('Time:'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await save(tester);
    expect(
      find.text('Choose a measurement time that has already happened.'),
      findsOneWidget,
    );
    expect(repository.saved, isEmpty);
  });

  testWidgets('delete requires confirmation', (tester) async {
    await pumpEditor(tester, reading: existing);
    await tester.ensureVisible(find.text('Delete reading'));
    await tester.tap(find.text('Delete reading'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(repository.deleted, isEmpty);
    await tester.tap(find.text('Delete reading'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(repository.deleted, ['reading']);
    expect(find.byType(BloodMarkerDialog), findsNothing);
  });

  testWidgets('save failure keeps the dialog open with a message', (
    tester,
  ) async {
    repository.failSave = true;
    await pumpEditor(tester, reading: existing);
    await save(tester);
    expect(find.byType(BloodMarkerDialog), findsOneWidget);
    expect(textOf(tester, value), '94');
  });
}

class _Repository implements HealthReadingsRepository {
  final saved = <BloodMarkerReading>[];
  final deleted = <String>[];
  bool failSave = false;

  @override
  Stream<List<BloodPressureReading>> watchBloodPressure({DateTime? since}) =>
      Stream.value(const []);

  @override
  Future<void> saveBloodPressure(BloodPressureReading reading) async {}

  @override
  Future<void> deleteBloodPressure(String id) async {}

  @override
  Stream<List<BloodMarkerReading>> watchBloodMarker(
    BloodMarker marker, {
    DateTime? since,
  }) => Stream.value(const []);

  @override
  Future<void> saveBloodMarker(BloodMarkerReading reading) async {
    if (failSave) throw const StorageException(message: 'Could not save');
    saved.add(reading);
  }

  @override
  Future<void> deleteBloodMarker(String id) async => deleted.add(id);

  @override
  Future<void> deleteAllData() async {}
}
