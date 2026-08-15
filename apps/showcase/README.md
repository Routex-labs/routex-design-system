# Routex Showcase

Runtime Kit의 실제 Flutter 컴포넌트를 import해 렌더링하는 경량 카탈로그다. v0.1에서는
foundation, 핵심 컴포넌트 상태와 반응형·텍스트 배율 검수에 집중한다.

```bash
flutter run -d chrome
```

Navigation의 배포 API를 연결하려면 `config.example.json`을 `config.local.json`으로
복사하고 `API_BASE_URL`을 채운 뒤 아래처럼 실행한다. 설정이 없거나 응답·CORS에 실패하면
Navigation의 `thehyundai-seoul` 데이터에서 추출한 고정 snapshot을 사용한다.

```bash
flutter run -d chrome --dart-define-from-file=config.local.json
```

```bash
flutter test
flutter build web
```

색 값과 컴포넌트 상태를 이 앱에 다시 정의하지 않는다. 표시 값은
`routex_design_system` package의 공개 API에서 읽는다.

## 매장 상세의 내용

`한눈에`와 `컴포넌트`의 매장 상세는 손으로 만든 예시가 아니라 Navigation 백엔드의 오설록
매장 상세(`backend/resources/store_details/osulloc-thehyundai-seoul-b1.json`)를 그대로 쓴다.
상세 컴포넌트는 사진·메뉴·영업시간처럼 "있는 매장과 없는 매장"이 갈리는 값을 다루므로,
지어낸 예시로 검수하면 실제로 어떤 조합이 오는지를 영영 못 본다. `API_BASE_URL`이 있으면
`GET /buildings/{id}/places/{place_id}`로 같은 값을 실제로 받아 오고, 없으면 snapshot을 쓴다.

사진은 Navigation 앱이 번들로 가진 자산 중 **대표 몇 장만** `assets/place_details/`에 옮겨
왔다. Runtime Kit package에는 넣지 않는다 — 자산은 소비 앱이 소유한다. 백엔드가 여기 없는
사진 경로를 내려주면 캐러셀이 자리표시로 떨어진다. 없는 사진을 다른 사진으로 바꿔치기하지
않는다. **pubspec의 자산 목록이 바뀌면 hot reload가 아니라 앱을 다시 실행해야 한다.**

`한눈에`는 언제나 제품 폭(390) 카드 **네 열**로 배치하고, 창이 그보다 좁으면 배치를 바꾸는
대신 그 결과를 통째로 축소해 보여 준다. 카드 폭·글자·간격의 비율이 그대로라 위계가 깨지지
않는다. 실제 크기를 재는 검수는 축소가 걸리지 않는 `품질 기준` 탭의 fixture가 맡는다.

카드 순서는 곧 중요도다. 격자는 앞의 네 장을 각 열 머리에 그대로 두고 나머지만 높이로
균형을 맞추므로, 위쪽에 매장 상세와 길찾기가, 아래쪽에 상태 표시와 빈 값이 모인다.

쇼케이스를 열면 `한눈에` 페이지가 먼저 열린다. 전체 제품 UX를 한 화면에서 훑은 뒤
컴포넌트·기초·품질 기준·모바일 UX 목업으로 들어가는 흐름이다.

`모바일 UX 목업`은 Promo Studio와 같은 19.5:9 휴대폰 비율과 기기 chrome을 사용하되 촬영용
camera·timeline을 가져오지 않는다. 지도 색 canvas를 모든 단계의 유일한 바탕으로 두고,
메인·장소 선택·상세·경로 미리보기에는 그 단색만 남긴다. 이동 안내·실내 전환·도착에서만
Showcase 앱 계층의 지도 시각 계층이 경로선과 마커를 그린다. 검색·시트·목록·상태·경로 UI는
Runtime Kit의 공개 컴포넌트와 Navigation 패턴만 조합한다.
메인→장소 선택→가게 상세→경로 미리보기→이동 안내→실내 전환→도착을 직접 전환할 수 있고,
분류 필터·메뉴 시트·저장·상세 탭·지도 이동/확대·경로 선택·안내 재생·음소거·층 선택도 상태로
확인한다.

메인 화면은 Navigation `MapShellScreen`의 구조를 따른다. 지도가 주 화면이므로 하단 시트를
두지 않고, 검색 한 줄과 지도 위 카테고리 줄, 화면 아래 모서리의 지도 조작만 남긴다. 메뉴
버튼은 pilot 1인 `AppMenuSheet`와 같은 구조의 시트를 연다. 아직 목적지가 없는 상태이므로
지도 도면·경로·목적지 마커를 그리지 않고 단색 지도 canvas만 둔다. 이동 안내 계열 단계의
경로선·현재 위치·목적지 표현은 Navigation에서 가져온 시각 계약을 Showcase의 지도 시각
계층이 소비한다.

목업의 배치 계약(오버레이 gutter, 상단 표면과 필터 줄 간격, 시트 기준 컨트롤 순서, 단계별
상단 시작선)은 `test/mockup_layout_spec_test.dart`가 좌표로 검증한다. 컴포넌트 계약은
package test가, 전체 모습 변화는 golden이 맡고, 그 사이의 화면 조합을 이 test가 지킨다.

`정렬과 리듬` fixture는 360/390px과 text scale 1.0/1.3/2.0을 전환한다. 정확한 기준
폭을 유지하기 때문에 좁은 화면에서는 fixture를 좌우로 확인하며, 자동 테스트는 여섯 조합의
긴 한글·상태 메시지·48dp action이 overflow 없이 렌더링되는지 검사한다. Showcase 자체도
같은 여섯 조합에서 모든 섹션의 좌우 경계가 정확히 일치하는지 좌표로 검증한다.

컴포넌트 섹션과 모바일 UX 목업은 임시 위젯을 복제하지 않고 Runtime Kit의 실제 공개
API를 렌더링한다. v0.1 핵심 10종은 `Button`, `ListCell`, `IconAction`,
`BottomSheet`, `Tabs`, `MapControl`, `PlaceHeader`, `ManeuverBanner`, `RouteOption`,
`TripProgress`다. 검색, 경로 입력, 이동수단, 층 선택, 인라인 결과, 상세 정보, 빈 상태와
완료 상태는 공개 Navigation 제품 패턴을 사용한다. 기기 프레임·상태바, Showcase 전용 지도
시각 계층·painter, API adapter와 화면 상태 머신만 Showcase 앱 계층에 남는다. 지도 시각 계층은
Runtime Kit의 `RoutexMapVisualTokens`를 사용하지만 MapLibre controller·실제 POI/경로 데이터는
가져오지 않는다. 검색 결과처럼 패턴으로 승격되지 않은 사설 시각 위젯은 목업에서 만들지 않는다.

이동수단은 Navigation 앱의 실제 가용성 규칙을 따른다. 사용할 수 있는 수단이 둘 이상일
때만 한 줄 선택기를 표시하고, 실내 매장 경로처럼 도보 하나만 가능하면 선택기를 숨긴다.
지원하지 않는 휠체어 전용 경로를 가짜 선택지로 표시하지 않는다.

컴포넌트 역할을 Showcase 안에서 사설 위젯으로 다시 만들거나, 360/390px 및 글자 배율
1.0/1.3/2.0에서 잘림·overflow가 생기면 실패다. 정확한 판정 기준은
[`../../docs/component-systemization-v0.1.md`](../../docs/component-systemization-v0.1.md)를 따른다.
