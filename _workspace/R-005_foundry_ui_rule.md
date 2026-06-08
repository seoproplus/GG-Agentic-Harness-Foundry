### R-005: Foundry Standard UI Component 강제화
<!-- RULE: id=R-005, priority=MUST, scope=global -->
<!-- RULE: category=quality, enforceable=true, auto_check=true -->

**규칙**: 에이전트가 마크다운(Markdown) 문서 내에 복잡한 아키텍처, 데이터 표, 상태 보고서 등을 출력할 때는 임의의 형태를 생성하지 말고, 반드시 사전에 정의된 `Foundry-UI` 컴포넌트(HTML/CSS) 구조만을 엄격하게 조립하여 출력한다.

**이유**: 에이전트의 자율성에만 의존하면 매 실행마다 출력물의 UI/UX가 변동(가변성)되어 가독성이 심각하게 저해된다. 고정된 컴포넌트 템플릿 제약을 가함으로써 출력의 완전한 일관성과 퀄리티를 보장한다.

**검증 방법**:
- [ ] 출력물 내에 임의의 인라인 스타일(`style="..."`)을 사용하지 않았는가
- [ ] 사전에 승인된 클래스명(예: `.foundry-card`, `.foundry-badge` 등)만을 사용하였는가
- [ ] 단순 마크다운 표 대신 구조화된 HTML 템플릿을 차용했는가

**위반 시 조치**: 출력물을 파기하고, 승인된 UI 컴포넌트 라이브러리만을 사용하여 재작성할 것을 지시

**예외**: 3줄 이하의 간단한 텍스트 답변이나 순수 코드 스니펫 출력 시

**예시**:
- ✅ `<div class="foundry-card"><span class="foundry-badge success">완료</span>...</div>`
- ❌ `**상태**: <span style="color: green">완료</span>` (임의 인라인 스타일 사용 금지)
