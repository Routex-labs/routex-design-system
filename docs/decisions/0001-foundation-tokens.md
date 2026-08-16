# 0001. Foundation token 계약

- 상태: 채택
- 결정일: 2026-08-14
- 근거: [Navigation UI 조사](../inventory/navigation-ui-inventory.md)

## 완료 판정

Foundation token은 다음 조건을 모두 만족해야 한다.

1. 제품 코드는 색상값·폰트 크기·간격·곡률·그림자·duration을 직접 고르지 않고 semantic
   role을 사용한다.
2. Showcase는 색 값과 role 목록을 복사하지 않고 Runtime Kit이 공개한 catalog를 순회한다.
3. 본문과 주요 action의 전경·배경 조합은 WCAG 2.2 AA 4.5:1 이상이다. disabled와 장식용
   표현은 별도로 구분한다.
4. 간격은 4px grid를 따르며 screen, section, component, content, control 역할을 섞지 않는다.
5. 곡률은 control, field, card, sheet, full 역할만 공개한다.
6. 크기는 compact/standard control, 48dp minimum touch target, leading column과 세 icon 역할만
   공개한다.
7. 지도 위 제품 UI는 onMap, chrome, overlay의 세 layer만 사용한다.
8. 공통 motion은 feedback, transition, emphasized와 enter/exit/standard curve만 공개하며,
   OS의 reduced-motion 요청에서 duration이 0이 된다.
9. 360px와 390px, text scale 1.0·1.3·2.0, 긴 한글에서 Showcase fixture가 overflow 없이
   렌더링된다.

## 먼저 막아야 할 실패

- 현재 Navigation의 12.5px, 13.5px, radius 10·20, gap 6·10을 새 global token으로 그대로
  승격한다.
- `blue500`, `gray100`처럼 구현 색 이름을 제품 코드에 공개한다.
- 선택·오류·경고마다 화면이 새로운 색을 만든다.
- Material 기본값과 Runtime Kit 값이 동시에 남아 컴포넌트가 어느 쪽을 따르는지 모호하다.
- Showcase가 token 이름, 상태, duration 또는 버전을 별도 상수로 복제한다.
- 지도 paint, POI·노선색, PDR·debounce·timeout을 제품 UI token으로 옮긴다.
- Promo Studio의 카메라 이동, particle, timeline, 장면 연출을 공통 motion에 넣는다.
- 360px에서만 맞고 2배 글자나 긴 한글에서 잘리거나 터치 영역이 48dp 아래로 줄어든다.

## 역할 구조

```text
private primitive
  → semantic token
    → core component
      → product pattern
        → Navigation screen
```

- private primitive는 Runtime Kit 파일 내부 구현이며 package 밖으로 export하지 않는다.
- semantic token은 역할 이름과 resolver/catalog를 함께 제공한다.
- core component는 외부에서 임의 padding, radius, text style을 받지 않는다.
- product pattern과 Navigation screen은 업무 상태와 지도 동작을 소유한다.

## 현재 범위

- light theme 한 개
- semantic color, typography, spacing, radius, metric, layer, product motion
- Runtime Kit을 실제 import하는 Alignment & Rhythm Showcase fixture
- 기존 `RoutexButton`이 새 token 계약을 소비하는지 확인하는 회귀 테스트

지도 visual token과 제품 motion은 이후 같은 계층 원칙으로 추가됐다. dark theme은 아직 범위
밖이다. 임의 반전으로 먼저 만들면 의미 검증 없이 색 조합만 두 배가 되므로 별도 대비·상태
매트릭스와 제품 검증 전에는 제공하지 않는다.
