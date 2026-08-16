# 장소 상세·안내 패턴 결정과 Navigation 적용 가이드

## 목적과 완료 판정

이 문서는 2026-08-16에 합의한 장소 상세, 하단 시트, 메뉴 필터, 길안내 상태의 단일 기준이다.
Showcase는 시각·상호작용 계약을 검증하고, 실제 링크 수신·API 조회·지도 이동은 Navigation 앱이
소유한다.

다음 조건을 모두 만족하면 적용이 끝난 것으로 본다.

- 저장 결과는 한 화면에서 한 번만 알리고, 공유 결과와 같은 메시지로 합치지 않는다.
- 장소 공유 링크는 cold start와 warm start에서 같은 `buildingId`·`placeId`의 상세를 연다.
- ID 누락, 잘못된 경로, 삭제·제외된 매장, 네트워크 실패 때 다른 매장을 대신 열지 않는다.
- 실제로 끌어 확장할 수 있는 하단 시트에만 handle이 보인다.
- 상세 헤더에는 보행 시간을 반복하지 않고 `이름 / 층 · 분류 · 세부분류`까지만 둔다.
- 신상품은 `신상품` 필터와 원래 분류에서 모두 조회되며, 전체 목록에서 중복되지 않는다.
- 안내 전에는 절대 도착 시각, 소요, 거리와 하나의 primary action만 둔다.
- 안내 중에는 절대 도착 시각, 남은 시간, 남은 거리가 서로 다른 뜻과 값을 가진다.
- 도착 문구는 상단 상태 배너 한 곳에서만 말하고 하단은 후속 행동만 제공한다.
- 360/390px, 글자 배율 1.0/1.3/2.0에서 잘림과 overflow가 없다.

## 디자인 시스템 결정

### 장소 상세와 공유

상세 헤더는 `오설록 / B1 · 식음료 · 카페` 두 묶음으로 끝낸다. 검색 결과의
`B1 · 식음료 · 도보 3분`은 비교·선택에 필요한 값이므로 유지하지만, 이미 선택한 장소의 상세에서
같은 보행 시간을 반복하지 않는다. 장소 이름 앞의 장식용 매장 아이콘도 상세에서는 제거한다.

주소는 사실 정보로 남길 수 있지만 복사 action을 붙이지 않는다. 실내에서는 같은 건물 주소보다
건물·층·매장 식별자가 중요하다. 외부 전달은 `RoutexPlaceHeader`에서 저장 옆의 `공유` icon
action이 맡고, 출발·도착은 그 아래 길찾기 행동 묶음에만 남긴다. Runtime Kit은 링크를 만들거나
플랫폼 공유 시트를 열지 않는다.

저장은 되돌리기가 있으므로 제품 흐름에서는 `RoutexInlineNotice` 한 개를 사용한다. 단순 완료나
공유 준비 실패처럼 되돌리기가 없는 결과는 `RoutexToast`를 사용한다. 같은 저장 callback에서
SnackBar·toast·inline notice를 동시에 띄우지 않는다.

### 메뉴의 신상품 필터

`신상품`은 메뉴 분류가 아니라 `NEW` 속성을 조회하는 필터다. 순서는
`전체 · 신상품 · 티 · 티푸드 · 라이프스타일`로 둔다.

- `전체`: 각 상품을 한 번만 표시한다.
- `신상품`: `NEW` 속성이 있는 상품을 원래 분류와 관계없이 모은다. 이 화면에서는 행마다 NEW
  배지를 다시 표시하지 않는다.
- 일반 분류: 해당 분류의 모든 상품을 표시하며, 신상품에는 NEW 배지를 표시한다.
- 필터 전환 시 펼침 상태를 초기화해 이전 필터의 행 개수와 disclosure 상태가 섞이지 않게 한다.

### 시트 handle과 간격

`RoutexBottomSheet.showHandle`의 기본값은 false다. handle은 표면을 끌 수 있다는 조작 안내이며
장식이나 위쪽 여백 채움이 아니다. 실제 `DraggableScrollableSheet`처럼 확장 gesture를 연결한
소비 화면만 true로 지정한다. 검색 결과 드롭다운과 고정 카드에는 표시하지 않는다. 저장 목록처럼
확장형으로 정의한 시트는 handle을 표시하되 다음을 함께 검증한다.

1. 접힘·펼침 높이가 명확하고 handle 또는 시트 drag로 두 상태를 오갈 수 있는가
2. 목록 스크롤이 끝에 닿기 전 시트 drag로 가로채지 않는가
3. 재정렬 손잡이 drag가 시트 확장·스크롤과 충돌하지 않는가

`RoutexListCell`의 제목과 설명은 `RoutexSpacing.inlineGap`으로 한 묶음이 된다. 설명이 제목을
다시 말하면 화면별 padding을 줄이는 대신 설명을 제거한다.

