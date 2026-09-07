import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The one way this app opens a modal bottom sheet.
///
/// Two things are wrong with a bare `showModalBottomSheet` here and both
/// are invisible in a test that does not model the device:
///
/// 1. **The navigator.** Shell tabs live in a `StatefulShellRoute`, so the
///    default `useRootNavigator: false` opens the sheet on the *branch*
///    navigator: clipped above the `NavigationBar`, tabs still tappable
///    under the scrim, and left behind in the other branch's stack when
///    the tab changes.
/// 2. **The system navigation bar.** Android is edge-to-edge (mandatory
///    from Android 15), so the app draws underneath the 3-button nav bar.
///    The shell's `NavigationBar` insets itself; a bottom sheet does not,
///    and `useSafeArea: true` only guards the *top*
///    (`SafeArea(bottom: false)` in `ModalBottomSheetRoute.buildPage`).
///    Reported 2026-09-03: the Wellbeing day sheet's "Mark as a recovery
///    day" row sat underneath the nav bar.
///
/// So every sheet goes through here and the bottom inset is applied
/// exactly once, in [AppBottomSheetInsets]. Sheets must not add their own
/// `SafeArea` or `viewInsets` padding — `MediaQuery.removePadding` below
/// makes a stray `SafeArea` a no-op rather than a double gap, but the
/// duplicate padding is still dead code worth deleting.
///
/// `test/app/modal_sheets_use_root_navigator_test.dart` scans `lib/` and
/// fails on any direct `showModalBottomSheet` call outside this file.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool? showDragHandle,
  ShapeBorder? shape,
  Color? backgroundColor,
  BoxConstraints? constraints,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    // Always: see (1) above.
    useRootNavigator: true,
    // Keeps a tall sheet below the status bar. Does nothing for the
    // bottom - that is [AppBottomSheetInsets]' job.
    useSafeArea: true,
    isScrollControlled: isScrollControlled,
    showDragHandle: showDragHandle,
    shape: shape,
    backgroundColor: backgroundColor,
    constraints: constraints,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (sheetContext) =>
        AppBottomSheetInsets(child: builder(sheetContext)),
  );
}

/// Holds a bottom sheet's content clear of the system navigation bar and
/// of the software keyboard.
///
/// The gap is `max(viewPadding.bottom, viewInsets.bottom)`:
///
/// * no keyboard - `viewPadding.bottom` is the nav bar / home indicator;
/// * keyboard up - it covers the nav bar (the bar is drawn *over* the
///   IME), so the keyboard inset alone is the correct clearance.
///
/// `viewPadding` rather than `padding` on purpose: `padding` is already
/// net of `viewInsets`, so it collapses to zero while the keyboard is up
/// and cannot be read as "the nav bar is N tall".
///
/// The padding sits *outside* the child, so a child that scrolls gets a
/// shorter viewport and its last row scrolls to rest above the bar rather
/// than under it.
class AppBottomSheetInsets extends StatelessWidget {
  const AppBottomSheetInsets({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottom = math.max(
      mediaQuery.viewPadding.bottom,
      mediaQuery.viewInsets.bottom,
    );
    return MediaQuery.removePadding(
      context: context,
      // Consumed here, so a nested `SafeArea` cannot add it a second time.
      removeBottom: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: child,
      ),
    );
  }
}
