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
import 'package:menfit_app/features/health/presentation/blood_pressure_dialog.dart';

void main() {
  final stamp = DateTime.utc(2026, 11, 1, 7);
  final existing = BloodPressureReading(
    id: 'reading',
    day: LocalDate(2026, 11, 1),
    measuredAt: stamp,
    systolic: 128,
    diastolic: 82,
    pulse: 64,
    note: 'Morning',
    createdAt: stamp,
    updatedAt: stamp,
  );
  late _Repository repository;

  setUp(() => repository = _Repository());

  Finder field(String label) => find.widgetWithText(TextFormField, label);
  final systolic = field('Systolic, top number (mmHg)');
  final diastolic = field('Diastolic, bottom number (mmHg)');
  final pulse = field('Pulse (bpm, optional)');
  final note = field('Note (optional)');

  String textOf(WidgetTester tester, Finder finder) =>
      tester.widget<TextFormField>(finder).controller!.text;

  Future<void> pumpEditor(
    WidgetTester tester, {
    BloodPressureReading? reading,
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
                onPressed: () =>
                    BloodPressureDialog.show(context, existing: reading),
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

  testWidgets('blank required fields show validation messages', (
    tester,
  ) async {
    await pumpEditor(tester);
    await save(tester);
    expect(find.text(systolicError('')!), findsOneWidget);
    expect(find.text(diastolicError('')!), findsOneWidget);
    expect(repository.saved, isEmpty);
  });

  testWidgets('out-of-range pulse is rejected; blank pulse is fine', (
    tester,
  ) async {
    await pumpEditor(tester);
    await tester.enterText(systolic, '120');
    await tester.enterText(diastolic, '80');
    await tester.enterText(pulse, '300');
    await save(tester);
    expect(find.text(pulseError('300')!), findsOneWidget);
    expect(repository.saved, isEmpty);
    await tester.enterText(pulse, '');
    await save(tester);
    expect(repository.saved.single.pulse, isNull);
  });

  testWidgets('systolic must exceed diastolic', (tester) async {
    await pumpEditor(tester);
    await tester.enterText(systolic, '80');
    await tester.enterText(diastolic, '120');
    await save(tester);
    expect(find.text(bloodPressurePairError(80, 120)!), findsOneWidget);
    expect(repository.saved, isEmpty);
  });

  testWidgets('non-digit input is filtered out', (tester) async {
    await pumpEditor(tester);
    await tester.enterText(systolic, '12a0');
    expect(textOf(tester, systolic), '120');
  });

  testWidgets('save writes a UTC reading with all fields', (tester) async {
    await pumpEditor(tester);
    await tester.enterText(systolic, '128');
    await tester.enterText(diastolic, '82');
    await tester.enterText(pulse, '64');
    await tester.enterText(note, '  After coffee  ');
    await save(tester);
    final saved = repository.saved.single;
    expect(saved.systolic, 128);
    expect(saved.diastolic, 82);
    expect(saved.pulse, 64);
    expect(saved.note, 'After coffee');
    expect(saved.measuredAt.isUtc, isTrue);
    expect(saved.createdAt.isUtc, isTrue);
    expect(saved.day, LocalDate.fromDateTime(saved.measuredAt.toLocal()));
    expect(isValidBloodPressureReading(saved), isTrue);
    expect(find.byType(BloodPressureDialog), findsNothing);
  });

  testWidgets('edit prefills and keeps id, instant and createdAt', (
    tester,
  ) async {
    await pumpEditor(tester, reading: existing);
    expect(textOf(tester, systolic), '128');
    expect(textOf(tester, diastolic), '82');
    expect(textOf(tester, pulse), '64');
    expect(textOf(tester, note), 'Morning');
    await save(tester);
    final saved = repository.saved.single;
    expect(saved.id, 'reading');
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
    expect(find.byType(BloodPressureDialog), findsNothing);
  });

  testWidgets('save failure keeps the dialog open with a message', (
    tester,
  ) async {
    repository.failSave = true;
    await pumpEditor(tester, reading: existing);
    await save(tester);
    expect(find.byType(BloodPressureDialog), findsOneWidget);
    expect(textOf(tester, systolic), '128');
  });
}

class _Repository implements HealthReadingsRepository {
  final saved = <BloodPressureReading>[];
  final deleted = <String>[];
  bool failSave = false;

  @override
  Stream<List<BloodPressureReading>> watchBloodPressure({DateTime? since}) =>
      Stream.value(const []);

  @override
  Future<void> saveBloodPressure(BloodPressureReading reading) async {
    if (failSave) throw const StorageException(message: 'Could not save');
    saved.add(reading);
  }

  @override
  Future<void> deleteBloodPressure(String id) async => deleted.add(id);

  @override
  Stream<List<BloodMarkerReading>> watchBloodMarker(
    BloodMarker marker, {
    DateTime? since,
  }) => Stream.value(const []);

  @override
  Future<void> saveBloodMarker(BloodMarkerReading reading) async {}

  @override
  Future<void> deleteBloodMarker(String id) async {}

  @override
  Future<void> deleteAllData() async {}
}
