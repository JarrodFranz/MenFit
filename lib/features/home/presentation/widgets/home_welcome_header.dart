import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';

/// The dashboard's greeting: a name when one is known, and today's date.
///
/// Falls back to the bare "Welcome back" rather than to a placeholder name
/// — the profile is optional, and inventing "Welcome back, there" reads
/// worse than saying nothing.
class HomeWelcomeHeader extends ConsumerWidget {
  const HomeWelcomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final name = ref.watch(userProfileProvider).value?.displayName;
    final displayName = name != null && name.trim().isNotEmpty
        ? name.trim().split(' ').first
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayName != null ? 'Welcome back, $displayName' : 'Welcome back',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          // A long first name at 150% scale wraps rather than clipping;
          // the ellipsis stays only as a last resort.
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: tokens.spacingXs / 2),
        Text(
          DateFormat('EEEE, MMM d').format(DateTime.now()),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
