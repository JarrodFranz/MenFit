import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/errors/error_messages.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';

/// The exercise hub's "Keep screen awake" switch, for this hub's type only.
///
/// Per-type rather than one global setting because the tradeoff genuinely
/// differs by activity — see `domain/screen_awake_preference.dart`. On by
/// default everywhere, and a change lands on a workout of this type that is
/// *already running*, not just the next one.
class ScreenAwakeSection extends ConsumerWidget {
  const ScreenAwakeSection({required this.type, super.key});

  final ActivityType type;

  /// What this switch actually covers, in her words.
  ///
  /// Yoga is the one type with two ways in — the free-running Flow Timer
  /// and a saved sequence — and both obey this switch, so the subtitle says
  /// so rather than leaving the sequence runner looking exempt.
  String get _subtitle => switch (type) {
    ActivityType.yoga => 'While a Yoga session or sequence is running',
    _ => 'While a ${type.label} workout is running',
  };

  Future<void> _setEnabled(
    BuildContext context,
    WidgetRef ref, {
    required bool enabled,
  }) async {
    try {
      await ref
          .read(screenAwakePreferenceProvider(type).notifier)
          .set(enabled: enabled);
    } on Object catch (error) {
      // The notifier has already put the switch back; this only says why.
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessageFor(error))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(screenAwakePreferenceProvider(type));

    return Card(
      margin: EdgeInsets.zero,
      child: SwitchListTile.adaptive(
        value: enabled,
        onChanged: (value) => unawaited(
          _setEnabled(context, ref, enabled: value),
        ),
        secondary: const Icon(Icons.brightness_high_outlined),
        title: const Text('Keep screen awake'),
        subtitle: Text(_subtitle),
      ),
    );
  }
}
