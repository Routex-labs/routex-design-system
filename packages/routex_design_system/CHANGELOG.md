## 0.2.15

- `RoutexLinkDisplay.labelAndUrl` 추가. 라벨이 브랜드를 말하면서 주소도 필요한 줄이 있다
  (`오설록 공식 홈페이지`). 라벨을 주소로 덮으면 어느 브랜드인지가 사라지고, 주소를 지우면 어디로
  나가는지가 사라진다 — 둘 중 하나를 고르는 계약으로는 표현되지 않았다. 그 줄만 두 줄이 되고
  주소는 한 급 작아진다. **앱 영향:** 기본값 `label`은 이전과 같다.

## 0.2.14

- `RoutexLinkAccent.image` 추가. **로고 파일은 여전히 이 저장소가 담지 않는다** — 소비 앱이 이미
  번들에 갖고 있는 그림만 넘길 수 있게 자리만 연다. 저작권 범위가 그 매장 자산과 이미 같아진
  경우에만 쓴다. 그림이 빠지면 브랜드 배지(글리프 + 색)로 되돌아간다 — 자산 누락은 빌드가 아니라
  실행 중에 드러나므로 줄이 통째로 사라지면 안 된다. **앱 영향:** 안 주면 이전과 같다.

## 0.2.13

- 장소 헤더의 저장 action을 공유와 **같은 평면**에 뒀다. 공유만 `quiet`(배경 없음)이고 저장은
  기본 tone이라 타일 배경을 갖고 있었는데, 그건 이 저장소가 이미 적어 둔 규칙과 어긋난다 —
  "한 줄 안에서 어떤 동작만 타일을 가지면 서로 다른 컨트롤로 읽힌다". 헤더는 이미 배경을 가진
  자리라 둘 다 타일을 두지 않는다. 저장 여부는 선택 상태(틴트 배경 + 강조색 글리프)가 그대로
  드러내므로 잃는 정보가 없다. **소비 앱 화면을 폰에서 보다 눈에 띄었다.**

## 0.2.12

- `RoutexPlaceHeader.onSaved`를 선택 입력으로 바꿨다. **모든 장소가 저장되는 것은 아니다** — 저장은
  식별자를 붙잡아 두는 일이고, 그것이 없는 항목(소비 앱의 구버전 저장 항목)에는 담을 곳이 없다.
  지금까지는 필수라 그런 화면에도 토글이 남았고, 눌러도 아무 일이 없는 버튼이 된다. 같은 컴포넌트의
  `onShare`와 같은 방식으로 null이면 action을 숨긴다. `saved`도 기본값 false로 둔다.
  **앱 영향:** 저장이 되는 화면은 이전과 같다.

## 0.2.11

- `RoutexResultStatus.clarify`를 **다시 걷었다.** 0.2.8에서 셋을 함께 냈는데, 소비 앱의 검색 화면을
  실제로 옮겨 보니 되물음의 **질문은 선택지 칩 줄과 붙어 있어야** 해서 앱 헤더에 남았고, 이 목록은
  그때도 결론 목록(`ready`)이었다. 행이 없을 때 빈손 화면으로 떨어지는 것도 앱이 안내 줄 유무로
  이미 가르고 있었다. `degraded`·`error`는 소비 중이라 그대로다.
  **앱 영향:** 없다 — 이 값을 쓰던 화면이 없다.

## 0.2.10

- 한 줄짜리 목록 행의 세로 정렬을 고쳤다. **실기기에서 처음 보였다** — 최근 검색 줄의 ×가 제목보다
  한 단계 아래에 있었다. 끝 동작은 48 터치 영역을 갖는데 제목 줄은 24라, 여러 줄 기준(첫 줄 윗면에
  맞춤)을 한 줄 행에도 그대로 쓰면 글리프만 12 내려간다. `trailingIcon`은 보정을 받고 있었지만
  끝 동작과 손잡이는 아니었고, **그때까지 끝 동작을 쓰는 소비 화면이 없어 드러나지 않았다.**
  줄 수가 기준을 정한다 — 여러 줄이면 첫 줄 윗면, 한 줄이면 가운데. 터치 영역은 그대로 48이다.
  **앱 영향:** 부제·값이 있는 행은 이전과 같다. 제목만 있는 행에서 아이콘이 12 올라온다.

