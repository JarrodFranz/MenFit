import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The pose countdown: a ring that empties, with the seconds left inside it.
///
/// A `CircularProgressIndicator` rather than a `CustomPaint` on purpose —
/// it already draws a themed, correctly-stroked arc, and a hand-painted one
/// would have to re-derive the track colour for every theme and contrast
/// mode we support.
///
/// The ring is decoration; the number is the information. The ring is
/// therefore excluded from semantics and the whole widget carries one
/// spoken label, so a screen reader says "38 seconds left" rather than
/// reading a progress percentage.
class YogaCountdownRing extends StatelessWidget {
  const YogaCountdownRing({
    required this.fractionRemaining,
    required this.secondsRemaining,
    required this.color,
    required this.trackColor,
    required this.semanticsLabel,
    super.key,
  });

  /// 1 at the top of the phase, 0 when it runs out.
  final double fractionRemaining;
  final int secondsRemaining;
  final Color color;
  final Color trackColor;
  final String semanticsLabel;

  /// Cap on the ring's diameter. Below this the ring shrinks with the
  /// window rather than overflowing a 320dp phone.
  static const double _maxDiameter = 220;

  /// Floor on the diameter, so the number inside stays legible at 150%
  /// text scale on the narrowest screen we support.
  static const double _minDiameter = 132;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final diameter = math
        .min(_maxDiameter, width - 96)
        .clamp(_minDiameter, _maxDiameter);

    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: fractionRemaining,
                strokeWidth: 10,
                backgroundColor: trackColor,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '$secondsRemaining',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
