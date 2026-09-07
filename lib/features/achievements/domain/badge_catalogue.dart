import 'package:menfit_app/features/achievements/domain/badge_catalogue_one_offs.dart';
import 'package:menfit_app/features/achievements/domain/badge_catalogue_one_offs_by_type.dart';
import 'package:menfit_app/features/achievements/domain/badge_catalogue_tiered.dart';
import 'package:menfit_app/features/achievements/domain/badge_catalogue_tiered_by_type.dart';
import 'package:menfit_app/features/achievements/domain/badge_definition.dart';

/// The badge catalogue: every badge the app offers, as pure declarative
/// data with no behaviour of its own.
///
/// Split across five files purely for size. The tiered definitions live in
/// `domain/badge_catalogue_tiered.dart` (the app-wide ladders) and
/// `domain/badge_catalogue_tiered_by_type.dart` (one ladder per activity
/// type); the one-offs in `domain/badge_catalogue_one_offs.dart` (firsts
/// and curiosities) and `domain/badge_catalogue_one_offs_by_type.dart`
/// (per-type firsts and single-session marks). Every one of those files
/// carries the reasoning behind its own thresholds. This file holds the
/// rules that govern all four, and the lookups.
///
/// ## Rules this catalogue is held to
///
/// 1. **Ids are permanent.** A shipped [BadgeDefinition.id] is never
///    renamed — awards persist as `(badgeId, tierKey)` rows, so a rename
///    takes the award away from everyone who earned it, with no migration
///    able to give it back. See [BadgeDefinition]'s class doc.
/// 2. **Tiers only on progressable behaviours.** A ladder implies "there is
///    always more", so it may only hang on a quantity that can keep rising.
///    Bounded facts (how many kinds of activity exist; whether a first has
///    happened) are one-off badges. This is why "five different kinds of
///    movement" is a one-off rather than a ladder — a ten-rung ceiling is
///    not an open-ended ladder however the rule is written.
/// 3. **Everything is computable from data already stored.** No badge may
///    justify collecting something new, and none may depend on an outside
///    service. See "Ideas deliberately not shipped" below.
/// 4. **Celebration only — never obligation, comparison, or valence.** No
///    badge says what she should do, implies she is behind, ranks her
///    against anyone, or treats a quiet week as a failure. Recovery is
///    never framed as a lapse (`knowledge/product/terminology.md`), which
///    is why the one consistency ladder that could have punished a period
///    week explicitly does not (see
///    `domain/badge_metrics.dart#countWeeklyWalkingTargetWeeks`).
/// 5. **Nothing about body, weight, or appearance.** There is deliberately
///    **no weight-logging badge of any kind** — not a tiered
///    "weigh-in consistency" ladder, not a one-off. Body weight is the most
///    eating-disorder-sensitive surface in the app
///    (`knowledge/domain/womens_health.md`, and the shipped rules for Tasks
///    2.1/2.2 in `knowledge/product/feature_ideas.md`), and attaching a
///    reward ladder to the act of stepping on a scale would manufacture
///    exactly the daily-weighing compulsion that feature was built to
///    avoid. This exclusion is a product decision, not an oversight: do not
///    add one later without revisiting `womens_health.md` first.
/// 6. **No badge duplicates the streak engine.** Streaks are already the
///    app's consistency mechanic and already carry protected recovery. A
///    "longest streak" ladder would double-count them and, worse, would
///    turn a broken streak into a *lost badge* — a second punishment for a
///    rest the app exists to protect.
/// 7. **Every activity type is covered.** Every `ActivityType` must have at
///    least one tiered ladder and at least two one-off badges that can
///    genuinely fire for it — shared badges count, but only where they
///    really do fire. This is what stops the catalogue quietly becoming a
///    running app's badge list: a woman who only swims, or only walks, has
///    a ladder of her own and firsts of her own. It is a **test**, not an
///    aspiration —
///    `test/features/achievements/badge_type_coverage_test.dart` proves the
///    claim by evaluating a session of each type through the real engine,
///    so the next activity type added to the enum fails the suite until it
///    is covered too.
///
/// ## Ideas deliberately not shipped
///
/// * **Rainy-day run** — needs weather, which means a network service and a
///   new data dependency. Rule 3.
/// * **First data export** — the app has no whole-account export path, and
///   the per-activity file export
///   (`features/activity/domain/activity_file_exporter.dart`) records
///   nothing durable, so "she exported once" is not a fact the app knows.
///   Rule 3. Worth revisiting if an export ever writes a marker.
/// * **Weight-logging consistency** — excluded on principle. Rule 5.
/// * **Nutrition-target adherence** ("days you hit your protein target") —
///   turns a food diary into a compliance scoreboard, which is the same
///   eating-disorder risk as rule 5 wearing different clothes.
/// * **Longest-streak ladder** — rule 6.
/// * **"Distinct activity types mastered" as a tiered badge** — the metric
///   tops out at the number of activity types that exist. Demoted to the
///   `five_movement_kinds` one-off. Rule 2.
/// * **Total ascent as the *hike* ladder** — thematically the right
///   quantity, but manual entry has no elevation field
///   (`features/activity/presentation/manual_entry_controller.dart` holds
///   `elevationInput` with nothing wired to it), so a hiker who logs by
///   hand would sit at zero for ever. Hiking's ladder is distance; ascent
///   became `elevation_climbed`, a bonus ladder across every type, and
///   `big_climb_session`. Revisit if manual entry ever asks for climbing.
/// * **"Finished every round you planned"** — computable, and worthless:
///   a hand-logged interval session stores its planned rounds *as* its
///   completed ones, so the badge would fire on every one of them.
///   Replaced by `twenty_interval_rounds`, which is a number she chose.
/// * **Per-stroke swimming ladders** — splits one honest swim ladder into
///   four thin ones, and `SwimWorkoutDetails.stroke` is a free string with
///   a "Mixed" value that would land in none of them. Rule 2's cousin.
/// * **A separate first-yoga and first-pilates badge** — First Stillness
///   already marks that moment, and a shipped id cannot be narrowed
///   (rule 1). The two disciplines got session ladders and hour-long
///   session one-offs instead.
const List<BadgeDefinition> badgeCatalogue = [
  ...tieredBadgeDefinitions,
  ...perTypeTieredBadgeDefinitions,
  ...oneOffBadgeDefinitions,
  ...perTypeOneOffBadgeDefinitions,
];

/// The catalogue keyed by [BadgeDefinition.id].
final Map<String, BadgeDefinition> badgeCatalogueById = {
  for (final badge in badgeCatalogue) badge.id: badge,
};

/// The definition for [id], or `null` if the catalogue has no such badge —
/// which is the expected state when reading an award whose badge was
/// retired from the catalogue entirely (rule 1 says leave the definition
/// in place, but a `null` here must still not crash a trophy case).
BadgeDefinition? badgeDefinitionFor(String id) => badgeCatalogueById[id];
