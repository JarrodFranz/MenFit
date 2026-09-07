import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/data_export/presentation/data_export_notice_dialog.dart';

void main() {
  Future<Future<DataExportChoice?> Function()> open(WidgetTester tester) async {
    DataExportChoice? choice;
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  choice = await DataExportNoticeDialog.show(context);
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

  testWidgets('the health check-in checkbox starts off', (tester) async {
    await open(tester);

    final checkbox = tester.widget<CheckboxListTile>(
      find.byKey(const Key('dataExportIncludeSensitiveHealth')),
    );
    expect(checkbox.value, isFalse);
  });

  testWidgets('"Not now" abandons the export', (tester) async {
    final result = await open(tester);

    await tester.tap(find.byKey(const Key('dataExportNoticeDecline')));
    expect(await result(), isNull);
  });

  testWidgets('dismissing by tapping outside abandons it too', (tester) async {
    final result = await open(tester);

    // A barrier tap is a way of saying no, and must not be read as a yes.
    await tester.tapAt(const Offset(10, 10));
    expect(await result(), isNull);
  });

  testWidgets('accepting without ticking excludes health data', (tester) async {
    final result = await open(tester);

    await tester.tap(find.byKey(const Key('dataExportNoticeAccept')));
    final choice = await result();

    expect(choice, isNotNull);
    expect(choice!.includeSensitiveHealth, isFalse);
  });

  testWidgets('ticking the box then accepting includes it', (tester) async {
    final result = await open(tester);

    // The dialog body scrolls; on a 600dp-tall surface the checkbox sits
    // below the fold, and a tap on an off-screen widget is a silent no-op.
    await tester.ensureVisible(
      find.byKey(const Key('dataExportIncludeSensitiveHealth')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('dataExportIncludeSensitiveHealth')),
    );
    await tester.pump();
    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(const Key('dataExportIncludeSensitiveHealth')),
          )
          .value,
      isTrue,
    );

    await tester.tap(find.byKey(const Key('dataExportNoticeAccept')));
    final choice = await result();

    expect(choice!.includeSensitiveHealth, isTrue);
  });

  testWidgets('the copy makes the four promises it has to', (tester) async {
    await open(tester);

    String textOf(Finder finder) =>
        tester.widgetList<Text>(finder).map((t) => t.data ?? '').join(' ');
    final body = textOf(find.byType(Text));

    // What is in the file.
    expect(body, contains('activities'));
    expect(body, contains('weight'));
    expect(body, contains('profile'));
    // Where it is made, and that nothing is sent anywhere.
    expect(body, contains('on this device'));
    expect(body, contains('Nothing is sent'));
    // The surprising part: soft-deleted rows are in there.
    expect(body, contains('deleted'));
    // The opt-in names what it covers, in the user's words rather than
    // table names.
    expect(body, contains('Daily check-ins'));
    expect(body, isNot(contains('daily_checkins')));
  });
}
