import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/features/accessibility/presentation/accessibility_controller.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';
import 'package:menfit_app/features/achievements/domain/badge_tier.dart';
import 'package:menfit_app/features/achievements/presentation/badge_tier_style.dart';

/// The crest drawn for one badge: a gradient disc when a tier is held, a
/// soft outlined disc when it is not.
///
/// The same emblem is used by the trophy case tile, the new-badge
/// celebration and the post-workout strip, so a badge looks like itself
/// wherever it appears. Its gradient-disc shape is deliberately the one
/// `features/activity/presentation/widgets/workout_celebration_dialog.dart`
/// already uses for its icon badge — the two celebrations belong to one
/// visual family.
///
/// **The emblem never carries meaning alone.** Callers render the tier's
/// name as text beside it (see `presentation/widgets/badge_tile.dart`),
/// because a colour and a shape are not something every user can read.
class BadgeEmblem extends ConsumerWidget {
  const BadgeEmblem({
    required this.kind,
    this.tier,
    this.isEarned = false,
    this.size = 48,
    super.key,
  });

  final BadgeKind kind;

  /// The tier to draw. `null` for a one-off badge, or for a tiered badge
  /// with no tier held yet.
  final BadgeTier? tier;

  /// Whether anything at all is held — a one-off's single award, or any
  /// tier. An unearned emblem is muted, never crossed out or padlocked:
  /// nothing here has been withheld from her.
  final bool isEarned;

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final preferences = ref.watch(accessibilityControllerProvider);

    final icon = kind == BadgeKind.tiered
        ? Icons.workspace_premium_rounded
        : Icons.auto_awesome_rounded;
    final iconSize = size * 0.52;

    final heldTier = tier;
    if (!isEarned || (kind == BadgeKind.tiered && heldTier == null)) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: preferences.highContrast ? 2 : 1,
          ),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    // An earned one-off has no tier; it borrows the Bronze crest so it
    // still reads as a won thing rather than as an empty ring.
    final style = BadgeTierStyle.forTier(
      heldTier ?? BadgeTier.bronze,
      brightness: theme.brightness,
      colorBlindness: preferences.colorBlindness,
      highContrast: preferences.highContrast,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: style.gradient,
        border: style.rimWidth > 0
            ? Border.all(color: colorScheme.onSurface, width: style.rimWidth)
            : null,
      ),
      child: Icon(icon, size: iconSize, color: style.foreground),
    );
  }
}
