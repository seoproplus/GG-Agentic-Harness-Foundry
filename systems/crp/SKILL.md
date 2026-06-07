---
name: crp
description: "Checkpoint & Resume Protocol — 작업 중간 기록 및 재개 시스템. 모든 작업의 Phase/Step 진행 상태를 checkpoint.json에 기록하고, 작업 중단 시 마지막 체크포인트부터 자동 재개한다. '작업 이어서', '재개', '이전 작업 계속', '중단된 작업' 등의 키워드뿐 아니라, 하네스가 multi-phase 작업을 수행하는 모든 상황에서 반드시 이 스킬을 사용할 것."
---

# CRP — Checkpoint & Resume Protocol

모든 작업의 진행 상태를 기록하여, 중단 후에도 마지막 체크포인트부터 정확히 재개할 수 있게 하는 프로토콜.

**핵심 원칙:**
1. 모든 Phase 완료 시 **자동으로** 체크포인트를 기록한다 (수동 호출 불필요)
2. 결정의 **이유(why)**를 함께 기록한다 — 재개 시 맥락 복원의 핵심
3. 체크포인트는 **파일 기반**이다 — 세션/메모리에 의존하지 않는다
4. 재개 시 목적 앵커(ICIP)를 먼저 로드하여 방향을 재설정한다

## 체크포인트 구조

### checkpoint.json 스키마

모든 하네스 작업은 `_workspace/checkpoint.json`을 유지한다:

```json
{
  "schema_version": "1.0",
  "session_id": "{unique-id}",
  "harness_name": "{하네스 이름}",
  "purpose_anchor": "_workspace/00_purpose_anchor.md",
  
  "status": "IN_PROGRESS | COMPLETED | PAUSED | FAILED",
  "current_phase": 3,
  "current_step": 2,
  "total_phases": 5,
  
  "phases": [
    {
      "phase": 1,
      "name": "도메인 분석",
      "status": "COMPLETED",
      "started_at": "2026-06-07T14:20:00+09:00",
      "completed_at": "2026-06-07T14:25:00+09:00",
      "outputs": ["_workspace/01_domain_analysis.md"],
      "summary": "ADHD 청소년 연구 도메인으로 확정, 팬아웃 패턴 선택"
    },
    {
      "phase": 2,
      "name": "팀 구성",
      "status": "COMPLETED",
      "started_at": "2026-06-07T14:25:00+09:00",
      "completed_at": "2026-06-07T14:30:00+09:00",
      "outputs": ["_workspace/02_team_config.md"],
      "summary": "의학조사관, 데이터분석가, 정책기획자, 리뷰어 4인 팀 구성"
    },
    {
      "phase": 3,
      "name": "병렬 조사",
      "status": "IN_PROGRESS",
      "started_at": "2026-06-07T14:30:00+09:00",
      "completed_at": null,
      "agents": {
        "completed": ["researcher", "analyst"],
        "in_progress": ["policy-planner"],
        "pending": []
      },
      "outputs": [
        "_workspace/03_researcher_findings.md",
        "_workspace/03_analyst_report.md"
      ],
      "summary": "2/3 에이전트 완료. 정책기획자 진행 중."
    }
  ],
  
  "decision_log": [
    {
      "timestamp": "2026-06-07T14:22:00+09:00",
      "phase": 1,
      "decision": "팬아웃/팬인 패턴 선택",
      "reason": "3개 독립 조사 영역(의학/데이터/정책)이 존재하므로 병렬 처리 최적",
      "alternatives_considered": ["파이프라인 — 순차 의존이 아니므로 부적합"]
    },
    {
      "timestamp": "2026-06-07T14:28:00+09:00",
      "phase": 2,
      "decision": "의학조사관 에이전트 추가",
      "reason": "ADHD는 의학 전문 지식이 필요하며, 범용 연구원으로는 논문 평가 품질 부족"
    }
  ],
  
  "error_log": [],
  
  "goal_mode": {
    "is_active": true,
    "current_iteration": 2,
    "max_iterations": 10,
    "status_file": "_workspace/goal_status.md",
    "success_criteria": [
      {"id": "SC-1", "criteria": "REE MUST rules passed (100%)", "satisfied": true},
      {"id": "SC-2", "criteria": "ICIP purpose anchor criteria satisfied", "satisfied": false}
    ],
    "last_failure_reason": "REE rule R-001 (TL;DR requirement) violated in researcher output"
  },
  
  "metadata": {
    "created_at": "2026-06-07T14:20:00+09:00",
    "last_updated": "2026-06-07T14:35:00+09:00",
    "total_elapsed_minutes": 15,
    "compaction_count": 0
  }
}
```

## FGM (Foundry Goal Mode) 연동 규칙

`/goal` 커맨드로 구동되는 FGM 모드에서는 `checkpoint.json` 내에 `"goal_mode"` 객체가 활성화되며, 다음 규칙에 따라 제어됩니다:

1. **상태 동기화**: 매 이터레이션이 끝날 때마다 `current_iteration`을 증가시키고 `goal_status.md` 마크다운 상태판과 동기화하여 파일에 덮어씁니다.
2. **에러 피드백 기록**: 에이전트 감사 결과 실패 요인이 발생하면 `last_failure_reason`에 기록하고, 해당 내용을 다음 이터레이션 에이전트 프롬프트 피드백에 주입합니다.
3. **루프 임계치 가드**: `current_iteration`이 `max_iterations`를 초과하면 status를 `FAILED`로 기록하고, `goal_status.md`에 최종 차단 원인을 표시한 뒤 자율 루프를 안전 정지합니다.

