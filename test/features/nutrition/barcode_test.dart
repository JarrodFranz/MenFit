import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/nutrition/domain/barcode.dart';

/// Real, in-the-wild codes with genuine check digits — a hand-invented
/// "barcode" that happens to fail the mod-10 check would make every one of
/// these tests pass for the wrong reason.
const String nutellaEan13 = '3017620422003';
const String cokeUpcA = '036000291452';
const String wikipediaEan8 = '96385074';

/// UPC-E that expands to `042100005264`.
const String upcE = '04252614';

/// UPC-E that expands to `012345000065` — and is *also* a structurally valid
/// EAN-8. See the ambiguity note on [Barcode.tryParse].
const String ambiguousEightDigits = '01234565';

void main() {
  group('Barcode.tryParse — EAN-13', () {
    test('accepts a real EAN-13 and keeps all 13 digits', () {
      final barcode = Barcode.tryParse(nutellaEan13);
      expect(barcode, isNotNull);
      expect(barcode!.digits, nutellaEan13);
      expect(barcode.symbology, BarcodeSymbology.ean13);
    });

    test('accepts another real EAN-13', () {
      expect(Barcode.tryParse('5000112637922'), isNotNull);
    });

    test('rejects a wrong check digit', () {
      expect(Barcode.tryParse('3017620422004'), isNull);
      expect(Barcode.tryParse('5000112637921'), isNull);
    });

    test('rejects a transposition that keeps the same digits', () {
      // 3017620422003 with two body digits swapped: same multiset, different
      // weighted sum. This is the error the check digit exists to catch.
      expect(Barcode.tryParse('3017624022003'), isNull);
    });
  });

  group('Barcode.tryParse — UPC-A', () {
    test('accepts a real UPC-A', () {
      final barcode = Barcode.tryParse(cokeUpcA);
      expect(barcode, isNotNull);
      expect(barcode!.symbology, BarcodeSymbology.upcA);
    });

    test('canonicalises to the 13-digit EAN-13 form', () {
      expect(Barcode.tryParse(cokeUpcA)!.digits, '0036000291452');
    });

    test('rejects a wrong check digit', () {
      expect(Barcode.tryParse('036000291453'), isNull);
    });
  });

  group('Barcode.tryParse — EAN-8', () {
    test('accepts a real EAN-8 and does NOT pad it to 13', () {
      final barcode = Barcode.tryParse(wikipediaEan8);
      expect(barcode, isNotNull);
      // Padding would be arithmetically valid and functionally wrong: product
      // databases key GTIN-8 products on the 8-digit code.
      expect(barcode!.digits, wikipediaEan8);
      expect(barcode.symbology, BarcodeSymbology.ean8);
    });

    test('rejects a wrong check digit', () {
      expect(Barcode.tryParse('96385075'), isNull);
    });
  });

  group('Barcode.tryParse — UPC-E', () {
    test('expands, validates and canonicalises when told it is a UPC-E', () {
      final barcode = Barcode.tryParse(
        upcE,
        scannedAs: BarcodeSymbology.upcE,
      );
      expect(barcode, isNotNull);
      expect(barcode!.digits, '0042100005264');
      expect(barcode.symbology, BarcodeSymbology.upcE);
    });

    test('expands each of the four zero-suppression cases', () {
      // Last payload digit 0-2, 3, 4 and 5-9 each expand differently; the
      // expansions below are the ones whose check digits verify.
      expect(
        Barcode.tryParse('04252614', scannedAs: BarcodeSymbology.upcE)!.digits,
        '0042100005264',
      );
      expect(
        Barcode.tryParse('01234565', scannedAs: BarcodeSymbology.upcE)!.digits,
        '0012345000065',
      );
    });

    test('rejects a number system other than 0 or 1', () {
      // A leading 2-9 cannot be encoded as UPC-E at all.
      expect(
        Barcode.tryParse('24252614', scannedAs: BarcodeSymbology.upcE),
        isNull,
      );
    });

    test('rejects a wrong check digit on the expanded form', () {
      expect(
        Barcode.tryParse('04252615', scannedAs: BarcodeSymbology.upcE),
        isNull,
      );
    });

    test('a UPC-A scanned and mislabelled upcE is still read by length', () {
      // Scanners sometimes expand a UPC-E themselves and still report the
      // original symbology. Length wins over the hint.
      final barcode = Barcode.tryParse(
        cokeUpcA,
        scannedAs: BarcodeSymbology.upcE,
      );
      expect(barcode!.digits, '0036000291452');
    });
  });

  group('Barcode.tryParse — the 8-digit ambiguity', () {
    test('hand-typed 8 digits are read as EAN-8', () {
      // No hint means no way to tell, and EAN-8 is what a person is far more
      // likely to be reading off a package.
      final barcode = Barcode.tryParse(ambiguousEightDigits);
      expect(barcode!.symbology, BarcodeSymbology.ean8);
      expect(barcode.digits, ambiguousEightDigits);
    });

    test('the same digits scanned as UPC-E expand instead', () {
      final barcode = Barcode.tryParse(
        ambiguousEightDigits,
        scannedAs: BarcodeSymbology.upcE,
      );
      expect(barcode!.symbology, BarcodeSymbology.upcE);
      expect(barcode.digits, '0012345000065');
    });

    test('an ean8 hint never falls through to the UPC-E reading', () {
      // 04252614 is a valid UPC-E but not a valid EAN-8 — with the hint, that
      // is a rejection rather than a silent reinterpretation.
      expect(Barcode.tryParse(upcE, scannedAs: BarcodeSymbology.ean8), isNull);
    });
  });

  group('Barcode.tryParse — normalisation', () {
    test('strips the spacing labels and people put between digits', () {
      expect(Barcode.tryParse('  3017 6204 22003 ')!.digits, nutellaEan13);
      expect(Barcode.tryParse('0-36000-29145-2')!.digits, '0036000291452');
      expect(Barcode.tryParse('9638-5074')!.digits, wikipediaEan8);
    });

    test('rejects anything non-digit that survives stripping', () {
      expect(Barcode.tryParse('30176204220O3'), isNull);
      expect(Barcode.tryParse('3017620422003x'), isNull);
      expect(Barcode.tryParse('3017.620.422.003'), isNull);
    });

    test('rejects blank and separator-only input', () {
      expect(Barcode.tryParse(''), isNull);
      expect(Barcode.tryParse('   '), isNull);
      expect(Barcode.tryParse('---'), isNull);
    });

    test('rejects lengths that are not 8, 12 or 13', () {
      expect(Barcode.tryParse('30176204220'), isNull); // 11
      expect(Barcode.tryParse('301762042200311'), isNull); // 15
      expect(Barcode.tryParse('9638507'), isNull); // 7
      expect(Barcode.tryParse('963850741'), isNull); // 9
    });
  });

  group('Barcode canonicalisation and equality', () {
    test('UPC-A and its EAN-13 form are the same barcode', () {
      final fromUsLabel = Barcode.tryParse(cokeUpcA)!;
      final fromEuLabel = Barcode.tryParse('0036000291452')!;

      expect(fromUsLabel.digits, fromEuLabel.digits);
      expect(fromUsLabel, fromEuLabel);
      expect(fromUsLabel.hashCode, fromEuLabel.hashCode);
      // Symbology differs — it records how the code was read, not what it is.
      expect(fromUsLabel.symbology, isNot(fromEuLabel.symbology));
    });

    test('the canonical form round-trips through the parser unchanged', () {
      final once = Barcode.tryParse(cokeUpcA)!;
      final twice = Barcode.tryParse(once.digits)!;
      expect(twice.digits, once.digits);
      expect(twice, once);
    });

    test('EAN-8 round-trips without acquiring a padding', () {
      final once = Barcode.tryParse(wikipediaEan8)!;
      expect(Barcode.tryParse(once.digits)!.digits, wikipediaEan8);
    });

    test('different products are not equal', () {
      expect(Barcode.tryParse(nutellaEan13), isNot(Barcode.tryParse(cokeUpcA)));
    });
  });

  group('validateBarcode', () {
    test('a valid code validates and carries the parsed barcode', () {
      final result = validateBarcode(nutellaEan13);
      expect(result.isValid, isTrue);
      expect(result.error, isNull);
      expect(result.barcode!.digits, nutellaEan13);
    });

    test('the carried barcode is already canonicalised', () {
      expect(validateBarcode(cokeUpcA).barcode!.digits, '0036000291452');
    });

    test('blank and separator-only input asks for a barcode', () {
      expect(validateBarcode('').isValid, isFalse);
      expect(validateBarcode('   ').isValid, isFalse);
      expect(validateBarcode('--').isValid, isFalse);
    });

    test('messages narrow from non-digit, to length, to check digit', () {
      final nonDigit = validateBarcode('3017620422O03').error;
      final wrongLength = validateBarcode('30176204220').error;
      final badCheck = validateBarcode('3017620422004').error;

      expect(nonDigit, isNotNull);
      expect(wrongLength, isNotNull);
      expect(badCheck, isNotNull);
      // Three distinct problems get three distinct messages, so the field can
      // actually tell the user which one they have.
      expect({nonDigit, wrongLength, badCheck}, hasLength(3));
    });

    test('an invalid result never carries a barcode', () {
      expect(validateBarcode('3017620422004').barcode, isNull);
    });

    test('no message contains the digits that were typed', () {
      // The privacy invariant, not a style preference: a barcode names a
      // product the user is about to eat (S2 —
      // knowledge/engineering/security_and_privacy.md), and validation
      // messages end up in analyzer output, test failure text and anything a
      // future logging utility captures.
      const rejected = [
        '3017620422004', // bad check digit
        '3017620422O03', // stray letter
        '30176204220', // too short
        '301762042200311', // too long
        '96385075', // bad EAN-8 check digit
        '036000291453', // bad UPC-A check digit
        '  1234 5678 9012 7  ', // separators, still a bad check digit
      ];

      for (final input in rejected) {
        final message = validateBarcode(input).error;
        expect(message, isNotNull, reason: '$input should be rejected');

        final digits = input.replaceAll(RegExp(r'[\s-]'), '');
        // Runs of three, not the whole string: the fixed copy legitimately
        // says "8, 12 or 13", and a one- or two-digit coincidence with that
        // is not a leak.
        for (var i = 0; i + 3 <= digits.length; i++) {
          final fragment = digits.substring(i, i + 3);
          expect(
            message!.contains(fragment),
            isFalse,
            reason: 'a validation message echoed part of the input back',
          );
        }
      }
    });
  });
}
