import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';

/// Lays the dashboard's cards out in one column, or in two when the caller
/// says there is room.
///
/// Two `Column`s side by side rather than a `GridView`: the cards are all
/// different heights (a ring, three macro bars, two lines of text) and a
/// grid would have to be told a single aspect ratio for all of them, which
/// is precisely the arrangement that overflowed the old dashboard grid the
/// moment the text scaled. Columns take each card's natural height instead,
/// so nothing here has a height that text scale can outgrow.
///
/// [twoColumn] is passed in rather than measured here on purpose. The
/// dashboard caps its content width at a comfortable reading width, and by
/// the time the constraint reaches this widget it has already been capped —
/// measuring it here would mean asking "is there room for two columns?"
/// of a box that was sized for one, and the answer would always be no. The
/// screen decides from the real window width and widens the cap to match
/// (see `home_screen.dart`).
///
/// Cards alternate between the two columns in order, so the reading order
/// left-to-right, top-to-bottom stays the order they were handed in — and
/// so does the traversal order a screen reader follows.
class HomeCardLayout extends StatelessWidget {
  const HomeCardLayout({
    required this.cards,
    this.twoColumn = false,
    super.key,
  });

  final List<Widget> cards;

  /// Whether to split the cards across two columns.
  final bool twoColumn;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    if (!twoColumn) return _CardColumn(cards: cards);

    final left = <Widget>[];
    final right = <Widget>[];
    for (var i = 0; i < cards.length; i++) {
      (i.isEven ? left : right).add(cards[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _CardColumn(cards: left)),
        SizedBox(width: tokens.spacingMd),
        Expanded(child: _CardColumn(cards: right)),
      ],
    );
  }
}

class _CardColumn extends StatelessWidget {
  const _CardColumn({required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) SizedBox(height: tokens.spacingMd),
          cards[i],
        ],
      ],
    );
  }
}
