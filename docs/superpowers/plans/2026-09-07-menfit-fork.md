# MenFit Fork Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce MenFit, a men's strength-first training and nutrition app, by forking FemFit, removing all menstrual-cycle features, rebranding, re-theming (Forge), resetting the database schema, and shipping a signed release APK to Firebase App Distribution.

**Architecture:** Subtractive fork of the FemFit Flutter tree (Riverpod 3 codegen, go_router typed routes, Drift, freezed). Delete the `cycle` feature module and let the analyzer and the existing architecture guard tests expose every coupling; strip each one. Package rename is a single text sweep. Schema restarts at v1 because there is no installed base.

**Tech Stack:** Flutter 3.47.2 / Dart 3.13.2, drift 2.34, flutter_riverpod 3.4 + riverpod_annotation, go_router 17.5, freezed 3, build_runner, Firebase CLI 15.29 (App Distribution), Pillow (Python) for asset generation.

Spec: `docs/superpowers/specs/2026-09-07-menfit-fork-design.md`. Audit with file-level detail: `docs/femfit_fork_audit.md`.

## Global Constraints

- Source tree: `D:\Documents\Claude\Projects\Female running app` (FemFit, commit `13e91b9`). Target: `D:\Documents\Claude\Projects\MenFit` (already a git repo on `main`, remote `origin` = `https://github.com/JarrodFranz/MenFit.git`, one docs commit).
- Identity: display name `MenFit`; Dart package `menfit_app`; Android/iOS id `com.jarrodfranz.menfit`; DB file `menfit`; method channel `com.menfit.app/wearables`; map user agent `com.menfit.app`; proxy header `X-MenFit-Key`; export filename prefix `menfit-`; GPX creator `MenFit`.
- Tabs: Home, Train, Nutrition, Recovery, Settings. Train keeps route path `/activity`; Recovery uses route path `/recovery`.
- Theme seed `Color(0xFFD84A1B)`; light surface `0xFFFAF8F5`; dark surface `0xFF121212`. Colour-blind seeds unchanged.
- Nutrition: Mifflin-St Jeor male constant `+5`; RDAs iron 8 mg, calcium 1000 mg, vitamin D 15 mcg, fibre 38 g, vitamin C 90 mg.
- Wellbeing enums: `SymptomType` drops `pelvicPain`, `cramping` label "Muscle cramps"; `FlareCategory` = `injury, illness, migraine, backPain, other`.
- Schema: `schemaVersion = 1`, `onCreate: createAll`, no `onUpgrade`.
- Validation sequence before any "done": `dart run build_runner build` → `dart format .` → `flutter analyze --fatal-infos` → `flutter test`. **Only ONE `flutter test` process at a time** (concurrent runs deadlock). Never run `find /`.
- Commits: `git commit` with trailer `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`. Commit after every task.
- Never commit secrets: `env/*.secrets.json`, `android/key.properties`, keystores.
- Copy rule: no she/her pronouns in code or docs; "Recovery day", never "period".
- Keep `handoff/HANDOFF.md` and `handoff/session-log.md` current at the end of every task.

---

### Task 1: Copy the tree and rename the Dart package

**Files:**
- Create: everything under `D:\Documents\Claude\Projects\MenFit\` from FemFit except the exclusions below.
- Modify: `pubspec.yaml` (name), every `*.dart` in `lib/` and `test/`, `windows/CMakeLists.txt`, `windows/runner/Runner.rc`, `windows/runner/main.cpp`, `.claude/launch.json`, `scripts/run.ps1`.

**Interfaces:**
- Produces: a MenFit tree where `package:menfit_app/...` resolves and `flutter analyze` shows only errors caused by cycle deletion (none yet, so it must be clean).

- [ ] **Step 1: Copy with exclusions (PowerShell)**

```powershell
$src = 'D:\Documents\Claude\Projects\Female running app'
$dst = 'D:\Documents\Claude\Projects\MenFit'
robocopy $src $dst /E /XD .git build .dart_tool .idea scratch Deployments handoff docs "tools\femfit_deploy\bin" "tools\femfit_deploy\obj" /XF female_fitness_business_plan.html TASKS_TO_DO.md femfit_app.iml .flutter-plugins-dependencies "env\dev.secrets.json" "env\staging.secrets.json" /NFL /NDL /NJH
```

`robocopy` exit codes 0–7 are success. `docs/` is excluded because MenFit already has its own `docs/` (audit, spec, plan); FemFit's `docs/privacy_policy.html` and `docs/live_tracker.html` are copied separately in Step 2. `handoff/` is excluded because MenFit has its own.

- [ ] **Step 2: Bring over the two web docs and rename their branding**

```powershell
Copy-Item "$src\docs\privacy_policy.html" "$dst\docs\privacy_policy.html"
Copy-Item "$src\docs\live_tracker.html"   "$dst\docs\live_tracker.html"
```

- [ ] **Step 3: Rename the package everywhere (PowerShell)**

```powershell
Set-Location $dst
$files = Get-ChildItem -Recurse -Include *.dart,*.yaml,*.cmake,*.txt,*.rc,*.cpp,*.json,*.ps1,*.md -File |
  Where-Object { $_.FullName -notmatch '\\(build|\.dart_tool|\.git)\\' }
foreach ($f in $files) {
  $c = Get-Content $f.FullName -Raw
  if ($c -match 'femfit_app') {
    Set-Content -NoNewline -Path $f.FullName -Value ($c -replace 'femfit_app','menfit_app')
  }
}
```

- [ ] **Step 4: Verify no references remain**

Run: `Select-String -Path (Get-ChildItem -Recurse -Include *.dart,*.yaml,*.cmake,*.txt,*.rc,*.cpp -File | ? { $_.FullName -notmatch '\\(build|\.dart_tool)\\' }) -Pattern 'femfit_app' | Measure-Object`
Expected: `Count : 0`.

- [ ] **Step 5: Restore the toolchain and baseline**

```bash
flutter pub get
dart run build_runner build
flutter analyze --fatal-infos
```

Expected: analyze reports `No issues found!`. If `build_runner` complains about the removed `--delete-conflicting-outputs`, it only warns; proceed.

- [ ] **Step 6: Replace .gitignore and commit**

Append FemFit's ignore list to MenFit's `.gitignore` (keep the `.superpowers/` line), replacing the two `tools/femfit_deploy/` lines with `tools/menfit_deploy/bin/` and `tools/menfit_deploy/obj/`, and delete the `female_fitness_business_plan.html` entry.

```bash
git add -A
git commit -m "chore: fork FemFit tree at 13e91b9 and rename package to menfit_app"
```

---

### Task 2: App identity (Android, iOS, web, Windows, in-Dart) and guard tests

**Files:**
- Modify: `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `android/app/proguard-rules.pro`
- Move: `android/app/src/main/kotlin/com/jarrodfranz/femfit/MainActivity.kt` → `android/app/src/main/kotlin/com/jarrodfranz/menfit/MainActivity.kt`
- Modify: `ios/Runner.xcodeproj/project.pbxproj`, `ios/Runner/Info.plist`
- Modify: `web/manifest.json`, `web/index.html`, `windows/CMakeLists.txt`, `windows/runner/Runner.rc`, `windows/runner/main.cpp`
- Modify: `lib/app/bootstrap.dart`, `lib/core/config/env.dart`, `lib/core/platform/wearables/watch_companion_io.dart`, `lib/features/activity/presentation/widgets/live_recording_map.dart`, `lib/features/activity/presentation/widgets/route_map.dart`, `lib/features/activity/domain/activity_file_exporter.dart`, `lib/features/activity/application/activity_export_service.dart`, `lib/core/db/app_database.dart` (db name only), `lib/core/widgets/splash_screen.dart`, `lib/core/errors/error_messages.dart`, `lib/features/home/presentation/home_screen.dart` (AppBar title), `lib/features/safety/presentation/safety_settings_screen.dart` (email subject)
- Rename: `tools/femfit_deploy/` → `tools/menfit_deploy/` (and `FemFitDeploy` strings inside), `scripts/*.ps1`, `codemagic.yaml`, `backend/fatsecret-proxy/*`, `docs/privacy_policy.html`, `docs/live_tracker.html`
- Test: `test/platform/app_identity_guard_test.dart`, `test/platform/ios_infoplist_guard_test.dart`, `test/platform/android_manifest_guard_test.dart`, `test/core/config/env_files_guard_test.dart`

**Interfaces:**
- Produces: `AppEnv.appName` default `'MenFit'`; splash widget class `MenFitSplashScreen`.

- [ ] **Step 1: Update the guard tests first**

