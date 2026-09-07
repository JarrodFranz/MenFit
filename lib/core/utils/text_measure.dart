/// Layout-time text measurement, for widgets that must *decide* their shape
/// from whether a string fits rather than discover afterwards that it did
/// not.
///
/// The alternative — a hard-coded "narrow enough" width — is wrong the
/// moment the user changes their text size, because a breakpoint measured
/// at 100% says nothing about the same label at 150%. Every function here
/// measures at the scale the caller's [BuildContext] is actually under, so
/// a layout decision made from one is correct at every setting.
///
/// Measurement is cheap (a single `TextPainter.layout` per string, no
/// widget tree) but not free: call it once per build from a `LayoutBuilder`
/// and reuse the answer, never per list item.
library;

import 'package:flutter/material.dart';

/// The width [text] occupies on a single unwrapped line, in logical pixels.
///
/// [scaler] defaults to the context's effective [TextScaler]. Pass one
/// explicitly when the widget being measured clamps scaling itself —
/// Material's `NavigationBar` label is the example: it renders inside
/// `MediaQuery.withClampedTextScaling`, so measuring it with the unclamped
/// scaler overstates it at large OS font sizes.
double measuredTextWidth(
  BuildContext context,
  String text, {
  required TextStyle? style,
  TextScaler? scaler,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: resolvedForMeasurement(context, style)),
    textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
    textScaler: scaler ?? MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

/// Whether every string in [texts] fits on one line inside [maxWidth].
///
/// Returns `false` for a non-positive [maxWidth]: nothing fits in no space,
/// and callers use this to pick a fallback layout.
bool textsFitOnOneLine(
  BuildContext context,
  Iterable<String> texts, {
  required TextStyle? style,
  required double maxWidth,
  TextScaler? scaler,
}) {
  if (maxWidth <= 0) return false;
  for (final text in texts) {
    final width = measuredTextWidth(
      context,
      text,
      style: style,
      scaler: scaler,
    );
    if (width > maxWidth) return false;
  }
  return true;
}

/// Fills in the fields a bare theme text style does not carry, the way
/// `Text` does when it renders one.
///
/// This app's font family is **not** on `textTheme.labelMedium` and
/// friends — those carry size, weight and colour only, and every `Text`
/// picks the family up by inheriting the enclosing `DefaultTextStyle`,
/// which inside any Material is `theme.textTheme.bodyMedium`. Measuring the
/// bare style therefore measures the platform's fallback font, which is
/// much wider than Inter: "Nutrition" comes out 108dp instead of 51dp, and
/// every fit test built on it would refuse layouts that fit fine.
///
/// `Theme.of(context)` is used rather than `DefaultTextStyle.of(context)`
/// on purpose: a widget that decides its own layout often sits *above* the
/// `Material` that would supply the inherited style (a shell scaffold above
/// its own `Scaffold`, a screen above its `AppBar`), where
/// `DefaultTextStyle` is still the framework's red-on-monospace debug
/// fallback. The theme is the same everywhere.
TextStyle resolvedForMeasurement(BuildContext context, TextStyle? style) {
  final inherited = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
  if (style == null) return inherited;
  return style.inherit ? inherited.merge(style) : style;
}
