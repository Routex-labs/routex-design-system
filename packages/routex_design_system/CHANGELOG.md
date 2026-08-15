## Unreleased

### v0.2 — 매장 상세·목록·안내 역할 보강

Navigation 앱과 대조해 **Runtime Kit에 없던 역할**을 채웠다. 기준은 "앱이 그 역할을 사설
위젯으로 다시 그리고 있는가"다. 지도 painter·마커·상태 머신처럼 앱 계층에 남는 것은
그대로 뒀다.

- `RoutexToast`/`RoutexToastSurface` 추가. 저장·복사·열기 실패의 결과를 말하는 자리가
  없어서, 앱은 시트에 가려 보이지 않는 SnackBar를 쓰고 있었다. 루트 Overlay에 한 개만
  띄우고 포인터는 통과시킨다. 되돌리기가 붙는 알림은 계속 `RoutexInlineNotice`다
- `RoutexDialog`와 `showRoutexDialog` 추가. 확인이 필요한 dialog만 바깥 누르기를 막는다 —
  되돌릴 수 없는 동작 앞에서 실수로 닫는 것과 취소하는 것을 사용자가 구분하지 못한다
- `RoutexSkeleton`/`RoutexSkeletonList` 추가. 글자 자리표시는 **글자 배율을 따라** 높아진다.
  고정 높이로 두면 200% 배율에서 값이 도착한 뒤 줄 높이가 두 배로 뛴다
- `RoutexHours` 추가. 판정("영업 중")은 소비 앱의 순수 함수가 하고 컴포넌트는 문장으로만
  바꾼다. 판정할 수 없을 때 "영업 종료"로 떨어뜨리지 않는다 — 열려 있는 매장을 돌려보내는
  것이 이 섹션이 만들 수 있는 가장 비싼 거짓말이다
- `RoutexMenuList`, `RoutexInfoRow`, `RoutexKeyValueRows`, `RoutexLinkList`,
  `RoutexMediaCarousel`, `RoutexPhotoGrid` 추가. 상세 시트를 이루는 조각이 전부 앱 안에만
  있어서, 같은 매장이 화면마다 다른 모양으로 그려질 수 있었다
- `RoutexResultList` 추가. **"찾는 중"과 "찾지 못했어요"를 다른 상태로 못박는다.** 1차 검색이
  빈손이라고 최종 결론을 띄우면 사용자는 앱이 못 찾는다고 읽는다
- `RoutexSortMenu` 추가. 쓸 수 없는 정렬 기준을 감추지 않고 이유를 함께 적는다
- `RoutexSwitchRow`, `RoutexDivider`, `RoutexBadge`, `RoutexDisclosure`, `RoutexShowMore`,
  `RoutexPlaceActions` 추가. 설정 줄, 묶음 경계, 상태 표시, 펼치기와 출발·도착 한 쌍이
  화면마다 다시 만들어지던 자리다
- `RoutexEtaCard`, `RoutexStepList`, `RoutexArrivalCard`, `RoutexTransitItinerary`,
  `RoutexTransitLegStrip` 추가. 계획·단계·도착·대중교통 후보는 안내 축에서 통째로 비어 있었다
- `RoutexPlaceHeader`에 `supportingIcon` 추가. "어디인가" 다음 줄인 "어떻게 닿는가"(도보 4분)를
  글리프와 함께 적는다
- `RoutexMetrics`에 `thumbnail`(72)과 `mediaBand`(200) 추가. 행 안 사진과 상세 대표 사진이
  화면마다 다른 크기로 그려지던 값이다
- `RoutexIcons`에 영업시간·링크·사진·정렬·대중교통 수단 의미 추가
- `RoutexDialog`의 화면 여백을 Material 기본값(가로 40) 대신 `sectionGap`(24)으로 맞춤
- **`RoutexSkeleton`의 숨쉬는 애니메이션을 제거하고 멈춘 면으로 바꿈.** 자리표시 하나가 곧
  애니메이션 컨트롤러 하나라, 로딩 예시가 한 화면에 있는 것만으로 프레임이 끝없이 그려졌다
  (카탈로그 한 페이지에서 컨트롤러 18개). 아무도 보고 있지 않은 동안 기기가 계속 일한다.
  자리표시의 일은 자리를 잡는 것이고, 진행 중이라는 사실은 `RoutexResultList.loadingMessage`가
  문장으로 말한다
- 같은 이유로 `RoutexResultList`의 대기 화면에서 회전 표시를 뺐다. 자리표시·문장·회전이 같은
  상태를 세 번 알리면서 화면이 쉬지 않고 다시 그려지던 자리다

