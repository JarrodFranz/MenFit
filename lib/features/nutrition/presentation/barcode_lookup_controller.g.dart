// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barcode_lookup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(BarcodeLookupController)
final barcodeLookupControllerProvider = BarcodeLookupControllerProvider._();

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
final class BarcodeLookupControllerProvider
    extends $NotifierProvider<BarcodeLookupController, BarcodeLookupState> {
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
  BarcodeLookupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'barcodeLookupControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$barcodeLookupControllerHash();

  @$internal
  @override
  BarcodeLookupController create() => BarcodeLookupController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BarcodeLookupState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BarcodeLookupState>(value),
    );
  }
}

String _$barcodeLookupControllerHash() =>
    r'7caa659f03c04cbeb5b257086dd73d4382c1f103';

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

abstract class _$BarcodeLookupController extends $Notifier<BarcodeLookupState> {
  BarcodeLookupState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BarcodeLookupState, BarcodeLookupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BarcodeLookupState, BarcodeLookupState>,
              BarcodeLookupState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
