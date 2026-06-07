#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# ANSI escape codes for colors
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

PLATFORM="gemini"

# Parse platform argument
while getopts "p:" opt; do
  case $opt in
    p)
      PLATFORM=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

platform_lower=$(echo "$PLATFORM" | tr '[:upper:]' '[:lower:]')
target_sub_dir=".gemini"
platform_display="Gemini"

if [ "$platform_lower" = "claude" ]; then
    target_sub_dir=".claude"
    platform_display="Claude Code"
elif [ "$platform_lower" = "openai" ] || [ "$platform_lower" = "chatgpt" ]; then
    target_sub_dir=".openai"
    platform_display="ChatGPT/Codex (OpenAI)"
fi

echo -e "${CYAN}================================================================================${NC}"
echo -e "${CYAN}         GG-Agentic-Harness-Foundry v1.5.0 자동 설치 (Target: $platform_display) ${NC}"
echo -e "${CYAN}================================================================================${NC}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGIN_NAME="gg-agentic-harness-foundry"
LEGACY_NAME="agentic_os_harness"

# Claude Code uses native paths without config/ subdirectory
if [ "$platform_lower" = "claude" ]; then
    TARGET_PARENT_DIR="$HOME/$target_sub_dir"
    TARGET_PLUGIN_PATH="$TARGET_PARENT_DIR/$PLUGIN_NAME"
    TARGET_LEGACY_PATH="$TARGET_PARENT_DIR/$LEGACY_NAME"
else
    # Gemini and OpenAI use config/plugins structure
    TARGET_PARENT_DIR="$HOME/$target_sub_dir/config/plugins"
    TARGET_PLUGIN_PATH="$TARGET_PARENT_DIR/$PLUGIN_NAME"
    TARGET_LEGACY_PATH="$TARGET_PARENT_DIR/$LEGACY_NAME"
fi

SOURCE_PLUGIN_PATH="$SCRIPT_DIR/gg-agentic-harness-foundry"

# 1. 기존 플러그인 유무 확인 및 사용자 안내
HAS_LEGACY=0
HAS_PLUGIN=0

if [ -d "$TARGET_LEGACY_PATH" ]; then HAS_LEGACY=1; fi
if [ -d "$TARGET_PLUGIN_PATH" ]; then HAS_PLUGIN=1; fi

if [ $HAS_LEGACY -eq 1 ] || [ $HAS_PLUGIN -eq 1 ]; then
    echo -e "${YELLOW}[경고] 이전 버전의 하네스 플러그인이 $platform_display 경로에서 감지되었습니다.${NC}"
    if [ $HAS_LEGACY -eq 1 ]; then echo -e "${YELLOW} - 감지된 구형 경로: $TARGET_LEGACY_PATH${NC}"; fi
    if [ $HAS_PLUGIN -eq 1 ]; then echo -e "${YELLOW} - 감지된 기존 경로: $TARGET_PLUGIN_PATH${NC}"; fi
    echo ""
    
    read -p "기존 버전을 제거하고 신규 버전(v1.5.0)을 새로 설치하시겠습니까? (Y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${RED}[설치 취소] 사용자가 승인하지 않아 설치를 중단합니다.${NC}"
        exit 1
    fi
    
    echo -e "${CYAN}[진행] 기존 플러그인 디렉토리를 제거합니다...${NC}"
    if [ $HAS_LEGACY -eq 1 ]; then rm -rf "$TARGET_LEGACY_PATH"; fi
    if [ $HAS_PLUGIN -eq 1 ]; then rm -rf "$TARGET_PLUGIN_PATH"; fi
fi

# 2. 신규 플러그인 설치 복사
echo -e "${CYAN}[진행] $platform_display 용 신규 플러그인 복사 중...${NC}"
mkdir -p "$TARGET_PARENT_DIR"
cp -r "$SOURCE_PLUGIN_PATH" "$TARGET_PARENT_DIR/"

# 3. EPR/REE 저장소 및 초기 설정 데이터 배치
echo -e "${CYAN}[진행] $platform_display 전역 에러 패턴 레지스트리(EPR) 및 규칙 엔진(REE) 구성...${NC}"

# Claude Code uses native paths
if [ "$platform_lower" = "claude" ]; then
    EPR_USER_PATH="$HOME/$target_sub_dir/memory"
    EPR_GLOBAL_PATH="$HOME/$target_sub_dir/memory"
    REE_RULES_PATH="$HOME/$target_sub_dir/rules"
else
    # Gemini and OpenAI use config structure
    EPR_USER_PATH="$HOME/$target_sub_dir/config/error-registry/user-level"
    EPR_GLOBAL_PATH="$HOME/$target_sub_dir/config/error-registry/global"
    REE_RULES_PATH="$HOME/$target_sub_dir/config/rules"
fi

mkdir -p "$EPR_USER_PATH"
mkdir -p "$EPR_GLOBAL_PATH"
mkdir -p "$REE_RULES_PATH"

# 시드 데이터 복사
SEED_ANTI_PATTERN="$SOURCE_PLUGIN_PATH/skills/epr/templates/global-antipatterns.md"
SEED_COMMON_MISTAKES="$SOURCE_PLUGIN_PATH/skills/epr/templates/user-level.md"
SEED_RULES="$SOURCE_PLUGIN_PATH/skills/ree/templates/rule-format.md"

if [ "$platform_lower" = "claude" ]; then
    # Claude Code uses memory/ for EPR data
    if [ -f "$SEED_ANTI_PATTERN" ]; then cp "$SEED_ANTI_PATTERN" "$EPR_GLOBAL_PATH/epr-global-antipatterns.md"; fi
    if [ -f "$SEED_COMMON_MISTAKES" ]; then cp "$SEED_COMMON_MISTAKES" "$EPR_USER_PATH/epr-user-common-mistakes.md"; fi
    if [ -f "$SEED_RULES" ]; then cp "$SEED_RULES" "$REE_RULES_PATH/ecl-global-rules.md"; fi
else
    # Gemini and OpenAI structure
    if [ -f "$SEED_ANTI_PATTERN" ]; then cp "$SEED_ANTI_PATTERN" "$EPR_GLOBAL_PATH/anti-patterns.md"; fi
    if [ -f "$SEED_COMMON_MISTAKES" ]; then cp "$SEED_COMMON_MISTAKES" "$EPR_USER_PATH/common-mistakes.md"; fi
    if [ -f "$SEED_RULES" ]; then cp "$SEED_RULES" "$REE_RULES_PATH/global-rules.md"; fi
fi

echo -e "${GREEN}================================================================================${NC}"
echo -e "${GREEN} 🎉 GG-Agentic-Harness-Foundry v1.5.0 ($platform_display) 설치 완료!${NC}"
echo -e "${GREEN}================================================================================${NC}"
echo ""

# 4. 검증 및 작동 확인
echo -e "${CYAN}[진행] 설치 상태 및 기능 검증 실행...${NC}"
INFO_SCRIPT="$TARGET_PLUGIN_PATH/foundry_info.py"
if [ -f "$INFO_SCRIPT" ]; then
    python3 "$INFO_SCRIPT"
else
    echo -e "${RED}[오류] foundry_info.py 스크립트를 찾을 수 없습니다.${NC}"
fi