## 0.2.9

- `RoutexChipBar`의 `dismiss`와 `selection`을 **다시 걷었다.** 0.2.8에서 화면을 열기 전에 설계한
  둘인데, 소비 앱을 실제로 옮겨 보니 **어댑터가 이미 풀고 있었다** — 카테고리 시트는 `전체` 칩의
  id와 "선택 없음"을 이어 주고 있어서, 칩 줄이 늘 하나를 강조하는 데 새 모드가 필요 없었다.
  오히려 `required`는 "고른 소분류를 다시 눌러 전체로 돌아오는" 길을 막아 회귀를 냈다. `dismiss`가
  겨냥한 자리(고른 값이 쌓인 줄)는 **축이 여럿이라** 이 줄의 "선택은 하나" 계약으로는 애초에
  표현되지 않는다. 소비처 없는 계약은 두지 않는다는 규칙대로 지운다.
  **앱 영향:** 없다 — 0.2.8을 소비한 화면이 없다.

## 0.2.8

단계 4(검색과 결과 목록) 착수 전에 결정 넷을 한 번에 반영했다. 앞선 다섯 release는 화면을 옮기다
걸릴 때마다 하나씩 끊었는데, 그 비용이 컸다. 네 항목 모두 기본값은 이전과 같다.

- `RoutexResultStatus`에 `clarify`·`degraded`·`error` 추가. 소비 앱의 검색은 상태가 아홉인데 여기는
  셋이라, 셋에 우겨넣으면 **의미가 죽는다**. `error`를 `empty`로 그리면 "그런 곳은 없다"로 읽혀
  다시 시도할 이유가 사라지고, 되물음을 `empty`로 그리면 질문을 던져 놓고 "찾지 못했어요"라고
  답하는 화면이 된다. 아홉을 그대로 옮기지는 않는다 — 문구만 다른 두 로딩과 두 ready는 그대로
  묶인다. `statusMessage`·`statusActionLabel`·`onStatusAction`이 함께 붙는다.
- `RoutexListCell.trailingActionIcon` 추가. 끝 동작이 늘 ⋯였는데, 최근 검색어 삭제처럼 **동작이
  하나뿐인 자리**에 ⋯를 두면 사용자는 메뉴가 열릴 줄 알고 누른다. ⋯는 "여기 여러 갈래가 있다"는
  뜻이다. **앱 영향:** 기본값은 ⋯ 그대로다.
- `RoutexChipOption.count` 추가. 화면이 `'패션 (12)'`처럼 문자열을 미리 이어 붙이면 같은 개수가
  줄마다 다른 모양으로 나온다. 괄호를 쓸지는 한 곳에서 정한다.
- `RoutexChipBar.dismiss`와 `selection` 추가. 고른 값이 쌓인 줄에서는 무엇을 눌러야 되돌아가는지
  보여야 하고(`dismiss: visible` → 선택된 칩에 ×), `전체`처럼 "좁히지 않음"을 뜻하는 칩이 줄에
  있으면 해제가 있어서는 안 된다(`selection: required`) — 해제하면 그 칩의 강조만 사라져 지금
  무엇을 보고 있는지가 화면에서 없어진다.

## 0.2.7

- `RoutexListCell.leadingIconTone` 추가. leading 아이콘은 늘 강조색이었는데, **종류가 섞인 목록**
  에서는 그것이 정보를 흐린다 — 검색 결과처럼 매장·건물·후보가 번갈아 오는 자리에서 아이콘까지
  강조색을 쓰면 목록이 색 점으로 칸칸이 나뉘어 보이고, 강조색이 "왜 이 줄이 걸렸나"를 말하는지
  "이건 장소다"를 말하는지 구분되지 않는다. 그런 목록에서 색은 제목의 일치 구간
  (`titleHighlights`) 몫이고 종류는 글리프 모양이 가른다. **앱 영향:** 기본값 `accent`는 이전과
  같다. 종류가 섞인 목록만 `quiet`로 준다.

