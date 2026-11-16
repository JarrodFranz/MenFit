import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';
import 'package:menfit_app/features/health/domain/blood_pressure_reading.dart';
import 'package:menfit_app/features/health/domain/health_readings_repository.dart';
import 'package:menfit_app/features/health/health_providers.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_copy.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_headline.dart';
import 'package:menfit_app/features/health/presentation/blood_pressure_section.dart';

void main() {
  final today = LocalDate.today();
  var counter = 0;

  // Newest first, as the repository returns them.
  BloodPressureReading reading(
    int daysAgo,
    int systolic,
    int diastolic, {
    int? pulse,
  }) {
    final day = today.addDays(-daysAgo);
    final at = DateTime(day.year, day.month, day.day, 7).toUtc();
    return BloodPressureReading(
      id: 'r${counter++}',
      day: day,
      measuredAt: at,
      systolic: systolic,
      diastolic: diastolic,
      pulse: pulse,
      createdAt: at,
      updatedAt: at,
    );
  }

  Future<void> pump(
    WidgetTester tester,
    List<BloodPressureReading> readings, {
    double width = 800,
    double height = 640,
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = Size(width, height)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthReadingsRepositoryProvider.overrideWithValue(
            _Repository(readings),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(child: BloodPressureSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty state', (tester) async {
    await pump(tester, []);
    expect(find.text(bpEmptyState), findsOneWidget);
    expect(find.text(bpAddReading), findsOneWidget);
    expect(find.text(bpNotADiagnosis), findsOneWidget);
    expect(find.text(bpSourceLine), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('rows show values, pulse and category label', (tester) async {
    await pump(tester, [
      reading(0, 128, 82, pulse: 64),
      reading(1, 118, 76),
    ]);
    expect(
      find.text('128/82 mmHg · pulse 64 · Normal'),
      findsOneWidget,
    );
    expect(find.text('118/76 mmHg · Optimal'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text(bpChartCaption), findsOneWidget);
  });

  testWidgets('one reading shows the too-few text instead of a chart', (
    tester,
  ) async {
    await pump(tester, [reading(0, 120, 80)]);
    expect(find.text(bpChartTooFew), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('highest-range line at 182/95', (tester) async {
    await pump(tester, [reading(0, 182, 95)]);
    expect(find.text(bpHighestRangeLine), findsOneWidget);
    expect(find.textContaining('Grade 3'), findsOneWidget);
  });

  testWidgets('no highest-range line at 150/95', (tester) async {
    await pump(tester, [reading(0, 150, 95)]);
    expect(find.text(bpHighestRangeLine), findsNothing);
    expect(find.textContaining('Grade 1'), findsOneWidget);
  });

  testWidgets('low line at 85/55 with no category label', (tester) async {
    await pump(tester, [reading(0, 85, 55)]);
    expect(find.text(bpLowLine), findsOneWidget);
    expect(find.text('85/55 mmHg'), findsOneWidget);
    for (final label in ['Optimal', 'Normal', 'High-normal', 'Grade']) {
      expect(find.textContaining(label), findsNothing);
    }
  });

  testWidgets('n of 5 hint under five days', (tester) async {
    await pump(tester, [for (var i = 0; i < 3; i++) reading(i, 120, 80)]);
    expect(find.text(bpWeeklyHint(3)), findsOneWidget);
    expect(find.text(bpWeeklyAverageTitle), findsNothing);
  });

  testWidgets('weekly headline at five days', (tester) async {
    await pump(tester, [for (var i = 0; i < 5; i++) reading(i, 136, 80)]);
    expect(find.text(bpWeeklyAverageTitle), findsOneWidget);
    expect(find.text(bpWeeklyBasis(5, 5)), findsOneWidget);
    expect(find.text(bpHomeNote), findsOneWidget);
    expect(find.textContaining('so far'), findsNothing);
  });

  testWidgets('weekly average below 90/60: no category, average low line', (
    tester,
  ) async {
    // The newest reading is classifiable, so its row adds no per-reading line.
    await pump(tester, [
      reading(0, 100, 70),
      for (var i = 1; i < 5; i++) reading(i, 80, 50),
    ]);
    expect(find.text(bpWeeklyAverageTitle), findsOneWidget);
    expect(find.text(bpAverageLowLine), findsOneWidget);
    expect(find.text(bpLowLine), findsNothing);
    final headline = find.byType(BloodPressureHeadline);
    for (final label in ['Optimal', 'Normal', 'High-normal', 'Grade']) {
      expect(
        find.descendant(of: headline, matching: find.textContaining(label)),
        findsNothing,
      );
    }
  });

  testWidgets('weekly average at or above 180/110: average highest line', (
    tester,
  ) async {
    await pump(tester, [
      reading(0, 150, 95),
      for (var i = 1; i < 5; i++) reading(i, 190, 115),
    ]);
    expect(find.text(bpAverageHighestRangeLine), findsOneWidget);
    expect(find.text(bpHighestRangeLine), findsNothing);
    expect(
      find.descendant(
        of: find.byType(BloodPressureHeadline),
        matching: find.textContaining('Grade 3'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('range chips filter the history', (tester) async {
    await pump(tester, [reading(0, 120, 80), reading(200, 140, 90)]);
    expect(find.textContaining('140/90 mmHg'), findsNothing);
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.textContaining('140/90 mmHg'), findsOneWidget);
  });

  for (final width in [320.0, 1400.0]) {
    testWidgets('no overflow at width $width and 1.3x text', (tester) async {
      await pump(
        tester,
        [
          for (var i = 0; i < 6; i++) reading(i, 182, 112, pulse: 70),
          reading(10, 85, 55),
        ],
        width: width,
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
      expect(find.text(bpWeeklyAverageTitle), findsOneWidget);
    });
  }

  testWidgets('tappable controls are at least 48 dp tall', (tester) async {
    await pump(
      tester,
      [reading(0, 120, 80), reading(1, 120, 80)],
      height: 2400,
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });
}

class _Repository implements HealthReadingsRepository {
  _Repository(this.readings);

  final List<BloodPressureReading> readings;

  @override
  Stream<List<BloodPressureReading>> watchBloodPressure({DateTime? since}) =>
      Stream.value(readings);

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
  Future<void> saveBloodMarker(BloodMarkerReading reading) async {}

  @override
  Future<void> deleteBloodMarker(String id) async {}

  @override
  Future<void> deleteAllData() async {}
}
