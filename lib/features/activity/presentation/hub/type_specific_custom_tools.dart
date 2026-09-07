import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menfit_app/core/theme/tokens.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/presentation/hub/gps_custom_section.dart';
import 'package:menfit_app/features/activity/presentation/hub/hiit_custom_section.dart';
import 'package:menfit_app/features/activity/presentation/hub/mindful_custom_section.dart';
import 'package:menfit_app/features/activity/presentation/hub/strength_custom_section.dart';
import 'package:menfit_app/features/activity/presentation/hub/swim_custom_section.dart';
import 'package:menfit_app/features/activity/presentation/hub/yoga_sequences_card.dart';

/// Type-specific custom domain tools.
class TypeSpecificCustomTools extends ConsumerWidget {
  const TypeSpecificCustomTools({required this.type, super.key});

  final ActivityType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (type == ActivityType.strength) {
      return const StrengthCustomSection();
    } else if (type == ActivityType.run ||
        type == ActivityType.walk ||
        type == ActivityType.hike ||
        type == ActivityType.ride) {
      return GpsCustomSection(type: type);
    } else if (type == ActivityType.hiit) {
      return const HiitCustomSection();
    } else if (type == ActivityType.yoga) {
      // Sequences first: a saved sequence is a whole practice, the style
      // chips only pre-select a label on the free-running Flow Timer.
      final tokens =
          Theme.of(context).extension<AppTokens>() ?? AppTokens.light();
      return Column(
        children: [
          const YogaSequencesCard(),
          SizedBox(height: tokens.spacingMd),
          MindfulCustomSection(type: type),
        ],
      );
    } else if (type == ActivityType.pilates) {
      return MindfulCustomSection(type: type);
    } else if (type == ActivityType.swim) {
      return const SwimCustomSection();
    }

    return const SizedBox.shrink();
  }
}
