/// MenFit v3: separates legacy FatSecret ids from barcodes without losing
/// ambiguous user data. Short ids move; valid long barcodes remain unchanged.
/// Valid non-zero-leading EAN-8 and invalid 12–14-digit values are copied to
/// provider_food_id while retaining barcode, because their origin is unknown.
/// Only FatSecret rows without an existing provider id change; replay is safe.
library;

import 'package:drift/drift.dart';

/// Applies the rule above to every FatSecret row in `foods`. Returns how many
/// rows were changed (moved or copied), for tests; nothing logs it.
///
/// Also safe to run after restoring a pre-v3 backup or import, which can
/// reintroduce rows shaped the old way.
Future<int> backfillFoodsProviderFoodId(DatabaseConnectionUser db) async {
  final rows = await db
      .customSelect(
        'SELECT id, barcode FROM foods '
        "WHERE source = 'fat_secret' AND barcode IS NOT NULL "
        'AND provider_food_id IS NULL',
      )
      .get();

  var changed = 0;
  for (final row in rows) {
    final id = row.read<String>('id');
    final value = row.read<String>('barcode').trim();
    switch (classifyLegacyFatSecretBarcode(value)) {
      case LegacyFatSecretBarcode.providerId:
        await db.customStatement(
          'UPDATE foods SET provider_food_id = ?, barcode = NULL WHERE id = ?',
          [value, id],
        );
        changed++;
      case LegacyFatSecretBarcode.ambiguous:
        await db.customStatement(
          'UPDATE foods SET provider_food_id = ? WHERE id = ?',
          [value, id],
        );
        changed++;
      case LegacyFatSecretBarcode.barcode:
        break;
    }
  }
  return changed;
}

/// What a value found in a pre-v3 FatSecret row's `barcode` column was.
enum LegacyFatSecretBarcode {
  /// Cannot be a scanned barcode: it is the FatSecret `food_id`.
  providerId,

  /// An 8-digit value that passes the EAN-8 check and does not start with
  /// `0` (a real EAN-8 or a `food_id`), or a 12-14 digit value whose check
  /// digit fails: nothing on the row says which, so it is copied and kept.
  ambiguous,

  /// A real product barcode.
  barcode,
}

/// Classifies [value] per the rule in this file's library doc.
LegacyFatSecretBarcode classifyLegacyFatSecretBarcode(String value) {
  final digits = value.trim();
  if (digits.isEmpty || !RegExp(r'^\d+$').hasMatch(digits)) {
    return LegacyFatSecretBarcode.providerId;
  }
  switch (digits.length) {
    case 12 || 13 || 14:
      return _checkDigitHolds(digits)
          ? LegacyFatSecretBarcode.barcode
          : LegacyFatSecretBarcode.ambiguous;
    case 8:
      if (digits.startsWith('0')) return LegacyFatSecretBarcode.barcode;
      return _checkDigitHolds(digits)
          ? LegacyFatSecretBarcode.ambiguous
          : LegacyFatSecretBarcode.providerId;
    default:
      return LegacyFatSecretBarcode.providerId;
  }
}

/// The GS1 mod-10 check digit, the same arithmetic as
/// `features/nutrition/domain/barcode.dart` (duplicated deliberately:
/// `core/` must not import a feature).
bool _checkDigitHolds(String digits) {
  final lastIndex = digits.length - 1;
  var sum = 0;
  for (var i = 0; i < lastIndex; i++) {
    final weight = (lastIndex - 1 - i).isEven ? 3 : 1;
    sum += (digits.codeUnitAt(i) - 0x30) * weight;
  }
  final expected = (10 - sum % 10) % 10;
  return expected == digits.codeUnitAt(lastIndex) - 0x30;
}
