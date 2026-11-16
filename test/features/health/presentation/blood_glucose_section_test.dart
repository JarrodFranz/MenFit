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
import 'package:menfit_app/features/health/presentation/blood_glucose_section.dart';
import 'package:menfit_app/features/health/presentation/blood_marker_chart.dart';
import 'package:menfit_app/features/health/presentation/blood_marker_copy.dart';
import 'package:menfit_app/features/health/presentation/blood_marker_dialog.dart';

void main() {
  final today = LocalDate.today();
  var counter = 0;
  const mmol = BloodMarkerUnit.mmolPerL;
  const mg = BloodMarkerUnit.mgPerDl;

  // Newest first, as the repository returns them.
  BloodMarkerReading reading(
    int daysAgo,
    double value, {
    BloodMarkerUnit unit = mmol,
    GlucoseContext? context = GlucoseContext.fasting,
  }) {
    final day = today.addDays(-daysAgo);
    final at = DateTime(day.year, day.month, day.day, 7).toUtc();
    return BloodMarkerReading(
      id: 'g${counter++}',
      day: day,
      measuredAt: at,
      marker: BloodMarker.glucose,
      value: value,
      unit: unit,
      context: context,
      createdAt: at,
      updatedAt: at,
    );
  }

  Future<void> pump(
    WidgetTester tester,
    List<BloodMarkerReading> readings, {
    double width = 800,
    double height = 1400,
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
            body: SingleChildScrollView(child: BloodGlucoseSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty state still shows the reference block', (tester) async {
    await pump(tester, []);
    expect(find.text(glucoseEmptyState), findsOneWidget);
    expect(find.text(glucoseAddReading), findsOneWidget);
    for (final line in [
      glucoseReferenceTitle,
      glucoseRangeFastingMmol,
      glucoseRangeAfterMealMmol,
      glucoseSourceLine,
      glucoseScopeLine,
      glucoseNotADiagnosis,
      glucoseMeterLine,
    ]) {
      expect(find.text(line), findsOneWidget);
    }
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('rows show position only where a range exists', (tester) async {
    await pump(tester, [
      reading(0, 5.2),
      reading(1, 6, context: GlucoseContext.other),
      reading(2, 6.5, context: null),
    ]);
    expect(
      find.text('5.2 mmol/L · Fasting · Within the reference range'),
      findsOneWidget,
    );
    expect(find.text('6.0 mmol/L · Other'), findsOneWidget);
    expect(find.text('6.5 mmol/L'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('mg/dL-entered row stays in mg/dL; unit follows latest', (
    tester,
  ) async {
    await pump(tester, [
      reading(0, 94, unit: mg),
      reading(1, 5.2),
    ]);
    expect(
      find.text('94 mg/dL · Fasting · Within the reference range'),
      findsOneWidget,
    );
    expect(find.text(glucoseRangeFastingMgDl), findsOneWidget);
    expect(
      tester.widget<BloodMarkerChart>(find.byType(BloodMarkerChart)).unit,
      mg,
    );
  });

  testWidgets('unit toggle changes chart and ranges, not row values', (
    tester,
  ) async {
    await pump(tester, [reading(0, 5.2), reading(1, 94, unit: mg)]);
    expect(find.text(glucoseRangeFastingMmol), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'mg/dL'));
    await tester.pumpAndSettle();
    expect(find.text(glucoseRangeFastingMgDl), findsOneWidget);
    expect(find.text(glucoseRangeAfterMealMgDl), findsOneWidget);
    expect(find.text(glucoseRangeFastingMmol), findsNothing);
    expect(
      tester.widget<BloodMarkerChart>(find.byType(BloodMarkerChart)).unit,
      mg,
    );
    expect(find.textContaining('5.2 mmol/L'), findsOneWidget);
    expect(find.textContaining('94 mg/dL'), findsOneWidget);
  });

  testWidgets('low lines for 2.8 fasting', (tester) async {
    await pump(tester, [reading(0, 2.8)]);
    expect(find.textContaining('Below the reference range'), findsOneWidget);
    expect(find.text(glucoseBelowLine), findsOneWidget);
    expect(find.text(glucoseUrgentLine), findsOneWidget);
    expect(find.text(glucoseAboveLine), findsNothing);
    expect(find.text(glucoseChartTooFew), findsOneWidget);
  });

  testWidgets('above line for 6.0 fasting', (tester) async {
    await pump(tester, [reading(0, 6)]);
    expect(find.textContaining('Above the reference range'), findsOneWidget);
    expect(find.text(glucoseAboveLine), findsOneWidget);
    expect(find.text(glucoseBelowLine), findsNothing);
  });

  testWidgets('no position lines for 6.0 other', (tester) async {
    await pump(tester, [reading(0, 6, context: GlucoseContext.other)]);
    expect(find.text(glucoseAboveLine), findsNothing);
    expect(find.text(glucoseBelowLine), findsNothing);
    expect(find.text(glucoseNoRange), findsOneWidget);
  });

  final lowCases = <String, BloodMarkerReading Function()>{
    '2.8 other': () => reading(0, 2.8, context: GlucoseContext.other),
    '2.8 no context': () => reading(0, 2.8, context: null),
    '50 mg/dL bedtime': () =>
        reading(0, 50, unit: mg, context: GlucoseContext.bedtime),
  };
  for (final MapEntry(:key, :value) in lowCases.entries) {
    testWidgets('low lines for $key without a range', (tester) async {
      await pump(tester, [value()]);
      expect(find.text(glucoseBelowLine), findsOneWidget);
      expect(find.text(glucoseUrgentLine), findsOneWidget);
      expect(find.text(glucoseNoRange), findsOneWidget);
      expect(find.textContaining('Below the reference range'), findsNothing);
    });
  }

  testWidgets('no low lines for 3.0 other', (tester) async {
    await pump(tester, [reading(0, 3, context: GlucoseContext.other)]);
    expect(find.text(glucoseBelowLine), findsNothing);
    expect(find.text(glucoseUrgentLine), findsNothing);
    expect(find.text(glucoseNoRange), findsOneWidget);
  });

  testWidgets('lines sit only under the latest reading', (tester) async {
    await pump(tester, [reading(0, 5), reading(1, 2.5)]);
    expect(find.text(glucoseBelowLine), findsNothing);
    expect(find.textContaining('Below the reference range'), findsOneWidget);
  });

  testWidgets('range chips filter the history', (tester) async {
    await pump(tester, [reading(0, 5), reading(200, 6.1)]);
    expect(find.textContaining('6.1 mmol/L'), findsNothing);
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.textContaining('6.1 mmol/L'), findsOneWidget);
  });

  testWidgets('add opens the dialog in the latest unit', (tester) async {
    await pump(tester, [reading(0, 94, unit: mg)]);
    await tester.tap(find.text(glucoseAddReading));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<BloodMarkerDialog>(find.byType(BloodMarkerDialog))
          .defaultUnit,
      mg,
    );
    expect(find.text('Glucose (mg/dL)'), findsOneWidget);
  });

  testWidgets('tapping a row opens it for editing', (tester) async {
    final r = reading(0, 5.2);
    await pump(tester, [r]);
    await tester.tap(find.textContaining('5.2 mmol/L'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<BloodMarkerDialog>(find.byType(BloodMarkerDialog)).existing,
      r,
    );
  });

  for (final width in [320.0, 1400.0]) {
    testWidgets('no overflow at width $width and 1.3x text', (tester) async {
      await pump(
        tester,
        [
          reading(0, 2.8),
          for (var i = 1; i < 5; i++) reading(i, 180, unit: mg),
          reading(6, 6, context: GlucoseContext.afterMeal),
          reading(7, 6, context: GlucoseContext.bedtime),
        ],
        width: width,
        height: 3000,
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
      expect(find.text(glucoseBelowLine), findsOneWidget);
    });
  }

  testWidgets('tappable controls are at least 48 dp tall', (tester) async {
    await pump(tester, [reading(0, 5), reading(1, 5.5)], height: 2400);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });
}

class _Repository implements HealthReadingsRepository {
  _Repository(this.readings);

  final List<BloodMarkerReading> readings;

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
  }) => Stream.value(readings);

  @override
  Future<void> saveBloodMarker(BloodMarkerReading reading) async {}

  @override
  Future<void> deleteBloodMarker(String id) async {}

  @override
  Future<void> deleteAllData() async {}
}
