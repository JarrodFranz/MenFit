import 'package:menfit_app/features/achievements/achievements_providers.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/challenges/challenges_providers.dart';
import 'package:menfit_app/features/cycle/cycle_providers.dart';
import 'package:menfit_app/features/nutrition/nutrition_providers.dart';
import 'package:menfit_app/features/profile/profile_providers.dart';
import 'package:menfit_app/features/recaps/recaps_providers.dart';
import 'package:menfit_app/features/routes/routes_providers.dart';
import 'package:menfit_app/features/settings/application/delete_my_data_service.dart';
import 'package:menfit_app/features/steps/steps_providers.dart';
import 'package:menfit_app/features/streaks/streaks_providers.dart';
import 'package:menfit_app/features/weight/weight_providers.dart';
import 'package:menfit_app/features/wellbeing/wellbeing_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

/// Composition surface for the `settings` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root) to
/// reach this feature's persistence: other features may import this file,
/// never `data/` or `presentation/` directly.
@Riverpod(keepAlive: true)
DeleteMyDataService deleteMyDataService(Ref ref) {
  return DeleteMyDataService(
    cycleRepository: ref.watch(cycleRepositoryProvider),
    wellbeingRepository: ref.watch(wellbeingRepositoryProvider),
    recoveryRepository: ref.watch(recoveryRepositoryProvider),
    activityRepository: ref.watch(activityRepositoryProvider),
    routeRepository: ref.watch(routeRepositoryProvider),
    yogaSequenceRepository: ref.watch(yogaSequenceRepositoryProvider),
    strengthRoutineRepository: ref.watch(strengthRoutineRepositoryProvider),
    nutritionRepository: ref.watch(nutritionRepositoryProvider),
    nutritionGoalsRepository: ref.watch(nutritionGoalsRepositoryProvider),
    waterRepository: ref.watch(waterRepositoryProvider),
    weightRepository: ref.watch(weightRepositoryProvider),
    stepsRepository: ref.watch(stepsRepositoryProvider),
    awardRepository: ref.watch(awardRepositoryProvider),
    challengeRepository: ref.watch(challengeRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
    // Both stores live in their own feature's `data/` layer, which this
    // feature may not import (ADR 007 / rule 2) - reached through the
    // owning composition surface and passed down as callbacks.
    clearRecapMarkers: () => ref.read(recapMarkerStoreProvider).clear(),
    clearOnlineLookupNotice: () =>
        ref.read(onlineLookupNoticeStoreProvider).clear(),
  );
}
