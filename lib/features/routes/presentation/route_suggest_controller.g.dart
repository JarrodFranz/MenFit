// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_suggest_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the route-suggest flow (`/activity/routes/suggest`): inputs ->
/// suggestion request -> selection -> explicit save.

@ProviderFor(RouteSuggestController)
final routeSuggestControllerProvider = RouteSuggestControllerProvider._();

/// Drives the route-suggest flow (`/activity/routes/suggest`): inputs ->
/// suggestion request -> selection -> explicit save.
final class RouteSuggestControllerProvider
    extends $NotifierProvider<RouteSuggestController, RouteSuggestState> {
  /// Drives the route-suggest flow (`/activity/routes/suggest`): inputs ->
  /// suggestion request -> selection -> explicit save.
  RouteSuggestControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routeSuggestControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routeSuggestControllerHash();

  @$internal
  @override
  RouteSuggestController create() => RouteSuggestController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RouteSuggestState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RouteSuggestState>(value),
    );
  }
}

String _$routeSuggestControllerHash() =>
    r'a2a48d9f76980ed9996804b55368d04ac53f6b45';

/// Drives the route-suggest flow (`/activity/routes/suggest`): inputs ->
/// suggestion request -> selection -> explicit save.

abstract class _$RouteSuggestController extends $Notifier<RouteSuggestState> {
  RouteSuggestState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RouteSuggestState, RouteSuggestState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RouteSuggestState, RouteSuggestState>,
              RouteSuggestState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
