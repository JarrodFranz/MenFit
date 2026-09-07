import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart' as db;
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/weight/data/drift_weight_repository.dart';
import 'package:menfit_app/features/weight/domain/weight_log.dart';
import 'package:menfit_app/features/weight/presentation/weight_history_providers.dart';
import 'package:menfit_app/features/weight/weight_providers.dart';
import 'package:menfit_app/features/weight/weight_widgets.dart';

import 'weight_test_vocabulary.dart';

/// The Progress screen mounts this through `weight_widgets.dart` only
/// (ADR 007), so the test imports it the same way.
void main() {
  late db.AppDatabase database;
  late DriftWeightRepository weightRepository;

  final today = LocalDate(2026, 9, 1);

  setUp(() {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
    weightRepository = DriftWeightRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> seedReadings(int days) async {
    for (var i = days - 1; i >= 0; i--) {
      final day = today.addDays(-i);
      await weightRepository.saveLog(
        WeightLog(
          id: day.toIso(),
          day: day,
          weightKg: 62 + (i.isEven ? 0.4 : -0.4),
          createdAt: DateTime.utc(2026, 9, 1, 7),
          updatedAt: DateTime.utc(2026, 9, 1, 7),
        ),
      );
    }
  }

  Future<void> pumpSection(WidgetTester tester) async {
    // Registered here rather than per test so no test can forget it: this
    // card mounts autoDispose providers over Drift `watch` queries, whose
    // cleanup timers are otherwise still pending at teardown.
    addTearDown(() => flushDriftTimers(tester));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weightRepositoryProvider.overrideWithValue(weightRepository),
          weightTodayProvider.overrideWithValue(today),
          activityUnitSystemProvider.overrideWith(
            (ref) => Stream.value(UnitSystem.metric),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(child: WeightProgressSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders its own empty state rather than disappearing', (
    tester,
  ) async {
    await pumpSection(tester);

    expect(find.text('Weight'), findsOneWidget);
    expect(find.textContaining('No weight readings yet'), findsOneWidget);
    expect(find.text('Log weight'), findsOneWidget);
    expect(find.text('View history'), findsOneWidget);
    await flushDriftTimers(tester);
  });

  testWidgets('shows the trend once there are readings', (tester) async {
    await seedReadings(20);
    await pumpSection(tester);

    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('Latest reading'), findsOneWidget);
    expect(find.text('62.4 kg'), findsOneWidget);
    await flushDriftTimers(tester);
  });

  testWidgets('carries the fluid-shift note with the chart', (tester) async {
    await seedReadings(20);
    await pumpSection(tester);

    expect(find.textContaining('mostly with fluid'), findsOneWidget);
    await flushDriftTimers(tester);
  });

  testWidgets('opens the entry dialog from the card', (tester) async {
    await pumpSection(tester);

    await tester.tap(find.byKey(const Key('weightSectionLogButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('weightLogWeightField')), findsOneWidget);
    await flushDriftTimers(tester);
  });
}
