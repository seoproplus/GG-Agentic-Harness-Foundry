param(
    [Parameter(Mandatory=$true, HelpMessage="경로를 지정하세요 (예: _workspace/scaffolded_harness/us-stock-analyzer)")]
    [string]$SourceDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path $SourceDir)) {
    Write-Error "소스 디렉토리를 찾을 수 없습니다: $SourceDir"
    exit 1
}

$harnessName = Split-Path $SourceDir -Leaf

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " GG-Agentic-Harness-Foundry: Harness Deployment Utility" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Deploying: $harnessName"
Write-Host ""

# 1. Platform Selection
Write-Host "Select target AI platform:"
Write-Host "1. Antigravity IDE (Gemini)"
Write-Host "2. Claude Code"
Write-Host "3. ChatGPT / OpenAI Codex"
$pChoice = Read-Host "Choice (1/2/3)"

$platformFolder = ""
switch ($pChoice) {
    '1' { $platformFolder = ".gemini\config\plugins" }
    '2' { $platformFolder = ".claude\skills" }
    '3' { $platformFolder = ".openai\plugins" }
    default { Write-Error "Invalid choice. Exiting."; exit 1 }
}

# 2. Scope Selection
Write-Host ""
Write-Host "Select installation scope:"
Write-Host "1. Global (Available everywhere)"
Write-Host "2. Local (Restricted to a specific project directory)"
$sChoice = Read-Host "Choice (1/2)"

$baseTarget = ""
if ($sChoice -eq '1') {
    $baseTarget = Join-Path $env:USERPROFILE $platformFolder
} elseif ($sChoice -eq '2') {
    $localPath = Read-Host "Enter the local project path (e.g., C:\Projects\MyApp)"
    if (-not (Test-Path $localPath)) {
        Write-Error "Path does not exist: $localPath"
        exit 1
    }
    $baseTarget = Join-Path $localPath $platformFolder
} else {
    Write-Error "Invalid choice. Exiting."
    exit 1
}

if (-not (Test-Path $baseTarget)) {
    New-Item -ItemType Directory -Force -Path $baseTarget | Out-Null
}

$finalTarget = Join-Path $baseTarget $harnessName

# 3. Conflict Check & Evasion
while (Test-Path $finalTarget) {
    Write-Warning "Conflict Detected: A harness named '$harnessName' already exists at $baseTarget"
    Write-Host "Choose resolution:"
    Write-Host "1. Overwrite existing harness (Backup will be created automatically)"
    Write-Host "2. Rename and deploy as a new harness (Evasion)"
    Write-Host "3. Cancel deployment"
    $rChoice = Read-Host "Choice (1/2/3)"
    
    if ($rChoice -eq '1') {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = Join-Path $baseTarget "${harnessName}_backup_${timestamp}"
        Copy-Item -Path $finalTarget -Destination $backupPath -Recurse -Force
        Write-Host "Backup created: $backupPath" -ForegroundColor Green
        break # Proceed to overwrite
    } elseif ($rChoice -eq '2') {
        $newName = Read-Host "Enter new harness name (e.g., $harnessName-v2)"
        if ([string]::IsNullOrWhiteSpace($newName)) {
            Write-Error "Name cannot be empty."
            exit 1
        }
        $harnessName = $newName
        $finalTarget = Join-Path $baseTarget $harnessName
        # Loop again to check if the new name also conflicts
    } else {
        Write-Host "Deployment cancelled."
        exit 0
    }
}

# 4. Deployment
Write-Host "Deploying files to $finalTarget ..." -ForegroundColor Yellow
Copy-Item -Path "$SourceDir\*" -Destination $finalTarget -Recurse -Force

Write-Host "$([char]0x2705) Harness deployment successful!" -ForegroundColor Green
Write-Host "You can now use your newly scaffolded agents." -ForegroundColor White
