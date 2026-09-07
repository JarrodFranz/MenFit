// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_import_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Coordinates file picking, document parsing, user confirmation, and
/// database restoration.

@ProviderFor(DataImportController)
final dataImportControllerProvider = DataImportControllerProvider._();

/// Coordinates file picking, document parsing, user confirmation, and
/// database restoration.
final class DataImportControllerProvider
    extends $NotifierProvider<DataImportController, DataImportState> {
  /// Coordinates file picking, document parsing, user confirmation, and
  /// database restoration.
  DataImportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataImportControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataImportControllerHash();

  @$internal
  @override
  DataImportController create() => DataImportController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataImportState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataImportState>(value),
    );
  }
}

String _$dataImportControllerHash() =>
    r'0c2dcf7eebceba67ccc4fc051af9fba2262e4bab';

/// Coordinates file picking, document parsing, user confirmation, and
/// database restoration.

abstract class _$DataImportController extends $Notifier<DataImportState> {
  DataImportState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DataImportState, DataImportState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DataImportState, DataImportState>,
              DataImportState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
