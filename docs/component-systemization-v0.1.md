# v0.1 컴포넌트 시스템화 기준

Showcase 목업을 완료 기준으로 사용하지 않는다. Runtime Kit의 공개 컴포넌트를 조합해
같은 화면을 만들 수 있을 때만 디자인 시스템에 포함된 것으로 본다.

## 이번 범위

기존 `Button`, `ListCell`에 아래 8개를 더해 v0.1 **핵심 컴포넌트**는 10개로 제한한다.

1. `IconAction`
2. `BottomSheet`
3. `Tabs`
4. `MapControl`
5. `PlaceHeader`
6. `ManeuverBanner`
7. `RouteOption`
8. `TripProgress`

다만 이 제한은 Showcase 제품 UI에 사설 시각 복제품을 남긴다는 뜻이 아니다. 아래
Navigation 제품 패턴도 Runtime Kit의 공개 API로 제공한다.

1. `SearchBar`
2. `TravelModeBar`
3. `RoutePlanner`
4. `FloorSelector`
5. `InlineNotice`
6. `InfoSection`
7. `EmptyState`
8. `StatusBanner`

기기 프레임, Dynamic Island, 지도 painter, 실제 지도 controller, API adapter, Dijkstra와
화면 상태 머신은 앱 계층에 남긴다. 이들은 디자인 시스템 컴포넌트가 아니다.

## 실패 조건

아래 중 하나라도 발생하면 시스템화가 완료되지 않은 상태다.

- Showcase가 사용자에게 보이는 위 역할을 `_PrivateWidget`으로 다시 구현한다.
- 모바일 UX 목업의 단계 화면이 지도 canvas가 아닌 별도 페이지 배경을 사용하거나, 지도 위
  UI를 Runtime Kit 컴포넌트가 아닌 Showcase 사설 표면으로 다시 그린다.
- 지도 시각 계층이 없는 단계에 지도 도면·경로선·마커를 계속 그리거나, 지도 시각 계층이
  `RoutexMapVisualTokens` 대신 제품 UI semantic 색을 직접 사용한다.
- 컴포넌트 소비자가 padding, 높이, 곡률, 글꼴을 직접 넘겨 같은 역할의 모양을 바꾼다.
- 아이콘 전용 동작의 터치 영역이 48dp 미만이거나 접근성 이름이 없다.
- 한 화면에서 primary 버튼이 두 개 이상 동시에 같은 위계로 노출된다.
- 360px·390px와 글자 배율 1.0·1.3·2.0 중 하나에서 overflow 또는 잘림이 발생한다.
- 빈 값, disabled, selected, loading 중 해당되는 상태가 의미와 동작에 같이 반영되지 않는다.
- 전체 Showcase가 브라우저 viewport보다 넓어져 문서나 목업을 보기 위해 가로 스크롤해야 한다.
- 제품 UI의 글자 배율을 강제로 1.0으로 고정해 실패를 숨긴다.
- 지도·API·경로 계산이나 Promo Studio의 촬영용 요소가 Runtime Kit으로 이동한다.
- 이동수단이 두 줄 이상으로 접히거나 세로 목록으로 무너진다.
- 현재 API·도메인이 지원하지 않는 이동수단을 선택지로 표시한다.
- 이동수단이 하나뿐인데 선택 UI를 노출하거나, 사용할 수 없는 수단을 누른 뒤 오류로 막는다.
- 데이터가 없는데 가짜 사진·메뉴·경로를 placeholder 콘텐츠처럼 표시한다.

## v0.2 범위 — 매장 상세·목록·안내

v0.1은 길찾기 축을 덮었고, Navigation 앱과 대조해 보니 **매장 상세 축이 통째로 비어
있었다**. 앱의 상세 시트는 약 3,000줄인데 Runtime Kit이 가진 것은 `PlaceHeader` 하나였다.
아래는 "앱이 그 역할을 사설 위젯으로 다시 그리고 있는가"를 기준으로 들여온 목록이다.

### 피드백과 대기

1. `Toast` — 되돌릴 것이 없는 결과. 시트에 가리는 SnackBar를 대체한다
2. `Dialog` — 되돌릴 수 없는 확인과 한 항목의 자세한 내용
3. `Skeleton` / `SkeletonList` — 아직 오지 않은 콘텐츠의 자리
4. `Divider`, `Badge`, `Disclosure`, `ShowMore`

### 매장 상세

5. `PlaceActions` — 출발·도착 한 쌍의 위계
6. `Hours` — 영업 상태 한 줄과 요일 표
7. `MenuList` — 판매 목록과 접힘
8. `InfoRow` / `KeyValueRows` — 사실 한 줄과 라벨-값 표
9. `LinkList` — 외부 채널
10. `MediaCarousel` / `PhotoGrid` — 대표 사진과 사진 격자

### 목록과 안내

11. `ResultList` — 찾는 중·찾지 못함·결과 세 상태
12. `SortMenu`, `SwitchRow`
13. `EtaCard`, `StepList`, `ArrivalCard`
14. `TransitItinerary` / `TransitLegStrip`

### v0.2에서 늘어난 실패 조건

- 저장·복사·열기 실패처럼 되돌릴 것이 없는 결과를 화면이 말하지 않는다.
- "찾는 중"과 "찾지 못했어요"를 같은 상태로 그린다. 아직 시도할 경로가 남았는데 최종
  결론을 띄우면 사용자는 앱이 못 찾는다고 읽는다.
- 영업시간을 판정할 수 없는데 "영업 종료"로 떨어뜨린다.
- 사진·메뉴가 없는 매장에 그럴듯한 자리표시를 콘텐츠처럼 남긴다. 자리표시는 "무엇이 올
  것이다"만 말하고 내용은 말하지 않는다.
- 글자 자리표시가 글자 배율을 따라가지 않는다.
- 쓸 수 없는 정렬 기준을 목록에서 감추거나, 눌러 본 뒤 오류로 막는다.
- 눌러야만 볼 수 있는 컴포넌트(토스트·dialog)를 카탈로그에서 버튼 뒤에만 둔다.
- 상세의 내용을 손으로 지어낸 예시로 검수한다. Showcase의 매장 상세는 Navigation
  백엔드의 오설록 매장(`store_details/osulloc-thehyundai-seoul-b1.json`)을 그대로 쓴다.

## 완료 판정

- 10개 핵심 컴포넌트와 8개 Navigation 제품 패턴이 package 공개 API로 export된다.
- Showcase 모바일 흐름이 공개 컴포넌트를 import해 구성된다.
- 모든 제품 상태가 360/390px 및 글자 배율 1.0/1.3/2.0에서 검증된다.
- package 컴포넌트 테스트와 Showcase 전체 레이아웃 테스트가 위 실패 조건을 자동 검사한다.
- `flutter analyze`, `flutter test`, `flutter build web`이 모두 통과한다.
