import 'package:menfit_app/features/achievements/domain/award_repository.dart';
import 'package:menfit_app/features/activity/domain/activity_repository.dart';
import 'package:menfit_app/features/activity/domain/strength_routine_repository.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence_repository.dart';
import 'package:menfit_app/features/challenges/domain/challenge_repository.dart';
import 'package:menfit_app/features/cycle/domain/cycle_repository.dart';
import 'package:menfit_app/features/nutrition/domain/nutrition_repository.dart';
import 'package:menfit_app/features/nutrition/domain/water_repository.dart';
import 'package:menfit_app/features/profile/domain/profile_repository.dart';
import 'package:menfit_app/features/routes/domain/route_repository.dart';
import 'package:menfit_app/features/steps/domain/steps_repository.dart';
import 'package:menfit_app/features/streaks/domain/recovery_repository.dart';
import 'package:menfit_app/features/weight/domain/weight_repository.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_repository.dart';

/// Wipes every repository-owned table this app persists — the data-layer
/// heart of the "Delete my data" flow, extracted out of
/// `features/settings/presentation/settings_screen.dart` so it can be
/// exercised directly by a test without pumping a widget tree (see
/// `test/features/settings/delete_my_data_covers_every_table_test.dart`,
/// which seeds one row into every table in `core/db/app_database.dart` and
/// asserts [run] leaves every one of them empty).
///
/// Neither pure domain nor persistence itself — it only sequences calls to
/// each feature's own `deleteAllData()` — exactly the shape
/// `architecture_overview.md` reserves the `application/` layer for (see
/// `features/challenges/application/challenge_code_service.dart`).
///
/// **Ordering matters and is documented at each call, not just here:**
/// S3-tier data (cycle, wellbeing, recovery days) goes first per
/// `knowledge/engineering/security_and_privacy.md`, then other
/// health/location-adjacent data, then everything else.
///
/// **Deliberately out of scope**: SharedPreferences-backed UI/session
/// state (theme mode, the fitness-device-sync and activity-energy-estimate
/// toggles, the onboarding-complete flag) and navigation. Those are not
/// rows in a table an audit of `app_database.dart` needs to reason about —
/// they stay the presentation layer's job in `settings_screen.dart`, which
/// calls [run] first and then resets them.
///
/// ## Which preference keys this *does* clear, and why the rest stay
///
/// Two SharedPreferences keys are cleared here even though they are not
/// table rows, because they are **residue of her data rather than
/// configuration of her device**:
///
/// * the recap-shown markers, which store a `cycle:<uuidv7>` whose id
///   embeds the timestamp the cycle record was created — a readable trace
///   of when a period was logged, outliving the S3 table it came from;
/// * the online-lookup notice acknowledgement, which is a consent that
///   belongs to the person who gave it, not to the handset.
///
/// Everything else stays on purpose: accessibility preferences, theme mode,
/// the food-search region and the per-activity `screen_awake_*` switches all
/// describe *this device* and how it is comfortable to use — resetting high
/// contrast or larger text because someone deleted their diary would be a
/// small act of hostility towards the person most likely to need them.
class DeleteMyDataService {
  const DeleteMyDataService({
    required this.cycleRepository,
    required this.wellbeingRepository,
    required this.recoveryRepository,
    required this.activityRepository,
    required this.routeRepository,
    required this.yogaSequenceRepository,
    required this.strengthRoutineRepository,
    required this.nutritionRepository,
    required this.nutritionGoalsRepository,
    required this.waterRepository,
    required this.weightRepository,
    required this.stepsRepository,
    required this.awardRepository,
    required this.challengeRepository,
    required this.profileRepository,
    required this.clearRecapMarkers,
    required this.clearOnlineLookupNotice,
  });

  final CycleRepository cycleRepository;
  final WellbeingRepository wellbeingRepository;
  final RecoveryRepository recoveryRepository;
  final ActivityRepository activityRepository;
  final RouteRepository routeRepository;
  final YogaSequenceRepository yogaSequenceRepository;
  final StrengthRoutineRepository strengthRoutineRepository;
  final NutritionRepository nutritionRepository;
  final NutritionGoalsRepository nutritionGoalsRepository;
  final WaterRepository waterRepository;
  final WeightRepository weightRepository;
  final StepsRepository stepsRepository;
  final AwardRepository awardRepository;
  final ChallengeRepository challengeRepository;
  final ProfileRepository profileRepository;

