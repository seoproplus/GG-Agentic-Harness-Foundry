param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " GG-Agentic-Harness-Foundry Local Restore/Rollback Tool " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$currentDir = (Get-Location).Path
$targetPath = Read-Host "Enter the project directory (Press Enter to use $currentDir)"
if ([string]::IsNullOrWhiteSpace($targetPath)) {
    $targetPath = $currentDir
}

if (-not (Test-Path $targetPath)) {
    Write-Error "Directory does not exist: $targetPath"
    exit 1
}

Write-Host "Select the platform to restore for this project:"
Write-Host "1. Antigravity IDE (Gemini)"
Write-Host "2. Claude Code"
Write-Host "3. ChatGPT / OpenAI Codex"
$choice = Read-Host "Enter your choice (1/2/3)"

$pluginName = "gg-agentic-harness-foundry"
$baseDir = ""

switch ($choice) {
    '1' { $baseDir = Join-Path $targetPath ".gemini\config\plugins" }
    '2' { $baseDir = Join-Path $targetPath ".claude\skills" }
    '3' { $baseDir = Join-Path $targetPath ".openai\plugins" }
    default { Write-Error "Invalid choice. Exiting."; exit 1 }
}

if (-not (Test-Path $baseDir)) {
    Write-Error "The local platform directory does not exist: $baseDir"
    exit 1
}

$backups = Get-ChildItem -Path $baseDir -Directory -Filter "${pluginName}_backup_*" | Sort-Object Name -Descending

if ($backups.Count -eq 0) {
    Write-Host "No backups found for $pluginName in $baseDir." -ForegroundColor Yellow
    exit 0
}

Write-Host "Available Local Backups:" -ForegroundColor Yellow
for ($i = 0; $i -lt $backups.Count; $i++) {
    Write-Host "[$($i + 1)] $($backups[$i].Name)"
}

$bChoice = Read-Host "Select the backup to restore (1-$($backups.Count), or press Enter to cancel)"
if ([string]::IsNullOrWhiteSpace($bChoice)) {
    Write-Host "Restore cancelled."
    exit 0
}

$bIndex = [int]$bChoice - 1
if ($bIndex -lt 0 -or $bIndex -ge $backups.Count) {
    Write-Error "Invalid selection."
    exit 1
}

$selectedBackup = $backups[$bIndex]
$destPath = Join-Path $baseDir $pluginName

if (Test-Path $destPath) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $corruptedPath = Join-Path $baseDir "${pluginName}_corrupted_${timestamp}"
    Write-Host "Moving current installation to $corruptedPath ..."
    Rename-Item -Path $destPath -NewName $corruptedPath -Force
}

Write-Host "Restoring local backup $($selectedBackup.Name) ..."
Copy-Item -Path $selectedBackup.FullName -Destination $destPath -Recurse -Force

Write-Host "$([char]0x2705) Successfully restored!" -ForegroundColor Green
