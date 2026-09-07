// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_awake_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's single [ScreenAwake].
///
/// No platform branch: `wakelock_plus` has an implementation on all four
/// targets and the adapter degrades to a swallowed failure where it cannot
/// act (see [WakelockPlusScreenAwake]). There is nothing a capability flag
/// would decide here that the adapter does not already handle.
///
/// `keepAlive` because the lock is a piece of process-wide state, not a
/// screen's: one owner for it means one place that can be asked to let go.
/// It is deliberately **not** released on provider disposal — a lock is
/// held by a session that knows when its session ends, and disposing the
/// container is not that moment.
///
/// Tests override it with
/// `test/core/platform/wakelock/fake_screen_awake.dart`, or with
/// `NoopScreenAwake` — no test should ever reach the real plugin.

@ProviderFor(screenAwake)
final screenAwakeProvider = ScreenAwakeProvider._();

/// The app's single [ScreenAwake].
///
/// No platform branch: `wakelock_plus` has an implementation on all four
/// targets and the adapter degrades to a swallowed failure where it cannot
/// act (see [WakelockPlusScreenAwake]). There is nothing a capability flag
/// would decide here that the adapter does not already handle.
///
/// `keepAlive` because the lock is a piece of process-wide state, not a
/// screen's: one owner for it means one place that can be asked to let go.
/// It is deliberately **not** released on provider disposal — a lock is
/// held by a session that knows when its session ends, and disposing the
/// container is not that moment.
///
/// Tests override it with
/// `test/core/platform/wakelock/fake_screen_awake.dart`, or with
/// `NoopScreenAwake` — no test should ever reach the real plugin.

final class ScreenAwakeProvider
    extends $FunctionalProvider<ScreenAwake, ScreenAwake, ScreenAwake>
    with $Provider<ScreenAwake> {
  /// The app's single [ScreenAwake].
  ///
  /// No platform branch: `wakelock_plus` has an implementation on all four
  /// targets and the adapter degrades to a swallowed failure where it cannot
  /// act (see [WakelockPlusScreenAwake]). There is nothing a capability flag
  /// would decide here that the adapter does not already handle.
  ///
  /// `keepAlive` because the lock is a piece of process-wide state, not a
  /// screen's: one owner for it means one place that can be asked to let go.
  /// It is deliberately **not** released on provider disposal — a lock is
  /// held by a session that knows when its session ends, and disposing the
  /// container is not that moment.
  ///
  /// Tests override it with
  /// `test/core/platform/wakelock/fake_screen_awake.dart`, or with
  /// `NoopScreenAwake` — no test should ever reach the real plugin.
  ScreenAwakeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'screenAwakeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$screenAwakeHash();

  @$internal
  @override
  $ProviderElement<ScreenAwake> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ScreenAwake create(Ref ref) {
    return screenAwake(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScreenAwake value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScreenAwake>(value),
    );
  }
}

String _$screenAwakeHash() => r'fe63df3939bd3c4a0b155e10b2469dc4c9cdd8b9';