## 자동 체크포인트 규칙

### 언제 체크포인트를 기록하는가

| 이벤트 | 체크포인트 동작 |
|-------|---------------|
| Phase 시작 | status를 `IN_PROGRESS`로, 시작 시각 기록 |
| Phase 완료 | status를 `COMPLETED`로, 완료 시각 + summary 기록 |
| 에이전트 완료 | agents 내 completed 목록에 추가 |
| 중요한 결정 | decision_log에 추가 (decision + reason + alternatives) |
| 오류 발생 | error_log에 추가, status를 `FAILED`로 변경 |
| 사용자 중단 | status를 `PAUSED`로 변경 |
| Compaction 발생 | metadata.compaction_count 증가 |

### 체크포인트 갱신 방법
- `checkpoint.json`을 **전체 덮어쓰기**(overwrite)한다 — 부분 수정 시 JSON 손상 위험
- 갱신 전 이전 버전을 `checkpoint.json.bak`으로 백업 (1세대만 보존)
- **자동 Git 스냅샷(Snapshot) 연동**: `checkpoint.json` 갱신 직후, 워크스페이스 로컬 저장소에 백그라운드 커밋(`git add .` 및 `git commit -m "CRP Checkpoint: Phase {N} - {Status}"`)을 강제 수행한다. (저장소가 없다면 `git init` 자동 수행)

## 재개 프로토콜

### 재개 시 동작 순서

1. **checkpoint.json 로드**: `_workspace/checkpoint.json` 존재 확인
2. **목적 앵커 재로드**: `purpose_anchor` 경로에서 앵커 파일 로드
3. **상태 파악**: 
   - `status`가 `PAUSED` 또는 `FAILED`인 경우 → 마지막 진행 Phase/Step 식별
   - `status`가 `IN_PROGRESS`인 경우 → 비정상 중단 (크래시). agents에서 completed/in_progress 확인
4. **decision_log 요약**: 지금까지의 결정 이유를 Main 컨텍스트에 주입
5. **재개 지점 결정**:
   - 완료된 Phase의 산출물은 재사용 (재실행 금지)
   - `IN_PROGRESS` Phase의 미완료 에이전트만 재호출
   - `FAILED` Phase는 error_log를 참조하여 수정 후 재시도
6. **사용자 확인**: 재개 계획을 요약하여 사용자에게 보고하고 승인받기

### 재개 시 프롬프트 템플릿

```
이전 세션에서 중단된 작업을 재개합니다.

**목적**: {purpose_anchor에서 핵심 목적}
**진행 상태**: Phase {N}/{total} — {Phase 이름}
**완료된 작업**: {completed agents/phases 목록}
**미완성 작업**: {pending/in_progress 목록}

**주요 결정 이력**:
{decision_log를 시간순으로 나열}

**재개 계획**:
- {미완성 에이전트}를 재호출합니다
- 이전 산출물 {파일 경로들}을 참조합니다
- Phase {N} 완료 후 게이트 평가를 진행합니다
```

## Decision Log 작성 가이드

Decision Log는 재개 시 **"왜 여기까지 왔는지"**를 복원하는 핵심 메커니즘이다.

### 기록해야 하는 결정
1. 아키텍처 패턴 선택 (왜 이 패턴인가)
2. 에이전트 추가/제거 (왜 이 에이전트가 필요/불필요한가)
3. 분기 설계 변경 (왜 분기를 추가/삭제했는가)
4. 사용자 피드백 반영 (사용자가 무엇을 요청하여 방향이 바뀌었는가)
5. 오류로 인한 전략 변경 (무엇이 실패하여 다른 접근을 시도했는가)

### 기록하지 않는 것
- 루틴 진행 사항 (Phase 3 시작 등 → Phase 배열에 이미 기록)
- 기술적 디테일 (코드 수준의 변경)
- 에이전트 내부 로직 (에이전트의 산출물에 기록)

## ICIP 연동

- 재개 시 반드시 ICIP의 목적 앵커를 먼저 로드한다
- 체크포인트의 `purpose_anchor` 필드가 앵커 파일 경로를 보장한다
- 재개 후 새로운 분기가 필요하면 ICIP의 Branch Map을 갱신한다

## TCM 연동

- Compaction 발생 시 checkpoint.json의 `compaction_count`를 증가시킨다
- Compaction으로 인해 이전 Phase의 상세가 사라져도, checkpoint.json의 summary와 decision_log가 맥락을 보존한다
- 이것이 CRP의 핵심 가치 — **Compaction에도 살아남는 메타데이터**

## 에러 핸들링 및 데이터 유실 복구
- checkpoint.json이 손상된 경우: `.bak` 파일에서 복원 시도
- .bak도 없는 경우: `_workspace/` 내 산출물 파일들의 존재 여부로 진행 상태 추론
- **Git Snapshot 기반 롤백 (치명적 데이터 유실 시)**: 파일이 유실되거나 상태가 심각하게 오염된 경우, 사용자에게 `git log`를 통한 상태 확인 및 `git reset --hard <commit-hash>` 기반의 롤백을 제안하고, 이전 체크포인트 상태로 원복한 뒤 재개한다.
- 산출물도 없는 경우: 사용자에게 "이전 작업 기록을 찾을 수 없습니다" 보고, 신규 시작 제안
