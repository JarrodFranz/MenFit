import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/cycle/domain/cycle_prediction_engine.dart';
import 'package:menfit_app/features/cycle/presentation/cycle_day_semantics.dart';

/// What the calendar says out loud under **Enhanced Semantics**.
///
/// The gate that matters here is not "is there a label" but "does the
/// label distinguish what the user logged from what the app guessed" —
/// `knowledge/domain/womens_health.md` allows the first as fact and
/// requires the second to be named as an estimate.
void main() {
  DayCycleStatus status({
    bool logged = false,
    bool predicted = false,
    bool ovulation = false,
    CyclePhase phase = CyclePhase.none,
    int? cycleDay,
  }) {
    return DayCycleStatus(
      date: LocalDate(2026, 3, 17),
      isLoggedPeriod: logged,
      isPredictedPeriod: predicted,
      phase: phase,
      cycleDayNumber: cycleDay,
      isOvulationDay: ovulation,
    );
  }

  String labelFor(
    DayCycleStatus value, {
    bool isToday = false,
    CycleConfidence confidence = CycleConfidence.moderate,
  }) => cycleDaySemanticLabel(
    status: value,
    isToday: isToday,
    confidence: confidence,
  );

  test('names the date in words, not as a bare number', () {
    expect(labelFor(status()), startsWith('Tuesday 17 March'));
  });

  test('marks today', () {
    expect(labelFor(status(), isToday: true), startsWith('Today, Tuesday'));
  });

  test('a logged period is a fact, with no estimate hedging', () {
    final label = labelFor(
      status(logged: true, phase: CyclePhase.menstrual, cycleDay: 3),
    );

    expect(label, contains('Period logged'));
    expect(label, contains('cycle day 3'));
    expect(label.toLowerCase(), isNot(contains('estimate')));
    expect(label.toLowerCase(), isNot(contains('confidence')));
  });

  test('a predicted period is named an estimate and carries confidence', () {
    final label = labelFor(
      status(predicted: true, phase: CyclePhase.menstrual),
    );

    expect(label, contains('Predicted period day, an estimate'));
    expect(label, contains('moderate confidence'));
  });

  test('an estimated phase is never announced as a fact', () {
    final label = labelFor(status(phase: CyclePhase.luteal));

    expect(label, contains('Estimated luteal phase'));
    expect(label, contains('moderate confidence'));
  });

  test('ovulation is an estimate too', () {
    final label = labelFor(
      status(ovulation: true, phase: CyclePhase.ovulatory),
    );

    expect(label, contains('Estimated ovulation day'));
  });

  test('an untracked day says so rather than guessing a phase', () {
    final label = labelFor(status());

    expect(label, contains('No cycle data'));
    expect(label, isNot(contains('Estimated')));
  });

  test(
    'low confidence explains itself rather than saying "Getting started"',
    () {
      final label = labelFor(
        status(phase: CyclePhase.follicular),
        confidence: CycleConfidence.low,
      );

      expect(label, contains('low confidence'));
      expect(label, contains('typical 28-day cycle'));
    },
  );

  test('carries no advice or medical claim', () {
    for (final phase in CyclePhase.values) {
      final label = labelFor(status(phase: phase)).toLowerCase();
      for (final word in const [
        'should',
        'recommend',
        'avoid',
        'fertile',
        'safe',
        'risk',
        'symptom',
      ]) {
        expect(
          label,
          isNot(contains(word)),
          reason: '"$word" would make a calendar day give advice',
        );
      }
    }
  });
}
