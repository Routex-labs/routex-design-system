# Routex Design System Runtime Kit

Routex 제품 UI가 import하는 Flutter package다. semantic foundation token, 공통 컴포넌트와
Navigation의 매장 상세·목록·안내 제품 패턴을 제공한다.

색상, 타이포그래피, 간격, 곡률, 공통 metric, 지도 위 layer와 제품 motion token, 그리고
`RoutexInset`·`RoutexStack`·`RoutexCluster` 같은 layout primitive는 proposal이다. 공개
위젯 51종은 별도 예외가 없는 한 모두 beta이며 값과 API는 v1 전에 조정할 수 있다. 상태를
51번 반복해서 적지 않고, stable·deprecated 같은 예외만 시스템화 기준 문서에 기록한다.

| 구분 | 공개 컴포넌트 | 소유하는 결정 |
|---|---|---|
| 기본 | `RoutexButton`, `RoutexIconAction`, `RoutexListCell`, `RoutexChipBar`, `RoutexSectionHeader`, `RoutexDivider`, `RoutexBadge` | 행동 위계, 44dp 시각 높이, 48dp 터치 영역, 텍스트 열, 분류 필터, 묶음 제목, 묶음 경계, 상태 표시 |
| 표면·탐색 | `RoutexBottomSheet`, `RoutexTabs`, `RoutexMapControl`, `RoutexDialog`, `RoutexDisclosure`, `RoutexShowMore` | 시트 곡률·여백·handle, 탭 선택선, 지도 조작 크기, 확인 표면, 그 자리에서 펼치기 |
| 피드백·대기 | `RoutexToast`, `RoutexToastSurface`, `RoutexInlineNotice`, `RoutexSkeleton`, `RoutexSkeletonList` | 되돌릴 것 없는 결과, 되돌리기가 붙는 결과, 아직 오지 않은 콘텐츠의 자리 |
| 상세 콘텐츠 | `RoutexInfoRow`, `RoutexKeyValueRows`, `RoutexMediaCarousel`, `RoutexPhotoGrid` | 사실 한 줄과 복사, 라벨-값 표, 대표 사진과 사진 격자 |
| 입력·설정 | `RoutexSearchBar`, `RoutexTravelModeBar`, `RoutexRoutePlanner`, `RoutexFloorSelector`, `RoutexSortMenu`, `RoutexSwitchRow` | 검색 진입, 출발·도착 순서, 가용 이동수단, 층 선택, 정렬 기준, 값 하나 켜고 끄기 |
| 장소 패턴 | `RoutexPlaceHeader`, `RoutexPlaceActions`, `RoutexHours`, `RoutexMenuList`, `RoutexLinkList`, `RoutexResultList` | 장소 정보와 공유·저장, 출발·도착 위계, 영업 상태와 요일 표, 판매 목록, 외부 채널, 목록의 세 상태 |
| 안내 패턴 | `RoutexManeuverBanner`, `RoutexRouteOption`, `RoutexTripProgress`, `RoutexEtaCard`, `RoutexStepList`, `RoutexArrivalCard`, `RoutexTransitItinerary`, `RoutexTransitLegStrip` | 다음 행동, 경로 선택, 진행 정보, 출발 전 요약, 단계 목록, 도착 확인, 대중교통 후보 |
| 상태 | `RoutexInfoSection`, `RoutexEmptyState`, `RoutexStatusBanner` | 상세 설명, 빈 값, 완료·경고·오류 |

```dart
import 'package:routex_design_system/routex_design_system.dart';

MaterialApp(
  theme: RoutexTheme.light,
  home: RoutexInset(
    role: RoutexInsetRole.screen,
    child: RoutexStack(
      gap: RoutexStackGap.section,
      children: [
        const Text('저장한 장소'),
        RoutexButton(label: '길찾기', onPressed: startRoute),
      ],
    ),
  ),
);
```

## 소비 규칙

- primitive 색 이름과 숫자는 `src/theme/routex_palette.dart`에만 두고 barrel에서 내보내지
  않는다. 새 테마는 팔레트가 아니라 semantic token 매핑을 교체해서 만든다.
