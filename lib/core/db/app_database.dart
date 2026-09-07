import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:menfit_app/core/db/tables/activities.dart';
import 'package:menfit_app/core/db/tables/activity_samples.dart';
import 'package:menfit_app/core/db/tables/badge_awards.dart';
import 'package:menfit_app/core/db/tables/challenges.dart';
import 'package:menfit_app/core/db/tables/daily_checkins.dart';
import 'package:menfit_app/core/db/tables/daily_step_totals.dart';
import 'package:menfit_app/core/db/tables/flare_events.dart';
import 'package:menfit_app/core/db/tables/foods.dart';
import 'package:menfit_app/core/db/tables/nutrition_entries.dart';
import 'package:menfit_app/core/db/tables/nutrition_goals.dart';
import 'package:menfit_app/core/db/tables/recovery_days.dart';
import 'package:menfit_app/core/db/tables/routes.dart';
import 'package:menfit_app/core/db/tables/strength_tables.dart';
import 'package:menfit_app/core/db/tables/user_profiles.dart';
import 'package:menfit_app/core/db/tables/water_logs.dart';
import 'package:menfit_app/core/db/tables/weight_logs.dart';
import 'package:menfit_app/core/db/tables/wellbeing_events.dart';
import 'package:menfit_app/core/db/tables/yoga_sequences.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/core/domain/local_date.dart';

part 'app_database.g.dart';

