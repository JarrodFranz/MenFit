# FemFit (working title)

A women-focused running, fitness, health and nutrition app — designed around women's physiology, safety, and privacy (not a generic fitness app with pink styling).

Working today: GPS activity recording (run/walk/hike/ride) with live map and route following; round-trip route suggestion by target distance; strength training with routines, multi-day cycles and progression memory; specialised live trackers (HIIT, yoga/pilates, swim) that survive backgrounding; nutrition logging with Open Food Facts search, barcode scanning, macro targets/locks and water tracking; cycle tracking with an interactive calendar, prediction engine and retrospective phase modelling; cycle-aware streaks with protected recovery days; post-workout celebrations, cycle-phase PRs and social share cards; monthly and cycle-end recap stories; a cross-domain personal-insights engine (descriptive-only, statistically gated); GPX/TCX activity export; Health Connect / HealthKit step and energy sync; Garmin GPX/TCX/FIT import; and a multi-domain progress dashboard. Local-first — all data lives on-device (Drift/SQLite); there is no backend.

> App id / bundle id is `com.jarrodfranz.femfit` (permanent). The Dart package name `menfit_app` is internal only.

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

## Distribute to testers

- **Android → Firebase App Distribution** (built here): one-time `scripts/create_upload_keystore.ps1`, then `scripts/distribute_android.ps1 -Notes "..."` per build.
  - GUI alternative: double-click `tools/femfit_deploy/bin/FemFitDeploy.exe` (rebuild with `powershell -ExecutionPolicy Bypass -File tools/femfit_deploy/build.ps1`; see `tools/femfit_deploy/README.md`).
- **iOS → TestFlight** (built by Codemagic from `codemagic.yaml`): push a tag matching `ios-v*`.

Setup steps, where each secret lives, and the reasoning: `knowledge/engineering/release_and_distribution.md`.

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

Architecture rules and mechanisms: `knowledge/architecture/architecture_overview.md`. Decisions: `knowledge/decisions/` (ADRs). Task tracker: `TASKS_TO_DO.md` (repo root — the canonical registry); phase history: `knowledge/product/implementation_roadmap.md`.

## Working on this repo (humans and AI agents)

Read `CLAUDE.md` first (Gemini: `GEMINI.md`; Codex and others: `AGENTS.md`). Current state and next steps: `handoff/HANDOFF.md`. Persistent project knowledge lives in `knowledge/` — read the relevant files before substantial work, write back discoveries. Cross-project Flutter knowledge: `D:\Documents\Claude\Flutter development knowledge\`. Privacy is architectural: health/cycle/location data rules in `knowledge/engineering/security_and_privacy.md` are non-negotiable.
