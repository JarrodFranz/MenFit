// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_vitals_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads watch vitals on demand. State lives in this provider's memory
/// only — nothing is persisted or cached — and is gone when the card that
/// watches it is disposed (autoDispose).

@ProviderFor(WatchVitalsController)
final watchVitalsControllerProvider = WatchVitalsControllerProvider._();

/// Reads watch vitals on demand. State lives in this provider's memory
/// only — nothing is persisted or cached — and is gone when the card that
/// watches it is disposed (autoDispose).
final class WatchVitalsControllerProvider
    extends $AsyncNotifierProvider<WatchVitalsController, WatchVitalsView> {
  /// Reads watch vitals on demand. State lives in this provider's memory
  /// only — nothing is persisted or cached — and is gone when the card that
  /// watches it is disposed (autoDispose).
  WatchVitalsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchVitalsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchVitalsControllerHash();

  @$internal
  @override
  WatchVitalsController create() => WatchVitalsController();
}

String _$watchVitalsControllerHash() =>
    r'64ee24b66758faed150d1795e42b94e5db66bb06';

/// Reads watch vitals on demand. State lives in this provider's memory
/// only — nothing is persisted or cached — and is gone when the card that
/// watches it is disposed (autoDispose).

abstract class _$WatchVitalsController extends $AsyncNotifier<WatchVitalsView> {
  FutureOr<WatchVitalsView> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<WatchVitalsView>, WatchVitalsView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WatchVitalsView>, WatchVitalsView>,
              AsyncValue<WatchVitalsView>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
