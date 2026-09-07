// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_entry_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the manual-activity-entry form (`/activity/log`,
/// `/activity/:id/edit`).

@ProviderFor(ManualEntryController)
final manualEntryControllerProvider = ManualEntryControllerProvider._();

/// Drives the manual-activity-entry form (`/activity/log`,
/// `/activity/:id/edit`).
final class ManualEntryControllerProvider
    extends $NotifierProvider<ManualEntryController, ManualEntryState> {
  /// Drives the manual-activity-entry form (`/activity/log`,
  /// `/activity/:id/edit`).
  ManualEntryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'manualEntryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$manualEntryControllerHash();

  @$internal
  @override
  ManualEntryController create() => ManualEntryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ManualEntryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ManualEntryState>(value),
    );
  }
}

String _$manualEntryControllerHash() =>
    r'efd2dda22f321c93330cb20312117a54947d97fb';

/// Drives the manual-activity-entry form (`/activity/log`,
/// `/activity/:id/edit`).

abstract class _$ManualEntryController extends $Notifier<ManualEntryState> {
  ManualEntryState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ManualEntryState, ManualEntryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ManualEntryState, ManualEntryState>,
              ManualEntryState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
