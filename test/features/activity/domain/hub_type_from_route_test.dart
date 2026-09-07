import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

/// `/activity/hub/:type` is the only place an [ActivityType] arrives as a
/// *route* string rather than a persisted one, and the two want opposite
/// fallbacks. A stored row with a value this build does not know is far
/// likelier to be a run than anything else, so [ActivityType.fromStorage]
/// keeps falling back to `run`. A hub opened with a value the router cannot
/// parse is a navigation bug, and MenFit is strength-first — landing the
/// user on Run would quietly contradict the whole product.
void main() {
  group('hubTypeFromRoute', () {
    test('parses every known type', () {
      for (final type in ActivityType.values) {
        expect(hubTypeFromRoute(type.toStorage()), type);
      }
    });

    test("'strength' is strength and 'run' is still run", () {
      expect(hubTypeFromRoute('strength'), ActivityType.strength);
      expect(hubTypeFromRoute('run'), ActivityType.run);
    });

    test('unknown and empty values fall back to strength, not run', () {
      expect(hubTypeFromRoute('garbage'), ActivityType.strength);
      expect(hubTypeFromRoute(''), ActivityType.strength);
      expect(hubTypeFromRoute('Run'), ActivityType.strength);
    });

    test('leaves the persisted-row fallback alone', () {
      expect(ActivityType.fromStorage('garbage'), ActivityType.run);
    });
  });
}
