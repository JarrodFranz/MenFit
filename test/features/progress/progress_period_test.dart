import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/progress/domain/progress_period.dart';

void main() {
  group('ProgressPeriod', () {
    final anchor = LocalDate(2026, 8, 28); // Friday
    final today = LocalDate(2026, 8, 28);

    test('rangeFor day returns the single day', () {
      final range = ProgressPeriod.day.rangeFor(anchor);
      expect(range.start, equals(anchor));
      expect(range.end, equals(anchor));
    });

    test('rangeFor week returns Monday to Sunday', () {
      final range = ProgressPeriod.week.rangeFor(anchor);
      expect(range.start, equals(LocalDate(2026, 8, 24))); // Monday
      expect(range.end, equals(LocalDate(2026, 8, 30))); // Sunday
    });

    test('rangeFor month returns first and last day of month', () {
      final range = ProgressPeriod.month.rangeFor(anchor);
      expect(range.start, equals(LocalDate(2026, 8, 1)));
      expect(range.end, equals(LocalDate(2026, 8, 31)));
    });

    test('previous steps back appropriately for each period', () {
      expect(
        ProgressPeriod.day.previous(anchor),
        equals(LocalDate(2026, 8, 27)),
      );
      expect(
        ProgressPeriod.week.previous(anchor),
        equals(LocalDate(2026, 8, 21)),
      );
      expect(
        ProgressPeriod.month.previous(anchor),
        equals(LocalDate(2026, 7, 28)),
      );
    });

    test('next steps forward and clamps to today', () {
      final pastDate = LocalDate(2026, 8, 20);
      expect(
        ProgressPeriod.day.next(pastDate, today),
        equals(LocalDate(2026, 8, 21)),
      );
      expect(
        ProgressPeriod.day.next(today, today),
        equals(today),
      );
    });

    test(
      'canGoForward reflects whether current range is before today range',
      () {
        expect(ProgressPeriod.day.canGoForward(anchor, today), isFalse);
        expect(
          ProgressPeriod.day.canGoForward(anchor.addDays(-1), today),
          isTrue,
        );

        expect(ProgressPeriod.week.canGoForward(anchor, today), isFalse);
        expect(
          ProgressPeriod.week.canGoForward(anchor.addDays(-7), today),
          isTrue,
        );
      },
    );

    test('formatRange formats Today, Yesterday, and date strings', () {
      expect(ProgressPeriod.day.formatRange(today, today), equals('Today'));
      expect(
        ProgressPeriod.day.formatRange(today.addDays(-1), today),
        equals('Yesterday'),
      );
      expect(
        ProgressPeriod.week.formatRange(today, today),
        equals('This Week'),
      );
      expect(
        ProgressPeriod.month.formatRange(today, today),
        equals('This Month'),
      );
    });
  });
}
