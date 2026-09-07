# 009 — Route suggestion engine: OpenRouteService round-trip API

- **Status:** Accepted
- **Date:** 2026-08-28 (recorded post-implementation after review flagged the missing ADR)

## Context
The product-owner-named feature "show me a route that is X km from my position" needs a routing engine capable of round-trip (loop) generation for a target length. Building a router (OSM graph + algorithms) is out of scope; the realistic options are hosted APIs.

## Options considered
OpenRouteService (ORS) round-trip; GraphHopper round_trip; Valhalla; self-hosted ORS/Valhalla; on-device routing (deferred entirely).

## Decision
**OpenRouteService** `POST /v2/directions/{profile}/geojson` with `options.round_trip{length, points, seed}` (contract verified against ORS docs + source, 2026-08-28), behind the `RouteSuggestionService` abstraction (`features/routes/domain/`) so the vendor is swappable. Profiles: run/walk → `foot-walking`, hike → `foot-hiking`, ride → `cycling-regular`. API key via `ORS_API_KEY` dart-define (secrets pattern per ADR 006 — never in committed env files, guarded by test); missing key degrades to an honest setup card with zero network calls.

## Reasons
Free tier suited to dev/small scale; genuine round-trip support (OSRM's public API lacks it); simple auth; OSM-based, consistent with our map stack.

## Consequences
- **Privacy commitment**: this is the app's first feature that sends location off-device — the user-chosen start point (often home-adjacent, S2) goes to api.openrouteservice.org, up to `count` times per search (seed variation). The suggest UI must disclose this plainly (review finding, fixed alongside this ADR). Nothing else is transmitted; nothing persists unless the user saves a route. **Any future provider swap re-triggers this privacy assessment.**
- ORS free-tier rate limits apply per key; sequential seed requests keep bursts small.
- Self-hosting ORS remains the escape hatch if terms/limits/privacy posture change.

## Rejected alternatives
- **GraphHopper** — comparable, but ORS's free tier and docs fit better; no differentiator justified it.
- **Valhalla public demo** — no stable/guaranteed public endpoint.
- **Self-hosted** — operational burden ahead of need.
