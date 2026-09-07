import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/app/router/routes.dart';
import 'package:menfit_app/features/recaps/presentation/recap_trigger_controller.dart';

/// Invisible widget that watches [recapTriggerControllerProvider] and, the
/// moment a recap becomes due, pushes `/recap`
/// (`app/router/routes.dart#RecapStoryRouteData`) and marks it shown.
///
/// Dropped straight into `home/presentation/home_screen.dart`'s widget
/// tree, the same "dashboard card that does its own thing" shape as
/// `features/wellbeing/presentation/widgets/checkin_card.dart` — Home
/// reaches this only through this feature's UI composition surface
/// (`recaps_widgets.dart`), never `presentation/` directly (ADR 007's
/// 2026-08-28 amendment).
class RecapTriggerListener extends ConsumerStatefulWidget {
  const RecapTriggerListener({super.key});

  @override
  ConsumerState<RecapTriggerListener> createState() =>
      _RecapTriggerListenerState();
}

class _RecapTriggerListenerState extends ConsumerState<RecapTriggerListener> {
  /// Whether this listener has already presented a recap this mount.
  ///
  /// One recap per sitting, ever: if `markShown` flips the provider back
  /// to `null` and re-evaluation somehow surfaces a *different* due recap
  /// right away, presenting it immediately would push a second story **on
  /// top of the still-open first one**, because Home stays mounted beneath
  /// the pushed route and this listener stays live. The runner-up recap
  /// simply waits for the next Home mount (next app launch or tab return),
  /// which is the "show exactly one, never two" rule the feature spec
  /// requires.
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(recapTriggerControllerProvider, (previous, next) {
      final recap = next.value;
      if (recap == null || _handled) return;
      _handled = true;

      // Deferred to after this frame: pushing a route from inside a
      // listener callback that fires mid-build (Home's own build, in this
      // case) must not happen synchronously.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(RecapStoryRouteData($extra: recap).push<void>(context));
        unawaited(
          ref.read(recapTriggerControllerProvider.notifier).markShown(),
        );
      });
    });

    return const SizedBox.shrink();
  }
}
