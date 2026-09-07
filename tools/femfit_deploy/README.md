# FemFit Deploy (Windows GUI)

A small WinForms front end for `scripts/distribute_android.ps1`. Double-click
`bin/FemFitDeploy.exe`, choose the environment, edit the release notes, tick
the optional tester group if wanted, press **Deploy**. The tool never
reimplements the script; it runs

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<repo>\scripts\distribute_android.ps1" -Env <env> -Groups "<groups>" -Notes "<notes>" [-SkipBuild]
```

with the repo root as the working directory and streams stdout/stderr into
the log pane. **Cancel** kills the whole process tree (`taskkill /T /F`).

## Rebuild

```
powershell -ExecutionPolicy Bypass -File tools/femfit_deploy/build.ps1
```

Uses the .NET Framework 4 `csc.exe` that ships with Windows (C# 5 syntax
only; no dotnet SDK). Output: `tools/femfit_deploy/bin/FemFitDeploy.exe`
(gitignored). The app icon is embedded from
`windows/runner/resources/app_icon.ico` when present.

Self-test without deploying:

```
tools\femfit_deploy\bin\FemFitDeploy.exe --dry-run
```

writes `tools/femfit_deploy/bin/dry-run.txt` with the resolved repo root,
config, preflight results and the exact command for both checkbox states.

## Repo discovery

Walks up from the exe's folder until it finds a directory containing both
`pubspec.yaml` and `scripts/distribute_android.ps1`. `--repo <path>` overrides
this; if neither works a folder picker appears.

## Group checkbox -> Firebase groups

`distribution/android.json` holds two plain fields with Firebase group
**aliases** (Firebase console > App Distribution > Testers & Groups shows the
alias next to each display name; aliases are auto-generated in lowercase):

| Field                  | Meaning                                          |
|------------------------|--------------------------------------------------|
| `testerGroups`         | Always included (e.g. `main`).                   |
| `optionalTesterGroups` | Added only when the checkbox is ticked (`testers`). |

Unchecked sends `-Groups "main"`; checked sends `-Groups "main,testers"`.
The checkbox label is built from those values, so editing the JSON updates
the GUI without a rebuild.

## Preflight

Blocking (Deploy stays disabled): `android/key.properties` present, `firebase`
CLI on PATH, `flutter` on PATH, `firebaseAppId` and `testerGroups` set,
`env/<env>.json` present. Warning only: `env/<env>.secrets.json` missing
(FatSecret and route suggestions show setup cards in that build). The tool
only tests that the secrets file exists; it never opens it.
