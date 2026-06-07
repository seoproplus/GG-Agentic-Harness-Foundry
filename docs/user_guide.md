# 📖 GG-Agentic-Harness-Foundry — 종합 사용자 가이드 (v1.5.0)

> **대상**: 개인 및 직장 PC 환경에서 고도화된 Agentic OS를 가동하려는 파워 유저 및 AI 엔지니어
> **작성일**: 2026-06-07
> **버전**: v1.5.0 (멀티 플랫폼 확장 및 가변 스캐폴더 완비)

---

## 1. 개요 및 핵심 철학

**GG-Agentic-Harness-Foundry**는 오픈소스 에이전트 팀 구성 도구인 `revfactory/harness` 위에 **6대 운영 레이어** 및 **자율 실행 루프(FGM)**를 탑재하여 개인의 일상적·전문적 작업을 보좌하는 **개인 Agentic OS** 파운드리입니다.

v1.5.0 부터는 **Gemini**뿐만 아니라 **Claude Code**, **ChatGPT/Codex (OpenAI)** 등 다양한 AI 플랫폼으로 확장 설치 및 스캐폴딩할 수 있도록 멀티 플랫폼 지원을 완벽히 강화했습니다.

### 🌟 핵심 설계 철학 (Design Principles)
1. **Multi-Platform Portability (멀티 플랫폼 이식성)**: 동일한 거버넌스 룰과 스캐폴딩 엔진을 타겟 AI 플랫폼(Gemini, Claude, OpenAI)의 규격으로 자동 전환 배포합니다.
2. **Layered Extension (레이어 확장성)**: 기존 하네스 설계 방식을 깨뜨리지 않고, 그 위에 거버넌스 및 실행 제어 레이어를 얹는 방식으로 호환성을 극대화합니다.
3. **File-First Persistence (파일 우선 지속성)**: 모든 체크포인트, 오류 패턴, 규칙 데이터, 상태판을 마크다운 및 JSON 파일로 보존하여 컨텍스트 손실이나 세션 끊김 현상을 전면 회피합니다.
4. **Scaffolding Feedback Loop (스캐폴딩 개선 환류)**: `R-004` 규칙에 의거, 스캐폴딩 전 이전 구동 시 발견한 보완점(`harness-100-improvements.md`)을 로드하여 자동 갱신 적용합니다.

---

## 2. 4-Layer 아키텍처 및 8대 구성 요소

파운드리는 다음과 같은 구조로 긴밀하게 연동되어 구동됩니다.

```
┌─────────────────────────────────────────────────────────┐
│              Layer 4: User Interface                     │
│  · Intent Engine: 자연어 의도 해독 및 아키타입 추천     │
│  · Harness Scaffolder: harness-100 연동, 플랫폼 가변 배포│
│  · Foundry Info: CLI 호환성 및 플랫폼별 버전 정보 (v1.5.0)│
├─────────────────────────────────────────────────────────┤
│            Layer 3: Operational Runtime                   │
│  · ICIP: 목적 앵커 고정 및 서브에이전트 게이트 필터링     │
│  · CRP: checkpoint.json 기반 상태 영구 저장 및 자동 재개  │
│  · TCM: 30%/50% 임계치 기반 지능형 컨텍스트 압축        │
│  · FGM: 무인 자율 구동 /goal 수정 루프 및 실시간 상태판   │
├─────────────────────────────────────────────────────────┤
│           Layer 2: Governance & Learning                 │
│  · EPR: 사용자/프로젝트/글로벌 오류 패턴 기록 및 사전 경고 │
│  · REE: MUST/SHOULD 마크다운 규칙 파싱 및 사후 감사(Audit) │
├─────────────────────────────────────────────────────────┤
│       Layer 1: Team Architecture (Base)                 │
│  · Pipeline, Expert Pool 등 6대 팀 설계 패턴 및 에이전트  │
└─────────────────────────────────────────────────────────┘
```

> *** 시스템 축약어 안내**
> - **ICIP**: Ishikawa Context Isolation Protocol (이시카와 컨텍스트 격리 프로토콜)
> - **CRP**: Checkpoint & Resume Protocol (체크포인트 및 재개 프로토콜)
> - **TCM**: Tiered Context Management (계층적 컨텍스트 관리)
> - **FGM**: Foundry Goal Mode (목표 주도형 자율 실행 모드)
> - **EPR**: Error Pattern Registry (오류 패턴 레지스트리)
> - **REE**: Rule Enforcement Engine (규칙 강제 준수 엔진)

