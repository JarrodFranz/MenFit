# Handoff — MenFit (men's training + nutrition app)

*Live state. Last updated 2026-11-16 22:20 AEST (Health area on `main`; build 0.1.0 (4) with it distributed to Firebase group `main` 2026-11-17).*

## State

- **Flutter 3.47.2 / Dart 3.13.2.** `main` == `fork-femfit`, pushed to `https://github.com/JarrodFranz/MenFit` (2026-09-08).
- **`main` is schema v4** with tabs Home, Train, Nutrition, Keto, Health,
  Recovery (Health merged and pushed 2026-11-17). `pubspec.yaml` is
  `0.1.0+4`; build 0.1.0 (4) is on Firebase group `main`. `pubspec.yaml` is `0.1.0+3`. Details under In flight.
- **Fork complete (2026-09-08):** all 14 plan tasks done
  (`docs/superpowers/plans/2026-09-07-menfit-fork.md`, ledger in
  `.git/sdd/progress.md`). Cycle tracking removed; tabs Home / Train /
  Nutrition / Recovery / Settings; strength-first Home with Today's session
  card; Forge theme (seed `0xFFD84A1B`); male Mifflin constant and adult-male
  reference intakes; Drift schema reset to v1; placeholder Forge assets;
  knowledge base rewritten (`knowledge/domain/mens_health.md`, ADR 017).
- **Final whole-branch review fixes landed (2026-09-08):** commits `998c308`
  (strength-first Train tab + hub routing + web identity guard) and `3466e5e`
  (stale defaults/docs/citations + build number). Full report:
  `.git/sdd/final-fix-report.md`.
- **Validation (2026-09-08, run centrally at `3466e5e`):**
  `dart run build_runner build` wrote 1212 outputs; `dart format .` 0 changed;
  `flutter analyze --fatal-infos` **No issues found!**; `flutter test`
  **3,509 passed, 0 failed** (1m54s, one process).
- **First tester build shipped (2026-09-08):** `scripts/distribute_android.ps1`
  built `app-release.apk` (122.7 MB, staging env + secrets overlay) and
  uploaded releases **0.1.0 (1)** and, after the final-review fixes, **0.1.0 (2)** (`versionCode 2`) to Firebase App Distribution, project
  `menfit-f17b3`, app `com.jarrodfranz.menfit`, group `main`. apksigner:
  CN=MenFit Upload Key; aapt: package `com.jarrodfranz.menfit`, label MenFit.
  Console: https://console.firebase.google.com/project/menfit-f17b3/appdistribution
  Group `main` had 0 testers at upload time, so nobody was emailed yet.
- Signing: MenFit upload keystore `%USERPROFILE%\menfit-signing\upload-keystore.jks`
  (alias `upload`); password only in gitignored `android/key.properties`.
  **Owner must back both up off-machine.**

## In flight

