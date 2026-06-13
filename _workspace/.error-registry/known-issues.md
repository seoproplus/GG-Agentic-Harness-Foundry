# GG-Agentic-Harness-Foundry — 프로젝트 레벨 Known Issues

이 파일은 EPR(Error Pattern Registry)의 프로젝트 레벨 오류 패턴을 기록한다.
REE Pre-flight Check 시 이 파일이 자동으로 스캔되어 사전 경고가 발령된다.

---

### EP-0001: 외부 명세 갱신의 내부 JSON 스키마/버전 미전파 드리프트
<!-- EPR: id=EP-0001, level=project, severity=high -->
<!-- EPR: created=2026-06-13, last_triggered=2026-06-13, trigger_count=5 -->
<!-- PROMOTED: rule_id=R-009 -->

**증상**: 아키텍처 문서(`architecture.md`), 통합 템플릿(`orchestrator-enhanced.md`), `foundry-info/SKILL.md` 등 외부 명세 파일을 갱신할 때, 동일한 개념을 참조하는 **내부 JSON 스키마 필드**(예: `systems_to_activate`, `archetype`)나 **버전 번호 표기**(예: `v1.4.0` 잔존)까지 함께 갱신하지 않아 불일치가 발생함.

**근본 원인**: 변경 작업이 "추가/수정하는 파일"에만 집중되고, 같은 개념을 **JSON 스키마 형태로 재정의하고 있는 다른 파일**까지 전파 확인을 하지 않는 단방향 편집 습관. 버전 번호도 주 파일만 올리고 나머지 참조 파일의 버전 표기는 방치됨.

**잘못된 접근**:
```
외부 명세(orchestrator-enhanced.md)에 FGM 시스템 추가
→ intent-engine/SKILL.md의 JSON 스키마 내 systems_to_activate는 그대로 방치
→ health-check에서 불일치 발견
```

**올바른 접근**:
```
외부 명세(orchestrator-enhanced.md)에 FGM 시스템 추가
→ "이 개념을 JSON 스키마로 정의한 파일이 있는가?" 자동 전파 확인
→ intent-engine/SKILL.md의 systems_to_activate 동시 갱신
→ /health-check로 교차 검증
```

**탐지 조건**: 다음 상황에서 이 패턴이 재발할 수 있다.
- 트리거 키워드: [`시스템 추가`, `시스템 목록`, `버전`, `v1.`, `아키타입`, `archetype`, `systems_to_activate`, `페르소나`, `명세`, `스키마`]
- 관련 파일: [`systems/intent-engine/SKILL.md`, `systems/foundry-info/SKILL.md`, `docs/architecture.md`, `scratch/harness-100-improvements.md`, `integration/orchestrator-enhanced.md`]

**적용 범위**: GG-Agentic-Harness-Foundry 코드베이스의 모든 변경 작업. 특히 새 시스템/아키타입/버전을 추가하거나 기존 명세를 갱신하는 모든 경우.

**✅ REE 승격 완료**: R-009로 승격 완료 (2026-06-13)
