import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/widgets/app_bottom_sheet.dart';

/// `showAppBottomSheet` is the app's only door to `showModalBottomSheet`
/// (guarded by `test/app/modal_sheets_use_root_navigator_test.dart`), so
/// the bottom inset is right here or it is wrong everywhere.
///
/// The bug this pins: Android draws edge-to-edge, and Flutter's
/// `useSafeArea: true` only guards the *top*. Nothing padded the bottom,
/// so the last row of a sheet sat underneath the 3-button system
/// navigation bar - reported on device 2026-09-03 against the Wellbeing
/// day sheet's "Mark as a recovery day".
///
/// The insets are injected through `MaterialApp.builder` rather than
/// `tester.view`, on purpose: `builder` sits *above* the Navigator, so a
/// pushed route sees them (a `MediaQuery` around `home:` would not), and
/// leaving `padding` at zero while `viewPadding` is 48 proves the wrapper
/// reads `viewPadding` - the one that survives the keyboard - rather than
/// `padding`.
void main() {
  const screen = Size(400, 800);
  const navBar = 48.0;
  const keyboard = 300.0;
  const lastChildKey = Key('sheetLastChild');

  setUp(() {
    // Keep logical pixels == the numbers in these tests.
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.implicitView!
          ..physicalSize = screen
          ..devicePixelRatio = 1;
    addTearDown(() {
      view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
  });

  Future<void> pumpSheet(
    WidgetTester tester, {
    required MediaQueryData mediaQuery,
    required Widget sheetChild,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            MediaQuery(data: mediaQuery, child: child!),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAppBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => sheetChild,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Widget shortSheet() => const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(height: 80, child: Center(child: Text('body'))),
      SizedBox(
        key: lastChildKey,
        height: 48,
        width: double.infinity,
        child: Center(child: Text('last action')),
      ),
    ],
  );

  testWidgets('the system navigation bar inset is left clear below the '
      "sheet's last child", (tester) async {
    await pumpSheet(
      tester,
      mediaQuery: const MediaQueryData(
        size: screen,
        viewPadding: EdgeInsets.only(bottom: navBar),
      ),
      sheetChild: shortSheet(),
    );

    expect(
      tester.getRect(find.byKey(lastChildKey)).bottom,
      lessThanOrEqualTo(screen.height - navBar),
      reason: 'the last action would be under the system navigation bar',
    );
  });

  testWidgets('with the keyboard up the sheet clears the keyboard, not the '
      'nav bar as well', (tester) async {
    await pumpSheet(
      tester,
      mediaQuery: const MediaQueryData(
        size: screen,
        viewPadding: EdgeInsets.only(bottom: navBar),
        viewInsets: EdgeInsets.only(bottom: keyboard),
      ),
      sheetChild: shortSheet(),
    );

    final bottom = tester.getRect(find.byKey(lastChildKey)).bottom;
    expect(
      bottom,
      lessThanOrEqualTo(screen.height - keyboard),
      reason: 'the last action would be hidden behind the keyboard',
    );
    // The nav bar is drawn *over* the IME, so the keyboard inset alone is
    // the right clearance - stacking both would waste 48dp of a sheet
    // that is already fighting the keyboard for room.
    expect(
      bottom,
      greaterThan(screen.height - keyboard - navBar),
      reason: 'the two insets are being added together instead of maxed',
    );
  });

  testWidgets('a scrolling sheet can scroll its last child above the nav '
      'bar', (tester) async {
    await pumpSheet(
      tester,
      mediaQuery: const MediaQueryData(
        size: screen,
        viewPadding: EdgeInsets.only(bottom: navBar),
      ),
      sheetChild: SizedBox(
        height: screen.height,
        child: ListView(
          children: [
            for (var i = 0; i < 20; i++)
              SizedBox(height: 60, child: Center(child: Text('row $i'))),
            const SizedBox(
              key: lastChildKey,
              height: 48,
              width: double.infinity,
              child: Center(child: Text('last action')),
            ),
          ],
        ),
      ),
    );

    await tester.drag(find.text('row 5'), const Offset(0, -2000));
    await tester.pumpAndSettle();

    final rect = tester.getRect(find.byKey(lastChildKey));
    expect(
      rect.bottom,
      lessThanOrEqualTo(screen.height - navBar),
      reason: 'scrolled to the end, the last row still sits under the bar',
    );
    expect(
      rect.bottom,
      greaterThan(screen.height - navBar - 60),
      reason: 'the last row should be reachable at the end of the scroll',
    );
  });

  testWidgets('a nested SafeArea does not add the inset a second time', (
    tester,
  ) async {
    await pumpSheet(
      tester,
      mediaQuery: const MediaQueryData(
        size: screen,
        padding: EdgeInsets.only(bottom: navBar),
        viewPadding: EdgeInsets.only(bottom: navBar),
      ),
      sheetChild: SafeArea(top: false, child: shortSheet()),
    );

    expect(
      tester.getRect(find.byKey(lastChildKey)).bottom,
      screen.height - navBar,
      reason:
          'a sheet that still wraps itself in SafeArea would be pushed '
          'up by 2 * $navBar',
    );
  });
}
