import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/recaps/data/recap_marker_store.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/recaps/domain/recap_trigger_evaluator.dart';
import 'package:shared_preferences/shared_preferences.dart';

CycleRecord _record(String id, LocalDate periodStart) => CycleRecord(
  id: id,
  periodStart: periodStart,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

/// Two logged periods, so exactly one cycle ("cycle:a", 1–28 June) is
/// completed; the June-29 period is still in progress and never recaps.
final List<CycleRecord> _oneCompletedCycle = [
  _record('a', LocalDate(2026, 6, 1)),
  _record('b', LocalDate(2026, 6, 29)),
];

/// Mid-July: the most recently completed calendar month is June 2026.
final LocalDate _midJuly = LocalDate(2026, 7, 15);

Future<RecapMarkerStore> _store([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  return RecapMarkerStore(await SharedPreferences.getInstance());
}

void main() {
  group('evaluateRecapDue - cycle end', () {
    test('offers the most recently completed cycle when none was shown', () {
      final due = evaluateRecapDue(
        cycleRecords: _oneCompletedCycle,
        today: _midJuly,
        lastShownCycleKey: null,
        lastShownMonthKey: 'month:2026-06',
      );

      expect(due, isA<CycleEndDue>());
      final period = (due as CycleEndDue).period;
      expect(period.key, 'cycle:a');
      expect(period.kind, RecapPeriodKind.cycleEnd);
      expect(period.start, LocalDate(2026, 6, 1));
      expect(period.end, LocalDate(2026, 6, 28));
    });

    test('a single logged period never completes a cycle', () {
      final due = evaluateRecapDue(
        cycleRecords: [_record('a', LocalDate(2026, 6, 1))],
        today: _midJuly,
        lastShownCycleKey: null,
        lastShownMonthKey: 'month:2026-06',
      );

      expect(due, isA<NoRecapDue>());
    });

    test('is not due again once its own key has been marked shown', () {
      final due = evaluateRecapDue(
        cycleRecords: _oneCompletedCycle,
        today: _midJuly,
        lastShownCycleKey: 'cycle:a',
        lastShownMonthKey: 'month:2026-06',
      );

      expect(due, isA<NoRecapDue>());
    });

    test('a newly completed cycle becomes due after an earlier one was '
        'shown', () {
      final due = evaluateRecapDue(
        cycleRecords: [
          ..._oneCompletedCycle,
          _record('c', LocalDate(2026, 7, 27)),
        ],
        today: LocalDate(2026, 8, 5),
        lastShownCycleKey: 'cycle:a',
        lastShownMonthKey: 'month:2026-07',
      );

      expect(due, isA<CycleEndDue>());
      expect((due as CycleEndDue).period.key, 'cycle:b');
    });

    test('an older completed cycle never resurfaces once the newest one '
        'has been shown', () {
      final due = evaluateRecapDue(
        cycleRecords: [
          ..._oneCompletedCycle,
          _record('c', LocalDate(2026, 7, 27)),
        ],
        today: LocalDate(2026, 8, 5),
        // "cycle:b" is the newest completed cycle; "cycle:a" was shown
        // long ago and must not come back.
        lastShownCycleKey: 'cycle:b',
        lastShownMonthKey: 'month:2026-07',
      );

      expect(due, isA<NoRecapDue>());
    });
  });

  group('evaluateRecapDue - month fallback', () {
    test('offers the most recently completed month with no cycle data', () {
      final due = evaluateRecapDue(
        cycleRecords: const [],
        today: _midJuly,
        lastShownCycleKey: null,
        lastShownMonthKey: null,
      );

      expect(due, isA<MonthEndDue>());
      final period = (due as MonthEndDue).period;
      expect(period.key, 'month:2026-06');
      expect(period.kind, RecapPeriodKind.month);
      expect(period.start, LocalDate(2026, 6, 1));
      expect(period.end, LocalDate(2026, 6, 30));
    });

    test('the in-progress month is never offered', () {
      final due = evaluateRecapDue(
        cycleRecords: const [],
        today: _midJuly,
        lastShownCycleKey: null,
        lastShownMonthKey: 'month:2026-06',
      );

      expect(due, isA<NoRecapDue>());
    });

    test('a new month falls due once the calendar rolls over', () {
      final due = evaluateRecapDue(
        cycleRecords: const [],
        today: LocalDate(2026, 8, 1),
        lastShownCycleKey: null,
        lastShownMonthKey: 'month:2026-06',
      );

      expect(due, isA<MonthEndDue>());
      expect((due as MonthEndDue).period.key, 'month:2026-07');
    });
  });

  group('evaluateRecapDue - precedence', () {
    test('cycle end wins when a month recap is due at the same time', () {
      final due = evaluateRecapDue(
        cycleRecords: _oneCompletedCycle,
        today: _midJuly,
        lastShownCycleKey: null,
        lastShownMonthKey: null,
      );

      expect(due, isA<CycleEndDue>());
      expect((due as CycleEndDue).period.key, 'cycle:a');
    });

    test('the month recap is not lost - it surfaces on the next check', () {
      // Exactly the previous case, re-evaluated after the cycle recap has
      // been marked shown.
      final due = evaluateRecapDue(
        cycleRecords: _oneCompletedCycle,
        today: _midJuly,
        lastShownCycleKey: 'cycle:a',
        lastShownMonthKey: null,
      );

      expect(due, isA<MonthEndDue>());
      expect((due as MonthEndDue).period.key, 'month:2026-06');
    });

    test('nothing is due once both markers are set', () {
      final due = evaluateRecapDue(
        cycleRecords: _oneCompletedCycle,
        today: _midJuly,
        lastShownCycleKey: 'cycle:a',
        lastShownMonthKey: 'month:2026-06',
      );

      expect(due, isA<NoRecapDue>());
    });
  });

  group('RecapMarkerStore', () {
    test('reports no marker before anything has been shown', () async {
      final store = await _store();

      expect(store.getLastShownCycleKey(), isNull);
      expect(store.getLastShownMonthKey(), isNull);
    });

    test('persists the two markers independently', () async {
      final store = await _store();

      await store.markCycleShown('cycle:a');
      expect(store.getLastShownCycleKey(), 'cycle:a');
      expect(store.getLastShownMonthKey(), isNull);

      await store.markMonthShown('month:2026-06');
      expect(store.getLastShownCycleKey(), 'cycle:a');
      expect(store.getLastShownMonthKey(), 'month:2026-06');
    });

    test('a later marker replaces the earlier one', () async {
      final store = await _store();

      await store.markCycleShown('cycle:a');
      await store.markCycleShown('cycle:b');

      expect(store.getLastShownCycleKey(), 'cycle:b');
    });

    test('a marker written by an earlier run is read back', () async {
      final store = await _store({
        'recaps_last_shown_cycle_key': 'cycle:a',
        'recaps_last_shown_month_key': 'month:2026-05',
      });

      expect(store.getLastShownCycleKey(), 'cycle:a');
      expect(store.getLastShownMonthKey(), 'month:2026-05');
    });
  });

  group('marker-driven trigger', () {
    /// Evaluates against whatever [store] currently holds — the same two
    /// reads `presentation/recap_trigger_controller.dart` performs.
    RecapDue evaluateWith(
      RecapMarkerStore store, {
      List<CycleRecord> cycleRecords = const [],
      LocalDate? today,
    }) {
      return evaluateRecapDue(
        cycleRecords: cycleRecords,
        today: today ?? _midJuly,
        lastShownCycleKey: store.getLastShownCycleKey(),
        lastShownMonthKey: store.getLastShownMonthKey(),
      );
    }

    test('each recap fires exactly once across repeated checks', () async {
      final store = await _store();

      // 1st check: the completed cycle, taking precedence over the month.
      final first = evaluateWith(store, cycleRecords: _oneCompletedCycle);
      expect(first, isA<CycleEndDue>());
      await store.markCycleShown((first as CycleEndDue).period.key);

      // 2nd check: the month that was queued behind it.
      final second = evaluateWith(store, cycleRecords: _oneCompletedCycle);
      expect(second, isA<MonthEndDue>());
      await store.markMonthShown((second as MonthEndDue).period.key);

      // 3rd and 4th checks: nothing left to show.
      expect(
        evaluateWith(store, cycleRecords: _oneCompletedCycle),
        isA<NoRecapDue>(),
      );
      expect(
        evaluateWith(store, cycleRecords: _oneCompletedCycle),
        isA<NoRecapDue>(),
      );
    });

    test('never fires when the markers are already in place', () async {
      final store = await _store({
        'recaps_last_shown_cycle_key': 'cycle:a',
        'recaps_last_shown_month_key': 'month:2026-06',
      });

      expect(
        evaluateWith(store, cycleRecords: _oneCompletedCycle),
        isA<NoRecapDue>(),
      );
    });
  });
}