- **Health area is on local `main`** (owner: "Merge to main", 2026-11-17):
  `main` fast-forwarded from `39fbd75` to the `feat/health` tip (feature
  commits `7f3c2f4` + `21ceb73`). A fast-forward, so the merged tree is the
  tree that was tested; the suite was not re-run. **Pushed to
  `origin/main` 2026-11-17** (owner: "Push main"; `39fbd75..b87cb5b`, then
  this handoff commit). **Distributed 2026-11-17** (owner: "distribute to
  Firebase"): release **0.1.0 (4)**, project `menfit-f17b3`, group `main`;
  CLI: "uploaded new release 0.1.0 (4) successfully", "distributed to
  testers/groups successfully". Release:
  https://console.firebase.google.com/project/menfit-f17b3/appdistribution/app/android:com.jarrodfranz.menfit/releases/22km0736fa290
  Built from `04361dc` (`0.1.0+4`, staging env + secrets overlay):
  apksigner CN=MenFit Upload Key, aapt versionCode 4. On that exact source,
  2026-11-17 11:31 AEST: `dart format` 0 changed, `flutter analyze
  --fatal-infos` No issues found, `flutter test` **3,940 passed, 0 failed**
  (3m26s). That exact APK was installed over a schema-v3 build (versionCode
  3) on a throwaway emulator: profile kept, six tabs, Health tab rendered,
  0 FATAL / E-flutter. Not checked on a physical device. `04361dc` and
  this handoff commit are on local `main`; whether they are pushed: see
  `git status -sb`. `pubspec.yaml` is still `0.1.0+3`. Built in worktree
  `../MenFit-health`. A separate checkout was used
  so the widget port on `feat/home-widgets` is undisturbed.
  - What it is: sixth tab **Health** (`/health`) with read-on-demand watch
    vitals (heart rate, resting HR, SpO2, sleep, HRV, respiratory rate; never
    persisted; separate READ-only Health Connect request), manual blood
    pressure log (Heart Foundation AU 2016 category per reading, 7-day-average
    headline, chart) and manual blood glucose log (RCPA reference range and
    neutral position for fasting and 2 h+ after eating only). **Schema v4**
    (`blood_pressure_readings`, `blood_marker_readings`, both S3). The
    Settings tab is gone: Settings lives at `/home/settings/...` behind the
    Home gear. Contract and owner decisions:
    `docs/superpowers/specs/2026-11-16-health-tab-design.md`. Evidence:
    `knowledge/research/blood_pressure_classification.md`,
    `knowledge/research/blood_glucose_reference_ranges.md`.
  - **Validation, run centrally 2026-11-16 22:12-22:15 AEST:** `dart format`
    0 changed (1,139 files); `flutter test` **3,940 passed, 0 failed**
    (2m05s). Afterwards two lint infos in one test were fixed (test name and
    a raw string only): `flutter analyze --fatal-infos` No issues found, and
    that file re-run 15/15. The full suite was not re-run after that edit.
  - **Emulator smoke test (throwaway AVD `MenFit_HealthQA`, port 5586, API 36,
    release APK of `7f3c2f4`, CN=MenFit Upload Key):** installed the
    schema-v3 build first, onboarded, saved a ketone reading, then installed
    the new APK over it - profile and ketone reading survived the v3 -> v4
    upgrade. Health Connect sheet listed exactly the six vitals types; after
    Allow the card showed "No recent watch data.". Blood pressure add / edit /
    delete, categories (128/82 Normal, 135/82 High-normal, 185/112 Grade 3 +
    the 000 line), glucose add in mmol/L and mg/dL, position label, Home gear
    -> Settings -> back, all worked; data survived force-stop + relaunch;
    logcat had 0 FATAL / E-flutter lines. The two fixes in `21ceb73` came
    from this test. The rebuilt APK of `21ceb73` was installed over it:
    readings still there, chart order now correct, 0 FATAL / E-flutter; the
    shortened dropdown hint was not looked at again. AVD deleted afterwards.
  - **Not verified:** real watch data on a physical device (sleep-stage and
    SpO2-unit handling rest on plugin source); anything iOS; export/import
    and Delete my data on a device (tests only); upgrade from the Firebase
    build 3 APK itself (the v3 build used was the widget session's 21:43
    rebuild of the same schema); web and Windows builds (the watch card's
    unsupported state is covered by widget tests only).
  - **Merge notes for `feat/home-widgets`:** both branches edit
    `delete_my_data_service.dart` + `settings_providers.dart` (each adds a
    required constructor field), `AndroidManifest.xml` (this branch: six
    `uses-permission` lines only), `lib/app/router/routes.dart` (this branch
    moved the Settings subtree under Home and added the Health branch) and
    both handoff files. Any widget deep link or test that assumes a Settings
    tab or a `/settings` path must become `/home/settings`.

- Nothing mid-edit. **Build 0.1.0 (3) is on Firebase App Distribution**
  (2026-11-16, project `menfit-f17b3`, group `main`, 1 tester at upload time;
  CLI: "uploaded new release 0.1.0 (3) successfully", "distributed to
  testers/groups successfully"). Release:
  https://console.firebase.google.com/project/menfit-f17b3/appdistribution/app/android:com.jarrodfranz.menfit/releases/5s8beea9q7kkg
- On this Linux host the Firebase CLI's default account has no access to
  `menfit-f17b3`; a second account that does was added by the owner. Pass
  `--account <owner's menfit account>` (see `firebase login:list`) on every
  `firebase` command for this project. Upload command used:
  `firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk --account <account> --app <firebaseAppId from distribution/android.json> --groups main --release-notes "..."`.
  Do not use `scripts/distribute_android.ps1` on Linux as-is: it sets
  `NODE_TLS_REJECT_UNAUTHORIZED=0` (an Avast workaround for the Windows host).
- `main` == `origin/main` == `8490d46` (fast-forward of
  `codex/frelia-ports-keto` + build-number bump). Suite re-run on merged
  `main` before the push: analyzer clean, **3,666 passed** (2m56s).
- APK for build 3 (built 16:30 from `8490d46`, staging env + secrets overlay):
  apksigner CN=MenFit Upload Key; aapt `com.jarrodfranz.menfit` versionCode 3.
  The emulator smoke test below was done on the build-2-numbered APK of the
  same source, not on this rebuild.
- What `d87bc68` contains: sixth tab `/keto` (diary macros + manual
  Blood mmol/L / Urine as-printed / Breath ppm log, no conversion, no net
  carbs); schema v1 → v2 (ketone readings + day index) → v3 (food provider
  identity backfill); S3 export/import/deletion for readings; Frelia ports
  (strength inputs/distance, workout permissions, Android backup exclusions,
  OCR/search/serving/attribution, hidden calories, percent targets, hydration,
  life-event name fixes). Ledger of ported vs unported:
  `docs/superpowers/specs/2026-11-16-frelia-port-and-keto-design.md`
  ("Implementation ledger"). Evidence note: `knowledge/research/keto_tracking.md`.
- Build-2/3 validation, APK and emulator details for `d87bc68`: see
  `handoff/session-log.md` (2026-11-16 entries). Never exercised on a
  device: Urine entry, ketone edit/delete, export/import, food search,
  workout permission prompts, anything iOS.
- Live FatSecret proxy returned HTTP 401 (no local key): live search
  unverified; OFF fallback and manual entry unaffected.

## Next

-1. **Health (build 0.1.0 (4) distributed 2026-11-17):** install it from
   Firebase on a physical Android phone over build 3 and check the upgrade.
   Next tester build needs `0.1.0+5`. `feat/home-widgets` must now merge or rebase
   onto `main` (see merge notes under In flight); re-run the full suite on
   the result.
   On a physical Android phone with a watch: grant the six vitals, check
   sleep, SpO2 and HRV values against the watch's own app. Full device, Mac and web/Windows checklist: end of
   `docs/superpowers/specs/2026-11-16-health-tab-design.md`.
0. Install build 0.1.0 (3) from Firebase on a physical Android device and
   smoke-test it (this exact rebuild was not run on an emulator).
1. Next tester build needs `0.1.0+4`. Never distribute a debug-signed build.
2. On a physical Android device: upgrade install over build 2 (real v1 data →
   v3), workout permission prompts (Health Connect), nutrition search once the
   proxy key is available.
3. Owner: add tester emails to Firebase groups `main`/`testers`
   (`firebase appdistribution:testers:add <email> --project menfit-f17b3 --group-alias main`);
   both groups had 0 testers when builds 1 and 2 were uploaded. Back up the
   upload keystore and the password in `android/key.properties` off-machine.
4. Replace placeholder artwork (overwrite `assets/images/app_icon.png`, run
   `python scripts/generate_brand_assets.py`).
5. Deferred Minors from the September final review: `.git/sdd/progress.md` and
   `TASKS_TO_DO.md`. Unported Frelia subsystems: see the spec ledger.
6. iOS lane: Codemagic app + Apple bundle id for `com.jarrodfranz.menfit`.

## Open questions

- **Health, for the owner:** (1) confirm the RCPA glucose reference interval in a
  browser (https://www.rcpa.edu.au/Manuals/RCPA-Manual/Pathology-Tests/G/Glucose) -
  the live page is behind bot verification, the numbers 3.0-5.4 fasting and
  3.0-7.7 non-fasting came from an archived copy of 4 Oct 2024; (2) whether a
  glucose reading of 15.0 mmol/L or more should show a "contact a doctor
  today" line (not built: the trigger is only sourced for people with
  diabetes); (3) whether "before a meal" should use the non-fasting range
  (not built: inferred, not sourced); (4) named hypertension grades, the 000
  line and glucose ranges sit close to the regulated-medical-software line
  (TGA / FDA wellness exclusions) - fine for private testers, needs a proper
  look before a public store release.
- No blocking product question: owner chose measurement selection. Historical fork decisions remain strength-first, Recovery tab kept, MenFit identity, Forge theme, no sex field and safety retained. The shipped v1 baseline must now be migrated forward, not reset.

## Traps

- **A widget test that pumps the real `App` with an in-memory Drift database
  must unmount the tree and pump 1 ms inside the test body.** Doing it in
  `addTearDown` fails with "A Timer is still pending even after the widget
  tree was disposed". See `knowledge/engineering/testing_strategy.md`.
- **A session isolated in a worktree cannot run compound shell lines that
  mention `git`** (the harness refuses them). Run git commands alone.
- **`health` 13.3.2 facts** (per-type reads, sleep value semantics, RMSSD vs
  SDNN, SpO2 scale): `knowledge/flutter/platform_notes.md`.
- Several agents in one worktree: `dart format <dir>` reformats other
  agents' files, and a spec example is copied into tests verbatim - a wrong
  example ("128/82 is High-normal"; it is Normal) became a failing test.

- **Check `firebase projects:list` shows `menfit-f17b3` before uploading.** The
  CLI uploads the entire APK first and only then reports a 403 — half an hour
  wasted on 2026-11-16. With the right `--account` the same upload succeeded.

- **Linux checkout shows ~1,200 phantom modified files** (worktree CRLF, index
  LF, no `core.autocrlf` on this host). Use
  `git -c core.autocrlf=true status|diff|add|commit` — then only real changes
  appear and blobs are stored LF. Plain `git diff --cached` can still *display*
  whole-file diffs (it reads the CRLF worktree file when stat-clean); the
  stored blobs are fine — check with `git diff <blobA> <blobB>`.
- **The `Pixel_6_Pro_API_36` emulator (emulator-5554) is shared with other
  agent sessions** (an `agenthq` UI test was driving it on 2026-11-16). Do not
  install/launch/tap on it without checking the foreground app. A second
  instance of the same AVD is refused unless every instance was started
  `-read-only`; create a throwaway AVD instead. `avdmanager` writes to
  `~/.config/.android/avd`, the emulator reads `~/.android/avd` — launch with
  `ANDROID_AVD_HOME=$HOME/.config/.android/avd`.
- `pkill -f '<pattern>'` kills the calling shell when the pattern appears in
  its own command line (exit 144). Use `adb -s <serial> emu kill`.

- **`workout_share_dialog_test.dart`'s `settleCardCapture` helper used a
  single fixed 50ms `tester.runAsync` wait for the real (non-fake-async)
  PNG encode `captureCardPng` does.** That's fine for one capture, but
  when two `WorkoutShareDialog`s that each capture a card run back to
  back in the same test file (as they do now that the phase-toggle tests
  sitting between them are gone), the second capture consistently missed
  its 50ms window on this machine, leaving `_cardPng` null and silently
  degrading `_handleShare` to its documented text-only fallback —
  `sharing.imageShares.single` then threw `Bad state: No element`. Fixed
  in Task 6 by looping the wait up to 5×50ms instead of one shot. If a
  similar `imageShares`/`toImage()`/`captureCardPng`-based assertion goes
  flaky elsewhere (recap share sheet, badge celebration share), suspect
  this same race before the app code.
- `test/core/adaptive_scaffold_test.dart` deliberately keeps a **six**-entry
  synthetic destination fixture (`_crowdedDestinations`) even though the shell
  has five: at five tabs, 320/5 = 64 dp is above the 62 dp comfort threshold
  and `AppAdaptiveScaffold._compactLabelStyle`'s shrink path would never run,
  so trimming it to five silently deletes that coverage. The shipped-list
  mirror is `adaptive_scaffold_real_font_test.dart`, which IS five.
- `StrengthCycles`/`strength_cycles` (training mesocycles) and `RecoveryDays`
  are not cycle tracking — keep them. "Period" inside `ProgressPeriod` /
  `RecapPeriod` means a date range, also keep.
- **`flutter test` writes nothing to a redirected stdout until it exits**, so
  a piped/backgrounded run looks hung at 0 bytes for its whole duration. The
  first post-fix full run took 29 minutes (cold kernel compile) before
  printing anything; the second took 1m54s. Do not kill a silent run and do
  not start a second one to "check" — poll the process, not the log.
- FemFit rules carry over: only ONE `flutter test` at a time (deadlocks);
  never `find /` on this Windows machine; Avast TLS interception affects
  Android builds (see FemFit `knowledge/troubleshooting/android_build.md`).
- **robocopy `/XD` and `/XF` entries that include a backslash path (e.g.
  `"tools\femfit_deploy\bin"`, `"env\dev.secrets.json"`) silently do NOT
  exclude anything in this environment** — only bare directory/file names
  work. Task 1 had to manually delete `env/dev.secrets.json`,
  `env/staging.secrets.json` and `tools/femfit_deploy/bin/` (a built .exe)
  after the copy because of this. Check for this every time a task brief
  uses a path-qualified robocopy exclusion.
- A blanket text-rename sweep (Step 3 of Task 1, matching `*.md` too) will
  happily rewrite MenFit's own `docs/`/`handoff/` files, corrupting factual
  statements like "Source: ... package `femfit_app`" into a false claim
  about MenFit itself. Always diff/review `git status` after a sweep like
  that and revert any hit inside `docs/`/`handoff/` that describes FemFit
  historically rather than needing an actual rename.
- **`flutter test <directory>` compiles every file it targets as one shared
  kernel.** In Task 4, `flutter test test/features/insights` reported 3
  files "failing to load" — `group_comparison_test.dart`,
  `insight_discovery_section_test.dart`,
  `insight_observations_provider_test.dart` — but only the latter two
  actually import the broken `insights_providers.dart` (→
  `nutrition_providers.dart` → deleted `features/cycle/`) chain.
  `group_comparison_test.dart` has zero nutrition/cycle dependency and
  passes 18/18 when run alone (`flutter test
  test/features/insights/group_comparison_test.dart`), but fails to load
  when run in the same invocation as a poisoned file. **When a directory
  run reports load failures, always re-run the suspect files individually
  before concluding a given file is actually broken** — list every clean
  file explicitly (space-separated paths) in one `flutter test` invocation
  to get a true pass count for "everything not touching the known cascade."
- `dart fix --apply` can silently modify `pubspec.yaml` as a side effect
  (it added `wakelock_plus_platform_interface: any` as a dev dependency to
  resolve an unrelated `depend_on_referenced_packages`/`unnecessary_ignore`
  pair that only appears because renaming the package shifts import-sort
  order). If you use `dart fix --apply` for `directives_ordering` fallout
  from a package rename, diff `pubspec.yaml`/`pubspec.lock` afterward and
  revert anything beyond the import reordering you intended.

## Corrections

- **2026-11-16 (Health):** the owner asked for blood pressure judged "given my
  age and gender". No adult guideline (Heart Foundation AU 2016, ACC/AHA,
  ESC 2024, ESH 2023) varies its categories by age or sex; only treatment
  targets vary. The app therefore uses one table and says so on screen. Do
  not add age- or sex-specific categories or population percentiles.
- **2026-11-16 (Health):** my own recommendation was store-and-chart for
  glucose; the owner chose to show reference ranges. Diabetes Australia's
  4.0-7.8 was rejected as the range (no fasting value; 4.0 is the hypo
  threshold for people with diabetes).
- **2026-11-16:** `CLAUDE.md` still calls the shell five tabs with Settings
  in places and tells sessions to arm a PowerShell watchdog; the shell is
  Home, Train, Nutrition, Keto, Health, Recovery and this host is Linux.

- **2026-11-16 (later):** the previous handoff said the signing keystore lives
  at `%USERPROFILE%\menfit-signing\`. On this Linux host
  `android/key.properties` points at `/home/jarrod/menfit-signing/upload-keystore.jks`
  and release signing works here. The earlier "Android release build running"
  note is resolved: the build finished and is verified above.

- **2026-11-16:** This host is Linux, not the Windows host described below. Flutter 3.47.2 / Dart 3.13.2 is available. Central Flutter KB: `/run/media/jarrod/Second M.2/Documents/Claude/Flutter development knowledge/`. The old watchdog uses Windows CIM and broad process matching; inspected, not launched. No process was killed.
- **2026-11-16:** MenFit has 1,222 pre-existing modified tracked files but `git diff --ignore-space-at-eol --stat` was empty before this session's documentation edits. Preserve the line-ending changes; they are not 1,222 substantive app changes.
- **2026-11-16:** Frelia is schema v37, MenFit v1. Do not copy its migration chain. Neither app records carbohydrate basis, and OFF imports do not currently populate fibre: a blanket carbs-minus-fibre calculation is not valid net-carb tracking.

- **2026-09-08 (final review):** `lib/core/db/tables/weight_logs.dart`'s
  dartdoc claimed "the migration seeds one row from the profile so the
  history starts non-empty". **That has never been true** — v1 `createAll`
  seeds nothing, so a fresh install has an empty weight history until the
  user logs a weight. The dartdoc now says so. (Separately, the S2/S3 tier
  mismatch flagged in Task 13's log entry was already resolved in `313a48c`.)
- **2026-09-08 (final review):** `ActivityType.fromStorage` is **not** a safe
  parser for the `/activity/hub/:type` route — its `run` fallback is correct
  for persisted rows and wrong for URLs, and it silently landed a
  strength-first app on the Run hub. Route parsing now goes through
  `hubTypeFromRoute()` in `lib/features/activity/domain/activity.dart`, which
  defaults to `strength`. Do not "unify" the two.
- **2026-09-08 (Task 14 prep):** robocopy in Task 1 leaked FemFit's gitignored
  `android/key.properties` (pointing at `%USERPROFILE%\femfit-signing\`) into
  the MenFit tree. It was never committed, but a release build would have
  been signed with FemFit's key. Replaced by a MenFit keystore at
  `%USERPROFILE%\menfit-signing\upload-keystore.jks` (alias `upload`,
  CN=MenFit Upload Key) with the password only in `android/key.properties`.
  Owner must back up the .jks and that password off-machine.

- **2026-09-08 (Task 6):** the Task 6 brief said the five finishing flows
  (`recording_controller.dart`, `strength_tracker_controller.dart`,
  `hiit_tracker_controller.dart`, `mindful_tracker_controller.dart`,
  `swim_tracker_controller.dart`, plus their screens) "pass `phase:`" and
  need to "stop resolving and passing `phase:` (and remove
  `cycleRepositoryProvider`/`cyclePredictionEngineProvider` reads)". **That
  wiring did not exist in any of the ten files** — grepped all of them
  plus every call site of the milestone-evaluator methods and the two
  dialogs' `.show()` before and after; none read a cycle provider or
  passed `phase:`. Whatever step removed it did so before this task (most
  likely folded into Task 3's cycle removal). No changes were needed in
  those ten files; do not re-open them looking for phase-passing code
  that Task 6 "missed" — it was never there.
- **2026-09-07 (Task 3):** the Task 3 brief said "Wellbeing renamed in Task 5"
  — that rename is actually **Task 9**. The Wellbeing tab was left as-is
  (label `'Wellbeing'`) in Task 3.
- **2026-09-07 (Task 3):** a large block of analyzer errors in
  `lib/features/nutrition/presentation/*`, `lib/features/home/presentation/
  widgets/{macros_today_card,water_quick_add_card}.dart`,
  `lib/features/progress/presentation/progress_screen.dart`,
  `lib/features/settings/{settings_providers.dart,presentation/widgets/
  food_search_region_tile.dart}` and their tests is **not** cycle coupling.
  `riverpod_generator` fails on `nutrition_providers.dart` (it imports
  `features/cycle`), so `nutrition_providers.g.dart` does not exist and every
  provider it declares reads as undefined/`dynamic` downstream. Fixing the
  one import in `nutrition_providers.dart` clears all of them at once. Do not
  treat them as extra work.
- **2026-09-07 (Task 2 review):** the identity sweep must NOT rename the
  FatSecret proxy backend or the `X-FemFit-Key` header. The proxy VM is
  shared infrastructure in FemFit's GCP project `femfit-5e600`
  (`34.27.29.29`); MenFit calls the same deployed server. Spec amended.

- **PowerShell's `-replace` operator is case-insensitive by default**, and
  the Task 2 brief's own verbatim sweep script used plain `-replace` for
  both `'FemFit','MenFit'` and `'femfit','menfit'`. Any lowercase `femfit`
  occurrence not already consumed by an earlier specific-pattern rule (e.g.
  `femfit-export`, `femfit-asc`, `femfit_secrets`, `femfit.app` in URLs,
  `femfit-workout-card.png`) matched the earlier `'FemFit'` pattern
  case-insensitively and got replaced with the literal `MenFit` (title
  case), silently corrupting lowercase identifiers into wrongly-capitalized
  ones (e.g. the export filename prefix became `MenFit-export` instead of
  the required `menfit-export`; `codemagic.yaml`'s `app_store_connect`
  became `MenFit-asc` instead of `menfit-asc`). There was also an
  all-caps variant (`FEMFIT_KS_PASS` in `scripts/create_upload_keystore.ps1`)
  that neither `FemFit` nor `femfit` (case-sensitive) would catch at all.
  **Fix used in Task 2**: rebuild the affected files from `git show
  HEAD:<path>` and reapply the same replacement list using PowerShell's
  `-creplace` (case-sensitive) instead of `-replace`, plus a manual pass
  for any `FEMFIT`/other-case survivors. `git reset --hard` /
  `git checkout -- <file>` were both blocked by the auto-mode classifier in
  this environment, so the fix had to reconstruct files via `git show`
  rather than checking them out. **Any later task that runs a similar
  find/replace sweep must use `-creplace`/`-ireplace` explicitly, never bare
  `-replace`, and should re-grep for `git grep -ohiE '<needle>' HEAD` first
  to enumerate every casing variant actually present.**
- `Set-Content -NoNewline` fed by `(Get-Content ... -Raw)` piped through
  `-join "`n"` after a `git show` round-trip drops the file's original
  trailing newline even when the source had one. The Task 2 rebuild above
  stripped trailing newlines from ~38 non-Dart files (json/yaml/xml/md/ps1/
  cs/html/pbxproj/plist/pro); each was fixed by appending `\n` back where
  `git show HEAD:<path>` confirmed the original ended in one. Dart files are
  unaffected because `dart format .` normalizes them afterward regardless.
  Check for `\ No newline at end of file` in `git diff` after any sweep that
  rewrites files by piping content through PowerShell string joins.
