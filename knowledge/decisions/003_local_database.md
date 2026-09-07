# 003 — Local Database: Drift (SQLite)

- **Status:** Accepted (adopted at first data feature; not wired during bootstrap)
- **Date:** 2026-08-25

## Context
Offline-first store for relational fitness data (activities→GPS samples, workouts→sets, foods→entries, cycle records) on iOS/Android/Web/Windows. Sensitive data (cycle) needs an encryption path.

## Options considered
Drift; Isar; hive_ce; sqflite(+ffi); ObjectBox; shared_preferences (prefs only).

## Decision
**Drift** everywhere (`drift_flutter` + `sqlite3_flutter_libs` native incl. Windows; sqlite3-WASM + OPFS on web with `sqlite3.wasm` + `drift_worker.js` shipped in `web/`). Sidecars: `shared_preferences` for trivial device prefs; `flutter_secure_storage` (behind an abstract backend) for tokens on native platforms — web gets in-memory tokens only.

Schema conventions fixed now: all tables in `core/db/tables/`, one database + one migration history; DAOs live with their feature's `data/` layer; GPS track points as a relational `track_points` table (collapse finished activities to encoded polylines only if profiling demands).

## Reasons
- The only candidate simultaneously relational, reactive (watch-queries → StreamProvider), type-safe, actively maintained, and covering all four platforms.
- The data is genuinely relational; SQL migrations/indices/aggregates (weekly mileage, macro totals, cycle-phase joins) beat document stores here.
- In-memory Drift (`NativeDatabase.memory()`) = real-SQL repository tests without mocks.
- SQLCipher path exists (`sqlcipher_flutter_libs`) for the cycle-data encryption review before launch.

## Consequences
Codegen (drift_dev); web needs the WASM assets; encryption decision deferred but the door is open.

## Rejected alternatives
- **Isar** — abandoned by its author (2026 consensus); `isar_plus` fork is single-maintainer. Disqualified regardless of merits.
- **hive_ce** — alive but key-value; wrong model for relational data.
- **ObjectBox** — no web support; sync product implies vendor lock.
- **sqflite(+ffi)** — raw SQL strings, no type safety/reactivity; Drift is strictly better on the same engine.
