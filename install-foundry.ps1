Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " GG-Agentic-Harness-Foundry: Installation Utility" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$sourceDir = $PSScriptRoot
$pluginName = "gg-agentic-harness-foundry"

# 1. Scope Selection
Write-Host "Select installation scope for the Foundry:"
Write-Host "1. Global (Available in all your IDE workspaces)"
Write-Host "2. Local (Restricted to a specific project workspace)"
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

if (-not (Test-Path $baseTarget)) {
    New-Item -ItemType Directory -Force -Path $baseTarget | Out-Null
}

$targetDir = Join-Path $baseTarget $pluginName

# 2. Backup Logic
if (Test-Path $targetDir) {
    Write-Warning "Existing installation detected at: $targetDir"
    $confirm = Read-Host "Do you want to overwrite it? A backup will be created. (Y/N)"
    if ($confirm -notmatch '^[Yy]$') {
        Write-Host "Installation aborted by user."
        exit 0
    }
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupDir = Join-Path $baseTarget "${pluginName}_backup_${timestamp}"
    Copy-Item -Path $targetDir -Destination $backupDir -Recurse -Force
    Write-Host "Backup created successfully at: $backupDir" -ForegroundColor Green
} else {
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}

# 3. Installation
Write-Host "Installing Foundry to $targetDir ..." -ForegroundColor Yellow

$foldersToCopy = @("systems", "_workspace", "scratch", "docs")
$filesToCopy = @("GG-Harness-plan.md", "README.md", "plugin.json")

foreach ($item in $foldersToCopy) {
    $srcPath = Join-Path $sourceDir $item
    if (Test-Path $srcPath) {
        Copy-Item -Path $srcPath -Destination (Join-Path $targetDir $item) -Recurse -Force
    }
}

foreach ($item in $filesToCopy) {
    $srcPath = Join-Path $sourceDir $item
    if (Test-Path $srcPath) {
        Copy-Item -Path $srcPath -Destination $targetDir -Force
    }
}

Write-Host "$([char]0x2705) Installation Complete!" -ForegroundColor Green
Write-Host "You can now use /health-check, /attention, and /goal commands in your AI IDE." -ForegroundColor White