- 행의 제목 열을 `RoutexMetrics.textKeyline`(64)로 공개하고 `RoutexSheetHeader`가 뒤로
  자리를 이 폭으로 잡도록 함. 지금까지 이 값은 `RoutexListCell` 안에서만 계산돼, 같은
  시트에서 헤더 제목(68)과 행 제목(80)이 12 어긋났다
- `RoutexSectionHeader`의 보조 동작이 좌우 패딩 대신 상자 크기로 터치 영역을 만들도록 함.
  패딩으로 만들면 그만큼 글자가 안으로 밀려 패딩 없는 제목 쪽(16)과 여백이 달랐다(24)
- `RoutexListCell`의 순서 손잡이를 보조 동작과 같은 48 상자에 넣어 두 글리프 높이를 맞추고,
  색을 `contentSecondary`에서 `borderStrong`으로 내림. 손잡이는 누르는 컨트롤이 아니라
  잡는 자리를 알리는 장식이라 보조 동작과 같은 무게로 읽히면 안 된다
- 지도 foundation을 `RoutexMapVisualRole` catalog로 공개해 Showcase가 도면·경로·마커
  색 목록을 복사하지 않도록 함
- 공통 의미 아이콘에 이동 안내·메뉴·사진 역할을 추가해 Showcase와 제품 패턴이 `Icons.*`를
  직접 고르지 않도록 함
- foundation을 color, typography, spacing, radius, metric, layer, product motion 역할로 분리
- Showcase가 직접 값 목록을 복사하지 않도록 semantic role catalog 추가
- 360/390px·2배 글자 fixture 검증 추가
- WCAG AA 대비를 `routex_contrast_test`로 분리하고 글자 4.5:1과 비텍스트 3:1을 나눠 검증
  (겹치는 조합을 쌍으로 열거하므로, 새 색을 들일 때 쌍을 추가하는 것이 곧 용도를 정하는 일)
- `borderStrong`을 3:1에 맞춰 조정 (0xFF98A3B3 → 0xFF828B99). secondary 버튼의 테두리는
  그 컨트롤을 식별하는 유일한 시각 정보인데 2.55로 비텍스트 기준에 못 미쳤다
- Navigation 앱의 하늘색(0xFF4A87F1)을 `accentBrand`로 들여옴. 흰 배경 3.48이라 **글자에는
  쓰지 않고** 선·표시·테두리에만 쓴다. 글자와 글자 밑 배경은 계속 `actionPrimary`가 맡는다
- 선택된 칩을 진한 파랑 채움에서 tint + `accentBrand` 테두리 + `actionPrimary` 글자로 변경.
  지도 위 한 줄이 통째로 무거워지던 것을 덜어낸다. 탭 표시줄과 선택된 경로 카드 테두리도
  `accentBrand`로 이동
  (이동수단 바는 트랙 안 세그먼트라 채움 유지 — 옅은 트랙 위 옅은 tint는 약하게 읽힌다)
- 세로로 쌓이는 컨트롤이 폭까지 늘어나지 않도록 `RoutexStackFill` 추가 (기본값은 기존 채우기)
- 분류 칩이 고유색을 따르도록 `RoutexChipAccent`와 `RoutexChipOption.category` 추가.
  한 칩 안에서 색을 두 갈래로 쓴다 — 아이콘은 도면과 같은 파스텔 원색(`colorFor`),
  선택을 전하는 테두리·글자는 대비를 확보한 `inkFor`. 원색은 흰 배경에서 1.80~2.46이라
  선택 표시를 맡을 수 없고, 반대로 아이콘까지 톤을 낮추면 분류 줄이 도면과 색감이 갈라진다.
  아이콘은 분류 이름이 늘 옆에 있어 뜻을 혼자 지지 않으므로 원색을 그대로 쓴다
- 공통 motion에서 지도 camera·PDR·업무 timer와 Promo Studio 연출을 명시적으로 제외
- semantic inset·stack·cluster layout primitive와 수치·좌표 계약 테스트 추가
- 고정된 leading column, 상태 semantics와 2배 글자를 검증하는 `RoutexListCell` beta 추가
- 모바일 정보 위계에 맞춰 typography를 22/18/16/14/12 단계로 조정
- 밀도 높은 보조 본문을 위한 `bodySmall`(14/400) 역할 추가와 `ListCell` subtitle·
  `PlaceHeader` metadata 적용
