# FemFit → MenFit fork audit (2026-09-07)

Source: `D:\Documents\Claude\Projects\Female running app` (package `femfit_app`,
app id `com.jarrodfranz.femfit`, Flutter 3.47.2, Drift schema v25, 717 lib
files, 367 test files, 3832 tests passing 2026-09-07).

## 1. Delete outright

- `lib/features/cycle/` (~28 files) and `lib/core/db/tables/cycle_records.dart`;
  remove `CycleRecords` from `@DriftDatabase(tables:)` in `app_database.dart`.
  **Do not delete `StrengthCycles`** (training mesocycles) or `RecoveryDays`.
- Routes: `CycleBranchData`, `CycleRouteData`, the shell branch and the
  `'Cycle'` nav destination in `lib/app/router/routes.dart`; regen `routes.g.dart`.
- Theme: `AppTokens.cyclePhase{Menstrual,Follicular,Ovulatory,Luteal}` in
  `lib/core/theme/tokens.dart`.
- `lib/features/insights/domain/evaluators/cycle_phase_evaluator.dart`.
- Recaps: `RecapPeriodKind.cycleEnd`, `forCompletedCycle`, `completedCyclePeriods`,
  `CycleEndDue`.
- Watch companion: `WatchCycleContext` / `sendCycleContext` (adapter, protocol, io, stub).
- Tests: 19 files under `test/features/cycle/`, `test/features/cycle_flow_test.dart`,
  `test/features/insights/cycle_phase_evaluator_test.dart`.

## 2. Amend (cross-feature cycle coupling)

| Feature | Coupling | Effort |
|---|---|---|
| streaks | `streak_assembly.dart` merges `periodDaysInRange` into protected days; `today_protection_sources.dart#isPeriodProtected`; 3 providers watch `cycleRepositoryProvider`. Recovery days + flares stay. | small |
| wellbeing | Tables neutral. `SymptomType` has `pelvicPain`, `cramping`, `bloating`; `FlareCategory` has `endometriosis`, `periodSymptoms`, `pelvicPain` (persisted enums → needs storage fallback). | small–medium |
| insights | `DailyObservation.cyclePhase`, `group_comparison` cyclePhase param, `InsightEngine.cyclePhaseEvaluator`, mapper `phaseByDay`, `insight_sentence` phase branches, `InsightKind.cyclePhase*`, thresholds. Day-of-week + other evaluators survive. | medium |
| recaps | Rename `CycleRecap`→`MonthRecap`; drop cycle-end path in period/trigger/builder/providers/marker store; drop phase pill in `recap_slides.dart` and `RecapPrHighlight.phase`. Month-end path is self-sufficient. | medium |
| achievements | `BadgeInputs.cycleRecords`, `_cycleLoggingMonths`, `BadgeMetric.cycleLoggingMonths`, `BadgeCondition.firstCompletedCycleRecord`, badges `cycle_logging_months` + `first_completed_cycle`, `BadgeCategory.cycleTracking`. | small |
| activity milestones | `WorkoutMilestoneType.cyclePhasePr`, 3 emit sites in `milestone_evaluator.dart`, `CyclePhase? phase` in celebration dialog, whole phase-pill opt-in in `workout_share_dialog.dart`. | medium |
| nutrition | `micronutrient_adequacy.dart` cyclePhase + female RDAs (iron 18); `micronutrient_info_sheet.dart` "Female Health" content; `nutrition_providers.dart#dayCycleStatusProvider`. | medium |
| weight | Cycle phase overlay bands in `weight_trend_chart.dart`, `weight_view_controller.dart#cycleOverlayVisible`, `weightHasCycleContext`, `weight_copy.dart#weightCycleContextNote`. | small |
| data export/import | `cycleAndWellbeingTables` const, S3 copy; coverage guard test in lockstep. | small |
| delete_my_data_service, settings, home today_sheet, onboarding copy, wearable_workout_sync_service (cycle tag), accessibility/challenge doc comments | | trivial–small |
| profile | Zero cycle refs, and **no sex field** exists. | n/a |

