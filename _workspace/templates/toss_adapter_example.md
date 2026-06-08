<!-- 
이 파일은 DDFG Publisher가 toss_design.md 가이드라인을 참조하여
금융 종목 분석 데이터를 어떻게 토스 컴포넌트로 조립(Assembly)해야 하는지 보여주는 어댑터 예시입니다. 
-->

<div class="toss-app-frame">
  <!-- 상단 네비게이션: toss_design.md 의 TopBar -->
  <TopBar title="테슬라 (TSLA)" backButton={true} />

  <!-- 금융 데이터 강조: tabular-nums 및 proportional-nums 혼합 사용 지침 반영 -->
  <div class="hero-section" style="padding: 24px 20px;">
    <h2 class="title-1">현재가</h2>
    <div class="display-1" style="font-feature-settings: 'pnum'">$250.00</div>
    <!-- 뱃지가 아닌 일반 텍스트 위계, 증감은 브랜드 컬러 사용 규정 -->
    <span class="body-2 text-brand">+2.50 (+1.01%)</span>
  </div>

  <div class="divider" style="height: 12px; background: var(--tds-bg-secondary);"></div>

  <!-- 투자 의견 요약: 토스의 ListRow 컴포넌트 활용 -->
  <div class="section-container" style="padding: 20px;">
    <h3 class="title-2" style="margin-bottom: 16px;">AI 애널리스트 의견</h3>
    <ListRow 
      left={<Badge type="warning">HOLD</Badge>} 
      title="단기 보유를 권장해요" 
      subtitle="최근 변동성이 커지고 있어요."
    />
  </div>

  <!-- 핵심 분석 요약: 카드 UI 및 해요체 적용 -->
  <div class="section-container" style="padding: 20px;">
    <h3 class="title-2" style="margin-bottom: 16px;">주요 포인트</h3>
    <div class="card" style="border-radius: var(--tds-radius-xl); background: var(--tds-bg-secondary); padding: 16px;">
      <p class="body-2 text-primary">
        1. 3분기 실적이 기대치를 약간 하회했어요.<br>
        2. 사이버트럭 양산 이슈가 리스크로 작용할 수 있어요.<br>
        3. 장기적인 관점에서는 긍정적인 모멘텀이 있어요.
      </p>
    </div>
  </div>

  <!-- 하단 고정 액션: BottomCTA 컴포넌트 -->
  <BottomCTA onClick="trade()">
    매수하기
  </BottomCTA>
</div>
