// Copy rules for every message in this file
// (`knowledge/engineering/security_and_privacy.md`, restated as a constraint
// on the code):
//
// 1. No message may contain the barcode, or any part of it. A barcode names
//    a product the user is about to eat — S2-tier data, same tier as the
//    diary entry it becomes — and validation messages end up in analyzer
//    output, in test failure text, and in whatever a future logging utility
//    decides to capture. Nothing here interpolates the input.
// 2. Messages are plain and non-blaming. A mistyped digit is a mistyped
//    digit, not a user error worth a scolding — same voice as
//    `nutrition_validation.dart`.
// 3. Nothing here mentions scanning hardware or platforms. Whether a camera
//    is available is `core/platform/barcode_scanning.dart`'s business.

// `freezed_annotation` is imported for `@immutable` alone (it re-exports
// `package:meta`), not for codegen — [Barcode] has a private constructor and a
// validated single field, which freezed cannot express. Pure Dart either way,
// so the no-Flutter-in-domain rule holds.
import 'package:freezed_annotation/freezed_annotation.dart';

/// The product-barcode symbologies this app reads.
///
/// Named [BarcodeSymbology] rather than `BarcodeFormat` on purpose:
/// `package:mobile_scanner` exports a `BarcodeFormat` enum *and* a `Barcode`
/// class, and `presentation/barcode_scan_screen.dart` has to hold both
/// vocabularies at once. Distinct names there beat an import prefix on the
/// domain type everywhere else.
///
/// Deliberately only the four retail-product symbologies. QR, Code 128,
/// Data Matrix and friends appear on food packaging too (batch codes,
/// marketing links), and none of them identifies a product to a nutrition
/// database — accepting one would look like it worked and then fail every
/// lookup.
enum BarcodeSymbology {
  /// 8 digits. The short form used on small European packages.
  ean8,

  /// 13 digits. The canonical storage form — see [Barcode.digits].
  ean13,

  /// 12 digits as printed; stored zero-padded to its 13-digit EAN-13 form.
  upcA,

  /// 8 digits as printed; a zero-suppressed UPC-A, stored expanded — see
  /// [Barcode.tryParse].
  upcE,
}

/// A product barcode that has passed check-digit validation, held in a
/// single canonical form.
///
/// ## The canonical form is 13-digit EAN-13, except for EAN-8
///
/// A 12-digit UPC-A and a 13-digit EAN-13 beginning with `0` are the *same
/// GTIN* — the US label simply omits the leading zero that the European
/// label prints. Storing them as typed would give the same tin of tomatoes
/// two catalogue rows and two lookups, depending on which side of the
/// Atlantic the label was printed on. So [digits] left-pads every UPC-A (and
/// every expanded UPC-E) to 13 and that string is the only thing that is
/// ever stored, cached against, or compared.
///
/// **EAN-8 stays 8 digits.** Zero-padding a GTIN-8 to 13 is arithmetically
/// harmless (the mod-10 weights are counted from the right, so leading zeros
/// contribute nothing and the check digit still verifies), but it is not what
/// product databases do: Open Food Facts — the lookup source this feature is
/// built on (ADR 010) — keys GTIN-8 products on the 8-digit code. Padding
/// here would guarantee a miss on every one of them.
///
/// ### Measured against Open Food Facts, 2026-08-27
///
/// The paragraph above began as an inference and is now a measurement.
/// Live requests, comparing the code asked for against the `code` the
/// product API echoes back:
///
/// | Requested | Echoed `code` |
/// |---|---|
/// | `016000275270` (UPC-A, 12) | `0016000275270` — padded up to GTIN-13 |
/// | `0016000275270` | `0016000275270` |
/// | `16000275270` (11) | `0016000275270` |
/// | `20000691` (a real GTIN-8 product) | `20000691` — left at 8 |
/// | `03017620422003` (14) | `3017620422003` — leading zero stripped |
///
/// So Open Food Facts' canonical form is the same as the one above: pad
/// UPC-A to 13, leave GTIN-8 at 8. Our [digits] and their `code` agree on
/// every case tested, which is why the local-first catalogue check can look
/// up [digits] and find a row keyed on their echoed code.
///
/// **That agreement is a fact about today, not a guarantee.** It is a third
/// party's normalisation rule, it is not versioned, and a second provider
/// behind the same port would bring its own. So
/// `presentation/barcode_lookup_controller.dart#lookUp` re-checks the
/// catalogue on the echoed code when it differs from [digits], rather than
/// resting the no-duplicate-rows invariant on this table staying true.
///
/// ## Equality is on [digits] alone
///
/// [symbology] records *how the code was read*, which is useful for a
/// debugging breadcrumb and useless for identity: a UPC-A scanned in a US
/// supermarket and the same GTIN typed off a European label must be equal, or
/// the canonicalisation above buys nothing. Two [Barcode]s with the same
/// [digits] are the same product, whatever symbology carried them.
///
/// ## No `toString` override
///
/// Deliberate. The default `Instance of 'Barcode'` is the whole point — an
/// override interpolating [digits] would leak S2 data into every string
/// interpolation, assertion message and future log line that ever touches
/// one of these.
@immutable
final class Barcode {
  const Barcode._({required this.digits, required this.symbology});

