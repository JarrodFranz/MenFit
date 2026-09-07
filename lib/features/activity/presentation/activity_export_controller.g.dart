// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_export_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wires `ActivityExportService` (which produces bytes and never touches a
/// file picker) to the platform save dialog.
///
/// Lives here rather than in the detail screen because the branch table
/// below — which sealed result maps to which outcome — is the decision the
/// test in `test/features/activity/activity_export_controller_test.dart`
/// pins, and a decision embedded in a widget callback can only be tested
/// through a native dialog that cannot run in a widget test.
///
/// Stateless: `build` returns nothing and the notifier exists purely for
/// [export]. Default `autoDispose` — nothing here outlives the screen that
/// invoked it.

@ProviderFor(ActivityExportController)
final activityExportControllerProvider = ActivityExportControllerProvider._();

/// Wires `ActivityExportService` (which produces bytes and never touches a
/// file picker) to the platform save dialog.
///
/// Lives here rather than in the detail screen because the branch table
/// below — which sealed result maps to which outcome — is the decision the
/// test in `test/features/activity/activity_export_controller_test.dart`
/// pins, and a decision embedded in a widget callback can only be tested
/// through a native dialog that cannot run in a widget test.
///
/// Stateless: `build` returns nothing and the notifier exists purely for
/// [export]. Default `autoDispose` — nothing here outlives the screen that
/// invoked it.
final class ActivityExportControllerProvider
    extends $NotifierProvider<ActivityExportController, void> {
  /// Wires `ActivityExportService` (which produces bytes and never touches a
  /// file picker) to the platform save dialog.
  ///
  /// Lives here rather than in the detail screen because the branch table
  /// below — which sealed result maps to which outcome — is the decision the
  /// test in `test/features/activity/activity_export_controller_test.dart`
  /// pins, and a decision embedded in a widget callback can only be tested
  /// through a native dialog that cannot run in a widget test.
  ///
  /// Stateless: `build` returns nothing and the notifier exists purely for
  /// [export]. Default `autoDispose` — nothing here outlives the screen that
  /// invoked it.
  ActivityExportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityExportControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityExportControllerHash();

  @$internal
  @override
  ActivityExportController create() => ActivityExportController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$activityExportControllerHash() =>
    r'a147f66f8627e556851539e5eb208d80fcb6c5be';

/// Wires `ActivityExportService` (which produces bytes and never touches a
/// file picker) to the platform save dialog.
///
/// Lives here rather than in the detail screen because the branch table
/// below — which sealed result maps to which outcome — is the decision the
/// test in `test/features/activity/activity_export_controller_test.dart`
/// pins, and a decision embedded in a widget callback can only be tested
/// through a native dialog that cannot run in a widget test.
///
/// Stateless: `build` returns nothing and the notifier exists purely for
/// [export]. Default `autoDispose` — nothing here outlives the screen that
/// invoked it.

abstract class _$ActivityExportController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
