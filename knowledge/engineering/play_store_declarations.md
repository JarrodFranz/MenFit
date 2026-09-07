# Google Play Store Submission & Policy Declarations

*Prepared: 2026-09-07. Required for Google Play Store review, Google Health Connect verification, and Foreground Service (FGS) permission approval.*

---

## 1. Application Identity

- **App Name:** FemFit
- **Package Name:** `com.jarrodfranz.femfit`
- **Hosted Privacy Policy URL:** `https://jarrodfranz.github.io/Womens-Fitness-App/privacy_policy.html` (or `https://femfit.app/privacy.html`)
- **Developer / Publisher:** Jarrod Franz

---

## 2. Google Play Data Safety Form Answers

| Category | Data Type | Collected? | Shared? | Purpose | Ephemeral / Stored |
|---|---|---|---|---|---|
| **Location** | Approximate & Precise Location | Yes | **No** (Stored locally on device) | App functionality (GPS outdoor workout tracking, route maps, pace calculation) | Stored locally in SQLite; deleted on activity deletion or full data wipe. |
| **Health & Fitness** | Fitness info (Workouts, steps, active calories) | Yes | **No** | App functionality (Exercise logging, activity analytics, daily step goals) | Stored locally on device. |
| **Health & Fitness** | Health info (Menstrual cycle dates, symptoms, check-ins) | Yes | **No** | App functionality (Cycle-aware training insights, personal bests by cycle phase) | Stored locally on device. Never uploaded to remote servers. |
| **Photos & Videos** | Photos / Images | Yes | **No** | App functionality (Nutrition label OCR and barcode scanning) | **Ephemeral** — processed on-device in memory and deleted immediately from disk. |
| **Personal Info** | Name, Height, Weight | Yes | **No** | App functionality (Profile personalization and metabolic energy calculations) | Stored locally on device. |
| **Contacts** | Trusted Contacts (Name, Phone number) | Yes | **No** | Safety & Emergency SOS (Optional SMS dispatch if runner is stationary) | Stored locally on device. |
| **Device or other IDs** | Device identifiers | **No** | **No** | N/A | None collected. |

### Data Safety Questions:
1. **Does your app collect or share any of the required user data types?** &rarr; **Yes**.
2. **Is all user data encrypted in transit?** &rarr; **Yes** (All online lookups use HTTPS/TLS).
3. **Do you provide a way for users to request that their data be deleted?** &rarr; **Yes** (In-app "Delete my data" feature permanently deletes all local tables and preferences).
4. **Is your app committed to following the Families Policy?** &rarr; **No** (Target audience is adults 18+).

---

## 3. Health Connect Declaration & Justifications

Google Play requires explicit functional justification for each requested Health Connect permission:

### A. Permission: `android.permission.health.READ_STEPS`
- **Justification:**
  > "FemFit reads daily step totals from Health Connect to display daily step progress on the Activity dashboard, Progress analytics screens, and Walking hub. This allows female runners and walkers to track baseline non-exercise activity without manually entering daily steps."

### B. Permission: `android.permission.health.READ_ACTIVE_ENERGY_BURNED` & `READ_TOTAL_CALORIES_BURNED`
- **Justification:**
  > "FemFit accesses active energy burned to calculate daily workout caloric expenditure and summarize physical workload alongside logged runs, walks, and strength workouts. This ensures fueling and nutrition targets accurately reflect training volume."

### C. Permission: `android.permission.health.READ_EXERCISE`
- **Justification:**
  > "FemFit accesses completed exercise workouts to allow users to automatically ingest activities recorded on Garmin, WearOS, or external fitness watches directly into their local FemFit activity diary with automated menstrual cycle-phase tagging."

### Core Health Connect Compliance Statements:
- Health Connect data is **never transferred, sold, or shared** with third parties or data brokers.
- Health Connect data is **never used for advertising or marketing**.
- All Health Connect data is processed and stored locally on the user's mobile device.

---

## 4. Foreground Service (FGS) Location Declaration

Google Play requires a policy declaration explaining why a Foreground Service with `location` type (`android:foregroundServiceType="location"`) is essential for core app functionality.

### Declaration Prompt: "Why does your app need to access location in the background / foreground service?"
- **Submission Text:**
  > "FemFit is a running and outdoor workout tracker. When a user begins an outdoor workout (run, walk, hike, or bicycle ride), the app activates a location foreground service (`FOREGROUND_SERVICE_LOCATION`) to continuously record GPS trackpoints, compute real-time split paces, calculate distance covered, and monitor runner safety (stationary SOS detection).
  >
  > Runners routinely lock their phone screen or place their device in a pocket or arm band while exercising. The foreground service is strictly necessary to maintain uninterrupted GPS recording while the screen is off.
  >
  > The foreground service is initiated exclusively by an explicit user tap on 'Start Run' or 'Start Activity', displays an ongoing persistent system notification showing elapsed workout metrics with immediate pause/stop controls, and terminates immediately when the user ends the activity. The app does not request `ACCESS_BACKGROUND_LOCATION`."

---

## 5. Foreground Service (FGS) Demo Video Script (30–60 Seconds)

Google Play submission requires a public YouTube or Cloud Storage video URL demonstrating the user-facing FGS location tracking flow:

1. **Scene 1 (0:00 – 0:08): Home & Pre-Run Setup**
   - User opens FemFit, taps on the "Activity" tab, and selects "GPS Run" / "Record Run".
   - Shows the pre-start HUD with GPS status, route options, and the prominent "Start Run" button.
2. **Scene 2 (0:08 – 0:20): Initiating Active Workout & FGS Notification**
   - User taps "Start Run". Workout timer begins counting.
   - User swipes down the Android notification shade.
   - Camera focuses on the persistent system notification:
     - Title: "FemFit — Running"
     - Subtitle: "Distance: 0.12 km · Time: 0:45 · Pace: 5:15 /km"
     - Action buttons: "Pause", "Finish".
3. **Scene 3 (0:20 – 0:35): Screen Off / Background Recording Demonstration**
   - User locks the phone screen (or switches to another app) for 5 seconds.
   - User wakes device and resumes FemFit. Shows that the GPS breadcrumb trail continued plotting accurately and metrics updated without data loss.
4. **Scene 4 (0:35 – 0:45): Finishing Activity & Immediate FGS Termination**
   - User taps "Finish Run" and confirms completion.
   - User swipes down notification shade to demonstrate that the persistent Foreground Service notification immediately disappears.
   - Celebration dialog displays earned milestones and workout summary.

---

## 6. Play Store Listing Copy

- **Short Description (80 characters):**
  > Women's running, fitness, and nutrition app with menstrual cycle intelligence.
- **Full Description Highlights:**
  - Cycle-Aware Running & Training: Plan runs and workouts harmonized with your natural biological rhythms.
  - Comprehensive Exercise Hubs: Live tracking for running, strength training, HIIT, mindful yoga/pilates, and swimming.
  - Honest Nutrition & Micronutrient Adequacy: Track fueling, protein, iron, and hydration without caloric restriction or moralizing language.
  - Offline-First & Private: All health and cycle data stays on your device. No cloud surveillance, no data selling, no ads.
