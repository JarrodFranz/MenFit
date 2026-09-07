import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Renders the [RepaintBoundary] carrying [boundaryKey] to PNG bytes.
///
/// Returns `null` — never throws — when the boundary is not in the tree,
/// has not been laid out, or the raster fails: a share card that cannot be
/// captured must degrade to sharing the text, not blow up a tap handler.
///
/// [pixelRatio] 3 gives a story card (220x390 logical) roughly 660x1170
/// px, which is what a social app wants and small enough to hand around
/// in memory.
///
/// **Web callers:** `navigator.share()` needs transient user activation,
/// which an `await` inside the tap handler consumes. Capture *before* the
/// tap (a post-frame callback when the card changes) and pass the bytes
/// straight to the adapter; awaiting this from inside the handler still
/// works everywhere else, and on the web degrades to the browser's
/// download fallback rather than failing.
Future<Uint8List?> captureCardPng(
  GlobalKey boundaryKey, {
  double pixelRatio = 3,
}) async {
  var boundary = _boundaryOf(boundaryKey);
  if (boundary == null) return null;

  // `toImage` on a boundary that has never painted throws in debug and
  // hands back a blank image in release. Waiting one frame is the only
  // fix, and it is only ever needed on the first capture — hence the
  // debug-only probe rather than an unconditional frame wait, which
  // inside a post-frame callback would queue onto the *next* frame and
  // stall a widget test that has stopped pumping.
  if (_needsPaint(boundary)) {
    await WidgetsBinding.instance.endOfFrame;
    boundary = _boundaryOf(boundaryKey);
    if (boundary == null) return null;
  }

  try {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  } on Object catch (_) {
    return null;
  }
}

/// The global rect of the widget behind [context], for
/// `SharingAdapter.shareText`/`shareImage`'s `sharePositionOrigin`.
///
/// On iPad and macOS the share sheet is a popover that anchors to this
/// rect; passing the tapped button's own rect is what makes it point at
/// the button instead of the middle of the screen. `null` elsewhere is
/// harmless — every other platform ignores it.
Rect? shareOriginOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

RenderRepaintBoundary? _boundaryOf(GlobalKey key) {
  final object = key.currentContext?.findRenderObject();
  if (object is! RenderRepaintBoundary || !object.hasSize) return null;
  return object;
}

bool _needsPaint(RenderRepaintBoundary boundary) {
  // `debugNeedsPaint` is debug-only (it reads a `late` field that is
  // never initialised in release), so it is read inside an assert.
  var needsPaint = false;
  assert(() {
    needsPaint = boundary.debugNeedsPaint;
    return true;
  }(), 'debugNeedsPaint probe');
  return needsPaint;
}
