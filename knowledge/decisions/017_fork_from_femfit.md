# ADR 017: MenFit is a subtractive fork of FemFit

*Status: accepted 2026-09-05.*

## Context
FemFit (`https://github.com/JarrodFranz/Womens-Fitness-App`, commit 13e91b9)
is a mature women's running/fitness/nutrition app. The owner wants a men's
training-and-nutrition app with the same engineering base.

## Decision
- Copy the FemFit tree, delete `features/cycle` and every coupling, rename
  the package to `menfit_app`, identity `com.jarrodfranz.menfit`.
- Fresh git history; this ADR records the origin.
- Schema restarts at v1 (no installed base; the v1→v25 chain served only
  FemFit upgrades).
- Strength-first navigation (Home, Train, Nutrition, Recovery, Settings).
- Adult-male physiology assumptions (`knowledge/domain/mens_health.md`).
- All FemFit ADRs 001–016 remain in force unless superseded here.

## Consequences
- Bug fixes made in FemFit after 13e91b9 must be ported by hand.
- No data migration from FemFit installs exists or is planned.
