# Migrates local database (menfit.sqlite) and SharedPreferences from the
# legacy package (com.example.menfit_app) to the new branded package
# (com.jarrodfranz.menfit) on an Android device or emulator via ADB.
#
# Usage:
#   .\scripts\migrate_device_data.ps1
#   .\scripts\migrate_device_data.ps1 -Device emulator-5554
#
# ASCII only, no BOM.

param(
  [string]$Device = '',
  [string]$SourcePackage = 'com.example.menfit_app',
  [string]$TargetPackage = 'com.jarrodfranz.menfit'
)

$ErrorActionPreference = 'Stop'

function Exec-Adb([string[]]$AdbArgs) {
  $cmd = @('adb')
  if ($Device) {
    $cmd += @('-s', $Device)
  }
  $cmd += $AdbArgs
  $result = & $cmd[0] $cmd[1..($cmd.Length - 1)] 2>&1
  return $result
}

Write-Host "=== MenFit Cross-Package Data Migration ===" -ForegroundColor Cyan

# 1. Verify ADB is installed
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
  Write-Error "adb command not found in PATH. Ensure Android SDK platform-tools is installed."
}

# 2. Check device
$devices = @(& adb devices | Where-Object { $_ -match '\tdevice$' })
if ($devices.Count -eq 0) {
  Write-Error "No connected Android devices or emulators found."
}
if (-not $Device) {
  $firstDev = ($devices[0] -split '\t')[0].Trim()
  $Device = $firstDev
  Write-Host "Auto-selected device: $Device" -ForegroundColor Green
}

# 3. Verify packages
Write-Host "Checking packages on $Device..."
$packages = Exec-Adb @('shell', 'pm', 'list', 'packages')
$hasSource = $packages | Where-Object { $_ -match "package:$SourcePackage" }
$hasTarget = $packages | Where-Object { $_ -match "package:$TargetPackage" }

if (-not $hasSource) {
  Write-Error "Source package '$SourcePackage' is not installed on $Device."
}

if (-not $hasTarget) {
  Write-Host "Target package '$TargetPackage' is not yet installed on $Device." -ForegroundColor Yellow
  Write-Host "Please build and install '$TargetPackage' first, for example:" -ForegroundColor Yellow
  Write-Host "  .\scripts\run.ps1 $Device" -ForegroundColor Cyan
  exit 1
}

# 4. Stop running instances
Write-Host "Stopping source and target apps..." -ForegroundColor Cyan
Exec-Adb @('shell', 'am', 'force-stop', $SourcePackage) | Out-Null
Exec-Adb @('shell', 'am', 'force-stop', $TargetPackage) | Out-Null

# 5. Check source data
$sourceDbCheck = Exec-Adb @('shell', 'run-as', $SourcePackage, 'ls', '-l', 'app_flutter/menfit.sqlite')
if ($sourceDbCheck -match 'No such file') {
  Write-Error "Source database app_flutter/menfit.sqlite does not exist in $SourcePackage."
}
Write-Host "Found source database: $sourceDbCheck" -ForegroundColor Green

# 6. Stage files in /data/local/tmp/menfit_migration
$tmpDir = '/data/local/tmp/menfit_migration'
Exec-Adb @('shell', "rm -rf $tmpDir && mkdir -p $tmpDir && chmod 777 $tmpDir") | Out-Null

Write-Host "Extracting data from $SourcePackage..." -ForegroundColor Cyan
Exec-Adb @('shell', "run-as $SourcePackage cp app_flutter/menfit.sqlite $tmpDir/menfit.sqlite") | Out-Null
# Copy WAL / SHM files if present
Exec-Adb @('shell', "run-as $SourcePackage sh -c 'cp app_flutter/menfit.sqlite-wal $tmpDir/ 2>/dev/null || true'") | Out-Null
Exec-Adb @('shell', "run-as $SourcePackage sh -c 'cp app_flutter/menfit.sqlite-shm $tmpDir/ 2>/dev/null || true'") | Out-Null
# Copy SharedPreferences if present
Exec-Adb @('shell', "run-as $SourcePackage sh -c 'cp shared_prefs/FlutterSharedPreferences.xml $tmpDir/ 2>/dev/null || true'") | Out-Null

# Make temp files world-readable for transfer
Exec-Adb @('shell', "chmod -R 777 $tmpDir") | Out-Null

# 7. Push into target package
Write-Host "Injecting data into $TargetPackage..." -ForegroundColor Cyan
Exec-Adb @('shell', "run-as $TargetPackage mkdir -p app_flutter shared_prefs") | Out-Null
Exec-Adb @('shell', "run-as $TargetPackage cp $tmpDir/menfit.sqlite app_flutter/menfit.sqlite") | Out-Null
Exec-Adb @('shell', "run-as $TargetPackage sh -c 'cp $tmpDir/menfit.sqlite-wal app_flutter/ 2>/dev/null || true'") | Out-Null
Exec-Adb @('shell', "run-as $TargetPackage sh -c 'cp $tmpDir/menfit.sqlite-shm app_flutter/ 2>/dev/null || true'") | Out-Null
Exec-Adb @('shell', "run-as $TargetPackage sh -c 'cp $tmpDir/FlutterSharedPreferences.xml shared_prefs/ 2>/dev/null || true'") | Out-Null

# Secure target permissions
Exec-Adb @('shell', "run-as $TargetPackage chmod 600 app_flutter/menfit.sqlite") | Out-Null
Exec-Adb @('shell', "run-as $TargetPackage sh -c 'chmod 600 app_flutter/menfit.sqlite* 2>/dev/null || true'") | Out-Null
Exec-Adb @('shell', "run-as $TargetPackage sh -c 'chmod 600 shared_prefs/FlutterSharedPreferences.xml 2>/dev/null || true'") | Out-Null

# 8. Clean up temp directory
Exec-Adb @('shell', "rm -rf $tmpDir") | Out-Null

# 9. Verify target files
$targetDbCheck = Exec-Adb @('shell', 'run-as', $TargetPackage, 'ls', '-la', 'app_flutter')
Write-Host "Target app_flutter directory verified:" -ForegroundColor Green
$targetDbCheck | ForEach-Object { Write-Host "  $_" }

Write-Host "`nMigration successfully completed!" -ForegroundColor Green
Write-Host "You can now launch $TargetPackage to see your transferred data." -ForegroundColor Cyan
