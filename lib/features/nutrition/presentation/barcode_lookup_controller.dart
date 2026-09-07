import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/features/nutrition/data/online_lookup_notice_store.dart';
import 'package:menfit_app/features/nutrition/domain/barcode.dart';
import 'package:menfit_app/features/nutrition/domain/food.dart';
import 'package:menfit_app/features/nutrition/domain/provider_food.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'barcode_lookup_controller.freezed.dart';
part 'barcode_lookup_controller.g.dart';

/// Where a barcode lookup landed. Three genuinely different destinations,
/// so a sealed type rather than a nullable pair
/// (`knowledge/engineering/error_handling.md`: expected outcomes are values,
/// not exceptions).
sealed class BarcodeLookupResult {
  const BarcodeLookupResult();
}

/// The catalogue already had this product. **Nothing was sent anywhere** —
/// see [BarcodeLookupController.lookUp].
final class LocalFoodMatched extends BarcodeLookupResult {
  const LocalFoodMatched(this.food);

  final Food food;
}

/// The food database had a record; it goes to the review screen for the
/// user to check before it becomes a `Food`.
final class ProviderFoodFetched extends BarcodeLookupResult {
  const ProviderFoodFetched(this.food);

  final ProviderFood food;
}

/// Nobody has this barcode yet. Not an error: the review screen opens with
/// the code filled in and the user adds the rest from the packet.
final class ProviderHasNoProduct extends BarcodeLookupResult {
  const ProviderHasNoProduct(this.barcode);

  /// The canonical digits (`domain/barcode.dart`), which is all we know.
  final String barcode;
}

/// UI state of a lookup in flight.
@freezed
abstract class BarcodeLookupState with _$BarcodeLookupState {
  const factory BarcodeLookupState({
    @Default(false) bool isLookingUp,

    /// Ready-to-show copy from `core/errors/error_messages.dart`, or `null`.
    /// Never contains the barcode — S2 (`domain/barcode.dart`'s copy rules).
    String? errorMessage,
  }) = _BarcodeLookupState;
}

/// Turns a scanned or typed barcode into somewhere to go.
///
/// ## The order is the feature
///
/// 1. **Validate** (`validateBarcode`), which also canonicalises: a UPC-A
///    and its EAN-13 spelling are one product and must not miss each other
///    at step 2.
/// 2. **Look in the catalogue first.** A product the user has already saved
///    resolves here and **no request is made at all**. That is the offline
///    story — barcodes get scanned in supermarket aisles, where signal is
///    worst — and a privacy property: the app does not tell a third party
///    about a food it already knows
///    (`domain/nutrition_repository.dart#getFoodByBarcode`).
/// 3. **Ask permission before the first request ever leaves**, and abandon
///    the lookup if the answer is no
///    (`data/online_lookup_notice_store.dart`).
/// 4. **Then** the food database.
///
/// ## Two spellings of one code
///
/// Step 2 searches the catalogue for **our** canonical digits; a row saved
/// from a provider result is keyed on the **provider's** echoed code. Those
/// agree with Open Food Facts — measured, and tabulated in
/// `domain/barcode.dart` — but the invariant that a scanned product never
/// yields a second row must not rest on a third party's normalisation
/// staying in step with ours. So [lookUp] re-checks the catalogue on the
/// echoed code whenever it differs. [fetchFullRecord] needs no such step: it
/// queries with the provider's own code to begin with.
///
/// ## Two different kinds of "no"
///
/// A code the provider rejects as not a product code is not the same as a
/// product it has never heard of. The first is an error worth saying
/// something about (`error.nutrition.invalidBarcode`); the second is
/// [ProviderHasNoProduct], which opens the form. Wave B made them distinct
/// deliberately (`domain/food_data_provider.dart#findByBarcode`).
@riverpod
class BarcodeLookupController extends _$BarcodeLookupController {
  @override
  BarcodeLookupState build() => const BarcodeLookupState();

