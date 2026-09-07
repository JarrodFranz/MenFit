import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/units.dart';
import 'package:menfit_app/features/activity/domain/pace_format.dart';

void main() {
  group('formatPace', () {
    test('formats a metric pace as m:ss /km', () {
      // 5:30 min/km = 330 seconds/km.
      expect(formatPace(330, UnitSystem.metric), '5:30 /km');
    });

    test('pads seconds under 10 with a leading zero', () {
      expect(formatPace(304, UnitSystem.metric), '5:04 /km');
    });

    test('rounds to the nearest second', () {
      // 330.6 rounds up to 331 seconds = 5:31.
      expect(formatPace(330.6, UnitSystem.metric), '5:31 /km');
    });

    test('converts to imperial (seconds/mile), not just relabels', () {
      // 300 s/km (5:00/km) -> 300 * 1.609344 = 482.8032 s/mi -> rounds to
      // 483s -> 8:03/mi. A naive relabel (still "5:00 /mi") would be wrong
      // since a mile is longer than a km, so pace-per-mile is slower.
      expect(formatPace(300, UnitSystem.imperial), '8:03 /mi');
    });

    test('null renders as a dashed placeholder, not 0:00', () {
      expect(formatPace(null, UnitSystem.metric), '--:-- /km');
      expect(formatPace(null, UnitSystem.imperial), '--:-- /mi');
    });

    test('zero renders as a dashed placeholder', () {
      expect(formatPace(0, UnitSystem.metric), '--:-- /km');
    });

    test('negative input renders as a dashed placeholder', () {
      expect(formatPace(-100, UnitSystem.metric), '--:-- /km');
    });

    test('non-finite input renders as a dashed placeholder', () {
      expect(formatPace(double.nan, UnitSystem.metric), '--:-- /km');
      expect(formatPace(double.infinity, UnitSystem.metric), '--:-- /km');
    });
  });

  group('formatDistance', () {
    test('formats metric distance to two decimal places', () {
      expect(formatDistance(5034, UnitSystem.metric), '5.03 km');
    });

    test('converts metres to miles for imperial', () {
      // 5034 m = 5.034 km -> 5.034 / 1.609344 = 3.1284... mi.
      expect(formatDistance(5034, UnitSystem.imperial), '3.13 mi');
    });

    test('zero distance formats as 0.00, not an error', () {
      expect(formatDistance(0, UnitSystem.metric), '0.00 km');
    });

    test('negative distance is treated as zero', () {
      expect(formatDistance(-500, UnitSystem.metric), '0.00 km');
    });

    test('non-finite distance is treated as zero', () {
      expect(formatDistance(double.nan, UnitSystem.metric), '0.00 km');
    });
  });

  group('formatDuration', () {
    test('formats minutes and seconds under an hour', () {
      expect(formatDuration(const Duration(minutes: 47, seconds: 12)), '47:12');
    });

    test('zero-pads minutes under 10', () {
      expect(formatDuration(const Duration(minutes: 5, seconds: 3)), '05:03');
    });

    test('zero duration formats as 00:00', () {
      expect(formatDuration(Duration.zero), '00:00');
    });

    test('rolls over into hours at exactly one hour', () {
      expect(formatDuration(const Duration(hours: 1)), '1:00:00');
    });

    test(
      'formats hours with zero-padded minutes/seconds, unpadded hours',
      () {
        expect(
          formatDuration(
            const Duration(hours: 1, minutes: 2, seconds: 45),
          ),
          '1:02:45',
        );
      },
    );

    test('formats multi-digit hours', () {
      expect(
        formatDuration(const Duration(hours: 12, minutes: 30, seconds: 9)),
        '12:30:09',
      );
    });

    test('negative duration is treated as its absolute value', () {
      expect(
        formatDuration(const Duration(minutes: -5, seconds: -3)),
        '05:03',
      );
    });
  });
}
