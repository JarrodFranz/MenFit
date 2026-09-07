# 004 — Backend Strategy: local-first now, vendor decision deferred behind thin interfaces

- **Status:** Accepted
- **Date:** 2026-08-25

## Context
The brief forbids premature backend lock-in. Social, live safety-tracking, and multi-device sync will eventually need a backend; running/nutrition/cycle logging must work fully offline forever.

## Options considered
Pick a BaaS now (Firebase/Supabase); sync engine (PowerSync); CRDT frameworks; local-first with owned sync plumbing.

## Decision
**Local-first with owned, minimal sync plumbing; no backend vendor chosen yet.**

- Drift is the single source of truth; UI reads only Drift streams; every write lands locally first.
- **Client-generated UUIDv7 ids on every row from day one** (non-negotiable for offline-first).
- Syncable tables carry `updated_at` (UTC ms), `deleted_at` (soft delete), `sync_status`; one global `outbox` table written in the same transaction as the domain write.
- A `SyncService` (keepAlive provider; triggers: app foreground, connectivity regained) drains the outbox with backoff, then pulls per-collection with `updated_since` cursors. Conflict policy: **last-write-wins per row by `updated_at`** — single-user data, low-stakes conflicts; documented as revisitable.
- Remote side: one abstract data source per feature (e.g. `ActivityRemoteDataSource`) with no-op implementations today. **No generic sync-engine abstraction** — abstract the endpoints, not the concept.

## Reasons
Vendor freedom at the cost of ~500 lines of well-trodden outbox plumbing when the backend arrives; the app is fully useful with no backend, which matches the product constraint (and the privacy posture for cycle data — see security_and_privacy.md).

## Consequences
Backend selection becomes its own ADR later (auth, live-tracking channel, E2E-encryption design for cycle sync decided with it). Live safety-tracking cannot ship until then — contact management UI can.

## Rejected alternatives
- **Firebase/Supabase now** — lock-in contradicts the brief; Firestore's model fights relational fitness data.
- **PowerSync** — good tech (built on the same Drift/OPFS foundations) but a vendor commitment we don't need yet.
- **CRDTs** — single-user data; massive complexity for no benefit.
