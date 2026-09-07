# Builds a release-signed Android APK and uploads it to Firebase App
# Distribution, which emails every tester in the named groups.
#
#   .\scripts\distribute_android.ps1                       # staging build, groups from distribution/android.json
#   .\scripts\distribute_android.ps1 -Notes "Fixes cycle calendar crash"
#   .\scripts\distribute_android.ps1 -Env prod -Groups "testers,family"
#   .\scripts\distribute_android.ps1 -SkipBuild            # re-upload the last APK
#
# Prerequisites (one-time, documented in
# knowledge/engineering/release_and_distribution.md):
#   1. scripts/create_upload_keystore.ps1 has been run (android/key.properties exists).
#   2. `npm install -g firebase-tools` and `firebase login` on this machine.
#   3. distribution/android.json has the Firebase Android app id filled in.
#
# The script REFUSES to upload a debug-signed build. Testers who install one
# cannot later update to a release-signed build without uninstalling, and
# uninstalling deletes their local health data.
#
# ASCII only, no BOM: Windows PowerShell 5.1 reads BOM-less UTF-8 as ANSI.

param(
  [string]$Env = '',
  [string]$Groups = '',
  [string]$Notes = '',
  [string]$AppId = '',
  [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
  $config = Get-Content (Join-Path $root 'distribution/android.json') -Raw | ConvertFrom-Json
  if (-not $Env) { $Env = $config.env }
  if (-not $Groups) { $Groups = $config.testerGroups }
  if (-not $AppId) { $AppId = $config.firebaseAppId }

  if (-not $AppId) {
    Write-Error 'No Firebase app id. Fill in distribution/android.json (firebaseAppId) or pass -AppId.'
  }
  if (-not (Test-Path 'android/key.properties')) {
    Write-Error 'android/key.properties is missing, so the build would be debug-signed. Run scripts/create_upload_keystore.ps1 first.'
  }
  if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
    Write-Error 'firebase CLI not found. Run: npm install -g firebase-tools ; firebase login'
  }

  $envFile = "env/$Env.json"
  $secretsFile = "env/$Env.secrets.json"
  if (-not (Test-Path $envFile)) { Write-Error "No env file at $envFile" }

  $apk = 'build/app/outputs/flutter-apk/app-release.apk'

  if (-not $SkipBuild) {
    $flutterArgs = @('build', 'apk', '--release', "--dart-define-from-file=$envFile")
    if (Test-Path $secretsFile) {
      $flutterArgs += "--dart-define-from-file=$secretsFile"
    } else {
      Write-Host "No $secretsFile - this build will use Open Food Facts only (no FatSecret) and route suggestions will show their setup card." -ForegroundColor Yellow
    }
    Write-Host "flutter $($flutterArgs -join ' ')" -ForegroundColor Cyan
    & flutter @flutterArgs
    if ($LASTEXITCODE -ne 0) { Write-Error "flutter build failed with exit code $LASTEXITCODE" }
  }

  if (-not (Test-Path $apk)) { Write-Error "No APK at $apk" }

  if (-not $Notes) {
    $sha = (git rev-parse --short HEAD).Trim()
    $subject = (git log -1 --pretty=%s).Trim()
    $Notes = "$Env build $sha - $subject"
  }

  $sizeMb = [math]::Round((Get-Item $apk).Length / 1MB, 1)
  Write-Host "Uploading $apk ($sizeMb MB) to groups '$Groups'" -ForegroundColor Cyan
  Write-Host "Release notes: $Notes"

  $prevTls = $env:NODE_TLS_REJECT_UNAUTHORIZED
  try {
    # Node.js CLI fails with self-signed certificate / revocation check on Windows when Avast Web Shield scans HTTPS.
    $env:NODE_TLS_REJECT_UNAUTHORIZED = '0'
    & firebase appdistribution:distribute $apk `
      --app $AppId `
      --groups $Groups `
      --release-notes $Notes
    if ($LASTEXITCODE -ne 0) { Write-Error "firebase upload failed with exit code $LASTEXITCODE" }
  } finally {
    $env:NODE_TLS_REJECT_UNAUTHORIZED = $prevTls
  }

  Write-Host 'Done. Testers in those groups have been emailed.' -ForegroundColor Green
} finally {
  Pop-Location
}
