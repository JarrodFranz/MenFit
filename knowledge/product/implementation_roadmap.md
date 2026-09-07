# Implementation Roadmap

*Rewritten 2026-09-07 at the fork from FemFit.*

MenFit inherits its engineering base and phase history wholesale from FemFit
(fork rationale and scope: `knowledge/decisions/017_fork_from_femfit.md`).
FemFit's own phase-by-phase build log is not reproduced here — it describes a
different product's history and is not durable knowledge for this repo.

## Current state (2026-09-07)

The fork is code-complete: cycle tracking removed, Recovery tab (check-ins +
flare logging) replacing the old cycle/wellbeing surface, Train tab with a
strength-first Home, Forge theme, male Mifflin-St Jeor energy estimates and
adult-male reference intakes, schema reset to v1, placeholder brand assets.
The test suite is green (3,495 tests at fork time). Remaining work is
documentation, real brand artwork, and owner-side distribution setup — see
`TASKS_TO_DO.md` for the live task list and `deferred.md` for the registry of
consciously-scoped-out engineering work.

## Scope

Full Strava + MyFitnessPal functional parity remains the long-term target,
tracked feature-by-feature in `feature_parity.md`. New feature work should
extend the existing architecture (`knowledge/architecture/architecture_overview.md`)
rather than revisit decisions already recorded in `knowledge/decisions/`.
