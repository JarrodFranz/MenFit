// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hiit_tracker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Global, persistent controller for live HIIT interval tracking.
///
/// `keepAlive: true` deliberately — the interval countdown must survive the
/// user leaving `hiit_tracker_screen.dart` (the active-workout banner resumes
/// it from any tab); only [finishWorkout] or [discardWorkout] end it. A plain
/// `@riverpod` would be autoDispose and would drop the round/phase state and
/// its ticker the moment the screen popped.

@ProviderFor(HiitTrackerController)
final hiitTrackerControllerProvider = HiitTrackerControllerProvider._();

/// Global, persistent controller for live HIIT interval tracking.
///
/// `keepAlive: true` deliberately — the interval countdown must survive the
/// user leaving `hiit_tracker_screen.dart` (the active-workout banner resumes
/// it from any tab); only [finishWorkout] or [discardWorkout] end it. A plain
/// `@riverpod` would be autoDispose and would drop the round/phase state and
/// its ticker the moment the screen popped.
final class HiitTrackerControllerProvider
    extends $NotifierProvider<HiitTrackerController, HiitTrackerState> {
  /// Global, persistent controller for live HIIT interval tracking.
  ///
  /// `keepAlive: true` deliberately — the interval countdown must survive the
  /// user leaving `hiit_tracker_screen.dart` (the active-workout banner resumes
  /// it from any tab); only [finishWorkout] or [discardWorkout] end it. A plain
  /// `@riverpod` would be autoDispose and would drop the round/phase state and
  /// its ticker the moment the screen popped.
  HiitTrackerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hiitTrackerControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hiitTrackerControllerHash();

  @$internal
  @override
  HiitTrackerController create() => HiitTrackerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HiitTrackerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HiitTrackerState>(value),
    );
  }
}

String _$hiitTrackerControllerHash() =>
    r'02435e7ad2218988d48529aaa010b74d65c775aa';

/// Global, persistent controller for live HIIT interval tracking.
///
/// `keepAlive: true` deliberately — the interval countdown must survive the
/// user leaving `hiit_tracker_screen.dart` (the active-workout banner resumes
/// it from any tab); only [finishWorkout] or [discardWorkout] end it. A plain
/// `@riverpod` would be autoDispose and would drop the round/phase state and
/// its ticker the moment the screen popped.

abstract class _$HiitTrackerController extends $Notifier<HiitTrackerState> {
  HiitTrackerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HiitTrackerState, HiitTrackerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HiitTrackerState, HiitTrackerState>,
              HiitTrackerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
