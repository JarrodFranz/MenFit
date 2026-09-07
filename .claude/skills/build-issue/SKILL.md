---
name: build-issue
description: Use for build failures, codegen failures, dependency conflicts, platform build/release problems, or tooling breakage.
---

# Build / Release Issue Workflow

1. **Check known issues first** — `knowledge/troubleshooting/` and central base (`platform-windows.md`, `platform-web.md`, `testing-pitfalls.md`) — build problems recur.
2. **Isolate the layer** — Dart compile vs codegen (`build_runner` — the `--delete-conflicting-outputs` flag no longer exists in this toolchain; try deleting `.dart_tool/build`) vs pub resolution (`flutter pub deps`; avoid casual `pub upgrade` — pin what fixed it) vs platform toolchain (Gradle/Xcode/CMake/web) vs flutter tool itself (`flutter doctor -v`, `flutter clean` as evidence-gathering, not ritual).
3. **Reproduce minimally & read the actual error** — the first error, not the cascade. Windows notes: kill stale processes locking build outputs; path-length and CRLF issues are real; see central `platform-windows.md` for process-kill mechanics.
4. **Fix root cause** — not suppress-and-move-on; version pins get a comment with the reason; iOS build issues cannot be verified on this Windows machine — document precisely what a Mac session must check.
5. **Verify the full matrix affected** — validation sequence + the platform builds that could regress (web + windows locally; android when relevant).
6. **Capture (mandatory for this workflow)** — every diagnosed build issue goes to `knowledge/troubleshooting/` (Symptom/Cause/Fix/versions) or the central base if generic. Build issues are the highest-recurrence knowledge category.
