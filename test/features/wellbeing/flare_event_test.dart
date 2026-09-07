import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/symptom_type.dart';

void main() {
  test("FlareCategory values are the men's-app set", () {
    expect(FlareCategory.values, [
      FlareCategory.injury,
      FlareCategory.illness,
      FlareCategory.migraine,
      FlareCategory.backPain,
      FlareCategory.other,
    ]);
  });

  test('FlareCategory storage round-trips and unknown falls back to other', () {
    for (final c in FlareCategory.values) {
      expect(FlareCategory.fromStorage(c.toStorage()), c);
    }
    expect(FlareCategory.fromStorage('periodSymptoms'), FlareCategory.other);
    expect(FlareCategory.fromStorage(null), isNull);
  });

  test('SymptomType has no pelvicPain and cramping reads as muscle cramps', () {
    expect(
      SymptomType.values.map((s) => s.name),
      isNot(contains('pelvicPain')),
    );
    expect(SymptomType.cramping.label, 'Muscle cramps');
    expect(SymptomType.fromStorage('pelvicPain'), SymptomType.other);
  });
}
