// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mindful_tracker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Global, persistent controller for live Yoga/Pilates tracking.
///
/// `keepAlive: true` deliberately — a session must survive the user leaving
/// `mindful_tracker_screen.dart` (the active-workout banner resumes it from
/// any tab); only [finishSession] or [discardSession] end it. A plain
/// `@riverpod` would be autoDispose and would drop the session, its ticker
/// and the notes typed so far the moment the screen popped.

@ProviderFor(MindfulTrackerController)
final mindfulTrackerControllerProvider = MindfulTrackerControllerProvider._();

/// Global, persistent controller for live Yoga/Pilates tracking.
///
/// `keepAlive: true` deliberately — a session must survive the user leaving
/// `mindful_tracker_screen.dart` (the active-workout banner resumes it from
/// any tab); only [finishSession] or [discardSession] end it. A plain
/// `@riverpod` would be autoDispose and would drop the session, its ticker
/// and the notes typed so far the moment the screen popped.
final class MindfulTrackerControllerProvider
    extends $NotifierProvider<MindfulTrackerController, MindfulTrackerState> {
  /// Global, persistent controller for live Yoga/Pilates tracking.
  ///
  /// `keepAlive: true` deliberately — a session must survive the user leaving
  /// `mindful_tracker_screen.dart` (the active-workout banner resumes it from
  /// any tab); only [finishSession] or [discardSession] end it. A plain
  /// `@riverpod` would be autoDispose and would drop the session, its ticker
  /// and the notes typed so far the moment the screen popped.
  MindfulTrackerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mindfulTrackerControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mindfulTrackerControllerHash();

  @$internal
  @override
  MindfulTrackerController create() => MindfulTrackerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MindfulTrackerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MindfulTrackerState>(value),
    );
  }
}

String _$mindfulTrackerControllerHash() =>
    r'32af8f106cd21240043aff96964beb6dfa7c8157';

/// Global, persistent controller for live Yoga/Pilates tracking.
///
/// `keepAlive: true` deliberately — a session must survive the user leaving
/// `mindful_tracker_screen.dart` (the active-workout banner resumes it from
/// any tab); only [finishSession] or [discardSession] end it. A plain
/// `@riverpod` would be autoDispose and would drop the session, its ticker
/// and the notes typed so far the moment the screen popped.

abstract class _$MindfulTrackerController
    extends $Notifier<MindfulTrackerState> {
  MindfulTrackerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MindfulTrackerState, MindfulTrackerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MindfulTrackerState, MindfulTrackerState>,
              MindfulTrackerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
