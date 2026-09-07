import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/weight/domain/weight_validation.dart';

void main() {
  final today = LocalDate(2026, 9, 1);

  WeightLogValidation validate({
    LocalDate? day,
    double? weightKg = 62,
    String? rawWeightInput = '62',
    String? notes,
    UnitSystem unitSystem = UnitSystem.metric,
  }) {
    return validateWeightLog(
      today: today,
      day: day ?? today,
      weightKg: weightKg,
      rawWeightInput: rawWeightInput,
      notes: notes,
      unitSystem: unitSystem,
    );
  }

  group('day', () {
    test('accepts today', () {
      expect(validate().dayError, isNull);
    });

    test('accepts a back-dated reading', () {
      expect(validate(day: today.addDays(-400)).dayError, isNull);
    });

    test('rejects tomorrow', () {
      expect(validate(day: today.addDays(1)).dayError, isNotNull);
      expect(validate(day: today.addDays(1)).isValid, isFalse);
    });
  });

  group('weight', () {
    test('accepts both bounds inclusively', () {
      expect(validate(weightKg: minLoggableWeightKg).weightError, isNull);
      expect(validate(weightKg: maxLoggableWeightKg).weightError, isNull);
    });

    test('rejects just outside either bound', () {
      expect(
        validate(weightKg: minLoggableWeightKg - 0.1).weightError,
        isNotNull,
      );
      expect(
        validate(weightKg: maxLoggableWeightKg + 0.1).weightError,
        isNotNull,
      );
    });

    test('rejects the classic kg-typed-as-lb mistake', () {
      // 140 lb read as 140 kg is inside the range; 620 lb (a plausible
      // double-conversion) is not — the bound only has to catch the
      // impossible, not police the plausible.
      expect(validate(weightKg: 620).weightError, isNotNull);
    });

    test('tells a blank field apart from an unparseable one', () {
      final blank = validate(weightKg: null, rawWeightInput: '');
      final garbage = validate(weightKg: null, rawWeightInput: 'sixty');

      expect(blank.weightError, isNotNull);
      expect(garbage.weightError, isNotNull);
      expect(blank.weightError, isNot(garbage.weightError));
    });

    test('rejects NaN and infinity', () {
      expect(validate(weightKg: double.nan).weightError, isNotNull);
      expect(validate(weightKg: double.infinity).weightError, isNotNull);
    });

    test('states the bound in the units the user actually types', () {
      final metric = validate(weightKg: 500).weightError!;
      final imperial = validate(
        weightKg: 500,
        unitSystem: UnitSystem.imperial,
      ).weightError!;

      expect(metric, contains('kg'));
      expect(metric, isNot(contains('lb')));
      expect(imperial, contains('lb'));
      expect(imperial, isNot(contains('kg')));
    });

    test('never quotes the value that was rejected', () {
      // S2: an out-of-range message must not echo the reading back, since
      // these strings travel into snackbars and error text.
      expect(validate(weightKg: 987.6).weightError, isNot(contains('987')));
    });
  });

  group('notes', () {
    test('accepts no note', () {
      expect(validate().notesError, isNull);
    });

    test('accepts a note at the limit', () {
      expect(validate(notes: 'x' * maxWeightNoteLength).notesError, isNull);
    });

    test('rejects a note past the limit', () {
      expect(
        validate(notes: 'x' * (maxWeightNoteLength + 1)).notesError,
        isNotNull,
      );
    });

    test('measures the trimmed note, not the whitespace around it', () {
      expect(
        validate(notes: '  ${'x' * maxWeightNoteLength}  ').notesError,
        isNull,
      );
    });
  });

  test('isValid is true only when every field is', () {
    expect(validate().isValid, isTrue);
    expect(validate(day: today.addDays(1)).isValid, isFalse);
    expect(validate(weightKg: 0).isValid, isFalse);
    expect(validate(notes: 'x' * 500).isValid, isFalse);
  });
}
