import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/recaps/data/recap_marker_store.dart';
import 'package:menfit_app/features/recaps/domain/recap_period.dart';
import 'package:menfit_app/features/recaps/domain/recap_trigger_evaluator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mid-July: the most recently completed calendar month is June 2026.
final LocalDate _midJuly = LocalDate(2026, 7, 15);

Future<RecapMarkerStore> _store([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  return RecapMarkerStore(await SharedPreferences.getInstance());
}

void main() {
  group('evaluateRecapDue', () {
    test('offers the most recently completed month when none was shown', () {
      final due = evaluateRecapDue(today: _midJuly, lastShownMonthKey: null);

      expect(due, isA<MonthEndDue>());
      final period = (due as MonthEndDue).period;
      expect(period.key, 'month:2026-06');
      expect(period.kind, RecapPeriodKind.monthEnd);
      expect(period.start, LocalDate(2026, 6, 1));
      expect(period.end, LocalDate(2026, 6, 30));
    });

    test('the in-progress month is never offered', () {
      final due = evaluateRecapDue(
        today: _midJuly,
        lastShownMonthKey: 'month:2026-06',
      );

      expect(due, isA<NothingDue>());
    });

    test('a new month falls due once the calendar rolls over', () {
      final due = evaluateRecapDue(
        today: LocalDate(2026, 8, 1),
        lastShownMonthKey: 'month:2026-06',
      );

      expect(due, isA<MonthEndDue>());
      expect((due as MonthEndDue).period.key, 'month:2026-07');
    });
  });

  group('RecapMarkerStore', () {
    test('reports no marker before anything has been shown', () async {
      final store = await _store();

      expect(store.getLastShownMonthKey(), isNull);
    });

    test('persists the month marker', () async {
      final store = await _store();

      await store.markMonthShown('month:2026-06');
      expect(store.getLastShownMonthKey(), 'month:2026-06');
    });

    test('a later marker replaces the earlier one', () async {
      final store = await _store();

      await store.markMonthShown('month:2026-06');
      await store.markMonthShown('month:2026-07');

      expect(store.getLastShownMonthKey(), 'month:2026-07');
    });

    test('a marker written by an earlier run is read back', () async {
      final store = await _store({
        'recaps_last_shown_month_key': 'month:2026-05',
      });

      expect(store.getLastShownMonthKey(), 'month:2026-05');
    });
  });

  group('marker-driven trigger', () {
    /// Evaluates against whatever [store] currently holds — the same read
    /// `presentation/recap_trigger_controller.dart` performs.
    RecapTriggerDecision evaluateWith(
      RecapMarkerStore store, {
      LocalDate? today,
    }) {
      return evaluateRecapDue(
        today: today ?? _midJuly,
        lastShownMonthKey: store.getLastShownMonthKey(),
      );
    }

    test('each recap fires exactly once across repeated checks', () async {
      final store = await _store();

      final first = evaluateWith(store);
      expect(first, isA<MonthEndDue>());
      await store.markMonthShown((first as MonthEndDue).period.key);

      expect(evaluateWith(store), isA<NothingDue>());
      expect(evaluateWith(store), isA<NothingDue>());
    });

    test('never fires when the marker is already in place', () async {
      final store = await _store({
        'recaps_last_shown_month_key': 'month:2026-06',
      });

      expect(evaluateWith(store), isA<NothingDue>());
    });
  });
}
