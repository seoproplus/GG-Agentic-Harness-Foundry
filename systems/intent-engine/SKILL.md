---
name: intent-engine
description: "Intent Classification Engine — 사용자의 모호한 요청을 구조화하고, 직업군/작업 성격에 따른 최적 하네스 구성을 제안하는 시스템. '하네스 구성해줘', '프로젝트 시작', '새 작업 시작', '분석해줘', '연구해줘' 등 작업 의도가 포함된 모든 요청의 최초 진입점으로 사용할 것. harness-scaffolder보다 먼저 실행되어 의도를 구조화한 뒤 scaffolder에 전달한다."
---

# Intent Engine — 의도 분류 및 구조화 시스템

사용자의 자연어 요청에서 의도를 추출·구조화하고, 직업군 및 작업 성격에 맞는 최적 하네스 구성을 결정하는 시스템.

**핵심 원칙:**
1. **추측하지 않는다** — 모호한 요청은 반드시 구조화 질문으로 확인한다
2. **사용자 프로파일을 참조한다** — 이전 작업 패턴과 선호를 반영한다
3. **직업군 아키타입을 활용한다** — 기본 구성을 제안하여 설정 부담을 줄인다
4. **결과는 구조화된 Intent Object로 출력한다** — 후속 시스템(scaffolder, ICIP)이 소비 가능

## Intent Object 구조

모든 요청은 다음 구조로 변환된다:

```json
{
  "intent": {
    "raw_request": "{사용자 원문 그대로}",
    "purpose": "{달성하려는 핵심 목적 — 1문장}",
    "task_type": "research | development | analysis | planning | creation | review | goal_execution",
    "depth": "quick | standard | deep | exhaustive",
    "output_format": "report | code | plan | presentation | data | mixed",
    "target_audience": "{누가 읽는가/사용하는가}",
    "language": "ko | en | mixed",
    "execution_mode": "standard | goal_execution"
  },
  "context": {
    "domain": "{도메인/분야}",
    "domain_keywords": ["{핵심 키워드들}"],
    "existing_artifacts": ["{이미 존재하는 관련 산출물}"],
    "constraints": ["{시간/범위/기술 제약}"]
  },
  "profile": {
    "archetype": "researcher | developer | code-reviewer | test-engineer | security-auditor | planner | designer",
    "expertise_level": "beginner | intermediate | advanced | expert",
    "preferred_patterns": ["{과거에 선호한 아키텍처 패턴}"],
    "communication_style": "concise | detailed | visual"
  },
  "harness_recommendation": {
    "architecture_pattern": "{추천 패턴}",
    "agent_count": "{추천 에이전트 수}",
    "estimated_complexity": "low | medium | high | very_high",
    "systems_to_activate": ["ICIP", "CRP", "TCM", "EPR", "REE", "FGM"]
  }
}
```

## 의도 분류 워크플로우

### Phase 1: 원문 분석

사용자 요청을 받으면 다음을 추출한다:

| 추출 대상 | 방법 | 예시 |
|----------|------|------|
| **목적** | "~를 위해", "~하고 싶다", "~해줘" 패턴 | "ADHD 원인을 밝혀줘" → 목적: 원인 규명 |
| **작업 유형** | 동사 기반 분류 및 커맨드 감지 | 연구해줘→research, 만들어줘→creation, /goal 커맨드 감지→goal_execution |
| **깊이** | 부사/형용사 단서 또는 커맨드 | "간단히"→quick, "심층적으로"→deep, /goal 커맨드→exhaustive |
| **도메인** | 명사/고유명사 | "ADHD", "주식", "웹사이트" |
| **제약** | "~까지", "~만", "~없이" | "오늘까지"→시간제약, "코드 없이"→기술제약 |

### Phase 2: 모호도 판정

추출 결과에서 다음 항목이 불확실하면 **구조화 질문**을 한다:

| 항목 | 모호도 판정 기준 | 질문 예시 |
|------|----------------|----------|
| 목적 | 동사가 없거나 복수 해석 가능 | "이 작업의 최종 목표가 무엇인가요? (조사만/보고서 작성/의사결정 지원)" |
| 깊이 | 깊이 단서 없음 | "빠른 개요가 필요하신가요, 아니면 심층 분석이 필요하신가요?" |
| 산출물 | 출력 형태 불명 | "결과를 어떤 형태로 원하시나요? (마크다운 보고서/코드/프레젠테이션)" |
| 대상 독자 | 전문성 수준 불명 | "이 결과를 누가 읽나요? (본인/동료 전문가/비전문 경영진)" |

**최대 3개 질문까지만** — 4개 이상이면 사용자 피로도가 높아진다.

**모호도가 낮은 요청**(명확한 목적 + 구체적 도메인 + 깊이 단서)은 **질문 없이 바로 진행**한다.

### Phase 3: 사용자 프로파일 참조

이전 작업에서 축적된 프로파일 데이터를 참조한다:

