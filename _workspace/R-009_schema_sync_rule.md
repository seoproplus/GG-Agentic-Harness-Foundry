### R-009: 명세 갱신 시 JSON 스키마·버전 동기화 의무화
<!-- RULE: id=R-009, priority=MUST, scope=project -->
<!-- RULE: category=quality, enforceable=true, auto_check=true -->
<!-- PROMOTED: epr_id=EP-0001, trigger_count=5 -->

**규칙**: 코드베이스 내 시스템 목록, 아키타입, 버전 번호 등 핵심 개념을 추가하거나 갱신할 때, 반드시 해당 개념을 **JSON 스키마 형태로 재정의하고 있는 모든 파일**과 **버전 번호를 직접 표기하고 있는 모든 파일**을 동시에 갱신한다.

**이유**: 외부 명세 파일만 갱신하고 내부 JSON 스키마(예: `systems_to_activate`, `archetype` 필드)나 버전 번호 표기를 방치하면, 에이전트가 구판 스키마를 기준으로 하네스를 설계하거나 버전 불일치를 일으킨다. 이 패턴이 5회 발생(EP-0001)하여 규칙으로 승격.

**검증 방법**:
- [ ] 새 시스템을 추가할 때 `intent-engine/SKILL.md`의 `systems_to_activate` 필드를 갱신했는가
- [ ] 새 아키타입을 추가할 때 `intent-engine/SKILL.md`의 `archetype` 필드 타입을 갱신했는가
- [ ] 버전을 올릴 때 `foundry-info/SKILL.md`, `docs/architecture.md`, `scratch/harness-100-improvements.md` 모두를 갱신했는가
- [ ] 작업 완료 후 `/health-check`로 교차 검증을 수행했는가

**위반 시 조치**: 갱신이 누락된 파일을 즉시 동기화하고, EPR의 EP-0001 `last_triggered`와 `trigger_count`를 갱신

**예외**: 내용 변경 없이 주석/오탈자만 수정하는 경우

**영향 파일 목록** (변경 시 동시 점검 대상):
- `systems/intent-engine/SKILL.md` — `archetype`, `systems_to_activate` 필드
- `systems/foundry-info/SKILL.md` — 시스템 목록, 버전
- `docs/architecture.md` — 버전, 시스템 연동 맵
- `scratch/harness-100-improvements.md` — 헤더 버전
- `integration/orchestrator-enhanced.md` — 활성화 시스템 체크박스

**예시**:
- ✅ FGM 추가 → `orchestrator-enhanced.md` + `intent-engine systems_to_activate` + `foundry-info 시스템 목록` 동시 갱신
- ❌ FGM 추가 → `orchestrator-enhanced.md`만 수정, 나머지 방치 (EP-0001 재발)
