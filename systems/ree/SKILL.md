---
name: ree
description: "Rule Enforcement Engine — 규칙 강제 준수 및 감사 시스템. 마크다운에 기록된 규칙을 구조화하여 파싱하고, 작업 시작 전 Pre-flight Check로 규칙을 로드하며, 작업 완료 후 Post-flight Audit으로 준수 여부를 검증한다. '규칙 추가', '규칙 검토', '규칙 위반', '컨벤션 확인', '표준 준수', 또는 하네스 작업의 시작/종료 시점에서 반드시 이 스킬을 사용할 것."
---

# REE — Rule Enforcement Engine

마크다운 규칙을 기계 판독 가능한 형태로 구조화하고, Pre-flight(사전 확인) / Post-flight(사후 감사)로 준수를 강제하는 시스템.

**핵심 원칙:**
1. 규칙은 **적는 것이 아니라 실행하는 것**이다 — 기록만으로는 준수를 보장할 수 없다
2. 모든 규칙은 **기계 판독 가능**해야 한다 — HTML 주석 마커로 구조화
3. 규칙 준수는 **사전(Pre-flight) + 사후(Post-flight)** 양방향으로 검증한다
4. 위반은 EPR(Error Pattern Registry)에 자동 연동하여 **학습 루프**를 형성한다

## 규칙 형식 (Rule Format)

### 구조화된 규칙 마커

일반 마크다운 내에 기계 판독 가능한 주석 마커를 삽입한다:

```markdown
### 규칙 제목
<!-- RULE: id=R-001, priority=MUST|SHOULD|MAY, scope=user|project|global -->
<!-- RULE: category=naming|structure|quality|security|performance|style -->
<!-- RULE: enforceable=true|false, auto_check=true|false -->

**규칙**: {규칙 본문 — 명확하고 검증 가능한 문장}

**이유**: {왜 이 규칙이 필요한가 — Why-First}

**검증 방법**: {이 규칙의 준수 여부를 어떻게 확인하는가}
- [ ] {체크 항목 1}
- [ ] {체크 항목 2}

**위반 시 조치**: {위반이 발견되었을 때 어떻게 하는가}

**예외**: {이 규칙이 적용되지 않는 상황}

**예시**:
- ✅ 올바른: {구체적 예시}
- ❌ 잘못된: {구체적 예시}
```

### 우선순위 체계

RFC 2119 기반:

| 우선순위 | 의미 | 위반 시 |
|---------|------|--------|
| **MUST** | 절대 준수. 위반 시 작업 차단 | ⛔ Post-flight에서 작업 결과 거부 |
| **SHOULD** | 강하게 권장. 합리적 이유 있으면 예외 가능 | ⚠️ 경고 + 예외 사유 기록 필수 |
| **MAY** | 선택적. 따르면 좋지만 필수는 아님 | 💡 권장사항으로 표시 |

### 범위 체계

| 범위 | 적용 | 저장 위치 |
|------|------|----------|
| **user** | 이 사용자의 모든 작업 | `.gemini/config/rules/user-rules.md` |
| **project** | 이 프로젝트에서만 | `{project}/.rules/project-rules.md` 또는 `{project}/_workspace/R-*.md` (개별 규칙 파일 글로빙) |
| **global** | 모든 사용자, 모든 프로젝트 | `.gemini/config/rules/global-rules.md` |

### 카테고리

| 카테고리 | 대상 | 예시 |
|---------|------|------|
| **naming** | 파일명, 변수명, 함수명 규칙 | "에이전트 파일명은 kebab-case" |
| **structure** | 디렉토리 구조, 파일 구성 | "모든 스킬은 SKILL.md를 포함" |
| **quality** | 산출물 품질 기준 | "보고서에 반드시 TL;DR 포함" |
| **security** | 보안 관련 규칙 | "API 키를 코드에 하드코딩 금지" |
| **performance** | 성능/효율 관련 | "단일 파일 읽기 800줄 이하" |
| **style** | 형식, 서식, 언어 | "사용자에게 한국어로 응답" |

## Pre-flight Check (사전 확인)

### 언제 수행하는가

| 상황 | Pre-flight 동작 |
|------|----------------|
| 하네스 작업 시작 | 모든 범위(user + project + global) 규칙 로드 |
| 서브에이전트 위임 | 해당 작업 관련 규칙을 에이전트 프롬프트에 주입 |
| 새 Phase 진입 | 해당 Phase 관련 카테고리 규칙 재확인 |

### Pre-flight 프로토콜

```
1. 규칙 파일 로드
   ├── global-rules.md (항상)
   ├── user-rules.md (항상)
   └── project-rules.md (프로젝트 작업 시)

2. RULE 마커 파싱
   └── 현재 작업의 카테고리와 매칭되는 규칙 필터링

3. EPR Pre-flight 조회 (연동)
   └── 오류 패턴 경고 수신

4. 체크리스트 구성
   └── MUST 규칙 → 필수 준수 목록
       SHOULD 규칙 → 권장 준수 목록
       MAY 규칙 → 참고 목록

5. 에이전트 프롬프트에 주입
   └── "다음 규칙을 반드시 준수하라: [MUST 규칙 목록]"
       "다음 규칙을 가능하면 준수하라: [SHOULD 규칙 목록]"
```

### Pre-flight 출력 형식