검색 결과와 최근 검색은 검색 표면에서 바로 이어지는 목록이다. 장식용 상단 공간을 두지 않고
header와 첫 행이 공통 inset·stack 역할을 사용한다. 결과 수와 정렬 action은 같은 header
baseline에, 각 행의 아이콘·제목·설명은 `RoutexListCell`의 예약된 leading column에 맞춘다.
개별 화면에서 아이콘 폭이나 `SizedBox`로 시작선을 보정하지 않는다.

### 영업시간

반복 영업시간의 기본 라벨은 `화`, `수`처럼 요일만 사용한다. 날짜는 임시 휴점·공휴일·특정일
변경처럼 그 날짜 자체가 판단에 필요한 예외의 `note`에만 둔다. 접힌 상태도
`화 · 10:30 - 20:00`처럼 가운데점을 사용해 요일과 시간을 한 문장으로 묶으며, 두 열을 멀리
벌리는 임의 가로 폭은 사용하지 않는다. 지금 영업 여부와 다음 전환 시각의 판정은 소비 앱이
맡고 `RoutexHours`는 전달받은 결과만 표현한다.

### Showcase 상태 예시

Toast, 실행 취소가 있는 inline notice, skeleton은 서로 다른 상태를 설명하는 독립 fixture다.
같은 제품 화면에서 저장 결과 두 개나 같은 loading skeleton 두 개를 동시에 조합하지 않는다.
Showcase에서는 각 역할을 한 번씩 대표하고, 변형은 컴포넌트 페이지의 상태 전환이나 테스트로
검수한다. 예시 수를 늘리려고 같은 모양을 중복 카드로 만들지 않는다.

### 길안내 상태

안내 전 `RoutexEtaCard`는 `도착 예정 / 오후 3:24`, `22분 소요 · 1.4km 거리`와
`안내 시작`만 둔다. 두 판단 값은 한 줄로 묶고, 큰 글자 배율에서만 자연스럽게 줄바꿈한다.
경로 선택지가 여럿이면 `routeOptions`에 `RoutexRouteOption` 묶음을 먼저
놓는다. `경로 지우기`는 공통 카드에서 제거한다. 상단 길찾기 입력의 닫기가 계획 취소를 맡고,
별도 취소가 꼭 필요한 화면만 카드 밖에서 작은 secondary action을 조합한다.

안내 중 `RoutexTripProgress`는 다음 세 값을 사용한다.

```text
오후 3:24  도착 예정
6분        남은 시간
410m       남은 거리
```

`6분 후`와 `6분`처럼 같은 계산값을 두 라벨에 복제하지 않는다. NEW·시즌 한정은 읽기 전용
`RoutexBadge`, 필터는 `RoutexChipBar`를 쓴다. GPS 약함처럼 앱이 자체 보정하는 낮은 강도의
상태는 작은 warning badge로 충분하며, 맥락상 중요하지 않으면 표시하지 않아도 된다. 경로 이탈은
상단에 error `RoutexStatusBanner`를 잠시 표시하고 `새 경로를 자동으로 찾고 있습니다`라고 알린다.
자동 재탐색하므로 별도 `경로 다시 찾기` action은 두지 않는다.

도착 화면은 상단 `RoutexStatusBanner`가 `목적지에 도착했습니다`와 위치를 말한다. 하단 시트는
매장 정보, 저장, 안내 종료만 제공하고 도착 문구나 목적지 제목을 반복하지 않는다.

## Navigation 앱 장소 공유 적용

아래는 제품 결정에 필요한 공유 계약 요약이다. 원본 코드 파일별 연결 순서, theme·sheet·지도
책임, 단계별 gate와 전체 테스트는 [Navigation 포팅 가이드](navigation-app-porting-guide.md)가
단일 출처다.

### 1. 먼저 확정할 외부 계약

공유 URL은 다음 형식으로 고정한다.

```text
https://[서비스 도메인]/place/[buildingId]/[placeId]
```

서비스 도메인, 미설치 사용자가 볼 HTTPS fallback 페이지, iOS Universal Links의
`apple-app-site-association`, Android App Links의 `assetlinks.json`이 준비되기 전에는 실제 앱의
공유 버튼을 release하지 않는다. 커스텀 scheme만 공유하면 미설치 사용자가 열 수 없고 메신저가
일반 링크로 다루지 않을 수 있다.

링크에는 표시 이름·층·좌표를 신뢰 가능한 식별자로 넣지 않는다. 경로의 `buildingId`와
`placeId`만 percent-encode하고, 수신 뒤 서버 데이터로 이름·층·입구 노드를 다시 구한다.

### 2. 앱 안의 책임 분리

Navigation 저장소에서 다음 순서로 연결한다.