---

## 3. 플랫폼별 설치 및 초기화 (원클릭 자동)

사용하려는 타겟 AI 플랫폼 환경에 맞춰 한 줄의 커맨드로 구버전을 청소하고 v1.5.0 버전을 클린 이식할 수 있습니다.

### 3-1. 플랫폼별 설치 명령어

**Windows (PowerShell)**
```powershell
# 1. Gemini 플랫폼 환경에 설치 (기본값)
powershell -ExecutionPolicy Bypass -File .\deploy\install.ps1 -Platform gemini

# 2. Claude Code 환경에 설치
powershell -ExecutionPolicy Bypass -File .\deploy\install.ps1 -Platform claude

# 3. ChatGPT / Codex (OpenAI) 환경에 설치
powershell -ExecutionPolicy Bypass -File .\deploy\install.ps1 -Platform openai
```

**macOS / Linux (Bash)**
```bash
# 실행 권한 부여
chmod +x ./deploy/install.sh

# 1. Gemini 플랫폼 환경에 설치 (기본값)
./deploy/install.sh -p gemini

# 2. Claude Code 환경에 설치
./deploy/install.sh -p claude

# 3. ChatGPT / Codex (OpenAI) 환경에 설치
./deploy/install.sh -p openai
```

### 3-2. 플랫폼별 경로 매핑 사양

선택한 플랫폼 변수에 따라 스크립트가 다음 전역 경로에 플러그인과 설정 데이터(EPR/REE 시드 템플릿)를 자동으로 분기 구성합니다:

#### Claude Code 네이티브 경로 구조 (v1.5.0+)

Claude Code는 네이티브 경로 구조를 사용하여 다른 플랫폼과 차별화됩니다:

| 구성 요소 | 경로 | 설명 |
| :--- | :--- | :--- |
| **플러그인/스킬** | `~/.claude/gg-agentic-harness-foundry/` | 모든 스킬 및 에이전트 정의 |
| **규칙 (Rules)** | `~/.claude/rules/` | REE 규칙 엔진용 글로벌 규칙 |
| **메모리 (Memory)** | `~/.claude/memory/` | EPR 에러 패턴 레지스트리 |
| **프로젝트 메모리** | `~/.claude/projects/{project}/memory/` | 프로젝트별 EPR 데이터 |
| **설정** | `~/.claude/settings.json` | Claude Code 글로벌 설정 |

> **참고**: Claude Code는 `config/` 하위 디렉토리를 사용하지 않고 네이티브 경로(`rules/`, `memory/`, `skills/`)를 직접 사용합니다.

| 대상 플랫폼 | 전역 설정 및 규칙 폴더 경로 | 플랫폼 롤 플러그인 설치 경로 |
| :--- | :--- | :--- |
| **Gemini** | `~/.gemini/config/` | `~/.gemini/config/plugins/gg-agentic-harness-foundry/` |
| **Claude Code** | `~/.claude/` (native) | `~/.claude/gg-agentic-harness-foundry/` |
| **OpenAI / ChatGPT** | `~/.openai/config/` | `~/.openai/config/plugins/gg-agentic-harness-foundry/` |

---

## 4. 30초 Onboarding 예제 (첫 번째 하네스 구동)

설치가 성공적으로 끝났다면, 첫 번째 하네스 스캐폴딩과 실행 과정을 플랫폼별로 체험해봅니다.

**1단계: 자연어 요청으로 하네스 설계 및 승인 요청**
에이전트에게 플랫폼 요구사항을 포함한 설계를 지시합니다:
```
하네스 구성해줘: C:\Projects\MyScrapApp 경로에 웹사이트 링크 추출을 수행하는 2인 에이전트 팀 개발 (Claude Code용으로 구성해줘)
```

**2단계: 스캐폴딩 계획서 승인**
- 에이전트가 `harness-100` 및 `EPR/REE`를 참조하여 계획서를 수립하고 사용자의 승인을 요청합니다.
- `Y` (승인)를 입력하면 백그라운드에서 즉시 스캐폴딩이 진행됩니다.

**3단계: 자동화 스캐폴딩 구동**
- 승인 즉시 뼈대와 규칙 파일이 자동 생성됩니다.

---

## 5. 핵심 시스템 가동 및 운영 (FGM & CRP)

### 5-1. Foundry Info (버전 및 정보 확인)
설치된 Foundry의 버전과 CLI 호환성을 확인합니다.

* **텍스트 UI 출력**:
  ```powershell
  python {설치경로}\gg-agentic-harness-foundry\foundry_info.py
  ```