In `test/platform/app_identity_guard_test.dart` replace every `com.jarrodfranz.femfit` with `com.jarrodfranz.menfit`, every `'FemFit'` with `'MenFit'`, every `femfit` path segment with `menfit`. Same in `ios_infoplist_guard_test.dart`, `android_manifest_guard_test.dart`, `env_files_guard_test.dart` (which checks `X-FemFit-Key` → `X-MenFit-Key` if present).

- [ ] **Step 2: Run the guards to see them fail**

Run: `flutter test test/platform test/core/config/env_files_guard_test.dart`
Expected: FAIL on bundle id / display name / package dir assertions.

- [ ] **Step 3: Sweep the identity strings (PowerShell)**

```powershell
Set-Location 'D:\Documents\Claude\Projects\MenFit'
git mv android/app/src/main/kotlin/com/jarrodfranz/femfit android/app/src/main/kotlin/com/jarrodfranz/menfit
git mv tools/femfit_deploy tools/menfit_deploy
$targets = Get-ChildItem -Recurse -File -Include *.kts,*.kt,*.xml,*.pro,*.pbxproj,*.plist,*.json,*.html,*.txt,*.rc,*.cpp,*.ps1,*.yaml,*.cs,*.js,*.md,*.dart,*.sh |
  ? { $_.FullName -notmatch '\\(build|\.dart_tool|\.git|docs\\superpowers|docs\\femfit_fork_audit)' }
foreach ($f in $targets) {
  $c = Get-Content $f.FullName -Raw
  $n = $c -replace 'com\.jarrodfranz\.femfit','com.jarrodfranz.menfit' `
         -replace 'com\.femfit\.app','com.menfit.app' `
         -replace 'X-FemFit-Key','X-MenFit-Key' `
         -replace 'FemFitDeploy','MenFitDeploy' `
         -replace 'femfit_deploy','menfit_deploy' `
         -replace 'femfit-signing','menfit-signing' `
         -replace 'FemFitSplashScreen','MenFitSplashScreen' `
         -replace 'femfit_logo','menfit_logo' `
         -replace 'femfit_splash','menfit_splash' `
         -replace "driftDatabase\(\s*name: 'femfit'","driftDatabase(name: 'menfit'" `
         -replace 'FemFit','MenFit' `
         -replace 'femfit','menfit'
  if ($n -ne $c) { Set-Content -NoNewline -Path $f.FullName -Value $n }
}
```

Then rename the asset files: `git mv assets/images/femfit_logo.png assets/images/menfit_logo.png` (and `_solid`, `_splash`). The image contents are replaced in Task 9.

- [ ] **Step 4: Manually verify the places sed cannot reason about**

- `android/app/build.gradle.kts`: `namespace = "com.jarrodfranz.menfit"`, `applicationId = "com.jarrodfranz.menfit"`.
- `android/app/src/main/kotlin/com/jarrodfranz/menfit/MainActivity.kt`: `package com.jarrodfranz.menfit`.
- `ios/Runner.xcodeproj/project.pbxproj`: six `PRODUCT_BUNDLE_IDENTIFIER` lines now `com.jarrodfranz.menfit` / `com.jarrodfranz.menfit.RunnerTests`.
- `ios/Runner/Info.plist`: `CFBundleDisplayName` and `CFBundleName` = `MenFit`.
- `lib/core/db/app_database.dart`: `driftDatabase(name: 'menfit', ...)`.
- `distribution/android.json` still holds the MenFit Firebase app id `1:717515032244:android:8e561294083fcbfa5ef9e1` (it was written before the sweep; confirm the sweep did not alter it).
- `codemagic.yaml`: bundle id `com.jarrodfranz.menfit`; integration `menfit-asc`; var group `menfit_secrets`; leave the tag trigger `ios-v*`.

- [ ] **Step 5: Run guards, analyze**

Run: `flutter test test/platform test/core/config/env_files_guard_test.dart && flutter analyze --fatal-infos`
Expected: all guard tests PASS; `No issues found!`.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "chore: MenFit app identity (com.jarrodfranz.menfit) across Android, iOS, web, Windows and Dart"
```

---

### Task 3: Delete the cycle module and strip the small couplings

**Files:**
- Delete: `lib/features/cycle/` (entire dir), `lib/core/db/tables/cycle_records.dart`, `test/features/cycle/` (entire dir), `test/features/cycle_flow_test.dart`
- Modify: `lib/core/db/app_database.dart` (remove `CycleRecords` import + table entry only; migration body is handled in Task 8), `lib/app/router/routes.dart`, `lib/core/theme/tokens.dart`, `lib/features/streaks/domain/streak_assembly.dart`, `lib/features/streaks/domain/today_protection_sources.dart`, `lib/features/streaks/streaks_providers.dart`, `lib/features/streaks/domain/recovery_validation.dart` (doc only), `lib/features/home/presentation/widgets/today_sheet.dart`, `lib/features/home/presentation/home_screen.dart`, `lib/features/settings/application/delete_my_data_service.dart`, `lib/features/settings/settings_providers.dart`, `lib/features/settings/presentation/settings_screen.dart`, `lib/core/platform/wearables/watch_companion_adapter.dart`, `watch_companion_protocol.dart`, `watch_companion_io.dart`, `watch_companion_stub.dart`, `lib/features/wearables/domain/wearable_workout_sync_service.dart`, `lib/features/wearables/wearables_providers.dart`, `lib/features/data_export/domain/data_export_tables.dart` and its callers, `lib/features/accessibility/domain/accessibility_preferences.dart` (docs), `lib/features/challenges/domain/challenge_validation.dart` (docs), `lib/core/widgets/month_calendar.dart` (docs), `lib/core/widgets/splash_screen.dart` (docs)
- Test: `test/app/app_shell_test.dart`, `test/core/adaptive_scaffold_test.dart`, `test/core/adaptive_scaffold_real_font_test.dart`, `test/accessibility/a11y_*_test.dart` (five files listing shell screens), `test/features/streaks/**`, `test/features/home/**`, `test/features/settings/**`, `test/features/wearables/**`, `test/features/data_export/data_export_table_coverage_test.dart`, `test/core/theme/**`

**Interfaces:**
- Produces: `assembleStreakResult({required List<Activity> activities, required Set<LocalDate> recoveryDays, required Set<LocalDate> flareProtectedDays, required LocalDate today})`; `TodayProtectionSources({required bool hasExplicitRecoveryDay, required bool hasProtectingFlare, String? recoveryNote})`; `AppTokens` without any `cyclePhase*` member; `sensitiveHealthTables` constant in `data_export_tables.dart`; shell with five branches (Cycle removed; Wellbeing renamed in Task 5).

- [ ] **Step 1: Delete**

```bash
git rm -r -q lib/features/cycle lib/core/db/tables/cycle_records.dart test/features/cycle test/features/cycle_flow_test.dart
```

- [ ] **Step 2: Database table list**

In `lib/core/db/app_database.dart` remove the `import '.../tables/cycle_records.dart';` line and the `CycleRecords,` entry in `@DriftDatabase(tables: [...])`. Leave the migration body alone for now (Task 8 replaces it); if the `from < 3` branch references `cycleRecords`, delete just that branch's `createTable(cycleRecords)` line so the file compiles.

- [ ] **Step 3: Routes and shell**

In `lib/app/router/routes.dart`:
- Delete the `import` of `cycle_screen.dart`.
- Delete the `TypedStatefulShellBranch<CycleBranchData>(routes: [TypedGoRoute<CycleRouteData>(path: '/cycle')])` entry.
- Delete `class CycleRouteData ...` and `class CycleBranchData ...`.
- Delete the `AdaptiveDestination(icon: Icons.favorite_outline, selectedIcon: Icons.favorite, label: 'Cycle')` entry.
- Update the doc comment to "five-tab".
Run `dart run build_runner build` to regenerate `routes.g.dart`.

- [ ] **Step 4: Theme tokens**

In `lib/core/theme/tokens.dart` remove the four `cyclePhase*` fields from: the constructor (`required this.cyclePhase...` ×4), the palette tuples (every `switch` arm returns a 9-tuple; make each a 5-tuple `(success, warning, intensityEasy, intensityModerate, intensityHard)` by deleting positions 3–6, i.e. the `menstrual, follicular, ovulatory, luteal` values), the destructuring `final (success, warning, menstrual, follicular, ovulatory, luteal, intensityEasy, intensityModerate, intensityHard) =` → `final (success, warning, intensityEasy, intensityModerate, intensityHard) =`, the `AppTokens(...)` return, the `final Color` declarations, `copyWith`, and `lerp`. Update the class doc to drop "cycle phases".

- [ ] **Step 5: Streaks**

