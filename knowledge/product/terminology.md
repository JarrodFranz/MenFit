# Terminology

*Canonical vocabulary. Use these terms consistently in code, UI copy, and docs. Extend as the domain model grows.*

| Term | Meaning |
|---|---|
| **Activity** | A single recorded session of movement (run, walk, hike). Has GPS track, duration, distance, etc. |
| **Activity sample** | One time-stamped data point within an activity (location, HR, elevation…). |
| **Route** | A geographic path. May be a suggested route (generated for a km target) or one extracted from a past activity. |
| **Workout** | A structured strength/fitness session composed of exercises. |
| **Exercise** | A movement type (e.g. squat). An **exercise set** is one performed set (reps × weight). |
| **Streak** | Consecutive-day/week engagement metric. Streaks are protected, never punitive — "paused"/"protected", never "frozen"/"excused"/"failed". |
| **DayStatus** | Per-day streak state (2026-08-27 spec): completedActivity, completedPlannedWorkout, plannedRecovery, protectedRecovery, missedPlannedWorkout, unscheduled. planned* statuses activate with Stage 2 plans. |
| **Protected Recovery** | A day the user (or a logged flare's impact) designates as recovery — maintains the streak; requires no proof. Positive framing always. |
| **Flare** | A user-logged symptom flare-up (severity, symptoms, impact) independent of period logging; never requires naming a diagnosis. |
| **Check-in** | The fast optional daily wellbeing entry (energy/sleep/soreness/stress/pain, symptoms, flare?). |
| **Cycle** | The menstrual cycle. A **cycle record** is user-logged cycle data. **Cycle phase**: menstrual, follicular, ovulatory, luteal. |
| **Period** | The menstrual phase of the cycle, as logged by the user. |
| **Trusted contact** | A person the user has authorised to live-track them during activities. |
| **Live tracking / safety share** | Real-time location sharing with trusted contacts during an activity. |
| **Nutrition entry** | One logged food item at a point in time; entries group into **meals**. |
| **Macros** | Protein / carbohydrate / fat totals. |
| **Body metric** | A measurement over time (weight, etc.). |
| **Goal** | A user-defined target (distance per week, weight, protein per day…). |
| **Training load** | Accumulated training stress over time. |
| **PR (personal record)** | Best performance for a standard distance/effort. |

## Naming conventions

- UI copy uses plain, warm language ("your period", not "menses"). Clinical terms only where precision requires.
- Never label cycle features with euphemisms in code — code uses `cycle`, `period`, `cyclePhase` explicitly for clarity.
