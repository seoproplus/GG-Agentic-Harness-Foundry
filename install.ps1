param(
    [Parameter(Position=0)]
    [ValidateSet('Gemini', 'Claude', 'OpenAI', 'All', '')]
    [string]$TargetPlatform = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " GG-Agentic-Harness-Foundry (v1.5.0) Installation Script" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

if ($TargetPlatform -eq "") {
    Write-Host "Please select the target AI IDE platform to install the Foundry plugins:"
    Write-Host "1. Antigravity IDE (Gemini)"
    Write-Host "2. Claude Code"
    Write-Host "3. ChatGPT / OpenAI Codex"
    Write-Host "4. All of the above"
    $choice = Read-Host "Enter your choice (1/2/3/4)"
    
    switch ($choice) {
        '1' { $TargetPlatform = 'Gemini' }
        '2' { $TargetPlatform = 'Claude' }
        '3' { $TargetPlatform = 'OpenAI' }
        '4' { $TargetPlatform = 'All' }
        default { Write-Error "Invalid choice. Exiting."; exit 1 }
    }
}

$sourceDir = $PSScriptRoot
$pluginName = "gg-agentic-harness-foundry"
$directoriesToCopy = @("systems", "docs", "integration", "scratch", "_workspace")

function Install-Foundry-Globally {
    param([string]$PlatformName, [string]$GlobalPath)
    
    Write-Host "[$PlatformName] Installing to $GlobalPath ..." -ForegroundColor Yellow
    
    if (Test-Path $GlobalPath) {
        Write-Warning "An existing installation was detected at $GlobalPath"
        $ans = Read-Host "Do you want to backup the existing files before installing to prevent conflicts? (Y/n)"
        if ($ans -ne "n" -and $ans -ne "N") {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $parentDir = Split-Path $GlobalPath
            $leaf = Split-Path $GlobalPath -Leaf
            $backupPath = Join-Path $parentDir "${leaf}_backup_${timestamp}"
            Copy-Item -Path $GlobalPath -Destination $backupPath -Recurse -Force
            Write-Host "Backed up existing installation to: $backupPath" -ForegroundColor Green
        } else {
            $ans2 = Read-Host "Proceed with overwrite WITHOUT backup? (y/N)"
            if ($ans2 -ne "y" -and $ans2 -ne "Y") {
                Write-Host "[$PlatformName] Installation skipped by user." -ForegroundColor DarkGray
                return
            }
        }
    } else {
        New-Item -ItemType Directory -Force -Path $GlobalPath | Out-Null
    }
    
    foreach ($dir in $directoriesToCopy) {
        if (Test-Path "$sourceDir\$dir") {
            Copy-Item -Path "$sourceDir\$dir" -Destination $GlobalPath -Recurse -Force
        }
    }
    Copy-Item -Path "$sourceDir\README.md" -Destination $GlobalPath -Force
    Write-Host "[$PlatformName] Setup Complete." -ForegroundColor Green
}

# 1. Gemini Installation Path
if ($TargetPlatform -eq 'Gemini' -or $TargetPlatform -eq 'All') {
    $geminiPath = "$env:USERPROFILE\.gemini\config\plugins\$pluginName"
    Install-Foundry-Globally -PlatformName "Gemini" -GlobalPath $geminiPath
}

# 2. Claude Installation Path
if ($TargetPlatform -eq 'Claude' -or $TargetPlatform -eq 'All') {
    $claudePath = "$env:USERPROFILE\.claude\skills\$pluginName"
    Install-Foundry-Globally -PlatformName "Claude" -GlobalPath $claudePath
}

# 3. OpenAI Installation Path
if ($TargetPlatform -eq 'OpenAI' -or $TargetPlatform -eq 'All') {
    $openaiPath = "$env:USERPROFILE\.openai\plugins\$pluginName"
    Install-Foundry-Globally -PlatformName "OpenAI" -GlobalPath $openaiPath
}

Write-Host ""
Write-Host "$([char]0x2705) Installation script finished!" -ForegroundColor Green
Write-Host "You can now use /health-check, /attention, and /goal commands in your AI IDE." -ForegroundColor White
Write-Host "For system info, run: python ./systems/foundry-info/foundry_info.py" -ForegroundColor DarkGray