- 남은 거리·시간·층 표면에 고정폭 숫자를 켜는 `RoutexTypography.tabular` 추가
- 지도 위 오버레이의 gutter·안전 영역·시트 기준 세로 순서를 소유하는 `RoutexMapOverlay` 추가
- 재사용 컴포넌트와 내비게이션 제품 패턴을 `components/`·`patterns/`로 분리
- primitive 색을 비공개 `RoutexPalette`로 분리하고 semantic token을 매핑으로 정리
- 분류 필터를 위한 `RoutexChipBar`와 목록 묶음 제목을 위한 `RoutexSectionHeader` 추가
- `SearchBar`의 메뉴·길찾기 보조 동작을 넘기지 않으면 누를 수 없는 자리를 남기지 않도록 변경
- 계약 test를 foundations·components·patterns·layout·theme·viewport로 분리
- 시트 header anatomy를 고정하는 `RoutexSheetHeader`와 `RoutexBottomSheet.header` slot 추가
- 목록 안 구획 라벨을 위한 `RoutexSectionHeaderLevel.group` 추가
- 지도 위 칩과 시트 안 칩을 구분하는 `RoutexChipSurface` 추가
- 지도 필터 줄을 상단 표면 아래에 두는 `RoutexMapOverlay.filters` slot 추가
- 칩·지도 버튼·아이콘 동작·경로 입력의 시각 높이를 32/44로 낮추고 48 터치 영역은 유지
- 상단 바 왼쪽 자리를 `RoutexSearchLeading`(메뉴 또는 뒤로)로 필수화
- 안내 진행 시트의 종료를 아이콘 타일에서 이름이 보이는 버튼으로 교체
- Navigation의 경로선·마커·도면 색을 `RoutexMapVisualTokens`로 들여와 지도 렌더러의
  단일 출처로 삼음 (제품 semantic token과 분리된 층)
- `SearchBar`에 입력 줄(controller/focus/onChanged/onSubmitted), 지우기, 진행 상태 추가
- 표면의 색·곡률·경계·깊이를 역할 하나로 고정하는 `RoutexSurface` 추가와 지도 위 컴포넌트 적용
- `ListCell`에 trailing 보조 동작과 순서 바꾸기 손잡이 추가 (Favorites pilot 요구사항)
- 의미와 글리프를 묶는 `RoutexIcons` 추가하고 package·Showcase의 `Icons.*` 직접 선택 제거
- 이동수단 세그먼트를 고정 폭 104에서 균등 분할로 교체 (라벨 길이에 따라 칸이 들쭉날쭉하던 문제)
- 검색 바 좌우 아이콘 자리를 48에서 44로 줄여 입력 줄과의 여백 과다 해소
- 인라인 알림의 액션 곡률을 표면과 같은 계열로 맞추고, 진행 시트의 종료를 세로 중앙 정렬된
  secondary 버튼으로 교체 (큰 글자에서는 줄을 나눔)
- focus·hover가 화면마다 Material 기본 회색이 되지 않도록 목록 행·경로 입력 칸의 tint 통일
- focus를 채움이 아닌 `focusRing` 링으로 그리는 `RoutexFocusRing` 추가와 목록 행·칩·지도
  버튼 적용 (채움은 selected·hover·pressed가 나눠 쓴다)
- 목록 셀의 leading·trailing 아이콘을 제목 첫 줄 광학 중심에 정렬
- 시트 위쪽 여백을 handle 유무에 따라 8/16으로 분기
- 시각 사양(높이·곡률·정렬·상태색)을 수치로 고정하는 `routex_visual_spec_test` 추가
- 버튼 시각 높이를 44dp로 줄이고 48dp padded tap target을 유지
- Showcase에 장소 선택부터 도착까지 조작 가능한 19.5:9 제품 UX 목업 추가
- `IconAction`, `BottomSheet`, `Tabs`, `MapControl`, `PlaceHeader`, `ManeuverBanner`,
  `RouteOption`, `TripProgress` beta 추가
- Showcase 제품 목업이 임시 UI 복제품 대신 공개 컴포넌트 10종을 사용하도록 교체
- 핵심 10종을 360/390px와 글자 배율 1.0/1.3/2.0에서 검증하는 component fixture 추가
- 검색·경로 입력·이동수단·층 선택·결과 알림·정보·빈 상태·상태 배너 제품 패턴 추가
- 가용 이동수단만 한 줄로 표시하고 선택지가 하나면 숨기는 규칙 추가
- Showcase의 가짜 휠체어 옵션과 사진 placeholder를 제거하고 실제 빈 상태로 교체

## 0.0.1

- semantic color, typography, spacing, radius, shadow, product motion token bootstrap
- package 공급 경로 검증을 위한 `RoutexButton` beta vertical slice
- theme extension, reduced-motion과 48dp touch target 검증 추가
