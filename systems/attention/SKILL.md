---
name: attention
description: "/attention 명령어를 처리하는 시스템 스킬. 사용자가 /attention을 입력하면 현재 워크스페이스의 목표(00_purpose_anchor)와 상태를 브리핑하고 다음 지시를 대기한다."
---

# Attention Command System

사용자가 대화 중에 `/attention` 명령어를 입력할 때 발동되는 컨텍스트 동기화 스킬.

## 워크플로우

1. **실행 중단**: 현재 진행 중인 코드 수정이나 파일 탐색을 일시 정지한다.
2. **컨텍스트 스캔**:
   - `_workspace/00_purpose_anchor.md` (Primary Goal 확인)
   - `_workspace/checkpoint.json` (진행 중인 Phase/Step 확인)
   - `_workspace/goal_status.md` 및 최근 변경 사항 파악
3. **상태 브리핑**: 스캔한 내용을 바탕으로 현재 코드베이스의 상태를 간략히 요약하여 출력한다.
4. **대기 모드 진입**: "현재 코드베이스 상태 파악을 완료했습니다. 다음 지시를 내려주세요."라고 명시적으로 응답하며 사용자의 새로운 Intent를 기다린다.

## REE 연동

이 스킬은 `_workspace/R-007_attention_command.md` 규칙과 밀접하게 연동된다. `R-007`은 에이전트가 이 스킬의 동작을 강제적으로 따르도록 하는 검증 규칙(Must-rule)으로 작용한다.

## 시스템 구성 방식
- **의도 감지**: `intent-engine`이 `/attention` 입력을 인식하면, 다른 작업을 유보하고 가장 먼저 이 `attention` 스킬을 호출한다.
- **TCM(Tiered Context Management) 연계**: 스킬 호출 직후, 필요 시 이전 대화의 요약 및 컨텍스트 리셋을 수행하여 완전한 "초기화 및 준비" 상태를 보장한다.
