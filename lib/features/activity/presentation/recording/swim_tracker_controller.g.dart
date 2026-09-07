// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swim_tracker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Global, persistent controller for live Swim tracking.
///
/// `keepAlive: true` deliberately — a swim must survive the user leaving
/// `swim_tracker_screen.dart` (the active-workout banner resumes it from any
/// tab); only [finishWorkout] or [discardWorkout] end it. A plain `@riverpod`
/// would be autoDispose and would drop the lap tally and ticker the moment
/// the screen popped.

@ProviderFor(SwimTrackerController)
final swimTrackerControllerProvider = SwimTrackerControllerProvider._();

/// Global, persistent controller for live Swim tracking.
///
/// `keepAlive: true` deliberately — a swim must survive the user leaving
/// `swim_tracker_screen.dart` (the active-workout banner resumes it from any
/// tab); only [finishWorkout] or [discardWorkout] end it. A plain `@riverpod`
/// would be autoDispose and would drop the lap tally and ticker the moment
/// the screen popped.
final class SwimTrackerControllerProvider
    extends $NotifierProvider<SwimTrackerController, SwimTrackerState> {
  /// Global, persistent controller for live Swim tracking.
  ///
  /// `keepAlive: true` deliberately — a swim must survive the user leaving
  /// `swim_tracker_screen.dart` (the active-workout banner resumes it from any
  /// tab); only [finishWorkout] or [discardWorkout] end it. A plain `@riverpod`
  /// would be autoDispose and would drop the lap tally and ticker the moment
  /// the screen popped.
  SwimTrackerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'swimTrackerControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$swimTrackerControllerHash();

  @$internal
  @override
  SwimTrackerController create() => SwimTrackerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SwimTrackerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SwimTrackerState>(value),
    );
  }
}

String _$swimTrackerControllerHash() =>
    r'18c62c90d32baba5c3b38b775b83002e772b5ada';

/// Global, persistent controller for live Swim tracking.
///
/// `keepAlive: true` deliberately — a swim must survive the user leaving
/// `swim_tracker_screen.dart` (the active-workout banner resumes it from any
/// tab); only [finishWorkout] or [discardWorkout] end it. A plain `@riverpod`
/// would be autoDispose and would drop the lap tally and ticker the moment
/// the screen popped.

abstract class _$SwimTrackerController extends $Notifier<SwimTrackerState> {
  SwimTrackerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SwimTrackerState, SwimTrackerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SwimTrackerState, SwimTrackerState>,
              SwimTrackerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