`lib/features/streaks/domain/streak_assembly.dart`:
- Remove imports of `cycle_record.dart` and `period_days.dart`.
- Remove parameters `records` and `pausingEnabled` from `assembleStreakResult` and from the protected-days helper below it; remove the `if (!pausingEnabled || records.isEmpty)` early return and the `...periodDaysInRange(...)` spread. The union becomes `{...recoveryDays, ...flareProtectedDays}`.

`lib/features/streaks/domain/today_protection_sources.dart`: remove `required bool isPeriodProtected`; `hasAnySource => hasExplicitRecoveryDay || hasProtectingFlare`; remove the period argument from `assembleTodayProtectionSources`.

`lib/features/streaks/streaks_providers.dart`: remove the three `cycleRepositoryProvider` watches (`watchRecords()`, `watchStreakPausingEnabled()`) and the arguments they fed. Regenerate.

Tests: in `test/features/streaks/**` delete every test whose name mentions period/pausing/cycle; in the remaining tests delete the `records:` and `pausingEnabled:` arguments and the `isPeriodProtected:` field.

- [ ] **Step 6: Home, settings, delete-my-data, watch, wearables, export**

- `today_sheet.dart`: delete `_PeriodSourceTile`, the `sources.isPeriodProtected` branch, and the "Cycle settings" button. Update `home_screen.dart` doc comment ("Your Cycle in Motion" → "monthly recap").
- `delete_my_data_service.dart`: remove the `CycleRepository` field/ctor param, the `cycleRepository.deleteAllData()` and `clearStreakPausingPreference()` calls, and the `cycle:<uuid>` recap-marker purge. `settings_providers.dart`: remove the injection. Regenerate.
- `settings_screen.dart`: "Automatic Cycle & Monthly Recaps" → "Automatic monthly recaps"; delete-data copy loses "cycle"/"period".
- Watch companion: delete `WatchCycleContext` and `sendCycleContext` from adapter, protocol, io, stub, and any test in `test/core/platform/wearables/`.
- `wearable_workout_sync_service.dart`: remove the three cycle imports, ctor params `cycleRepository` and `predictionEngine`, `_resolveCyclePhase`, and the phase tagging block; `wearables_providers.dart` stops passing them. Fix `test/features/wearables/**` accordingly.
- `data_export_tables.dart`: rename `cycleAndWellbeingTables` → `sensitiveHealthTables` and drop `'cycle_records'`. Update callers (`drift_data_exporter.dart`, `data_export_service.dart`, `data_export_source.dart`, `data_export_widgets.dart`, notice dialogs) and `test/features/data_export/data_export_table_coverage_test.dart`. User-facing copy: "cycle and wellbeing data" → "health check-in data".
- Doc comments in `accessibility_preferences.dart`, `challenge_validation.dart`, `month_calendar.dart`, `splash_screen.dart`, `recovery_validation.dart`: rewrite the sentences that mention the cycle calendar.

- [ ] **Step 7: Shell and a11y tests**

In `test/app/app_shell_test.dart` (both label lists), `test/core/adaptive_scaffold_test.dart`, `test/core/adaptive_scaffold_real_font_test.dart`, and each of `test/accessibility/a11y_color_and_os_scale_audit_test.dart`, `a11y_enhanced_semantics_test.dart`, `a11y_large_touch_targets_test.dart`, `a11y_navigation_labels_test.dart`, `a11y_shell_tabs_audit_test.dart`: remove the `'Cycle'` entry / `A11yScreen(name: 'Cycle', ...)`; change "6 destinations" wording to "5".

- [ ] **Step 8: Compile-fix loop**

