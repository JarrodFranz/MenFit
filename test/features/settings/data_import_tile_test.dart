import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/data_export/data_export_widgets.dart';
import 'package:menfit_app/features/settings/presentation/widgets/data_import_tile.dart';

class _StubImportController extends DataImportController {
  _StubImportController(this.gate);

  final Completer<DataImportState> gate;
  int calls = 0;

  @override
  DataImportState build() => const DataImportIdle();

  @override
  Future<DataImportState> importData({
    required DataImportConfirmDialog confirmDialog,
    DataImportFilePicker? filePicker,
  }) async {
    calls++;
    state = const DataImportInProgress();
    final result = await gate.future;
    state = result;
    return result;
  }
}

void main() {
  late _StubImportController stub;
  late Completer<DataImportState> gate;

  Future<void> pumpTile(WidgetTester tester) async {
    gate = Completer<DataImportState>();
    stub = _StubImportController(gate);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dataImportControllerProvider.overrideWith(() => stub)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: Column(children: [DataImportTile()]),
          ),
        ),
      ),
    );
  }

  testWidgets('renders title and subtitle when idle', (tester) async {
    await pumpTile(tester);

    expect(find.text('Import data from backup'), findsOneWidget);
    expect(
      find.text('Restore your data from a menfit-export file'),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows progress indicator while importing', (tester) async {
    await pumpTile(tester);

    await tester.tap(find.text('Import data from backup'));
    await tester.pump();

    expect(find.text('Restoring your backup…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    gate.complete(const DataImportAborted());
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows SnackBar on successful restore', (tester) async {
    await pumpTile(tester);

    await tester.tap(find.text('Import data from backup'));
    await tester.pump();

    gate.complete(
      const DataImportRestored(
        summary: DataExportSummary(tableCount: 3, rowCount: 15),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Successfully restored 15 records across 3 tables'),
      findsOneWidget,
    );
  });
}