## 0.2.6

검색 결과 행(포팅 가이드 단계 4)을 대조하니 `RoutexListCell`이 지금 받는 것보다 네 가지를 더 이고
있었다. 그중 **둘만** 계약으로 올린다 — 나머지 둘(제목 오른쪽 업종 라벨)은 소비 앱이 맥락 줄로
흡수한다. 두 입력 모두 기본값은 없던 것과 같다.

- `titleHighlights` 추가. 검색 결과는 "왜 이 줄이 걸렸는지"를 색으로 말한다. **무엇이 걸렸는지
  정하는 일은 소비 앱이 한다** — 대소문자·공백 정규화와 의미 검색의 판정은 도메인이고, 여기서
  흉내 내면 서버 판정과 어긋난다. 이 컴포넌트는 강조가 어떻게 보이는지만 소유한다. 비어 있는 것이
  정상 상태다(의미 검색은 이름에 검색어가 없는 결과를 주는 것이 목적이다).
- `metric` 추가. 거리·소요 시간처럼 **이 줄을 고를지 정하는 값**이다. `subtitle`이 "어디에 있는가"
  라면 이쪽은 "지금 갈까"에 답한다. 한 줄로 합치면 결정에 쓰는 값이 맥락과 같은 무게가 되어 목록을
  훑는 눈이 짚을 곳을 잃는다. 크기는 맥락 줄과 같고 굵기와 색만 올린다. 스크린 리더는 보이는
  순서대로 제목·맥락·값을 읽는다.

## 0.2.5

- 시트 표면이 **잉크 면**을 준다. 시트 본문은 누를 수 있는 줄로 차 있는데, 그 줄들은 배경과 물결을
  가장 가까운 `Material`에 칠한다. 표면이 색을 칠한 상자로만 그려져 있으면 칠할 자리가 시트 색
  아래로 내려가 보이지 않고, `ListTile`은 그 상황을 단언으로 잡는다 — 소비 앱의 매장 목록 시트를
  옮기다 그 자리에서 걸렸다. 색과 그림자는 그대로 두고 투명한 `Material`만 얹으므로 픽셀은
  변하지 않는다. **앱 영향:** 없다. 시트 표면을 쓰려고 앱이 따로 `Material`을 두던 것을 뗄 수 있다.

## 0.2.4

포팅 가이드 단계 3(하단 시트)을 시작하려고 소비 앱의 시트 여섯 개를 대조한 결과, 지금 계약으로는
**현재 디자인을 표현할 수 없는 자리가 셋**이었다. 세 항목 모두 기본값은 이전과 같다.

- `RoutexSheetHandle` 공개. 본문이 스크롤하는 시트에서 handle은 표면 위가 아니라 **스크롤 콘텐츠의
  첫 항목**이어야 한다 — `DraggableScrollableSheet`는 제 scrollController가 받은 드래그로만 크기가
  바뀌므로, 표면 위에 고정하면 눌러도 끌리지 않는 장식이 된다. `showHandle`은 그대로 두고 같은
  위젯을 그린다. **앱 영향:** 스크롤하는 시트는 `showHandle: false`로 두고 본문 안에 이 위젯을 둔다.
- `RoutexBottomSheet.contentInset` 추가. 대표 사진처럼 가장자리까지 닿아야 하는 조각과 안쪽으로
  들어와야 하는 글이 한 본문에 섞인 시트가 있다. 표면이 여백을 강제하면 그 사진을 표현할 수 없어
  소비 앱이 표면을 사설로 다시 그리게 된다. **앱 영향:** 기본값 `surface`는 이전과 같고, 그런 시트만
  `content`로 준다. 그때 여백은 본문 조각들이 저마다 갖는다.
