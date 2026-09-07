---
name: package-evaluation
description: Use before adding, replacing, or removing any pub.dev dependency — no package enters pubspec.yaml without this.
---

# Package Evaluation Workflow

1. **Necessity** — can existing dependencies or ~100 lines of owned code do this? Prefer fewer dependencies. Check `knowledge/flutter/package_decisions.md` — the package may already be adopted, deferred with a named candidate, or **rejected (do not re-litigate without new facts)**.
2. **Evaluate** (delegate to `researcher` for non-trivial cases) against: maintenance activity (recent commits/releases, issue triage, bus factor), **explicit support for all four platforms** (iOS/Android/Web/Windows — verify, don't assume; note degraded platforms), popularity/likes/pub points, licence, transitive dependency weight, API quality, migration cost if it dies. Check central `package-ecosystem-status.md` for known verdicts (e.g. Isar abandoned).
3. **Decide** — a package used across features or hard to remove later gets an ADR; others get a row in `package_decisions.md` (adopted/deferred/rejected + one-line reason + date).
4. **Adopt cleanly** — pin via `flutter pub add`; platform-limited packages go behind an adapter with capability flags; run full validation plus web + windows build smoke.
5. **Capture** — verdict in `package_decisions.md`; generic ecosystem facts to the central base (dated).
