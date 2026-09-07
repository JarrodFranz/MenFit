// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wellbeing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition surface for the `wellbeing` feature (ADR 007).
///
/// The only legal way for another feature (e.g. `home`'s check-in card, or
/// the future streak `DayStatus` evolution reading flare impact) to reach
/// this feature's persistence: other features may import this file, never
/// `data/` or `presentation/` directly.

@ProviderFor(wellbeingRepository)
final wellbeingRepositoryProvider = WellbeingRepositoryProvider._();

/// Composition surface for the `wellbeing` feature (ADR 007).
///
/// The only legal way for another feature (e.g. `home`'s check-in card, or
/// the future streak `DayStatus` evolution reading flare impact) to reach
/// this feature's persistence: other features may import this file, never
/// `data/` or `presentation/` directly.

final class WellbeingRepositoryProvider
    extends
        $FunctionalProvider<
          WellbeingRepository,
          WellbeingRepository,
          WellbeingRepository
        >
    with $Provider<WellbeingRepository> {
  /// Composition surface for the `wellbeing` feature (ADR 007).
  ///
  /// The only legal way for another feature (e.g. `home`'s check-in card, or
  /// the future streak `DayStatus` evolution reading flare impact) to reach
  /// this feature's persistence: other features may import this file, never
  /// `data/` or `presentation/` directly.
  WellbeingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wellbeingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wellbeingRepositoryHash();

  @$internal
  @override
  $ProviderElement<WellbeingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WellbeingRepository create(Ref ref) {
    return wellbeingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WellbeingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WellbeingRepository>(value),
    );
  }
}

String _$wellbeingRepositoryHash() =>
    r'5fe482723d6da58ff24c376020c27f3d2117faed';
