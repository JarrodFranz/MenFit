import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/card_shape.dart';
import 'package:menfit_app/core/theme/tokens.dart';

/// The shared chrome every card on the home dashboard wears: the themed
/// card shape, a tinted leading icon, a title row, and — when the card
/// goes somewhere — one tap target covering the whole card.
///
/// One widget rather than six near-identical `Card`s so the dashboard reads
/// as one surface, and so the two things that are easy to lose in a
/// redesign are held in a single place:
///
/// * [themedCardShape], which keeps the High Contrast outline a bare
///   `Card.shape` override would silently drop
///   (`core/theme/card_shape.dart`);
/// * the tap semantics. A tappable card announces itself as a **button**
///   with a label that says where it goes, and its contents stay their own
///   nodes underneath (`container`, never `excludeSemantics`) so a screen
///   reader can still read the numbers on it.
class HomeCard extends StatelessWidget {
  const HomeCard({
    required this.icon,
    required this.title,
    required this.child,
    this.onTap,
    this.semanticsLabel,
    super.key,
  });

  final IconData icon;
  final String title;

  /// The card's body, under the title row.
  final Widget child;

  /// Where the card goes. `null` for a card that only reports.
  final VoidCallback? onTap;

  /// What a screen reader announces for the whole card — say where tapping
  /// leads, not what the card contains. Required in practice whenever
  /// [onTap] is set.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    final content = Padding(
      padding: EdgeInsets.all(tokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _HomeCardTitle(icon: icon, title: title),
          SizedBox(height: tokens.spacingSm),
          child,
        ],
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      shape: themedCardShape(context, radius: tokens.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : Semantics(
              button: true,
              label: semanticsLabel,
              container: true,
              child: InkWell(
                onTap: onTap,
                // The card is always far taller than this; the floor is
                // here so a future empty state can never shrink the target
                // below the platform minimum.
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: content,
                ),
              ),
            ),
    );
  }
}

class _HomeCardTitle extends StatelessWidget {
  const _HomeCardTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            // Two lines: at 150% text scale on a 320dp phone a two-column
            // layout is not in play, but a single column still leaves a
            // title like "Recent achievement" wider than the card. It
            // breaks at a space, never mid-word.
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
