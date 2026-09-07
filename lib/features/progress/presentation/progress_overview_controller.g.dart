// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_overview_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProgressOverviewController)
final progressOverviewControllerProvider =
    ProgressOverviewControllerProvider._();

final class ProgressOverviewControllerProvider
    extends
        $NotifierProvider<ProgressOverviewController, ProgressOverviewState> {
  ProgressOverviewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressOverviewControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$progressOverviewControllerHash();

  @$internal
  @override
  ProgressOverviewController create() => ProgressOverviewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgressOverviewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgressOverviewState>(value),
    );
  }
}

String _$progressOverviewControllerHash() =>
    r'611c42d8480a9c643494d1252e4352f1dcc37c81';

abstract class _$ProgressOverviewController
    extends $Notifier<ProgressOverviewState> {
  ProgressOverviewState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProgressOverviewState, ProgressOverviewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProgressOverviewState, ProgressOverviewState>,
              ProgressOverviewState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
