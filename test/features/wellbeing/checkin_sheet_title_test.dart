import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/wellbeing/presentation/checkin_sheet.dart';

/// The check-in sheet's heading names the day it is saving against.
///
/// It was hard-coded to "How are you feeling today?" while the only way in
/// was today's card. The wellbeing calendar opens the same sheet on any
/// past day, and asking how they feel *today* while writing a row dated
/// 12 August asks the wrong question of the wrong day.
void main() {
  test('today keeps the original present-tense question', () {
    expect(
      checkinSheetTitle(LocalDate.today()),
      'How are you feeling today?',
    );
  });

  test('an earlier day is asked about in the past tense, by name', () {
    expect(
      checkinSheetTitle(LocalDate(2026, 8, 12)),
      'How were you feeling on Wednesday 12 August?',
    );
  });

  test('yesterday is not "today"', () {
    final yesterday = LocalDate.today().addDays(-1);
    final title = checkinSheetTitle(yesterday);
    expect(title, isNot(contains('today')));
    expect(title, startsWith('How were you feeling on '));
  });

  test('the copy asks, it never assesses', () {
    for (final day in [LocalDate.today(), LocalDate(2026, 8, 12)]) {
      final title = checkinSheetTitle(day);
      expect(title, isNot(contains('should')));
      expect(title, isNot(contains('missed')));
    }
  });
}
