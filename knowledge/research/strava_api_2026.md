# Strava API integration — research findings (2026-09-01)

*Research for TASKS_TO_DO.md Task 1.5 (Wave 3). Product decision pending; the
GPX/TCX export half shipped instead. Re-verify all of this before scheduling
the OAuth wave — Strava has changed terms twice in two years.*

## The blocking facts

- **No PKCE.** Strava OAuth2 is authorization-code only; token exchange AND
  refresh require `client_secret`. No sanctioned public-client flow exists
  (developers.strava.com/docs/authentication/; community thread "How to keep
  client secret secure in public app" — official answer is "use a backend").
- **Developer subscription required (verified directly against
  strava.com/legal/api_policy, effective 1 June 2026, §3.3):** Standard Tier
  apps require "the developer or specified end users [to] maintain an active
  Strava subscription" (~US$11.99/mo). Extended tier (10,000+ users) is exempt.
  Whether END USERS' own subscriptions can satisfy it is ambiguous — ask Strava
  support before deciding.
- **Athlete caps:** default 1 (own account), self-service to 10, review beyond
  that. Community reports of months-long review queues (Apr-May 2026
  submissions unanswered) — anecdotal, unverified.
- **Developers may not charge end users** for functionality that uses the API
  (policy, verified). Note the interaction with a premium app: uploading is
  fine to offer, but never as a paid-tier exclusive framed as buying API access.

## Options assessed for the no-backend constraint (ADR 004)

1. `--dart-define` secret like ORS_API_KEY — **rejected**: extractable from any
   binary; a Strava client_secret grants app-identity impersonation, and the
   API agreement's 24h breach-notification clause makes a shipped secret a
   standing violation, not an incident. Not equivalent to the rate-limited ORS
   key precedent.
2. Stateless serverless token-exchange function — architecturally correct
   endpoint; needs an ADR 004 carve-out, hosting, and a privacy design (its
   access logs reveal who connects Strava and when). A product-owner decision.
3. **Defer OAuth; ship manual GPX/TCX export (CHOSEN for Wave 3).** Zero new
   deps (`package:xml`, `file_picker` already present), zero cost, zero terms
   exposure. Implemented: `activity_file_exporter.dart` + export action on the
   activity detail screen.

## For the eventual OAuth wave (so it isn't re-researched)

- Packages: `flutter_web_auth_2` (^5.1.0 at research time; browser+redirect in
  one, all 6 platforms) + `flutter_secure_storage` (^11.0.0) behind the
  existing SecureStorageBackend seam. NOT url_launcher+app_links (redundant).
  Web: keep tokens in-memory only (per central secure-storage doc).
- Upload: `POST /api/v3/uploads` (gpx/tcx/fit + name, description, sport_type,
  external_id; async — poll `GET /uploads/{id}`) for GPS activities;
  `POST /api/v3/activities` for manual/no-GPS. Set `external_id` to the MenFit
  activity UUID as the idempotency key (exact dedup algorithm undocumented).
  Description length limit undocumented — cap client-side (~1,000 chars).
- Terms that bind: per-user data display only; no AI/ML training on API data;
  Strava brand assets mandatory for connect buttons; no persistent indexes of
  Strava data (7-day transient cache only); 24h breach notification.

## Not verifiable at research time

Description length caps; dedup algorithm; whether end-user subscriptions
satisfy §3.3; actual review-queue latency; exact rate-limit table split
(200/2,000 vs 100/1,000 readings appeared to be different limit categories).
