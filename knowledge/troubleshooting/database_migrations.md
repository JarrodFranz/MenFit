# Database migration traps

*Companion to the `onUpgrade` dartdoc in `lib/core/db/app_database.dart` —
that dartdoc is the authority on guard rules; this file collects the traps
discovered while writing migrations.*

## Migrator.createIndex has no IF NOT EXISTS (found 2026-09-01, schema v18)

`Migrator.createTable` guards with `IF NOT EXISTS`; **`Migrator.createIndex`
does not**. Combined with this project's `onUpgrade` convention (it ignores
`to` and runs every `from < N` branch), any migration test whose fixture
database was opened via `forTesting` (so `onCreate` already built the index)
collides with a duplicate-index error when the migration step re-runs.

**Rule for every future table-with-index migration:** the shared
migration-test fixture helpers must `DROP TABLE IF EXISTS <new_table>` before
replaying upgrade steps (dropping the table drops its indexes), exactly as
done for `water_logs` (v16) and `weight_logs` (v18). Check all `onUpgrade`
call sites in `test/core/db/app_database_test.dart` — there were 22 at v18.

Applies immediately to the planned v19 (badge/achievement persistence,
TASKS_TO_DO Task 1.8). RESOLVED for v19 - see the entry below: v19 avoided
the trap entirely.

## Migration steps that seed data must be idempotent (v18 precedent)

`onUpgrade` re-entry is possible; a seed insert (e.g. v18's
profile-weight seed) must guard with `SELECT EXISTS(...)` on something the
seed itself sets (`source = 'profile-migration'`), never on row counts the
user may have changed since.

## Table-level UNIQUE constraints sidestep the createIndex trap (v19, 2026-09-01)

A `uniqueKeys` table constraint is emitted INSIDE the `CREATE TABLE IF NOT
EXISTS` statement, so a migration step that only creates such a table is
re-entrant with zero fixture drops (v19 needed 0 across 29 onUpgrade call
sites, vs v18's drop-everywhere). Prefer `uniqueKeys` over a standalone
`@TableIndex` for uniqueness whenever the index exists for the constraint
rather than for query speed.

Related: a discriminator column in a UNIQUE key must be **NOT NULL with a
sentinel** (v19 uses tier_key = 'once' for one-off badges) - SQLite treats
two NULLs as DISTINCT inside UNIQUE, so a nullable column silently defeats
insert-idempotency.

## Migrator.addColumn is not idempotent — guard it with PRAGMA (v21, 2026-09-03)

SQLite has **no `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`**, so
`Migrator.addColumn` fails with a duplicate-column error on a second pass.
Combined with this project's `onUpgrade` convention (it ignores `to` and runs
every `from < N` branch), that means a column-addition step is *not* safe to
replay, and the conventional `from < N && from >= <introducing version>`
guard does not fix it: that guard only rules out colliding with a
`createTable` in the **same** run.

Every earlier column step (v4, v7, v12, v13, v14, v15) pays for this in the
fixtures — each is put back to its pre-step shape by a reshape helper or by
`dropAllTablesToPreV2` in `test/core/db/app_database_test.dart` before the
replay.

**v21 (13 optional nutrients on both `foods` and `nutrition_entries`, 26
columns) did it differently**, because 26 columns across two tables would
have meant reshaping `foods` at all **19** `onUpgrade` call sites whose
`from` is >= 11. The adds go through a helper on `AppDatabase` — see
`_addColumnsIfMissing` in `lib/core/db/app_database.dart` for the
implementation (a `PRAGMA table_info` existence check per column before
calling `Migrator.addColumn`).

Result: **0 existing fixture call sites had to change** (v18 had to touch
everything; v19 and v20 got away with 0 by having no index to create). The
step is genuinely re-entrant — replaying it is a no-op, and a partially
applied upgrade resumes instead of wedging.

Notes:
- The conventional `from < 21 && from >= 11` guard is kept anyway. It is
  redundant for safety once the PRAGMA check is there, but it keeps the step
  readable next to its nineteen predecessors and skips the PRAGMA entirely
  for a device below v11 (whose `createTable` already built the columns).
