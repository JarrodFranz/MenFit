import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';

/// Shared full-bleed layout for one `RecapStoryScreen` slide: an icon, a
/// headline, body content, and an optional small footnote — every concrete
/// slide in `recap_slides.dart` is built from this so the story reads as
/// one consistent visual rhythm rather than seven differently-laid-out
/// screens.
///
/// Text defaults to white — the story background is always a dark
/// gradient (`RecapStoryScreen` uses
/// `core/widgets/share_card_style.dart`'s `ShareCardTheme.forgeDark`,
/// the same immersive chrome Wave 2's share card and celebration dialog
/// already use for this kind of surface, rather than the app's normal
/// Material surface colors).
class RecapSlideScaffold extends StatelessWidget {
  const RecapSlideScaffold({
    required this.icon,
    required this.title,
    required this.body,
    this.footnote,
    super.key,
  });

  final IconData icon;
  final String title;
  final Widget body;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacingLg,
        vertical: tokens.spacingXl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: Colors.white),
          SizedBox(height: tokens.spacingLg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: tokens.spacingMd),
          DefaultTextStyle(
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
            child: body,
          ),
          if (footnote != null) ...[
            SizedBox(height: tokens.spacingLg),
            Text(
              footnote!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A single big stat line used inside several slides' [RecapSlideScaffold.body]
/// (e.g. "12.40 km", "3,450 kg").
class RecapBigStat extends StatelessWidget {
  const RecapBigStat({required this.value, required this.label, super.key});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
