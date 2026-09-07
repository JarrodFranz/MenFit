// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yoga_sequence_runner_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs a saved [YogaSequence] pose by pose, on the wall clock.
///
/// `keepAlive: true` for the same reason as every other tracker here: the
/// practice must survive the user leaving `yoga_sequence_runner_screen.dart`
/// (the active-workout banner resumes it from any tab). Only [finish] or
/// [discard] end it.
///
/// **Nothing in here logs.** Pose and sequence names are activity data
/// (S1, `knowledge/engineering/security_and_privacy.md`).

@ProviderFor(YogaSequenceRunnerController)
final yogaSequenceRunnerControllerProvider =
    YogaSequenceRunnerControllerProvider._();

/// Runs a saved [YogaSequence] pose by pose, on the wall clock.
///
/// `keepAlive: true` for the same reason as every other tracker here: the
/// practice must survive the user leaving `yoga_sequence_runner_screen.dart`
/// (the active-workout banner resumes it from any tab). Only [finish] or
/// [discard] end it.
///
/// **Nothing in here logs.** Pose and sequence names are activity data
/// (S1, `knowledge/engineering/security_and_privacy.md`).
final class YogaSequenceRunnerControllerProvider
    extends $NotifierProvider<YogaSequenceRunnerController, YogaRunnerState> {
  /// Runs a saved [YogaSequence] pose by pose, on the wall clock.
  ///
  /// `keepAlive: true` for the same reason as every other tracker here: the
  /// practice must survive the user leaving `yoga_sequence_runner_screen.dart`
  /// (the active-workout banner resumes it from any tab). Only [finish] or
  /// [discard] end it.
  ///
  /// **Nothing in here logs.** Pose and sequence names are activity data
  /// (S1, `knowledge/engineering/security_and_privacy.md`).
  YogaSequenceRunnerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'yogaSequenceRunnerControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$yogaSequenceRunnerControllerHash();

  @$internal
  @override
  YogaSequenceRunnerController create() => YogaSequenceRunnerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(YogaRunnerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<YogaRunnerState>(value),
    );
  }
}

String _$yogaSequenceRunnerControllerHash() =>
    r'ec0177c27ad9e7771eff8ad38bdd9e3e42762840';

/// Runs a saved [YogaSequence] pose by pose, on the wall clock.
///
/// `keepAlive: true` for the same reason as every other tracker here: the
/// practice must survive the user leaving `yoga_sequence_runner_screen.dart`
/// (the active-workout banner resumes it from any tab). Only [finish] or
/// [discard] end it.
///
/// **Nothing in here logs.** Pose and sequence names are activity data
/// (S1, `knowledge/engineering/security_and_privacy.md`).

abstract class _$YogaSequenceRunnerController
    extends $Notifier<YogaRunnerState> {
  YogaRunnerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<YogaRunnerState, YogaRunnerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<YogaRunnerState, YogaRunnerState>,
              YogaRunnerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
