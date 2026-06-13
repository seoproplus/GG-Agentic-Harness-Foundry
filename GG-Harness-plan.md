# GG-Agentic-Harness-Foundry 코어 아키텍처 및 구현 계획서 (v1.5.0)

## 🎯 목적

본 계획서는 단순한 에이전트 템플릿 생성을 넘어, 자율 수정, 상태 영구 보존, 에러 자가 치유 및 무결성 검증 능력을 갖춘 **개인화된 Agentic OS 파운드리**의 작동 원리와 4-Layer/8대 핵심 시스템 아키텍처를 정의합니다.
실행은 타겟 AI 플랫폼(Gemini, Claude, OpenAI) 환경에 맞춰 동적으로 라우팅 및 배포되며, 메인 오케스트레이터가 자율 루프(FGM)를 통해 작업의 시작과 끝을 통제합니다.

---

## 📐 설계 원칙

1. **Multi-Platform Portability (다중 플랫폼 호환성)**: `.gemini`, `.claude`, `.openai` 등 플랫폼별 고유의 네임스페이스와 플러그인 구조에 맞춰 시스템 로직을 유연하게 배포(`install.ps1` 및 Scaffolder)합니다.
2. **Layered Extension (4-Layer 확장성)**: UI, Runtime, Governance, Team Architecture의 4계층으로 분리하여 시스템 결합도를 낮춥니다.
3. **File-First Persistence (파일 우선 지속성)**: 세션이나 메모리에 의존하지 않습니다. 모든 체크포인트, 오류 패턴, 앵커 상태는 파일(`.md`, `.json`)로 영구 저장됩니다.
4. **Zero-Drift Policy (무결점 헬스체크)**: 코드베이스 명세 갱신 시 발생하는 누락이나 모순을 방지하기 위해 다중 패스 매트릭스(Multi-Pass Matrix) 방식의 기계적 교차 검증을 강제합니다.
5. **Agent-First CLI**: 사용자가 아닌 에이전트 스스로 런타임 제어를 위해 호출할 수 있는 전용 커맨드(`/health-check`, `/attention`, `/goal`) 생태계를 구축합니다.

---

## 🏗️ 핵심 구조 (4-Layer & 8대 시스템)

### Layer 4: User Interface
- **Intent Engine (의도 분류 엔진)**: 사용자의 모호한 요청을 구조화(`Intent Object`)하고 7개 직업군 아키타입을 기반으로 시스템 활성화 매트릭스를 제안합니다.
- **Harness Scaffolder (지능형 스캐폴더)**: `harness-100` 템플릿과 연동하여 대상 플랫폼에 최적화된 에이전트 폴더 트리를 임시 공간에 배포하고, `deploy-harness.ps1` 스크립트 실행을 통해 로컬/전역 무비용 배포를 완수합니다.

### Layer 3: Operational Runtime
- **ICIP (Ishikawa Context Isolation Protocol)**: `00_purpose_anchor.md`를 불변 앵커로 삼아 목적 드리프트를 방지하고 서브 에이전트의 결과를 게이트 평가합니다.
- **CRP (Checkpoint & Resume Protocol)**: `checkpoint.json`에 상태를 기록하고 로컬 `.git`에 스냅샷을 남겨 완벽한 중단/재개를 보장합니다.
- **TCM (Tiered Context Management)**: 토큰 임계치 도달 시 컨텍스트를 Soft/Hard Compaction하여 주의력을 유지합니다.
- **FGM (Foundry Goal Mode)**: `/goal` 커맨드 시 `goal_status.md` 모니터링판을 띄우고 성공 기준 100% 달성 시까지 자율 자가 수정(Self-Correction) 루프를 구동합니다.

### Layer 2: Governance & Learning
- **EPR (Error Pattern Registry)**: 작업 중 발생한 에러를 수집하고, 다음 작업 시 Pre-flight 경고로 주입해 동일 실수를 반복하지 않게 합니다. (`.error-registry/`)
- **REE (Rule Enforcement Engine)**: 마크다운 룰북(`R-*.md`)을 로드하여 산출물 규칙 준수 여부를 강제로 사후 검증(Post-flight Audit)합니다.

### Layer 1: Team Architecture
- **revfactory/harness 기반 패턴**: Pipeline, Fan-out/Fan-in, Expert Pool, Producer-Reviewer 등 6대 협업 패턴 기반의 템플릿 구조를 제공합니다.

---

## 🔄 운영 워크플로우

### 1. 작업 스캐폴딩 (Initialization)
1. Intent Engine이 의도와 아키타입(예: Researcher, Developer)을 분석.
2. Harness Scaffolder가 임시 경로(`_workspace/scaffolded_harness/...`)에 소스를 생성하고, `deploy-harness.ps1`을 통해 다중 플랫폼 경로(`.gemini` 등)로 안전한 배포 완수.

### 2. 자율 루프 실행 (Execution via FGM)
1. 오케스트레이터가 `00_purpose_anchor.md`와 룰북(`R-*.md`)을 로드.
2. 에이전트는 산출물 생성 후 ICIP 게이트 평가 및 REE 규칙 검증을 거침.
3. 조건 미달 또는 규정 위반 시, EPR 반박 논리(Rebuttal)가 주입된 채로 재실행.

### 3. 상태 저장 및 메모리 관리 (Persistence)
1. 단계 완료 시 **CRP**가 `checkpoint.json` 및 `git commit` 수행.
2. 대화가 길어지면 **TCM**이 개입하여 이전 턴을 요약(Compaction)하고 메인 컨텍스트를 비움.

### 4. 무결성 감사 (Zero-Drift Maintenance)
1. 사용자가 주기적으로 `/health-check` 커맨드를 호출.
2. 에이전트가 단일 패스 통독을 멈추고 `health_check_matrix.md` 아티팩트를 렌더링하며 시스템 간의 버전 및 JSON 스키마 불일치를 100% 색출함.

---

## 📁 파일 구조 도식 (플랫폼 가변 모델)

```text
target-workspace/
  ├── .gemini/ (또는 .claude/, .openai/)
  │     ├── GEMINI.md               # 플랫폼 명세 메타데이터
  │     ├── agents/
  │     │     ├── agent-1.md        # Governance 규칙이 주입된 에이전트 프롬프트
  │     │     └── agent-2.md
  │     └── skills/
  │           └── main-orchestrator/
  │                 └── SKILL.md    # 6대 운영 시스템이 믹스인된 메인 지휘소
  ├── .git/                         # CRP 자동 스냅샷 로컬 저장소
  └── _workspace/                   # 런타임 데이터 영구 저장소
        ├── 00_purpose_anchor.md    # ICIP: 목적 불변 앵커
        ├── R-*.md                  # REE: 검증 룰북
        ├── checkpoint.json         # CRP: 진행 상태
        ├── goal_status.md          # FGM: 자율 실행 모니터링판
        ├── artifacts/              # 산출물
        ├── .error-registry/        # EPR: 오류 아카이브
        └── scratch/
```