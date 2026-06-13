### R-008: Health-Check Command Workflow (Multi-Pass Matrix)
<!-- RULE: id=R-008, priority=MUST, scope=project -->
<!-- RULE: category=workflow, enforceable=true, auto_check=true -->

**규칙**: 사용자가 `/health-check` 명령어를 입력하면, 에이전트는 직관적 단일 패스 감사를 금지하고, 반드시 **Multi-Pass(기준점 추출 -> 표적 감사) 워크플로우**를 따르며, 시각적 증거인 `health_check_matrix.md` 아티팩트를 생성하여 결정론적인 대조 결과를 보고해야 한다. 모순 수정 후에는 반드시 Zero-Drift Policy에 따라 미니 재검증을 수행한다.

**이유**: 10개가 넘는 파일을 한 번에 읽고 모든 모순을 잡아내는 것은 에이전트의 컨텍스트 한계상 불가능하며 잦은 환각/누락(Whack-a-mole)을 유발한다. 기계적인 O/X 매트릭스 작성을 강제함으로써 감사의 사각지대를 없앤다.

**검증 방법**:
- [ ] Pass 1: `foundry-info/SKILL.md` 등에서 기준점(버전, 시스템 수, 아키타입)을 명시적으로 추출하였는가
- [ ] Pass 2: 감사를 수행하는 동안 `health_check_matrix.md` 아티팩트 표를 작성하며 O/X를 시각화하였는가
- [ ] Pass 3/4: 구조화된 헬스체크 결과 보고서를 제출하였는가
- [ ] Pass 5: (모순 수정 시) 수정한 파일들에 대해 즉각적인 미니 재검증을 수행하였는가

**위반 시 조치**: 작업을 중단하고 매트릭스 아티팩트부터 다시 생성하여 기계적 대조를 처음부터 수행할 것을 지시

**예외**: 없음 — `/health-check`는 항상 다중 패스 매트릭스 방식을 강제한다.

**예시**:
- ✅ `User: /health-check` → `Agent: (Pass 1 수행) 기준점 v1.5.0 추출 완료. (Pass 2 수행) health_check_matrix.md 생성. ...`
- ❌ `User: /health-check` → `Agent: (전체 파일을 한 번에 읽고 머릿속으로 판단하여) 문제 없습니다.` (매트릭스 아티팩트 미작성 시 위반)
