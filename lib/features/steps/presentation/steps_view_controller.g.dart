// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'steps_view_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StepsViewController)
final stepsViewControllerProvider = StepsViewControllerProvider._();

final class StepsViewControllerProvider
    extends $NotifierProvider<StepsViewController, StepsViewState> {
  StepsViewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stepsViewControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stepsViewControllerHash();

  @$internal
  @override
  StepsViewController create() => StepsViewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StepsViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StepsViewState>(value),
    );
  }
}

String _$stepsViewControllerHash() =>
    r'cdedb8499aa45de41a1c1a67fad4c1bc0a39f4dc';

abstract class _$StepsViewController extends $Notifier<StepsViewState> {
  StepsViewState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StepsViewState, StepsViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StepsViewState, StepsViewState>,
              StepsViewState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
