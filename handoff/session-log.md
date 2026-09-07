# Session log — MenFit

## 2026-09-07 — Session 1: kickoff and evaluation

- Owner request: build a men's training + nutrition app by forking FemFit
  (`D:\Documents\Claude\Projects\Female running app`), dropping cycle features,
  changing the look. Target repo `https://github.com/JarrodFranz/MenFit` (empty).
- Surveyed FemFit: 717 Dart files in lib/, 367 test files, 25-version Drift
  schema, feature modules listed in HANDOFF. Launched a coupling audit to
  classify every module as delete / amend / keep.
- Audit completed and saved to `docs/femfit_fork_audit.md`. Brainstormed with
  the owner: strength-first (running kept), Wellbeing → Recovery tab, name
  MenFit / `menfit_app` / `com.jarrodfranz.menfit`, Forge visual direction
  (chosen from three browser mockups), faithful fork for v1, subtractive fork
  approach with fresh git history. Spec written and approved in conversation.
- Owner created Firebase project `menfit-f17b3`. Registered Android app
  `com.jarrodfranz.menfit` (app id `1:717515032244:android:8e561294083fcbfa5ef9e1`),
  created groups `main` and `testers`, wrote `distribution/android.json`.
- `git init -b main`, remote added, nothing pushed yet.
