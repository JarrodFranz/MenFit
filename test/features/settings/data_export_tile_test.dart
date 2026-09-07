import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/data_export/data_export_widgets.dart';
import 'package:menfit_app/features/settings/presentation/widgets/data_export_tile.dart';

/// Stands in for the real controller so the tile can be driven without a
/// database or a native save dialog. It publishes the same states in the
/// same order the real one does, held open on [gate] so the in-progress
/// frame can actually be looked at.
class _StubController extends DataExportController {
  _StubController(this.gate);

  final Completer<DataExportState> gate;

  int calls = 0;
  bool? askedForCycleAndWellbeing;

  @override
  DataExportState build() => const DataExportIdle();

  @override
  Future<DataExportState> export({
    required bool includeSensitiveHealth,
    DataExportFileSaver? saver,
  }) async {
    calls++;
    askedForCycleAndWellbeing = includeSensitiveHealth;
    state = const DataExportInProgress();
    final result = await gate.future;
    state = result;
    return result;
  }
}

void main() {
  late _StubController stub;
  late Completer<DataExportState> gate;

  Future<void> pumpTile(WidgetTester tester) async {
    gate = Completer<DataExportState>();
    stub = _StubController(gate);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dataExportControllerProvider.overrideWith(() => stub)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: Column(children: [DataExportTile()]),
          ),
        ),
      ),
    );
  }

  Future<void> accept(WidgetTester tester) async {
    await tester.tap(find.text('Export my data'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dataExportNoticeAccept')));
    // Fixed pumps, not pumpAndSettle: the progress indicator this is here
    // to see never stops animating, and settle would spin until it timed
    // out. Long enough for the dialog route to finish popping.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Found by its title rather than by type: while the notice dialog is
  /// animating away its `CheckboxListTile` has a `ListTile` inside it.
  ListTile tile(WidgetTester tester) => tester.widget<ListTile>(
    find.widgetWithText(ListTile, 'Export my data'),
  );

  testWidgets('at rest it offers the export and says what it does', (
    tester,
  ) async {
    await pumpTile(tester);

    expect(find.text('Export my data'), findsOneWidget);
    // Honest scope: the notice dialog is where "everything you've logged"
    // is spelled out, opt-in included.
    expect(
      find.text("Save a copy of what you've logged as a file"),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tile(tester).enabled, isTrue);
  });

  testWidgets('an export in flight is visible on the tile', (tester) async {
    await pumpTile(tester);

    await accept(tester);

    // The reason the tile watches the controller rather than only reading
    // its notifier: an autoDispose notifier with no listener is torn down
    // the moment `read` returns, and this frame never happens.
    expect(find.text('Preparing your file…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tile(tester).enabled, isFalse);
    expect(tile(tester).onTap, isNull);

    gate.complete(
      const DataExportSaved(
        filename: 'menfit-export-2026-09-04.json',
        summary: DataExportSummary(tableCount: 3, rowCount: 9),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Saved menfit-export-2026-09-04.json'), findsOneWidget);
    expect(tile(tester).enabled, isTrue);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a second tap while it is running starts nothing', (
    tester,
  ) async {
    await pumpTile(tester);
    await accept(tester);

    await tester.tap(find.text('Export my data'), warnIfMissed: false);
    await tester.pump();

    expect(stub.calls, 1);
    // No second notice dialog either.
    expect(find.byKey(const Key('dataExportNoticeAccept')), findsNothing);

    gate.complete(const DataExportCancelled());
    await tester.pumpAndSettle();
  });

  testWidgets('declining the notice never reaches the controller', (
    tester,
  ) async {
    await pumpTile(tester);

    await tester.tap(find.text('Export my data'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dataExportNoticeDecline')));
    await tester.pumpAndSettle();

    expect(stub.calls, 0);
    expect(tile(tester).enabled, isTrue);
  });

  testWidgets('a failure shows its message and re-enables the tile', (
    tester,
  ) async {
    await pumpTile(tester);
    await accept(tester);

    gate.complete(const DataExportFailed('Something went wrong.'));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong.'), findsOneWidget);
    expect(tile(tester).enabled, isTrue);
  });

  testWidgets('the checkbox answer is carried to the controller', (
    tester,
  ) async {
    await pumpTile(tester);

    await tester.tap(find.text('Export my data'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('dataExportIncludeSensitiveHealth')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('dataExportIncludeSensitiveHealth')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('dataExportNoticeAccept')));
    await tester.pump();

    expect(stub.askedForCycleAndWellbeing, isTrue);

    gate.complete(const DataExportCancelled());
    await tester.pumpAndSettle();
  });
}
