param(
    [string]$GodotPath = "C:\Users\13948\Desktop\Godot_v4.6.2-stable_win64.exe",
    [int]$TimeoutSeconds = 45
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$userRoot = Join-Path $env:APPDATA "Linxi's Evaluation Adventure"
$targets = @(
    Get-ChildItem (Join-Path $projectRoot "tests") -Filter "run_*.gd" | Sort-Object Name
) + @(
    Get-ChildItem (Join-Path $projectRoot "tools\diagnostics") -Filter "*.gd" | Sort-Object Name
)
$results = @()

foreach ($target in $targets) {
    $testName = [IO.Path]::GetFileNameWithoutExtension($target.Name)
    $relativePath = $target.FullName.Substring($projectRoot.Length + 1).Replace("\", "/")
    $logName = "suite_$testName.log"
    $logPath = Join-Path $userRoot $logName
    if (Test-Path $logPath) {
        Remove-Item -LiteralPath $logPath -Force
    }

    $process = Start-Process `
        -FilePath $GodotPath `
        -ArgumentList @("--headless", "--path", ".", "--log-file", "user://$logName", "--script", "res://$relativePath") `
        -WorkingDirectory $projectRoot `
        -WindowStyle Hidden `
        -PassThru

    $timedOut = $false
    try {
        Wait-Process -Id $process.Id -Timeout $TimeoutSeconds -ErrorAction Stop
    } catch {
        $timedOut = $true
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }

    $content = if (Test-Path $logPath) { Get-Content -Raw $logPath } else { "" }
    $status = "NO PASS MARKER"
    if ($timedOut) {
        $status = "TIMEOUT"
    } elseif ($content -match "SCRIPT ERROR:|ERROR:|FAIL:") {
        $status = "FAIL"
    } elseif ($content -match "PASS:") {
        $status = "PASS"
    }
    $detail = (($content -split "`r?`n") | Where-Object { $_ -match "PASS:|SCRIPT ERROR:|ERROR:|FAIL:" } | Select-Object -First 2) -join " | "
    $results += [pscustomobject]@{ Status = $status; Test = $testName; Detail = $detail }
}

$results | Format-Table -Wrap -AutoSize
$failed = @($results | Where-Object { $_.Status -ne "PASS" })
if ($failed.Count -gt 0) {
    Write-Error "$($failed.Count) test(s) did not pass."
    exit 1
}

Write-Host "PASS: $($results.Count) project tests completed cleanly."
exit 0
