param(
    [Parameter(Position=0)]
    [string]$TargetPath = "",
    
    [Parameter(Position=1)]
    [ValidateSet('Gemini', 'Claude', 'OpenAI', 'All', '')]
    [string]$TargetPlatform = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " GG-Agentic-Harness-Foundry (v1.5.0) Local/Project Installation" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Target Path Selection
if ($TargetPath -eq "") {
    $currentDir = (Get-Location).Path
    $response = Read-Host "Install to current directory ($currentDir)? (Y/n)"
    if ($response -eq "" -or $response.ToLower() -eq "y") {
        $TargetPath = $currentDir
    } else {
        $TargetPath = Read-Host "Enter the full path to the target project directory"
        if (-not (Test-Path $TargetPath)) {
            Write-Error "The specified directory does not exist: $TargetPath"
            exit 1
        }
    }
}

# 2. Target Platform Selection
if ($TargetPlatform -eq "") {
    Write-Host "Please select the target AI IDE platform for this project:"
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

# Function to perform the copy
function Install-Foundry-Locally {
    param([string]$PlatformName, [string]$LocalPath)
    
    Write-Host "[$PlatformName] Installing to $LocalPath ..." -ForegroundColor Yellow
    
    if (Test-Path $LocalPath) {
        Write-Warning "An existing installation was detected at $LocalPath"
        $ans = Read-Host "Do you want to backup the existing files before installing to prevent conflicts? (Y/n)"
        if ($ans -ne "n" -and $ans -ne "N") {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $parentDir = Split-Path $LocalPath
            $leaf = Split-Path $LocalPath -Leaf
            $backupPath = Join-Path $parentDir "${leaf}_backup_${timestamp}"
            Copy-Item -Path $LocalPath -Destination $backupPath -Recurse -Force
            Write-Host "Backed up existing installation to: $backupPath" -ForegroundColor Green
        } else {
            $ans2 = Read-Host "Proceed with overwrite WITHOUT backup? (y/N)"
            if ($ans2 -ne "y" -and $ans2 -ne "Y") {
                Write-Host "[$PlatformName] Installation skipped by user." -ForegroundColor DarkGray
                return
            }
        }
    } else {
        New-Item -ItemType Directory -Force -Path $LocalPath | Out-Null
    }
    
    foreach ($dir in $directoriesToCopy) {
        if (Test-Path "$sourceDir\$dir") {
            Copy-Item -Path "$sourceDir\$dir" -Destination $LocalPath -Recurse -Force
        }
    }
    Copy-Item -Path "$sourceDir\README.md" -Destination $LocalPath -Force
    Write-Host "[$PlatformName] Setup Complete." -ForegroundColor Green
}

# 3. Execution
if ($TargetPlatform -eq 'Gemini' -or $TargetPlatform -eq 'All') {
    $geminiPath = Join-Path $TargetPath ".gemini\config\plugins\$pluginName"
    Install-Foundry-Locally -PlatformName "Gemini" -LocalPath $geminiPath
}

if ($TargetPlatform -eq 'Claude' -or $TargetPlatform -eq 'All') {
    $claudePath = Join-Path $TargetPath ".claude\skills\$pluginName"
    Install-Foundry-Locally -PlatformName "Claude" -LocalPath $claudePath
}

if ($TargetPlatform -eq 'OpenAI' -or $TargetPlatform -eq 'All') {
    $openaiPath = Join-Path $TargetPath ".openai\plugins\$pluginName"
    Install-Foundry-Locally -PlatformName "OpenAI" -LocalPath $openaiPath
}

Write-Host ""
Write-Host "$([char]0x2705) Local project installation script finished!" -ForegroundColor Green
Write-Host "The Foundry has been integrated into the target project workspace." -ForegroundColor White
