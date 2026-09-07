# Google Play Store Submission & Policy Declarations

*Prepared: 2026-09-07. Required for Google Play Store review, Google Health Connect verification, and Foreground Service (FGS) permission approval.*

---

## 1. Application Identity

- **App Name:** MenFit
- **Package Name:** `com.jarrodfranz.menfit`
- **Hosted Privacy Policy URL:** `https://jarrodfranz.github.io/MenFit/privacy_policy.html` (or `https://menfit.app/privacy.html`)
- **Developer / Publisher:** Jarrod Franz

---

## 2. Google Play Data Safety Form Answers

| Category | Data Type | Collected? | Shared? | Purpose | Ephemeral / Stored |
|---|---|---|---|---|---|
| **Location** | Approximate & Precise Location | Yes | **No** (Stored locally on device) | App functionality (GPS outdoor workout tracking, route maps, pace calculation) | Stored locally in SQLite; deleted on activity deletion or full data wipe. |
| **Health & Fitness** | Fitness info (Workouts, steps, active calories) | Yes | **No** | App functionality (Exercise logging, activity analytics, daily step goals) | Stored locally on device. |
| **Health & Fitness** | Health info (Health check-ins — sleep, energy, soreness, pain, mood — and logged injury/illness flares) | Yes | **No** | App functionality (Recovery tracking, protecting training streaks during illness, injury, or a planned recovery day) | Stored locally on device. Never uploaded to remote servers. |
| **Health & Fitness** | Nutrition & hydration logs (food diary, water intake) | Yes | **No** | App functionality (Fuelling and hydration tracking) | Stored locally on device. |
| **Photos & Videos** | Photos / Images | Yes | **No** | App functionality (Nutrition label OCR and barcode scanning) | **Ephemeral** — processed on-device in memory and deleted immediately from disk. |
| **Personal Info** | Name, Height, Weight | Yes | **No** | App functionality (Profile personalization and metabolic energy calculations) | Stored locally on device. |
| **Contacts** | Trusted Contacts (Name, Phone number) | Yes | **No** | Safety & Emergency SOS (Optional SMS dispatch if the user is stationary) | Stored locally on device. |
| **Device or other IDs** | Device identifiers | **No** | **No** | N/A | None collected. |

No reproductive-health data of any kind is collected, requested, or inferred by MenFit.

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
  > "MenFit reads daily step totals from Health Connect to display daily step progress on the Activity dashboard, Progress analytics screens, and Walking hub. This allows users to track baseline non-exercise activity without manually entering daily steps."

### B. Permission: `android.permission.health.READ_ACTIVE_ENERGY_BURNED` & `READ_TOTAL_CALORIES_BURNED`
- **Justification:**
  > "MenFit accesses active energy burned to calculate daily workout caloric expenditure and summarize physical workload alongside logged runs, walks, and strength workouts. This ensures fueling and nutrition targets accurately reflect training volume."

### C. Permission: `android.permission.health.READ_EXERCISE`
- **Justification:**
  > "MenFit accesses completed exercise workouts to allow users to automatically ingest activities recorded on Garmin, WearOS, or external fitness watches directly into their local MenFit activity diary."

### Core Health Connect Compliance Statements:
- Health Connect data is **never transferred, sold, or shared** with third parties or data brokers.
- Health Connect data is **never used for advertising or marketing**.
- All Health Connect data is processed and stored locally on the user's mobile device.

---

## 4. Foreground Service (FGS) Location Declaration

Google Play requires a policy declaration explaining why a Foreground Service with `location` type (`android:foregroundServiceType="location"`) is essential for core app functionality.

### Declaration Prompt: "Why does your app need to access location in the background / foreground service?"
- **Submission Text:**
  > "MenFit is a men's strength-first training and nutrition app that also supports outdoor GPS workouts (runs, walks, hikes, and rides). When a user begins an outdoor workout, the app activates a location foreground service (`FOREGROUND_SERVICE_LOCATION`) to continuously record GPS trackpoints, compute real-time split paces, calculate distance covered, and monitor user safety (stationary check-in / SOS detection).
  >
  > Users routinely lock their phone screen or place their device in a pocket or arm band while exercising. The foreground service is strictly necessary to maintain uninterrupted GPS recording while the screen is off.
  >
  > The foreground service is initiated exclusively by an explicit user tap on 'Start Run' or 'Start Activity', displays an ongoing persistent system notification showing elapsed workout metrics with immediate pause/stop controls, and terminates immediately when the user ends the activity. The app does not request `ACCESS_BACKGROUND_LOCATION`."

---

## 5. Foreground Service (FGS) Demo Video Script (30–60 Seconds)

Google Play submission requires a public YouTube or Cloud Storage video URL demonstrating the user-facing FGS location tracking flow, plus the app's other permission-gated features:

1. **Scene 1 (0:00 – 0:08): Home & Strength Session Start**
   - User opens MenFit to the **Home** tab, then switches to the **Train** tab.
   - User selects a strength workout and taps "Start Session"; sets and reps logging begins.
2. **Scene 2 (0:08 – 0:20): Starting a GPS Run & FGS Notification**
   - User returns to **Train**, selects "GPS Run" / "Record Run", and taps "Start Run". Workout timer begins counting.
   - User swipes down the Android notification shade.
   - Camera focuses on the persistent system notification:
     - Title: "MenFit — Running"
     - Subtitle: "Distance: 0.12 km · Time: 0:45 · Pace: 5:15 /km"
     - Action buttons: "Pause", "Finish".
3. **Scene 3 (0:20 – 0:32): Screen Off & Safety Check-In**
   - User locks the phone screen for 5 seconds, then wakes the device and resumes MenFit, showing the GPS breadcrumb trail continued plotting accurately.
   - User triggers the stationary safety check-in prompt and dismisses it, demonstrating the SOS flow without sending a real alert.
   - User taps "Finish Run"; the persistent Foreground Service notification disappears immediately.
4. **Scene 4 (0:32 – 0:45): Nutrition — Barcode Scan**
   - User switches to the **Nutrition** tab, taps "Add Food" &rarr; "Scan Barcode", and scans a packaged food item.
   - The camera closes immediately after the scan and the parsed nutrition entry appears in the food diary.
5. **Scene 5 (0:45 – 0:55): Recovery Check-In**
   - User switches to the **Recovery** tab and completes a daily check-in (sleep, energy, soreness, mood).
   - Summary screen shows the day marked as a Recovery day with no numeric penalty applied to streaks.

---

## 6. Play Store Listing Copy

- **Short Description (80 characters):**
  > Men's strength-first training and nutrition app.
- **Full Description Highlights:**
  - Strength-First Training: Plan and log strength sessions, track sets, reps, and progressive overload.
  - Comprehensive Exercise Hubs: Live tracking for running, strength training, HIIT, and other outdoor and indoor workouts.
  - Recovery Tracking: Daily check-ins for sleep, energy, soreness, and mood, with injury/illness flare logging that protects training streaks during a Recovery day.
  - Honest Nutrition: Track fueling, protein, and hydration without caloric restriction or moralizing language.
  - Offline-First & Private: All health and recovery data stays on your device. No cloud surveillance, no data selling, no ads.
