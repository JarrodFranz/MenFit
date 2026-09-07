import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/data_export/application/data_import_service.dart';
import 'package:menfit_app/features/data_export/data_export_providers.dart';
import 'package:menfit_app/features/data_export/data_export_widgets.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';
import 'package:menfit_app/features/data_export/domain/data_import_target.dart';

class _FakeTarget implements DataImportTarget {
  _FakeTarget({this.failure, this.summary});

  final Object? failure;
  final DataExportSummary? summary;

  @override
  int get schemaVersion => 24;

  @override
  Future<DataExportSummary> importDocument(DataExportDocument document) async {
    // Throws whatever the test provided to verify error handling.
    // ignore: only_throw_errors
    if (failure != null) throw failure!;
    return summary ?? const DataExportSummary(tableCount: 1, rowCount: 1);
  }
}

void main() {
  Uint8List validBytes() {
    final doc = DataExportDocument(
      schemaVersion: 24,
      exportedAt: DateTime.utc(2026, 9, 4),
      includesSensitiveHealthData: false,
      tables: {
        'weight_logs': [
          {'id': 'w-1', 'weight_kg': 60.0},
        ],
      },
    );
    return doc.toBytes();
  }

  ProviderContainer createContainer({_FakeTarget? target}) {
    final fakeTarget = target ?? _FakeTarget();
    return ProviderContainer(
      overrides: [
        dataImportTargetProvider.overrideWithValue(fakeTarget),
        dataImportServiceProvider.overrideWithValue(
          DataImportService(
            target: fakeTarget,
            decode: (bytes) async => decodeDataExportJson(bytes),
          ),
        ),
      ],
    );
  }

  test('initial state is DataImportIdle', () {
    final container = createContainer();
    addTearDown(container.dispose);

    expect(
      container.read(dataImportControllerProvider),
      isA<DataImportIdle>(),
    );
  });

  test('abort when user cancels file picker', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final controller = container.read(dataImportControllerProvider.notifier);
    final result = await controller.importData(
      filePicker: () async => null,
      confirmDialog: (_) async => true,
    );

    expect(result, isA<DataImportAborted>());
    expect(
      container.read(dataImportControllerProvider),
      isA<DataImportAborted>(),
    );
  });

  test('abort when user declines confirmation dialog', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final controller = container.read(dataImportControllerProvider.notifier);
    final result = await controller.importData(
      filePicker: () async => validBytes(),
      confirmDialog: (_) async => false,
    );

    expect(result, isA<DataImportAborted>());
    expect(
      container.read(dataImportControllerProvider),
      isA<DataImportAborted>(),
    );
  });

  test('success restores data and transitions to DataImportRestored', () async {
    final container = createContainer(
      target: _FakeTarget(
        summary: const DataExportSummary(tableCount: 2, rowCount: 10),
      ),
    );
    addTearDown(container.dispose);

    final controller = container.read(dataImportControllerProvider.notifier);
    final result = await controller.importData(
      filePicker: () async => validBytes(),
      confirmDialog: (_) async => true,
    );

    expect(result, isA<DataImportRestored>());
    final restored = result as DataImportRestored;
    expect(restored.summary.tableCount, 2);
    expect(restored.summary.rowCount, 10);
  });

  test('corrupted file transitions to DataImportError', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final controller = container.read(dataImportControllerProvider.notifier);
    final result = await controller.importData(
      filePicker: () async => Uint8List.fromList([1, 2, 3]),
      confirmDialog: (_) async => true,
    );

    expect(result, isA<DataImportError>());
    final error = result as DataImportError;
    expect(error.userMessage, contains('Could not read the backup file'));
  });

  test('failure during restore transitions to DataImportError', () async {
    final container = createContainer(
      target: _FakeTarget(
        failure: const StorageException(
          message: 'disk failure',
          userMessageKey: 'error.importWrite',
        ),
      ),
    );
    addTearDown(container.dispose);

    final controller = container.read(dataImportControllerProvider.notifier);
    final result = await controller.importData(
      filePicker: () async => validBytes(),
      confirmDialog: (_) async => true,
    );

    expect(result, isA<DataImportError>());
    final error = result as DataImportError;
    expect(error.userMessage, contains('restoring your data'));
  });
}
