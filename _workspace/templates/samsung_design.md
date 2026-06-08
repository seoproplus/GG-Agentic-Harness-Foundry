---
name: 삼성전자 (Samsung Design Identity 5.0)
slug: samsung_di5
category: general_corporate
last_updated: "2026-06-08"
created_at: "2026-06-08"
sources:
  - https://design.samsung.com/kr/contents/design-identity-5/
related_services: [Samsung Global, Corporate Design]
lang: ko
logo: https://getdesign.kr/logos/samsung.png
---

# 삼성전자 (Samsung) — samsung_design.md

> 본 문서는 2030년을 향한 삼성전자의 최신 디자인 철학인 **Design Identity 5.0 (DI 5.0)**을 DDFG 시스템 규격으로 캡슐화한 가이드라인입니다. 퍼블리셔 에이전트는 기계적이고 뻔한 블록 조립을 벗어나, **"목적 있는 혁신(Purposeful Innovation)"**을 바탕으로 Essential, Innovative, Harmonious의 3가지 핵심 축을 출력물에 엄격히 렌더링해야 합니다.

## 1. Design Philosophy (3대 핵심 축)

퍼블리셔는 화면 구성 시 아래 3가지 철학을 반드시 점검해야 합니다.

*   **Essential (본질)**: "군더더기를 제거한 심플하고 명확하며 직관적인 디자인."
    *   적용 룰: 배경색으로 영역을 구분하는 카드(Card) 뷰 남용을 금지합니다. 완전한 순백의 공간(`white`)에 **여백(Spacing)**과 **타이포그래피 위계**만으로 정보 그룹을 나눕니다.
*   **Innovative (혁신)**: "지금까지 없었던 차별화된 경험과 가치."
    *   적용 룰: 전통적인 표(Table) 형식의 딱딱한 나열을 지양합니다. 숫자가 중요하다면 숫자를 화면 절반 크기로 키우는 과감하고 **독창적인 데이터 그리드(Data Grid)**를 사용합니다.
*   **Harmonious (조화)**: "사람과의 감성적 교감, 그리고 포용력."
    *   적용 룰: 차가운 직선과 모서리를 배제하고, 자연물에서 영감을 받은 **유기적인 곡선(Organic Squircle)**과 따뜻하게 스며드는 그라디언트를 보조로 사용합니다.

## 2. Colors & Typography

### Colors (포용과 신뢰)
기존의 딱딱한 회색조를 최소화하고, 순백과 깊은 브랜드 블루, 그리고 자연스러운 틴트를 활용합니다.
```yaml
white:           oklch(1.000 0.000 0)     # 메인 캔버스
black:           oklch(0.000 0.000 0)     # 강력한 타이포그래피 (대비감 극대화)
blue-essential:  oklch(0.380 0.230 260)   # 핵심 혁신 요소 및 CTA 
tint-harmonious: oklch(0.970 0.010 260)   # 조화를 나타내는 은은한 배경 틴트 (옅은 블루그레이)
```

### Typography (SamsungOne)
본질적 정보를 전달하기 위해 폰트 스케일의 간극을 크게 벌려(Contrast) 직관성을 높입니다.
```yaml
font-family: "SamsungOne Sans", "SamsungOne", -apple-system, sans-serif;

display-hero:  "56px, 700, letter-spacing: -1px"  # 핵심 메시지 (Essential)
title-innov:   "24px, 600"                        # 혁신 데이터 타이틀
body-harm:     "16px, 400, line-height: 1.7"      # 조화로운 줄간격의 본문
```

## 3. UI Components (DI 5.0 Blocks)

퍼블리셔 에이전트는 일반적인 `<ListRow>` 대신, DI 5.0의 철학이 담긴 아래 컴포넌트 조합만을 허용합니다.

### `<EssentialCanvas>`
모든 것을 담는 최상위 컨테이너입니다.
- **제약**: 배경색은 무조건 `white`이며, 내부 좌우 여백은 최소 32px을 강제하여 답답함을 없앱니다.

### `<InnovativeTypographyGrid>`
금융 데이터나 스펙을 나열할 때 표(Table)를 쓰지 않고 사용하는 타이포그래피 중심의 컴포넌트입니다.
- **구조**: 숫자는 `display-hero` 급으로 거대하게 배치하고, 설명은 숫자를 방해하지 않는 작은 사이즈로 하단에 배치합니다. 카드 선이나 테두리가 없습니다.

### `<HarmoniousVisual>`
핵심 이미지를 담거나 강조할 때 사용하는 컴포넌트.
- **구조**: 완전한 직사각형을 배제하고 둥근 원형, 혹은 비대칭 곡선(Organic Shape) 마스크를 씌워 감성적이고 부드러운 느낌을 줍니다.

### `<PurposefulCTA>`
목적 있는 혁신을 이끄는 단 하나의 행동 유도 버튼입니다.
- **특징**: 화면 하단 또는 주요 섹션 끝에 배치되며, `blue-essential` 색상의 완전한 캡슐형(Pill)을 띱니다.

## 4. Voice & Tone
- 기술이 인간을 돕는 '조화'를 위해, 차가운 시스템 어조가 아닌 **포용력 있고 정중한 평어/경어체**를 씁니다.
- "조회할 수 없습니다"가 아닌, "현재 정보를 불러오기 어렵습니다. 잠시 후 다시 연결해 주세요"와 같이 배려하는 톤을 유지합니다.
