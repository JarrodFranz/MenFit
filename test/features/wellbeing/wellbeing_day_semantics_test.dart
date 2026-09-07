import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/wellbeing/presentation/wellbeing_day_semantics.dart';

/// What a wellbeing calendar day says out loud. The glyphs carry the
/// meaning visually; this is the same information for someone who cannot
/// see them.
void main() {
  final date = LocalDate(2026, 9, 1); // A Tuesday.

  String? label({
    bool isToday = false,
    bool hasCheckin = false,
    bool hasFlare = false,
    bool isRecoveryDay = false,
  }) {
    return wellbeingDaySemanticLabel(
      date: date,
      isToday: isToday,
      hasCheckin: hasCheckin,
      hasFlare: hasFlare,
      isRecoveryDay: isRecoveryDay,
    );
  }

  test('a day with nothing on it is left announcing its bare number', () {
    expect(label(), isNull);
  });

  test('every logged thing is enumerated after the date', () {
    expect(
      label(hasCheckin: true, hasFlare: true, isRecoveryDay: true),
      'Tuesday 1 September, check-in logged, flare-up, recovery day.',
    );
  });

  test('only what is actually logged is named', () {
    expect(label(hasFlare: true), 'Tuesday 1 September, flare-up.');
    expect(label(isRecoveryDay: true), 'Tuesday 1 September, recovery day.');
  });

  test('today is announced as today, and says so even when bare', () {
    expect(label(isToday: true), 'Today, Tuesday 1 September, nothing logged.');
    expect(
      label(isToday: true, hasCheckin: true),
      'Today, Tuesday 1 September, check-in logged.',
    );
  });

  test('nothing is hedged as an estimate — every fact here was logged', () {
    final spoken = label(
      hasCheckin: true,
      hasFlare: true,
      isRecoveryDay: true,
    )!;
    expect(spoken, isNot(contains('estimate')));
    expect(spoken, isNot(contains('confidence')));
  });

  test('no copy implies a day was missed', () {
    for (final spoken in [
      label(isToday: true),
      label(hasCheckin: true),
      label(hasFlare: true),
    ]) {
      expect(spoken, isNot(contains('missed')));
      expect(spoken, isNot(contains('should')));
    }
  });
}