- 시트가 본문을 제 곡률(`RoutexRadii.sheet`)로 자른다. 스크롤하는 본문이 둥근 모서리를 지나 올라갈
  때 자르지 않으면 그 자리에서 사각으로 튀어나온다. **앱 영향:** 없다 — 모서리 밖으로 나가던 픽셀만
  사라진다. 대표 golden의 실제 변화 여부는 Ubuntu CI가 확인한다.

## 0.2.3

- `RoutexChipBar.overflow` 추가. 지도 위 칩 줄은 소비 앱이 이미 가로 스크롤 뷰포트를 소유한
  자리에 놓인다 — 지도가 플랫폼 뷰라 그 스크롤이 시각이 아니라 **입력 계약**(휠이 지도까지
  내려가는 것을 막는 잠금, 그 잠금을 뷰포트 전체가 아니라 칩이 그려진 영역에만 거는 것)을 함께
  지기 때문이다. 스크롤을 줄이 계속 소유하면 가로 뷰포트가 겹쳐 무한 폭으로 터진다.
  **앱 영향:** 기본값 `scroll`은 이전과 같다. 부모가 스크롤을 소유한 자리에서만
  `RoutexChipBarOverflow.deferToParent`를 준다. 그때는 **부모가 가로 스크롤을 반드시
  제공해야 한다** — 칩은 큰 글자에서 폭이 늘고 이 줄은 스스로 접히지 않는다.

## 0.2.2

- `RoutexFeedbackTiming.noticeVisibility` 추가. 되돌리기가 붙은 알림은 읽는 시간에 더해 손이 닿을
  시간이 필요해 토스트보다 길다. 소비 앱이 알림 유지 시간을 직접 적지 않게 한다.

## 0.2.1

- `RoutexHours`의 `staleNote`가 접혀 있을 때 트리에서 빠지던 것을 고쳤다. 머리 줄의
  "영업시간 정보가 오래됐어요"는 주장이고 확인일은 그 근거인데, 주장만 보이고 근거는 펼쳐야
  나왔다. `RoutexDisclosure.preview`로 옮겨 접힘·펼침 모두에서 남긴다. 펼친 상태에서는 요일
  표 아래가 아니라 상태 줄 바로 아래로 자리가 올라간다 — 근거는 그것이 수식하는 문장 옆에
  둔다. **앱 영향:** `staleNote`를 늘 넘기던 소비자는 이제 오래된 상태에서만 넘겨야 한다.
- Showcase가 `staleNote`를 무조건 넘겨 방금 확인한 영업시간에도 경고가 붙던 것을 고쳤다.

## 0.2.0 — 매장 상세·목록·안내 역할 보강

Navigation이 처음 소비하는 release다(포팅 가이드 단계 1). 소비 앱은 `v0.2.0` tag가 가리키는 전체
commit SHA를 고정한다. `0.0.1`은 공급 구조 검증용 bootstrap이었고 소비 앱이 없었으므로, 아래
**Migration**이 붙은 항목은 이 저장소 안에서만 적용된 것이다.

Navigation 앱과 대조해 **Runtime Kit에 없던 역할**을 채웠다. 기준은 "앱이 그 역할을 사설
위젯으로 다시 그리고 있는가"다. 지도 painter·마커·상태 머신처럼 앱 계층에 남는 것은
그대로 뒀다.

- `RoutexSearchBar`와 `RoutexRoutePlanner` 내부 아이콘 동작이 작은 부모에 잘려 실제 40/44dp로
  눌리던 문제를 수정했다. 글리프 크기는 유지하고 투명한 터치 영역만 48dp로 확보한다
- focus를 모든 컴포넌트의 동일한 링으로 강제하지 않는다. 커스텀 표면은 2dp 링, Material
  기본 컨트롤은 `focusRing`에서 파생한 12% 상태 레이어를 쓰며 hover와 다른 값으로 고정한다
- `RoutexSurface`의 임의 `BorderRadius`·clip 주입을 제거하고 `field/card` 의미형 shape만
  허용한다. `overlay`는 Surface variant가 아니라 `RoutexLayer.overlay`를 쓰는 앱 조합이다.
  **Migration:** `radius: RoutexRadii.field`는 `shape: RoutexSurfaceShape.field`로 바꾼다.
  `clip`은 실제 소비처가 없어 제거했으며, 임의 clipping이 필요하면 Surface 밖의 앱 조합이
  소유한다
