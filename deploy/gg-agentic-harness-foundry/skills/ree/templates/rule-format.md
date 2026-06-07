# REE 규칙 형식 가이드
<!-- Rule Enforcement Engine — Rule Format Reference -->

## 규칙 마커 사양

### 기본 마커

```markdown
<!-- RULE: id=R-{NNN}, priority=MUST|SHOULD|MAY, scope=user|project|global -->
<!-- RULE: category=naming|structure|quality|security|performance|style -->
<!-- RULE: enforceable=true|false, auto_check=true|false -->
```

### 필드 설명

| 필드 | 필수 | 값 | 설명 |
|------|------|---|------|
| `id` | ✅ | `R-{NNN}` | 고유 식별자 |
| `priority` | ✅ | `MUST\|SHOULD\|MAY` | RFC 2119 기반 우선순위 |
| `scope` | ✅ | `user\|project\|global` | 적용 범위 |
| `category` | ✅ | 6개 카테고리 중 택 1 | 분류 |
| `enforceable` | ❌ | `true\|false` | 자동 검증 가능 여부 |
| `auto_check` | ❌ | `true\|false` | Post-flight에서 자동 체크 여부 |

### 규칙 본문 구조

```markdown
### R-{NNN}: {규칙 제목}
<!-- RULE: id=R-001, priority=MUST, scope=global -->
<!-- RULE: category=quality, enforceable=true, auto_check=true -->

**규칙**: {1-2문장의 명확한 규칙}

**이유**: {왜 이 규칙이 필요한가}

**검증 방법**:
- [ ] {체크 항목 1}
- [ ] {체크 항목 2}

**위반 시 조치**: {구체적 조치}

**예외**: {적용되지 않는 경우}

**예시**:
- ✅ `correct_example`
- ❌ `wrong_example`
```

## 기본 규칙 세트 (시드)

아래는 모든 하네스 작업에 공통으로 적용되는 시드 규칙이다:

### R-001: 산출물에 TL;DR 필수
<!-- RULE: id=R-001, priority=MUST, scope=global -->
<!-- RULE: category=quality, enforceable=true, auto_check=true -->

**규칙**: 모든 산출물(보고서, 분석, 조사 결과)의 최상단에 `## TL;DR` 섹션을 포함한다.

**이유**: TCM의 Compaction 시 TL;DR 섹션만 보존함으로써 기계적 추출이 가능하다. 이 섹션이 없으면 LLM이 요약을 판단해야 하며, 이는 정보 손실 위험을 높인다.

**검증 방법**:
- [ ] 산출물 상단 5줄 이내에 `## TL;DR` 또는 `### TL;DR`이 존재하는가
- [ ] TL;DR 내용이 3문장 이내인가

**위반 시 조치**: TL;DR 섹션 추가 요구

**예외**: 10줄 미만의 짧은 산출물

---

### R-002: 목적 앵커 불변성
<!-- RULE: id=R-002, priority=MUST, scope=global -->
<!-- RULE: category=structure, enforceable=true, auto_check=false -->

**규칙**: `_workspace/00_purpose_anchor.md`는 생성 후 수정하지 않는다.

**이유**: 목적 앵커가 수정되면 이전 분기의 평가 기준이 변경되어, 게이트 평가의 일관성이 깨진다.

**검증 방법**:
- [ ] 앵커 파일의 수정 시각이 생성 시각과 동일한가

**위반 시 조치**: 수정된 앵커를 원래로 복원하고, 목적 변경이 필요하면 새 앵커를 별도 생성

**예외**: 사용자가 명시적으로 목적 변경을 요청한 경우 → 새 앵커 생성 + 이전 앵커 아카이빙

---

### R-003: 체크포인트 자동 갱신
<!-- RULE: id=R-003, priority=MUST, scope=global -->
<!-- RULE: category=structure, enforceable=true, auto_check=true -->

**규칙**: 2개 이상의 Phase로 구성된 작업에서, 각 Phase 완료 시 `_workspace/checkpoint.json`을 갱신한다.

**이유**: 체크포인트 없이 세션이 종료되면 모든 진행 상태가 손실된다. CRP의 핵심 가치는 "Compaction에도 살아남는 메타데이터"이다.

**검증 방법**:
- [ ] `_workspace/checkpoint.json`이 존재하는가
- [ ] `current_phase` 값이 실제 진행 상태와 일치하는가

**위반 시 조치**: 즉시 checkpoint.json 생성/갱신

**예외**: 단일 Phase 작업 (Phase가 1개뿐인 경우)

---

### R-004: 스캐폴딩 개선 가이드라인 반영
<!-- RULE: id=R-004, priority=MUST, scope=global -->
<!-- RULE: category=quality, enforceable=true, auto_check=true -->

**규칙**: 하네스 스캐폴딩을 시작하기 전, 반드시 `scratch/harness-100-improvements.md` 파일을 참조하여 플랫폼 적합성 및 개선 지침을 자동 주입하여 배포한다.

**이유**: 누적된 유저 피드백과 서브에이전트의 스캐폴딩 보완 요소를 무시하지 않고 지속적이고 실질적으로 다음 스캐폴딩에 반영하기 위함이다.

**검증 방법**:
- [ ] 스캐폴딩 실행 전 `scratch/harness-100-improvements.md` 파일이 로드되었는가
- [ ] 개선 보고서에 적힌 조항들(플랫폼 독립적 배포, 다자간 루프 믹스인 등)이 생성된 하네스 구조에 물리적으로 적용되었는가

**위반 시 조치**: 스캐폴딩 재실행 및 코드 수정 적용

**예외**: 개선 지침 파일이 존재하지 않는 최초 구동 상태
