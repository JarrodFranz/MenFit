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
  /// Signature deep orchid/plum gradient with radiant lilac accents.
  signatureOrchid,

  /// High-contrast obsidian dark with gold PR accents.
  obsidianDark,

  /// Clean, modern crisp light card with soft floral accents.
  cleanLight,
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
      ShareCardTheme.signatureOrchid => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A1A4E), Color(0xFF1E0A21)],
        ),
      ),
      ShareCardTheme.obsidianDark => const BoxDecoration(
        color: Color(0xFF121216),
      ),
      ShareCardTheme.cleanLight => BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2DCE6), width: 1.5),
      ),
    };

    final isLight = theme == ShareCardTheme.cleanLight;
    final textColor = isLight ? const Color(0xFF1E1622) : Colors.white;
    final subtextColor = isLight
        ? const Color(0xFF6B5E70)
        : Colors.white.withValues(alpha: 0.75);
    final accentColor = isLight
        ? const Color(0xFF8F4C86)
        : const Color(0xFFE879F9);

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
