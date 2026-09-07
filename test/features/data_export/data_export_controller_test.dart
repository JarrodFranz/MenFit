import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/data_export/application/data_export_service.dart';
import 'package:menfit_app/features/data_export/data_export_providers.dart';
import 'package:menfit_app/features/data_export/data_export_widgets.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';
import 'package:menfit_app/features/data_export/domain/data_export_source.dart';

/// Stands in for the Drift exporter so the controller's branch table can be
/// exercised without a database: this test is about which outcome maps to
/// which state, not about SQL.
class _FakeSource implements DataExportSource {
  _FakeSource({this.failure});

  final Object? failure;

  bool? askedForCycleAndWellbeing;

  @override
  int get schemaVersion => 24;

  @override
  Future<Map<String, List<Map<String, Object?>>>> readTables({
    required bool includeCycleAndWellbeing,
  }) async {
    askedForCycleAndWellbeing = includeCycleAndWellbeing;
    // Deliberately untyped: the controller catches `on Object`, and the
    // point of these tests is that anything at all coming out of the
    // layers below turns into a static user message.
    // ignore: only_throw_errors
    if (failure != null) throw failure!;
    return {
      'weight_logs': [
        {'id': 'weight-1', 'weight_kg': 63.2},
      ],
      if (includeCycleAndWellbeing)
        'cycle_records': [
          {'id': 'cycle-1'},
        ],
    };
  }
}

/// Records what the save dialog was handed and answers with [location]
/// (`null` standing in for the user dismissing it), or throws [failure].
class _RecordingSaver {
  _RecordingSaver({this.location, this.failure});

  final Uri? location;
  final Object? failure;

  int calls = 0;
  String? fileName;
  Uint8List? bytes;
  String? mimeType;

