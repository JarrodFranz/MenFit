import 'package:flutter/material.dart';
import 'package:menfit_app/features/accessibility/domain/accessibility_preferences.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';

/// The resolved crest colours for one [BadgeTier].
///
/// A style *class* rather than raw colours inside the widgets, for the same
/// reason as `core/widgets/share_card_style.dart`: the trophy case, the
/// new-badge celebration and the post-workout strip all draw the same
/// emblem, and three copies of a metal gradient drift apart. The
/// `coding_standards.md` ban on `Color(0x...)` is a ban on raw colours in
/// *feature widgets* — this is the one file the palette lives in, and every
/// widget reads it from here.
///
/// ## Colour is never the only channel
///
/// Bronze and Gold are two warm metals, and to a red-blind eye they can be
/// the same colour. That is acceptable here **only because the tier's name
/// is rendered as text beside every emblem that uses this style** — the
/// colour is decoration on top of a label, never the label itself. On top
/// of that, [BadgeTierStyle.forTier] switches to a monotonic lightness ramp
/// whenever a colour-blindness mode is on, so the rungs stay ordered even
/// when the hues collapse, and thickens the rim under high contrast.
///
/// Both ramps are defined separately for light and dark: a metal that reads
/// as "silver" on white is a grey smudge on near-black.
@immutable
class BadgeTierStyle {
  const BadgeTierStyle({
    required this.begin,
    required this.end,
    required this.foreground,
    required this.rimWidth,
  });

  /// The crest colours for [tier].
  ///
  /// Every Diamond level shares the Diamond crest — the ladder is
  /// open-ended, so a per-level colour would have to invent a hundred of
  /// them, and the level is already spelled out in [BadgeTier.label]
  /// ("Diamond II").
  factory BadgeTierStyle.forTier(
    BadgeTier tier, {
    required Brightness brightness,
    ColorBlindnessMode colorBlindness = ColorBlindnessMode.none,
    bool highContrast = false,
  }) {
    final index = tier.rank.clamp(0, _lightMetals.length - 1);
    final isDark = brightness == Brightness.dark;
    final ramp = switch (colorBlindness) {
      ColorBlindnessMode.none => isDark ? _darkMetals : _lightMetals,
      _ => isDark ? _darkAccessible : _lightAccessible,
    };
    final (begin, end) = ramp[index];
    return BadgeTierStyle(
      begin: begin,
      end: end,
      foreground: Colors.white,
      rimWidth: highContrast ? 2.5 : 0,
    );
  }

  final Color begin;
  final Color end;

  /// The colour of the emblem's icon. White on every crest in both ramps —
  /// each gradient ends dark enough to carry it.
  final Color foreground;

  /// Width of the ring drawn around the crest. Non-zero only under high
  /// contrast, where a shape needs an edge and not just a fill.
  final double rimWidth;

  /// The crest as a gradient, top-left to bottom-right — the same
  /// direction the workout celebration's icon badge uses, so the two read
  /// as one visual family.
  LinearGradient get gradient => LinearGradient(
    colors: [begin, end],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Bronze, Silver, Gold, Platinum, Diamond — in [BadgeTier.rank] order.
  //
  // Silver and Platinum are deliberately pulled apart (neutral grey vs
  // cool slate-blue): two blue-greys next to each other on a ladder are
  // indistinguishable at emblem size.
  static const List<(Color, Color)> _lightMetals = [
    (Color(0xFFCE8A4F), Color(0xFF8A4B21)), // Bronze
    (Color(0xFFC3CBD3), Color(0xFF6B7683)), // Silver
    (Color(0xFFF0C020), Color(0xFFB07908)), // Gold
    (Color(0xFF8FA6C6), Color(0xFF3E5675)), // Platinum
    (Color(0xFF6ED8F0), Color(0xFF2F62C6)), // Diamond
  ];

  static const List<(Color, Color)> _darkMetals = [
    (Color(0xFFE0A472), Color(0xFFA96031)), // Bronze
    (Color(0xFFDCE3EA), Color(0xFF8A94A1)), // Silver
    (Color(0xFFFFD65C), Color(0xFFC98F12)), // Gold
    (Color(0xFFB3C6E0), Color(0xFF5A749B)), // Platinum
    (Color(0xFF9AE9FA), Color(0xFF4B84E0)), // Diamond
  ];

  // The colour-blind-safe ramp: one hue, five steps of steadily rising
  // darkness, so the ordering survives every mode including monochromacy
  // (which flattens all of these to five distinct greys).
  static const List<(Color, Color)> _lightAccessible = [
    (Color(0xFFD3D8E4), Color(0xFF9AA3B8)),
    (Color(0xFFB0BAD6), Color(0xFF7A87A8)),
    (Color(0xFF8B9AC8), Color(0xFF5A6A96)),
    (Color(0xFF64769F), Color(0xFF3C4A6E)),
    (Color(0xFF3E4C70), Color(0xFF1F2842)),
  ];

  static const List<(Color, Color)> _darkAccessible = [
    (Color(0xFF4A5570), Color(0xFF2E3548)),
    (Color(0xFF66738F), Color(0xFF424D66)),
    (Color(0xFF8794AF), Color(0xFF5D6A85)),
    (Color(0xFFAAB6CE), Color(0xFF7C88A3)),
    (Color(0xFFD2DBEC), Color(0xFF9EA9C2)),
  ];
}
