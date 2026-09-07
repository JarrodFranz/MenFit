---
name: bug-fix
description: Use when diagnosing and fixing any bug, test failure, or unexpected behaviour in this app.
---

# Bug Fix Workflow

1. **Reproduce first** — a failing test or reproducible command before any fix. If you cannot reproduce, investigate until you can or report why not.
2. **Check known issues** — search `knowledge/troubleshooting/` and the central base (`D:\Documents\Claude\Flutter development knowledge\`, especially `testing-pitfalls.md`) — it may already be diagnosed.
3. **Diagnose root cause** — use the `superpowers:systematic-debugging` skill if available on this machine for anything non-obvious. Fix causes, not symptoms.
4. **Fix minimally** — smallest correct change; delegate to `flutter-implementer` if substantial; no drive-by refactors (queue those via `refactor`).
5. **Prove** — the reproduction test now passes; full validation sequence green (`build_runner` if codegen touched, `dart format`, `flutter analyze --fatal-infos`, `flutter test`). Consider whether the bug class exists elsewhere in the codebase.
6. **Capture** — non-obvious diagnoses go to `knowledge/troubleshooting/` (Symptom / Cause / Fix / versions); generic Flutter discoveries go to the central base; recurring defect *shapes* go to the defect-shape list.
