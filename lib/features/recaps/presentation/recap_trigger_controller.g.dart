// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recap_trigger_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Decides whether a "Your Cycle in Motion" recap (`TASKS_TO_DO.md` Task
/// 1.3) is due and ready to present, and exposes the action to mark it
/// shown once it has been.
///
/// Watched from `presentation/widgets/recap_trigger_listener.dart`, which
/// `home/presentation/home_screen.dart` mounts through this feature's UI
/// composition surface (`recaps_widgets.dart`, ADR 007's amendment) — this
/// controller itself stays a `presentation/` internal, never imported by
/// another feature directly.
///
/// Default `autoDispose` (no `keepAlive`): the app keeps every shell
/// branch's navigator mounted offstage in an `IndexedStack`
/// (`activity_providers.dart#personalRecords`'s dartdoc documents the same
/// reality for a different provider), so this stays alive for as long as
/// Home does without needing to opt out of disposal — there's no
/// app-scoped reason for it to outlive that.

@ProviderFor(RecapTriggerController)
final recapTriggerControllerProvider = RecapTriggerControllerProvider._();

/// Decides whether a "Your Cycle in Motion" recap (`TASKS_TO_DO.md` Task
/// 1.3) is due and ready to present, and exposes the action to mark it
/// shown once it has been.
///
/// Watched from `presentation/widgets/recap_trigger_listener.dart`, which
/// `home/presentation/home_screen.dart` mounts through this feature's UI
/// composition surface (`recaps_widgets.dart`, ADR 007's amendment) — this
/// controller itself stays a `presentation/` internal, never imported by
/// another feature directly.
///
/// Default `autoDispose` (no `keepAlive`): the app keeps every shell
/// branch's navigator mounted offstage in an `IndexedStack`
/// (`activity_providers.dart#personalRecords`'s dartdoc documents the same
/// reality for a different provider), so this stays alive for as long as
/// Home does without needing to opt out of disposal — there's no
/// app-scoped reason for it to outlive that.
final class RecapTriggerControllerProvider
    extends $AsyncNotifierProvider<RecapTriggerController, CycleRecap?> {
  /// Decides whether a "Your Cycle in Motion" recap (`TASKS_TO_DO.md` Task
  /// 1.3) is due and ready to present, and exposes the action to mark it
  /// shown once it has been.
  ///
  /// Watched from `presentation/widgets/recap_trigger_listener.dart`, which
  /// `home/presentation/home_screen.dart` mounts through this feature's UI
  /// composition surface (`recaps_widgets.dart`, ADR 007's amendment) — this
  /// controller itself stays a `presentation/` internal, never imported by
  /// another feature directly.
  ///
  /// Default `autoDispose` (no `keepAlive`): the app keeps every shell
  /// branch's navigator mounted offstage in an `IndexedStack`
  /// (`activity_providers.dart#personalRecords`'s dartdoc documents the same
  /// reality for a different provider), so this stays alive for as long as
  /// Home does without needing to opt out of disposal — there's no
  /// app-scoped reason for it to outlive that.
  RecapTriggerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recapTriggerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recapTriggerControllerHash();

  @$internal
  @override
  RecapTriggerController create() => RecapTriggerController();
}

String _$recapTriggerControllerHash() =>
    r'393153dfd9cf0d615789c246d5e4b34296ae7a29';

/// Decides whether a "Your Cycle in Motion" recap (`TASKS_TO_DO.md` Task
/// 1.3) is due and ready to present, and exposes the action to mark it
/// shown once it has been.
///
/// Watched from `presentation/widgets/recap_trigger_listener.dart`, which
/// `home/presentation/home_screen.dart` mounts through this feature's UI
/// composition surface (`recaps_widgets.dart`, ADR 007's amendment) — this
/// controller itself stays a `presentation/` internal, never imported by
/// another feature directly.
///
/// Default `autoDispose` (no `keepAlive`): the app keeps every shell
/// branch's navigator mounted offstage in an `IndexedStack`
/// (`activity_providers.dart#personalRecords`'s dartdoc documents the same
/// reality for a different provider), so this stays alive for as long as
/// Home does without needing to opt out of disposal — there's no
/// app-scoped reason for it to outlive that.

abstract class _$RecapTriggerController extends $AsyncNotifier<CycleRecap?> {
  FutureOr<CycleRecap?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CycleRecap?>, CycleRecap?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CycleRecap?>, CycleRecap?>,
              AsyncValue<CycleRecap?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