* **버전 정보만 출력** (스크립트 확인용):
  ```powershell
  python {설치경로}\gg-agentic-harness-foundry\foundry_info.py --version
  ```
* **구조화된 JSON 데이터 출력** (에이전트 연동 및 자동화 파이프라인용):
  ```powershell
  python {설치경로}\gg-agentic-harness-foundry\foundry_info.py --json
  ```

### 5-2. FGM (Foundry Goal Mode) — `/goal` 커맨드
장시간(예: 오버나이트) 무인 자율 구동하면서 최종 목표를 달성할 때까지 자가 수정을 거쳐 결과를 도출하는 특화 모드입니다.

* **사용법**: 자연어 지시 사항 맨 앞에 `/goal` 프리픽스를 부착합니다.
* **동작 메커니즘**:
  1. `_workspace/00_purpose_anchor.md` 파일에 성공 검증 기준(Success Criteria)을 수립 및 박제합니다.
  2. 실시간 상태판 `_workspace/goal_status.md`와 `goal_status.json`을 생성하여 현재 진척도와 이터레이션 이력을 실시간 업데이트합니다.
  3. 에이전트 실행 → ICIP 게이트 만족도 검증 및 REE 규칙 위반 여부 확인 → 위반 또는 실패 시 Blocker 원인을 프롬프트에 담아 자율 수정 이터레이션(최대 10회)을 반복합니다.
  4. 누적 도구 호출 50회 돌파 시 비용 오버런을 차단하기 위해 자율 정지(Limit Guard)합니다.

---

### 5-3. 데이터 유실 방지를 위한 자동 Git 스냅샷 및 복구 (CRP 연동)
v1.5.0부터 사용자의 치명적인 작업 유실(Rollback 불가 현상)을 방지하기 위해 CRP에 로컬 Git 기반의 스냅샷 백업 메커니즘을 내장했습니다.

* **동작 원리**: 하네스가 배포된 후 프로젝트 루트 디렉토리에 `.git` 환경이 자동 구성되며, 에이전트가 각 Phase를 완료하거나 중요한 체크포인트를 기록할 때마다 백그라운드에서 `git add .` 및 `git commit -m "CRP Checkpoint: Phase {N} - {Status}"`가 자동 수행됩니다.
* **사용자 개입 제거**: 백그라운드 커밋 과정은 일일이 사용자 승인을 받지 않고 전면 자동화되어 작업 속도를 저해하지 않습니다.
* **복구(Rollback) 방법**: 만약 치명적인 데이터 오염이나 유실이 발생하여 처음부터 다시 시작해야 할 위기가 발생했다면, 워크스페이스 터미널에서 다음 명령을 통해 안전했던 시점으로 시간을 되돌릴 수 있습니다.
  ```powershell
  # 1. 과거 체크포인트 이력 확인
  git log --oneline
  
  # 2. 원하는 특정 커밋 해시(예: a1b2c3d) 시점으로 강제 복원
  git reset --hard a1b2c3d
  ```

---

## 6. 시스템 승인 간소화 규칙 (Essential vs Automated)

Agentic OS의 피로도를 낮추고 속도를 끌어올리기 위해 승인 단계를 분리하였습니다.

| 구분 | 해당되는 지점 (예시) | 사용자 개입 여부 |
| :--- | :--- | :--- |
| **필수 승인 (Essential)** | • 최초 스캐폴딩 계획서 생성 시<br>• 중단된 작업의 복구 계획 확인 시<br>• FGM 루프 임계치(비용/에러) 도달 시<br>• 치명적 시스템 파괴(삭제) 명령 전 | **[O]** 사용자의 명시적 동의(`Y`, `시작해줘`) 없이는 절대 진행하지 않음 |
| **완전 자동화 (Automated)** | • 서브 에이전트 간 역할 전환 (ICIP)<br>• 메모리 30/50% 컨텍스트 압축 (TCM)<br>• 체크포인트 상태 저장 및 Git 백업 (CRP)<br>• 에러 발견에 따른 내부 프롬프트 자율 수정 (FGM) | **[X]** 알림 없이 백그라운드에서 자율 전개됨 |

---

## 7. 실전 운영 팁 및 PC 간 동기화

### 7-1. 직장 PC와 로컬 PC 데이터 연동 전략
로컬 가동 이력과 직장의 가도 이력을 효율적으로 매핑하고 회사 보안에 저해되지 않는 데이터 분리 전략입니다.