- `PRAGMA` takes no bound parameters, so the table name is interpolated in
  `_addColumnsIfMissing`. Safe there only because it is
  `TableInfo.actualTableName`, a generator-emitted constant — never do this
  with a value that came from anywhere else.
- **Use this helper for any future multi-column addition.** The alternative
  is another reshape fixture at every call site.

## v22 confirms the pattern: a natural primary key is also re-entrant (2026-09-03)

`daily_step_totals` (v22, ADR 013) needs exactly one row per calendar day. It
gets that from `primaryKey => {day}` — **not** a UUID `id` plus a
`@TableIndex(unique: true)`, and not `uniqueKeys` either (which would have been
redundant beside the primary key and would have created a second index for
nothing).

Same payoff as v19's `uniqueKeys`, one step further: `PRIMARY KEY (day)` is
emitted **inside** the `CREATE TABLE IF NOT EXISTS` statement, so the migration
step is `await m.createTable(dailyStepTotals);` and nothing else. **0 of the 45
pre-existing `database.migration.onUpgrade(...)` call sites in
`test/core/db/app_database_test.dart` had to change**
(v18's standalone index made every fixture drop the table first; v19/v20/v22
each got away with 0). The only edit the file needed was the mechanical
`expect(database.schemaVersion, 21)` -> `22` in 19 places.

The rule this makes concrete, alongside the v19 entry above: **express
uniqueness as a table-level constraint — a primary key where the natural key
*is* the row's identity, `uniqueKeys` where it is not — and never as a
standalone `@TableIndex`, unless the index exists for query speed rather than
for the constraint.** The bonus with a natural primary key is that drift's
`insertOnConflictUpdate` resolves the conflict on it with no explicit `target`,
so upsert-by-day needs no extra ceremony at the call site.

## v23 is the same shape again — the rule is now three-for-three (2026-09-04)

`yoga_sequences` (v23) is a brand-new table whose only constraint is its own
`PRIMARY KEY (id)`, so its whole migration step is
`await m.createTable(yogaSequences);`. **0 of the pre-existing
`database.migration.onUpgrade(...)` call sites in
`test/core/db/app_database_test.dart` had to change** — the only edit the file
needed was the mechanical `expect(database.schemaVersion, 22)` -> `23` in 20
places, plus the new v23 group.

That is v19 (`uniqueKeys`), v20, v22 (natural primary key) and now v23 all
getting away with zero fixture churn, against v18's standalone
`@TableIndex` which forced a drop at every call site. Treat the rule from the
v22 entry as settled: **express uniqueness/identity as a table-level
constraint inside `CREATE TABLE`, never as a standalone `@TableIndex`, unless
the index exists for query speed rather than for the constraint.**

Note also what v23 did *not* do: it seeds nothing. The feature ships two
starter sequences, but they live in the domain as a constant
(`YogaSequenceStarters`) and are never rows — accepting one writes a copy
under a fresh id. A seeding step would have needed the v18 idempotency dance
(`SELECT EXISTS(...)` on a marker the seed itself sets) for no gain, and would
have made "the list is empty" mean something other than "she has saved
nothing".

## Adding a table is not done until deletion and export cover it (2026-09-04)

Two tables shipped without a `deleteAllData()` and a wipe wire-up
(`strength_routines`/`strength_cycles` at v17, `water_logs` earlier) and were
only found on 2026-09-04. The defect class is "the feature works, the
privacy obligations were forgotten". Two guards now make it structural:

- `test/features/settings/delete_my_data_covers_every_table_test.dart` seeds
  one row into every table in `AppDatabase.allTables` (it fails naming any
  table without a seed entry), runs `DeleteMyDataService.run()`, and asserts
  every table is empty. **A new table must add a seed entry there and a
  `deleteAllData()` on its repository wired into the service.**
- The whole-app export (ADR 015) iterates `allTables` generically and its
  guard fails if a table is neither exported by default nor in the explicit
  S3 opt-in set. **Decide the tier when you add the table.**

Checklist for a new table: Drift class → `@DriftDatabase` list → bump
`schemaVersion` → `if (from < N) createTable` → migration tests → repository
`deleteAllData()` + `DeleteMyDataService` → seed entry in the every-table
guard → export tier (default / S3 opt-in) → `data_architecture.md` row.
