---
name: refactor
description: Use for restructuring code without behaviour change — moves, renames, splits, deduplication, pattern alignment.
---

# Refactor Workflow

1. **Green baseline** — full validation sequence passes before starting; never refactor on a red build.
2. **Scope** — behaviour-preserving only; feature work or bug fixes discovered mid-refactor are queued separately, not mixed in.
3. **Safety net** — existing tests around the area; for pure data moves/renames add a **byte-identical snapshot test** (serialize before, assert equality after — central `testing-pitfalls.md`); add missing tests BEFORE refactoring if coverage is thin.
4. **Execute in mechanical steps** — one transformation at a time, validation between steps; delegate large mechanical sweeps to `flutter-implementer` with an explicit file list; re-run `build_runner` after moving annotated code.
5. **Review** — `code-reviewer` for refactors spanning multiple features (checking pattern consistency and that no behaviour changed).
6. **Capture** — if the refactor establishes/changes a convention, update `knowledge/flutter/flutter_patterns.md` or `coding_standards.md`; large planned-but-deferred refactors go in the deferred registry (`knowledge/product/deferred.md`).
