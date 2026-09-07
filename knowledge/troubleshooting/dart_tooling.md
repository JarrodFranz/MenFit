# Dart tooling

Problems with the `dart` / `flutter` command-line tools themselves, as
opposed to the app's build (`android_build.md`), its dependencies
(`dependency_resolution.md`) or its database (`database_migrations.md`).

---

## `dart run <file>.dart` fails with a hooks_runner `PathAccessException`

**Symptom** (2026-09-03, Dart 3.13.2 / Flutter 3.47.2, Windows 11). Running
any Dart file directly from this package — even a two-line `void main() =>
print('hello');` — fails before the program starts:

```
Running build hooks...Running build hooks...PathAccessException: Cannot open file, path = 'D:\...\Female running app\.dart_tool\hooks_runner\objective_c\8e04c28b44\stderr.txt' (OS Error: Access is denied, errno = 5)
#0      _checkForErrorResponse (dart:io/common.dart:58)
...
#4      NativeAssetsBuildRunner._createFileStreamingLogger (package:hooks_runner/src/build_runner/build_runner.dart:748)
...
#19     DartNativeAssetsBuilder.compileNativeAssetsJitYamlFile (package:dartdev/src/native_assets.dart:107)
#21     RunCommand._runLocal (package:dartdev/src/commands/run.dart:531)
```

It alternates between `stdout.txt` and `stderr.txt`, and it is
**deterministic** — three consecutive runs, same failure.

**What is not the cause.** Not a permissions problem: the same file can be
created by hand in the same directory in the same shell
(`echo test > .dart_tool/hooks_runner/objective_c/<hash>/stderr.txt`
succeeds). Not a stale cache: deleting the file changes nothing. Not the
script — a `print('hello')` with no imports fails identically.

**Cause (inferred, not confirmed by a fix).** `dart run <file>` takes
dartdev's `_runLocal` path, which JIT-compiles native assets by running
`hooks_runner` over every dependency that has a build hook. `objective_c`
9.5.0 (transitive) has one. The progress line prints **twice** —
`Running build hooks...Running build hooks...` — i.e. two runners start
against the same package directory, and the second one's exclusive open of
the log file collides with the first's open handle. Windows reports a
sharing violation as `Access is denied, errno = 5`, which is exactly what
comes back. On POSIX the two opens would coexist, which is presumably why
this is a Windows-only report.

**What still works, so this is a nuisance and not a blocker:**

- `flutter test`, `flutter analyze`, `flutter run`, `flutter build` — all
  fine; none of them goes through `_runLocal`.
- **`dart run build_runner build` — fine.** The package-binary form of
  `dart run` does not hit this; only `dart run <path>.dart` does. So the
  documented validation sequence is unaffected.

**Workaround, when you actually need to execute a chunk of this app's pure
Dart** (e.g. to sanity-check parser or mapping logic without a widget
test): copy the pure-Dart sources into a **throwaway standalone package**
outside the project — a `pubspec.yaml` with a name, an SDK constraint and
**no dependencies at all**, so there are no build hooks to run — rewrite
the `package:menfit_app/...` imports to relative ones, and `dart run` there.
Verified working 2026-09-03 for the nutrition-label parser and the
label-scan mapping.

Two things that bite while doing it:

- The SDK constraint must be **`^3.13.0`**, not `>=3.0.0`. This codebase
  uses null-aware elements (`?v` inside a collection literal); under a
  lower constraint the copied files fail to compile with *"This requires
  the experimental 'null-aware-elements' language feature to be enabled."*
- Anything the copied code imports from outside the pure subtree has to be
  stubbed. For the label parser that was one method
  (`ParsedColumn.toNutritionFacts()`, which pulls in freezed via
  `NutritionFacts`) and one function (`formatNutritionField`, copied
  verbatim out of `nutrition_format.dart`).

The scratch package is a diagnostic tool, never a source of truth: it is a
*copy*, so it can silently go stale. Anything it proves still has to end up
in a real test in `test/`.
