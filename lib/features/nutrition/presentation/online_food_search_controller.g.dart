// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_food_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs text searches against the food database — **only when asked**.
///
/// ## Never search-as-you-type
///
/// Typing searches the local catalogue and nothing else. Sending a query
/// online is a button press, and there are two independent reasons, either
/// of which alone would settle it:
///
/// 1. **Privacy.** The words a person types into a food search are theirs, and
///    ADR 010 makes sending them an explicit act rather than a side-effect
///    of typing. This is the first feature in the app to send user-typed
///    content off-device at all.
/// 2. **Rate limits.** Open Food Facts documents **10 search requests per
///    minute** per IP, which for a client-side app means per end-user. A
///    live-search box fires one per keystroke and would be blocked within
///    seconds of the first word.
///
/// Anyone "improving" this into a live-search box has to solve the second
/// before arguing about the first
/// (`data/open_food_facts_service.dart` says the same at the wire).
///
/// ## Paging
///
/// One page per explicit request, following the contract's rule: keep asking
/// for successive pages until one comes back with fewer than
/// [onlineFoodSearchPageSize] hits. Eagerly draining every page would burn
/// the whole per-minute budget on a common word, so the next page is a
/// button too. The provider's total count is a **capped estimate** and is
/// deliberately never rendered.

@ProviderFor(OnlineFoodSearchController)
final onlineFoodSearchControllerProvider =
    OnlineFoodSearchControllerProvider._();

/// Runs text searches against the food database — **only when asked**.
///
/// ## Never search-as-you-type
///
/// Typing searches the local catalogue and nothing else. Sending a query
/// online is a button press, and there are two independent reasons, either
/// of which alone would settle it:
///
/// 1. **Privacy.** The words a person types into a food search are theirs, and
///    ADR 010 makes sending them an explicit act rather than a side-effect
///    of typing. This is the first feature in the app to send user-typed
///    content off-device at all.
/// 2. **Rate limits.** Open Food Facts documents **10 search requests per
///    minute** per IP, which for a client-side app means per end-user. A
///    live-search box fires one per keystroke and would be blocked within
///    seconds of the first word.
///
/// Anyone "improving" this into a live-search box has to solve the second
/// before arguing about the first
/// (`data/open_food_facts_service.dart` says the same at the wire).
///
/// ## Paging
///
/// One page per explicit request, following the contract's rule: keep asking
/// for successive pages until one comes back with fewer than
/// [onlineFoodSearchPageSize] hits. Eagerly draining every page would burn
/// the whole per-minute budget on a common word, so the next page is a
/// button too. The provider's total count is a **capped estimate** and is
/// deliberately never rendered.
final class OnlineFoodSearchControllerProvider
    extends
        $NotifierProvider<OnlineFoodSearchController, OnlineFoodSearchState> {
  /// Runs text searches against the food database — **only when asked**.
  ///
  /// ## Never search-as-you-type
  ///
  /// Typing searches the local catalogue and nothing else. Sending a query
  /// online is a button press, and there are two independent reasons, either
  /// of which alone would settle it:
  ///
  /// 1. **Privacy.** The words a person types into a food search are theirs, and
  ///    ADR 010 makes sending them an explicit act rather than a side-effect
  ///    of typing. This is the first feature in the app to send user-typed
  ///    content off-device at all.
  /// 2. **Rate limits.** Open Food Facts documents **10 search requests per
  ///    minute** per IP, which for a client-side app means per end-user. A
  ///    live-search box fires one per keystroke and would be blocked within
  ///    seconds of the first word.
  ///
  /// Anyone "improving" this into a live-search box has to solve the second
  /// before arguing about the first
  /// (`data/open_food_facts_service.dart` says the same at the wire).
  ///
  /// ## Paging
  ///
  /// One page per explicit request, following the contract's rule: keep asking
  /// for successive pages until one comes back with fewer than
  /// [onlineFoodSearchPageSize] hits. Eagerly draining every page would burn
  /// the whole per-minute budget on a common word, so the next page is a
  /// button too. The provider's total count is a **capped estimate** and is
  /// deliberately never rendered.
  OnlineFoodSearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onlineFoodSearchControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onlineFoodSearchControllerHash();

  @$internal
  @override
  OnlineFoodSearchController create() => OnlineFoodSearchController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnlineFoodSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnlineFoodSearchState>(value),
    );
  }
}

String _$onlineFoodSearchControllerHash() =>
    r'e60b8664ad2fcc274484229e09ecb87291eecdf2';

/// Runs text searches against the food database — **only when asked**.
///
/// ## Never search-as-you-type
///
/// Typing searches the local catalogue and nothing else. Sending a query
/// online is a button press, and there are two independent reasons, either
/// of which alone would settle it:
///
/// 1. **Privacy.** The words a person types into a food search are theirs, and
///    ADR 010 makes sending them an explicit act rather than a side-effect
///    of typing. This is the first feature in the app to send user-typed
///    content off-device at all.
/// 2. **Rate limits.** Open Food Facts documents **10 search requests per
///    minute** per IP, which for a client-side app means per end-user. A
///    live-search box fires one per keystroke and would be blocked within
///    seconds of the first word.
///
/// Anyone "improving" this into a live-search box has to solve the second
/// before arguing about the first
/// (`data/open_food_facts_service.dart` says the same at the wire).
///
/// ## Paging
///
/// One page per explicit request, following the contract's rule: keep asking
/// for successive pages until one comes back with fewer than
/// [onlineFoodSearchPageSize] hits. Eagerly draining every page would burn
/// the whole per-minute budget on a common word, so the next page is a
/// button too. The provider's total count is a **capped estimate** and is
/// deliberately never rendered.

abstract class _$OnlineFoodSearchController
    extends $Notifier<OnlineFoodSearchState> {
  OnlineFoodSearchState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OnlineFoodSearchState, OnlineFoodSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnlineFoodSearchState, OnlineFoodSearchState>,
              OnlineFoodSearchState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
