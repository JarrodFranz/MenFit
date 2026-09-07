import 'package:flutter/material.dart';

// The one place the Wellbeing tab's three record types are given a shape.
//
// The calendar's day markers, its legend, the day detail sheet and the
// history list all draw from here so that a symbol means the same thing
// everywhere in the tab: a user who learns the flame on a card must not
// have to learn a second flame on the grid.
//
// **Glyph first, colour second** (`knowledge/engineering/accessibility.md`
// — the cycle calendar's colour-only day dots are the mistake this exists
// not to repeat): each record type has a distinct icon, and the colours
// below only ever accompany it. Nothing in the app may encode one of these
// three facts in colour alone.

/// A logged daily check-in. Coloured with `ColorScheme.primary` at the call
/// site, so it has no constant here.
const IconData checkinGlyph = Icons.self_improvement;

/// A logged flare-up.
const IconData flareGlyph = Icons.local_fire_department;

/// A day marked as protected recovery.
const IconData recoveryGlyph = Icons.shield;

/// The flare-up red. A literal rather than an `AppTokens` role because
/// these are the exact values the history cards have always drawn and this
/// file is a consolidation of them, not a re-decision — promoting them to
/// semantic theme roles is a design-system change, not a calendar one.
const Color flareGlyphColor = Color(0xFFDC2626);

/// The protected-recovery violet. Same reasoning as [flareGlyphColor].
const Color recoveryGlyphColor = Color(0xFF7C3AED);

/// The flare-up glyph's tinted circular backdrop on a card.
Color flareGlyphBackground({required bool isDark}) =>
    isDark ? const Color(0x33DC2626) : const Color(0xFFFEE2E2);

/// The recovery glyph's tinted circular backdrop on a card.
Color recoveryGlyphBackground({required bool isDark}) =>
    isDark ? const Color(0x337C3AED) : const Color(0xFFEDE9FE);

/// A logged intimacy event.
const IconData intimacyGlyph = Icons.favorite;
const Color intimacyGlyphColor = Color(0xFFE11D48);

/// A logged injury event.
const IconData injuryGlyph = Icons.healing;
const Color injuryGlyphColor = Color(0xFFD97706);

/// A logged holiday event.
const IconData holidayGlyph = Icons.beach_access;
const Color holidayGlyphColor = Color(0xFF0D9488);

/// A logged other / custom event.
const IconData otherEventGlyph = Icons.star_rounded;
const Color otherEventGlyphColor = Color(0xFF8B5CF6);
