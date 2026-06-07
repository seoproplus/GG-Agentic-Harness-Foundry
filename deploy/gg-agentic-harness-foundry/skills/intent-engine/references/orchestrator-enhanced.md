# 통합 오케스트레이터 템플릿 (Enhanced)
<!-- GG-Agentic-Harness-Foundry — 6대 시스템 통합 오케스트레이터 -->
<!-- revfactory/harness의 오케스트레이터 템플릿을 확장하여 6대 시스템을 내장 -->

## 사용 방법

이 템플릿을 기반으로 도메인별 오케스트레이터 스킬을 생성합니다.
`{placeholder}`를 실제 값으로 치환하세요.

---

```markdown
---
name: {domain}-orchestrator
description: "{도메인} 에이전트 팀을 조율하는 오케스트레이터. 6대 운영 시스템(ICIP/CRP/TCM/EPR/REE/Intent) 통합. {트리거 키워드 나열}."
---

# {Domain} Orchestrator (Enhanced)

{도메인}의 에이전트 팀을 조율하여 {최종 산출물}을 생성하는 통합 스킬.
GG-Agentic-Harness-Foundry의 6대 시스템을 내장하여 컨텍스트 보존, 오류 방지, 규칙 준수를 강제한다.

## 활성화 시스템
<!-- Intent Engine의 추천에 따라 필요한 시스템만 활성화 -->
- [x] ICIP (목적 앵커 + 게이트 평가)
- [x] CRP (체크포인트 + 재개)
- [x] TCM (컨텍스트 압축)
- [x] EPR (오류 패턴 사전 조회)
- [x] REE (규칙 사전/사후 검증)

## 에이전트 구성

| 팀원 | 에이전트 타입 | 역할 | 스킬 | 출력 |
|------|-------------|------|------|------|
| {teammate-1} | {type} | {역할} | {skill} | {output} |
| {teammate-2} | {type} | {역할} | {skill} | {output} |

## 워크플로우

### Phase 0: 시스템 초기화

#### 0-1. 컨텍스트 확인 (CRP)
1. `_workspace/checkpoint.json` 존재 여부 확인
2. 존재 → **재개 모드**: 체크포인트에서 상태 복원, Phase 0-2로 이동
3. 미존재 → **신규 모드**: Phase 0-2로 진행

#### 0-2. EPR Pre-flight 조회
1. 현재 작업 키워드 추출
2. EPR 3계층(user/project/global) 스캔
3. 매칭된 오류 패턴 경고 출력

#### 0-3. REE Pre-flight Check
1. 규칙 파일 로드 (global + user + project)
2. MUST 규칙 체크리스트 구성
3. 에이전트 프롬프트에 주입할 규칙 준비

### Phase 1: 준비 + 목적 앵커 (ICIP)

1. 사용자 입력 분석
2. `_workspace/` 생성
3. **목적 앵커 설정**: `_workspace/00_purpose_anchor.md` 생성
   - 핵심 목적, 성공 기준, 범위 제한, 최종 산출물 명시
4. **분기 맵 설계**: `_workspace/01_branch_map.md` 생성
   - 이시카와 분기 구조 정의
   - 각 분기의 구체적 질문 + 담당 에이전트 배정
5. **CRP 체크포인트**: Phase 1 완료 기록

### Phase 2: 팀 구성 + 규칙 주입

1. 팀 생성 (revfactory/harness의 TeamCreate 또는 Agent 호출)
2. 각 에이전트 프롬프트에 **필수 포함**:
   - 목적 앵커 전문 (ICIP)
   - 해당 분기의 구체적 질문 (ICIP)
   - 반환 형식 (ICIP — TL;DR + 핵심 발견 + 목적 기여도)
   - Pre-flight 규칙 (REE)
   - 관련 EPR 경고 (EPR)
3. **CRP 체크포인트**: Phase 2 완료 기록

### Phase 3: 실행 및 게이트 평가 (또는 FGM 자율 실행 루프)

#### 3-1. 실행 모드 분기
- **일반 모드**: 에이전트들이 단발성으로 병렬 작업을 수행하고 결과를 검증합니다.
- **FGM (Foundry Goal Mode) 모드** (`/goal` 커맨드 작동 시): 목적 성공 기준 충족 및 규칙 준수 100% 달성 시까지 자가 수정을 수행하는 무인(Unattended) 실행 루프를 가동합니다.

#### 3-2. FGM 자율 실행 루프 (Unattended Self-Correction Loop)
```
While current_iteration <= max_iterations (기본값: 10회):
  1. [상태 기록] `_workspace/goal_status.md` 및 `goal_status.json` 생성 및 상태 기록.
     - 구성: 진척도, 완료된 단계, 현재 차단요인(Blocker), 누적 API/도구 호출수 및 예산 상태
  2. [작업 수행] 에이전트들을 기동하여 분기별 질문 해결 및 산출물 생성.
  3. [게이트 평가 (ICIP)] 각 결과가 `00_purpose_anchor.md`에서 규정한 성공 기준을 달성하는지 평가.
  4. [Post-flight Audit (REE)] 산출물의 MUST 규칙 준수 여부 자동 감사.
  5. [판정 및 자가 수정]
     - 충족도 100% -> status = SUCCESS 기록, 루프 즉시 완료 및 Phase 4로 진행.
     - 미달 사항 존재 -> Blocker 요인을 수집하여 `goal_status.md` 갱신.
       - 실패 사유와 EPR의 회피 패턴을 다음 이터레이션의 에이전트 프롬프트에 피드백으로 주입.
       - current_iteration += 1 및 재시도 실행.
  6. [안전 장치 (Limit Guard)] 누적 도구 호출 50회 초과 또는 예산 한도 초과 시 즉시 강제 종료 (FAILED).
