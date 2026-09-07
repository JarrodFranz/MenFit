import 'package:menfit_app/core/errors/app_exception.dart';

/// Maps an error caught at a UI boundary to friendly, human copy.
///
/// [AppException.userMessageKey] is looked up in [_messagesByKey]; any
/// other error (including an [AppException] subtype added later without a
/// matching key here) falls back to [_genericMessage]. This is the single
/// place that turns a `userMessageKey` into English text - every screen
/// that surfaces an error to the user should route through this function
/// rather than interpolating `error.toString()` into the UI.
///
/// The keys themselves (`'error.storage'`, etc., defined alongside each
/// [AppException] subtype in `app_exception.dart`) are written to already
/// read as l10n message ids; when localisation is added, this mapping's
/// English strings become the `en` resource bundle and this function is
/// replaced by a lookup against `AppLocalizations`.
String userMessageFor(Object error) {
  if (error is AppException) {
    return _messagesByKey[error.userMessageKey] ?? _genericMessage;
  }
  return _genericMessage;
}

const String _genericMessage = 'Something went wrong. Please try again.';

const Map<String, String> _messagesByKey = {
  'error.storage': 'Something went wrong saving your data. Please try again.',
  'error.network':
      "We couldn't connect. Check your internet connection and try again.",
  'error.auth': 'You need to sign in again to continue.',
  'error.permission':
      "This needs a permission that isn't currently granted. You can "
      'enable it in your device settings.',
  'error.validation': 'Please check the highlighted fields and try again.',
  // The route-suggestion API key is a build-time setting, not something the
  // user can fix in-app - see `core/config/env.dart#orsApiKey`. Worded for a
  // person, not a developer: naming the vendor or the key would only tell
  // her about a thing she has no way to act on. Keep this in step with the
  // setup card in `features/routes/presentation/route_suggest_screen.dart`.
  'error.routes.apiKeyMissing':
      "Route suggestions aren't switched on yet. There's nothing you need "
      'to do - this is a one-off setup step for whoever set this app up '
      'for you.',
  // The scanner or the field read something that isn't a product code —
  // a partially-read label, or a QR/batch code that happens to be on the
  // packet. Never repeats the digits back: a barcode is S2 data
  // (`features/nutrition/domain/barcode.dart`'s copy rules).
  'error.nutrition.invalidBarcode':
      "That didn't come through as a product barcode. Try the scan again, "
      'or type the number under the stripes.',
  // A food database that cannot be searched by name; barcode lookup is a
  // separate capability and is unaffected. Says what still works rather
  // than leaving the whole feature looking broken, and names neither the
  // vendor nor the reason (see
  // `features/nutrition/domain/food_data_provider.dart#supportsTextSearch`).
  // Deliberately platform-neutral: this is no longer the web's message —
  // web searches foods like everywhere else.
  'error.nutrition.searchUnsupported':
      "Searching foods by name isn't available here. Barcodes still are — "
      'enter one and we can look the product up.',
  // 429/503: a genuinely retryable condition, and saying so is the honest
  // thing. No status code and no vendor name - neither helps a person
  // decide what to do next, which is "try again shortly".
  'error.nutrition.foodDatabaseBusy':
      'The food database is busy just now. Trying again in a minute usually '
      'works — your own foods are all still here in the meantime.',
  // A whole-app export that could not read the database. Distinct from
  // `error.storage` because that one says "saving your data", and this
  // failure saved nothing and changed nothing - being told a read failed as
  // though a write had gone wrong is the kind of small lie that makes a
  // person check whether their diary is still there. Static and
  // content-free: it is built while holding cycle and location rows
  // (security_and_privacy.md rule 3).
  'error.exportRead':
      'Something went wrong reading your data for the export. Nothing was '
      'changed. Please try again.',
  'error.importRead':
      'Could not read the backup file. It may be damaged or not a valid '
      'MenFit export.',
  'error.importWrite':
      'Something went wrong restoring your data from the backup. '
      'Please try again.',
  'error.sync':
      "We couldn't sync your data just now. It's safe on this device and "
      "we'll try again later.",
  'error.unknown': _genericMessage,
};
