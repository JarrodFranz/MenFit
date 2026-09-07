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
import 'package:menfit_app/features/weight/presentation/weight_screen.dart';
import 'package:menfit_app/features/weight/weight_providers.dart';

import 'weight_test_vocabulary.dart';

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

  /// [days] consecutive daily readings ending today.
  Future<void> seedReadings(int days) async {
    for (var i = days - 1; i >= 0; i--) {
      final day = today.addDays(-i);
      await weightRepository.saveLog(
        WeightLog(
          id: day.toIso(),
          day: day,
          // A gentle sawtooth, so the trend has something to smooth.
          weightKg: 62 + (i.isEven ? 0.4 : -0.4),
          createdAt: DateTime.utc(2026, 9, 1, 7),
          updatedAt: DateTime.utc(2026, 9, 1, 7),
        ),
      );
    }
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    UnitSystem unitSystem = UnitSystem.metric,
  }) async {
    // Registered here rather than per test so no test can forget it: this
    // screen mounts autoDispose providers over Drift `watch` queries, whose
    // cleanup timers are otherwise still pending at teardown — which fails
    // the test *and* wedges every test after it in this file.
    addTearDown(() => flushDriftTimers(tester));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weightRepositoryProvider.overrideWithValue(weightRepository),
          weightTodayProvider.overrideWithValue(today),
          activityUnitSystemProvider.overrideWith(
            (ref) => Stream.value(unitSystem),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const WeightScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Scrolls [finder] into view before tapping it: this screen is taller
  /// than the test viewport, and the extended FAB sits over its bottom.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  LineChartData chartData(WidgetTester tester) =>
      tester.widget<LineChart>(find.byType(LineChart)).data;

  List<FlSpot> rawSpots(WidgetTester tester) =>
      chartData(tester).lineBarsData.last.spots;

  testWidgets('shows the empty state before anything is logged', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.textContaining('No weight readings yet'), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);
    expect(find.text('Nothing logged in this range.'), findsOneWidget);
    await flushDriftTimers(tester);
  });

  group('an empty range with a non-empty history', () {
    /// One reading in April — five months before [today], so it is outside
    /// every range shorter than 6M.
    Future<void> seedAprilOnly() async {
      await weightRepository.saveLog(
        WeightLog(
          id: 'april',
          day: LocalDate(2026, 4, 12),
          weightKg: 61.5,
          createdAt: DateTime.utc(2026, 4, 12, 7),
          updatedAt: DateTime.utc(2026, 4, 12, 7),
        ),
      );
    }

    testWidgets('does not claim they have never logged anything', (
      tester,
    ) async {
      await seedAprilOnly();
      await pumpScreen(tester);

      // The default range is 3M, which April falls outside of — while the
      // header above still shows the April reading, because "latest" is
      // range-independent.
      expect(find.text('61.5 kg'), findsWidgets);
      expect(find.byType(LineChart), findsNothing);
      expect(find.textContaining('No weight readings yet'), findsNothing);
      expect(
        find.textContaining('Nothing was logged in this stretch'),
        findsOneWidget,
      );
      await flushDriftTimers(tester);
    });

    testWidgets('goes back to the chart when the range is widened', (
      tester,
    ) async {
      await seedAprilOnly();
      await pumpScreen(tester);

      await tapVisible(tester, find.text('6M'));

      expect(find.byType(LineChart), findsOneWidget);
      expect(
        find.textContaining('Nothing was logged in this stretch'),
        findsNothing,
      );
      await flushDriftTimers(tester);
    });

    testWidgets('keeps the never-logged wording when nothing exists at all', (
      tester,
    ) async {
      await pumpScreen(tester);

      expect(
        find.textContaining('Nothing was logged in this stretch'),
        findsNothing,
      );
      expect(find.textContaining('No weight readings yet'), findsOneWidget);
      await flushDriftTimers(tester);
    });
  });

  testWidgets('renders the chart, the headline and the fluid note', (
    tester,
  ) async {
    await seedReadings(20);
    await pumpScreen(tester);

    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('Latest reading'), findsOneWidget);
    expect(find.text('62.4 kg'), findsWidgets);
    expect(find.textContaining('mostly with fluid'), findsOneWidget);
    await flushDriftTimers(tester);
  });

  testWidgets('honours the imperial unit preference', (tester) async {
    await seedReadings(20);
    await pumpScreen(tester, unitSystem: UnitSystem.imperial);

    expect(find.textContaining('lb'), findsWidgets);
    expect(find.textContaining('62.4 kg'), findsNothing);
    expect(find.textContaining('pound'), findsOneWidget);
    await flushDriftTimers(tester);
  });

  group('range selector', () {
    testWidgets('defaults to three months', (tester) async {
      await seedReadings(40);
      await pumpScreen(tester);

      expect(rawSpots(tester), hasLength(40));
      await flushDriftTimers(tester);
    });

    testWidgets('narrows the window when a shorter range is picked', (
      tester,
    ) async {
      await seedReadings(40);
      await pumpScreen(tester);

      await tapVisible(tester, find.text('1M'));

      expect(rawSpots(tester), hasLength(30));
      await flushDriftTimers(tester);
    });

    testWidgets('offers every range', (tester) async {
      await seedReadings(10);
      await pumpScreen(tester);

      for (final label in ['1M', '3M', '6M', '1Y', 'All']) {
        expect(find.text(label), findsOneWidget);
      }
      await flushDriftTimers(tester);
    });
  });

  group('series toggle', () {
    testWidgets('switches to the trend line alone', (tester) async {
      await seedReadings(20);
      await pumpScreen(tester);
      expect(chartData(tester).lineBarsData, hasLength(2));

      await tapVisible(tester, find.text('Trend only'));

      expect(chartData(tester).lineBarsData, hasLength(1));
      await flushDriftTimers(tester);
    });

    testWidgets('is hidden while there is no trend to show', (tester) async {
      await seedReadings(3);
      await pumpScreen(tester);

      expect(find.text('Trend only'), findsNothing);
      expect(find.textContaining('needs readings on at least'), findsOneWidget);
      await flushDriftTimers(tester);
    });
  });

  group('history', () {
    testWidgets('lists the readings newest first', (tester) async {
      await weightRepository.saveLog(
        WeightLog(
          id: 'older',
          day: today.addDays(-1),
          weightKg: 61,
          createdAt: DateTime.utc(2026, 8, 31, 7),
          updatedAt: DateTime.utc(2026, 8, 31, 7),
        ),
      );
      await weightRepository.saveLog(
        WeightLog(
          id: 'newer',
          day: today,
          weightKg: 63,
          createdAt: DateTime.utc(2026, 9, 1, 7),
          updatedAt: DateTime.utc(2026, 9, 1, 7),
        ),
      );
      await pumpScreen(tester);

      final newer = tester.getTopLeft(find.text('63.0 kg').last);
      final older = tester.getTopLeft(find.text('61.0 kg').last);
      expect(newer.dy, lessThan(older.dy));
      await flushDriftTimers(tester);
    });

    testWidgets('shows a note when one was attached', (tester) async {
      await weightRepository.saveLog(
        WeightLog(
          id: 'noted',
          day: today,
          weightKg: 63,
          notes: 'new scale',
          createdAt: DateTime.utc(2026, 9, 1, 7),
          updatedAt: DateTime.utc(2026, 9, 1, 7),
        ),
      );
      await pumpScreen(tester);

      expect(find.text('new scale'), findsOneWidget);
      await flushDriftTimers(tester);
    });

    testWidgets('deletes a reading after confirmation', (tester) async {
      await weightRepository.saveLog(
        WeightLog(
          id: 'doomed',
          day: today,
          weightKg: 63,
          createdAt: DateTime.utc(2026, 9, 1, 7),
          updatedAt: DateTime.utc(2026, 9, 1, 7),
        ),
      );
      await pumpScreen(tester);

      await tapVisible(tester, find.byIcon(Icons.more_vert));
      await tapVisible(tester, find.text('Delete'));
      await tapVisible(
        tester,
        find.byKey(const Key('weightDeleteConfirmButton')),
      );

      expect(await weightRepository.getLatestLog(), isNull);
      await flushDriftTimers(tester);
    });

    testWidgets('leaves the reading alone when the delete is cancelled', (
      tester,
    ) async {
      await weightRepository.saveLog(
        WeightLog(
          id: 'kept',
          day: today,
          weightKg: 63,
          createdAt: DateTime.utc(2026, 9, 1, 7),
          updatedAt: DateTime.utc(2026, 9, 1, 7),
        ),
      );
      await pumpScreen(tester);

      await tapVisible(tester, find.byIcon(Icons.more_vert));
      await tapVisible(tester, find.text('Delete'));
      await tapVisible(tester, find.text('Cancel'));

      expect(await weightRepository.getLatestLog(), isNotNull);
      await flushDriftTimers(tester);
    });
  });

  group('the judgement-vocabulary sweep', () {
    /// Every string the user can currently read, whatever kind of widget or
    /// callback it lives in.
    ///
    /// Sweeping `Text` alone missed most of the surface: a chart's
    /// accessibility label, its tooltip strings, and a menu button's
    /// tooltip are all copy a user reads (or hears), and none of them is a
    /// `Text` in the tree. Each entry is `(source, text)` so a failure
    /// names what to go and fix.
    List<(String, String)> readableCopy(WidgetTester tester) {
      final found = <(String, String)>[
        for (final widget in tester.widgetList<Text>(find.byType(Text)))
          if (widget.data != null) ('a Text widget', widget.data!),
        for (final widget in tester.widgetList<Tooltip>(find.byType(Tooltip)))
          if (widget.message != null) ('a Tooltip', widget.message!),
      ];

      // The chart's own strings: the semantics label screen readers get,
      // and every tooltip the touch handler can build.
      if (find.byType(LineChart).evaluate().isNotEmpty) {
        final chartSemantics = tester.widget<Semantics>(
          find
              .ancestor(
                of: find.byType(LineChart),
                matching: find.byType(Semantics),
              )
              .first,
        );
        final label = chartSemantics.properties.label;
        if (label != null) found.add(('the chart semantics label', label));

        final data = chartData(tester);
        final getItems = data.lineTouchData.touchTooltipData.getTooltipItems;
        for (
          var barIndex = 0;
          barIndex < data.lineBarsData.length;
          barIndex++
        ) {
          final bar = data.lineBarsData[barIndex];
          for (final spot in bar.spots) {
            for (final item in getItems([LineBarSpot(bar, barIndex, spot)])) {
              if (item != null) found.add(('a chart tooltip', item.text));
            }
          }
        }
      }

      return found;
    }

    void expectClean(WidgetTester tester, {required String where}) {
      final rendered = readableCopy(tester);
      expect(rendered, isNotEmpty, reason: 'nothing was swept in $where');
      for (final (source, text) in rendered) {
        expectNoJudgementVocabulary(text, source: '$source in $where');
      }
    }

    testWidgets('across the screen itself', (tester) async {
      await seedReadings(20);
      await pumpScreen(tester);

      expectClean(tester, where: 'the weight screen');
      await flushDriftTimers(tester);
    });

    testWidgets('across the entry dialog and its date picker', (tester) async {
      await pumpScreen(tester);

      await tapVisible(tester, find.byKey(const Key('weightLogFab')));
      expect(find.byKey(const Key('weightLogWeightField')), findsOneWidget);
      expectClean(tester, where: 'the log dialog');

      // An invalid save, so the validation messages are on screen too.
      await tester.tap(find.byKey(const Key('weightLogSaveButton')));
      await tester.pumpAndSettle();
      expectClean(tester, where: 'the log dialog after a refused save');

      await tester.tap(find.byKey(const Key('weightLogDayButton')));
      await tester.pumpAndSettle();
      expect(find.text('Which day was this reading?'), findsOneWidget);
      expectClean(tester, where: 'the date picker');
      await flushDriftTimers(tester);
    });

    testWidgets('across the row menu and the delete confirmation', (
      tester,
    ) async {
      await weightRepository.saveLog(
        WeightLog(
          id: 'swept',
          day: today,
          weightKg: 63,
          createdAt: DateTime.utc(2026, 9, 1, 7),
          updatedAt: DateTime.utc(2026, 9, 1, 7),
        ),
      );
      await pumpScreen(tester);

      // The PopupMenuButton's tooltip is only reachable while the row is
      // mounted; the menu items only once it is open.
      expectClean(tester, where: 'the history row');

      await tapVisible(tester, find.byIcon(Icons.more_vert));
      expectClean(tester, where: 'the open row menu');

      await tapVisible(tester, find.text('Delete'));
      expectClean(tester, where: 'the delete confirmation');
      await flushDriftTimers(tester);
    });
  });
}
