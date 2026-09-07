# Running Domain Notes

*Initial bootstrap notes, 2026-08-25. Expand via research tasks before building the running feature.*

## Core concepts

- **Activity types (initial):** run, walk, hike. **Ride (cycling) confirmed in scope** for Strava parity (2026-08-26) — include in `ActivityType` from the start; recording UX for rides can lag runs. Keep the enum extensible (swim etc. later).
- **Recorded metrics:** distance, duration (moving vs elapsed), pace (min/km — support min/mi via settings), speed, elevation gain/loss, heart rate (if source available), cadence (later).
- **Splits:** per-km (or per-mile) segments with pace; negative-split detection is a nice analytic.
- **GPS track:** ordered, timestamped samples (lat, lon, elevation, accuracy, HR…). Raw samples are high-volume — store efficiently, downsample for display, keep raw for recompute.
- **PRs:** best efforts over standard distances (1k, 5k, 10k, half, full) computed by best rolling window over the track, not only whole activities.
- **Training load:** simple first (weekly distance/duration trends); sophisticated models (TRIMP etc.) later, and they benefit from cycle context.

## Data quality realities

- GPS is noisy: filter by horizontal accuracy, smooth pace, handle tunnels/canyons/signal loss, auto-pause detection.
- Distance from GPS needs haversine + filtering; naive point-to-point summation over-reports.
- Background tracking is the hardest cross-platform problem in the app: iOS background location entitlements, Android foreground service + Doze, no equivalent needed on Web/Windows (record-on-device is mobile-first; Web/Windows are review/planning surfaces first).

## Route suggestion (named feature)

- Input: start point + target distance (km), later preferences (loop vs out-and-back, elevation, lit streets, avoid isolated paths — a women's-safety differentiator).
- Requires a routing/graph source: OSM-based services (e.g. OpenRouteService round-trip routing, GraphHopper, Valhalla) are the realistic options vs building a router. Evaluate in a dedicated research task before Phase C/D.
- Route storage must be independent of activity storage (routes are shareable, reusable).

## Women-specific considerations

- Performance varies across cycle phases for many users; analytics should be able to annotate activities with cycle phase (join at query time — do not denormalise cycle data into activity records; privacy separation matters).
- Safety features (live tracking, check-ins, lit-route preference) are core running features here, not add-ons.
