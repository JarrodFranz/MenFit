import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/data/fat_secret_json.dart';

void main() {
  group('fatSecretNumber', () {
    test('reads numbers and quoted numbers', () {
      expect(fatSecretNumber(150), 150.0);
      expect(fatSecretNumber(2.5), 2.5);
      expect(fatSecretNumber(' 2.50 '), 2.5);
      expect(fatSecretNumber('0'), 0.0);
    });

    test('absent, blank and unreadable values are null, never 0', () {
      expect(fatSecretNumber(null), isNull);
      expect(fatSecretNumber(''), isNull);
      expect(fatSecretNumber('   '), isNull);
      expect(fatSecretNumber('abc'), isNull);
      expect(fatSecretNumber(<String>[]), isNull);
    });

    test('non-finite values are null, quoted or not', () {
      for (final value in <Object>[
        'NaN',
        'Infinity',
        '-Infinity',
        ' NaN ',
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(fatSecretNumber(value), isNull, reason: '$value');
      }
    });
  });
}
