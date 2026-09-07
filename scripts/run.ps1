# Runs the app with BOTH env files, so build-time configuration is actually
# present.
#
# Why this script exists: `ORS_API_KEY` (route suggestions) is a compile-time
# `String.fromEnvironment` and is deliberately NOT in the committed
# `env/*.json` (ADR 006 - it is secret-ish and never repo material). A plain
# `flutter run` therefore builds with an empty key, and the suggest screen
# correctly shows its "not switched on yet" setup card. That looks exactly
# like a missing feature, which is what makes forgetting the flags expensive.
#
#   .\scripts\run.ps1                      # default device
#   .\scripts\run.ps1 emulator-5554        # a named device
#   .\scripts\run.ps1 chrome -Release
#
# ASCII only, no BOM: Windows PowerShell 5.1 reads BOM-less UTF-8 as ANSI and
# mangles non-ASCII characters into parse errors far from the real cause.

param(
  [string]$Device = '',
  [string]$Env = 'dev',
  [switch]$Release
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$envFile = Join-Path $root "env/$Env.json"
$secretsFile = Join-Path $root "env/$Env.secrets.json"

if (-not (Test-Path $envFile)) {
  Write-Error "No env file at $envFile"
}

$flutterArgs = @('run')
if ($Device) { $flutterArgs += @('-d', $Device) }
if ($Release) { $flutterArgs += '--release' }
$flutterArgs += "--dart-define-from-file=$envFile"

# The secrets overlay is optional: it is gitignored, so a fresh clone will not
# have one. Say so rather than failing - everything except route suggestions
# works without it.
if (Test-Path $secretsFile) {
  $flutterArgs += "--dart-define-from-file=$secretsFile"
} else {
  Write-Host "No $Env.secrets.json - route suggestions will show the setup card." -ForegroundColor Yellow
  Write-Host "Create env/$Env.secrets.json with { `"ORS_API_KEY`": `"...`" } to enable them." -ForegroundColor Yellow
}

Write-Host "flutter $($flutterArgs -join ' ')" -ForegroundColor Cyan
Push-Location $root
try {
  & flutter @flutterArgs
} finally {
  Pop-Location
}
