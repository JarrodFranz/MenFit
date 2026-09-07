---
name: schema-change
description: Use when adding or modifying database tables, columns, indices, or Drift migrations.
---

# Database / Schema Change Workflow

1. **Read** — `knowledge/architecture/data_architecture.md`, existing tables in `core/db/tables/` (directory exists once Drift is wired — ADR 003), and ADRs 003/004. Schema follows the fixed conventions: UUIDv7 text ids; `updated_at`/`deleted_at`/`sync_status` on syncable tables; UTC timestamps; canonical metric units.
2. **Sensitivity tier first** — classify the new data per `knowledge/engineering/security_and_privacy.md`. S3 (health check-ins/flares/weight/location) data: never denormalised into other tables, never in logs; joins happen at query time.
3. **Design** — table + indices for the actual query patterns (streams the UI watches, aggregates). Derived data (splits, streaks, PRs) is not stored unless profiling demands a cache.
4. **Migrate safely** — bump `schemaVersion`, write the migration step, never edit an already-shipped migration; use Drift's step-by-step migration API and schema tests (`drift_dev` schema verification) once the DB exists.
5. **Test** — migration test (old schema + data → migrate → verify), DAO tests on in-memory Drift, and a data-preservation snapshot test if restructuring existing data.
6. **Document** — update `data_architecture.md` (entity map) in the same change; note migration gotchas in `knowledge/troubleshooting/` if any.
