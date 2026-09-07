// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The saved-routes list for this screen — a thin stream over the
/// repository's non-deleted routes, newest first.

@ProviderFor(routesList)
final routesListProvider = RoutesListProvider._();

/// The saved-routes list for this screen — a thin stream over the
/// repository's non-deleted routes, newest first.

final class RoutesListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavedRoute>>,
          List<SavedRoute>,
          Stream<List<SavedRoute>>
        >
    with $FutureModifier<List<SavedRoute>>, $StreamProvider<List<SavedRoute>> {
  /// The saved-routes list for this screen — a thin stream over the
  /// repository's non-deleted routes, newest first.
  RoutesListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routesListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routesListHash();

  @$internal
  @override
  $StreamProviderElement<List<SavedRoute>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SavedRoute>> create(Ref ref) {
    return routesList(ref);
  }
}

String _$routesListHash() => r'05f14b517ec281dd5cc4fa2a64d04743aba26f17';