| 데이터 유형 | 동기화 여부 | 이유 및 동기화 방법 |
| :--- | :--- | :--- |
| **plugin 디렉토리** | **필수 공유** | 파운드리의 기본 운영 룰(SKILL.md)은 동일하므로 Git/클라우드로 상시 업데이트합니다. |
| **EPR Global** | **권장 공유** | 보편적인 코딩 실수 및 안티패턴 정보이므로 양방향 병합 관리합니다. |
| **EPR User-level** | **개별 보존** | 사용자의 로컬 환경과 회사 개발 환경에서의 실수 패턴이 다를 수 있으므로 개별 유지합니다. |
| **REE Project-rules** | **완전 분리** | 회사 프로젝트의 사내 코딩 컨벤션 및 보안 가이드는 로컬에 반출되지 않도록 엄격히 관리합니다. |
| **checkpoint.json** | **공유 불가능** | 현재 활성화된 세션의 로컬 물리 경로와 작업 상태가 박제되어 있으므로 이동이 불가능합니다. |

---

## 8. 문제 해결 (FAQ)

#### Q1. 터미널에서 `foundry_info.py`를 실행할 때 인코딩 오류가 발생합니다.
* **해결**: v1.5.0의 `foundry_info.py`는 유니코드가 아닌 ASCII 안전 배너로 전면 교체되어 해당 문제를 원천 해결했습니다. 만약 다른 스크립트에서 깨진다면 출력 스트림의 인코딩을 UTF-8로 지정하거나 `chcp 65001`을 터미널에 입력하십시오.

#### Q2. "/goal"로 무인 실행 시 무한 루프에 빠질 염려는 없나요?
* **해결**: FGM 자율 실행 루프에는 이중 안전장치가 탑재되어 있습니다. 이터레이션 수가 10회를 돌파하거나 단일 태스크의 누적 도구 호출 수가 50회를 초과할 경우 루프가 자동으로 멈추고 `goal_status.md`에 최종 Blocker 및 정지 상태를 기록한 뒤 종료됩니다.

#### Q3. 목적 앵커를 실수로 수정하거나 지웠을 때 어떻게 하나요?
* **해결**: ICIP는 `00_purpose_anchor.md`를 불변으로 유지하는 것을 감시합니다. 만약 훼손되었을 경우, `checkpoint.json` 또는 `Decision Log`에 남아있는 백업본 정보를 바탕으로 오케스트레이터가 목적 앵커 파일을 다시 원래대로 자동 복원합니다.

### 5-2. FGM (Foundry Goal Mode) — `/goal` 커맨드
장시간(예: 오버나이트) 무인 자율 구동하면서 최종 목표를 달성할 때까지 자가 수정을 거쳐 결과를 도출하는 특화 모드입니다.

* **사용법**: 자연어 지시 사항 맨 앞에 `/goal` 프리픽스를 부착합니다.
* **동작 메커니즘**:
  1. `_workspace/00_purpose_anchor.md` 파일에 성공 검증 기준(Success Criteria)을 수립 및 박제합니다.
  2. 실시간 상태판 `_workspace/goal_status.md`와 `goal_status.json`을 생성하여 현재 진척도와 이터레이션 이력을 실시간 업데이트합니다.
  3. 에이전트 실행 → ICIP 게이트 만족도 검증 및 REE 규칙 위반 여부 확인 → 위반 또는 실패 시 Blocker 원인을 프롬프트에 담아 자율 수정 이터레이션(최대 10회)을 반복합니다.
  4. 누적 도구 호출 50회 돌파 시 비용 오버런을 차단하기 위해 자율 정지(Limit Guard)합니다.

---

### 5-3. 데이터 유실 방지를 위한 자동 Git 스냅샷 및 복구 (CRP 연동)
v1.5.0부터 사용자의 치명적인 작업 유실(Rollback 불가 현상)을 방지하기 위해 CRP에 로컬 Git 기반의 스냅샷 백업 메커니즘을 내장했습니다.

