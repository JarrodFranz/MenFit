# Handoff — MenFit (men's training + nutrition app)

*Live state. Rewritten and pruned on every material change. Last updated 2026-09-07.*

## State

- Project directory was empty at session start (2026-09-07). GitHub repo
  `https://github.com/JarrodFranz/MenFit` exists and is **empty** (no commits).
- Source app to fork: FemFit at `D:\Documents\Claude\Projects\Female running app`
  (Flutter 3.47.2 / Dart 3.13.2, package `femfit_app`, app id
  `com.jarrodfranz.femfit`, schema v25, 3832 tests passing as of 2026-09-07).
- Evaluation done: `docs/femfit_fork_audit.md`. Design approved by the owner
  and written to `docs/superpowers/specs/2026-09-07-menfit-fork-design.md`.
- Git initialised on `main`, remote `origin` = the MenFit GitHub repo. Not
  yet pushed.
- Firebase: project `menfit-f17b3`, Android app `com.jarrodfranz.menfit`
  registered (app id in `distribution/android.json`), groups `main` and
  `testers` exist with 0 testers.
- No app code copied yet.

## In flight

- Spec written; awaiting owner review before the implementation plan is
  written (superpowers brainstorming → writing-plans flow).

## Next

1. Owner reviews the spec; then write the implementation plan
   (`docs/superpowers/plans/`) with the writing-plans skill.
2. Execute the plan: copy FemFit tree, delete cycle module, rename package,
   reset schema, Forge theme, Recovery/Train renames, nutrition male values,
   docs rewrite, get analyze/format/test green, release APK check, push.
3. Owner: add Firebase testers, create upload keystore, Codemagic iOS app.

## Open questions

- None blocking. Decisions recorded in the spec: strength-first, Recovery
  tab kept, MenFit identity, Forge theme, faithful fork, schema reset to v1,
  no sex field, safety kept.

## Traps

- FemFit rules carry over: only ONE `flutter test` at a time (deadlocks);
  never `find /` on this Windows machine; Avast TLS interception affects
  Android builds (see FemFit `knowledge/troubleshooting/android_build.md`).

## Corrections

- (none yet)
