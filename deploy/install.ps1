# -*- coding: utf-8 -*-
Param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("gemini", "claude", "openai", "chatgpt")]
    [string]$Platform = "gemini"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Normalize platform alias
$platformLower = $Platform.ToLower()
$targetSubDir = ".gemini"
$platformDisplayName = "Gemini"

if ($platformLower -eq "claude") {
    $targetSubDir = ".claude"
    $platformDisplayName = "Claude Code"
} elseif ($platformLower -eq "openai" -or $platformLower -eq "chatgpt") {
    $targetSubDir = ".openai"
    $platformDisplayName = "ChatGPT/Codex (OpenAI)"
}

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "         GG-Agentic-Harness-Foundry v1.5.0 자동 설치 (Target: $platformDisplayName)" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

# Claude Code uses native paths without config/ subdirectory
if ($platformLower -eq "claude") {
    $pluginDirName = "gg-agentic-harness-foundry"
    $legacyDirName = "agentic_os_harness"
    $targetParentDir = "$env:USERPROFILE\$targetSubDir"
    $targetPluginPath = Join-Path $targetParentDir $pluginDirName
    $targetLegacyPath = Join-Path $targetParentDir $legacyDirName
    $sourcePluginPath = Join-Path $PSScriptRoot "gg-agentic-harness-foundry"
} else {
    # Gemini and OpenAI use config/plugins structure
    $pluginDirName = "gg-agentic-harness-foundry"
    $legacyDirName = "agentic_os_harness"
    $targetParentDir = "$env:USERPROFILE\$targetSubDir\config\plugins"
    $targetPluginPath = Join-Path $targetParentDir $pluginDirName
    $targetLegacyPath = Join-Path $targetParentDir $legacyDirName
    $sourcePluginPath = Join-Path $PSScriptRoot "gg-agentic-harness-foundry"
}

# 1. 기존 플러그인 유무 확인 및 사용자 안내
$hasLegacy = Test-Path $targetLegacyPath
$hasPlugin = Test-Path $targetPluginPath

if ($hasLegacy -or $hasPlugin) {
    Write-Host "[경고] 이전 버전의 하네스 플러그인이 $platformDisplayName 경로에서 감지되었습니다." -ForegroundColor Yellow
    if ($hasLegacy) { Write-Host " - 감지된 구형 경로: $targetLegacyPath" -ForegroundColor Yellow }
    if ($hasPlugin) { Write-Host " - 감지된 기존 경로: $targetPluginPath" -ForegroundColor Yellow }
    Write-Host ""
    
    $confirm = Read-Host "기존 버전을 제거하고 신규 버전(v1.5.0)을 새로 설치하시겠습니까? (Y/N)"
    if ($confirm.Trim().ToUpper() -ne "Y") {
        Write-Host "[설치 취소] 사용자가 승인하지 않아 설치를 중단합니다." -ForegroundColor Red
        Exit
    }
    
    Write-Host "[진행] 기존 플러그인 디렉토리를 제거합니다..." -ForegroundColor Cyan
    if ($hasLegacy) { Remove-Item -Recurse -Force $targetLegacyPath -ErrorAction SilentlyContinue }
    if ($hasPlugin) { Remove-Item -Recurse -Force $targetPluginPath -ErrorAction SilentlyContinue }
}

# 2. 신규 플러그인 설치 복사
Write-Host "[진행] $platformDisplayName 용 신규 플러그인 복사 중..." -ForegroundColor Cyan
if (-not (Test-Path $targetParentDir)) {
    New-Item -ItemType Directory -Path $targetParentDir -Force | Out-Null
}
Copy-Item -Recurse -Force $sourcePluginPath $targetParentDir

# 3. EPR/REE 저장소 및 초기 설정 데이터 배치
Write-Host "[진행] $platformDisplayName 전역 에러 패턴 레지스트리(EPR) 및 규칙 엔진(REE) 구성..." -ForegroundColor Cyan

# Claude Code uses native paths
if ($platformLower -eq "claude") {
    $eprUserPath = "$env:USERPROFILE\$targetSubDir\memory"
    $eprGlobalPath = "$env:USERPROFILE\$targetSubDir\memory"
    $reeRulesPath = "$env:USERPROFILE\$targetSubDir\rules"
} else {
    # Gemini and OpenAI use config structure
    $eprUserPath = "$env:USERPROFILE\$targetSubDir\config\error-registry\user-level"
    $eprGlobalPath = "$env:USERPROFILE\$targetSubDir\config\error-registry\global"
    $reeRulesPath = "$env:USERPROFILE\$targetSubDir\config\rules"
}

if (-not (Test-Path $eprUserPath)) { New-Item -ItemType Directory -Path $eprUserPath -Force | Out-Null }
if (-not (Test-Path $eprGlobalPath)) { New-Item -ItemType Directory -Path $eprGlobalPath -Force | Out-Null }
if (-not (Test-Path $reeRulesPath)) { New-Item -ItemType Directory -Path $reeRulesPath -Force | Out-Null }

# 시드 데이터 복사
$seedAntiPattern = Join-Path $sourcePluginPath "skills\epr\templates\global-antipatterns.md"
$seedCommonMistakes = Join-Path $sourcePluginPath "skills\epr\templates\user-level.md"
$seedRules = Join-Path $sourcePluginPath "skills\ree\templates\rule-format.md"

if ($platformLower -eq "claude") {
    # Claude Code uses memory/ for EPR data
    if (Test-Path $seedAntiPattern) { Copy-Item -Force $seedAntiPattern (Join-Path $eprGlobalPath "epr-global-antipatterns.md") }
    if (Test-Path $seedCommonMistakes) { Copy-Item -Force $seedCommonMistakes (Join-Path $eprUserPath "epr-user-common-mistakes.md") }
    if (Test-Path $seedRules) { Copy-Item -Force $seedRules (Join-Path $reeRulesPath "ecl-global-rules.md") }
} else {
    # Gemini and OpenAI structure
    if (Test-Path $seedAntiPattern) { Copy-Item -Force $seedAntiPattern (Join-Path $eprGlobalPath "anti-patterns.md") }
    if (Test-Path $seedCommonMistakes) { Copy-Item -Force $seedCommonMistakes (Join-Path $eprUserPath "common-mistakes.md") }
    if (Test-Path $seedRules) { Copy-Item -Force $seedRules (Join-Path $reeRulesPath "global-rules.md") }
}

Write-Host "================================================================================" -ForegroundColor Green
Write-Host " 🎉 GG-Agentic-Harness-Foundry v1.5.0 ($platformDisplayName) 설치 완료!" -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Green
Write-Host ""

# 4. 검증 및 작동 확인
Write-Host "[진행] 설치 상태 및 기능 검증 실행..." -ForegroundColor Cyan
$infoScript = Join-Path $targetPluginPath "foundry_info.py"
if (Test-Path $infoScript) {
    python $infoScript
} else {
    Write-Host "[오류] foundry_info.py 스크립트를 찾을 수 없습니다." -ForegroundColor Red
}
