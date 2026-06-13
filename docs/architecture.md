# GG-Agentic-Harness-Foundry — Architecture Document

## 개요

**GG-Agentic-Harness-Foundry**는 [revfactory/harness](https://github.com/revfactory/harness)의 L3 Meta-Factory(팀 아키텍처 팩토리) 위에 **4-Layer 운영 아키텍처(8대 핵심 시스템)**를 구축하여, **개인 Agentic OS**를 구현하고 고도화하는 프레임워크 파운드리입니다.

이 파운드리는 Gemini의 지속적인 모델 업데이트 및 API 플랫폼 사양 변경에 민첩하게 조응하며, 자체 버전 관리(`foundry-info` 스킬 및 `foundry_info.py` CLI 도구)와 **8대 운영 시스템** 및 FGM 자율 실행 모드의 최적 정렬 상태를 보장합니다.

---

## 4-Layer Architecture

```
┌─────────────────────────────────────────────────────────┐
│              Layer 4: User Interface                     │
│                                                         │
│  ┌─────────────────────────┐   ┌─────────────────────┐  │
│  │      intent-engine      │   │    foundry-info     │  │
│  │  · 자연어 → Intent 객체  │   │  · v1.5.0 관리      │  │
│  │  · 직업군 아키타입 매핑 │   │  · Gemini 업데이트  │  │
│  │  · 사용자 프로파일 참조  │   │    호환 대응 안내   │  │
│  │  · 시스템 활성화 추천   │   │                     │  │
│  └─────────────────────────┘   └─────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │                harness-scaffolder                 │  │
│  │   · harness-100 베스트 프랙티스 템플릿 연동       │  │
│  │   · 사용자 지정 프로젝트 루트 및 하위 구조 매핑     │  │
│  │   · 배포 전 계획서 출력 및 유저 선 승인제 (v1.5.0)   │  │
│  │   · 네이티브 도구(write_to_file) 기반 자동 배포   │  │
│  └───────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│            Layer 3: Operational Runtime                   │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   ICIP    │  │   CRP    │  │   TCM    │  │   FGM    │   │
│  │  Context  │  │  Check-  │  │  Context │  │  Goal    │   │
│  │ Isolation │  │  point   │  │  Manage  │  │  Loop    │   │
│  │ · 앵커    │  │ · check  │  │ · Tier1  │  │ · 자율   │   │
│  │ · 분기맵  │  │   point  │  │ · Tier2  │  │   루프   │   │
│  │ · 게이트  │  │ · 결정   │  │ · Tier3  │  │ · 상태판 │   │
│  │   평가    │  │   로그   │  │ · 압축   │  │ · 가드   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
├─────────────────────────────────────────────────────────┤
│           Layer 2: Governance & Learning                 │
│                                                         │
│  ┌────────────────────┐  ┌──────────────────────────┐  │
│  │        EPR          │  │          REE             │  │
│  │  Error Pattern      │  │  Rule Enforcement        │  │
│  │  Registry           │  │  Engine                  │  │
│  │                    │  │                          │  │
│  │ · 사용자/프로젝트/  │  │ · 구조화된 규칙 마커     │  │
│  │   범용 3계층        │  │ · Pre-flight Check      │  │
│  │ · 패턴 매칭         │  │ · Post-flight Audit     │  │
│  │ · 사전 경고         │  │ · 위반 → EPR 연동       │  │
│  │ · 규칙 승격         │  │ · MUST/SHOULD/MAY       │  │
│  └────────────────────┘  └──────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│       Layer 1: Team Architecture (revfactory/harness)    │
│                                                         │
│  · 6 Architectural Patterns:                            │
│    Pipeline | Fan-out/Fan-in | Expert Pool              │
│    Producer-Reviewer | Supervisor | Hierarchical        │
│  · Agent Definition (.{platform}/agents/)               │
│  · Skill Generation (.{platform}/skills/)               │
│  · Orchestrator Templates                               │
└─────────────────────────────────────────────────────────┘
```

## 시스템 간 연동 맵

```
                    intent-engine
                          │
                    ┌────┴────┐
                    ▼         ▼
               harness-   시스템 활성화
              scaffolder   매트릭스
                    │
        ┌───────┬──┴───┬───────┐
        ▼       ▼      ▼       ▼
      ICIP    CRP    EPR     REE
        │       │      │       │
        │       │      └──┬────┘
        │       │         │
        │       │    Pre/Post-flight
        │       │    (사전/사후 검증)
        │       │
        └──┬────┘
           │
          TCM
    (모든 시스템의
     컨텍스트를 관리)
```

### 구체적 연동 관계

| 소스 → 타겟 | 연동 내용 |
|------------|----------|
| **intent-engine → harness-scaffolder** | 구조화된 Intent Object와 사용자 지정 프로젝트 루트 경로를 스캐폴더에 전달 |
| **harness-scaffolder → User** | 파일 생성 전 "스캐폴딩 계획 보고서"를 띄우고 명시적 승인 확인 (v1.5.0) |
| **harness-scaffolder → L2/L3 Layers** | 에이전트에 EPR/REE 사전 경고 주입, 오케스트레이터에 ICIP/CRP/TCM/REE 감사/FGM 루프 주입 |
| **intent-engine → ICIP/CRP/TCM/EPR/REE** | 시스템 활성화 결정 |
| **ICIP → CRP** | 목적 앵커 경로를 checkpoint에 등록 |
| **ICIP → TCM** | 목적 앵커를 Tier 1 불변 영역에 배치 |
| **CRP → TCM** | Compaction 발생 시 compaction_count 증가 |
| **TCM → CRP** | Compaction 후에도 checkpoint.json은 보존 |
| **EPR → REE** | 안정 패턴(3회+) → 규칙 승격 |
| **REE → EPR** | 규칙 위반 → 오류 패턴 등록 |
| **EPR → Pre-flight** | 오류 패턴 사전 경고 |
| **REE → Pre-flight** | MUST 규칙 체크리스트 로드 |
| **REE → Post-flight** | 산출물 규칙 준수 검증 |

## 파일 시스템 구조

### 프로젝트 실행 시 생성되는 구조

```
{project}/
├── _workspace/                      # 작업 디렉토리
│   ├── 00_purpose_anchor.md         # ICIP: 목적 앵커 (불변)
│   ├── 01_branch_map.md             # ICIP: 이시카와 분기 맵
│   ├── R-005_foundry_ui_rule.md     # REE: 글로벌/프로젝트 레벨 강제 규칙 파일 1
│   ├── R-006_ddfg_rule.md           # REE: 글로벌/프로젝트 레벨 강제 규칙 파일 2
│   ├── R-007_attention_command.md   # REE: /attention 커맨드 규칙
│   ├── R-008_health_check_command.md # REE: /health-check 커맨드 규칙
│   ├── R-009_schema_sync_rule.md    # REE: 명세 갱신 시 JSON 스키마 동기화 MUST 규칙
│   ├── checkpoint.json              # CRP: 체크포인트 메타데이터 (FGM 상태 내장)
│   ├── checkpoint.json.bak          # CRP: 백업
│   ├── goal_status.md               # FGM: 실시간 자율 실행 진행 상태 마크다운
│   ├── goal_status.json             # FGM: 상태 메타데이터 JSON (CRP와 동기화)
│   ├── 02_agent_A_result.md         # 에이전트 A 산출물
│   ├── 02_agent_B_result.md         # 에이전트 B 산출물
│   ├── 03_integrated_report.md      # 통합 산출물
│   ├── compliance_report.md         # REE: Post-flight 감사 보고서
│   ├── archive/                     # TCM: Compaction된 원본
│   │   ├── phase_1_full.md
│   │   └── phase_2_full.md
│   └── .error-registry/            # EPR: 프로젝트 레벨
│       ├── known-issues.md
│       └── resolved-patterns.md
```

### 전역 설정 구조

```
.gemini/config/
├── error-registry/                  # EPR: 전역
│   ├── user-level/
│   │   ├── common-mistakes.md
│   │   └── preferences.md
│   └── global/
│       └── anti-patterns.md
├── rules/                           # REE: 전역
│   ├── global-rules.md
│   └── user-rules.md
```

## 설계 원칙 (Design Principles)

| # | 원칙 | 설명 |
|---|------|------|
| 1 | **Layered Extension** | harness를 변경하지 않고 위에 쌓는다 |
| 2 | **Independent Deployability** | 각 시스템은 독립 배포·비활성화 가능 |
| 3 | **File-First Persistence** | 모든 상태는 파일 기반 (세션/메모리 비의존) |
| 4 | **Purpose Anchor Immutability** | 목적 앵커는 생성 후 수정 불가 |
| 5 | **Rules Are Executable** | 규칙은 적는 것이 아니라 검증하는 것 |
| 6 | **Mandatory Compaction** | 임계치 도달 시 선택 아닌 강제 압축 |
| 7 | **Error as Learning Asset** | 오류는 학습 자산으로 축적·재활용 |

## AI 리더 인사이트 반영

| 인사이트 | 출처 | 반영 시스템 |
|---------|------|-----------|
| "에이전트는 과거 행동의 일관된 감각이 없어서 실패한다" | Andrej Karpathy | ICIP (목적 앵커), CRP (결정 로그), TCM (앵커 보존) |
| "핵심 언락은 개인 맥락을 에이전트에 주입하는 것" | Garry Tan | Intent Engine (프로파일), EPR (개인 오류 패턴) |
| "Context is a first-class engineering asset" | 2026 업계 합의 | TCM 전체 설계 |
| "Software 3.0 — 에이전트 엔지니어링" | Karpathy | 전체 4-Layer 아키텍처 |
