// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_export_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wires [DataExportService] (which produces bytes and never touches a file
/// picker) to the platform save dialog.
///
/// Lives here rather than in the settings tile because the branch table
/// below — which result maps to which state — is what
/// `test/features/data_export/data_export_controller_test.dart` pins, and a
/// decision embedded in a widget callback can only be tested through a native
/// dialog that cannot run in a widget test.
///
/// Default `autoDispose`: nothing here outlives the screen that asked —
/// which is why the tile that starts an export `watch`es it rather than
/// only `read`ing the notifier. Without a listener the notifier is torn down
/// between calls, [DataExportInProgress] is published to nobody, and the
/// progress the state exists to show never appears.

@ProviderFor(DataExportController)
final dataExportControllerProvider = DataExportControllerProvider._();

/// Wires [DataExportService] (which produces bytes and never touches a file
/// picker) to the platform save dialog.
///
/// Lives here rather than in the settings tile because the branch table
/// below — which result maps to which state — is what
/// `test/features/data_export/data_export_controller_test.dart` pins, and a
/// decision embedded in a widget callback can only be tested through a native
/// dialog that cannot run in a widget test.
///
/// Default `autoDispose`: nothing here outlives the screen that asked —
/// which is why the tile that starts an export `watch`es it rather than
/// only `read`ing the notifier. Without a listener the notifier is torn down
/// between calls, [DataExportInProgress] is published to nobody, and the
/// progress the state exists to show never appears.
final class DataExportControllerProvider
    extends $NotifierProvider<DataExportController, DataExportState> {
  /// Wires [DataExportService] (which produces bytes and never touches a file
  /// picker) to the platform save dialog.
  ///
  /// Lives here rather than in the settings tile because the branch table
  /// below — which result maps to which state — is what
  /// `test/features/data_export/data_export_controller_test.dart` pins, and a
  /// decision embedded in a widget callback can only be tested through a native
  /// dialog that cannot run in a widget test.
  ///
  /// Default `autoDispose`: nothing here outlives the screen that asked —
  /// which is why the tile that starts an export `watch`es it rather than
  /// only `read`ing the notifier. Without a listener the notifier is torn down
  /// between calls, [DataExportInProgress] is published to nobody, and the
  /// progress the state exists to show never appears.
  DataExportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataExportControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataExportControllerHash();

  @$internal
  @override
  DataExportController create() => DataExportController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataExportState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataExportState>(value),
    );
  }
}

String _$dataExportControllerHash() =>
    r'39cb1839003608e3f456d780390662d5ee0ff359';

/// Wires [DataExportService] (which produces bytes and never touches a file
/// picker) to the platform save dialog.
///
/// Lives here rather than in the settings tile because the branch table
/// below — which result maps to which state — is what
/// `test/features/data_export/data_export_controller_test.dart` pins, and a
/// decision embedded in a widget callback can only be tested through a native
/// dialog that cannot run in a widget test.
///
/// Default `autoDispose`: nothing here outlives the screen that asked —
/// which is why the tile that starts an export `watch`es it rather than
/// only `read`ing the notifier. Without a listener the notifier is torn down
/// between calls, [DataExportInProgress] is published to nobody, and the
/// progress the state exists to show never appears.

abstract class _$DataExportController extends $Notifier<DataExportState> {
  DataExportState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DataExportState, DataExportState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DataExportState, DataExportState>,
              DataExportState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
