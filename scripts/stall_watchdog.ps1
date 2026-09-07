# Stall watchdog - poll for known stalled-process signatures in this project's
# dev loop and emit one line per anomaly (consumed by Claude Code's Monitor).
# ASCII-only on purpose: Windows PowerShell 5.1 reads BOM-less files as ANSI
# and mangles non-ASCII characters into parse errors.
# Signatures (from knowledge/troubleshooting + session history 2026-08-27/28):
#  - 'find' processes: agents accidentally scanning the whole drive -> KILL + report.
#  - MORE THAN ONE concurrent 'flutter test' run: they deadlock on the shared
#    .dart_tool / build/unit_test_assets state. Reported immediately, because
#    this is the early warning that precedes every wedge below.
#  - flutter_tester older than 5 min that burned ZERO cpu since the last poll:
#    genuinely stuck, not merely slow. Reports the parent 'flutter test' pids
#    too - killing only the tester leaves the parent hung forever.
#  - dart older than 45 min: leftover daemon (normal builds/tests finish well under).
# Quiet when healthy; re-reports a surviving anomaly at most every 5 minutes.
$reported = @{}
$prevCpu = @{}
while ($true) {
  $now = Get-Date
  $anomalies = @()

  Get-Process -Name find -ErrorAction SilentlyContinue | ForEach-Object {
    $age = [math]::Round(($now - $_.StartTime).TotalMinutes, 1)
    if ($age -gt 3) {
      Stop-Process -Id $_.Id -Force -Confirm:$false -ErrorAction SilentlyContinue
      $anomalies += "KILLED stray filesystem 'find' pid=$($_.Id) age=${age}m (drive-wide scan, banned by CLAUDE.md)"
    }
  }

  # Parent 'flutter test' runs, identified by the flutter_tools snapshot plus a
  # ' test ' verb in the command line.
  $testParents = @()
  Get-CimInstance Win32_Process -Filter "Name='dart.exe'" -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.CommandLine -and $_.CommandLine -match 'flutter_tools\.snapshot" test') { $testParents += $_.ProcessId }
  }
  if ($testParents.Count -gt 1) {
    $anomalies += "CONCURRENT flutter test runs pids=$($testParents -join ',') count=$($testParents.Count) (they deadlock on shared .dart_tool - run ONE at a time)"
  }

  $curCpu = @{}
  Get-Process -Name flutter_tester -ErrorAction SilentlyContinue | ForEach-Object {
    $curCpu[$_.Id] = $_.CPU
    $age = [math]::Round(($now - $_.StartTime).TotalMinutes, 1)
    if ($age -gt 5 -and $prevCpu.ContainsKey($_.Id)) {
      $delta = [math]::Round($_.CPU - $prevCpu[$_.Id], 2)
      if ($delta -le 0.05) {
        $kill = @($_.Id) + $testParents
        $anomalies += "DEADLOCKED flutter_tester pid=$($_.Id) age=${age}m cpu-delta-60s=${delta}s (zero progress; kill tester AND parents: $($kill -join ','))"
      }
    }
  }
  $prevCpu = $curCpu

  # Stale dart processes. 'flutter run' is deliberately EXEMPT: a dev server
  # is meant to live for hours and sits at 0% CPU while idle, so age alone
  # says nothing about it - flagging it every 5 minutes is pure noise, and
  # killing it would take down a server someone is actively using.
  #
  # The exemption MUST cover the children 'flutter run' spawns, not just the
  # command itself. A debug session also runs a 'dart development-service'
  # (DDS + DevTools) whose command line carries no 'flutter_tools.snapshot run'
  # marker, so the narrower match reported a perfectly healthy session on a
  # real device as a leftover after 45 minutes (observed 2026-08-27, against a
  # live Android emulator run). Acting on that report would have killed the
  # user's running app - a watchdog whose advice is destructive when wrong is
  # worse than no watchdog.
  Get-CimInstance Win32_Process -Filter "Name='dart.exe'" -ErrorAction SilentlyContinue | ForEach-Object {
    $proc = Get-Process -Id $_.ProcessId -ErrorAction SilentlyContinue
    if (-not $proc) { return }
    $age = [math]::Round(($now - $proc.StartTime).TotalMinutes, 1)
    # 'dart mcp-server' is the Dart MCP server the Claude desktop tooling
    # keeps alive for the whole session; it is long-lived by design and
    # killing it breaks the tooling (misreported 2026-09-06).
    $isDevServer = $_.CommandLine -and (
      $_.CommandLine -match 'flutter_tools\.snapshot" run' -or
      $_.CommandLine -match 'development-service' -or
      $_.CommandLine -match 'devtools' -or
      $_.CommandLine -match 'mcp-server'
    )
    if (-not $isDevServer -and $age -gt 45) {
      $anomalies += "STALE dart daemon pid=$($_.ProcessId) age=${age}m (leftover build/analysis process)"
    }
  }

  foreach ($a in $anomalies) {
    $key = ($a -split ' age=| cpu-delta| count=')[0]
    if (-not $reported.ContainsKey($key) -or ($now - $reported[$key]).TotalMinutes -ge 5) {
      $reported[$key] = $now
      Write-Output "[stall-watchdog $($now.ToString('HH:mm'))] $a"
    }
  }
  Start-Sleep -Seconds 60
}
