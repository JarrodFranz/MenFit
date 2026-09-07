import 'package:flutter/material.dart';

/// Card format / aspect ratio for a shareable achievement card.
///
/// Shared kernel (`architecture_overview.md`): both
/// `features/activity/presentation/widgets/workout_share_dialog.dart` (Wave
/// 2) and `features/recaps/presentation/widgets/recap_share_sheet.dart`
/// (Wave 3) render a shareable card and must look like the same visual
/// system, so the ratio/theme vocabulary and the theme-to-colors mapping
/// live here rather than in either feature's `presentation/` — a feature
/// may only reach another feature's `domain/` or composition surface
/// (ADR 007's rule 2), never its `presentation/`.
enum ShareCardRatio {
  /// 9:16 vertical story format (Instagram / TikTok / WhatsApp Status).
  story,

  /// 1:1 square format (Strava activity photo / Instagram Feed).
  square,
}

/// Visual theme presets for a shareable achievement card.
enum ShareCardTheme {
  /// Signature Forge card: charcoal ground with a burnt-orange accent.
  forgeDark,

  /// Forge in daylight: warm off-white ground with a burnt-orange accent.
  forgeLight,

  /// Neutral white card with a near-black accent, for feeds that already
  /// carry a lot of colour.
  clean,
}

/// The resolved colors/decoration for one [ShareCardTheme] — extracted
/// from `WorkoutShareDialog._buildCardPreview` (Wave 2) unchanged, so every
/// existing card keeps rendering byte-for-byte identically after this
/// extraction.
@immutable
class ShareCardStyle {
  const ShareCardStyle({
    required this.backgroundDecoration,
    required this.textColor,
    required this.subtextColor,
    required this.accentColor,
  });

  factory ShareCardStyle.forTheme(ShareCardTheme theme) {
    final backgroundDecoration = switch (theme) {
      ShareCardTheme.forgeDark => const BoxDecoration(
        color: Color(0xFF121212),
      ),
      ShareCardTheme.forgeLight => BoxDecoration(
        color: const Color(0xFFFAF8F5),
        border: Border.all(color: const Color(0xFFE4DED6), width: 1.5),
      ),
      ShareCardTheme.clean => BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFFE3E3E3), width: 1.5),
      ),
    };

    final isLight = theme != ShareCardTheme.forgeDark;
    final textColor = isLight ? const Color(0xFF1B1B1B) : Colors.white;
    final subtextColor = isLight
        ? const Color(0xFF605C57)
        : Colors.white.withValues(alpha: 0.75);
    final accentColor = switch (theme) {
      ShareCardTheme.forgeDark => const Color(0xFFFF6D3A),
      ShareCardTheme.forgeLight => const Color(0xFFD84A1B),
      ShareCardTheme.clean => const Color(0xFF1B1B1B),
    };

    return ShareCardStyle(
      backgroundDecoration: backgroundDecoration,
      textColor: textColor,
      subtextColor: subtextColor,
      accentColor: accentColor,
    );
  }

  final BoxDecoration backgroundDecoration;
  final Color textColor;
  final Color subtextColor;
  final Color accentColor;
}
