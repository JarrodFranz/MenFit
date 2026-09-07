// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strength_tracker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Global, persistent controller for live Strength tracking.
///
/// `keepAlive: true` deliberately — a session must survive the user leaving
/// `strength_tracker_screen.dart` (the active-workout banner resumes it from
/// any tab); only [finishWorkout] or [discardWorkout] end it. A plain
/// `@riverpod` would be autoDispose and would drop the live session, its
/// ticker and its logged sets the moment the screen popped.

@ProviderFor(StrengthTrackerController)
final strengthTrackerControllerProvider = StrengthTrackerControllerProvider._();

/// Global, persistent controller for live Strength tracking.
///
/// `keepAlive: true` deliberately — a session must survive the user leaving
/// `strength_tracker_screen.dart` (the active-workout banner resumes it from
/// any tab); only [finishWorkout] or [discardWorkout] end it. A plain
/// `@riverpod` would be autoDispose and would drop the live session, its
/// ticker and its logged sets the moment the screen popped.
final class StrengthTrackerControllerProvider
    extends $NotifierProvider<StrengthTrackerController, StrengthTrackerState> {
  /// Global, persistent controller for live Strength tracking.
  ///
  /// `keepAlive: true` deliberately — a session must survive the user leaving
  /// `strength_tracker_screen.dart` (the active-workout banner resumes it from
  /// any tab); only [finishWorkout] or [discardWorkout] end it. A plain
  /// `@riverpod` would be autoDispose and would drop the live session, its
  /// ticker and its logged sets the moment the screen popped.
  StrengthTrackerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'strengthTrackerControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$strengthTrackerControllerHash();

  @$internal
  @override
  StrengthTrackerController create() => StrengthTrackerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StrengthTrackerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StrengthTrackerState>(value),
    );
  }
}

String _$strengthTrackerControllerHash() =>
    r'84a449c2991f0027c260eb3b867f9c6c675a09a0';

/// Global, persistent controller for live Strength tracking.
///
/// `keepAlive: true` deliberately — a session must survive the user leaving
/// `strength_tracker_screen.dart` (the active-workout banner resumes it from
/// any tab); only [finishWorkout] or [discardWorkout] end it. A plain
/// `@riverpod` would be autoDispose and would drop the live session, its
/// ticker and its logged sets the moment the screen popped.

abstract class _$StrengthTrackerController
    extends $Notifier<StrengthTrackerState> {
  StrengthTrackerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StrengthTrackerState, StrengthTrackerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StrengthTrackerState, StrengthTrackerState>,
              StrengthTrackerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