  Future<Uri?> save({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    calls++;
    this.fileName = fileName;
    this.bytes = bytes;
    this.mimeType = mimeType;
    // Same reasoning as _FakeSource above.
    // ignore: only_throw_errors
    if (failure != null) throw failure!;
    return location;
  }
}

void main() {
  late _FakeSource source;
  late ProviderContainer container;

  void build({Object? failure}) {
    source = _FakeSource(failure: failure);
    container = ProviderContainer(
      overrides: [
        dataExportSourceProvider.overrideWithValue(source),
        // The production service encodes on a background isolate. These
        // tests are about the controller's branch table, so they encode
        // inline instead - `data_export_service_test.dart` is where the
        // isolate hop is checked.
        dataExportServiceProvider.overrideWith(
          (ref) => DataExportService(
            source: ref.watch(dataExportSourceProvider),
            encode: (json) async => encodeDataExportJson(json),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    // The controller is autoDispose; without a live listener it is torn down
    // between `read`s, `ref.mounted` is false by the time `export` finishes,
    // and the published-state assertions below would be testing a fresh
    // notifier rather than the one that ran. In the app the listener is real:
    // `DataExportTile` watches this provider (see
    // `test/features/settings/data_export_tile_test.dart`).
    container.listen(dataExportControllerProvider, (_, _) {});
  }

  DataExportController controller() =>
      container.read(dataExportControllerProvider.notifier);

  test('starts idle', () {
    build();
    expect(container.read(dataExportControllerProvider), isA<DataExportIdle>());
  });

  test('a saved file reports its name and summary, and publishes it', () async {
    build();
    final saver = _RecordingSaver(location: Uri.parse('file:///out.json'));

    final state = await controller().export(
      includeCycleAndWellbeing: false,
      saver: saver.save,
    );

    expect(state, isA<DataExportSaved>());
    final saved = state as DataExportSaved;
    expect(saved.filename, startsWith('femfit-export-'));
    expect(saved.filename, endsWith('.json'));
    expect(saved.summary.tableCount, 1);
    expect(saved.summary.rowCount, 1);
    expect(container.read(dataExportControllerProvider), same(state));
  });

  test(
    'the save dialog is handed JSON bytes under the right mime type',
    () async {
      build();
      final saver = _RecordingSaver(location: Uri.parse('file:///out.json'));

      await controller().export(
        includeCycleAndWellbeing: false,
        saver: saver.save,
      );

      expect(saver.calls, 1);
      expect(saver.mimeType, 'application/json');
      expect(saver.fileName, endsWith('.json'));
      final decoded =
          jsonDecode(utf8.decode(saver.bytes!)) as Map<String, Object?>;
      expect(decoded['format'], 'femfit-export');
    },
  );

  test('the checkbox answer reaches the source, both ways round', () async {
    build();
    await controller().export(
      includeCycleAndWellbeing: false,
      saver: _RecordingSaver(location: Uri.parse('file:///a.json')).save,
    );
    expect(source.askedForCycleAndWellbeing, isFalse);

    build();
    await controller().export(
      includeCycleAndWellbeing: true,
      saver: _RecordingSaver(location: Uri.parse('file:///b.json')).save,
    );
    expect(source.askedForCycleAndWellbeing, isTrue);
  });

  test('a dismissed save dialog is cancelled, not a failure', () async {
    build();
    final saver = _RecordingSaver();

    final state = await controller().export(
      includeCycleAndWellbeing: false,
      saver: saver.save,
    );

    expect(state, isA<DataExportCancelled>());
    expect(saver.calls, 1);
  });

  test(
    'a throwing saver fails with a static message carrying no data',
    () async {
      build();
      final saver = _RecordingSaver(
        failure: StateError('disk full at C:/Users/jordan/femfit-export.json'),
      );

      final state = await controller().export(
        includeCycleAndWellbeing: false,
        saver: saver.save,
      );

      expect(state, isA<DataExportFailed>());
      final failed = state as DataExportFailed;
      expect(failed.userMessage, 'Something went wrong. Please try again.');
      // The point of routing through `userMessageFor`: whatever the underlying
      // error said — a path, a table name, a row — cannot reach the SnackBar,
      // and from there a log.
      expect(failed.userMessage, isNot(contains('jordan')));
      expect(failed.userMessage, isNot(contains('disk full')));
    },
  );

  test('a failing read never reaches the save dialog', () async {
    build(failure: const StorageException(message: 'read failed'));
    final saver = _RecordingSaver(location: Uri.parse('file:///out.json'));

    final state = await controller().export(
      includeCycleAndWellbeing: false,
      saver: saver.save,
    );

    expect(state, isA<DataExportFailed>());
    expect(
      (state as DataExportFailed).userMessage,
      'Something went wrong saving your data. Please try again.',
    );
    expect(saver.calls, 0);
    expect(
      container.read(dataExportControllerProvider),
      isA<DataExportFailed>(),
    );
  });

  test(
    'an export in flight publishes in-progress before it finishes',
    () async {
      build();
      final gate = Completer<Uri?>();
      var calls = 0;

      final first = controller().export(
        includeCycleAndWellbeing: false,
        saver: ({required fileName, required bytes, required mimeType}) {
          calls++;
          return gate.future;
        },
      );
      await pumpEventQueue();

      expect(
        container.read(dataExportControllerProvider),
        isA<DataExportInProgress>(),
      );

      // A second tap while the first is still going is ignored, not queued:
      // two whole-database reads racing each other, and two save dialogs, is
      // nobody's idea of an export.
      final second = await controller().export(includeCycleAndWellbeing: false);
      expect(second, isA<DataExportInProgress>());
      expect(calls, 1);

      gate.complete(Uri.parse('file:///out.json'));
      expect(await first, isA<DataExportSaved>());
      expect(calls, 1);
    },
  );

  test(
    'a read failure says nothing was changed, not that a save failed',
    () async {
      // The exporter's own key: "saving your data" would be a small lie about
      // a failure that saved nothing (`core/errors/error_messages.dart`).
      build(
        failure: const StorageException(
          message: 'Failed to read local data for export',
          userMessageKey: 'error.exportRead',
        ),
      );

      final state = await controller().export(includeCycleAndWellbeing: false);

      expect(
        (state as DataExportFailed).userMessage,
        'Something went wrong reading your data for the export. Nothing was '
        'changed. Please try again.',
      );
    },
  );
}
