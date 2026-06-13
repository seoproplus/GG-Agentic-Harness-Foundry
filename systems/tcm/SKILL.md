---
name: tcm
description: "Tiered Context Management — 컨텍스트 윈도우 사용량을 모니터링하고, 30% 도달 시 Soft Compaction, 50% 도달 시 Hard Compaction을 강제하여 에이전트의 의도 파악 능력을 유지하는 시스템. '컨텍스트 정리', '요약해줘', '대화가 길어졌다', '기억 못하나' 등의 키워드나, multi-turn 대화가 길어지는 모든 상황에서 이 스킬을 참조할 것."
---

# TCM — Tiered Context Management

컨텍스트 윈도우를 3계층(Hot/Warm/Cold)으로 관리하고, 임계치 도달 시 강제 Compaction을 수행하여 에이전트의 추론 품질을 유지하는 시스템.

**핵심 원칙:**
1. 컨텍스트는 **공공재**다 — 모든 토큰은 그 비용을 정당화해야 한다
2. 목적 앵커와 핵심 결정사항은 **절대 Compaction 대상이 아니다** (Tier 1 불변 영역)
3. Compaction은 선택이 아닌 **강제**다 — 임계치 도달 시 자동 트리거
4. "lost-in-the-middle" 현상을 **구조적으로** 방지한다

## 3계층 컨텍스트 모델

### Tier 1: Hot Context (활성 — 항상 보존)
현재 작업에 즉시 필요한 정보. Compaction 대상이 아님.

| 항목 | 설명 | 예상 크기 |
|------|------|----------|
| 목적 앵커 | ICIP의 `00_purpose_anchor.md` | ~200 토큰 |
| 현재 Phase 지시사항 | 지금 수행 중인 단계의 구체적 지시 | ~500 토큰 |
| 활성 규칙 | REE의 Pre-flight에서 로드한 현재 스코프 규칙 | ~300 토큰 |
| 체크포인트 요약 | CRP의 현재 상태 + 마지막 3개 결정 | ~200 토큰 |
| 사용자 최근 요청 | 가장 최근 사용자 메시지 | 가변 |

**Tier 1 보존 원칙**: 이 계층의 내용은 어떤 Compaction 레벨에서도 삭제/요약되지 않는다.

### Tier 2: Warm Context (참조 가능 — 필요 시 로드)
이전 작업의 요약과 메타데이터. Soft Compaction 시 파일로 이관.

| 항목 | 설명 |
|------|------|
| 이전 Phase 요약 | 완료된 Phase의 TL;DR + 핵심 발견 |
| 에이전트 결과 요약 | 서브에이전트 반환의 TL;DR 섹션 |
| Decision Log | CRP의 결정 이력 (최근 3개 이후) |
| 관련 EPR 항목 | 현재 작업과 매칭된 오류 패턴 |

### Tier 3: Cold Context (파일 저장 — 명시적 로드만)
상세 원본 데이터. 컨텍스트에 로드하지 않음.

| 항목 | 설명 |
|------|------|
| 서브에이전트 전체 로그 | 중간 과정 포함 완전한 로그 |
| 산출물 원본 | 전체 보고서, 데이터, 분석 결과 |
| 도구 호출 기록 | 웹 검색, 파일 읽기 등의 상세 결과 |
| 이전 대화 기록 | Compaction된 이전 대화 원본 |

## Compaction 전략

### 임계치 판단

에이전트가 직접적으로 토큰 수를 측정할 수는 없으나, 다음 **프록시 지표**로 판단한다:

| 프록시 지표 | Soft (30%) 기준 | Hard (50%) 기준 |
|------------|-----------------|-----------------|
| 대화 턴 수 | 15턴 이상 | 25턴 이상 |
| 파일 읽기 누적 | 5개 이상 | 10개 이상 |
| 도구 호출 누적 | 20회 이상 | 35회 이상 |
| 서브에이전트 결과 수신 | 3개 이상 | 5개 이상 |
| 명시적 사용자 피드백 | "기억 못하나", "아까 말한 것" | "처음부터 다시", "맥락을 잃은 것 같다" |

> **주의**: 위 수치는 경험적 가이드라인이다. 실제 체감 성능 저하 시점에 따라 조정한다.

### Soft Compaction (30% 도달)

**목표**: Tier 2를 파일로 이관하여 활성 컨텍스트를 가볍게 유지

**동작:**
1. 완료된 Phase의 상세 내용을 **요약**으로 대체
   - 원본 → `_workspace/archive/phase_{N}_full.md`
   - 요약 → Tier 1에 남는 ~100 토큰 요약
2. 서브에이전트 결과의 상세를 TL;DR로 대체
3. 오래된 Decision Log 항목을 checkpoint.json에만 보존 (컨텍스트에서 제거)
4. **CRP 갱신**: checkpoint.json의 `compaction_count` 증가

**요약 작성 규칙:**
```markdown
## Phase {N} 요약 (Compacted)
<!-- COMPACTED: 원본은 _workspace/archive/phase_{N}_full.md -->

**TL;DR**: {3문장 이내 핵심}
**주요 결정**: {이 Phase에서 내린 핵심 결정 1-2개}
**후속 Phase에 전달할 핵심 데이터**: {구체적 수치, 이름, 식별자 등}
```

