import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/domain/cycle_record.dart';
import 'package:menfit_app/features/streaks/domain/streak_assembly.dart';

/// `assembleProtectedDays` is the single decision source for "is this day
/// protected", shared by the streak engine and by the achievements
/// feature's cycle-aware consistency ladder. `streak_assembly_test.dart`
/// already covers what protection *does* to a streak; this file pins the
/// set itself, because a second consumer now reads it directly.
void main() {
  final today = LocalDate(2026, 8, 26);

  CycleRecord record({
    required LocalDate start,
    LocalDate? end,
    String id = 'r1',
  }) {
    return CycleRecord(
      id: id,
      periodStart: start,
      periodEnd: end,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  Set<LocalDate> assemble({
    Set<LocalDate> recoveryDays = const {},
    Set<LocalDate> flareProtectedDays = const {},
    List<CycleRecord> records = const [],
    bool pausingEnabled = true,
  }) {
    return assembleProtectedDays(
      recoveryDays: recoveryDays,
      flareProtectedDays: flareProtectedDays,
      records: records,
      pausingEnabled: pausingEnabled,
      today: today,
    );
  }

  test('no source at all is an empty set', () {
    expect(assemble(), isEmpty);
  });

  test('the three sources union, none of them requiring the others', () {
    final days = assemble(
      recoveryDays: {LocalDate(2026, 8, 20)},
      flareProtectedDays: {LocalDate(2026, 8, 21)},
      records: [
        record(start: LocalDate(2026, 8, 23), end: LocalDate(2026, 8, 25)),
      ],
    );
    expect(days, {
      LocalDate(2026, 8, 20),
      LocalDate(2026, 8, 21),
      LocalDate(2026, 8, 23),
      LocalDate(2026, 8, 24),
      LocalDate(2026, 8, 25),
    });
  });

  test('an ongoing period is capped at today, never predicted forward', () {
    final days = assemble(records: [record(start: LocalDate(2026, 8, 24))]);
    expect(days, {
      LocalDate(2026, 8, 24),
      LocalDate(2026, 8, 25),
      LocalDate(2026, 8, 26),
    });
    expect(days, isNot(contains(LocalDate(2026, 8, 27))));
  });

  test('a stale un-ended record stops protecting after a plausible period', () {
    // Protection from an ongoing record ends
    // `maxPlausiblePeriodDuration` days after its start, rather than
    // running to today forever: a record she forgot to close used to pause
    // her streak indefinitely, with no way back except editing the record.
    // She still can - logging the real end, or a recovery day - which is
    // exactly the point.
    const maxDuration = CyclePredictionEngine.maxPlausiblePeriodDuration;
    final start = LocalDate(2026, 6, 1);
    final days = assemble(records: [record(start: start)]);

    expect(days, hasLength(maxDuration));
    expect(days, contains(start.addDays(maxDuration - 1)));
    expect(days, isNot(contains(start.addDays(maxDuration))));
    expect(
      days,
      isNot(contains(today)),
      reason: 'a June record must not still be pausing the streak in August',
    );
  });

  test('period days stop protecting when pausing is off; the rest do not', () {
    final days = assemble(
      recoveryDays: {LocalDate(2026, 8, 20)},
      flareProtectedDays: {LocalDate(2026, 8, 21)},
      records: [
        record(start: LocalDate(2026, 8, 23), end: LocalDate(2026, 8, 25)),
      ],
      pausingEnabled: false,
    );
    expect(days, {LocalDate(2026, 8, 20), LocalDate(2026, 8, 21)});
  });

  test('a period logged long before any other source is still included', () {
    // The lower bound handed to `periodDaysInRange` is derived from the
    // records themselves, so an old period is not clipped away by a recent
    // recovery day.
    final days = assemble(
      recoveryDays: {LocalDate(2026, 8, 25)},
      records: [
        record(start: LocalDate(2024, 1, 2), end: LocalDate(2024, 1, 4)),
      ],
    );
    expect(days, contains(LocalDate(2024, 1, 3)));
    expect(days, hasLength(4));
  });

  test('overlapping sources collapse rather than double-counting', () {
    final day = LocalDate(2026, 8, 24);
    final days = assemble(
      recoveryDays: {day},
      flareProtectedDays: {day},
      records: [record(start: day, end: day)],
    );
    expect(days, {day});
  });
}