- `components/`는 도메인과 무관한 재사용 컴포넌트, `patterns/`는 내비게이션 제품 패턴이다.
  소비자는 barrel 하나만 import하므로 이 경계는 재사용 반경과 안정화 속도를 구분하기 위한
  것이다.
- 제품은 `RoutexColorTokens`, `RoutexTypography`, `RoutexSpacing`, `RoutexRadii`,
  `RoutexMetrics`, `RoutexLayer`, `RoutexMotion`의 semantic 역할을 사용한다.
- Showcase 같은 진단 도구는 `RoutexColorRole.values` 등 공개 catalog를 순회하며 목록과 값을
  복사하지 않는다.
- 지도 foundation도 `RoutexMapVisualRole.values`와 `resolve()`를 사용한다. 지도 canvas·구조물·
  경로·마커의 색은 제품 semantic color와 섞지 않는다.
- 14px 텍스트는 굵기로 역할이 갈린다. 보조 본문은 `RoutexTypography.bodySmall`,
  칩·배지·보조 액션은 `RoutexTypography.label`을 사용한다.
- 남은 거리·시간·층처럼 값이 실시간으로 바뀌는 텍스트는 `RoutexTypography.tabular(...)`로
  감싸 고정폭 숫자를 켠다. 크기·굵기를 바꾸지 않는 유일한 typography 변형이다.
- 현재는 light theme만 지원한다. 검증되지 않은 자동 반전 dark theme은 제공하지 않는다.
- 텍스트와 주요 action 조합은 WCAG 2.2 AA 4.5:1을 테스트로 고정한다.
- 컨트롤의 시각 높이는 compact 32dp, standard 44dp, 검색 줄 52dp 역할을 쓴다. 누르는
  영역은 시각 크기와 별개로 최소 48dp다. 작은 부모가 `IconButton`의 padded tap target을
  잘라서도 안 된다.
- 아이콘은 `RoutexIcons`의 의미를 쓴다. 화면이 `Icons.*`에서 글리프를 직접 고르지 않는다.
  분류·시설처럼 데이터에서 오는 아이콘만 소비 앱이 소유한다.
- focus 결과는 한 가지 모양으로 강제하지 않는다. 경계가 있는 커스텀 표면은
  `RoutexFocusRing`, Button·IconButton·TextField·Tab 같은 Material 컨트롤은 theme의 옅은
  focus state layer나 입력 표시를 쓴다. 둘 다 `focusRing` token에서 파생하고 selected·hover와
  눈으로 구분되어야 한다.
- 시각 사양(높이·곡률·정렬·상태색)은 `test/routex_visual_spec_test.dart`가 값으로 고정한다.
  규칙을 문서에만 두면 구현이 조용히 어긋난다.
- 상단 바 왼쪽 자리는 비우지 않는다. `RoutexSearchLeading.menu` 또는 `.back` 중 하나를
  반드시 넘긴다.
- 일반 카드·패널·지도 chrome의 색·경계·깊이는 `RoutexSurfaceRole`(flat/outlined/onMap/
  chrome), 내용 구조에 따른 곡률은 제한된 `RoutexSurfaceShape`(field/card)로 고른다. 임의
  radius·elevation·border는 받지 않는다. 상태 배너·안내 배너·토스트·시트처럼 의미 자체가
  표면 구조를 정하는 전문 컴포넌트는 예외이며, 공개 token만 써서 자기 구조를 소유한다.
  전체 화면 dim·전환은 Surface variant가 아니라 앱이 `RoutexLayer.overlay`로 조합한다.
- 지도 위 경로선·마커·도면 색은 `RoutexMapVisualTokens`에서 읽는다. 제품 semantic token과
  다른 층이며 서로 값을 공유하지 않는다. 값의 출처는 Navigation의 `map_route_style.dart`다.
