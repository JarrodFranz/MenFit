# CLAUDE.md

Women-focused running, fitness & nutrition app. Flutter, targeting **iOS + Android + Web + Windows** — never assume a task is mobile-only. Production architecture over quick prototypes unless explicitly asked otherwise.

## Read before substantial work

1. `knowledge/architecture/architecture_overview.md` — layout, layer rules, mechanisms (baseline for ANY code change)
2. `knowledge/engineering/coding_standards.md` — conventions + the validation sequence
3. The relevant `knowledge/domain/*.md` and ADRs in `knowledge/decisions/` for your area
4. **Central Flutter knowledge (cross-project):** `D:\Documents\Claude\Flutter development knowledge\` — generic Flutter learnings, package ecosystem status, platform notes, testing pitfalls

`knowledge/` is the project's persistent memory (see its README for structure and rules). Review existing docs/ADRs before making contradictory decisions — supersede explicitly, never silently.

## How to work here

- **Orchestrate.** Decompose substantial work and delegate to sub-agents (`.claude/agents/`: `flutter-implementer`, `code-reviewer`, `researcher`); don't do everything inline. Give agents a bounded objective, relevant context, file allowlist, expected deliverable, and validation requirements. Research agents are read-only. Don't spawn agents for trivial work.
- **Model/effort selection:** stronger models/higher effort for architecture, data modelling, security, health-data logic, hard debugging, review-of-competing-approaches; faster/cheaper (e.g. sonnet, lower effort) for exploration, mechanical implementation, doc formatting, simple tests.
- **Use the workflows** (`.claude/skills/`): new-feature, bug-fix, arch-change, ui-implementation, research-task, package-evaluation, schema-change, refactor, testing, review, build-issue, knowledge-capture. Understand → Inspect → Research → Plan → Delegate → Implement → Test → Review → Document → Update knowledge; collapse stages only for genuinely small tasks.
- **Independent review** for important changes: an agent that didn't write the code reviews correctness, architecture, edge cases, privacy, cross-platform behaviour, tests, complexity. The orchestrator owns the final result.
- **Inspect existing code before changing it; never duplicate existing functionality.**

## Hard rules

- Validation before "done": `dart run build_runner build` (if codegen touched; the `--delete-conflicting-outputs` flag was removed from build_runner in this toolchain and now only warns) → `dart format .` → `flutter analyze --fatal-infos` → `flutter test`. All green, honestly reported.
- Architecture consistency: Riverpod 3 codegen (ADR 001), go_router typed routes (ADR 002), Drift when data lands (ADR 003), freezed (ADR 005). Layer rules in architecture_overview.md — domain/ has no Flutter imports; features depend only on other features' domain/; platform code behind adapters.
- No giant files/classes/widgets (~300-line splitting instinct). Business logic never in widgets.
- No new package without the `package-evaluation` workflow; check the rejected list in `knowledge/flutter/package_decisions.md` first.
- **Privacy is architectural:** user health, cycle, and location data is highly sensitive — see `knowledge/engineering/security_and_privacy.md`. Never log/analytics it. No secrets in the repo, ever (env config: ADR 006).
- Women's-health features are evidence-gated: `knowledge/domain/womens_health.md` gates claims; no medical advice.
- Test meaningful logic; config-only surfaces (manifests/entitlements) get guard tests.
- **Never scan the filesystem to locate a package** (`find / ...` runs for an hour on Windows). Resolve package paths from `.dart_tool/package_config.json` or `%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\<package>-<version>\`.
- Long-running shell loops must emit a heartbeat line per iteration and have an iteration cap — silent infinite waits are forbidden.
- **Only ONE `flutter test` may run at a time in this package.** Concurrent runs deadlock on the shared `.dart_tool`/`build/unit_test_assets` state — all processes sit at zero CPU and `--timeout` never fires, and killing the tester leaves its parent hung. When delegating, agents run `build_runner`/`dart format`/`flutter analyze` and *write* tests; the orchestrator runs the suite once, centrally, and agents report tests as "written, unexecuted".
- **At session start, arm the stall watchdog**: run `scripts/stall_watchdog.ps1` as a persistent Monitor (it kills stray drive-wide `find` scans and reports wedged test/daemon processes; quiet when healthy).
- **Capture knowledge** when you discover something future sessions need (`knowledge-capture` workflow); ADRs for significant decisions.

## Project facts

- App identity is **`com.jarrodfranz.femfit`** (Android applicationId = iOS bundle id, permanent since 2026-09-05; guarded by `test/platform/app_identity_guard_test.dart`). The Dart package name `menfit_app` is internal and stays. Distribution: Android → Firebase App Distribution from the dev machine (GUI: `tools/femfit_deploy`), iOS → Codemagic → TestFlight — `knowledge/engineering/release_and_distribution.md`. Never distribute a debug-signed build.
- Dev machine is Windows: web + windows + **android all build locally** (Android was blocked by Avast TLS interception until 2026-08-27 — fix and diagnosis in `knowledge/troubleshooting/android_build.md`; do not re-litigate it); **iOS target exists but needs macOS to compile** — document anything a Mac session must verify.
- Run: `flutter run -d windows|chrome` (defaults to dev env); other envs: `--dart-define-from-file=env/staging.json`.
