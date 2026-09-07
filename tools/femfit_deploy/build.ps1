# Compiles FemFit Deploy into a single dependency-free exe using the .NET
# Framework 4 C# compiler that ships with Windows (no dotnet SDK needed).
#
#   powershell -ExecutionPolicy Bypass -File tools/femfit_deploy/build.ps1
#
# Output: tools/femfit_deploy/bin/FemFitDeploy.exe (gitignored).
# ASCII only, no BOM; Windows PowerShell 5.1 compatible.

$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$csc = Join-Path $env:SystemRoot 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path $csc)) {
  $csc = Join-Path $env:SystemRoot 'Microsoft.NET\Framework\v4.0.30319\csc.exe'
}
if (-not (Test-Path $csc)) {
  throw 'csc.exe not found under Microsoft.NET\Framework64\v4.0.30319 (or Framework). The .NET Framework 4.x runtime is required.'
}

$binDir = Join-Path $here 'bin'
New-Item -ItemType Directory -Force -Path $binDir | Out-Null
$outExe = Join-Path $binDir 'FemFitDeploy.exe'

$sources = Get-ChildItem -Path $here -Filter '*.cs' | ForEach-Object { $_.FullName }
if (-not $sources) { throw "No .cs sources found in $here" }

$references = @(
  'System.dll',
  'System.Core.dll',
  'System.Drawing.dll',
  'System.Windows.Forms.dll',
  'System.Web.Extensions.dll'
)

$cscArgs = @('/nologo', '/target:winexe', '/optimize+', '/warn:4', "/out:$outExe")
foreach ($ref in $references) { $cscArgs += "/reference:$ref" }

$icon = Join-Path $here '..\..\windows\runner\resources\app_icon.ico'
if (Test-Path $icon) {
  $icon = (Resolve-Path $icon).Path
  $cscArgs += "/win32icon:$icon"
  Write-Host "Embedding icon $icon"
} else {
  Write-Host 'No windows/runner/resources/app_icon.ico; building without an icon.'
}

$cscArgs += $sources

Write-Host "Compiling $($sources.Count) source file(s) with $csc"
& $csc @cscArgs
if ($LASTEXITCODE -ne 0) { throw "csc.exe failed with exit code $LASTEXITCODE" }

$sizeKb = [math]::Round((Get-Item $outExe).Length / 1KB, 1)
Write-Host "Built: $outExe ($sizeKb KB)" -ForegroundColor Green