- 반복되는 화면 여백, 세로 간격과 컨트롤 묶음은 `Padding`, `Column`, `Wrap`을 조합하지 않고
  `RoutexInset`, `RoutexStack`, `RoutexCluster`의 semantic role로 표현한다.
- 지도 위 오버레이는 `Positioned` 좌표 대신 `RoutexMapOverlay`의 slot(top, leading·trailing
  control, notice, sheet)으로 배치한다. 컨트롤은 시트 높이를 계산하지 않고 시트 위에 쌓이며,
  상단 표면은 `MediaQuery` 안전 영역을 기준으로 놓인다.
- layout primitive에는 임의 수치나 alignment를 입력할 수 없다. 새로운 반복 관계가 확인되면
  role과 실패 테스트를 먼저 추가한다.
- 목록을 좁히는 분류 필터는 `RoutexChipBar`, 상호배타적인 전체 선택지를 균등 폭으로 보여주는
  자리는 `RoutexTravelModeBar`를 사용한다. 두 역할을 한 컴포넌트로 합치지 않는다.
- 목록 묶음의 제목과 "전체 보기" 같은 보조 동작은 `RoutexSectionHeader`가 소유한다. 이 줄에
  주 행동을 넣지 않는다. 한 목록 안의 구획 라벨은 `RoutexSectionHeaderLevel.group`을 쓴다.
- 시트의 뒤로·제목·닫기는 `RoutexSheetHeader`를 `RoutexBottomSheet.header`에 넘겨 만든다.
  본문에서 제목 줄을 다시 조립하지 않는다. `trailing`에는 화면을 바꾸지 않는 버튼만 온다.
- 시트 handle은 실제로 끌어 확장할 수 있는 소비 화면만 `showHandle: true`로 켠다. 기본값은
  false이며 고정 카드·검색 결과·고정 높이 목록의 위쪽 여백 장식으로 사용하지 않는다.
- 지도에 보이는 대상을 좁히는 칩은 `RoutexMapOverlay.filters`에 `RoutexChipSurface.onMap`으로
  둔다. 목록을 좁히는 칩은 그 목록이 있는 시트 안에 `inSheet`로 둔다.
- 장소·검색 결과 행은 `RoutexListCell`을 사용한다. 현재 beta 계약은 leading 유무와 관계없이
  leading column을 예약하며 임의 padding, TextStyle 또는 커스텀 leading 위젯을 받지 않는다.
- 위 표의 컴포넌트는 역할에 필요한 내용과 상태만 받는다. 소비자가 padding, 높이, 곡률,
  글꼴을 넘겨 외형을 바꾸는 API는 추가하지 않는다.
- 화면 상태, API adapter와 지도 controller는 소비 앱이 연결한다. Runtime Kit 컴포넌트는
  도메인 객체나 네트워크 응답에 의존하지 않는다.
- 이동수단 선택기는 소비 앱이 전달한 가용 수단만 표시한다. 하나뿐이면 숨기며, 큰 글자에서도
  세로로 접지 않고 한 줄의 내부 스크롤을 사용한다.

카메라 이동, 파티클, 영상 타임라인, 장면 연출과 프로모션 asset은 이 package에 넣지 않는다.
제품 앱의 domain model, MapLibre controller와 Dijkstra도 소비 앱이 소유한다.

실패 조건과 자동 검증 범위는
[`../../docs/system-contract.md`](../../docs/system-contract.md)를 따른다.
장소 공유·신상품 필터·안내 상태와 Navigation 앱 연결 계약은
[`../../docs/place-detail-guidance-decisions.md`](../../docs/place-detail-guidance-decisions.md)를 따른다.
현재 디자인을 유지하면서 시각 값을 시스템화하는 규칙과 자동 검사는
[`../../docs/decisions/0002-visual-source-contract.md`](../../docs/decisions/0002-visual-source-contract.md)를 따른다.
Navigation 원본 코드의 상태·gesture·지도 책임을 보존하며 실제로 포팅하는 단계와 실패 기준은
[`../../docs/navigation-app-porting-guide.md`](../../docs/navigation-app-porting-guide.md)를 따른다.