Run: `dart run build_runner build && flutter analyze --fatal-infos`
Expected at first: errors only in insights, recaps, achievements, activity milestones/share dialog, nutrition micronutrient, weight (these are Tasks 4–7). Any error outside those modules belongs to this task: fix it. Stop when the remaining errors are confined to `lib/features/{insights,recaps,achievements,activity/domain/milestone*,activity/presentation/widgets/workout_*,nutrition/domain/micronutrient*,nutrition/presentation/widgets/micronutrient*,nutrition/nutrition_providers.dart,weight}` and their tests.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "feat!: remove cycle tracking module, table, tab and streak/home/settings/wearable couplings"
```

---

### Task 4: Insights without cycle phase

**Files:**
- Delete: `lib/features/insights/domain/evaluators/cycle_phase_evaluator.dart`, `test/features/insights/cycle_phase_evaluator_test.dart`
- Modify: `lib/features/insights/domain/daily_observation.dart`, `evaluators/group_comparison.dart`, `domain/insight_engine.dart`, `domain/insight_thresholds.dart`, `domain/personal_insight.dart`, `application/insight_observation_mapper.dart`, `presentation/insight_sentence.dart`, `insights_providers.dart`
- Test: `test/features/insights/**`

**Interfaces:**
- Consumes: nothing new.
- Produces: `DailyObservation` without `cyclePhase`/`hasCyclePhase`; `InsightEngine` without `cyclePhaseEvaluator`; `InsightKind` without `cyclePhaseExertion`/`cyclePhaseOutput`; `InsightGroup` without `cyclePhaseFocus`/`otherCyclePhases`; `mapDailyObservations(...)` without `phaseByDay`.

- [ ] **Step 1: Delete the evaluator and its test**

```bash
git rm -q lib/features/insights/domain/evaluators/cycle_phase_evaluator.dart test/features/insights/cycle_phase_evaluator_test.dart
```

- [ ] **Step 2: Strip the field through the chain**

- `daily_observation.dart`: remove `CyclePhase? cyclePhase` (freezed field) and `bool get hasCyclePhase`; remove the cycle import.
- `group_comparison.dart`: remove the `cyclePhase` parameter and any branch that reads it; the function stays generic over `Set<DailyObservation>` arms.
- `insight_engine.dart`: remove the `cyclePhaseEvaluator` field, ctor param and the call in `evaluate`.
- `insight_thresholds.dart`: remove `minCliffsDeltaCyclePhase`.
- `personal_insight.dart`: remove `InsightKind.cyclePhaseExertion`, `InsightKind.cyclePhaseOutput`, `InsightGroup.cyclePhaseFocus`, `InsightGroup.otherCyclePhases` and any `switch` arms over them.
- `insight_observation_mapper.dart`: remove the `phaseByDay` parameter and the assignment.
- `insight_sentence.dart`: remove the cycle branches of `_groupPhrase` / `_phraseFor`.
- `insights_providers.dart`: delete the `phaseByDay` construction (lines ~96–110) and its cycle imports.
Regenerate.

- [ ] **Step 3: Tests**

In `test/features/insights/**` remove `cyclePhase:` arguments, `phaseByDay:` arguments, and tests named for cycle phases. Keep every day-of-week / hydration / protein / wellbeing test.

Run: `flutter test test/features/insights`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat!: insights engine drops cycle-phase evaluator and observations"
```

---

### Task 5: Recaps are month-end only

**Files:**
- Rename: `lib/features/recaps/domain/cycle_recap.dart` → `month_recap.dart` (class `CycleRecap` → `MonthRecap`)
- Modify: `domain/recap_period.dart`, `domain/recap_trigger_evaluator.dart`, `domain/recap_pr_highlight.dart`, `domain/recap_builder.dart`, `data/recap_marker_store.dart`, `presentation/recap_trigger_controller.dart`, `presentation/recap_story_screen.dart`, `presentation/widgets/recap_slides.dart`, `presentation/widgets/recap_share_sheet.dart`, `presentation/widgets/recap_history_section.dart`, `recaps_providers.dart`
- Test: `test/features/recaps/**`

**Interfaces:**
- Produces: `RecapPeriodKind { monthEnd }` only; `RecapPeriod.forCalendarMonth(...)` unchanged; `RecapTriggerDecision` has `MonthEndDue` and `NothingDue` only; `MonthRecap` class; `RecapPrHighlight` without `phase`/`displayPhase`; `buildRecap(...)` without `phaseByDay`/`hasAnyCycleData`; marker store keeps `recaps_last_shown_month_key` only.

- [ ] **Step 1: Rename the class**

```bash
git mv lib/features/recaps/domain/cycle_recap.dart lib/features/recaps/domain/month_recap.dart
```
Then replace `CycleRecap` → `MonthRecap` and `cycle_recap.dart` → `month_recap.dart` across `lib/` and `test/` (PowerShell `-replace` over `*.dart`).

- [ ] **Step 2: Remove the cycle-end path**

- `recap_period.dart`: delete `RecapPeriodKind.cycleEnd`, `forCompletedCycle`, `completedCyclePeriods`, cycle imports; any `switch` on the kind keeps only `monthEnd`.
- `recap_trigger_evaluator.dart`: delete `CycleEndDue` and the precedence rule; the evaluator returns `MonthEndDue` when the month recap qualifies (≥3 sessions in the month, not yet shown), else `NothingDue`.
- `recap_pr_highlight.dart`: delete `CyclePhase? phase` and `displayPhase`.
- `recap_builder.dart`: delete `phaseByDay`, `hasAnyCycleData` and the `cycleEnd` branch.
- `recap_marker_store.dart`: delete `recaps_last_shown_cycle_key` and its accessors.
- `recaps_providers.dart`: delete the phase map (lines ~208–244) and cycle repository watches.
- `recap_slides.dart`: label becomes `'Monthly Summary · '`; delete the phase pill. `recap_share_sheet.dart`: default theme remains whatever `ShareCardTheme` default is (renamed in Task 10).
- Settings toggle copy already changed in Task 3.
Regenerate.

- [ ] **Step 3: Tests**

In `test/features/recaps/**` delete cycle-end trigger tests and `phase:` arguments; keep month-end tests.

Run: `flutter test test/features/recaps`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat!: recaps are month-end only; CycleRecap renamed MonthRecap"
```

---

### Task 6: Achievements, milestones and the share dialog

**Files:**
- Modify: `lib/features/achievements/domain/badge_inputs.dart`, `badge_metrics.dart`, `badge_definition.dart`, `badge_catalogue_tiered.dart`, `badge_catalogue_one_offs.dart`, `badge_catalogue.dart` (docs), `achievements_providers.dart`, `presentation/achievements_copy.dart`
- Modify: `lib/features/activity/domain/workout_milestone.dart`, `domain/milestone_evaluator.dart`, `presentation/widgets/workout_celebration_dialog.dart`, `presentation/widgets/workout_share_dialog.dart`, and the five finishing flows that pass `phase:` (`recording_controller.dart`, `strength_tracker_controller.dart`, `hiit_tracker_controller.dart`, `mindful_tracker_controller.dart`, `swim_tracker_controller.dart`, plus their screens)
- Test: `test/features/achievements/**`, `test/features/activity/**` (milestone, celebration, share tests)

**Interfaces:**
- Produces: `BadgeInputs` without `cycleRecords`; `BadgeCategory` without `cycleTracking`; `WorkoutMilestoneType` without `cyclePhasePr`; `evaluateWorkoutMilestones(...)` without `phase`; `WorkoutCelebrationDialog` / `WorkoutShareDialog` without `phase`.

- [ ] **Step 1: Achievements**

- `badge_inputs.dart`: remove `List<CycleRecord> cycleRecords`.
- `badge_metrics.dart`: remove `_cycleLoggingMonths`, `BadgeMetric.cycleLoggingMonths`, `BadgeCondition.firstCompletedCycleRecord` and their switch arms.
- `badge_catalogue_tiered.dart`: delete the `cycle_logging_months` definition. `badge_catalogue_one_offs.dart`: delete `first_completed_cycle`.
- `badge_definition.dart`: delete `BadgeCategory.cycleTracking` and its `'Cycle notes'` label.
- `achievements_providers.dart`: stop watching the cycle repository.
- Any test asserting the total badge count: decrement by 2.

- [ ] **Step 2: Milestones**

- `workout_milestone.dart`: delete `WorkoutMilestoneType.cyclePhasePr` and its label/icon arms.
- `milestone_evaluator.dart`: delete the three `cyclePhasePr` emit blocks and the `CyclePhase? phase` parameters.
- `workout_celebration_dialog.dart`: delete the `phase` param and pill.
- `workout_share_dialog.dart`: delete `_showCyclePhase`, its filter, toggle row, rendered pill and share-text gate; delete the `phase` param.
- Each finishing flow: stop resolving and passing `phase:` (and remove `cycleRepositoryProvider` / `cyclePredictionEngineProvider` reads).
Regenerate.

- [ ] **Step 3: Tests and run**

Delete cycle-phase PR tests, phase-pill tests, and `phase:` arguments in `test/features/achievements/**` and `test/features/activity/**`.

Run: `flutter test test/features/achievements test/features/activity`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat!: drop cycle badges, cycle-phase PR milestone and share-card phase pill"
```

---

### Task 7: Nutrition for men and weight chart without phase overlay

**Files:**
- Modify: `lib/features/nutrition/domain/energy_estimate.dart`, `domain/micronutrient_adequacy.dart`, `presentation/widgets/micronutrient_adequacy_card.dart`, `presentation/widgets/micronutrient_info_sheet.dart`, `nutrition_providers.dart`, `domain/macro_targets.dart` / `macro_locks.dart` / `calorie_target.dart` / `core/db/tables/nutrition_goals.dart` (doc citations → `mens_health.md`)
- Modify: `lib/features/weight/presentation/widgets/weight_trend_chart.dart`, `weight_chart_panel.dart`, `weight_view_controller.dart`, `weight_history_providers.dart`, `weight_copy.dart`, `domain/weight_trend.dart` (doc)
- Test: `test/features/nutrition/energy_estimate_test.dart`, `test/features/nutrition/micronutrient_adequacy_test.dart`, `test/features/weight/**`

**Interfaces:**
- Produces: `estimateEnergyNeeds` using `+5`; `MicronutrientType.standardDailyReference` male values; `evaluateMicronutrientAdequacy(totals: ...)` with no `cyclePhase`; `MicronutrientAdequacy` without `cyclePhase`; `WeightViewController` without `cycleOverlayVisible`.

- [ ] **Step 1: Failing test for the male constant**

In `test/features/nutrition/energy_estimate_test.dart` find the BMR expectation test and change the expected value. For the existing fixture (weight 60 kg, height 165 cm, age 30, if that is what the test uses) the female BMR is `600 + 1031.25 − 150 − 161 = 1320.25`; the male BMR is `600 + 1031.25 − 150 + 5 = 1486.25`. Replace with the fixture's own numbers: `expected = 10*w + 6.25*h − 5*a + 5`.

Run: `flutter test test/features/nutrition/energy_estimate_test.dart`
Expected: FAIL (off by 166).

- [ ] **Step 2: Implement**

In `energy_estimate.dart`:

```dart
  final bmr = (10 * weight) + (6.25 * height) - (5 * age) + _maleConstant;
```
```dart
/// Mifflin-St Jeor's male constant, added to the weight/height/age terms.
/// MenFit's population is men and the profile deliberately does not ask
/// for sex, so the male variant is applied to everyone; the estimate is
/// labelled as an estimate everywhere it is shown. The female variant
/// subtracts 161 instead.
const double _maleConstant = 5;
```
Rewrite the surrounding dartdoc (lines ~154–170) to match.

Run the test again. Expected: PASS.

- [ ] **Step 3: Failing tests for RDAs**

In `test/features/nutrition/micronutrient_adequacy_test.dart` change the reference expectations to `iron 8.0`, `calcium 1000.0`, `vitaminD 15.0`, `fiber 38.0`, `vitaminC 90.0`; delete tests that pass `cyclePhase:` or assert the menstrual banner. Run; expected FAIL on iron/fibre/vitamin C.

- [ ] **Step 4: Implement RDAs and strip the cycle field**

`micronutrient_adequacy.dart`:

```dart
  /// Standard daily reference intake for adult males (19–50, DRI).
  double get standardDailyReference => switch (this) {
    MicronutrientType.iron => 8.0,
    MicronutrientType.calcium => 1000.0,
    MicronutrientType.vitaminD => 15.0,
    MicronutrientType.fiber => 38.0,
    MicronutrientType.vitaminC => 90.0,
  };

  /// Informational rationale for active men.
  String get biologicalRationale => switch (this) {
    MicronutrientType.iron =>
      'Carries oxygen (haemoglobin) and powers cellular energy. Endurance '
          'training raises losses through foot-strike haemolysis and sweat.',
    MicronutrientType.calcium =>
      'Builds bone mineral density and drives muscle contraction; protects '
          'against bone stress injuries under high training loads.',
    MicronutrientType.vitaminD =>
      'Needed to absorb calcium, for skeletal recovery and immune defence.',
    MicronutrientType.fiber =>
      'Supports gut health, steady energy and satiety during a cut.',
    MicronutrientType.vitaminC =>
      'Supports collagen synthesis, tissue repair and iron absorption.',
  };
```
Remove the `cycle_prediction_engine` import, the `CyclePhase? cyclePhase` field and parameter, and any phase-based adjustment. Update the enum member docs ("adult male").

`micronutrient_adequacy_card.dart`: delete the menstrual context banner. `micronutrient_info_sheet.dart`: heading `'Micronutrients & Recovery'`, replace the iron/menstruation paragraph with endurance-loss wording, keep the "not medical advice" footer. `nutrition_providers.dart`: delete `dayCycleStatusProvider` and the `cyclePhase:` argument. Doc citations `womens_health.md` → `mens_health.md` in the four files listed.

Run: `flutter test test/features/nutrition`
Expected: PASS.

- [ ] **Step 5: Weight chart**

- `weight_trend_chart.dart`: delete `phaseByDay`, `bandedCyclePhases`, `_phaseBands` and their rendering; `weight_chart_panel.dart` stops passing them.
- `weight_view_controller.dart`: delete `cycleOverlayVisible`, `overlayVisibleWhen`, `setCycleOverlayVisible`.
- `weight_history_providers.dart`: delete `weightHasCycleContext`. `weight_copy.dart`: delete `weightCycleContextNote`. `weight_trend.dart`: fix the doc line.
- Tests: delete overlay tests in `test/features/weight/**`.

Run: `flutter test test/features/weight`
Expected: PASS.

- [ ] **Step 6: Whole-tree analyze**

Run: `dart run build_runner build && flutter analyze --fatal-infos`
Expected: `No issues found!` (all cycle couplings are now gone). If the domain import guard test still finds a `features/cycle` import anywhere, fix it here.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat!: male energy constant and reference intakes; weight chart drops cycle overlay"
```

---

### Task 8: Reset the database schema to v1

**Files:**
- Modify: `lib/core/db/app_database.dart`
- Test: `test/core/db/app_database_test.dart` (replace), keep `test/architecture/**`

**Interfaces:**
- Produces: `AppDatabase.schemaVersion == 1`; `MigrationStrategy(onCreate: (m) => m.createAll())`.

- [ ] **Step 1: Write the replacement test**

Replace the contents of `test/core/db/app_database_test.dart` with:

```dart
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/db/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('schema version is 1 (fresh app, no migration chain)', () {
    expect(db.schemaVersion, 1);
  });

  test('onCreate creates every table the app uses', () async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    const expected = {
      'user_profiles',
      'activities',
      'activity_samples',
      'daily_checkins',
      'flare_events',
      'recovery_days',
      'routes',
      'foods',
      'nutrition_entries',
      'nutrition_goals',
      'water_logs',
      'strength_routines',
      'strength_cycles',
      'weight_logs',
      'badge_awards',
      'challenges',
      'daily_step_totals',
      'yoga_sequences',
      'wellbeing_events',
    };
    expect(names.containsAll(expected), isTrue,
        reason: 'missing: ${expected.difference(names)}');
    expect(names.contains('cycle_records'), isFalse);
  });

  test('a profile round-trips through the fresh schema', () async {
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            id: 'u1',
            displayName: 'Test',
            unitSystem: 'metric',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
    final row = await db.select(db.userProfiles).getSingle();
    expect(row.displayName, 'Test');
  });
}
```
Adjust the `UserProfilesCompanion.insert` arguments to the real required columns of `lib/core/db/tables/user_profiles.dart` (read the table file; add any other `required` columns with sensible values). Verify the actual table names in `sqlite_master` against each table class's `@DataClassName`/`tableName` before finalising `expected`.

Run: `flutter test test/core/db/app_database_test.dart`
Expected: the version test FAILS (25 ≠ 1); the others may pass.

- [ ] **Step 2: Collapse the migration**

In `lib/core/db/app_database.dart`:
- `int get schemaVersion => 1;`
- Replace the whole `MigrationStrategy get migration => MigrationStrategy(onCreate: ..., onUpgrade: ...)` with:

```dart
  /// MenFit forked from FemFit with no installed base, so the schema starts
  /// again at v1 with a clean `createAll`. Future changes: bump
  /// [schemaVersion], add an `onUpgrade` branch, and never edit this
  /// baseline in place (`knowledge/troubleshooting/database_migrations.md`).
  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (m) => m.createAll());
```
- Delete the private helpers used only by migrations: `_seedWeightLogFromProfile`, `_addOptionalNutrientColumns`, `_addVolumeColumns`, `_addColumnsIfMissing`, and the long migration dartdoc block (lines ~70–480). Keep the class doc's first paragraph.
- Check whether any table file has a column whose `withDefault`/nullability only existed to satisfy a migration (e.g. comments saying "nullable because pre-vN rows"); leave them, they are harmless.

Run: `dart run build_runner build && flutter test test/core/db && flutter analyze --fatal-infos`
Expected: PASS; no issues.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "feat!: reset Drift schema to v1 with a clean createAll"
```

---

### Task 9: Wellbeing becomes Recovery; enums for men

**Files:**
- Modify: `lib/app/router/routes.dart` (label, icon, path), `lib/features/wellbeing/presentation/wellbeing_screen.dart` (title), `lib/features/wellbeing/domain/symptom_type.dart`, `lib/features/wellbeing/domain/flare_event.dart`, `lib/features/wellbeing/presentation/flare_dialog.dart`, `checkin_sheet.dart` (chip labels), `lib/features/home/presentation/widgets/today_sheet.dart` (any "Wellbeing" copy)
- Test: `test/features/wellbeing/**`, `test/app/wellbeing_branch_test.dart`, shell + a11y tests from Task 3 Step 7

**Interfaces:**
- Produces: route `/recovery` (`WellbeingRouteData` class name unchanged); nav label `'Recovery'`; `SymptomType { cramping, backPain, fatigue, bloating, giSymptoms, headache, other }`; `FlareCategory { injury, illness, migraine, backPain, other }`.

- [ ] **Step 1: Failing enum tests**

Add to `test/features/wellbeing/flare_event_test.dart` (create if absent):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/wellbeing/domain/flare_event.dart';
import 'package:menfit_app/features/wellbeing/domain/symptom_type.dart';

void main() {
  test('FlareCategory values are the men\'s-app set', () {
    expect(FlareCategory.values, [
      FlareCategory.injury,
      FlareCategory.illness,
      FlareCategory.migraine,
      FlareCategory.backPain,
      FlareCategory.other,
    ]);
  });

  test('FlareCategory storage round-trips and unknown falls back to other', () {
    for (final c in FlareCategory.values) {
      expect(FlareCategory.fromStorage(c.toStorage()), c);
    }
    expect(FlareCategory.fromStorage('periodSymptoms'), FlareCategory.other);
    expect(FlareCategory.fromStorage(null), isNull);
  });

  test('SymptomType has no pelvicPain and cramping reads as muscle cramps', () {
    expect(SymptomType.values.map((s) => s.name), isNot(contains('pelvicPain')));
    expect(SymptomType.cramping.label, 'Muscle cramps');
    expect(SymptomType.fromStorage('pelvicPain'), SymptomType.other);
  });
}
```

Run: `flutter test test/features/wellbeing/flare_event_test.dart`
Expected: FAIL (compile error: `FlareCategory.injury` undefined).

- [ ] **Step 2: Implement the enums**

`flare_event.dart`:

```dart
enum FlareCategory {
  injury,
  illness,
  migraine,
  backPain,
  other;

  static FlareCategory? fromStorage(String? value) {
    if (value == null) return null;
    return switch (value) {
      'injury' => FlareCategory.injury,
      'illness' => FlareCategory.illness,
      'migraine' => FlareCategory.migraine,
      'backPain' => FlareCategory.backPain,
      _ => FlareCategory.other,
    };
  }

  String toStorage() => switch (this) {
    FlareCategory.injury => 'injury',
    FlareCategory.illness => 'illness',
    FlareCategory.migraine => 'migraine',
    FlareCategory.backPain => 'backPain',
    FlareCategory.other => 'other',
  };

  String get label => switch (this) {
    FlareCategory.injury => 'Injury',
    FlareCategory.illness => 'Illness',
    FlareCategory.migraine => 'Migraine',
    FlareCategory.backPain => 'Back pain',
    FlareCategory.other => 'Other',
  };
}
```
Keep any other members the enum had (icon, description) and map them to the new values. Wherever `FlareCategory.custom` was used for the free-text template feature, use `FlareCategory.other`.

`symptom_type.dart`: remove `pelvicPain` from the enum, `fromStorage` (falls to `other`), `toStorage`, `label`, and any icon/description switch; `cramping` label `'Muscle cramps'`.

Fix `flare_dialog.dart`, `checkin_sheet.dart`, `wellbeing_glyphs.dart` and any `switch` that is now non-exhaustive.

Run: `flutter test test/features/wellbeing`
Expected: PASS (delete tests that asserted the removed values).

- [ ] **Step 3: Rename the tab**

- `routes.dart`: `TypedGoRoute<WellbeingRouteData>(path: '/recovery')`; destination `AdaptiveDestination(icon: Icons.self_improvement_outlined, selectedIcon: Icons.self_improvement, label: 'Recovery')`.
- `wellbeing_screen.dart`: `title: const Text('Recovery')`.
- Sweep `'/wellbeing'` → `'/recovery'` in `lib/` and `test/` (`*.dart`), and `'Wellbeing'` nav-label expectations → `'Recovery'` in `test/app/app_shell_test.dart`, `test/app/wellbeing_branch_test.dart`, `test/core/adaptive_scaffold*_test.dart`, `test/accessibility/a11y_*_test.dart`. Screen-internal strings like "Wellbeing check-in" become "Recovery check-in".
Regenerate.

Run: `flutter test test/app test/core test/accessibility test/features/wellbeing test/features/home`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat: Wellbeing tab becomes Recovery; flare categories and symptoms for men"
```

---

### Task 10: Train tab and strength-first Home

**Files:**
- Modify: `lib/app/router/routes.dart` (Activity destination label/icon), `lib/features/activity/presentation/activity_screen.dart` (AppBar title, primary action row)
- Create: `lib/features/home/presentation/widgets/today_session_card.dart`
- Modify: `lib/features/home/presentation/home_screen.dart` (card order, AppBar title `MenFit`)
- Test: `test/features/home/today_session_card_test.dart` (create), `test/app/app_shell_test.dart` (label `'Train'`), `test/features/activity/activity_screen_test.dart` (if it asserts the title)

**Interfaces:**
- Consumes: `activeStrengthCycleProvider` (`Stream<StrengthCycle?>`, `lib/features/activity/activity_providers.dart:68`), `StrengthCycle` (`lib/features/activity/domain/strength_routine.dart:193` — read it for the fields: routine name, current week/day, total weeks), `StrengthTrackerRouteData` (`routes.dart`), `HomeCard` (`home_card.dart`).
- Produces: `TodaySessionCard` widget.

- [ ] **Step 1: Failing widget test**

`test/features/home/today_session_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/theme/app_theme.dart';
import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/home/presentation/widgets/today_session_card.dart';

void main() {
  Widget host(List<Override> overrides) => ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: TodaySessionCard()),
        ),
      );

  testWidgets('shows a start-a-routine prompt when no strength cycle is active',
      (tester) async {
    await tester.pumpWidget(host([
      activeStrengthCycleProvider.overrideWith((ref) => Stream.value(null)),
    ]));
    await tester.pumpAndSettle();
    expect(find.text("Today's session"), findsOneWidget);
    expect(find.text('Start a routine'), findsOneWidget);
  });
}
```
Add a second test that overrides the provider with a real `StrengthCycle` fixture (build it from the domain constructor; look at `test/features/activity/active_strength_cycle_provider_test.dart` for how existing tests construct one) and expects the routine name and `'Start workout'`.

Run: `flutter test test/features/home/today_session_card_test.dart`
Expected: FAIL (widget missing).

- [ ] **Step 2: Implement the card**

`today_session_card.dart`: a `ConsumerWidget` that watches `activeStrengthCycleProvider`, renders inside `HomeCard` with title `"Today's session"`; when data is null → subtitle `'No routine running'` and a `FilledButton` `'Start a routine'` navigating to `ExerciseHubRouteData(type: 'strength')` (confirm the parameter name in `routes.dart`); when a cycle exists → routine name, `'Week ${cycle.currentWeek} of ${cycle.totalWeeks}'` (use the real field names), and `FilledButton` `'Start workout'` navigating to `StrengthTrackerRouteData` with the same arguments the strength hub uses to launch the active cycle (`strength_custom_section.dart` shows the call). Loading/error states render the title only.

- [ ] **Step 3: Home order and titles**

`home_screen.dart`: AppBar title `'MenFit'` (already swept), and children order:

```dart
const RecapTriggerListener(),
const HomeWelcomeHeader(),
SizedBox(height: tokens.spacingMd),
const TodaySessionCard(),
SizedBox(height: tokens.spacingSm),
const StreakCard(),
const CheckinCard(),
SizedBox(height: tokens.spacingSm),
HomeCardLayout(
  twoColumn: twoColumn,
  cards: const [
    MacrosTodayCard(),
    WaterQuickAddCard(),
    RecentAchievementCard(),
    StepsRingCard(),
    ProgressSummaryCard(),
    TodayOverviewCard(),
  ],
),
```

- [ ] **Step 4: Train tab**

`routes.dart`: Activity destination → `AdaptiveDestination(icon: Icons.fitness_center_outlined, selectedIcon: Icons.fitness_center, label: 'Train')`. `activity_screen.dart`: AppBar title `'Train'`; in the type chip row, reorder so `strength` is the first chip after `All` (build the list as `[ActivityType.strength, ...ActivityType.values.where((t) => t != ActivityType.strength)]`). Update test expectations (`'Activity'` → `'Train'` in shell/a11y tests).

Run: `flutter test test/app test/accessibility test/features/home test/features/activity`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: Train tab and strength-first Home with today's session card"
```

---

### Task 11: Forge theme, share-card themes, copy and pronoun sweep

**Files:**
- Modify: `lib/core/theme/app_theme.dart`, `lib/core/theme/tokens.dart` (docs), `lib/features/activity/presentation/widgets/workout_share_dialog.dart`, `lib/features/recaps/presentation/widgets/recap_share_sheet.dart`, `lib/features/onboarding/presentation/onboarding_steps.dart`, and every `lib/**/*.dart` / `test/**/*.dart` containing she/her wording
- Test: `test/core/theme/**`, `test/features/activity/workout_share_dialog_test.dart` (theme names), `test/features/onboarding/**`

**Interfaces:**
- Produces: `AppTheme._seed = Color(0xFFD84A1B)`; `enum ShareCardTheme { forgeDark, forgeLight, clean }` with `forgeDark` default.

- [ ] **Step 1: Theme test**

Add to `test/core/theme/app_theme_test.dart` (create if absent):

```dart
test('Forge seed drives the default light and dark schemes', () {
  final light = AppTheme.light();
  final dark = AppTheme.dark();
  expect(light.colorScheme.primary, ColorScheme.fromSeed(seedColor: const Color(0xFFD84A1B)).primary);
  expect(light.scaffoldBackgroundColor, const Color(0xFFFAF8F5));
  expect(dark.scaffoldBackgroundColor, const Color(0xFF121212));
});
```
Run; expected FAIL.

- [ ] **Step 2: Implement**

`app_theme.dart`: `static const Color _seed = Color(0xFFD84A1B);`, class doc "seeded from Forge burnt orange on charcoal". In `light()` set `surface: const Color(0xFFFAF8F5)` on the `copyWith` and `scaffoldBackgroundColor` accordingly; in `dark()` `surface: const Color(0xFF121212)`. Keep every accessibility branch as it is. Remove "orchid"/"lilac"/"plum" wording from comments in `app_theme.dart` and `tokens.dart`.

- [ ] **Step 3: Share-card themes and tagline**

`workout_share_dialog.dart`: rename the three `ShareCardTheme` values with this exact mapping: `signatureOrchid → forgeDark` (default; charcoal card, orange accent), `obsidianDark → forgeLight` (off-white card, orange accent), `cleanLight → clean` (white card, neutral accent). If the existing enum member names differ from these, map by position (first → `forgeDark`, second → `forgeLight`, third → `clean`). Update the colour constants of each to `0xFF121212`/`0xFFFF6D3A`, `0xFFFAF8F5`/`0xFFD84A1B`, `0xFFFFFFFF`/`0xFF1B1B1B`. Tagline at line ~558: `'Built for the work · MenFit'`. `recap_share_sheet.dart`: default `ShareCardTheme.forgeDark`. Update tests naming the themes.

- [ ] **Step 4: Onboarding copy**

`onboarding_steps.dart` line ~68–69: `'A training and nutrition companion built around how men actually train, recover and progress.'`; line ~531 privacy bullet: `'Health and location data never leave your device without explicit consent.'`. Fix onboarding tests that match the old strings.

- [ ] **Step 5: Pronoun sweep**

```powershell
$files = Get-ChildItem lib,test -Recurse -Include *.dart -File
foreach ($f in $files) {
  $c = Get-Content $f.FullName -Raw
  $n = $c -creplace '\bshe\b','they' -creplace '\bShe\b','They' -creplace '\bherself\b','themselves' -creplace '\bhers\b','theirs'
  if ($n -ne $c) { Set-Content -NoNewline -Path $f.FullName -Value $n }
}
```
Then `Select-String -Path lib,test -Pattern '\bher\b' -CaseSensitive -Recurse -Include *.dart` and hand-edit each hit (`her` is ambiguous: object → `them`, possessive → `their`). Also grep `women|woman|female` in `lib/` and rewrite each remaining sentence (expected hits: badge catalogue docs, splash, error messages, db table docs, router docs, audio docs).

Run: `dart format . && flutter analyze --fatal-infos && flutter test test/core test/features/activity test/features/onboarding test/features/recaps`
Expected: clean; PASS.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: Forge theme, share-card themes, onboarding copy and neutral wording"
```

---

### Task 12: Placeholder brand assets

**Files:**
- Create: `scripts/generate_brand_assets.py`
- Overwrite: `assets/images/app_icon.png`, `assets/images/menfit_logo.png`, `assets/images/menfit_logo_solid.png`, `assets/images/menfit_splash.png`, `android/app/src/main/res/mipmap-*/ic_launcher*.png`, `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`, `web/icons/*.png`, `web/favicon.png`, `windows/runner/resources/app_icon.ico`
- Test: `scripts/generate_ios_icons.py --check` (existing)

- [ ] **Step 1: Write the generator**

`scripts/generate_brand_assets.py`:

```python
"""Generates MenFit placeholder brand assets in the Forge palette.

    python scripts/generate_brand_assets.py

Overwrites assets/images/{app_icon,menfit_logo,menfit_logo_solid,menfit_splash}.png,
the Android mipmaps, web icons and the Windows .ico, then calls
generate_ios_icons.py. Replace with real artwork later by overwriting
assets/images/app_icon.png and re-running.
"""
from __future__ import annotations
import subprocess, sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
IMG = ROOT / "assets" / "images"
CHARCOAL, ORANGE, OFFWHITE = (18, 18, 18, 255), (255, 109, 58, 255), (250, 248, 245, 255)

def font(size: int):
    for name in ("arialbd.ttf", "Arial Bold.ttf", "DejaVuSans-Bold.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()

def emblem(size: int, bg, fg, rounded=True) -> Image.Image:
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    r = size * 0.22 if rounded else 0
    d.rounded_rectangle((0, 0, size - 1, size - 1), radius=r, fill=bg)
    # Barbell: bar + two plates each side.
    y = size / 2; bar_h = size * 0.07
    d.rounded_rectangle((size*0.14, y-bar_h/2, size*0.86, y+bar_h/2), radius=bar_h/2, fill=fg)
    for x0 in (0.16, 0.24, 0.70, 0.78):
        d.rounded_rectangle((size*x0, size*0.30, size*(x0+0.06), size*0.70), radius=size*0.02, fill=fg)
    return im

def wordmark(width: int, height: int, bg, fg) -> Image.Image:
    im = Image.new("RGBA", (width, height), bg)
    d = ImageDraw.Draw(im)
    f = font(int(height * 0.42))
    text = "MenFit"
    tw, th = d.textbbox((0, 0), text, font=f)[2:]
    d.text(((width - tw) / 2, (height - th) / 2 - height * 0.05), text, font=f, fill=fg)
    return im

def main() -> None:
    IMG.mkdir(parents=True, exist_ok=True)
    icon = emblem(1024, CHARCOAL, ORANGE)
    icon.save(IMG / "app_icon.png")
    emblem(1024, (0, 0, 0, 0), ORANGE, rounded=False).save(IMG / "menfit_logo.png")
    emblem(1024, CHARCOAL, ORANGE).save(IMG / "menfit_logo_solid.png")
    splash = Image.new("RGBA", (1242, 2688), CHARCOAL)
    e = emblem(420, CHARCOAL, ORANGE)
    splash.alpha_composite(e, ((1242 - 420) // 2, 900))
    splash.alpha_composite(wordmark(1242, 300, CHARCOAL, OFFWHITE), (0, 1360))
    splash.save(IMG / "menfit_splash.png")
    # Android mipmaps.
    res = ROOT / "android" / "app" / "src" / "main" / "res"
    for folder, px in {"mipmap-mdpi": 48, "mipmap-hdpi": 72, "mipmap-xhdpi": 96, "mipmap-xxhdpi": 144, "mipmap-xxxhdpi": 192}.items():
        d = res / folder; d.mkdir(exist_ok=True)
        icon.resize((px, px), Image.LANCZOS).save(d / "ic_launcher.png")
        icon.resize((px, px), Image.LANCZOS).save(d / "ic_launcher_round.png")
        fg = Image.new("RGBA", (px * 108 // 48,) * 2, (0, 0, 0, 0))
        inner = emblem(px, (0, 0, 0, 0), ORANGE, rounded=False)
        fg.alpha_composite(inner, ((fg.width - px) // 2,) * 2)
        fg.save(d / "ic_launcher_foreground.png")
    # Web + Windows.
    web = ROOT / "web" / "icons"; web.mkdir(exist_ok=True)
    for name, px in {"Icon-192.png": 192, "Icon-512.png": 512, "Icon-maskable-192.png": 192, "Icon-maskable-512.png": 512}.items():
        icon.resize((px, px), Image.LANCZOS).save(web / name)
    icon.resize((32, 32), Image.LANCZOS).save(ROOT / "web" / "favicon.png")
    icon.convert("RGBA").save(ROOT / "windows" / "runner" / "resources" / "app_icon.ico", sizes=[(16, 16), (32, 32), (48, 48), (256, 256)])
    subprocess.check_call([sys.executable, str(ROOT / "scripts" / "generate_ios_icons.py")])
    print("brand assets written")

if __name__ == "__main__":
    main()
```
Check `android/app/src/main/res/values/colors.xml` (or `ic_launcher_background`) and set the adaptive-icon background to `#121212` if it is defined there.

- [ ] **Step 2: Run and verify**

Run: `python scripts/generate_brand_assets.py && python scripts/generate_ios_icons.py --check`
Expected: `brand assets written`; check exits 0. Open `assets/images/app_icon.png` (Read tool) and confirm an orange barbell on charcoal.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore: placeholder Forge brand assets and generator script"
```

---

### Task 13: Knowledge, instructions and tooling docs

**Files:**
- Create: `knowledge/domain/mens_health.md`, `knowledge/decisions/017_fork_from_femfit.md`, `TASKS_TO_DO.md`
- Delete: `knowledge/domain/womens_health.md`, `knowledge/product/stage1_audit.md`
- Rewrite: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `README.md`, `knowledge/product/product_vision.md`, `knowledge/product/target_users.md`, `knowledge/product/terminology.md`, `knowledge/product/feature_parity.md`, `knowledge/product/implementation_roadmap.md`, `knowledge/product/deferred.md`, `knowledge/product/feature_ideas.md`, `knowledge/engineering/security_and_privacy.md`, `knowledge/architecture/data_architecture.md`, `knowledge/domain/fitness.md`, `knowledge/domain/nutrition.md`, `knowledge/domain/running.md`, `knowledge/research/micronutrient_adequacy.md`, `knowledge/research/nutrition_energy_estimates.md`, `knowledge/engineering/release_and_distribution.md`, `knowledge/decisions/README.md`, `.claude/agents/*.md`, `.claude/skills/*/SKILL.md`, `tools/menfit_deploy/README.md`, `backend/fatsecret-proxy/README.md`
- Modify: every `lib/**` dartdoc citing `womens_health.md` → `mens_health.md`

- [ ] **Step 1: mens_health.md**

```markdown
# Men's Health Domain Notes

*Created 2026-09-07 at the fork from FemFit. This file gates what the product may claim. Read before building any physiology-based feature.*

## Population and assumptions

- MenFit assumes an adult male user. The profile does not collect sex; every
  physiology-based calculation uses adult-male reference values and is
  labelled as an estimate wherever it is shown.
- Energy: Mifflin-St Jeor with the male constant (+5), times an activity
  factor. Source and error bands: `knowledge/research/nutrition_energy_estimates.md`.
- Micronutrient reference intakes (adult male 19–50, DRI): iron 8 mg,
  calcium 1000 mg, vitamin D 15 mcg (600 IU), fibre 38 g, vitamin C 90 mg.
  Rationale: `knowledge/research/micronutrient_adequacy.md`.

## Product rules

1. **No medical claims.** Training, recovery and nutrition features are
   informational. No diagnosis, no supplement or hormone guidance.
2. **Evidence-gating:** any recommendation derived from physiology needs a
   written review in `knowledge/research/` and product sign-off first.
3. **Disclaimers:** health-adjacent surfaces carry "not medical advice".
4. **Opt-in everything:** check-ins, flares, weight and location features are
   optional and degrade gracefully when absent.
5. **Recovery is never failure:** streak logic treats recovery days and
   flare-protected days as success-equivalent, no proof demanded.

## Privacy

Health check-ins, injury/illness flares, body weight and location are
sensitive. Local-first; never logged, never sent to analytics; export and
delete must work for these categories first. See
`knowledge/engineering/security_and_privacy.md`.
```

- [ ] **Step 2: ADR 017**

`knowledge/decisions/017_fork_from_femfit.md`:

```markdown
# ADR 017: MenFit is a subtractive fork of FemFit

*Status: accepted 2026-09-07.*

## Context
FemFit (`https://github.com/JarrodFranz/Womens-Fitness-App`, commit 13e91b9)
is a mature women's running/fitness/nutrition app. The owner wants a men's
training-and-nutrition app with the same engineering base.

## Decision
- Copy the FemFit tree, delete `features/cycle` and every coupling, rename
  the package to `menfit_app`, identity `com.jarrodfranz.menfit`.
- Fresh git history; this ADR records the origin.
- Schema restarts at v1 (no installed base; the v1→v25 chain served only
  FemFit upgrades).
- Strength-first navigation (Home, Train, Nutrition, Recovery, Settings).
- Adult-male physiology assumptions (`knowledge/domain/mens_health.md`).
- All FemFit ADRs 001–016 remain in force unless superseded here.

## Consequences
- Bug fixes made in FemFit after 13e91b9 must be ported by hand.
- No data migration from FemFit installs exists or is planned.
```

- [ ] **Step 3: Rewrite product and engineering docs**

For each file in the rewrite list: replace the women's-health framing with men's strength-first framing; delete sections about cycles, pregnancy and the S3 "cycle" tier (S3 becomes health check-ins, flares, body weight, location); keep everything about architecture, validation, distribution and privacy mechanics. `terminology.md`: define Recovery day, Flare (injury/illness episode), Check-in, Mesocycle (strength cycle). `release_and_distribution.md`: identity `com.jarrodfranz.menfit`, Firebase project `menfit-f17b3`, app id from `distribution/android.json`, keystore path `%USERPROFILE%\menfit-signing\`. `deferred.md`: start a fresh table with the items that still apply (custom_lint re-add, Windows MSIX identity) plus "real brand artwork", "sex field if the product ever widens".

- [ ] **Step 4: CLAUDE.md / AGENTS.md / GEMINI.md / README.md / .claude**

Rewrite `CLAUDE.md` from FemFit's, changing the first line to "Men's strength-first training & nutrition app", replacing `womens_health.md` with `mens_health.md`, `com.jarrodfranz.femfit` with `com.jarrodfranz.menfit`, `femfit_app` with `menfit_app`, `tools/femfit_deploy` with `tools/menfit_deploy`; keep every hard rule (one `flutter test`, no `find /`, stall watchdog, validation sequence). `AGENTS.md`/`GEMINI.md`: same pointers; the "Health and safety" paragraph names check-in, weight and location data. `README.md`: MenFit description, five tabs, run/validate/distribute sections. `.claude/agents/*.md` and `.claude/skills/*/SKILL.md`: grep for `womens_health|cycle|FemFit|femfit` and fix each line.

- [ ] **Step 5: TASKS_TO_DO.md**

```markdown
# MenFit — Tasks To Do

