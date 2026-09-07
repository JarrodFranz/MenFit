// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_export_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads the local database for export, typed as the domain interface so
/// nothing above `data/` knows Drift is behind it.

@ProviderFor(dataExportSource)
final dataExportSourceProvider = DataExportSourceProvider._();

/// Reads the local database for export, typed as the domain interface so
/// nothing above `data/` knows Drift is behind it.

final class DataExportSourceProvider
    extends
        $FunctionalProvider<
          DataExportSource,
          DataExportSource,
          DataExportSource
        >
    with $Provider<DataExportSource> {
  /// Reads the local database for export, typed as the domain interface so
  /// nothing above `data/` knows Drift is behind it.
  DataExportSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataExportSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataExportSourceHash();

  @$internal
  @override
  $ProviderElement<DataExportSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DataExportSource create(Ref ref) {
    return dataExportSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataExportSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataExportSource>(value),
    );
  }
}

String _$dataExportSourceHash() => r'76580408834696d71db2cae0c034a53100a45e4d';

/// Builds the export document from what [dataExportSourceProvider] reads.
///
/// `keepAlive` for the same reason as `activityExportServiceProvider`: it is
/// an app-scoped, stateless service, and an export begun from a screen must
/// not be torn down because that screen went away mid-write.

@ProviderFor(dataExportService)
final dataExportServiceProvider = DataExportServiceProvider._();

/// Builds the export document from what [dataExportSourceProvider] reads.
///
/// `keepAlive` for the same reason as `activityExportServiceProvider`: it is
/// an app-scoped, stateless service, and an export begun from a screen must
/// not be torn down because that screen went away mid-write.

final class DataExportServiceProvider
    extends
        $FunctionalProvider<
          DataExportService,
          DataExportService,
          DataExportService
        >
    with $Provider<DataExportService> {
  /// Builds the export document from what [dataExportSourceProvider] reads.
  ///
  /// `keepAlive` for the same reason as `activityExportServiceProvider`: it is
  /// an app-scoped, stateless service, and an export begun from a screen must
  /// not be torn down because that screen went away mid-write.
  DataExportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataExportServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataExportServiceHash();

  @$internal
  @override
  $ProviderElement<DataExportService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DataExportService create(Ref ref) {
    return dataExportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataExportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataExportService>(value),
    );
  }
}

String _$dataExportServiceHash() => r'61623d63255c1cfe6d05cb9027e11f9385dcf296';

/// Restores the local database from an export, typed as the domain interface.

@ProviderFor(dataImportTarget)
final dataImportTargetProvider = DataImportTargetProvider._();

/// Restores the local database from an export, typed as the domain interface.

final class DataImportTargetProvider
    extends
        $FunctionalProvider<
          DataImportTarget,
          DataImportTarget,
          DataImportTarget
        >
    with $Provider<DataImportTarget> {
  /// Restores the local database from an export, typed as the domain interface.
  DataImportTargetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataImportTargetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataImportTargetHash();

  @$internal
  @override
  $ProviderElement<DataImportTarget> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DataImportTarget create(Ref ref) {
    return dataImportTarget(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataImportTarget value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataImportTarget>(value),
    );
  }
}

String _$dataImportTargetHash() => r'e0ffb61bad918aa3c8d40020d93150ed6088d622';

/// Orchestrates backup document parsing and restoration into persistence.

@ProviderFor(dataImportService)
final dataImportServiceProvider = DataImportServiceProvider._();

/// Orchestrates backup document parsing and restoration into persistence.

final class DataImportServiceProvider
    extends
        $FunctionalProvider<
          DataImportService,
          DataImportService,
          DataImportService
        >
    with $Provider<DataImportService> {
  /// Orchestrates backup document parsing and restoration into persistence.
  DataImportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataImportServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataImportServiceHash();

  @$internal
  @override
  $ProviderElement<DataImportService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DataImportService create(Ref ref) {
    return dataImportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataImportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataImportService>(value),
    );
  }
}

String _$dataImportServiceHash() => r'0bf31553ff4b0c93559b06a966df025dcb8b1fb5';
