// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_display.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [badgeProgressProvider] with every persisted award folded in — the
/// trophy case's data source.
///
/// Awards are watched, not fetched once: recording a fresh award during
/// detection re-emits and the tile updates with it.
///
/// The awards stream's own loading state is treated as "none yet" rather
/// than awaited, so a case whose progress is ready never waits on a second
/// source to paint. The first emission arrives a frame later and only ever
/// *adds* held rungs.

@ProviderFor(badgeDisplayProgress)
final badgeDisplayProgressProvider = BadgeDisplayProgressProvider._();

/// [badgeProgressProvider] with every persisted award folded in — the
/// trophy case's data source.
///
/// Awards are watched, not fetched once: recording a fresh award during
/// detection re-emits and the tile updates with it.
///
/// The awards stream's own loading state is treated as "none yet" rather
/// than awaited, so a case whose progress is ready never waits on a second
/// source to paint. The first emission arrives a frame later and only ever
/// *adds* held rungs.

final class BadgeDisplayProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BadgeProgress>>,
          List<BadgeProgress>,
          FutureOr<List<BadgeProgress>>
        >
    with
        $FutureModifier<List<BadgeProgress>>,
        $FutureProvider<List<BadgeProgress>> {
  /// [badgeProgressProvider] with every persisted award folded in — the
  /// trophy case's data source.
  ///
  /// Awards are watched, not fetched once: recording a fresh award during
  /// detection re-emits and the tile updates with it.
  ///
  /// The awards stream's own loading state is treated as "none yet" rather
  /// than awaited, so a case whose progress is ready never waits on a second
  /// source to paint. The first emission arrives a frame later and only ever
  /// *adds* held rungs.
  BadgeDisplayProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'badgeDisplayProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$badgeDisplayProgressHash();

  @$internal
  @override
  $FutureProviderElement<List<BadgeProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BadgeProgress>> create(Ref ref) {
    return badgeDisplayProgress(ref);
  }
}

String _$badgeDisplayProgressHash() =>
    r'9c9e3bdb575f74e8e155510fb0d2ad730fa8fc6e';
