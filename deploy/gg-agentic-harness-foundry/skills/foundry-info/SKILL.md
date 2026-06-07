---
name: foundry-info
description: "GG-Agentic-Harness-Foundry의 버전 정보, 탑재된 핵심 시스템 개요 및 최신 Gemini 엔진 업데이트와의 호환성을 조회하고 요약 출력하는 스킬. 사용자가 버전이나 시스템 정보를 문의할 때 트리거할 것."
---

# GG-Agentic-Harness-Foundry Info & Version Skill

이 스킬은 **GG-Agentic-Harness-Foundry**의 현재 탑재 시스템 사양, 릴리즈 버전 및 최신 Gemini 모델/업데이트와의 정렬 사양을 확인하는 데 사용됩니다.

## 1. 개요 및 버전 정보

- **명칭**: GG-Agentic-Harness-Foundry
- **버전**: `v1.5.0` (멀티 플랫폼 가변 배포, 설치 옵션, 온보딩 가이드 및 선 승인제 완비)
- **최종 업데이트**: 2026-06-07
- **플랫폼**: Antigravity IDE (Gemini 기반 최적화)

---

## 2. Gemini 업데이트에 맞춘 고도화 로드맵 (Gemini Alignment)

이 Foundry는 Gemini 엔진의 새로운 사양과 업데이트 속도에 최적화되도록 지속적으로 개선됩니다:

| Gemini 업데이트 특성 | Foundry 대응 설계 | 영향도 및 최적화 형태 |
|---------------------|-----------------|---------------------|
| **대용량 컨텍스트 (1M~2M+)** | **TCM (Tiered Context Management)** | 단순 컨텍스트 낭비를 최소화하고 핵심 목적/이시카와 분기 상태만 선별적(Tier 1)으로 보존하여 추론의 집중도 향상. |
| **JSON/Structured Output** | **Intent Engine & CRP Schema** | 에이전트 간의 데이터 전달 및 중간 체크포인트를 엄격한 JSON Schema로 검증하여 파싱 오류 전면 차단. |
| **Agentic Planning Mode** | **ICIP & REE Audit Gate** | 모델 자체의 자율 계획(Planning) 모드 수행 시 발생할 수 있는 목표 드리프트(Drift)를 Pre/Post-flight 감사 프로세스로 차단. |
| **자율 무인 실행 (Overnight Goal)** | **FGM (Foundry Goal Mode)** | Claude Code의 `/goal` 커맨드와 같이 장시간 자율 실행하여 성공 기준 및 감사율 100% 충족 시까지 자동 자가 수정을 반복 실행. |
| **지능형 에이전트 팀 스캐폴딩** | **Harness Scaffolder** | `harness-100` 연동, 멀티 플랫폼 타겟 가변 매핑(.gemini/.claude/.openai), 계획 선 제안 및 유저 승인 게이트 탑재. |

---

## 3. 탑재 핵심 운영 시스템 개요

1. **ICIP (Ishikawa Context Isolation Protocol)**
   - *목적*: Main context 보호 및 목적 드리프트 차단
   - *핵심*: `_workspace/00_purpose_anchor.md` 파일 기반의 불변 목적 고정 및 에이전트 간 분기 요약 맵핑

2. **CRP (Checkpoint & Resume Protocol)**
   - *목적*: 세션 끊김 방지 및 영구 의사결정 기록
   - *핵심*: `_workspace/checkpoint.json` 및 `Decision Log`를 통한 실행 중단 상태의 무손실 자동 재개

3. **TCM (Tiered Context Management)**
   - *목적*: 컨텍스트 소모율에 따른 지능형 압축
   - *핵심*: 3-Tier 컨텍스트 모델 및 Soft Compaction(30% 소모 시), Hard Compaction(50% 소모 시) 자동 수행

4. **EPR (Error Pattern Registry)**
   - *목적*: 동일 실수 반복 제거를 위한 오류 학습 루프
   - *핵심*: 3계층(User/Project/Global) 오류 아카이브 조회 및 Pre-flight Warning 제공

5. **REE (Rule Enforcement Engine)**
   - *목적*: 규칙의 완벽 준수 및 사후 검증
   - *핵심*: 마크다운 마커를 이용한 구조화된 규칙 파싱, 작업 완료 후 Post-flight Compliance Audit 수행

6. **Intent Engine (Intent Classification Engine)**
   - *목적*: 사용자 의도 해석 및 최적 하네스 스캐폴딩
   - *핵심*: 자연어 요청을 분류하여 직업군 아키타입(Researcher, Developer, Planner, Designer) 매핑 및 템플릿 생성

7. **FGM (Foundry Goal Mode) - `/goal` 자율 실행 루프**
   - *목적*: 장시간 무인 구동 및 성공 목표 최종 달성
   - *핵심*: 자가 수정(Self-Correction) 피드백 루프, 실시간 상태 모니터링판(`_workspace/goal_status.md`), 최대 루프 가드레일(Limit Guard)

8. **Harness Scaffolder (지능형 스캐폴더)**
   - *목적*: 멀티 플랫폼 타겟 기반 맞춤형 하네스 설계, 경로 라우팅, 유저 승인 및 원클릭 설치 자동화
   - *핵심*: 플랫폼별 네임스페이스(.gemini/.claude/.openai) 가변 매핑, `harness-100` 템플릿 및 개선 조항(`R-004`) 자동 연동, 윈도우/맥 파라미터 설치 스크립트

---

## 4. 터미널 조회를 위한 실행 기능

Foundry가 설치된 로컬 혹은 직장 환경의 터미널(PowerShell 또는 bash)에서 파이썬 스크립트를 직접 구동하여 버전과 기능 요약을 즉시 출력할 수 있습니다.

### 사용법
```powershell
# 1. 텍스트 UI 정보 출력 (기본)
python {설치경로}/gg-agentic-harness-foundry/foundry_info.py

# 2. JSON 포맷 출력 (도구/에이전트 연동용)
python {설치경로}/gg-agentic-harness-foundry/foundry_info.py --json

# 3. 버전 정보만 단순 출력
python {설치경로}/gg-agentic-harness-foundry/foundry_info.py --version
```

### 에이전트 지침
사용자가 "이 Foundry의 버전 정보가 어떻게 돼?" 혹은 "탑재된 기능들을 설명해 줘"라고 요청하면, 이 `foundry-info` 스킬 내용 및 `foundry_info.py` 실행 결과를 조합하여 **Gemini 최신 엔진 업데이트에 대응하고 harness-100 연동 스캐폴딩이 가능한 GG-Agentic-Harness-Foundry v1.3.0**의 세부 내용을 정중하고 명확하게 브리핑하십시오.
