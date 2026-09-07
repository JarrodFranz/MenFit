// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wall-clock source for [RecordingController]: both the [RecordingSession]
/// it creates and its forgotten-end ticker comparison
/// ([RecordingController._syncStateFromSession]) read "now" through this
/// rather than calling [DateTime.now] directly, so a test can override it
/// with a controllable fake clock and jump forward by minutes instead of
/// waiting out real wall-clock time (see `recording_controller_test.dart`).
/// Defaults to real wall-clock time, so production behaviour is unchanged.

@ProviderFor(recordingClock)
final recordingClockProvider = RecordingClockProvider._();

/// Wall-clock source for [RecordingController]: both the [RecordingSession]
/// it creates and its forgotten-end ticker comparison
/// ([RecordingController._syncStateFromSession]) read "now" through this
/// rather than calling [DateTime.now] directly, so a test can override it
/// with a controllable fake clock and jump forward by minutes instead of
/// waiting out real wall-clock time (see `recording_controller_test.dart`).
/// Defaults to real wall-clock time, so production behaviour is unchanged.

final class RecordingClockProvider
    extends
        $FunctionalProvider<
          DateTime Function(),
          DateTime Function(),
          DateTime Function()
        >
    with $Provider<DateTime Function()> {
  /// Wall-clock source for [RecordingController]: both the [RecordingSession]
  /// it creates and its forgotten-end ticker comparison
  /// ([RecordingController._syncStateFromSession]) read "now" through this
  /// rather than calling [DateTime.now] directly, so a test can override it
  /// with a controllable fake clock and jump forward by minutes instead of
  /// waiting out real wall-clock time (see `recording_controller_test.dart`).
  /// Defaults to real wall-clock time, so production behaviour is unchanged.
  RecordingClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordingClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordingClockHash();

  @$internal
  @override
  $ProviderElement<DateTime Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTime Function() create(Ref ref) {
    return recordingClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime Function()>(value),
    );
  }
}

String _$recordingClockHash() => r'b24b318d4f37afbf9220d8a3aafa346d765ffa91';

/// Orchestrates a GPS recording end to end: permission flow ->
/// [RecordingSession] feeding -> persistence.
///
/// `keepAlive: true` deliberately — a recording must survive the user
/// navigating away from `record_screen.dart` (e.g. checking another tab
/// mid-run); only [finish] or [discard] end it. This mirrors why the
/// Android foreground-service notification exists at all (ADR 008): the
/// recording is a long-lived background operation, not screen-scoped state.

@ProviderFor(RecordingController)
final recordingControllerProvider = RecordingControllerProvider._();

/// Orchestrates a GPS recording end to end: permission flow ->
/// [RecordingSession] feeding -> persistence.
///
/// `keepAlive: true` deliberately — a recording must survive the user
/// navigating away from `record_screen.dart` (e.g. checking another tab
/// mid-run); only [finish] or [discard] end it. This mirrors why the
/// Android foreground-service notification exists at all (ADR 008): the
/// recording is a long-lived background operation, not screen-scoped state.
final class RecordingControllerProvider
    extends $NotifierProvider<RecordingController, RecordingControllerState> {
  /// Orchestrates a GPS recording end to end: permission flow ->
  /// [RecordingSession] feeding -> persistence.
  ///
  /// `keepAlive: true` deliberately — a recording must survive the user
  /// navigating away from `record_screen.dart` (e.g. checking another tab
  /// mid-run); only [finish] or [discard] end it. This mirrors why the
  /// Android foreground-service notification exists at all (ADR 008): the
  /// recording is a long-lived background operation, not screen-scoped state.
  RecordingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordingControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordingControllerHash();

  @$internal
  @override
  RecordingController create() => RecordingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecordingControllerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecordingControllerState>(value),
    );
  }
}

String _$recordingControllerHash() =>
    r'f2058ff4b6602835317a2aa70491a3dcf4a04465';

/// Orchestrates a GPS recording end to end: permission flow ->
/// [RecordingSession] feeding -> persistence.
///
/// `keepAlive: true` deliberately — a recording must survive the user
/// navigating away from `record_screen.dart` (e.g. checking another tab
/// mid-run); only [finish] or [discard] end it. This mirrors why the
/// Android foreground-service notification exists at all (ADR 008): the
/// recording is a long-lived background operation, not screen-scoped state.

abstract class _$RecordingController
    extends $Notifier<RecordingControllerState> {
  RecordingControllerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<RecordingControllerState, RecordingControllerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RecordingControllerState, RecordingControllerState>,
              RecordingControllerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
