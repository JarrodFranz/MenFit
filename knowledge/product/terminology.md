# Terminology

*Canonical vocabulary. Use these terms consistently in code, UI copy, and docs. Extend as the domain model grows.*

| Term | Meaning |
|---|---|
| **Activity** | A single recorded session of movement (run, walk, hike, ride). Has GPS track, duration, distance, etc. |
| **Activity sample** | One time-stamped data point within an activity (location, HR, elevation…). |
| **Route** | A geographic path. May be a suggested route (generated for a km target) or one extracted from a past activity. |
| **Workout** | A structured strength/fitness session composed of exercises. |
| **Exercise** | A movement type (e.g. squat). An **exercise set** is one performed set (reps × weight). |
| **Mesocycle** | A multi-day/week structured block of strength training (`StrengthCycle` in code) — the unit of programming and progression memory, distinct from a single workout. |
| **Streak** | Consecutive-day/week engagement metric. Streaks are protected, never punitive — "paused"/"protected", never "frozen"/"excused"/"failed". |
| **DayStatus** | Per-day streak state: completedActivity, completedPlannedWorkout, plannedRecovery, protectedRecovery, missedPlannedWorkout, unscheduled. |
| **Recovery day** | A day the user (or a logged flare's impact) designates as recovery — maintains the streak; requires no proof. Positive framing always. Never called "period" or "excused". |
| **Flare** | A user-logged injury, illness, or other health episode (severity, symptoms, impact); categories are injury, illness, migraine, back pain, other. Never requires naming a diagnosis. |
| **Check-in** | The fast optional daily wellbeing entry (energy/sleep/soreness/stress/pain, symptoms, flare?). |
| **Trusted contact** | A person the user has authorised to live-track them during activities. |
| **Live tracking / safety share** | Real-time location sharing with trusted contacts during an activity. |
| **Nutrition entry** | One logged food item at a point in time; entries group into **meals**. |
| **Macros** | Protein / carbohydrate / fat totals. |
| **Body metric** | A measurement over time (weight, etc.). |
| **Goal** | A user-defined target (distance per week, weight, protein per day…). |
| **Training load** | Accumulated training stress over time. |
| **PR (personal record)** | Best performance for a standard distance/effort or lift. |

## Naming conventions

- UI copy uses plain, direct language. Clinical terms only where precision requires.
- Never euphemise health-adjacent features in code — code uses `flare`, `checkin`, `recoveryDay` explicitly for clarity.
