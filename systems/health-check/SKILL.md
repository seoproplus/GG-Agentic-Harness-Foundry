---
name: health-check
description: "/health-check 명령어를 처리하는 시스템 스킬. 사용자가 /health-check를 입력하면 코드베이스 전체를 다중 패스 매트릭스(Multi-Pass Matrix) 검증 방식으로 전수 감사하여 모순을 완벽하게 탐지하고, Zero-Drift 정책에 따라 파생 모순까지 철저히 차단한다."
---

# Health-Check Command System

사용자가 `/health-check` 명령어를 입력할 때 발동되는 코드베이스 무결성 심층 감사 스킬.
에이전트의 컨텍스트 한계와 환각을 방지하기 위해 "기계적이고 결정론적인 매트릭스 대조 방식"을 강제한다.

## 핵심 원칙
1. **결정론적 다중 패스 (Deterministic Multi-Pass)** — 전체 파일을 한 번에 읽고 짐작하지 않는다. 기준점(Source of Truth)을 먼저 확립하고, 그 기준을 들고 타겟 파일들을 표적 감사한다.
2. **매트릭스 검증 (Matrix Validation)** — 반드시 `health_check_matrix.md` 아티팩트를 렌더링하여 각 파일별 점검 결과를 O/X로 시각화한다.
3. **무결점 보장 (Zero-Drift Policy)** — 모순을 패치한 직후 해당 파일들에 대해 미니 헬스체크를 반복하여, 순차적 수정으로 인한 파생 모순을 원천 차단한다.

## 워크플로우

### Pass 1: Source of Truth (기준점) 확립
본격적인 스캔에 앞서, 프로젝트의 "정답"을 먼저 변수로 추출한다.
- `systems/foundry-info/SKILL.md`와 `docs/architecture.md`를 읽고 다음 핵심 기준을 추출한다.
  - **CURRENT_VERSION**: 현재 전체 코드베이스의 메이저/마이너 버전 (예: v1.5.0)
  - **SYSTEM_COUNT & LIST**: 활성화된 운영 시스템의 총 개수 및 명칭 리스트 (예: 8대 핵심 시스템)
  - **ARCHETYPE_LIST**: Intent Engine 등에서 정의한 활성 아키타입 전체 목록

### Pass 2: Matrix Validation (표적 감사)
추출한 기준점을 바탕으로, 다음 스캔 대상을 순회하며 **결정론적**으로 일치 여부를 대조한다. 이때 반드시 `health_check_matrix.md` 아티팩트 표를 작성하며 진행한다.

| 스캔 대상 | 검증 포인트 |
|----------|------------|
| `systems/*/SKILL.md` (전체) | 버전 번호 일치, `systems_to_activate` 및 `archetype` JSON 스키마 필드 완전성, Agent-First CLI 연동 정합성 |
| `docs/architecture.md` | 버전 번호, N대 핵심 시스템 개수(Pass 1 기준점) 명시, 구조도 내 파일 누락 여부 |
| `integration/orchestrator-enhanced.md` | FGM 체크박스 및 런타임 개입 로직, 시스템 목록 일치 |
| `_workspace/R-*.md` (전체 규칙) | REE 규칙 경로 유효성 및 마커 `<!-- RULE: ... -->` 형식 무결성 |
| `scratch/harness-100-improvements.md` | 헤더 버전 번호 동기화 여부 |

### Pass 3: REE & EPR Audit (규칙 정합성)
- R-009 (명세 갱신 시 JSON 스키마·버전 동기화 의무화) 원칙이 준수되었는지 검사한다.
- `_workspace/.error-registry/known-issues.md` 내의 EPR 마커 `<!-- EPR: ... -->` 문법 및 "승격(PROMOTED)" 상태 불일치를 확인한다.

### Pass 4: 보고서 작성 및 사용자 승인
모순이 발견되면 다음 형식으로 보고서를 작성한다 (`implementation_plan.md` 활용):

```markdown
# 🏥 Health-Check Report — {날짜}

## 📊 검증 매트릭스 (`health_check_matrix.md` 참조 완료)
...
## 🛑 발견된 모순
### 모순 {N}: {제목} (심각도: {High/Medium/Low})
- **위치**: `{파일경로}` L{라인번호}
- **💡 Proposed Fix**: {구체적 해결 방안}
```
- 사용자의 패치 승인을 대기한다. 모순이 0건이면 정상 종료한다.

### Pass 5: Zero-Drift Policy (패치 후 즉각 재검증)
- 사용자의 승인 하에 패치를 수행한 직후, **작업을 바로 종료하지 않는다**.
- 수정한 파일들과 연관된 참조 파일들(R-009 영향 파일 목록 등)을 대상으로 Pass 2를 부분 재실행(Mini Health-Check)한다.
- "패치로 인해 또 다른 모순이 발생하지 않았음"이 100% 증명되었을 때만 턴을 마친다.

## REE 연동
이 스킬은 `_workspace/R-008_health_check_command.md` 규칙에 의해 실행 방식(매트릭스 아티팩트 강제 등)이 엄격하게 통제된다.