**요약 시 보존 우선순위:**
1. 수치 데이터 (정량적 결과) — 가장 중요
2. 고유 명사/식별자 (이름, ID, 경로)
3. 결정 사항 (무엇을 선택하고 무엇을 버렸는지)
4. 관계/인과 (X 때문에 Y를 결정함)
5. 서술/설명 (가장 먼저 축약)

### Hard Compaction (50% 도달)

**목표**: 컨텍스트를 Tier 1 필수 요소로만 구성

**동작:**
1. Soft Compaction의 모든 동작 수행 (아직 안 했다면)
2. Tier 2의 모든 항목을 파일로 이관
3. 현재 진행 중인 Phase의 지시사항도 **핵심만** 남기고 축약
4. **Compaction Report** 생성:

```markdown
## Compaction Report
<!-- 이 보고서는 Hard Compaction 직후 Main 컨텍스트에 남는 유일한 요약 -->

### 목적 (불변)
{purpose_anchor에서 복사}

### 현재 위치
- Phase: {N}/{total} — {Phase 이름}
- 상태: {완료된 것 / 진행 중인 것 / 남은 것}

### 지금까지의 핵심 결정 (최대 5개)
1. {결정 + 이유}
2. ...

### 현재 Phase에서 해야 할 것
{구체적 다음 단계}

### 참조 필요 시
- 상세 기록: _workspace/archive/
- 체크포인트: _workspace/checkpoint.json
- 분기 맵: _workspace/01_branch_map.md
```

## Compaction-Friendly 산출물 작성 규칙

모든 산출물(에이전트 결과, 보고서, 분석)은 Compaction에 대비한 구조를 따른다:

### 필수 섹션

```markdown
## TL;DR
{3문장 이내 — Compaction 시 이 섹션만 보존}

## 핵심 데이터
{수치, 고유 명사 등 — Soft Compaction에서도 보존}

## 상세
{본문 — Soft Compaction 시 파일로 이관}
```

### 왜 TL;DR이 중요한가
Compaction 시 LLM이 "무엇을 남기고 무엇을 버릴지" 판단하면 **판단 오류 위험**이 있다. 미리 저자가 TL;DR을 작성하면:
- Compaction 판단이 아닌 **기계적 추출**로 수행 가능
- 저자(서브에이전트)가 자신의 결과를 가장 잘 요약할 수 있음
- 일관된 요약 품질 보장

## ICIP 연동
- 목적 앵커는 Tier 1에 항상 존재 → Compaction 후에도 목적을 잊지 않음
- Compaction Report에 목적을 복사하여 이중 보험
- 분기 맵은 Soft Compaction에서 보존, Hard Compaction에서 파일로 이관

## CRP 연동
- Compaction 발생마다 checkpoint.json 갱신
- Decision Log가 Compaction에서 밀려나도 checkpoint.json에 영구 보존
- 재개 시 checkpoint.json에서 결정 이력 복원 → Compaction에 무관하게 맥락 유지

## 에러 핸들링
- Compaction 후 목적 앵커가 누락된 경우: `_workspace/00_purpose_anchor.md`에서 재로드
- Compaction 후 현재 Phase를 모르는 경우: `_workspace/checkpoint.json`에서 복원
- archive 파일이 손상/누락된 경우: checkpoint.json의 summary로 대체 (품질 저하 수용)

## Agent-First CLI Synergy: Field Masking & Progressive Disclosure (점진적 공개)
Addy Osmani의 에이전트 설계 원칙에 따라, TCM은 정적 파일 텍스트를 무비판적으로 전체 로드하는 것을 지양하고, **동적 스키마 조회 및 Field Masking**을 통해 필요한 JSON 필드나 특정 메타데이터만 로드하여 토큰을 방어한다.

### 점진적 공개 원칙에 따른 Cold Context 설계
스킬 명세서(`SKILL.md`)만 Hot Context(Tier 1)에 상주시키고, 방대한 체크리스트(예: `security-checklist.md`, `testing-patterns.md`)는 기본적으로 완전히 배제된 Cold Context(Tier 3)로 취급한다. 에이전트가 특정 검증 단계에 돌입했을 때만 `tcm_query`나 Field Masking을 통해 해당 파일의 필요 섹션만 핀포인트로 당겨오게 만들어, 토큰 사용량을 극단적으로 최적화한다.

### Field Mask 쿼리
거대한 산출물(Artifact)이나 스킬 목록을 로드해야 할 때, 전체 마크다운 텍스트를 로드하지 말고 아래와 같이 Field Mask를 지정하여 필요한 필드만 JSON 형태로 요청한다.
- **AS-IS (Human DX)**: `view_file("huge_artifact.md")` (전체 텍스트 로드, 토큰 낭비)
- **TO-BE (Agent DX)**: `tcm_query(target="huge_artifact.md", fields="summary, tldr")` (필요한 속성만 JSON으로 반환받아 컨텍스트에 추가)

### NDJSON Pagination
목록성 데이터(예: 파일 목록, 스킬 목록)를 읽어올 때 전체 배열을 한 번에 읽는 대신, 각 항목을 개별 JSON(NDJSON) 스트림 형태로 가져와 처리 중 메모리 한계와 컨텍스트 초과를 사전에 차단한다.
