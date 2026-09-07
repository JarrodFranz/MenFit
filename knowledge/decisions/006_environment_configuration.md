# 006 — Environment Configuration: dart-define-from-file; no flavors yet

- **Status:** Accepted
- **Date:** 2026-08-25

## Context
Need dev/staging/prod configuration across four platforms without committing secrets. Windows and Web have no flavor concept; anything compiled into a Flutter binary is extractable.

## Options considered
`--dart-define-from-file`; envied; flutter_dotenv; native flavors (Gradle/Xcode).

## Decision
**`--dart-define-from-file` with committed non-secret env files** `env/dev.json`, `env/staging.json`, `env/prod.json` (API base URL, env name, flags, log level). One reader: `core/config/env.dart` via `String.fromEnvironment` (compile-time const, all platforms). Running with no defines defaults to dev.

Secret-ish client keys (map tiles etc. — always rate-limited/domain-locked server-side): CI writes a gitignored `env/*.secrets.json` from its secret store and passes both files via repeated `--dart-define-from-file`. Runtime user secrets (tokens) → secure storage per ADR 003 sidecar rules. True secrets never ship in the client.

**Native flavors deferred** — add standard Gradle flavors + Xcode schemes only when a staging TestFlight/Play track requires side-by-side installs; they're additive later, a tax now, and don't exist on Windows/Web anyway.

## Consequences
Build/run commands must pass `--dart-define-from-file=env/<env>.json` for non-dev; documented in README; a `env/*.secrets.json` gitignore entry exists from day one.

## Rejected alternatives
- **envied** — obfuscation is security theater; adds codegen for negative benefit.
- **flutter_dotenv** — runtime `.env` ships readable in the asset bundle; strictly worse.
- **flavors now** — premature; dart-define is the only mechanism spanning all four platforms.