- v1 전 공개 위젯은 기본 beta, foundation/layout은 proposal로 정한다. 51종에 같은 상태를
  반복하지 않고 stable·deprecated 예외와 실제 migration이 생길 때만 기록한다
- 장소 상세에서 주소 복사와 보행 시간 반복을 제거하고 `RoutexPlaceHeader`의 저장 옆에 선택적 공유
  icon action을 추가했다. `RoutexEtaCard`의 공통 `경로 지우기` action은 제거하고 복수 경로용 `routeOptions`
  slot을 추가했다
- `RoutexBottomSheet.showHandle` 기본값을 false로 바꿨다. 실제 확장 gesture가 있는 소비 화면만
  명시적으로 켠다. **Migration:** 확장형 시트는 `showHandle: true`, 고정형 시트는 변경하지 않는다
- Showcase 메뉴에 `신상품` 속성 필터를 추가했다. 신상품은 원래 분류에도 남고, 신상품 필터에서는
  NEW 배지를 행마다 반복하지 않는다
- 검색 결과·최근 검색 카드의 위쪽 간격과 결과 머리 줄의 좌우 keyline을 줄에 맞췄다. 시트 헤더의
  좌우 glyph 중심도 목록 아이콘 열과 일치시켰다
- 영업시간은 반복 날짜를 제거하고 `요일 · 시간` 한 줄로 묶었다. GPS 약함은 작은 상태 badge로
  낮추고, 경로 이탈은 자동 재탐색을 알리는 상단 error banner로 분리했다
- Showcase의 저장 피드백과 검색 중 skeleton 중복 예시를 제거했다
- 기존 골든을 바꾸지 않고 stroke·opacity·content measure·optical correction·feedback timing을
  foundation 계약으로 승격했다. 제품 컴포넌트에 직접 시각 값이 다시 들어오지 않도록 source contract
  test와 문서화된 optical-correction allowlist를 추가했다. **Migration:** `RoutexSkeleton.widthFactor`
  대신 `width: RoutexSkeletonWidth.long/short`를 사용한다

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
- `RoutexPlaceHeader`에 `supportingIcon` 추가. 검색 결과·장소 요약의 "어떻게 닿는가"(도보 4분)를
  글리프와 함께 적는다. 선택 뒤 상세 헤더에서는 이 줄을 반복하지 않는다
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
- `IconAction`, `BottomSheet`, `Tabs`, `MapControl`, `PlaceHeader`, `ManeuverBanner`,
  `RouteOption`, `TripProgress` beta 추가
- 핵심 10종을 360/390px와 글자 배율 1.0/1.3/2.0에서 검증하는 component fixture 추가
- 검색·경로 입력·이동수단·층 선택·결과 알림·정보·빈 상태·상태 배너 제품 패턴 추가
- 가용 이동수단만 한 줄로 표시하고 선택지가 하나면 숨기는 규칙 추가
- Showcase의 가짜 휠체어 옵션과 사진 placeholder를 제거하고 실제 빈 상태로 교체
- 문서 구조를 현재 계약·제품 결정·원본 앱 포팅 가이드 중심으로 정리하고 정적 HTML Showcase와
  완료된 계획·중복 문서를 제거했다
- source contract test의 optical-correction 허용 목록이 Windows에서 항상 실패하던 것을 고쳤다.
  `listSync`가 돌려주는 `\` 경로를 저장소 기준 POSIX 경로로 맞춘다. 앱 영향과 공개 API 변경은
  없으며 `lib/`은 그대로다 — 골든도 바뀌지 않는다

## 0.0.1

- semantic color, typography, spacing, radius, shadow, product motion token bootstrap
- package 공급 경로 검증을 위한 `RoutexButton` beta vertical slice
- theme extension, reduced-motion과 48dp touch target 검증 추가