  /// Parses [input] into a [Barcode], or returns `null` when it is not a
  /// valid product barcode.
  ///
  /// Normalisation first: whitespace and hyphens are stripped (labels and
  /// people group digits — `5 000112 637922`, `0-36000-29145-2`), and
  /// anything left that is not an ASCII digit rejects the whole input.
  ///
  /// [scannedAs] is the symbology a scanner reported, and matters for exactly
  /// one case: **8 digits are ambiguous**. An 8-digit string can be a GTIN-8
  /// or a zero-suppressed UPC-E, and the two are not merely hard to tell
  /// apart — for a UPC-E in number system `0` whose sixth digit is 5–9, the
  /// UPC-E and GTIN-8 check digits are *provably always identical* (both
  /// weightings reduce to the same sum), so no amount of arithmetic can
  /// separate them. With no [scannedAs] hint — i.e. hand-typed — an 8-digit
  /// code is therefore read as EAN-8, which is the far more common thing to
  /// find printed on a package a person is squinting at. A lookup layer that
  /// misses on an 8-digit code may reasonably retry it as
  /// `scannedAs: BarcodeSymbology.upcE` before giving up.
  ///
  /// A [scannedAs] that disagrees with the length is ignored; length wins,
  /// because scanners do occasionally report a UPC-A as `upcE` after
  /// expanding it themselves.
  static Barcode? tryParse(String input, {BarcodeSymbology? scannedAs}) {
    final digits = input.replaceAll(_separators, '');
    if (digits.isEmpty || !_digitsOnly.hasMatch(digits)) return null;

    return switch (digits.length) {
      13 =>
        _checkDigitHolds(digits)
            ? Barcode._(digits: digits, symbology: BarcodeSymbology.ean13)
            : null,
      12 =>
        _checkDigitHolds(digits)
            ? Barcode._(digits: '0$digits', symbology: BarcodeSymbology.upcA)
            : null,
      8 => switch (scannedAs) {
        BarcodeSymbology.upcE => _fromUpcE(digits),
        BarcodeSymbology.ean8 => _fromEan8(digits),
        _ => _fromEan8(digits) ?? _fromUpcE(digits),
      },
      _ => null,
    };
  }

  /// The canonical digits — 13 for EAN-13/UPC-A/UPC-E, 8 for EAN-8. This is
  /// the only form that gets stored or looked up; see the class doc.
  final String digits;

  /// How this code was read. Descriptive, not part of identity.
  final BarcodeSymbology symbology;

  @override
  bool operator ==(Object other) => other is Barcode && other.digits == digits;

  @override
  int get hashCode => digits.hashCode;
}

/// Result of validating a barcode typed into the manual-entry field.
///
/// A typed result value, not a thrown exception — the same convention as
/// `domain/nutrition_validation.dart`'s `FoodValidation`, for the same
/// reason: a half-typed barcode is an ordinary state of a text field being
/// filled in, not an exceptional one.
///
/// [barcode] carries the parsed value on success so the caller does not
/// parse the same string twice (and cannot accidentally parse it *differently*
/// the second time).
class BarcodeValidation {
  const BarcodeValidation({this.barcode, this.error});

  final Barcode? barcode;
  final String? error;

  bool get isValid => error == null;
}

const String _blankMessage = 'Type the barcode from the packet, or scan it.';
const String _nonDigitMessage =
    'Barcodes are digits only — is there a stray character in there?';
const String _wrongLengthMessage =
    'Product barcodes have 8, 12 or 13 digits — worth counting them again?';
