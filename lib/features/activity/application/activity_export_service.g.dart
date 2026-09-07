// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_export_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for [ActivityExportService].
///
/// `keepAlive` because the service holds the [Ref] it later reads the
/// activity repository from: an autoDispose provider's ref can be disposed
/// between construction and the `exportActivity` call it is used in, and
/// reading a disposed ref throws. It is app-scoped and stateless anyway,
/// like every other service on a composition surface here.

@ProviderFor(activityExportService)
final activityExportServiceProvider = ActivityExportServiceProvider._();

/// Provider for [ActivityExportService].
///
/// `keepAlive` because the service holds the [Ref] it later reads the
/// activity repository from: an autoDispose provider's ref can be disposed
/// between construction and the `exportActivity` call it is used in, and
/// reading a disposed ref throws. It is app-scoped and stateless anyway,
/// like every other service on a composition surface here.

final class ActivityExportServiceProvider
    extends
        $FunctionalProvider<
          ActivityExportService,
          ActivityExportService,
          ActivityExportService
        >
    with $Provider<ActivityExportService> {
  /// Provider for [ActivityExportService].
  ///
  /// `keepAlive` because the service holds the [Ref] it later reads the
  /// activity repository from: an autoDispose provider's ref can be disposed
  /// between construction and the `exportActivity` call it is used in, and
  /// reading a disposed ref throws. It is app-scoped and stateless anyway,
  /// like every other service on a composition surface here.
  ActivityExportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityExportServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityExportServiceHash();

  @$internal
  @override
  $ProviderElement<ActivityExportService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ActivityExportService create(Ref ref) {
    return activityExportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActivityExportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActivityExportService>(value),
    );
  }
}

String _$activityExportServiceHash() =>
    r'2604161cfd5b97ea979b9e431a24acf7c7f4669a';
