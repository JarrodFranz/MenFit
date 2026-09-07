# Creates the Android UPLOAD keystore once and writes android/key.properties.
#
# Why this is a script and not a doc: the keystore is the single most
# expensive thing to get wrong in distribution. Android refuses to install an
# update whose signing key differs from the installed app's, so a tester on
# a build signed with key A cannot update to a build signed with key B - they
# must uninstall, and uninstalling deletes their locally stored health and
# cycle data. One key, created once, backed up, used for every tester and
# store build. See knowledge/engineering/release_and_distribution.md.
#
#   .\scripts\create_upload_keystore.ps1                   # first time
#   .\scripts\create_upload_keystore.ps1 -PropertiesOnly   # keystore exists, rewrite android/key.properties
#
# The keystore is written OUTSIDE the repo (default
# %USERPROFILE%\femfit-signing\upload-keystore.jks) so a `git clean` or a
# fresh clone can never delete it. android/key.properties (gitignored) points
# at it. Passwords are read with hidden input and handed to keytool through
# an environment variable, never on a command line. Nothing here is echoed.
#
# ASCII only, no BOM: Windows PowerShell 5.1 reads BOM-less UTF-8 as ANSI.

param(
  [string]$KeystoreDir = (Join-Path $env:USERPROFILE 'femfit-signing'),
  [string]$Alias = 'upload',
  [string]$DistinguishedName = 'CN=FemFit Upload Key, O=Jarrod Franz',
  [switch]$PropertiesOnly
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$keystorePath = Join-Path $KeystoreDir 'upload-keystore.jks'
$propertiesPath = Join-Path $root 'android/key.properties'

# Prefer the full JDK 17: Android Studio's bundled JBR is unusable on this
# machine for Gradle (knowledge/troubleshooting/android_build.md) and keytool
# from the same JDK keeps the toolchain consistent.
$candidates = @('C:\Program Files\Java\jdk-17\bin\keytool.exe')
if ($env:JAVA_HOME) { $candidates += (Join-Path $env:JAVA_HOME 'bin\keytool.exe') }
$candidates += 'keytool'
$keytool = $null
foreach ($c in $candidates) {
  if ($c -and (Get-Command $c -ErrorAction SilentlyContinue)) { $keytool = $c; break }
}
if (-not $keytool) { Write-Error 'keytool not found. Install a JDK 17 or set JAVA_HOME.' }

function Read-PlainPassword([string]$prompt) {
  $secure = Read-Host $prompt -AsSecureString
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
  finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

# Runs keytool and returns its combined output. Success is judged by exit
# code ONLY: keytool writes its "JKS is a proprietary format" advisory to
# stderr even when it succeeds, and Windows PowerShell 5.1 under
# $ErrorActionPreference = 'Stop' turns any redirected stderr line from a
# native command into a terminating NativeCommandError.
function Invoke-Keytool([string[]]$arguments) {
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    $output = & $keytool @arguments 2>&1 | ForEach-Object { "$_" }
  } finally {
    $ErrorActionPreference = $prev
  }
  if ($LASTEXITCODE -ne 0) {
    $output | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    Write-Error "keytool failed with exit code $LASTEXITCODE"
  }
  return $output
}

function Write-KeyProperties([string]$password) {
  # Gradle reads this file (android/app/build.gradle.kts). It is gitignored.
  # Plain string replace, not -replace: a lone backslash is an invalid regex.
  $storeFileForGradle = $keystorePath.Replace('\', '/')
  $lines = @(
    "storeFile=$storeFileForGradle",
    "storePassword=$password",
    "keyPassword=$password",
    "keyAlias=$Alias"
  )
  Set-Content -Path $propertiesPath -Value ($lines -join "`n") -Encoding ascii -NoNewline
}

function Show-Fingerprints([string]$password) {
  Write-Host 'Certificate fingerprints (needed if Firebase or Play ever ask for them):'
  $env:FEMFIT_KS_PASS = $password
  try {
    Invoke-Keytool @('-list', '-v', '-keystore', $keystorePath, '-alias', $Alias, '-storepass:env', 'FEMFIT_KS_PASS') |
      Select-String 'SHA1:|SHA256:'
  } finally {
    Remove-Item Env:\FEMFIT_KS_PASS -ErrorAction SilentlyContinue
  }
}

$keystoreExists = Test-Path $keystorePath

if ($PropertiesOnly) {
  if (-not $keystoreExists) { Write-Error "No keystore at $keystorePath - run without -PropertiesOnly to create one." }
  Write-Host "Writing android/key.properties for the existing keystore at $keystorePath" -ForegroundColor Cyan
  $password = Read-PlainPassword 'Keystore password (hidden)'
  # Verify the password against the keystore before writing anything, so a
  # typo here surfaces now rather than as a Gradle signing failure later.
  $env:FEMFIT_KS_PASS = $password
  try {
    Invoke-Keytool @('-list', '-keystore', $keystorePath, '-alias', $Alias, '-storepass:env', 'FEMFIT_KS_PASS') | Out-Null
  } finally {
    Remove-Item Env:\FEMFIT_KS_PASS -ErrorAction SilentlyContinue
  }
  Write-KeyProperties $password
  Write-Host "Gradle config:   $propertiesPath (gitignored)" -ForegroundColor Green
  Show-Fingerprints $password
  $password = $null
  exit 0
}

if ($keystoreExists) {
  Write-Host "A keystore already exists at $keystorePath" -ForegroundColor Yellow
  Write-Host 'Refusing to overwrite it: replacing the upload key strands every installed tester.' -ForegroundColor Yellow
  Write-Host 'To (re)write android/key.properties for it, run again with -PropertiesOnly.'
  exit 1
}

Write-Host 'Creating the FemFit upload keystore.' -ForegroundColor Cyan
Write-Host 'Choose a strong password and store it in a password manager NOW - it cannot be recovered.'
$plain1 = Read-PlainPassword 'Keystore password (hidden)'
$plain2 = Read-PlainPassword 'Repeat password (hidden)'
if ($plain1 -ne $plain2) { Write-Error 'Passwords do not match.' }
if ($plain1.Length -lt 12) { Write-Error 'Use at least 12 characters.' }

New-Item -ItemType Directory -Force $KeystoreDir | Out-Null

# keytool reads passwords from named environment variables with the :env
# suffix, so the secret never appears in the process command line.
$env:FEMFIT_KS_PASS = $plain1
try {
  Invoke-Keytool @(
    '-genkeypair', '-v',
    '-keystore', $keystorePath,
    '-storetype', 'JKS',
    '-alias', $Alias,
    '-keyalg', 'RSA', '-keysize', '2048', '-validity', '10000',
    '-dname', $DistinguishedName,
    '-storepass:env', 'FEMFIT_KS_PASS',
    '-keypass:env', 'FEMFIT_KS_PASS'
  ) | ForEach-Object { Write-Host $_ }
} finally {
  Remove-Item Env:\FEMFIT_KS_PASS -ErrorAction SilentlyContinue
}

Write-KeyProperties $plain1

Write-Host ''
Write-Host "Keystore:        $keystorePath" -ForegroundColor Green
Write-Host "Gradle config:   $propertiesPath (gitignored)" -ForegroundColor Green
Write-Host ''
Write-Host 'BACK UP THE .jks FILE AND THE PASSWORD SOMEWHERE OUTSIDE THIS MACHINE.' -ForegroundColor Yellow
Write-Host 'Losing either means no existing tester can ever receive another update.' -ForegroundColor Yellow
Write-Host ''
Show-Fingerprints $plain1
$plain1 = $null; $plain2 = $null