```markdown
## ✅ REE Pre-flight Check

### MUST 규칙 (위반 시 작업 차단)
- [R-001] {규칙 요약}
- [R-005] {규칙 요약}

### SHOULD 규칙 (강하게 권장)
- [R-012] {규칙 요약}

### EPR 경고 (연동)
- [EP-003] {과거 오류 패턴 경고}
```

## Post-flight Audit (사후 감사)

### 언제 수행하는가

| 상황 | Post-flight 동작 |
|------|-----------------|
| 서브에이전트 결과 반환 | 결과의 규칙 준수 여부 검증 |
| Phase 완료 | 해당 Phase 산출물 전체 감사 |
| 최종 산출물 생성 | 모든 MUST/SHOULD 규칙 최종 검증 |

### Post-flight 프로토콜

```
1. Pre-flight에서 로드한 규칙 목록 재참조

2. 산출물 대조 검증
   └── 각 규칙의 "검증 방법" 체크 항목을 하나씩 확인

3. 준수 보고서 생성
   ├── 준수한 규칙: ✅ 표시
   ├── 위반한 규칙: ❌ 표시 + 위반 내용 기술
   └── 해당 없는 규칙: ➖ 표시

4. 위반 처리
   ├── MUST 위반: ⛔ 작업 결과 거부 → 수정 후 재감사
   ├── SHOULD 위반: ⚠️ 경고 → 예외 사유 기록 또는 수정
   └── MAY 위반: 💡 참고 기록

5. EPR 연동
   └── 반복 위반 → EPR에 오류 패턴 등록
```

### Post-flight Compliance Report

```markdown
## 📋 REE Post-flight Audit Report

### 감사 대상: {Phase/에이전트/산출물 이름}
### 감사 시각: {타임스탬프}

| Rule ID | 우선순위 | 규칙 | 판정 | 비고 |
|---------|---------|------|------|------|
| R-001 | MUST | 보고서에 TL;DR 포함 | ✅ | — |
| R-005 | MUST | 파일명 kebab-case | ❌ | `MyReport.md` → `my-report.md` |
| R-012 | SHOULD | 한국어 사용 | ✅ | — |
| R-020 | MAY | mermaid 다이어그램 포함 | ➖ | 해당 없음 |

### 종합 판정
- MUST 위반: {N}건 → ⛔ **수정 필요**
- SHOULD 위반: {N}건 → ⚠️ 경고
- 총 준수율: {N}%

### 수정 요구사항
1. [R-005] 파일명을 `my-report.md`로 변경
```

## 규칙 생명주기

### 규칙 생성

```
사용자/시스템이 규칙 필요성 인식
  │
  ├─→ 규칙 초안 작성 (RULE 마커 포함)
  │
  ├─→ 범위/우선순위/카테고리 결정
  │
  ├─→ 검증 방법 정의 (체크 항목)
  │
  └─→ 해당 규칙 파일에 추가
```

### EPR → REE 승격

```
EPR에서 3회 이상 발생한 안정 패턴
  │
  ├─→ 패턴을 RULE 형식으로 변환
  │
  ├─→ 검증 방법 정의
  │
  ├─→ REE 규칙 파일에 등록
  │
  └─→ EPR 엔트리에 PROMOTED 마커 추가
```

### 규칙 폐기

| 조건 | 동작 |
|------|------|
| 6개월간 Post-flight에서 한 번도 트리거되지 않음 | 폐기 검토 대상 표시 |
| 사용자가 명시적으로 폐기 요청 | 즉시 제거 또는 MAY로 강등 |
| 기술 스택 변경으로 무의미해짐 | 제거 + 사유 기록 |

## ICIP 연동
- 서브에이전트 위임 시 Pre-flight 규칙을 에이전트 프롬프트에 주입
- 게이트 평가 시 Post-flight 감사 연동
- 목적 부합성 + 규칙 준수를 동시에 평가

## CRP 연동
- Post-flight 결과를 checkpoint.json의 해당 Phase에 기록
- 재개 시 이전 Phase의 감사 결과를 참조하여 같은 위반 방지

## TCM 연동
- Pre-flight 체크리스트는 Tier 1 (Hot Context)에 위치 — Compaction 대상이 아님
- Post-flight 보고서는 Soft Compaction 시 요약으로 대체 가능

## 에러 핸들링
- 규칙 파일이 없는 경우: 자동 생성 (빈 파일 + 기본 global 규칙 3개)
- RULE 마커 파싱 실패: 해당 규칙을 무시하고 경고 출력
- 모든 MUST 규칙 위반 + 수정 불가: 사용자에게 에스컬레이션

## Agent-First CLI Synergy: Introspectable Schema
Addy Osmani의 에이전트 설계 원칙에 따라, REE는 정적 규칙 마크다운을 무조건 프롬프트에 구겨 넣는 방식(Human DX)에서 벗어나, 에이전트가 런타임에 직접 스키마를 질의할 수 있는 **동적 조회 엔진(Agent DX)**으로 고도화된다.

### 동적 스키마 조회 (Introspection)
- **명령어 기반 질의**: 에이전트는 작업 착수 전 `ree query --task="frontend" --output=json` 형태로 필요한 도메인 규칙만 질의할 수 있다.
- **예측 가능성(Predictability)**: 질의 결과는 자연어가 아닌 기계 판독 가능한 JSON 스키마 규격으로 반환되어 에이전트가 오해 없이 규칙을 준수하도록 강제한다.
- **토큰 예산 방어**: 전체 글로벌 룰을 로드하지 않으므로 에이전트의 컨텍스트 한계와 토큰 예산을 지켜준다.
