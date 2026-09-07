import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/data_export/domain/data_export_document.dart';
import 'package:menfit_app/features/data_export/presentation/data_import_notice_dialog.dart';

void main() {
  final testDocument = DataExportDocument(
    schemaVersion: 24,
    exportedAt: DateTime.utc(2026, 9, 4, 12),
    includesCycleAndWellbeingData: true,
    tables: {
      'weight_logs': [
        {'id': 'w-1', 'weight_kg': 60.0},
      ],
      'activities': [
        {'id': 'a-1', 'title': 'Run'},
      ],
    },
  );

  Future<Future<bool?> Function()> open(
    WidgetTester tester, {
    DataExportDocument? doc,
  }) async {
    bool? choice;
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  choice = await DataImportNoticeDialog.show(
                    context,
                    doc ?? testDocument,
                  );
                  completed = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    return () async {
      await tester.pumpAndSettle();
      expect(completed, isTrue, reason: 'the dialog never completed');
      return choice;
    };
  }

  testWidgets('renders document details accurately', (tester) async {
    await open(tester);

    expect(find.text('Restore from backup'), findsOneWidget);
    expect(
      find.textContaining('2 tables with 2 total records.'),
      findsOneWidget,
    );
    expect(find.text('Total records'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Cycle & Wellbeing'), findsOneWidget);
    expect(find.text('Included'), findsOneWidget);
  });

  testWidgets('"Cancel" rejects restore', (tester) async {
    final result = await open(tester);

    await tester.tap(find.byKey(const Key('dataImportNoticeCancel')));
    expect(await result(), isFalse);
  });

  testWidgets('dismissing by tapping outside rejects restore', (tester) async {
    final result = await open(tester);

    await tester.tapAt(const Offset(10, 10));
    expect(await result(), isNull);
  });

  testWidgets('"Restore data" accepts restore', (tester) async {
    final result = await open(tester);

    await tester.tap(find.byKey(const Key('dataImportNoticeConfirm')));
    expect(await result(), isTrue);
  });
}
