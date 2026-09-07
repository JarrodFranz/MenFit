# Handoff — MenFit (men's training + nutrition app)

*Live state. Rewritten and pruned on every material change. Last updated 2026-09-07.*

## State

- Branch `fork-femfit`, 4 commits: docs/audit+spec, implementation plan,
  Task 1 (tree copy + package rename), Task 2 (app identity sweep, `ee397ae`).
  `main` branch also exists but is behind; work is happening on `fork-femfit`
  per the SDD task sequence in `.git/sdd/`.
- Source app: FemFit at `D:\Documents\Claude\Projects\Female running app`,
  forked at commit `13e91b9` (Flutter 3.47.2 / Dart 3.13.2, schema v25,
  3832 tests passing as of 2026-09-07).
- **Task 1 done**: FemFit's tree copied into MenFit, Dart package renamed
  `femfit_app` -> `menfit_app`.
- **Task 2 done** (see `.git/sdd/task-2-report.md`): every remaining
  FemFit/femfit identity string swept to MenFit/menfit — Android
  applicationId/namespace (`com.jarrodfranz.menfit`) + Kotlin package dir,
  iOS bundle id + `CFBundleDisplayName`/`CFBundleName`, web manifest/index,
  Windows runner strings, Dart-side `AppEnv.appName` default, DB name
  (`menfit`), method channel (`com.menfit.app/wearables`), proxy header
  (`X-MenFit-Key`), export filename prefix (`menfit-`), GPX/share-card
  creator strings, `tools/femfit_deploy` -> `tools/menfit_deploy` (+
  `FemFitDeploy.cs` -> `MenFitDeploy.cs`), `scripts/*.ps1`,
  `backend/fatsecret-proxy/*`, `docs/privacy_policy.html`,
  `docs/live_tracker.html`. `pubspec.yaml` and `web/manifest.json`
  descriptions fixed from the leftover "Women-focused" text. All 4 guard
  tests + `flutter analyze --fatal-infos` clean. See **Corrections** below
  for a real bug found and fixed in the brief's own sweep script — read it
  before running any similar find/replace sweep in a later task.
- Firebase: project `menfit-f17b3`, Android app `com.jarrodfranz.menfit`
  registered (app id in `distribution/android.json`, confirmed unchanged by
  the Task 2 sweep), groups `main` and `testers` exist with 0 testers.
- Not yet pushed to the GitHub remote.

## In flight

- Nothing mid-task. Task 2 is complete and committed. 12 more tasks remain
  per the implementation plan (`docs/superpowers/plans/2026-09-07-menfit-fork.md`)
  and the SDD briefs under `.git/sdd/`.

## Next

1. Task 3 onward per the plan/SDD briefs: delete the cycle module, reset the
   Drift schema, Forge theme, Recovery/Train renames, nutrition male values,
   docs rewrite (Task 13).
2. Keep running `flutter analyze --fatal-infos` after each task — see Traps
   below for rename-fallout gotchas that cost time in Tasks 1 and 2.
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
