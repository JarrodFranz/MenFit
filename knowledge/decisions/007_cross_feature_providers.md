# 007 — Cross-feature dependencies: feature provider surface

- **Status:** Accepted
- **Date:** 2026-08-26

## Context
Phase B review found onboarding importing `features/profile/data/drift_profile_repository.dart` to reach `profileRepositoryProvider` — violating the rule "features depend only on another feature's domain/". The rule as written was unsatisfiable: repository providers must construct concrete `data/` implementations, `domain/` may not import `data/`, so there was no legal home for a provider another feature could use.

## Options considered
(a) Feature-root provider surface file; (b) move shared entities/interfaces/providers into `core/domain`/`core/db`; (c) waive the rule.

## Decision
Each feature exposes a **composition surface** at its root: `features/<name>/<name>_providers.dart`. It may import the feature's `data/` internally; it exposes providers **typed as domain interfaces** (e.g. `Provider<ProfileRepository>`). 

Amended dependency rule: a feature may import another feature's `domain/` **and its `<name>_providers.dart`** — never its `data/` or `presentation/`.

**Amendment (2026-08-28):** a feature may additionally export **designated public widgets** via a `features/<name>/<name>_widgets.dart` barrel (the UI composition surface). Other features (typically `home`, which composes feature cards) may import that barrel — still never `presentation/` internals. First use: `wellbeing_widgets.dart` exporting the check-in card.

## Reasons
Keeps features self-contained (profile stays a feature; no premature migration of entities to core), gives exactly one legal cross-feature entry point, and stays mechanical enough for agents to copy correctly.

## Consequences
`profileRepositoryProvider` moves to `features/profile/profile_providers.dart`; future features follow. `core/domain` remains reserved for entities genuinely shared by many features (units, ids) — moving `UserProfile` there stays an option if it becomes ubiquitous.

## Rejected alternatives
- **(b) core/domain migration** — heavier, weakens feature ownership, and wasn't needed to satisfy the constraint.
- **(c) waiving** — the rule's purpose (persistence swaps don't ripple across features) is real; the fix is cheap.
