import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/weekday.dart';

void main() {
  group('Weekday', () {
    test('fromStorage parses every known value', () {
      expect(Weekday.fromStorage('mon'), Weekday.mon);
      expect(Weekday.fromStorage('tue'), Weekday.tue);
      expect(Weekday.fromStorage('wed'), Weekday.wed);
      expect(Weekday.fromStorage('thu'), Weekday.thu);
      expect(Weekday.fromStorage('fri'), Weekday.fri);
      expect(Weekday.fromStorage('sat'), Weekday.sat);
      expect(Weekday.fromStorage('sun'), Weekday.sun);
    });

    test('fromStorage returns null for an unrecognised value', () {
      expect(Weekday.fromStorage('bogus'), isNull);
      expect(Weekday.fromStorage(''), isNull);
    });

    test('toStorage round-trips through fromStorage', () {
      for (final day in Weekday.values) {
        expect(Weekday.fromStorage(day.toStorage()), day);
      }
    });

    test('label is a short, distinct string per day', () {
      final labels = Weekday.values.map((d) => d.label).toSet();
      expect(labels, hasLength(Weekday.values.length));
    });
  });
}
