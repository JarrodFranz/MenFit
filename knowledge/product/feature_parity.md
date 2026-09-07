# Feature Parity Inventory — Strava + MyFitnessPal

*Created 2026-08-26 after the product owner confirmed the goal: **all the functionality of Strava and MyFitnessPal**, adapted for a strength-first men's audience since the 2026-09-07 fork (ADR 017). This is the tracking document — every parity feature maps to a roadmap phase (see `implementation_roadmap.md`). Update status as features ship. Statuses: ⬜ not started · 🔨 in progress · ✅ shipped · 🔁 adapted (deliberately different from the original) · ❌ consciously excluded (with reason).*

## Strava parity

### Recording & activities
| Feature | Phase | Status | Notes |
|---|---|---|---|
| GPS recording: run, walk, hike | C | 🔨 | Engine + recording UI shipped & reviewed 2026-08-26 (accuracy/jump filtering, auto-pause, save-retry); pending: on-device verification, mid-run crash recovery, map view (C3) |
| **Cycling (ride) recording** | C/E | 🔨 | Ride is a recordable type in the shipped engine (25 m/s jump threshold); ride-specific UX later |
| Other sport types (swim, elliptical, yoga…) | E+ | ⬜ | Extensible ActivityType; manual entry first |
| Live stats while recording (pace, distance, time, elevation) | C | ✅ | Shipped 2026-08-26: elapsed/moving/distance/rolling pace |
| Auto-pause | C | ✅ | Shipped 2026-08-26: speed hysteresis + fix-staleness detection, back-dated moving time |
| Manual activity entry | C | ✅ | Shipped 2026-08-26 (run/walk/hike/ride; unit-aware; edit/delete; day-grouped history + detail) |
| Treadmill/indoor (non-GPS) mode | E | ⬜ | |
| Heart-rate recording (sensor/wearable) | K | ⬜ | Via HealthAdapter |
| Activity edit/delete, titles, descriptions, photos | C/E | 🔨 | Edit/delete/titles/notes shipped 2026-08-26; photos later |
| Perceived exertion logging | E | ⬜ | Pairs with recovery-aware energy tracking 🔁 |

### Analysis & performance
| Feature | Phase | Status | Notes |
|---|---|---|---|
| Splits (per km/mi), pace analysis | E | ✅ | Shipped 2026-08-27: interpolated splits + relative pace bars on detail; unit-aware |
| Elevation profiles | E | 🔨 | Per-split elevation delta shipped; full elevation chart later |
| Personal records / best efforts (rolling-window) | E | ✅ | Shipped 2026-08-27: dual two-pointer best efforts (1k–marathon) + longest + most climb, brute-force-verified |
| Training load / fitness & freshness | E, M | ⬜ | v1 simple in E; modelled version in M 🔁 recovery-aware |
| Weekly/monthly/yearly stats & trends | E | 🔨 | Weekly (12-week chart + this-vs-last tiles) shipped 2026-08-27; monthly/yearly later |
| Goals (distance, time, frequency) | B/E | ⬜ | Goal skeleton lands with profile |
| Segments & segment leaderboards | L | ⬜ | Needs backend + community mass; low early priority |
| Route maps on activities | C | ✅ | Shipped 2026-08-26: flutter_map polyline + bounds-fit + attribution on detail screen; live in-recording map later |
| Heatmaps (personal) | E+ | ⬜ | Privacy-zone aware from day one 🔁 |

### Routes
| Feature | Phase | Status | Notes |
|---|---|---|---|
| Route suggestion by target distance (km) | H | ⬜ | Named signature feature (goes beyond Strava) 🔁 |
| Route builder/editor | H | ⬜ | |
| Saved routes, repeat a route | H | ⬜ | |
| Safety-aware route preferences (lit streets, avoid isolated paths) | H | ⬜ | Safety differentiator 🔁 |

### Social & community
| Feature | Phase | Status | Notes |
|---|---|---|---|
| Profiles, followers/following | L | ⬜ | Backend-gated (Phase I first) |
| Activity feed, kudos→reactions, comments | L | ⬜ | 🔁 strong moderation |
| Clubs/groups | L | ⬜ | |
| Challenges | L | ⬜ | 🔁 flare-pause-fair scoring |
| Activity sharing (links/images) | L | ⬜ | Privacy zones ship FIRST |
| Privacy zones & default-private activities | L (design in C) | ⬜ | Table stakes; data model prepared early |
| **Beacon (live location sharing)** | J | ⬜ | 🔁 Elevated: trusted-contact live tracking is a signature feature, not premium |
| Strava import (bulk/GPX) | K | ⬜ | Also serves migration onboarding |

### Devices & integrations
| Feature | Phase | Status | Notes |
|---|---|---|---|
| HealthKit / Health Connect sync | K | ⬜ | |
| Garmin/Fitbit/wearable import | K | ⬜ | |
| Watch companion apps | K+ | ⬜ | Far future |

## MyFitnessPal parity

### Food logging
| Feature | Phase | Status | Notes |
|---|---|---|---|
| Food database search & logging | G | ⬜ | DB source research task first (licensing = product decision) |
| Barcode scanning | G | ⬜ | Mobile only |
| Meals (breakfast/lunch/dinner/snacks), custom meal slots | G | ⬜ | |
| Recipes / meal builder, copy previous days | G | ⬜ | |
| Custom foods | G | ⬜ | |
| Water tracking | G | ⬜ | |
| Quick-add calories/macros | G | ⬜ | |

### Nutrition goals & analysis
| Feature | Phase | Status | Notes |
|---|---|---|---|
| Calorie budget & remaining | G | ⬜ | 🔁 ED-safe design: no shaming, hideable numbers, adequacy focus (domain/nutrition.md) |
| Macro targets & breakdowns (protein/carbs/fat) | G | ⬜ | |
| Micronutrients | G+ | ⬜ | Iron first (see domain/nutrition.md) 🔁 |
| Exercise-calorie adjustment | G | ⬜ | Links activity data to nutrition — optional/off by default 🔁 |
| Nutrition reports/trends | G | ⬜ | |
| Intermittent-fasting tracking | ❌ for now | ❌ | Re-evaluate with medical caution given ED-safety stance |

### Weight & body
| Feature | Phase | Status | Notes |
|---|---|---|---|
| Weight logging + trend smoothing | G | ⬜ | |
| Body measurements | G | ⬜ | |
| Progress photos | G+ | ⬜ | S2 data — local-first |
| Weight goals | G | ⬜ | 🔁 conservative-deficit defaults |

### MFP platform features
| Feature | Phase | Status | Notes |
|---|---|---|---|
| Streaks | D | ✅ | 🔁 Signature shipped + review-hardened 2026-08-27: engine with flare/recovery-day pausing (bridging, retroactive, satisfied-precedence, midnight rollover), home hero card, opt-out toggle; 5-dimension workflow review, all findings fixed |
| Reminders/notifications | G/K | ⬜ | Notification adapter |
| Community/forums | L | ⬜ | Folded into our community design |
| Premium paywall features | ❌ | ❌ | No monetisation decisions yet — all features unpaywalled for now |

## Beyond-parity (this product's differentiators — not in Strava/MFP)
Flare-protected recovery streaks (D), trusted-contact live tracking as a core free feature (J), safety-aware routing (H), ED-safe nutrition design (G), recovery-aware training intelligence (M).

## Ground rules for this inventory
- "Parity" means capability parity, not UI cloning; every 🔁 row documents where we deliberately diverge.
- No feature ships outside its phase without updating this doc and the roadmap.
- Anything involving health interpretation stays evidence-gated per `domain/mens_health.md`.
