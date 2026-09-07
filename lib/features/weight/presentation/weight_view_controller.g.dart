// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_view_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the weight screen's view state. No domain rules live here — the
/// smoothing is in `domain/weight_trend.dart` and the window arithmetic in
/// `domain/weight_range.dart`.
///
/// Defaults to [WeightRange.threeMonths]: long enough that a 7-day trend
/// line has something to say and that two or three cycles are visible for
/// context, short enough that individual readings are still separable.

@ProviderFor(WeightViewController)
final weightViewControllerProvider = WeightViewControllerProvider._();

/// Holds the weight screen's view state. No domain rules live here — the
/// smoothing is in `domain/weight_trend.dart` and the window arithmetic in
/// `domain/weight_range.dart`.
///
/// Defaults to [WeightRange.threeMonths]: long enough that a 7-day trend
/// line has something to say and that two or three cycles are visible for
/// context, short enough that individual readings are still separable.
final class WeightViewControllerProvider
    extends $NotifierProvider<WeightViewController, WeightViewState> {
  /// Holds the weight screen's view state. No domain rules live here — the
  /// smoothing is in `domain/weight_trend.dart` and the window arithmetic in
  /// `domain/weight_range.dart`.
  ///
  /// Defaults to [WeightRange.threeMonths]: long enough that a 7-day trend
  /// line has something to say and that two or three cycles are visible for
  /// context, short enough that individual readings are still separable.
  WeightViewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weightViewControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weightViewControllerHash();

  @$internal
  @override
  WeightViewController create() => WeightViewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeightViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeightViewState>(value),
    );
  }
}

String _$weightViewControllerHash() =>
    r'22cdd639ebbce8af95c077b74d2c1d67067e62ba';

/// Holds the weight screen's view state. No domain rules live here — the
/// smoothing is in `domain/weight_trend.dart` and the window arithmetic in
/// `domain/weight_range.dart`.
///
/// Defaults to [WeightRange.threeMonths]: long enough that a 7-day trend
/// line has something to say and that two or three cycles are visible for
/// context, short enough that individual readings are still separable.

abstract class _$WeightViewController extends $Notifier<WeightViewState> {
  WeightViewState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WeightViewState, WeightViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WeightViewState, WeightViewState>,
              WeightViewState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