```

#### 3-3. TCM 점검 (루프 내 매 회 실행)
프록시 지표 확인:
- 15턴 이상 or 파일 5개 이상 읽음 → Soft Compaction 고려 (요약본 파일 이관)
- 25턴 이상 or 파일 10개 이상 → Hard Compaction 실행 (목적 앵커 및 상태 파일만 제외하고 컨텍스트 제거)

#### 3-4. CRP 체크포인트
각 이터레이션 완료 시 진행 상황을 `checkpoint.json`에 영구 기록.

### Phase 4: 통합 + 최종 산출물

1. Main이 직접 통합 수행:
   - 각 분기 TL;DR 수집 → 전체 그림 파악
   - 상세 선택적 참조
   - 분기 간 상충 발견 시 명시 + 판단
2. 최종 산출물 구조:
   - `## TL;DR` (R-001 준수)
   - `## 목적 달성도 평가`
   - `## 핵심 발견 통합`
   - `## 한계 및 후속 과제`
3. **Post-flight 최종 감사 (REE)**: 전체 MUST 규칙 최종 검증
4. **CRP 최종 체크포인트**: status를 COMPLETED로

### Phase 5: 오류 패턴 수확 (EPR)

작업 완료 후:
1. 작업 중 발생한 오류/재작업 검토
2. 반복 가능성 있는 패턴 → EPR에 등록
3. REE 규칙 후보 식별 → 3회 이상 발생 패턴은 규칙 승격 검토

## 에러 핸들링
- 전체 시스템 실패 시: checkpoint.json에 FAILED 기록, 사용자에게 보고
- 부분 실패 시: 완료된 부분은 보존, 실패 에이전트만 재호출
- TCM Hard Compaction 후 맥락 손실 시: checkpoint.json + purpose_anchor로 복원
```

---

## 이 템플릿과 revfactory/harness 원본의 차이점

| 영역 | 원본 (revfactory) | Enhanced (Agentic OS) |
|------|-------------------|----------------------|
| Phase 0 | 컨텍스트 확인만 | + EPR Pre-flight + REE Pre-flight |
| Phase 1 | 입력 분석 | + 목적 앵커 + 분기 맵 (ICIP) |
| Phase 2 | 팀 생성 | + 규칙/EPR 주입 |
| Phase 3 | 병렬 실행 | + 게이트 평가 + Post-flight + TCM |
| Phase 4 | 통합 | + 최종 감사 (REE) |
| Phase 5 | — (없음) | + 오류 패턴 수확 (EPR) |
| 전반 | — | + CRP 체크포인트 매 Phase |