* **동작 원리**: 하네스가 배포된 후 프로젝트 루트 디렉토리에 `.git` 환경이 자동 구성되며, 에이전트가 각 Phase를 완료하거나 중요한 체크포인트를 기록할 때마다 백그라운드에서 `git add .` 및 `git commit -m "CRP Checkpoint: Phase {N} - {Status}"`가 자동 수행됩니다.
* **사용자 개입 제거**: 백그라운드 커밋 과정은 일일이 사용자 승인을 받지 않고 전면 자동화되어 작업 속도를 저해하지 않습니다.
* **복구(Rollback) 방법**: 만약 치명적인 데이터 오염이나 유실이 발생하여 처음부터 다시 시작해야 할 위기가 발생했다면, 워크스페이스 터미널에서 다음 명령을 통해 안전했던 시점으로 시간을 되돌릴 수 있습니다.
  ```powershell
  # 1. 과거 체크포인트 이력 확인
  git log --oneline
  
  # 2. 원하는 특정 커밋 해시(예: a1b2c3d) 시점으로 강제 복원
  git reset --hard a1b2c3d
  ```

---

## 6. 시스템 승인 간소화 규칙 (Essential vs Automated)

Agentic OS의 피로도를 낮추고 속도를 끌어올리기 위해 승인 단계를 분리하였습니다.

| 구분 | 해당되는 지점 (예시) | 사용자 개입 여부 |
| :--- | :--- | :--- |
| **필수 승인 (Essential)** | • 최초 스캐폴딩 계획서 생성 시<br>• 중단된 작업의 복구 계획 확인 시<br>• FGM 루프 임계치(비용/에러) 도달 시<br>• 치명적 시스템 파괴(삭제) 명령 전 | **[O]** 사용자의 명시적 동의(`Y`, `시작해줘`) 없이는 절대 진행하지 않음 |
| **완전 자동화 (Automated)** | • 서브 에이전트 간 역할 전환 (ICIP)<br>• 메모리 30/50% 컨텍스트 압축 (TCM)<br>• 체크포인트 상태 저장 및 Git 백업 (CRP)<br>• 에러 발견에 따른 내부 프롬프트 자율 수정 (FGM) | **[X]** 알림 없이 백그라운드에서 자율 전개됨 |

---

## 7. 실전 운영 팁 및 PC 간 동기화

### 7-1. 직장 PC와 로컬 PC 데이터 연동 전략
로컬 가동 이력과 직장의 가도 이력을 효율적으로 매핑하고 회사 보안에 저해되지 않는 데이터 분리 전략입니다.

| 데이터 유형 | 동기화 여부 | 이유 및 동기화 방법 |
| :--- | :--- | :--- |
| **plugin 디렉토리** | **필수 공유** | 파운드리의 기본 운영 룰(SKILL.md)은 동일하므로 Git/클라우드로 상시 업데이트합니다. |
| **EPR Global** | **권장 공유** | 보편적인 코딩 실수 및 안티패턴 정보이므로 양방향 병합 관리합니다. |
| **EPR User-level** | **개별 보존** | 사용자의 로컬 환경과 회사 개발 환경에서의 실수 패턴이 다를 수 있으므로 개별 유지합니다. |
| **REE Project-rules** | **완전 분리** | 회사 프로젝트의 사내 코딩 컨벤션 및 보안 가이드는 로컬에 반출되지 않도록 엄격히 관리합니다. |
| **checkpoint.json** | **공유 불가능** | 현재 활성화된 세션의 로컬 물리 경로와 작업 상태가 박제되어 있으므로 이동이 불가능합니다. |

---

## 8. 문제 해결 (FAQ)

#### Q1. 터미널에서 `foundry_info.py`를 실행할 때 인코딩 오류가 발생합니다.
* **해결**: v1.5.0의 `foundry_info.py`는 유니코드가 아닌 ASCII 안전 배너로 전면 교체되어 해당 문제를 원천 해결했습니다. 만약 다른 스크립트에서 깨진다면 출력 스트림의 인코딩을 UTF-8로 지정하거나 `chcp 65001`을 터미널에 입력하십시오.

#### Q2. "/goal"로 무인 실행 시 무한 루프에 빠질 염려는 없나요?
* **해결**: FGM 자율 실행 루프에는 이중 안전장치가 탑재되어 있습니다. 이터레이션 수가 10회를 돌파하거나 단일 태스크의 누적 도구 호출 수가 50회를 초과할 경우 루프가 자동으로 멈추고 `goal_status.md`에 최종 Blocker 및 정지 상태를 기록한 뒤 종료됩니다.

#### Q3. 목적 앵커를 실수로 수정하거나 지웠을 때 어떻게 하나요?
* **해결**: ICIP는 `00_purpose_anchor.md`를 불변으로 유지하는 것을 감시합니다. 만약 훼손되었을 경우, `checkpoint.json` 또는 `Decision Log`에 남아있는 백업본 정보를 바탕으로 오케스트레이터가 목적 앵커 파일을 다시 원래대로 자동 복원합니다.