const String _checkDigitMessage =
    "That doesn't look like a product barcode — check the digits?";

/// Validates a hand-typed barcode for the manual-entry field.
///
/// Manual entry is a first-class path, not a fallback: it is the *only* path
/// on Windows and Web (`core/platform/barcode_scanning.dart`), and it is what
/// is left everywhere else when camera permission is refused or the label is
/// scuffed, wrapped round a curve, or under cling film.
///
/// The messages narrow as the input gets closer to being a barcode — blank,
/// then non-digits, then length, then the check digit — so the field says the
/// most specific true thing it can at each keystroke. None of them repeats
/// the digits back; see this file's copy rules.
BarcodeValidation validateBarcode(String input) {
  final digits = input.replaceAll(_separators, '');
  if (digits.isEmpty) return const BarcodeValidation(error: _blankMessage);
  if (!_digitsOnly.hasMatch(digits)) {
    return const BarcodeValidation(error: _nonDigitMessage);
  }
  if (digits.length != 8 && digits.length != 12 && digits.length != 13) {
    return const BarcodeValidation(error: _wrongLengthMessage);
  }

  final barcode = Barcode.tryParse(digits);
  if (barcode == null) {
    return const BarcodeValidation(error: _checkDigitMessage);
  }
  return BarcodeValidation(barcode: barcode);
}

/// Whitespace and hyphens, the two things labels and people use to group
/// digits into readable blocks.
final RegExp _separators = RegExp(r'[\s-]');

/// ASCII digits only. Non-ASCII digit forms are rejected rather than
/// transliterated: a barcode is a machine identifier, and quietly rewriting
/// what someone typed is a worse failure than saying it looks wrong.
final RegExp _digitsOnly = RegExp(r'^\d+$');

Barcode? _fromEan8(String digits) => _checkDigitHolds(digits)
    ? Barcode._(digits: digits, symbology: BarcodeSymbology.ean8)
    : null;

/// Expands a UPC-E to its UPC-A form, then validates and canonicalises that.
///
/// UPC-E is UPC-A with a run of zeros squeezed out; the sixth digit of the
/// payload says where they came from and how many. The check digit printed on
/// a UPC-E belongs to the *expanded* UPC-A, so there is nothing to validate
/// until the expansion has happened — which is why this is a real expansion
/// rather than the "accept 8 digits unchecked" shortcut.
Barcode? _fromUpcE(String digits) {
  final numberSystem = digits[0];
  // Only number systems 0 and 1 are encodable as UPC-E. A leading 2-9 means
  // this is an EAN-8 (or a typo), not a zero-suppressed UPC-A.
  if (numberSystem != '0' && numberSystem != '1') return null;

  const fourZeros = '0000';
  const fiveZeros = '00000';
  final payload = digits.substring(1, 7);
  final check = digits[7];
  final last = payload[5];
  final body = switch (last) {
    '0' || '1' || '2' =>
      '${payload.substring(0, 2)}$last$fourZeros${payload.substring(2, 5)}',
    '3' => '${payload.substring(0, 3)}$fiveZeros${payload.substring(3, 5)}',
    '4' => '${payload.substring(0, 4)}$fiveZeros${payload[4]}',
    _ => '${payload.substring(0, 5)}$fourZeros$last',
  };

  final upcA = '$numberSystem$body$check';
  if (!_checkDigitHolds(upcA)) return null;
  return Barcode._(digits: '0$upcA', symbology: BarcodeSymbology.upcE);
}

/// The GS1 mod-10 check: weight each digit left of the check digit 3, 1, 3,
/// 1… counting *from the right*, and the total plus the check digit must be a
/// multiple of ten.
///
/// Counting from the right rather than the left is what makes this work
/// unchanged for GTIN-8, GTIN-12 and GTIN-13, and what makes zero-padding a
/// shorter GTIN to a longer one check-digit-preserving.
bool _checkDigitHolds(String digits) {
  final lastIndex = digits.length - 1;
  var sum = 0;
  for (var i = 0; i < lastIndex; i++) {
    final weight = (lastIndex - 1 - i).isEven ? 3 : 1;
    sum += (digits.codeUnitAt(i) - _zero) * weight;
  }
  final expected = (10 - sum % 10) % 10;
  return expected == digits.codeUnitAt(lastIndex) - _zero;
}

const int _zero = 0x30;
