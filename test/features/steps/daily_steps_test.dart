import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/steps/domain/daily_steps.dart';

void main() {
  final day = LocalDate(2026, 9, 1);
  final syncedAt = DateTime.utc(2026, 9, 1, 18);

  DailySteps steps({
    LocalDate? on,
    int count = 8123,
    String? source = 'Health Connect',
    DateTime? at,
  }) {
    return DailySteps(
      day: on ?? day,
      steps: count,
      source: source,
      syncedAt: at ?? syncedAt,
    );
  }

  group('value equality', () {
    test('two identical values are equal and hash alike', () {
      expect(steps(), equals(steps()));
      expect(steps().hashCode, equals(steps().hashCode));
    });

    test('every field participates', () {
      expect(steps(), isNot(equals(steps(on: LocalDate(2026, 9, 2)))));
      expect(steps(), isNot(equals(steps(count: 8124))));
      expect(steps(), isNot(equals(steps(source: 'Apple Health'))));
      expect(steps(), isNot(equals(steps(source: null))));
      expect(
        steps(),
        isNot(equals(steps(at: DateTime.utc(2026, 9, 1, 19)))),
      );
    });
  });

  group('copyWith', () {
    test('replaces only what it is given', () {
      final updated = steps().copyWith(steps: 9000);
      expect(updated.steps, 9000);
      expect(updated.day, day);
      expect(updated.source, 'Health Connect');
      expect(updated.syncedAt, syncedAt);
    });

    test('an empty copyWith equals the original', () {
      expect(steps().copyWith(), equals(steps()));
    });
  });

  test('zero steps is a value, not an absence', () {
    // A day she did not carry her phone. The repository stores it; a day
    // never synced simply has no DailySteps at all.
    expect(steps(count: 0).steps, 0);
    expect(steps(count: 0), isNot(equals(steps())));
  });

  test('toString never carries the step count', () {
    // S2 (security_and_privacy.md): toString is what reaches a debugger, an
    // assertion message or a crash breadcrumb. A health value must not
    // travel that way.
    final text = steps().toString();
    expect(text, contains('2026-09-01'));
    expect(text, isNot(contains('8123')));
  });
}