/// The single Drift database for the app (ADR 003).
///
/// All tables live centrally under `core/db/tables/`; DAOs live with their
/// owning feature's `data/` layer. Bump [schemaVersion] and add a migration
/// step whenever a table changes shape — never edit an already-shipped
/// version's baseline in place.
@DriftDatabase(
  tables: [
    UserProfiles,
    Activities,
    ActivitySamples,
    DailyCheckins,
    FlareEvents,
    RecoveryDays,
    Routes,
    Foods,
    NutritionEntries,
    NutritionGoals,
    WaterLogs,
    StrengthRoutines,
    StrengthCycles,
    WeightLogs,
    BadgeAwards,
    Challenges,
    DailyStepTotals,
    YogaSequences,
    WellbeingEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the real, platform-appropriate database (native SQLite file, or
  /// sqlite3-WASM/OPFS on web).
  AppDatabase() : super(_openConnection());

  /// Opens against a caller-provided [executor] — use
  /// `NativeDatabase.memory()` in tests for a real in-memory SQLite
  /// database with no mocks.
  // ignore: use_super_parameters (generated base ctor's param is named `e`)
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 25;

  /// v1 -> v2 (Phase C wave 1): adds `activities` and `activity_samples`
  /// (see `core/db/tables/activities.dart`, `activity_samples.dart`).
  /// v3 -> v4 (Phase E wave 1): adds
  /// `activity_samples.is_paused` (see `activity_samples.dart`). v4 -> v5
  /// (S1-1): adds `daily_checkins` and `flare_events` (see
  /// `daily_checkins.dart`, `flare_events.dart`). v5 -> v6 (S1-2): adds
  /// `recovery_days` (see `recovery_days.dart`) for the `DayStatus`
  /// protected-recovery streak engine. v6 -> v7 (S1-3): adds
  /// `user_profiles.date_of_birth`/`height_cm`/`weight_kg`/`fitness_goal`/
  /// `running_experience`/`strength_experience`/`training_days` (see
  /// `user_profiles.dart`). v7 -> v8 (routes feature): adds the `routes`
  /// table (see `routes.dart`) and `activities.route_id`. v8 -> v9
  /// (multi-day flares): adds `flare_events.end_day` (see
  /// `flare_events.dart`) — the inclusive last day of a flare that spans
  /// more than one calendar day; `null` for the single-day flares every
  /// pre-v9 row is. v9 -> v10 (routes review): adds `routes.descent_meters`
  /// (see `routes.dart`) — descent was already being fetched from the
  /// routing provider alongside ascent and then silently discarded at save
  /// time. The v1 baseline (`user_profiles` only) is never edited
  /// in place — new tables/columns arrive as upgrade steps here.
  ///
  /// The `from < 4 && from >= 2` guard on the `is_paused` column addition
  /// (rather than a plain `from < 4`) matters: `createTable` always builds
  /// the table's *current* Dart-defined shape, so a device upgrading
  /// straight from v1 already gets `activity_samples` created with
  /// `is_paused` baked in by the `from < 2` branch above — running
  /// `addColumn` for it again in that same upgrade would fail with a
  /// duplicate-column error. The guard only adds the column when the table
  /// already existed *before* this migration run (i.e. wasn't just created
  /// fresh above). `from < 5`/`from < 6` need no such guard —
  /// `daily_checkins`/`flare_events`/`recovery_days` are new tables, not
  /// column additions to a possibly-just-created table. The `from < 7`
  /// block below (new columns on `user_profiles`) *also* needs no such
  /// guard, for the opposite reason to `is_paused`: `user_profiles` is part
  /// of the v1 baseline, so it is never newly created inside `onUpgrade` at
  /// any `from` — it always already exists by the time this callback runs,
  /// so `addColumn` can never collide with a fresh `createTable`. The
  /// `from < 8` step splits both ways: `routes` is a new table (no guard),
  /// while `activities.route_id` is a column addition to a table the
  /// `from < 2` branch may have just created at its current (v8) shape —
  /// so its `addColumn` carries the same `from >= 2` guard as `is_paused`.
  /// The `from < 9` step (`flare_events.end_day`) needs a guard of exactly
  /// the same shape, keyed to *its* table's introducing version:
  /// `flare_events` was created by the `from < 5` branch above, which (like
  /// every `createTable`) builds the table's current Dart-defined shape —
  /// so a device upgrading from v1-v4 already receives `end_day` baked in,
  /// and running `addColumn` for it again in the same upgrade would fail
  /// with a duplicate-column error. Hence `from < 9 && from >= 5`: only a
  /// device that already had `flare_events` *before* this migration run
  /// (i.e. one at v5-v8, where the table exists at its pre-v9 shape) needs
  /// the column added. The `from < 10` step (`routes.descent_meters`) is the
  /// same pattern once more, keyed to `routes`' own introducing version:
  /// `routes` is created by the `from < 8` branch at its current shape, so a
  /// device coming from v1-v7 already has `descent_meters` — hence
  /// `from < 10 && from >= 8`. v10 -> v11 (S1-4 nutrition core): adds
  /// `foods`, `nutrition_entries`, and `nutrition_goals` (see `foods.dart`,
  /// `nutrition_entries.dart`, `nutrition_goals.dart`) — the food diary,
  /// its per-entry nutrition snapshots, and the single-row targets/display
  /// preferences.
  ///
  /// The `from < 11` step needs **no** `from >= N` guard, for the same
  /// reason `from < 5`/`from < 6` don't: all three are brand-new tables,
  /// not column additions to a table an earlier branch above may have just
  /// created at its current Dart-defined shape. The guard question only
  /// arises for an `addColumn` — and this step has none. (Were a later
  /// version to add a column to one of these three, it would need
  /// `from >= 11`, keyed to their introducing version, exactly as
  /// `end_day` is keyed to `flare_events`' v5 and `descent_meters` to
  /// `routes`' v8.)
  ///
  /// v11 -> v12 (percentage-based macro targets): adds
  /// `nutrition_goals.macro_target_mode`/`protein_target_percent`/
  /// `carb_target_percent`/`fat_target_percent` (see
  /// `nutrition_goals.dart`) — the user may state her three macro targets
  /// as shares of the day's energy instead of in grams, and the mode column
  /// says which of the two stored sets counts. `macro_target_mode` defaults
  /// to `'grams'`, so every pre-v12 row keeps meaning exactly what it meant.
  ///
  /// This step is the parenthetical the `from < 11` paragraph above
  /// anticipated, and it takes the guard that paragraph named:
  /// `from < 12 && from >= 11`. Four `addColumn`s on `nutrition_goals`, a
  /// table the `from < 11` branch creates — like every `createTable` — at
  /// its *current* Dart-defined shape, which now includes these four
  /// columns. So a device coming from v1-v10 already receives them from
  /// that branch, and adding them again in the same upgrade run would fail
  /// with a duplicate-column error. Only a device that already had
  /// `nutrition_goals` *before* this migration run — one at exactly v11,
  /// where the table exists at its pre-v12 shape — needs the columns added.
  /// Identical in shape to `end_day` (keyed to `flare_events`' v5) and
  /// `descent_meters` (keyed to `routes`' v8), keyed here to
  /// `nutrition_goals`' own introducing version, v11.
  ///
  /// v12 -> v13 (log by weight): adds `nutrition_entries.quantity_amount`/
  /// `quantity_unit`/`serving_grams` (see `nutrition_entries.dart`) — an
  /// entry now remembers that it was logged as "47 g" rather than only as
  /// the 1.57 servings that works out to. `quantity_servings` stays the
  /// canonical multiplier and is untouched, so every day and meal total is
  /// bit-for-bit what it was.
  ///
  /// The guard is `from < 13 && from >= 11`, keyed — like every guard above
  /// — to the *table's own introducing version*, which for
  /// `nutrition_entries` is v11: the `from < 11` branch creates it, as every
  /// `createTable` does, at its current Dart-defined shape, which now
  /// includes these three columns. A device coming from v1-v10 therefore
  /// already receives them from that branch, and adding them again in the
  /// same upgrade run would fail with a duplicate-column error. Only a
  /// device that already had `nutrition_entries` *before* this run — one at
  /// v11 or v12, where the table exists at its pre-v13 shape — needs the
  /// `addColumn`s. Same shape as `end_day` (keyed to `flare_events`' v5),
  /// `descent_meters` (`routes`' v8) and the v12 columns
  /// (`nutrition_goals`' v11); the only difference is that this table's
  /// window is now two versions wide rather than one, because v12 added
  /// nothing to it.
  ///
  /// **The backfill is explicit, and belongs inside the same guard.** The
  /// column default of `1` exists only so SQLite will accept a NOT NULL
  /// `ALTER TABLE` (and so a fresh insert has something to fall back on);
  /// left standing on a migrated row it would claim every pre-v13 entry was
  /// "1 of something", which is false — those rows hold real serving counts
  /// like 2.5. So the step follows the `addColumn`s with a custom
  /// `UPDATE … SET quantity_amount = quantity_servings`, which is exactly
  /// true: before v13, servings were the only thing that could be logged,
  /// so the amount she typed *was* the serving count. It runs only in the
  /// `from >= 11` branch, which is also the only branch where any row can
  /// exist — below v11 the table was created empty moments earlier, so
  /// there is nothing to backfill. `quantity_unit` needs no such statement:
  /// its `'serving'` default *is* the correct reading of those rows.
  /// `serving_grams` correctly stays null — nobody recorded a weight
  /// against those entries, and `quantity_unit.dart` already reads null as
  /// "weight units unavailable for this entry" rather than guessing one
  /// from the food's current definition.
  ///
  /// v13 -> v14 (macro locks): adds `nutrition_goals.macro_locks` (see
  /// `nutrition_goals.dart`) — the comma-separated set of gram targets the
  /// user has pinned, so the app can work out the one she left free from her
  /// calorie target. One column, because a set is what it is.
  ///
  /// The guard is `from < 14 && from >= 11`, worked out the same way as
  /// every guard above and keyed, once again, to the table's own
  /// introducing version: `nutrition_goals` arrives at v11, and the
  /// `from < 11` branch creates it — as every `createTable` does — at its
  /// current Dart-defined shape, which now includes `macro_locks`. So a
  /// device coming from v1-v10 already receives the column from that
  /// branch, and a second `addColumn` in the same upgrade run would fail
  /// with a duplicate-column error. Only a device that already had
  /// `nutrition_goals` *before* this run — one at v11, v12 or v13, where
  /// the table exists at its pre-v14 shape — needs it added. Identical in
  /// shape to the v12 columns (also keyed to v11); the window is now three
  /// versions wide rather than one, because v13 added nothing to this
  /// table.
  ///
  /// **No backfill, and none is owed.** Unlike v13's `quantity_amount`, the
  /// `''` default is not a placeholder standing in for a real value: no row
  /// written before v14 had any lock, and `''` is exactly "nothing locked"
  /// — the same thing `MacroLocks.none` means and the same thing a fresh
  /// row means. There is no earlier column this one could be derived from,
  /// and inventing locks for existing targets would pin numbers the user
  /// never asked to pin.
  ///
  /// v14 -> v15 (multi-exercise workout details): adds
  /// `activities.metadata_json` (see `activities.dart`) — structured
  /// JSON metadata for Strength sets/reps/rest, HIIT intervals,
  /// Yoga/Pilates mindfulness, and Swim laps.
  ///
  /// The guard is `from < 15 && from >= 2`, keyed to `activities`' own
  /// introducing version (v2): `from < 2` creates `activities` at its current
  /// shape with `metadata_json` baked in.
  ///
  /// v15 -> v16 (S1-5 hydration): adds `water_logs` (see `water_logs.dart`).
  /// v16 -> v17 (strength programming): adds `strength_routines` and
  /// `strength_cycles` (see `strength_tables.dart`). Both are new tables
  /// with no `addColumn`, so — like `from < 5`/`from < 6`/`from < 11` —
  /// neither needs a `from >= N` guard.
  ///
  /// v17 -> v18 (task 2.1, body-weight history): adds `weight_logs` (see
  /// `weight_logs.dart`) — the history behind the profile's single
  /// `weight_kg`, so weight can be trended over time instead of only
  /// known as one current number.
  ///
  /// **The `createTable` needs no `from >= N` guard**, for the same reason
  /// `from < 5`/`from < 6`/`from < 11`/`from < 16`/`from < 17` don't: this
  /// is a brand-new table, not a column addition to a table an earlier
  /// branch above may have just created at its current Dart-defined shape.
  /// The guard question only arises for an `addColumn`, and this step has
  /// none. (Were a later version to add a column to `weight_logs`, it
  /// would need `from >= 18`, keyed to this table's introducing version,
  /// exactly as `end_day` is keyed to `flare_events`' v5.)
  ///
  /// **The profile seed, and why it is here.** After creating the table
  /// this step copies the profile's existing `weight_kg` — if she has one
  /// — into a single [WeightLogs] row dated the migration day, with
  /// `source = 'profile-migration'`. Without it the history would be empty
  /// on every upgrading install, so the first thing a returning user saw
  /// from a "weight trend" feature would be a blank chart, discarding the
  /// one data point the app already held. One row is also all that is
  /// honest: the profile stores a value, not a history — there is no
  /// record of *when* it was measured, so the migration day is the only
  /// date we can truthfully claim, and inventing a back-dated series would
  /// be fabricating measurements.
  ///
  /// `user_profiles.weight_kg` is deliberately **not** removed: several
  /// features read the profile value directly (activity energy estimates,
  /// BMR/TDEE, the progress card). The seed is a one-way copy at a point
  /// in time, not a replacement.
  ///
  /// The seed reads `weight_kg` unguarded because that column is
  /// guaranteed present by the time this branch runs: `user_profiles` is
  /// part of the v1 baseline (never created inside `onUpgrade`), and the
  /// `from < 7` branch above adds `weight_kg` for any device that predates
  /// it — `onUpgrade` runs its branches in order, so v7's column exists
  /// before v18's read of it, at every `from`. It picks the
  /// earliest-created non-deleted profile row, matching
  /// `DriftProfileRepository`'s single-profile resolution, so the seeded
  /// value is the same one the rest of the app calls "her weight".
  ///
  /// **It is idempotent.** The insert is skipped when a
  /// `source = 'profile-migration'` row already exists. On the normal path
  /// that check is trivially false (the table was created empty moments
  /// earlier), and it is there for the abnormal one: this callback runs
  /// every step whose `from` guard matches and ignores `to`, so a re-entry
  /// — a partially-applied upgrade, a migration test invoking `onUpgrade`
  /// directly, a future step that recreates state — must not be able to
  /// stack duplicate seed rows onto a history the user has since added to.
  ///
  /// v18 -> v19 (task 1.8, achievements): adds `badge_awards` (see
  /// `badge_awards.dart`) — one row per badge tier the user has earned,
  /// with the moment she earned it. The moment is the only part of an
  /// achievement that cannot be recomputed from her logs, which is why
  /// this table exists at all.
  ///
  /// **No `from >= N` guard**, for the same reason as `from < 5`/
  /// `from < 6`/`from < 11`/`from < 16`/`from < 17`/`from < 18`: a
  /// brand-new table, no `addColumn`, so the duplicate-column question
  /// never arises. (A later column addition here would need
  /// `from >= 19`, keyed to this table's introducing version.)
  ///
  /// **No `createIndex`, deliberately, and no seed.** `badge_awards`
  /// carries a `UNIQUE(badge_id, tier_key)` *table constraint* rather than
  /// a standalone index, so its uniqueness guarantee is emitted inside the
  /// `CREATE TABLE` statement that `createTable` already guards with
  /// `IF NOT EXISTS`. That is what keeps this step re-entrant without
  /// touching a single migration-test fixture:
  /// `knowledge/troubleshooting/database_migrations.md` records that
  /// `createIndex` has no `IF NOT EXISTS`, so a standalone index here
  /// would have obliged every one of the 29 `onUpgrade` call sites in
  /// `test/core/db/app_database_test.dart` to drop the table first. There
  /// is nothing to seed either — an award is earned, never backfilled, and
  /// inventing dated awards for history the user logged before this
  /// version shipped would be claiming she was told something she never
  /// was. The detector awards them on her next visit, dated honestly to
  /// then (`features/achievements/application/award_detector.dart`).
  ///
  /// v19 -> v20 (task 1.7, buddy challenges): adds `challenges` (see
  /// `challenges.dart`) - one row per offline peer challenge this device
  /// holds, with the buddy's last shared progress snapshot embedded in the
  /// same row rather than split into a second table (the justification is
  /// on that table's own class doc: a strictly 1:1 optional child row,
  /// replaced wholesale on every import and reachable only through its
  /// parent, is a join bought for nothing).
  ///
  /// The table gained its `author_tag` column *before release*, and the
  /// definition was amended in place rather than given a v21 `addColumn`
  /// step: v20 had never shipped, so no installed database exists that
  /// this `createTable` would meet without the column. A column added
  /// after a release is a new version with an `addColumn` and a
  /// `from >= 20` guard, exactly as the paragraph below sets out.
  ///
  /// **No `from >= N` guard**, for the same reason as `from < 5`/
  /// `from < 6`/`from < 11`/`from < 16`/`from < 17`/`from < 18`/
  /// `from < 19`: a brand-new table with no `addColumn`, so the
  /// duplicate-column question never arises. (A later column addition
  /// here would need `from >= 20`, keyed to this table's introducing
  /// version.)
  ///
  /// **No `createIndex`, no `uniqueKeys`, and no seed.** The only
  /// uniqueness this table needs is on its primary key: a challenge's id
  /// is derived from the very bytes its shareable code carries
  /// (`features/challenges/domain/challenge_codes.dart`), so "the same
  /// challenge" and "the same primary key" are one statement, and pasting
  /// a code twice collides on the PK rather than needing a constraint of
  /// its own. v19 bought re-entrancy by choosing a table constraint over a
  /// standalone index; this step gets it by needing neither - a bare
  /// `createTable` is emitted as `CREATE TABLE IF NOT EXISTS`, so no
  /// migration-test fixture in `test/core/db/app_database_test.dart` has
  /// to drop anything first (`knowledge/troubleshooting/database_migrations.md`
  /// records why a `createIndex` here would have forced exactly that, at
  /// every one of the file's `onUpgrade` call sites). There is nothing to
  /// seed either: a challenge is something two people agreed on through a
  /// code they exchanged, and no history logged before this version
  /// shipped can be read as one.
  ///
  /// v20 -> v21 (nutrition data loss): adds the thirteen optional-nutrient
  /// columns to **both** `foods` and `nutrition_entries` (see `foods.dart`,
  /// `nutrition_entries.dart`) - saturated/trans/monounsaturated/
  /// polyunsaturated fat, fibre, sugars, added sugars, sodium, potassium,
  /// cholesterol, calcium, vitamin D and vitamin C. 26 columns in all,
  /// every one nullable, `null` meaning **unknown** exactly as `iron_mg`
  /// already does. The food form had collected and validated all thirteen
  /// since S1-5 and `Food.perServing` carried them, but there were no
  /// columns, so `saveFood` discarded them silently; `nutrition_entries`
  /// snapshots the same facts, so the entry side has to move with the food
  /// side or a logged entry would lose them one step later.
  ///
  /// **No index.** Nothing filters or orders on these columns - they are
  /// read as part of a row the query already selected - so the
  /// `createIndex`-has-no-`IF NOT EXISTS` trap
  /// (`knowledge/troubleshooting/database_migrations.md`) is avoided by
  /// having no index to create, the same way v20 avoided it.
  ///
  /// **The guard, and why it is doubled.** The step carries the
  /// conventional `from < 21 && from >= 11` window, keyed - like every
  /// column-addition guard above - to the tables' own introducing version:
  /// `foods` and `nutrition_entries` arrive at v11, and the `from < 11`
  /// branch creates them, as every `createTable` does, at their *current*
  /// Dart-defined shape, which now includes these columns. So a device
  /// coming from v1-v10 already receives them there.
  ///
  /// That guard alone is not enough here, because it only rules out the
  /// collision with a `createTable` in the *same* run - it cannot make the
  /// step safe to run **twice at the same `from`**, and `onUpgrade` ignores
  /// its `to` argument and re-runs every matching branch. SQLite has no
  /// `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`, so `Migrator.addColumn` is
  /// not idempotent: a second pass would fail with a duplicate-column
  /// error. Every earlier column-addition step (v4, v7, v12, v13, v14, v15)
  /// inherits that fragility and pays for it in the test fixtures, which
  /// must reshape the table back to its pre-step form before replaying.
  /// With 26 columns across two tables, that would have meant a
  /// hand-written `CREATE TABLE` fixture for `foods` at all nineteen
  /// `onUpgrade` call sites in `test/core/db/app_database_test.dart` whose
  /// `from` is 11 or greater.
  ///
  /// So the adds go through [_addColumnsIfMissing], which reads
  /// `PRAGMA table_info` once per table and skips any column already
  /// present. The step is then genuinely re-entrant: replaying it is a
  /// no-op, no fixture has to be reshaped, and a partially-applied upgrade
  /// (interrupted mid-`ALTER`) resumes correctly instead of wedging.
  ///
  /// **No backfill, and none is owed.** `null` is not a placeholder here -
  /// it is the honest reading of every pre-v21 row. Nobody recorded the
  /// fibre in a food logged last month, and defaulting to `0` would turn
  /// missing data into a claim about the food, which is the exact mistake
  /// `iron_mg`'s nullability exists to avoid (`foods.dart`'s class doc, and
  /// the "sum is a floor, not a guess" rule in
  /// `features/nutrition/domain/nutrition_totals.dart`).
  ///
  /// v21 -> v22 (daily step history): adds `daily_step_totals` (see
  /// `daily_step_totals.dart`) - one row per calendar day holding the step
  /// count read from Health Connect / Apple HealthKit, so a step history
  /// exists on this device instead of only inside the health platform. See
  /// ADR 013 for why the totals are stored rather than re-fetched: a chart
  /// over a month otherwise costs one platform-channel call per day on
  /// every rebuild, and web/Windows - which have no health platform at all
  /// - could never show history the phone already collected.
  ///
  /// **No `from >= N` guard**, for the same reason as `from < 5`/
  /// `from < 6`/`from < 11`/`from < 16`/`from < 17`/`from < 18`/
  /// `from < 19`/`from < 20`: a brand-new table with no `addColumn`, so the
  /// duplicate-column question never arises. (A later column addition here
  /// would need `from >= 22`, keyed to this table's introducing version.)
  ///
  /// **No `createIndex`, and no seed.** The table's only uniqueness - one
  /// row per calendar day - is its own `PRIMARY KEY (day)`, emitted inside
  /// the `CREATE TABLE` statement that `createTable` already guards with
  /// `IF NOT EXISTS`, exactly as v19's `UNIQUE(badge_id, tier_key)` table
  /// constraint is. That is what keeps this step re-entrant while touching
  /// **zero** of the existing `onUpgrade` call sites in
  /// `test/core/db/app_database_test.dart`: a standalone index would have
  /// obliged every one of them to drop the table first, because
  /// `Migrator.createIndex` has no `IF NOT EXISTS`
  /// (`knowledge/troubleshooting/database_migrations.md`). Nothing is
  /// seeded either - there is no earlier column, table or preference in
  /// this app that holds a past day's step count, so any row this step
  /// invented would be a number nobody measured. The history starts empty
  /// and fills on the next sync, which reads the real window back from the
  /// platform (`features/steps/steps_providers.dart#StepsSync.syncRecent`).
  ///
  /// v22 -> v23 (yoga sequences): adds `yoga_sequences` (see
  /// `yoga_sequences.dart`) - one row per user-built sequence, its ordered
  /// poses carried as a JSON blob in `poses_json` exactly as
  /// `strength_routines.exercises_json` carries its exercises.
  ///
  /// **No `from >= N` guard, no `createIndex`, no seed** - the same three
  /// reasons as v22, one step simpler. It is a brand-new table with no
  /// `addColumn`, so the duplicate-column question never arises; its only
  /// uniqueness is its own `PRIMARY KEY (id)`, emitted inside the
  /// `CREATE TABLE IF NOT EXISTS` statement, so the step is re-entrant and
  /// touches **zero** existing `onUpgrade` call sites in
  /// `test/core/db/app_database_test.dart` (a standalone index would have
  /// obliged every one of them to drop the table first -
  /// `knowledge/troubleshooting/database_migrations.md`). And nothing is
  /// seeded: the two starter sequences are a domain constant
  /// (`YogaSequenceStarters`), never rows, so an empty table honestly means
  /// "she has saved nothing" and accepting a starter writes her own copy
  /// under a fresh id.
  ///
  /// v23 -> v24 (wellbeing events): adds `wellbeing_events` (see
  /// `wellbeing_events.dart`) - user-logged discrete life events (intimacy,
  /// injury, holiday, or custom other).
  ///
  /// **No `from >= N` guard, no `createIndex`, no seed** - the same
  /// reasons as v22 and v23. Brand-new table with re-entrant
  /// `PRIMARY KEY (id)`.
  ///
  /// v24 -> v25 (fluid volume logging): adds `serving_volume_ml` to both
  /// `foods` and `nutrition_entries` (see `foods.dart`,
  /// `nutrition_entries.dart`), allowing accurate volume-based logging of
  /// liquids (ml, fl oz). Follows the same idempotent `_addColumnsIfMissing`
  /// pattern as v21.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(activities);
        await m.createTable(activitySamples);
        await m.createIndex(idxActivitiesStartedAt);
        await m.createIndex(idxActivitySamplesActivityIdTimestampMs);
      }
      if (from < 4 && from >= 2) {
        await m.addColumn(activitySamples, activitySamples.isPaused);
      }
      if (from < 5) {
        await m.createTable(dailyCheckins);
        await m.createIndex(idxDailyCheckinsDay);
        await m.createTable(flareEvents);
        await m.createIndex(idxFlareEventsDay);
      }
      if (from < 6) {
        await m.createTable(recoveryDays);
        await m.createIndex(idxRecoveryDaysDay);
      }
      if (from < 7) {
        await m.addColumn(userProfiles, userProfiles.dateOfBirth);
        await m.addColumn(userProfiles, userProfiles.heightCm);
        await m.addColumn(userProfiles, userProfiles.weightKg);
        await m.addColumn(userProfiles, userProfiles.fitnessGoal);
        await m.addColumn(userProfiles, userProfiles.runningExperience);
        await m.addColumn(userProfiles, userProfiles.strengthExperience);
        await m.addColumn(userProfiles, userProfiles.trainingDays);
      }
      if (from < 8) {
        await m.createTable(routes);
        if (from >= 2) {
          await m.addColumn(activities, activities.routeId);
        }
      }
      if (from < 9 && from >= 5) {
        await m.addColumn(flareEvents, flareEvents.endDay);
      }
      if (from < 10 && from >= 8) {
        await m.addColumn(routes, routes.descentMeters);
      }
      if (from < 11) {
        await m.createTable(foods);
        await m.createIndex(idxFoodsName);
        await m.createIndex(idxFoodsBarcode);
        await m.createTable(nutritionEntries);
        await m.createIndex(idxNutritionEntriesDay);
        await m.createTable(nutritionGoals);
      }
      if (from < 12 && from >= 11) {
        await m.addColumn(nutritionGoals, nutritionGoals.macroTargetMode);
        await m.addColumn(nutritionGoals, nutritionGoals.proteinTargetPercent);
        await m.addColumn(nutritionGoals, nutritionGoals.carbTargetPercent);
        await m.addColumn(nutritionGoals, nutritionGoals.fatTargetPercent);
      }
      if (from < 13 && from >= 11) {
        await m.addColumn(nutritionEntries, nutritionEntries.quantityAmount);
        await m.addColumn(nutritionEntries, nutritionEntries.quantityUnit);
        await m.addColumn(nutritionEntries, nutritionEntries.servingGrams);
        // Not the column default: see the migration doc above for why every
        // pre-v13 row's amount is its serving count and nothing else.
        await m.database.customStatement(
          'UPDATE nutrition_entries SET quantity_amount = quantity_servings',
        );
      }
      if (from < 14 && from >= 11) {
        await m.addColumn(nutritionGoals, nutritionGoals.macroLocks);
      }
      if (from < 15 && from >= 2) {
        await m.addColumn(activities, activities.metadataJson);
      }
      if (from < 16) {
        await m.createTable(waterLogs);
        await m.createIndex(idxWaterLogsDay);
      }
      if (from < 17) {
        await m.createTable(strengthRoutines);
        await m.createTable(strengthCycles);
      }
      if (from < 18) {
        await m.createTable(weightLogs);
        await m.createIndex(idxWeightLogsDay);
        await _seedWeightLogFromProfile(m);
      }
      if (from < 19) {
        await m.createTable(badgeAwards);
      }
      if (from < 20) {
        await m.createTable(challenges);
      }
      if (from < 21 && from >= 11) {
        await _addOptionalNutrientColumns(m);
      }
      if (from < 22) {
        await m.createTable(dailyStepTotals);
      }
      if (from < 23) {
        await m.createTable(yogaSequences);
      }
      if (from < 24) {
        await m.createTable(wellbeingEvents);
      }
      if (from < 25 && from >= 11) {
        await _addVolumeColumns(m);
      }
    },
  );

  /// Copies the profile's current `weight_kg` (if any) into a single
  /// `weight_logs` row dated today, so an upgrading install starts with a
  /// history instead of nothing. See the v17 -> v18 paragraphs in the
  /// [migration] doc above for why one row, why today's date, and why this
  /// is idempotent.
  ///
  /// S2: the weight is passed as a bound parameter, never interpolated
  /// into SQL text, so the value cannot end up in a statement string that
  /// some future logging or error path might surface.
  Future<void> _seedWeightLogFromProfile(Migrator m) async {
    final seeded = await m.database
        .customSelect(
          'SELECT EXISTS(SELECT 1 FROM weight_logs '
          "WHERE source = 'profile-migration') AS already_seeded",
        )
        .getSingle();
    if (seeded.read<int>('already_seeded') != 0) return;

    final profile = await m.database
        .customSelect(
          'SELECT weight_kg FROM user_profiles '
          'WHERE weight_kg IS NOT NULL AND deleted_at IS NULL '
          'ORDER BY created_at ASC, id ASC LIMIT 1',
        )
        .getSingleOrNull();
    if (profile == null) return;

    final nowMillis = DateTime.now().toUtc().millisecondsSinceEpoch;
    await m.database.customStatement(
      'INSERT INTO weight_logs '
      '(id, day, weight_kg, notes, source, created_at, updated_at) '
      'VALUES (?, ?, ?, NULL, ?, ?, ?)',
      [
        EntityId.generate(),
        LocalDate.today().toIso(),
        profile.read<double>('weight_kg'),
        'profile-migration',
        nowMillis,
        nowMillis,
      ],
    );
  }

  /// Adds the thirteen optional-nutrient columns to `foods` and to
  /// `nutrition_entries` (v20 -> v21). See the v21 paragraphs in the
  /// [migration] doc for why both tables move together and why the adds are
  /// guarded rather than issued blind.
  Future<void> _addOptionalNutrientColumns(Migrator m) async {
    await _addColumnsIfMissing(m, foods, [
      foods.saturatedFatGrams,
      foods.transFatGrams,
      foods.monounsaturatedFatGrams,
      foods.polyunsaturatedFatGrams,
      foods.fiberGrams,
      foods.sugarsGrams,
      foods.addedSugarsGrams,
      foods.sodiumMg,
      foods.potassiumMg,
      foods.cholesterolMg,
      foods.calciumMg,
      foods.vitaminDMcg,
      foods.vitaminCMg,
    ]);
    await _addColumnsIfMissing(m, nutritionEntries, [
      nutritionEntries.saturatedFatGrams,
      nutritionEntries.transFatGrams,
      nutritionEntries.monounsaturatedFatGrams,
      nutritionEntries.polyunsaturatedFatGrams,
      nutritionEntries.fiberGrams,
      nutritionEntries.sugarsGrams,
      nutritionEntries.addedSugarsGrams,
      nutritionEntries.sodiumMg,
      nutritionEntries.potassiumMg,
      nutritionEntries.cholesterolMg,
      nutritionEntries.calciumMg,
      nutritionEntries.vitaminDMcg,
      nutritionEntries.vitaminCMg,
    ]);
  }

  /// Adds the serving_volume_ml column to `foods` and to `nutrition_entries`
  /// (v24 -> v25). See the v25 paragraphs in the [migration] doc.
  Future<void> _addVolumeColumns(Migrator m) async {
    await _addColumnsIfMissing(m, foods, [foods.servingVolumeMl]);
    await _addColumnsIfMissing(
      m,
      nutritionEntries,
      [nutritionEntries.servingVolumeMl],
    );
  }

  /// `ALTER TABLE ... ADD COLUMN` for each of [columns] that [table] does
  /// not already have.
  ///
  /// SQLite has no `ADD COLUMN IF NOT EXISTS`, so `Migrator.addColumn` is
  /// not idempotent; this reads the live column list once per table and
  /// skips what is already there, which is what makes a step built on it
  /// safe to replay. Use it for any future multi-column addition - the
  /// alternative is a hand-written pre-step `CREATE TABLE` fixture at every
  /// `onUpgrade` call site in the migration tests
  /// (`knowledge/troubleshooting/database_migrations.md`).
  ///
  /// The table name is interpolated because `PRAGMA` takes no bound
  /// parameters. It is safe to do so: the value is
  /// [TableInfo.actualTableName], a compile-time constant emitted by
  /// drift's generator, never anything a user typed.
  Future<void> _addColumnsIfMissing(
    Migrator m,
    TableInfo<Table, dynamic> table,
    List<GeneratedColumn<Object>> columns,
  ) async {
    final rows = await m.database
        .customSelect('PRAGMA table_info(${table.actualTableName})')
        .get();
    final existing = rows.map((row) => row.read<String>('name')).toSet();
    for (final column in columns) {
      if (existing.contains(column.name)) continue;
      await m.addColumn(table, column);
    }
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'menfit',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