1. `client/lib/routing/place_link.dart`에 순수 parser/builder를 둔다. scheme·host·정확히 세 개인
   path segment(`place`, building, place)를 검사하고 빈 값, 여분 segment, 잘못된 percent encoding을
   거부한다.
2. `client/lib/app.dart`의 `_NavigationAppState`가 링크 패키지(`app_links` 또는 동등한 구현)의
   최초 URI와 URI stream을 각각 구독한다. 최초 URI는 cold start, stream은 실행 중·백그라운드
   복귀를 담당한다. 같은 URI가 두 경로로 연달아 오면 한 번만 처리한다.
3. parser 결과를 앱 계층의 `PlaceLinkIntent(buildingId, placeId)`로 바꾸고 지도 셸이 준비될 때까지
   한 개만 보류한다. `BuildContext`가 생기기 전에 곧바로 modal을 열지 않는다.
4. `client/lib/screens/map_shell/map_shell_screen.dart`가 intent를 받으면 건물과 store index를 먼저
   조회하고 `entry.id == placeId`인 항목을 정확히 찾는다. 이름 검색이나 첫 번째 결과 fallback은
   금지한다.
5. 일치한 `StoreIndexEntry`를 기존 `_showStoreInfo` 흐름에 넘겨 지도 focus와
   `PlaceDetailSheet.show`를 연다. 이 경로도 기존 온디바이스 Dijkstra를 그대로 사용하며 경로
   계산을 서버나 링크 계층으로 옮기지 않는다.

현재 `PlaceDetailSheet.show`는 제목·층 등 이미 조회한 `PoiSearchResult`를 요구한다. 따라서
딥링크가 `PlaceDetailRepository.getPlaceDetail`만 바로 호출해 시트를 여는 방식보다, store index로
정확한 매장을 복원한 뒤 기존 `_showStoreInfo`를 재사용하는 편이 지도 focus·저장·근처 매장 계약을
보존한다.

### 3. 공유 action

`client/lib/screens/map_shell/widgets/sheets/place_detail_sheet.dart`의 상세 헤더에서 저장 icon action 옆에 공유 callback을
추가한다. 출발·도착 text button 행에는 섞지 않는다. 다음을 모두 만족할 때만 활성화한다.

- `buildingId.trim().isNotEmpty`
- `placeId != null && placeId.trim().isNotEmpty`
- 확정된 서비스 HTTPS origin이 설정됨

callback은 builder로 URL을 만든 뒤 이미 의존 중인 `share_plus`로 장소명과 링크를 공유한다. iPad의
공유 popover에는 0 크기가 아닌 현재 버튼의 origin rect를 넘긴다. 플랫폼 공유 시트가 취소된 것은
오류 toast로 보지 않고, 링크 생성이나 플랫폼 호출이 실패한 경우에만 공유 실패 피드백을 한 번
표시한다. 공유 성공 피드백은 저장 피드백과 별도 채널·문구를 사용한다.

### 4. 실패 처리

다음 경우에는 상세를 열지 않고 `장소를 찾을 수 없습니다`처럼 원인을 과장하지 않는 안내를 한 번
보여 준 뒤 현재 지도에 머문다.

- `buildingId` 또는 `placeId` 누락·공백
- 허용하지 않은 scheme/host/path 또는 여분 segment
- 건물 조회 실패
- store index에 정확한 `placeId`가 없음(삭제·비공개 포함)
- 상세 응답의 `kind`가 제외 시설이거나 API 계약을 파싱할 수 없음
- 링크 처리 중 같은 매장이 삭제됨

네트워크 실패와 삭제를 클라이언트가 구분할 수 없다면 둘 다 다른 매장 fallback 없이 같은 복구 안내로
끝낸다. 실패 뒤 재시도는 사용자가 명시적으로 눌렀을 때만 같은 ID로 수행한다.

### 5. Navigation 테스트 목록

- builder/parser round trip, 한글·공백 percent encoding, 누락·여분 segment, 다른 host
- cold start 최초 URI 한 번 처리
- warm start URI stream 한 번 처리 및 중복 URI dedupe
- 지도 셸 준비 전 URI 보류 후 정확한 매장 열기
- 잘못된 building ID, 존재하지 않는 place ID, 삭제된 매장에서 modal 미표시
- 동명 매장 두 개가 있어도 exact `placeId`만 열기
- share_plus 성공·취소·예외와 iPad non-zero `sharePositionOrigin`
- 공유와 저장을 연달아 눌러도 피드백이 겹치지 않음

앱 적용 PR에서는 링크 parser/coordinator, 상세 action, 플랫폼 설정, 테스트를 기능 커밋으로 묶고,
서비스 도메인·운영 fallback 문서는 별도 문서 커밋으로 갱신한다.