  /// Runs the four steps above for [rawCode].
  ///
  /// Returns `null` when there is nowhere to go: an unreadable code, a
  /// declined notice, or a failed request. The reason, where there is one
  /// worth showing, lands in [BarcodeLookupState.errorMessage].
  ///
  /// [confirmOnlineLookup] shows the first-run notice and answers whether
  /// to go ahead. It is only ever called before the *first* request this
  /// app makes, and a `false` from it aborts before anything is sent.
  ///
  /// A lookup already in flight wins: a second call returns `null`
  /// immediately rather than putting a second request on a documented
  /// 15/minute budget and a second screen on the stack. Same guard
  /// `OnlineFoodSearchController.search` already carries. The UI stops the
  /// result tiles being tappable while [state] says so as well; this is the
  /// half that still holds when a caller forgets.
  Future<BarcodeLookupResult?> lookUp(
    String rawCode, {
    required Future<bool> Function() confirmOnlineLookup,
  }) async {
    if (state.isLookingUp) return null;

    final validation = validateBarcode(rawCode);
    final barcode = validation.barcode;
    if (barcode == null) {
      _set(BarcodeLookupState(errorMessage: validation.error));
      return null;
    }

    _set(const BarcodeLookupState(isLookingUp: true));
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      final saved = await repository.getFoodByBarcode(barcode.digits);
      if (saved != null) {
        _set(const BarcodeLookupState());
        return LocalFoodMatched(saved);
      }

      // Goes idle while the notice is up, and only then — see [_consented].
      if (!await _consented(confirmOnlineLookup)) return null;

      // The scope's region is ignored by `findByBarcode` — a barcode is
      // global — but its language decides which `product_name_<lc>` the
      // record comes back with.
      final found = await ref
          .read(foodDataProviderProvider)
          .findByBarcode(
            barcode.digits,
            scope: ref.read(foodSearchScopeProvider),
          );
      if (found == null) {
        _set(const BarcodeLookupState());
        return ProviderHasNoProduct(barcode.digits);
      }

      // Step 2 asked the catalogue for **our** canonical spelling; a row
      // saved from a provider result is keyed on the **provider's** echoed
      // one (`domain/provider_food.dart`). Those two agree with Open Food
      // Facts today — measured, `domain/barcode.dart` — so this branch does
      // not fire against it, and it is not covering a live bug. It is here
      // because the no-duplicate-rows invariant must hold by construction
      // rather than by a third party's normalisation rules continuing to
      // match ours: if they ever diverge, or a second provider arrives
      // behind the same port, the local-first check above could never hit
      // the row it created and every scan would fetch and save another one.
      if (found.barcode != barcode.digits) {
        final echoed = await repository.getFoodByBarcode(found.barcode);
        if (echoed != null) {
          _set(const BarcodeLookupState());
          return LocalFoodMatched(echoed);
        }
      }

      _set(const BarcodeLookupState());
      return ProviderFoodFetched(found);
    } on Object catch (error) {
      // Copy only, never the code itself: `userMessageFor` resolves a
      // static key, and the barcode stays out of every message
      // (`domain/barcode.dart`).
      _set(BarcodeLookupState(errorMessage: userMessageFor(error)));
      return null;
    }
  }

  /// Fetches the **full** record behind a text-search hit.
  ///
  /// Mandatory rather than an optimisation. Search hits carry no iron at
  /// all — the provider's search index exposes seven nutriments and iron is
  /// not among them (`domain/provider_food.dart`) — so a `Food` built from
  /// a summary would silently be missing the one nutrient this app treats
  /// as first-class. Nothing may build a food from a summary alone.
  ///
  /// Returns `null` when the fetch failed or the notice was declined;
  /// [ProviderHasNoProduct] when the record vanished between the search and
  /// this call, which sends the user to the same add-it-yourself form.
  ///
  /// Consults the catalogue first, exactly as [lookUp] does. That is not
  /// only the round trip saved and the request not made: without it, picking
  /// a search hit for a product the user *already has* would walk her
  /// through the review screen again and save a **second** catalogue row for
  /// the same food — a duplicate the barcode path is already careful not to
  /// create. Reaching a food by searching for it rather than by scanning it
  /// must not change what ends up stored.
  ///
  /// Re-entrant calls are refused while one is in flight — see [lookUp].
  /// Result tiles are what this guards: tapping two of them in quick
  /// succession must not send two requests and stack two review screens.
  ///
  /// Unlike [lookUp] there is no echoed-code re-check here, and none is
  /// needed: this queries with the provider's own code, which is the string
  /// a saved row is keyed on.
  ///
  /// [source] is the summary's own [ProviderFoodSummary.source] — required,
  /// not inferred — so the fetch is resolved to the specific provider that
  /// produced the hit (`FoodDataProvider.providerFor`) rather than to
  /// whichever one the composite happens to be pointed at. A FatSecret hit's
  /// [barcode] is a FatSecret `food_id`, not a GTIN; asking the composite
  /// would pad it into a barcode shape, miss on FatSecret, and fall back to
  /// Open Food Facts under a code that means nothing there.
  Future<BarcodeLookupResult?> fetchFullRecord(
    String barcode, {
    required FoodSource source,
    required Future<bool> Function() confirmOnlineLookup,
  }) async {
    if (state.isLookingUp) return null;

    try {
      _set(const BarcodeLookupState(isLookingUp: true));
      final saved = await ref
          .read(nutritionRepositoryProvider)
          .getFoodByBarcode(barcode);
      if (saved != null) {
        _set(const BarcodeLookupState());
        return LocalFoodMatched(saved);
      }

      // Consent first, going idle only while a notice is actually being
      // shown — see [_consented].
      if (!await _consented(confirmOnlineLookup)) return null;

      final found = await ref
          .read(foodDataProviderProvider)
          .providerFor(source)
          .findByBarcode(barcode, scope: ref.read(foodSearchScopeProvider));
      _set(const BarcodeLookupState());
      return found == null
          ? ProviderHasNoProduct(barcode)
          : ProviderFoodFetched(found);
    } on Object catch (error) {
      _set(BarcodeLookupState(errorMessage: userMessageFor(error)));
      return null;
    }
  }

  /// Clears a message the user has now seen.
  void clearError() => _set(const BarcodeLookupState());

  /// Writes [next] unless this controller has already been disposed.
  ///
  /// A lookup outlives the screen whenever the user backs out mid-request,
  /// and assigning `state` after disposal throws — which would then be
  /// caught by the `catch` below and rethrown from the assignment inside
  /// it. Guarding here keeps an abandoned lookup silent, which is what
  /// abandoning it meant.
  void _set(BarcodeLookupState next) {
    if (ref.mounted) state = next;
  }

  /// Runs the consent gate, dropping [state] to idle **only when a notice is
  /// actually going to be shown**, and restoring the busy flag afterwards.
  ///
  /// The idle step is there so a progress bar is not spinning behind a
  /// question the user has not answered yet — which only matters while the
  /// dialog is genuinely up. Once the notice has been acknowledged nothing is
  /// displayed and [grantOnlineLookupConsent] resolves in a microtask, so the
  /// early return here is a tidy-up rather than a fix: it skips two state
  /// writes (and the rebuilds they cause) on every lookup after the first.
  ///
  /// To be clear for anyone tempted to treat this as load-bearing — lowering
  /// the flag on that path was **not** a bug that let a second lookup start.
  /// Microtasks always drain before a frame is painted, so an idle state set
  /// and cleared without an intervening real await can never reach the
  /// screen, and the tiles never become tappable again. `hasSeenNotice` being
  /// synchronous is simply what lets the decision be made without an await.
  Future<bool> _consented(Future<bool> Function() confirm) async {
    final store = ref.read(onlineLookupNoticeStoreProvider);
    if (store.hasSeenNotice()) return true;

    _set(const BarcodeLookupState());
    final granted = await grantOnlineLookupConsent(store, confirm);
    // Busy again if we are about to make the request; idle if she backed out.
    _set(BarcodeLookupState(isLookingUp: granted));
    return granted;
  }
}