*Canonical tracker. Last updated 2026-09-07.*

| # | Task | Status |
|---|---|---|
| 1 | Fork from FemFit, strip cycles, rebrand, Forge theme (plan `docs/superpowers/plans/2026-09-07-menfit-fork.md`) | In progress |
| 2 | Owner: add testers to Firebase groups `main`/`testers` | Pending |
| 3 | Owner: Codemagic app + Apple bundle id for iOS TestFlight | Pending |
| 4 | Real brand artwork (replace `assets/images/app_icon.png`, rerun `scripts/generate_brand_assets.py`) | Pending |
| 5 | Roadmap idea: estimated 1RM per exercise from logged sets | Idea |
| 6 | Roadmap idea: body-fat / waist tracking beside weight | Idea |
| 7 | Roadmap idea: bulk / cut / maintain calorie targets | Idea |
```

- [ ] **Step 6: Verify and commit**

Run: `Select-String -Recurse -Path lib,test,knowledge,.claude,CLAUDE.md,AGENTS.md,GEMINI.md,README.md -Pattern 'womens_health|menstru|FemFit|femfit' | Measure-Object`
Expected: `Count : 0` except ADR 017 and `knowledge/decisions/*` history references (allow those; list them).

```bash
git add -A
git commit -m "docs: MenFit knowledge base, mens_health domain notes, ADR 017, agent instructions"
```

---

### Task 14: Full validation, release build, distribution, push

**Files:**
- Modify: `handoff/HANDOFF.md`, `handoff/session-log.md`
- Create (gitignored): `android/key.properties`, `%USERPROFILE%\menfit-signing\upload-keystore.jks`, `env/dev.secrets.json`, `env/staging.secrets.json`

- [ ] **Step 1: Full validation, run centrally, one at a time**

```bash
dart run build_runner build
dart format .
flutter analyze --fatal-infos
flutter test
```
Expected: format 0 changed; `No issues found!`; `All tests passed!` with the count printed (record it; expect roughly 3,300). Any failure is fixed before continuing. Commit if format changed anything.

- [ ] **Step 2: Secrets overlay (never committed)**

Copy `D:\Documents\Claude\Projects\Female running app\env\dev.secrets.json` and `env\staging.secrets.json` into `env/` (the FatSecret proxy and ORS keys are app-agnostic). Confirm `git status` does not list them.

- [ ] **Step 3: Upload keystore**

The FemFit script prompts for a hidden password, which a non-interactive session cannot answer. Generate the keystore directly with a random password, write `android/key.properties` exactly as the script would, and tell the owner where to find and back up both:

```powershell
$dir = "$env:USERPROFILE\menfit-signing"; New-Item -ItemType Directory -Force $dir | Out-Null
$pw = -join ((48..57 + 65..90 + 97..122) | Get-Random -Count 28 | % {[char]$_})
$env:KS_PW = $pw
& "C:\Program Files\Java\jdk-17\bin\keytool.exe" -genkeypair -v -keystore "$dir\upload-keystore.jks" -alias upload -keyalg RSA -keysize 2048 -validity 10000 -storepass:env KS_PW -keypass:env KS_PW -dname "CN=MenFit Upload Key, O=Jarrod Franz, C=AU"
@"
storePassword=$pw
keyPassword=$pw
keyAlias=upload
storeFile=$($dir -replace '\\','/')/upload-keystore.jks
"@ | Set-Content -NoNewline android/key.properties
Remove-Item Env:KS_PW
```
Verify `android/key.properties` is gitignored (`git check-ignore android/key.properties` prints the path).

- [ ] **Step 4: Release build**

```bash
flutter build apk --release --dart-define-from-file=env/staging.json --dart-define-from-file=env/staging.secrets.json
```
Expected: `build/app/outputs/flutter-apk/app-release.apk` built with no "debug-signed" warning. Verify:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\build-tools\*\apksigner.bat" verify --print-certs build/app/outputs/flutter-apk/app-release.apk | Select-String 'CN='
& "$env:LOCALAPPDATA\Android\Sdk\build-tools\*\aapt.exe" dump badging build/app/outputs/flutter-apk/app-release.apk | Select-String "package: name|application-label"
```
Expected: `CN=MenFit Upload Key`; `package: name='com.jarrodfranz.menfit'`; `application-label:'MenFit'`. (If the FemFit script `scripts/distribute_android.ps1` already performs the build and these checks, use it in Step 5 instead of building by hand.)

- [ ] **Step 5: Distribute**

```powershell
.\scripts\distribute_android.ps1 -Notes "MenFit 0.1.0 (1): first fork build — strength-first, no cycle features, Forge theme"
```
Expected: `firebase appdistribution:distribute` reports success with a console link for project `menfit-f17b3`, app `1:717515032244:android:8e561294083fcbfa5ef9e1`, group `main`. Note: the group has no testers yet, so nobody is emailed until the owner adds some.

- [ ] **Step 6: Handoff and push**

Update `handoff/HANDOFF.md` State (test count, commit SHA, release verified, distribution link), In flight (none), Next (owner tester emails, keystore backup, Codemagic), Traps (carried from FemFit), Corrections (anything learned). Append to `session-log.md`.

```bash
git add -A
git commit -m "docs(handoff): first MenFit build distributed"
git push -u origin main
```
Expected: `main` on `https://github.com/JarrodFranz/MenFit` shows every commit.

---

## Self-review

- **Spec coverage:** identity (T2), navigation/Home/Train (T10), removed (T3–T7), Recovery enums (T9), nutrition (T7), theme/copy/pronouns (T11), database (T8), knowledge/docs/ADR/tooling (T13), assets (T12), distribution and done-criteria (T14). Web docs branding (T1 Step 2 + T2 sweep). Guard tests (T2). Data export rename (T3).
- **Placeholders:** none; every deletion names the identifiers; every new logic block has code.
- **Type consistency:** `sensitiveHealthTables` (T3) used nowhere else; `MonthRecap` (T5) consistent; `ShareCardTheme.forgeDark` (T11) referenced by recaps (T5 notes the rename happens in T11); `TodaySessionCard` (T10) matches its test; `FlareCategory.other` replaces `custom` everywhere (T9).
