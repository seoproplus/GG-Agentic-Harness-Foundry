Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " GG-Agentic-Harness-Foundry: Rollback Utility" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$pluginName = "gg-agentic-harness-foundry"

# 1. Scope Selection
Write-Host "Select rollback scope:"
Write-Host "1. Global"
Write-Host "2. Local"
$sChoice = Read-Host "Choice (1/2)"

$baseTarget = ""
if ($sChoice -eq '1') {
    $baseTarget = Join-Path $env:USERPROFILE ".gemini\config\plugins"
} elseif ($sChoice -eq '2') {
    $localPath = Read-Host "Enter the local project path (e.g., C:\Projects\MyApp)"
    if (-not (Test-Path $localPath)) {
        Write-Error "Path does not exist: $localPath"
        exit 1
    }
    $baseTarget = Join-Path $localPath ".gemini\config\plugins"
} else {
    Write-Error "Invalid choice. Exiting."
    exit 1
}

$targetDir = Join-Path $baseTarget $pluginName

if (-not (Test-Path $baseTarget)) {
    Write-Error "Foundry is not installed in the selected scope ($baseTarget)."
    exit 1
}

# 2. Find Backups
$backups = Get-ChildItem -Path $baseTarget -Directory -Filter "${pluginName}_backup_*" | Sort-Object Name -Descending

if ($backups.Count -eq 0) {
    Write-Host "No backup found in $baseTarget. Cannot perform rollback." -ForegroundColor Yellow
    exit 0
}

Write-Host "Available Backups:"
for ($i = 0; $i -lt $backups.Count; $i++) {
    Write-Host "$($i + 1). $($backups[$i].Name)"
}

$bChoice = Read-Host "Select a backup to restore (1-$($backups.Count))"
$selectedIndex = [int]$bChoice - 1

if ($selectedIndex -lt 0 -or $selectedIndex -ge $backups.Count) {
    Write-Error "Invalid choice."
    exit 1
}

$selectedBackup = $backups[$selectedIndex].FullName

# 3. Restore Logic
if (Test-Path $targetDir) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $corruptedDir = Join-Path $baseTarget "${pluginName}_corrupted_${timestamp}"
    Rename-Item -Path $targetDir -NewName $corruptedDir -Force
    Write-Host "Current (corrupted) installation moved to: $corruptedDir" -ForegroundColor Yellow
}

Write-Host "Restoring from $selectedBackup ..." -ForegroundColor Cyan
Copy-Item -Path $selectedBackup -Destination $targetDir -Recurse -Force

Write-Host "$([char]0x2705) Rollback Complete!" -ForegroundColor Green