## 3. Female-specific but NOT cycle

- `energy_estimate.dart`: Mifflin-St Jeor hardcoded `_femaleConstant = 161`
  (male variant is `+5`). Highest-impact single line.
- `micronutrient_adequacy.dart`: iron 18 mg, calcium 1000 mg, vit D 15 mcg,
  fibre 25 g (female). Male: iron 8 mg, fibre 38 g.
- `app_theme.dart` seed `0xFF8F4C86` (orchid plum); `ShareCardTheme.signatureOrchid`
  default; share tagline "Tuned to her rhythm · FemFit".
- ~100+ she/her dartdoc comments (badge catalogue, db tables, router, audio, errors).
- Onboarding pitch copy ("how women's bodies actually train…"), splash screen
  `FemFitSplashScreen`, error_messages "FemFit export".
- **Safety / live tracking / trusted contacts is NOT gendered in code** — generic
  check-in timer, inactivity alerts, trusted contacts.
- Achievements/challenges affirmations are neutral.

## 4. Keep as-is (branding only)

activity (GPS, strength routines + mesocycles, HIIT, swim, yoga runner, mindful,
audio coaching, hub, GPX/TCX), routes, steps, challenges, progress, safety,
wearables/BLE, health platform, accessibility, data export mechanics, profile,
nutrition logging/barcode/OCR/FatSecret/water. Yoga/pilates/mindful is framed
mechanically, not gendered.

## 5. Branding surface

- `pubspec.yaml name: femfit_app` — 4,397 `package:femfit_app/` imports across 849 files.
- Android: `build.gradle.kts` namespace/applicationId, Kotlin dir
  `com/jarrodfranz/femfit/MainActivity.kt`, manifest label, proguard, key.properties.
- iOS: 6 `PRODUCT_BUNDLE_IDENTIFIER` in pbxproj, Info.plist display/bundle name.
- Web manifest + index.html; Windows CMakeLists/Runner.rc/main.cpp.
- In-Dart: `bootstrap.dart` name, `env.dart` default name + `X-FemFit-Key`,
  `MethodChannel('com.femfit.app/wearables')`, map `userAgentPackageName`,
  GPX creator, export filename prefix, DB filename `femfit`.
- Assets: `femfit_logo*.png`, `femfit_splash.png`, `app_icon.png`, icon sets.
- Build/dist: codemagic.yaml, distribution/android.json, tools/femfit_deploy,
  scripts/*.ps1, .claude/launch.json, .iml, .idea.
- Backend `backend/fatsecret-proxy/*`; docs/privacy_policy.html, live_tracker.html.
- Guard tests: app_identity_guard, ios_infoplist_guard, android_manifest_guard,
  env_files_guard.
- No femfit-prefixed SharedPreferences keys.

## 6. Test impact

367 test files. Tight grep: 54 files (15%) touch cycle. ~21 deleted, ~33 amended.

## 7. Architecture notes

- **Reset schema to v1** with clean `onCreate`; no installed base, migration
  chain (v1→v25, ~24 branches) buys nothing. Delete migration tests.
- ADR 007 rule (features import other features' `domain/` only) means every
  cycle dependency is an explicit import; `domain_import_guard_test.dart`
  flags stragglers. Delete dir → fix compile errors is a reliable first pass.
- Docs needing rewrite: `knowledge/domain/womens_health.md` (cited by ~15
  source files), all `knowledge/product/*.md`, `data_architecture.md` streak/cycle
  section, `security_and_privacy.md` S3 tier definition, `knowledge/research/
  micronutrient_adequacy.md` + `nutrition_energy_estimates.md`, `.claude/agents/*`
  and `.claude/skills/*` womens_health enforcement, `TASKS_TO_DO.md`,
  `female_fitness_business_plan.html`.
