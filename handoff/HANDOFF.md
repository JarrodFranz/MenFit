# Handoff — MenFit (men's training + nutrition app)

*Live state. Rewritten and pruned on every material change. Last updated 2026-09-07.*

## State

- Branch `fork-femfit`, 3 commits: docs/audit+spec, implementation plan, and
  Task 1 (tree copy + package rename). `main` branch also exists but is
  behind; work is happening on `fork-femfit` per the SDD task sequence in
  `.git/sdd/`.
- Source app: FemFit at `D:\Documents\Claude\Projects\Female running app`,
  forked at commit `13e91b9` (Flutter 3.47.2 / Dart 3.13.2, schema v25,
  3832 tests passing as of 2026-09-07).
- **Task 1 done** (see `.git/sdd/task-1-report.md` for full detail): FemFit's
  tree copied into MenFit (1298 files committed), Dart package renamed
  `femfit_app` -> `menfit_app` everywhere (pubspec.yaml, lib/, test/, windows
  runner). `flutter analyze --fatal-infos` is clean ("No issues found!").
  MenFit's own `docs/`, `handoff/`, `distribution/android.json` preserved;
  `.gitignore` merged (FemFit's list appended, `.superpowers/` kept,
  `tools/femfit_deploy/` lines pointed at the future `tools/menfit_deploy/`
  path per the brief). No identity/branding strings changed yet (still
  `com.jarrodfranz.femfit`, `femfit_splash.png`, etc.) — later tasks own that.
- Firebase: project `menfit-f17b3`, Android app `com.jarrodfranz.menfit`
  registered (app id in `distribution/android.json`), groups `main` and
  `testers` exist with 0 testers.
- Not yet pushed to the GitHub remote.

## In flight

- Nothing mid-task. Task 1 is complete and committed. 13 more tasks remain
  per the implementation plan (`docs/superpowers/plans/2026-09-07-menfit-fork.md`)
  and the SDD briefs under `.git/sdd/`.

## Next

1. Task 2 onward per the plan/SDD briefs: delete the cycle module, reset the
   Drift schema, rename identity strings (`com.jarrodfranz.femfit` ->
   `com.jarrodfranz.menfit`, Kotlin package dir, iOS bundle id), Forge theme,
   Recovery/Train renames, nutrition male values, docs rewrite.
2. Keep running `flutter analyze --fatal-infos` after each task — see Traps
   below for a rename-fallout gotcha that cost time in Task 1.
3. Owner: add Firebase testers, create upload keystore, Codemagic iOS app,
   push to the GitHub remote once ready.

## Open questions

- None blocking. Decisions recorded in the spec: strength-first, Recovery
  tab kept, MenFit identity, Forge theme, faithful fork, schema reset to v1,
  no sex field, safety kept.

## Traps

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
- `dart fix --apply` can silently modify `pubspec.yaml` as a side effect
  (it added `wakelock_plus_platform_interface: any` as a dev dependency to
  resolve an unrelated `depend_on_referenced_packages`/`unnecessary_ignore`
  pair that only appears because renaming the package shifts import-sort
  order). If you use `dart fix --apply` for `directives_ordering` fallout
  from a package rename, diff `pubspec.yaml`/`pubspec.lock` afterward and
  revert anything beyond the import reordering you intended.

## Corrections

- (none yet)
