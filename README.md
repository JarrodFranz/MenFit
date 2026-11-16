# MenFit (working title)

A men's strength-first training, running and nutrition app — a full
fitness/running/strength/nutrition platform designed around consistent
training, honest recovery, and adequate fuelling (not a generic fitness app
with a different colour scheme).

Working today: GPS activity recording (run/walk/hike/ride) with live map and
route following; round-trip route suggestion by target distance; strength
training with routines, multi-day mesocycles and progression memory;
specialised live trackers (HIIT, yoga/pilates, swim) that survive
backgrounding; nutrition logging with Open Food Facts/FatSecret search,
barcode scanning, macro targets/locks and water tracking; health check-ins
and flare logging (injury, illness, migraine, back pain, other) with
flare-protected streaks; post-workout celebrations and social share cards;
monthly recap stories; a cross-domain personal-insights engine
(descriptive-only, statistically gated); trusted-contact live tracking for
solo training sessions; GPX/TCX activity export; Health Connect / HealthKit
step and energy sync; Garmin GPX/TCX/FIT import; and a multi-domain progress
dashboard. Local-first — all data lives on-device (Drift/SQLite); there is no
backend beyond a shared, third-party-brokered food-data proxy.

> App id / bundle id is `com.jarrodfranz.menfit` (permanent). The Dart package name `menfit_app` is internal only.

## Platforms

Flutter app targeting **iOS, Android, Web, Windows**. Mobile is the full experience (GPS recording); Web/Windows are first-class review/planning surfaces (and Web will host the trusted-contact live-tracking viewer). iOS builds require macOS (this repo was bootstrapped on Windows; the iOS target exists but is unvalidated locally).

## Prerequisites

- Flutter ≥ 3.47 stable (Dart ≥ 3.13) — `flutter doctor`
- For Windows builds: Visual Studio with Desktop C++ workload
- For Android: Android SDK/Studio toolchain

## Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows     # or: -d chrome, -d <android device>
```

No `--dart-define` needed for dev (defaults apply). Other environments: `flutter run --dart-define-from-file=env/staging.json`. Env files in `env/` contain **no secrets** (see ADR 006); local secrets (e.g. `ORS_API_KEY` for route suggestions) go in the gitignored `env/dev.secrets.json` — `scripts/run.ps1` passes both files. Route suggestion is the only feature that needs a key; everything else works without one.

## Six tabs

Home (strength-first dashboard), Train (`/activity` — GPS recording, strength
workouts, exercise hubs), Nutrition, Keto (`/keto` — diary macros plus a manual blood/urine/breath ketone log), Recovery (`/recovery` — check-ins, flare
logging, protected-recovery history), Settings.

## Distribute to testers

- **Android → Firebase App Distribution** (built here, project `menfit-f17b3`): one-time `scripts/create_upload_keystore.ps1` (writes `%USERPROFILE%\menfit-signing\upload-keystore.jks`), then `scripts/distribute_android.ps1 -Notes "..."` per build.
  - GUI alternative: double-click `tools/menfit_deploy/bin/MenFitDeploy.exe` (rebuild with `powershell -ExecutionPolicy Bypass -File tools/menfit_deploy/build.ps1`; see `tools/menfit_deploy/README.md`).
- **iOS → TestFlight** (built by Codemagic from `codemagic.yaml`): push a tag matching `ios-v*`.

Setup steps, where each secret lives, and the reasoning: `knowledge/engineering/release_and_distribution.md`.

## FatSecret proxy is shared infrastructure

Food lookups go through a FatSecret Platform API proxy that is **not**
MenFit's own service — it is deployed once, in FemFit's GCP project
(`femfit-5e600`, VM `femfit-proxy-vm`, static IP `34.27.29.29`), and used by
both apps. MenFit sends the `X-FemFit-Key` header because that is what the
deployed server checks. Do not rename that infrastructure in this repo's
docs — see `backend/fatsecret-proxy/README.md`.

## Validate (run before considering any change done)

```bash
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze --fatal-infos
flutter test
```

Generated files (`*.g.dart`, `*.freezed.dart`) are committed. Only **one** `flutter test` process may run at a time in this package — concurrent runs deadlock on shared `.dart_tool` state (see `CLAUDE.md`).

## Project structure

```
lib/app/        composition root: bootstrap, App, router (single route table)
lib/core/       shared kernel: config, theme (tokens/breakpoints), widgets, errors, (db/sync later)
lib/features/   feature modules, each: domain/ data/ presentation/
knowledge/      persistent project memory: architecture, ADRs, domain notes, standards, troubleshooting
.claude/        Claude Code orchestration: sub-agents + workflow skills
env/            per-environment non-secret config (dart-define-from-file)
handoff/        live session state + log so any agent/human can resume the work
```

Architecture rules and mechanisms: `knowledge/architecture/architecture_overview.md`. Decisions: `knowledge/decisions/` (ADRs; ADR 017 records the fork from FemFit). Task tracker: `TASKS_TO_DO.md` (repo root — the canonical registry); phase history: `knowledge/product/implementation_roadmap.md`.

## Working on this repo (humans and AI agents)

Read `CLAUDE.md` first (Gemini: `GEMINI.md`; Codex and others: `AGENTS.md`). Current state and next steps: `handoff/HANDOFF.md`. Persistent project knowledge lives in `knowledge/` — read the relevant files before substantial work, write back discoveries. Cross-project Flutter knowledge: `D:\Documents\Claude\Flutter development knowledge\`. Privacy is architectural: health/flare/location data rules in `knowledge/engineering/security_and_privacy.md` are non-negotiable.
