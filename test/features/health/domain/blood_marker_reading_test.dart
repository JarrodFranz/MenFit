import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/health/domain/blood_marker_reading.dart';

void main() {
  test('storage round trips every enum value', () {
    for (final marker in BloodMarker.values) {
      expect(BloodMarker.fromStorage(marker.toStorage()), marker);
    }
    for (final unit in BloodMarkerUnit.values) {
      expect(BloodMarkerUnit.fromStorage(unit.toStorage()), unit);
    }
    for (final context in GlucoseContext.values) {
      expect(GlucoseContext.fromStorage(context.toStorage()), context);
    }
  });

  test('storage strings match the contract', () {
    expect(BloodMarker.glucose.toStorage(), 'glucose');
    expect(BloodMarkerUnit.mmolPerL.toStorage(), 'mmol/L');
    expect(BloodMarkerUnit.mgPerDl.toStorage(), 'mg/dL');
    expect(BloodMarker.glucose.units, [
      BloodMarkerUnit.mmolPerL,
      BloodMarkerUnit.mgPerDl,
    ]);
  });

  test('parsers reject unknown values without echoing them', () {
    final parsers = <void Function()>[
      () => BloodMarker.fromStorage('sensitive-input'),
      () => BloodMarkerUnit.fromStorage('sensitive-input'),
      () => GlucoseContext.fromStorage('sensitive-input'),
    ];
    for (final parse in parsers) {
      expect(
        parse,
        throwsA(
          isA<FormatException>().having(
            (e) => e.toString(),
            'message',
            isNot(contains('sensitive-input')),
          ),
        ),
      );
    }
  });

  test('glucose conversion', () {
    const mmol = BloodMarkerUnit.mmolPerL;
    const mg = BloodMarkerUnit.mgPerDl;
    expect(glucoseIn(mmol, 5.4, mmol), 5.4);
    expect(glucoseIn(mg, 100, mg), 100);
    expect(glucoseIn(mg, 5, mmol), closeTo(90.08, 1e-9));
    expect(glucoseIn(mmol, 90.08, mg), closeTo(5, 1e-9));
    expect(glucoseIn(mmol, glucoseIn(mg, 6.7, mmol), mg), closeTo(6.7, 1e-9));
  });
}
