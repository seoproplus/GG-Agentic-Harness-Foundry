---
name: harness-scaffolder
description: "AI 기반 동적 하네스(에이전트+스킬) 생성 스킬. 사용자가 '하네스 구성해줘: [주제/도메인]', '프로젝트 스캐폴딩 해줘', '새로운 에이전트 팀 만들어줘' 라고 요청할 때 이 스킬을 사용하여 harness-100을 참조해 개선된 하네스를 구성한다."
---

# Harness Scaffolder — 지능형 템플릿 연동 및 개선 스캐폴딩 스킬

이 스킬은 사용자가 요청한 도메인에 부합하는 베스트 프랙티스 템플릿(`harness-100` 라이브러리)을 찾아내고, 여기에 **GG-Agentic-Harness-Foundry의 6대 운영 레이어(ICIP/CRP/TCM/EPR/REE/FGM)**를 강제로 주입(Injection)하여 고도로 최적화된 프로덕션급 에이전트 하네스를 생성 및 배포합니다.

---

## 1. 작동 워크플로우

### Phase 1: 의도 분석 및 루트 디렉토리 결정
0. **[필수] 스캐폴딩 개선 가이드라인 로드**: 작업을 시작하기 전, 반드시 [harness-100-improvements.md](file:///c:/Users/themo/Documents/03_AI_WORKSPACE/GG-Agentic-OS-Harness/scratch/harness-100-improvements.md)를 읽고 여기에 누적 수록된 개선 지침(플랫폼 독립적 배포, 다자간 환류 루프 믹스인, 공백 경로 쿼트 처리)을 가져와 이번 스캐폴딩 구조 설계 시 강제 적용합니다.
1. **의도 및 도메인 분석**: 사용자의 자연어 요청에서 핵심 도메인 키워드(예: "재고관리 웹앱" -> `webapp`, `database`, `api`)를 도출하고 `harness-100` 라이브러리에서 매칭할 폴더(예: `16-fullstack-webapp`)를 식별합니다.
2. **프로젝트 루트 경로 식별**: 사용자가 요청에 포함한 **프로젝트 루트 경로**(예: `C:\Projects\MyScrapApp`)를 추출합니다. 경로가 주어지지 않았다면, 기본값으로 워크스페이스 하위에 사용자 의도에 맞는 프로젝트 폴더(`_workspace/{project-name}`)를 생성하도록 지정합니다.
3. **베이스라인 정보 로드**: 매칭된 템플릿의 `.claude/agents/` 및 `.claude/skills/` 데이터를 로드합니다.
4. **타겟 플랫폼 판별 및 네임스페이스 결정**: 사용자의 명시적 플랫폼 지시(예: "Claude용", "Gemini용", "ChatGPT용")를 판별하여 배포 대상 네임스페이스 폴더와 메타데이터 파일명을 다음과 같이 동적 매핑합니다.
   - **Claude**: `.claude/` 폴더 구성 및 `CLAUDE.md` 명세서 생성
   - **Gemini**: `.gemini/` 폴더 구성 및 `GEMINI.md` 명세서 생성 (기본값)
   - **ChatGPT / OpenAI**: `.openai/` 폴더 구성 및 `OPENAI.md` 명세서 생성

### Phase 2: [필수] 스캐폴딩 계획서 제안 및 사용자 승인
* **계획서 출력**: 파일 생성 작업(`write_to_file`)을 수행하기 전에, **반드시 아래 양식의 "스캐폴딩 계획 보고서"를 작성하여 사용자에게 보여주고 승인을 구해야 합니다.** (참고: 스캐폴딩 뼈대 생성이나 중단 복구 등은 필수 승인을 받지만, 이후 작업 시 하위 에이전트 교대(ICIP), 상태 저장(CRP), 메모리 압축(TCM), 목표 반복 핑퐁(FGM) 등은 사용자 피로도 감소를 위해 시스템이 자동 전개합니다.)
  ```markdown
  ### 📋 GG-Agentic-Harness-Foundry 스캐폴딩 계획 보고서
  - **매칭 템플릿**: `harness-100` 하위의 `[매칭된 폴더명]`
  - **배포 타겟 경로**: `[사용자 프로젝트 루트 경로 및 생성될 하위 폴더 구조]`
  - **생성될 에이전트 목록**:
    - `agents/[에이전트A].md` - [역할 설명]
    - `agents/[에이전트B].md` - [역할 설명]
  - **주입될 거버넌스 레이어**:
    - **ICIP**: 목적 앵커 (`00_purpose_anchor.md`), 분기 맵 (`01_branch_map.md`)
    - **CRP**: 체크포인트 (`checkpoint.json`), 의사결정록 (`Decision Log`)
    - **TCM**: 30%/50% 자동 컨텍스트 압축 (Compaction)
    - **EPR & REE**: 오류 방지 및 MUST 규칙 프롬프트 자동 주입
    - **FGM**: /goal 자율 수정 실행 루프 및 실시간 상태판 (`goal_status.md`)
  ```
* **승인 확인**: 사용자가 **"승인합니다"**, **"시작해줘"**, **"Y"** 등의 명시적인 동의 의사를 표현한 경우에만 다음 Phase로 진행합니다. 사용자가 수정을 원할 경우 계획을 수정하여 다시 승인을 요청합니다.

### Phase 3: 에이전트 프롬프트 개선 (EPR & REE 주입)
불러온 모든 개별 에이전트 정의 파일(`agents/{agent_name}.md`)에 아래의 공통 거버넌스 가이드라인 프롬프트를 주입하여 학습 및 검증 루프를 강제합니다.

```markdown
## 🛡️ GG-Agentic-Harness-Foundry Governance Guidelines
- **EPR 사전 점검**: 작업을 시작하기 전, 반드시 EPR(오류 패턴 레지스트리)을 조회하여 이전 유사 작업에서 발생한 오류 패턴을 확인하고 회피하십시오.
- **REE 규정 준수**: 이 프로젝트에 정의된 MUST 규칙(예: 모든 보고서에 출처 명시, 요약 TL;DR 기재 등)을 프롬프트에 주입하고, 산출물 생성 시 반드시 준수하십시오.
- **결정로그 기록**: 중요한 기술적 의사결정을 내렸을 경우, 그 사유(Reason)를 명확히 구조화하여 Main 오케스트레이터에 전달하십시오.
```

### Phase 4: 오케스트레이터 고도화 (FGM, ICIP, CRP, TCM, REE 믹스인)
템플릿 원본의 오케스트레이터 스킬 파일(`skills/{orchestrator}/skill.md`)의 제어 흐름에 `integration/orchestrator-enhanced.md` 템플릿을 결합하여 다음 과정을 기동하는 **자율 제어 루프**를 설계합니다.

1. **Phase 0: EPR & REE Pre-flight**: 작업 시작 전 EPR 오류 검색 및 REE MUST 규칙 체크리스트 로드.
2. **Phase 1: ICIP 목적 앵커링**: `_workspace/00_purpose_anchor.md` 생성 및 분기 맵(`01_branch_map.md`) 설계.
3. **Phase 3: FGM 자율 실행 및 게이트 평가**:
   - `goal_status.md` 모니터링판 및 `goal_status.json` 상태 메타데이터 생성.
   - `While current_iteration <= max_iterations` 루프 가동.
   - 루프 내에서: 에이전트 실행 -> ICIP 성공 기준 게이트 평가 -> REE Post-flight 규정 준수 감사 실행.
   - 만족도 100% 충족 시 루프 탈출. 미달 시 실패 보고를 피드백 프롬프트에 동적 주입하고 이터레이션 반복.
4. **TCM Compaction 트리거**: 이터레이션 및 턴 횟수 누적에 따른 Soft(30%), Hard(50%) Compaction 기동.
5. **CRP 체크포인트**: 각 루프/Phase 완료 시 상태 메타데이터를 `checkpoint.json`에 영구 기록.

### Phase 5: 타겟 배포 (Target Deployment)
- 결정된 플랫폼의 하네스 폴더(`.gemini/` 또는 `.claude/` 또는 `.openai/`)를 생성하고 고도화된 하네스 소스 코드를 지정된 **사용자 프로젝트 루트 디렉토리** 하위에 기록합니다.
- **배포 툴 원칙**: terminal command(`run_command`, `mkdir`, `echo` 등)를 실행하면 사용자에게 개별 권한 승인을 묻게 되므로, **절대 run_command를 쓰지 말고, 네이티브 도구인 `write_to_file`만을 사용하여 지정된 루트 폴더와 파일들을 백그라운드에서 직접 생성**하십시오.
- **Initial Git Snapshot**: 파일 배포가 완전히 끝난 직후, 백그라운드 명령어(run_command)를 호출하여 해당 루트 디렉토리에서 `git init`, `git add .`, `git commit -m "Initial Scaffolding Commit"`을 강제 수행합니다. 이는 CRP의 복구 시스템이 동작하기 위한 초기 베이스라인입니다.

---

## 2. 배포 디렉토리 규격

스캐폴딩이 완료되면 작업 폴더는 선택한 플랫폼에 따라 다음 구조를 갖춰야 합니다.

```
{target_project}/
├── .gemini/ 또는 .claude/ 또는 .openai/
│   ├── GEMINI.md 또는 CLAUDE.md 또는 OPENAI.md   # 플랫폼 사양 명세서
│   ├── agents/
│   │   ├── {agent-1}.md             # Governance 지침이 주입된 에이전트
│   │   └── {agent-2}.md
│   └── skills/
│       └── {domain}-orchestrator/
│           └── SKILL.md             # FGM 자율 루프 및 6대 시스템이 믹스인된 오케스트레이터
```

---

## 3. 에이전트 작동 지침
사용자가 하네스 스캐폴딩을 요구하거나, 특정 프로젝트의 자율 에이전트 구성을 원할 경우:
1. `harness-100` 라이브러리를 탐색해 가장 유사한 도메인 템플릿을 식별하고,
2. 본 스킬 문서에 기술된 개선 주입(Injection) 가이드를 따라 에이전트 및 오케스트레이터를 작성하고,
3. 사용자가 지정한 폴더에 `write_to_file` 도구를 활용해 소스 파일들을 완전 배포한 후,
4. 배포 완료 내용과 구동 명령어 가이드를 사용자에게 깔끔하게 브리핑하십시오.
