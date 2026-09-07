import 'dart:async';

import 'package:flutter/material.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/steps/presentation/steps_copy.dart';

/// Shown while the health platform is still answering whether step access
/// has been granted, so a permitted device does not flash the permission
/// prompt on the way to its own data.
///
/// It gives up after [timeout] and calls [onTimeout]. A spinner with no end
/// is its own kind of dishonesty — after eight seconds an unanswered check
/// is indistinguishable from a refused one, and the screen owes them the
/// button rather than the wheel.
///
/// The timer lives here rather than on the screen so its lifetime is
/// exactly this widget's: the moment the platform answers, this unmounts
/// and its state disposes the timer. A timer owned by the screen would
/// outlive the state it describes (and would linger in every widget test
/// that merely happened to mount the screen).
class StepsCheckingPanel extends StatefulWidget {
  const StepsCheckingPanel({
    required this.onTimeout,
    this.timeout = const Duration(seconds: 8),
    super.key,
  });

  final VoidCallback onTimeout;
  final Duration timeout;

  @override
  State<StepsCheckingPanel> createState() => _StepsCheckingPanelState();
}

class _StepsCheckingPanelState extends State<StepsCheckingPanel> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.timeout, widget.onTimeout);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.spacingXl),
      child: Column(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(height: tokens.spacingMd),
          Text(
            stepsCheckingMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
