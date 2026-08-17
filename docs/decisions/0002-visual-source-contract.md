# 0002. 현재 디자인을 보존하는 시각 값 계약

## 상태

채택 — 2026-08-16

## 결정

Runtime Kit의 현재 골든을 시각 기준선으로 유지한다. `components`, `patterns`, `layout`에서는
직접 색상, 글자 크기, 간격, 크기, 곡률, 선 굵기, 투명도, 지속 시간을 만들지 않는다. 반복되거나
컴포넌트의 정체성을 정하는 값은 foundation의 의미형 계약으로 승격한다.

- `RoutexStroke`: hairline과 선택·focus emphasis
- `RoutexContentMeasure`: 스크롤 option과 dialog의 읽기 폭
- `RoutexOpacity`: subtle outline과 sheet handle
- `RoutexOpticalCorrection`: glyph live-area 보정
- `RoutexFeedbackTiming`: 결과 문장을 읽는 시간
- `RoutexProportion`: skeleton line과 확장 시트가 부모에서 차지하는 비율
- `RoutexTypography.scrollLayoutTextScale`: 균등 배치에서 스크롤 배치로 전환하는 기준

값을 옮길 때 숫자를 바꾸지 않는다. 변경 전후 Showcase 골든 파일의 SHA-256이 모두 같아야 한다.
새 디자인은 별도 변경으로 검토하며 시스템화 작업에 섞지 않는다.

## 자동 경계

`routex_source_contract_test.dart`가 제품 컴포넌트 디렉터리의 직접 시각 값을 검사한다. 새 값이
필요하면 테스트를 우회하지 않고 foundation 또는 이름 있는 component geometry 계약을 먼저 만든다.
데이터가 전달하는 브랜드 accent는 `RoutexBadgeAccent`처럼 명시된 입력 계약을 사용한다.

`Transform.translate`는 일반 정렬 수단으로 금지한다. 허용된 예외는 `RoutexSheetHeader`와 장소
상세의 right glyph뿐이다. 수학적 상자 중심이 아니라 glyph의 보이는 중심을 맞추며, 좌표 테스트로
고정한다. 아이콘 세트·글꼴이 정규화된 live area를 제공하거나 공통 glyph frame을 공유하면 각 예외와
allowlist를 함께 제거한다.

`RoutexInfoRow`는 16/24 본문 줄과 20dp 아이콘을 한 줄로 놓을 때 아이콘이 낮게 보이는
차이를 `RoutexOpticalCorrection.infoRowIconTop` 2dp로 보정한다. `routex_visual_spec_test.dart`가
값 글리프와 아이콘 중심을 함께 검증하며, 글꼴 또는 아이콘 세트가 바뀌면 이 값을 다시 재고
불필요해지면 제거한다.

`RoutexSectionHeader`는 48dp 보조 action 버튼에서 한글 glyph가 아래로 쏠려 보이는 차이를
`RoutexOpticalCorrection.sectionHeaderActionLabelTop` 2dp로 보정한다. `routex_visual_spec_test.dart`가
label line box와 버튼의 상대 위치를 검증한다. 짧은 label은 hover·pressed 배경의 수평 중심에 두고,
카드 끝선은 글리프가 아니라 48dp 터치 상자가 맡는다. 글꼴 또는 버튼의 glyph frame이 바뀌면 이 값을
다시 재고 불필요해지면 제거한다.

## 결과

화면별 미세 보정이 공통 규칙처럼 확산되는 것을 막는다. foundation의 숫자는 여전히 실제 시각 값을
가져야 하지만, 이름·역할·검증 없이 개별 요소 안에 숫자가 숨어 있지는 않게 된다.
