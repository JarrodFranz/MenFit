# Fitness / Strength Domain Notes

*Initial bootstrap notes, 2026-08-25. Fork note (2026-09-07): the
women-specific section below was replaced when MenFit forked from FemFit
(ADR 017); see `knowledge/domain/mens_health.md` for the evidence-gating rule
that replaces it.*

## Core concepts

- **Exercise catalogue:** movement definitions (name, muscle groups, equipment, instructions). Seed from a curated dataset; users can add custom exercises.
- **Workout (template/plan)** vs **WorkoutSession (performed instance)** — keep these distinct entities from day one.
- **ExerciseSet:** reps, weight, optional RPE, rest time. Support bodyweight (null/percent weight), timed sets, and unilateral exercises eventually — but start with reps×weight.
- **Progression:** track per-exercise history (est. 1RM via Epley/Brzycki as a simple analytic), progressive overload suggestions later.
- **Recovery:** rest days, muscle-group frequency; later integrates cycle phase and sleep/energy logging.

## Evidence-gating

- Full programming for strength across the board; avoid stereotyping any
  single archetype of user.
- Relative-strength standards and progression rates vary by training age and
  body composition; avoid presenting a single "expected" number as normative.
- Any recommendation derived from physiology (e.g. recovery-aware
  programming) is **evidence-gated** — see `knowledge/domain/mens_health.md`.

## Data notes

- Units: kg default with lb setting; store canonical kg (double), convert at presentation.
- Streak logic consumes workout sessions as well as runs — streaks are cross-domain and live in their own feature, consuming activity + workout + cycle data.