  /// Clears `RecapMarkerStore`'s two keys, and
  /// `OnlineLookupNoticeStore`'s one.
  ///
  /// Passed as callbacks rather than as the stores themselves: both live in
  /// their own feature's `data/` layer, which `architecture_overview.md`
  /// rule 2 does not let this feature import — only the owning feature's
  /// `<name>_providers.dart` surface may reach them, and that is where
  /// these are bound (`settings_providers.dart`).
  final Future<void> Function() clearRecapMarkers;
  final Future<void> Function() clearOnlineLookupNotice;

  /// Runs the full wipe. Throws whatever the first failing repository call
  /// throws (each repository already wraps its own failure in a
  /// `StorageException`) — the caller decides how to surface that.
  Future<void> run() async {
    // Cycle and wellbeing (check-ins/flares) data are S3-tier (most
    // sensitive) - delete them first (see
    // knowledge/engineering/security_and_privacy.md: "Full export and
    // deletion must work for this data category first"). Recovery days
    // are health-adjacent for the same reason - deleted alongside them,
    // still ahead of the less sensitive activities/profile/preferences.
    // The streak-pausing preference is cleared in the same breath as
    // cycle data, since `DriftCycleRepository` owns that SharedPreferences
    // key too (B1/F4: see
    // `domain/cycle_repository.dart#clearStreakPausingPreference`) - an
    // absent key both resets streak pausing to its default AND stops a
    // stale persisted value from permanently blocking F4's grandfathering
    // re-seed for a later, unrelated install on the same device.
    await cycleRepository.deleteAllData();
    await cycleRepository.clearStreakPausingPreference();
    await wellbeingRepository.deleteAllData();
    await recoveryRepository.deleteAllData();
    // Activities (and their GPS samples) are location data - also
    // sensitive, but ordered after the S3 tier per the same policy
    // document's tiering, ahead of the least-sensitive profile/prefs.
    await activityRepository.deleteAllData();
    // Saved routes carry start points that are typically home-adjacent -
    // S2-tier location data, wiped in the same breath as activities.
    await routeRepository.deleteAllData();
    // Yoga sequences and strength routines/cycles are self-authored
    // training content (S1) rather than a health measurement, but they
    // are still hers - hard-deleted with the activities they were built
    // to accompany, soft-deleted rows included, since a hidden row is not
    // a deleted one.
    await yogaSequenceRepository.deleteAllData();
    await strengthRoutineRepository.deleteAllData();
    // The food diary is S2-tier too (nutrition logs, and targets derived
    // from body metrics) - entries and saved foods, then the targets and
    // display preferences, which live in their own single-row table and
    // would otherwise survive the wipe. Logged water is the same tier and
    // wiped alongside them.
    await nutritionRepository.deleteAllData();
    await nutritionGoalsRepository.deleteAllData();
    await waterRepository.deleteAllData();
    // Body-weight history is S2-tier body metrics, wiped alongside the
    // rest of the S2 tier and ahead of the profile - and it is a genuine
    // hard delete with no soft-delete column to leave rows hiding in
    // (see `features/weight/domain/weight_repository.dart`).
    await weightRepository.deleteAllData();
    // Step history synced from Health Connect / Apple Health is S2-tier
    // health-platform data, wiped with the rest of that tier. Note the
    // limit of what this can promise: the health platform keeps its own
    // copy, which only she can delete there - this removes what *this
    // app* stored, which is all this app is able to remove.
    await stepsRepository.deleteAllData();
    // Earned badges are S1 in themselves, but the *set* of them is a
    // fingerprint of everything above: which cycles she logged, how
    // often she checked in. Wiped with the data they were derived from,
    // and genuinely - an award is a row, not a soft-delete flag.
    await awardRepository.deleteAllData();
    // Buddy challenges carry two self-chosen display names (hers and her
    // buddy's) and one shared percentage - S1 personal data, and a record
    // of who she trains with besides. Hard-deleted with the rest, no
    // soft-delete flag to hide behind.
    await challengeRepository.deleteAllData();
    await profileRepository.deleteAllData();
    // Two SharedPreferences keys that are residue of the rows above rather
    // than device configuration - see the class doc for why these two and
    // not the accessibility/theme/region/screen-awake keys. Last, because a
    // failure here must not stop the tables being emptied.
    await clearRecapMarkers();
    await clearOnlineLookupNotice();
  }
}
