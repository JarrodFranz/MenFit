import 'package:flutter/material.dart';

/// Builds a `Card.shape` override that changes the corner radius (and,
/// optionally, the outline colour) without silently dropping the outline
/// `AppTheme` puts on every card.
///
/// `AppTheme` (`core/theme/app_theme.dart`) sets `cardTheme.shape` to a
/// [RoundedRectangleBorder] whose `side` carries the accessibility-aware
/// outline: a faint 1px line in
/// light mode, transparent in dark mode, and — when High Contrast is on —
/// an opaque black (light) or white (dark) line at width 1.5. A `Card`
/// that sets its own `shape` replaces that [RoundedRectangleBorder]
/// wholesale, including the `side`, so any card that only wanted a
/// different radius (or a bespoke tint) would silently lose the outline.
/// That is invisible most of the time, but High Contrast is exactly the
/// case this guards: without it, a High-Contrast screen ends up with some
/// cards outlined and others not, which reads as broken next to the
/// neighbours that still go through the theme.
///
/// Pass [side] for a card that deliberately wants its own outline colour —
/// a tinted feature card, a selected/highlight state. It is honoured only
/// outside High Contrast: once High Contrast is on, the theme's side
/// always wins, because a faint or accent-coloured line is exactly what
/// High Contrast exists to replace, and the app has no separate "is HC on"
/// flag to check here — `AppTheme` signals it by giving its side a width
/// of 1.5, so that width is the tell this helper keys off. Omit [side]
/// (or pass `null`) to always take
/// the theme's current side — the plain "just wanted a different radius"
/// case.
///
/// Never changes the radius or colour a call site already chose outside
/// High Contrast; only changes what happens to the outline once High
/// Contrast is on.
ShapeBorder themedCardShape(
  BuildContext context, {
  required double radius,
  BorderSide? side,
}) {
  final themeSide =
      (Theme.of(context).cardTheme.shape as RoundedRectangleBorder?)?.side ??
      BorderSide.none;
  // AppTheme's high-contrast side is always width 1.5; the non-high-contrast
  // sides are 1.0 (light) or 0.0 (dark) — see app_theme.dart ~109 and ~193.
  final isHighContrast = themeSide.width >= 1.5;
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
    side: isHighContrast ? themeSide : (side ?? themeSide),
  );
}
