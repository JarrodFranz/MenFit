# Fitness / Strength Domain Notes

*Initial bootstrap notes, 2026-08-25.*

## Core concepts

- **Exercise catalogue:** movement definitions (name, muscle groups, equipment, instructions). Seed from a curated dataset; users can add custom exercises.
- **Workout (template/plan)** vs **WorkoutSession (performed instance)** — keep these distinct entities from day one.
- **ExerciseSet:** reps, weight, optional RPE, rest time. Support bodyweight (null/percent weight), timed sets, and unilateral exercises eventually — but start with reps×weight.
- **Progression:** track per-exercise history (est. 1RM via Epley/Brzycki as a simple analytic), progressive overload suggestions later.
- **Recovery:** rest days, muscle-group frequency; later integrates cycle phase and sleep/energy logging.

## Women-specific considerations

- Programming emphasis differs from typical male-oriented apps: lower-body/glute emphasis demand is high, but avoid stereotyping — full programming for strength across the board.
- Relative-strength standards and progression rates differ; avoid male-calibrated "expected" numbers in UI.
- Cycle-aware programming (e.g. heavier phases when energy is typically higher) is a differentiator but **evidence-gated** — see `womens_health.md`.
- Pregnancy/postpartum modification is a future, medically-reviewed area.

## Data notes

- Units: kg default with lb setting; store canonical kg (double), convert at presentation.
- Streak logic consumes workout sessions as well as runs — streaks are cross-domain and live in their own feature, consuming activity + workout + cycle data.