```
프로파일 조회 경로:
1. Knowledge Items에서 사용자 프로파일 KI 검색
2. EPR의 user-level/preferences.md 참조
3. 최근 5개 대화의 작업 패턴 분석
```

**프로파일 데이터 활용:**
- 이전에 팬아웃 패턴을 3회 연속 사용 → 이번에도 우선 검토
- 항상 한국어 보고서를 요청 → language를 'ko'로 기본값
- 항상 TL;DR을 먼저 확인 → communication_style을 'concise'

### Phase 4: 직업군 아키타입(페르소나) 매핑

단순한 제너럴 아키타입 외에도, Addy Osmani의 `agent-skills` 원칙에 기반하여 특정 SDLC 단계에 특화된 **전문가 페르소나**를 정밀하게 식별한다.

| 아키타입 / 페르소나 | 특성 | 기본 패턴 | 기본 시스템 |
|-----------------|------|----------|-----------|
| **Researcher** | 깊은 조사, 다각도 분석, 문헌 기반 | Fan-out/Fan-in | ICIP + TCM + CRP |
| **Developer** | 범용 코드 생성, 기능 구현 | Pipeline | CRP + REE |
| **Code-Reviewer** | (SDLC: Review) 스태프 엔지니어 관점, 5축 코드 리뷰 | Reviewer | ICIP + REE + EPR |
| **Test-Engineer** | (SDLC: Test) QA 전문가 관점, 테스트 커버리지 및 증거 확보 | Producer-Reviewer | ICIP + REE + EPR |
| **Security-Auditor** | (SDLC: Review) 보안 엔지니어 관점, OWASP 및 취약점 탐지 | Reviewer | ICIP + REE + EPR |
| **Planner** | 전략 수립, 의사결정, 로드맵 | Supervisor | ICIP + REE |
| **Designer** | 창작, 시각화, 프로토타입 | Producer-Reviewer | CRP |

**아키타입/페르소나 감지 방법:**
1. 사용자 프로파일에 명시된 경우 → 직접 사용
2. 요청 키워드에서 추론: 
   - 일반: "연구"→Researcher, "개발"→Developer, "계획"→Planner, "디자인"→Designer
   - SDLC 특화: "코드 리뷰"→Code-Reviewer, "테스트 코드", "QA"→Test-Engineer, "보안", "취약점"→Security-Auditor
3. 과거 작업 패턴에서 가장 빈번한 유형 → 기본값

### Phase 5: 하네스 구성 추천

Intent Object를 기반으로 최적 하네스 구성을 추천한다:

```markdown
## 📋 Intent Classification Result

### 분석된 의도
- **목적**: {purpose}
- **작업 유형**: {task_type}
- **깊이**: {depth}
- **도메인**: {domain}

### 추천 하네스 구성
- **아키텍처**: {architecture_pattern}
- **에이전트 수**: {agent_count}명
- **예상 복잡도**: {estimated_complexity}
- **활성화 시스템**: {systems_to_activate}

### 활성화 시스템 설명
- ✅ ICIP: {왜 필요/불필요}
- ✅ CRP: {왜 필요/불필요}
- ✅ TCM: {왜 필요/불필요}
- ✅ EPR: {왜 필요/불필요}
- ✅ REE: {왜 필요/불필요}

이 구성으로 진행할까요?
```

## 시스템 활성화 매트릭스

작업 특성에 따라 어떤 시스템을 활성화할지 결정한다:

| 조건 | ICIP | CRP | TCM | EPR | REE |
|------|------|-----|-----|-----|-----|
| 에이전트 2개 이상 | ✅ | ✅ | — | ✅ | — |
| 깊이: deep/exhaustive | ✅ | ✅ | ✅ | ✅ | ✅ |
| task_type == 'goal_execution' | ✅ | ✅ | ✅ | ✅ | ✅ |
| 작업 예상 시간 > 30분 | — | ✅ | ✅ | — | — |
| 반복 실행 가능성 높음 | — | ✅ | — | ✅ | ✅ |
| MUST 규칙 존재 | — | — | — | — | ✅ |
| 이전 유사 작업에서 오류 발생 | — | — | — | ✅ | ✅ |

## harness-scaffolder 연동

Intent Engine은 scaffolder의 **전처리 단계**로 동작한다:

```
사용자 요청 → [Intent Engine] → Intent Object → [harness-scaffolder] → 하네스 생성
```

- Intent Object의 `harness_recommendation`이 scaffolder의 입력
- scaffolder는 Intent Engine이 결정한 패턴/에이전트 수를 기반으로 스캐폴딩
- Intent Engine이 활성화한 시스템(ICIP, CRP 등)의 프로토콜을 오케스트레이터에 주입

## 에러 핸들링
- 사용자가 질문에 답하지 않는 경우: 가장 가능성 높은 값으로 기본 설정하고 진행 (추후 수정 가능)
- 프로파일 데이터가 없는 경우 (첫 사용자): 아키타입 "Researcher"를 기본값으로 설정
- 복합 작업 (연구 + 개발): 하이브리드 아키타입으로 처리, 두 아키타입의 시스템을 합산
