# Navigation 원본 앱 포팅 가이드

## 문서 상태와 범위

- 상태: 단계 2 진행 중
- 공급자: `packages/routex_design_system`
- 소비자: `Routex-labs/Navigation`의 Flutter 클라이언트
- 목적: Showcase에서 검증한 현재 디자인과 컴포넌트 계약을 원본 앱에 안전하게 연결하는 방법 정의
- 비목적: 이 문서만으로 단계 2 이후를 시작하거나 승인하지 않음
- 원본 코드 조사 기준: Navigation `main`의 `b655c066e00ca6b2bab6dd9035c37a9d8d54fe62`
- 앱이 소비 중인 Runtime Kit release: `v0.2.2`. 앱이 실제로 고정한 전체 SHA는 Navigation
  `client/pubspec.lock`의 `resolved-ref`가 단일 출처다

### 적용 상태

| 단계 | 상태 | 증거 |
|---|---|---|
| 0. 기준선과 release 고정 | 적용 | 적용 직전 Navigation `flutter test` 1457개 전부 통과, `flutter analyze` 무결 |
| 1. 의존성과 테마 브리지 | 적용 | `client/pubspec.yaml`·`client/pubspec.lock`의 고정 ref, `AppTheme.withRoutexTokens`, `client/test/theme/routex_theme_bridge_test.dart` |
| 2. 저위험 기반 요소 | 진행 중 | 아래 표 |
| 3 이후 | 미착수 | — |

전역 테마는 아직 `RoutexTheme.light`가 아니다. 브리지는 `RoutexColorTokens` ThemeExtension **하나만**
더하며, 그 사실 자체를 `withRoutexTokens`에 대한 테스트가 지킨다.

tag는 사람이 읽는 이름이고 **앱이 고정하는 것은 그 tag가 가리키는 전체 SHA**다. tag는 옮길 수 있지만
SHA는 그럴 수 없다.

#### 단계 2 안쪽

| 항목 | 상태 | 증거 |
|---|---|---|
| Badge·Chip·status banner 의미 분리 | 지도 위 표시만 적용 | `parts/ui.dart`의 `RoutexBadge`·`RoutexInlineNotice`, `client/test/app_test.dart` |
| 공통 list cell | 미착수 | 목록이 전부 시트·검색 안이라 단계 3~5에서 그 표면과 함께 옮긴다 |
| 영업시간 접힘·펼침 | 적용 | `place_detail_hours_section.dart`(`RoutexHours`) |
| 저장 피드백 단일 notice | 적용 | `place_detail_sheet.dart`(`RoutexInlineNotice`) |
| toast·skeleton 중복 제한 | 적용 | `place_detail_rich_sections.dart`(`RoutexToast`). skeleton은 앱에 아직 없다 |

**칩은 지도 위 대분류 줄까지만 이 단계에서 옮긴다.** 시트 안 소분류 줄과 검색 되물음 줄은 계약이
아직 모자라고(7.4), 그 표면 자체가 단계 3·4에서 옮겨간다 — 먼저 칩만 바꾸면 같은 파일을 두 번
건드리게 된다.

이 문서는 **어떻게 옮길지**를 설명한다. 장소 상세·공유·안내 화면의 제품 결정은
[`place-detail-guidance-decisions.md`](place-detail-guidance-decisions.md), 현재 픽셀을 바꾸지 않고
직접 값을 계약으로 승격하는 기준은
[`0002-visual-source-contract.md`](decisions/0002-visual-source-contract.md)를 단일 출처로 사용한다.
두 문서와 충돌하면 해당 주제의 단일 출처가 우선한다.

### 조사에서 확인한 현재 조건

이 가이드는 원본 앱의 파일 이름만 훑어 만든 계획이 아니다. 앱 진입점, 지도 shell, 상세·검색·안내
상태, 플랫폼 설정과 기존 테스트를 위 조사 기준에서 대조했다. 포팅 착수 시 Navigation ref가
달라졌다면 이 절부터 다시 확인한다.

- `client/lib/app.dart`의 `NavigationApp`은 `WidgetsBindingObserver`로 PDR background/foreground를
  중계한다. 링크 수신을 붙일 때 이 lifecycle을 대체하거나 두 번 구독하면 안 된다.
- `client/lib/routing/app_routes.dart`에는 named route가 `outdoorMap = '/'` **하나뿐이다.** 지도 셸이
  야외·실내와 그 사이 모든 단계를 시트로 그려서 push할 곳이 없다. `/place/...` named route나 URI
  coordinator는 없다.
- `client/lib/screens/map_shell/map_shell_screen.dart`의 `_MapShellScreenState`가 검색, route draft,
  sheet chain, 지도 focus와 현재 demo 건물 상태를 소유한다.
- 같은 파일의 `_buildingId`는 `demoBuildingId`로 고정돼 있다. 현재 앱은 링크가 가리키는 임의
  건물로 전환할 수 없다.
- 장소 상세는 named route가 아니라 `_showStoreInfo(PoiSearchResult)`가
  `PlaceDetailSheet.show(...)`를 호출해 연다.
- `PlaceDetailSheet`와 `CategoryStoresSheet`는 `MapPassThroughSheetRoute`, `MapOverlayGuard`,
  `DraggableScrollableSheet(expand: false)`를 함께 사용한다. 이 세 계약은 시각 코드가 아니다.
- `FavoritesSheet`는 `ReorderableListView` assertion 때문에 의도적으로
  `DraggableScrollableSheet`를 사용하지 않는다.
- `SearchPanel`은 단순 loading/ready 목록이 아니라 `_SearchPhase` 9개 상태와 request sequence,
  두 단계 debounce, 최근 검색, 온디바이스 후보, 의미 검색, 정렬을 소유한다.
- `OutdoorMapBodyState`가 GPS 표시, 실내 안내, 자동 재탐색, 도착 timer, MapLibre pointer guard를
  소유하고 실제 `EtaCard`·`IndoorArrivalCard`·`StatusBadge`를 조합한다.
- `share_plus`는 이미 `client/pubspec.yaml`에 있지만 app/universal link 수신 package는 없다.
- Android manifest에는 launcher intent만 있고 HTTPS App Links intent filter가 없다. iOS에는
  associated-domains entitlement 파일이 없다.
- Navigation은 UI, 지도 font stack과 mock SVG가 모두 Pretendard를 쓴다는 테스트를 갖고 있다.
  테마 포팅이 이 계약을 끊으면 안 된다.

조사한 원본은 아래 permalink로 고정한다.

| 영역 | 원본 코드 |
|---|---|
| 앱 lifecycle·theme·route 설치 | [`client/lib/app.dart`](https://github.com/Routex-labs/Navigation/blob/b655c066e00ca6b2bab6dd9035c37a9d8d54fe62/client/lib/app.dart) |
| named route 목록 | [`client/lib/routing/app_routes.dart`](https://github.com/Routex-labs/Navigation/blob/b655c066e00ca6b2bab6dd9035c37a9d8d54fe62/client/lib/routing/app_routes.dart) |
| 전역 theme·legacy token·브리지 | [`client/lib/theme/app_theme.dart`](https://github.com/Routex-labs/Navigation/blob/b655c066e00ca6b2bab6dd9035c37a9d8d54fe62/client/lib/theme/app_theme.dart) |
| 검색·sheet chain·route draft | [`client/lib/screens/map_shell/map_shell_screen.dart`](https://github.com/Routex-labs/Navigation/blob/b655c066e00ca6b2bab6dd9035c37a9d8d54fe62/client/lib/screens/map_shell/map_shell_screen.dart) |
| MapLibre·GPS·실내 안내·도착 | [`client/lib/screens/outdoor_map/outdoor_map_screen.dart`](https://github.com/Routex-labs/Navigation/blob/b655c066e00ca6b2bab6dd9035c37a9d8d54fe62/client/lib/screens/outdoor_map/outdoor_map_screen.dart) |
| 장소 상세 sheet | [`client/lib/screens/map_shell/widgets/sheets/place_detail_sheet.dart`](https://github.com/Routex-labs/Navigation/blob/b655c066e00ca6b2bab6dd9035c37a9d8d54fe62/client/lib/screens/map_shell/widgets/sheets/place_detail_sheet.dart) |
| 카테고리 sheet | [`client/lib/screens/map_shell/widgets/sheets/category_stores_sheet.dart`](https://github.com/Routex-labs/Navigation/blob/b655c066e00ca6b2bab6dd9035c37a9d8d54fe62/client/lib/screens/map_shell/widgets/sheets/category_stores_sheet.dart) |
| 저장한 장소·reorder | [`client/lib/screens/map_shell/widgets/sheets/favorites_sheet.dart`](https://github.com/Routex-labs/Navigation/blob/b655c066e00ca6b2bab6dd9035c37a9d8d54fe62/client/lib/screens/map_shell/widgets/sheets/favorites_sheet.dart) |
| 검색 상태 | [`client/lib/screens/map_shell/widgets/search/search_panel.dart`](https://github.com/Routex-labs/Navigation/blob/b655c066e00ca6b2bab6dd9035c37a9d8d54fe62/client/lib/screens/map_shell/widgets/search/search_panel.dart) |
| 경로 입력 결과 | [`client/lib/screens/map_shell/widgets/search/route_field_results.dart`](https://github.com/Routex-labs/Navigation/blob/b655c066e00ca6b2bab6dd9035c37a9d8d54fe62/client/lib/screens/map_shell/widgets/search/route_field_results.dart) |
| 안내 표시 | [`client/lib/widgets/eta_card.dart`](https://github.com/Routex-labs/Navigation/blob/b655c066e00ca6b2bab6dd9035c37a9d8d54fe62/client/lib/widgets/eta_card.dart) |
| 도착 표시 | [`client/lib/screens/outdoor_map/widgets/indoor_arrival_card.dart`](https://github.com/Routex-labs/Navigation/blob/b655c066e00ca6b2bab6dd9035c37a9d8d54fe62/client/lib/screens/outdoor_map/widgets/indoor_arrival_card.dart) |
| 영업시간 판정 | [`client/lib/domain/store/store_hours.dart`](https://github.com/Routex-labs/Navigation/blob/b655c066e00ca6b2bab6dd9035c37a9d8d54fe62/client/lib/domain/store/store_hours.dart) |
| sheet pointer route | [`client/lib/widgets/map_pass_through_sheet_route.dart`](https://github.com/Routex-labs/Navigation/blob/b655c066e00ca6b2bab6dd9035c37a9d8d54fe62/client/lib/widgets/map_pass_through_sheet_route.dart) |

이전 기준 `b54b7300`과 비교하면 `client/lib` 232개 파일이 바뀌었고, 시트·검색·안내 위젯이
`client/lib/widgets/`에서 `client/lib/screens/<화면>/widgets/` 아래로 옮겨졌다. 경로만 보고 이 문서의
옛 판을 따르면 존재하지 않는 파일을 고치게 된다. 지도 pointer 계약(`map_pass_through_sheet_route`,
`map_overlay_guard`)과 `eta_card`는 여러 화면이 공유하므로 `client/lib/widgets/`에 남아 있다.

## 1. 실패 기준부터 확정한다

아래 항목은 경고가 아니라 **해당 단계의 즉시 중단·수정 또는 롤백 조건**이다. 화면이 얼핏
정상으로 보여도 하나라도 해당하면 포팅 성공으로 인정하지 않는다.

### 공급과 빌드

- 소비 앱이 `main`, 작업 브랜치, 로컬 sibling 경로처럼 바뀔 수 있는 패키지에 의존한다.
- 디자인 시스템의 검토 commit과 Showcase 기준 화면의 commit이 다르다.
- `pubspec.lock`이 고정 ref와 일치하지 않거나 macOS·Windows·CI 중 한 곳에서 복원되지 않는다.
- 소비 앱이 package의 공개 export가 아닌 `lib/src`를 import한다.
- analyze, build, 기존 unit/widget/integration test 중 새 실패가 하나라도 생긴다.

### 책임 경계

- Runtime Kit 안으로 앱 도메인 모델, API client, provider, Navigator, MapLibre controller,
  Dijkstra 또는 PDR 처리가 들어온다.
- 표시 위젯이 API를 호출하거나 route를 열고, 소비 앱이 그 동작을 제어할 수 없다.
- UI 포팅을 이유로 API 계약, 경로 계산, 센서 처리 또는 지도 상태가 바뀐다.
- 앱 화면을 맞추기 위해 Runtime Kit 내부 구현을 fork하거나 앱에서 내부 geometry를 override한다.

### 시스템과 시각

- 포팅된 범위에 임의 색상, `EdgeInsets`, `SizedBox`, radius, font size 또는 그림자 값이 새로
  들어간다.
- 시스템화만 하는 변경에서 Showcase golden의 픽셀이 바뀐다.
- 같은 역할의 앱 전용 위젯과 디자인 시스템 위젯이 최종 결과에 함께 남는다.
- 테마 토큰 누락을 임의 fallback 값으로 숨긴다.
- 전역 테마 교체 때문에 아직 포팅하지 않은 화면에 승인되지 않은 변화가 생긴다.
- 360/390px 또는 글자 배율 1.0/1.3/2.0 중 하나라도 잘림, overflow, 겹침, 도달 불가가 있다.
- focus, semantics, 명암 또는 최소 48×48 터치 영역이 깨진다.

### 상태와 상호작용

- 한 번의 탭이 저장, 공유, 상세 열기 또는 안내 시작 callback을 두 번 실행한다.
- 저장·공유 한 사건에 toast, snackbar, notice가 둘 이상 나타난다.
- loading, empty, error, ready 중 둘 이상의 상태가 동시에 렌더링된다.
- 같은 의미의 skeleton, 도착 문구 또는 목적지 정보가 한 화면에 중복된다.
- 지도 위 투명 영역이 포인터를 가로채거나 지도 pan/zoom을 막는다.
- draggable sheet의 scroll controller가 실제 scroll view에 연결되지 않는다.
- 고정형 표면에 handle이 있거나, 확장 가능한 sheet에 handle이 없다.
- 저장한 장소의 reorder, 목록 scroll, sheet drag 사이에서 assertion·jump·오작동이 한 번이라도
  재현된다.

### 정확성과 링크

- cold start와 warm start가 다른 장소 또는 다른 화면을 연다.
- `buildingId`·`placeId` 누락, 삭제 또는 조회 실패 때 이름이나 첫 검색 결과로 대체한다.
- 같은 URI의 중복 전달로 상세 sheet가 두 번 열린다.
- 앱 미설치 환경에서 HTTPS 링크가 유효한 안내·설치 화면에 도달하지 않는다.
- iPad에서 공유 popover의 origin이 없어 플랫폼 공유 창을 열지 못한다.
- 현재 `_buildingId == demoBuildingId`인데 다른 `buildingId` 링크를 받은 뒤 현재 건물의 store
  index에서 같은 `placeId`나 이름을 찾아 연다.
- 다중 건물 전환이 준비되지 않은 상태에서 다른 건물 링크를 성공처럼 처리한다.

## 2. 완료 판정

포팅은 패키지가 연결되거나 화면 하나가 비슷해진 시점이 아니라 다음 증거가 모두 있을 때 끝난다.

1. 검토 완료된 release tag 또는 전체 commit SHA와 lockfile을 함께 사용한다.
2. 포팅된 모든 표면이 Runtime Kit의 공개 컴포넌트와 semantic token으로 구성된다.
3. 앱의 검색·지도·Dijkstra·PDR·저장·라우팅 책임과 기존 동작이 유지된다.
4. 공급자 golden과 소비 앱 상태별 캡처가 PR에서 비교 가능하다.
5. 너비·글자 배율·상태·제스처·접근성 검증 매트릭스를 모두 통과한다.
6. 장소 공유가 정확한 ID로 cold/warm start 모두 동작하며 실패 시 다른 장소를 열지 않는다.
7. 실제 확장 가능한 sheet에만 handle이 있고 지도·scroll·reorder gesture가 충돌하지 않는다.
8. 사용하지 않게 된 앱 전용 UI, 상수, 문서가 같은 작업 흐름에서 제거 또는 갱신된다.
9. 각 수직 기능을 이전 commit으로 되돌렸을 때 앱이 다시 빌드되고 정상 동작한다.

## 3. 포팅의 원리

### 3.1 코드를 복사하지 않고 계약을 연결한다

Showcase는 카탈로그 코드를 원본 앱에 복사하기 위한 샘플 앱이 아니다. Runtime Kit의 실제 공개
컴포넌트가 올바른 상태와 화면 크기에서 어떻게 보이는지를 검증하는 소비자다. Navigation도 같은
package를 다른 소비자로 연결한다.

```text
Navigation의 API·도메인·지도·경로 상태
                    ↓
             앱 소유 어댑터
                    ↓
Runtime Kit의 공개 props·상태·callback
                    ↓
              사용자 입력
                    ↓
Navigation의 저장·공유·이동·안내 동작
```

그 결과 다음 경계가 생긴다.

| Navigation이 소유 | 앱 어댑터가 수행 | Runtime Kit이 소유 |
|---|---|---|
| 장소·건물·층 ID와 API 모델 | 제목, metadata, 표시 상태로 변환 | 헤더, 목록, Badge의 위계와 geometry |
| 검색 loading·empty·error·ready | 하나의 명시적 표시 상태로 변환 | 검색 표면과 상태별 시각 표현 |
| 저장 여부와 실행 | 선택 상태와 단일 callback 제공 | 저장 action의 크기·색·focus·semantics |
| 길찾기·안내 상태 | ETA, 남은 시간·거리, 안내 문구로 변환 | 계획·진행·도착 패턴 |
| 지도·PDR 상태 | 의미 상태와 callback으로 변환 | 지도 컨트롤의 시각 규칙 |
| URI 수신과 장소 조회 | ID 검증, dedupe, 앱 준비 대기 | 공유 action과 오류·로딩 표현 |

### 3.2 어댑터는 얇고 명시적이어야 한다

- 디자인 시스템에 앱 model 전체를 넘기지 않는다.
- 여러 nullable 값이나 boolean 조합보다 enum 또는 sealed state를 사용한다.
- 변환은 가능하면 순수 함수로 만들고 단위 테스트한다.
- API 호출, Navigator 조작과 platform share는 callback 밖의 앱 계층에 둔다.
- 로딩과 빈 결과를 같은 skeleton 상태로 처리하지 않는다.
- 디자인 시스템은 소비 앱 파일명, route 이름, provider 존재를 알지 못한다.

### 3.3 수직 기능 단위로 옮긴다

foundation 전체, 컴포넌트 전체, 앱 전체를 한 번에 교체하지 않는다. 예를 들어 장소 상세를
옮길 때는 헤더 한 조각만 바꾸고 나머지를 오래 이중 유지하지 않는다. 장소 상세를 이루는 데이터
어댑터, header, actions, hours, 상태, 테스트를 하나의 수직 기능으로 끝낸다.

각 수직 기능은 다음 순서를 반복한다.

```text
기존 동작 고정 → 앱 상태 어댑터 → Runtime Kit 조합 → 상호작용 검증
→ 시각·접근성 검증 → 레거시 제거 → 문서 갱신
```

## 4. 패키지 공급 방법

### 4.1 병합 가능한 연결

Navigation의 `client/pubspec.yaml`에는 검토 완료된 불변 ref를 사용한다.

```yaml
dependencies:
  routex_design_system:
    git:
      url: https://github.com/Routex-labs/routex-design-system.git
      ref: <검토 완료 tag 또는 전체 commit SHA>
      path: packages/routex_design_system
```

- `client/pubspec.lock`을 함께 커밋한다.
- package가 private이면 개발자 두 운영체제와 CI의 checkout 권한을 실제로 검증한다.
- package 버전 상승은 별도 PR 또는 명확히 분리된 commit으로 처리한다.
- package 변경 내역, 영향 받은 앱 화면, migration 필요 여부를 기록한다.

Navigation이 소비하는 release는 `v0.2.0`이다. tag 이름이 아니라 그것이 가리키는 전체 SHA를 적는다 —
tag는 나중에 옮길 수 있고, 그러면 같은 앱 커밋이 다른 package를 가리키게 된다. 다음 release도
같은 절차를 거치기 전에는 앱이 소비하지 않는다.

Navigation은 Dart `^3.12.2`, Runtime Kit은 Dart `^3.12.2`와 Flutter `>=3.44.0`을 요구하므로
현재 선언만 보면 SDK 축은 맞는다. 그래도 소비 앱 CI의 실제 Flutter 버전을 기준으로
`flutter pub get`을 확인해야 한다. 선언이 맞는 것과 resolver·플러그인·플랫폼 빌드가 맞는 것은
다른 문제다.

의존성 변경 시 기존 두 로컬 예외를 훼손하지 않는다.

- `indoor_pdr_core`는 Navigation 저장소 내부 path package다.
- `objective_c`는 Xcode 26 대응을 위해 저장소의 patched package로 override한다.

디자인 시스템을 추가하면서 `dependency_overrides` 블록을 통째로 교체하거나 `objective_c`를
업스트림으로 돌리는 것은 UI 포팅 범위를 벗어난 회귀다.

### 4.2 로컬 동시 개발

두 저장소를 함께 수정할 때만 gitignore된 `pubspec_overrides.yaml`로 sibling package를 연결한다.

```yaml
dependency_overrides:
  routex_design_system:
    path: ../../navdesignsystem+promo/packages/routex_design_system
```

로컬 path는 폴더 구조가 다른 개발자와 CI에서 깨지므로 commit하지 않는다. 로컬 검증을 마치면
패키지 변경을 먼저 검토·release하고, 앱은 새 불변 ref를 소비해야 한다.

### 4.3 공급 release 게이트

다음이 모두 확인되기 전에는 소비 앱 PR을 열지 않는다.

- 디자인 시스템 작업 트리의 release 대상이 확정돼 있다.
- Runtime Kit과 Showcase가 같은 commit을 사용한다.
- package analyze·test·golden이 통과한다.
- 공개 export와 beta 상태가 문서화돼 있다.
- CHANGELOG에 앱 영향과 breaking 여부가 적혀 있다.
- 기준 문서가 해당 tag의 permalink로 고정돼 있다.

## 5. 테마 연결 방법

Navigation은 현재 자체 `ThemeData`와 Pretendard 설정을 사용한다. 첫 단계에서 이를
`RoutexTheme.light`로 통째로 교체하면 아직 포팅하지 않은 Material 위젯도 한꺼번에 바뀌므로
영향 범위를 판별할 수 없다.

초기 포팅은 **테마 브리지**를 사용한다.

1. Navigation의 기존 `ThemeData`와 font 설정을 유지한다.
2. Runtime Kit이 요구하는 `RoutexColorTokens.light` ThemeExtension과 최소 semantic 설정을
   기존 테마에 연결한다.
3. 포팅된 수직 기능은 Runtime Kit 컴포넌트와 token만 사용한다.
4. 아직 옮기지 않은 화면은 기존 테마로 유지한다.
5. 모든 제품 화면과 전체 앱 golden을 검토한 뒤에만 전역 `RoutexTheme.light` 전환을 별도
   변경으로 판단한다.

현재 `AppTheme.light`는 `CardTheme`, `FilledButtonTheme`, `TextButtonTheme`, 입력창, FAB,
progress indicator, ListTile과 divider까지 전역으로 지정한다. 반면 현재 `RoutexTheme.light`는
ColorScheme, Runtime Kit text theme, ThemeExtension, focus/divider/disabled semantic 값까지만
제공한다. 둘을 즉시 바꾸면 다음이 동시에 일어나므로 첫 포팅 PR에서 허용하지 않는다.

- legacy Material 카드의 radius·elevation·border가 바뀐다.
- 기존 입력창과 버튼의 padding·shape·text style이 바뀐다.
- `AppElevation.onMap < chrome < overlay`를 검사하는 기존 테스트의 전제가 사라진다.
- 앱이 직접 선언한 `fontFamily: 'Pretendard'`가 사라질 수 있다.

브리지 구현의 판정 기준은 “Runtime Kit이 렌더링된다”가 아니라 **포팅하지 않은 위젯의 계산된
ThemeData가 이전과 같다**는 것이다. `AppTheme.light.copyWith(extensions: [...])`처럼 연결할 경우
기존 extension을 덮어쓰지 않고 병합해야 한다. 향후 전역 전환 때도 앱의 Pretendard asset과
지도 font stack은 별개 계약이므로 함께 삭제하지 않는다.

`context.routexColors`가 토큰을 찾지 못해 예외가 나는 경우 임의 기본색을 반환하지 않는다. 테마
설치 누락으로 보고 고친다.

제품 UI 토큰과 지도 시각화 토큰도 분리한다. Navigation의 기존 색은 MapLibre style, painter,
경로선에 쓰일 수 있으므로 UI 포팅만으로 일괄 삭제하지 않는다. 지도 영역은
`RoutexMapVisualTokens` 대응표를 만든 뒤 별도 단계에서 옮긴다.

## 6. 포팅 순서와 단계별 게이트

이 순서는 영향 범위가 작은 계약부터 증명하고, 지도·gesture·딥링크처럼 실패 피해가 큰 영역으로
확장한다. 앞 단계가 완료되지 않으면 다음 단계로 넘어가지 않는다.

### 단계 0. 기준선과 release 고정

진행:

- 사용할 package tag/SHA와 기준 문서 permalink를 정한다.
- Navigation의 관련 기존 테스트를 실행한다.
- 검색, 장소 상세, 저장한 장소, 안내 전·중·도착의 상태별 캡처를 남긴다.
- 360/390px와 글자 배율별 동작을 기록한다.
- 지도 pass-through, sheet drag, scroll, reorder와 callback 횟수를 characterization test로
  고정한다.

통과 기준:

- 기존 실패와 새 회귀를 구분할 수 있다.
- 화면별 앱 책임과 디자인 시스템 책임이 표로 정리돼 있다.
- 불변 package ref를 모든 개발·CI 환경에서 가져올 수 있다.

### 단계 1. 의존성과 테마 브리지

진행:

- package와 lockfile을 연결한다.
- 기존 앱 theme에 필요한 ThemeExtension을 설치한다.
- 내부 진단 화면 또는 첫 저위험 컴포넌트에서 typography, color, focus, divider, elevation을
  확인한다.

통과 기준:

- 아직 포팅하지 않은 화면의 golden diff가 0이다.
- Runtime Kit 컴포넌트가 token 누락 없이 렌더링된다.
- macOS·Windows·CI의 dependency restore와 전체 테스트가 통과한다.

### 단계 2. 저위험 기반 요소

진행:

- Badge, Chip, status banner의 의미를 분리한다.
- 공통 list cell의 아이콘 열, 텍스트 시작선, 제목·설명 간격을 적용한다.
- 영업시간을 접힘 상태 `영업 중 · 20:00 종료`, 펼침 상태 `화 · 10:30–20:00` 계열로
  연결한다.
- 저장 성공 feedback을 실행 취소가 있는 단일 notice로 통일한다.
- 동일 상태에서 반복되는 toast와 skeleton을 한 개로 제한한다.

통과 기준:

- NEW·시즌 한정은 읽기 전용 Badge, 사용자 필터는 Chip이다.
- GPS 약함은 낮은 강도의 Badge 또는 미표시이며 경로 이탈보다 강하지 않다.
- 같은 역할의 행은 같은 시작선·baseline·inset을 사용한다.
- 한 사건에 feedback이 정확히 한 번 나타난다.

### 단계 3. 하단 시트

진행:

- 장소 상세와 카테고리 매장처럼 이미 draggable인 sheet부터 공통 표면으로 옮긴다.
- `DraggableScrollableSheet`가 준 scroll controller를 실제 목록에 전달한다.
- Navigation의 map pass-through route와 overlay guard는 유지한다.
- handle은 실제 min/max extent 사이를 끌 수 있는 sheet에 한 개만 둔다.
- 저장한 장소는 현재 reorder 제약이 있으므로 우선 고정형을 유지하고 handle을 넣지 않는다.

통과 기준:

- sheet 밖에서 지도를 tap·pan·zoom할 수 있다.
- sheet drag, 내부 scroll, 닫기, back이 각각 한 번만 동작한다.
- favorites reorder 중 assertion, scroll jump, 원치 않는 sheet drag가 없다.
- 고정 카드와 검색 dropdown에 handle이 없다.

### 단계 4. 검색과 결과 목록

진행:

- 최근 검색, 자동 완성, 결과 목록을 각각 하나의 수직 기능으로 옮긴다.
- 결과 수와 정렬 action을 같은 header baseline에 둔다.
- 행은 공통 icon, content, trailing 열을 사용한다.
- 상단 공간은 surface inset token으로만 결정한다.
- loading·empty·error·ready를 명시적으로 분리한다.

통과 기준:

- 검색 결과와 최근 검색의 상단 여백이 공통 계약과 일치한다.
- 같은 skeleton이 한 상태에 두 번 보이지 않는다.
- 결과 선택, 정렬 변경, 최근 검색 선택의 기존 동작이 유지된다.
- 글자 배율 2.0에서 header와 행이 겹치지 않는다.

### 단계 5. 장소 상세와 공유

진행:

- 비동기 상세 조회와 즐겨찾기 controller는 앱에 유지하고 표시부만 옮긴다.
- 상세 header는 `이름 / 층 · 분류 · 세부분류`로 끝내며 도보 시간을 반복하지 않는다.
- 공유는 저장과 같은 장소 수준 header action에 두고 출발·도착 행에 섞지 않는다.
- 저장과 공유의 결과 feedback을 분리한다.
- 장소 링크는 [`place-detail-guidance-decisions.md`](place-detail-guidance-decisions.md)의 builder,
  parser, coordinator, exact-ID 복원 순서로 구현한다.

통과 기준:

- 승인된 장소 상세 상태와 같은 구조·시각을 사용한다.
- 저장과 공유 callback 및 feedback이 각각 한 번이다.
- cold/warm start가 정확히 같은 `buildingId`·`placeId`를 연다.
- 잘못된 링크와 삭제 장소에서 다른 장소를 열지 않는다.

### 단계 6. 안내 전·안내 중·도착

진행:

- 안내 전은 절대 도착 시각, `소요 22분 · 1.4km 거리`, 단일 primary action으로 구성한다.
- 카드의 취소가 상단 길찾기 닫기와 중복되면 제거한다.
- 안내 중은 절대 도착 시각, 남은 시간, 남은 거리를 서로 다른 값으로 표시한다.
- 경로 이탈은 error 색의 일시적 상단 안내로 표시하고 자동 재탐색을 알린다.
- 도착 문구는 상단 status banner 한 곳에서만 사용하고 하단에는 후속 행동만 둔다.

통과 기준:

- 계획 카드에 의미 없는 큰 빈 공간과 중복 취소가 없다.
- `6분 후`와 `6분`처럼 같은 계산값을 반복하지 않는다.
- 경로 이탈이 GPS 약함보다 높은 우선순위로 인지된다.
- 수동 `경로 다시 찾기` action과 중복 도착 문구가 없다.
- Dijkstra·PDR·지도 경로 테스트 결과가 포팅 전과 같다.

### 단계 7. 지도 컨트롤과 map visual token

진행:

- 층, 저장, 내 위치, 방향 컨트롤을 공통 컨테이너·간격·hit-area 계약에 연결한다.
- glyph 크기 차이는 개별 padding이 아니라 공통 frame과 문서화된 optical correction으로
  해결한다.
- MapLibre, 경로선, painter 색은 별도 map visual 대응표로 옮긴다.

통과 기준:

- 같은 계열 컨트롤의 외곽 폭과 터치 영역이 일치한다.
- glyph의 시각 중심이 맞고 focus·semantics가 유지된다.
- 지도 style, route line, camera 동작에 의도하지 않은 변화가 없다.

### 단계 8. 레거시 제거와 최종 전환 판단

진행:

- 참조가 0인 앱 전용 pill, handle, header, 색상·간격 상수를 제거한다.
- 기능 포팅과 레거시 삭제는 논리적으로 분리된 commit으로 만든다.
- 실제 파일, 상태, 테스트와 문서를 맞춘다.
- 모든 제품 화면이 옮겨진 경우에만 전역 `RoutexTheme.light` 전환을 별도 검토한다.

통과 기준:

- 포팅된 범위에 raw 시각 값과 중복 컴포넌트가 없다.
- 방치된 코드와 낡은 문서가 없다.
- 전체 회귀·시각·접근성 검증이 통과한다.

## 7. 원본 앱의 주요 포팅 대응표

구체적인 파일 존재와 역할은 착수 시 Navigation의 해당 ref에서 다시 확인한다. 아래 표는 현재
구조를 기준으로 한 계획이며 소비 앱 파일을 디자인 시스템 계약으로 만들지는 않는다.

| 제품 영역 | Navigation의 현재 책임 | Runtime Kit 연결 | 주요 위험 |
|---|---|---|---|
| 장소 상세 sheet | 비동기 조회, 즐겨찾기, 지도 focus, draggable 상태 | bottom sheet, sheet header, place header/actions, hours | 지도 pass-through와 scroll controller |
| 카테고리 매장 sheet | 카테고리 상태와 매장 선택 | 확장형 sheet, result/list cell | drag와 내부 scroll 충돌 |
| 저장한 장소 | 저장 상태, 삭제, reorder | 고정형 surface와 list cell부터 적용 | reorder와 sheet drag 충돌 |
| 검색 패널 | query, 최근 검색, API 상태, 선택 | search, result header/list, skeleton/empty | 상태 중복과 callback 중복 |
| 경로 입력 결과 | 출발·도착 상태, 결과 선택 | 공통 result list | 결과 header 기준선 |
| 안내 전 | route 계획, 시작/취소 동작 | ETA card | pointer guard와 중복 취소 |
| 안내 중 | 위치·ETA·남은 값·재탐색 | maneuver, trip progress, status banner | 의미가 다른 값의 중복 |
| 도착 | 도착 판정, 안내 종료, 후속 행동 | status banner와 action surface | 상·하단 문구 중복 |
| 지도 컨트롤 | MapLibre/PDR callback과 선택 상태 | floor selector, map control | glyph optical alignment와 hit area |

### 7.1 포팅 중 교체하면 안 되는 원본 계약

아래 코드는 겉모양을 그리는 것처럼 보여도 실제로 상태·gesture·지도 정확성을 지킨다. Runtime Kit
컴포넌트로 감싸거나 그 안에 넣을 수는 있지만 책임을 package로 옮기거나 삭제하지 않는다.

| 원본 심볼 | 유지할 계약 | 잘못된 포팅 예 |
|---|---|---|
| `NavigationApp.didChangeAppLifecycleState` | inactive를 무시하고 PDR background/foreground 경합 방지 | 링크 plugin을 붙이며 기존 observer를 새 observer로 대체 |
| `_MapShellScreenState._runSheetChain` | X가 nested sheet 전체를 닫고 이전 sheet가 다시 열리지 않음 | 각 `RoutexSheetHeader.onClose`에서 현재 route만 pop |
| `_withMapsLocked` | 웹에서만 MapLibre DOM wheel을 잠그고 native 지도는 계속 조작 가능 | 모든 플랫폼에서 sheet가 열리면 지도 비활성화 |
| `MapPassThroughSheetRoute.buildModalBarrier` | sheet 위 빈 지도 영역의 pointer 통과 | `showModalBottomSheet`에 투명 barrier 색만 지정 |
| `MapOverlayGuard` | 웹 sheet 영역의 pointer가 DOM 지도까지 새지 않음 | Flutter 위젯만 보고 guard 제거 |
| `DraggableScrollableSheet(expand: false)` | 실제 sheet 영역만 hit-test하고 위쪽은 지도에 전달 | `expand: true` 또는 화면 전체 opaque detector 추가 |
| sheet의 전달 `scrollController` | drag extent와 내부 scroll 연결 | 새 `ScrollController`를 목록 안에서 생성 |
| `_intentionalPop`과 `PopScope` | back/X/선택과 drag dismiss를 구분해 chain close | `Navigator.pop`만 남기고 flag 제거 |
| `_requestId`, `_routeSearchSeq`, debounce | 늦은 검색 응답이 새 질의를 덮지 않음 | 디자인 상태 adapter에서 비동기 요청을 다시 수행 |
| `reachableFrom`, `_reachByNodeId` | 거리와 비용을 온디바이스에서 한 번 계산해 여러 화면에 공유 | 행 컴포넌트가 자체 거리 계산 또는 서버 요청 |
| `_mapOverlayTapGuard`, `onClosePointerDown` | 웹에서 닫기 tap이 뒤의 MapLibre click으로 재발화하지 않음 | 새 버튼 callback만 연결하고 pointer-down wiring 제거 |
| `_syncArrival`과 `arrivalAutoClearDelay` | 경로는 지우되 확인 surface는 남기고 timer 중복 방지 | 도착 UI를 바꾸며 timer·highlight까지 재구현 |
| `_rerouteIndoorFromCurrentPosition` | 목적지는 유지하고 anchor 층에서 자동 재탐색 | 경로 이탈 banner action으로 수동 재탐색 호출 |

### 7.2 실제 상태를 Runtime Kit에 연결하는 표

Runtime Kit의 상태 enum이 원본 앱의 모든 상태를 대신하지 않는다. 표현 가능한 부분만 매핑하고,
나머지는 공개 primitive를 조합하거나 먼저 공급자 계약을 보강한다.

#### 검색

| Navigation `_SearchPhase` | 표시 계약 | 연결 방법 |
|---|---|---|
| `idle` | 최근 검색 또는 검색 안내 | `RoutexSectionHeader` + `RoutexListCell`; 결과 목록의 empty로 처리하지 않음 |
| `typingLightSearch` | 빠른 1차 검색 진행 | `RoutexResultStatus.loading`, `loadingMessage: '매장을 찾는 중'` |
| `semanticSearching` | 더 긴 의미 검색 진행 | 같은 loading이되 메시지를 `추천 결과를 찾는 중`처럼 구분 |
| `clarify` | 질문, 선택 Chip, 선택 결과 | `RoutexChipBar`와 ready 결과를 조합; empty로 축약하지 않음 |
| `results` | 확정 결과 | `RoutexResultStatus.ready` |
| `suggestions` | 온디바이스 후보 | ready 목록. 오타 교정 여부와 ID callback 유지 |
| `noMatch` | 모든 검색 경로 종료 후 빈 결과 | 이때만 `RoutexResultStatus.empty` |
| `degraded` | 일부 검색 기능 사용 불가 | warning `RoutexStatusBanner`와 남은 결과를 조합 |
| `error` | 검색 자체를 끝내지 못함 | error `RoutexStatusBanner`; empty로 표시 금지 |

`RoutexResultStatus`에는 현재 error/degraded/clarify가 없다. 이를 억지로 empty/ready에 넣어 의미를
잃지 않는다. 조합만으로 승인된 시각을 유지할 수 없으면 Navigation에 앱 전용 사본을 만들지 말고
Runtime Kit 공개 pattern을 먼저 보강한다.

현재 검색 행은 다음 정보를 가진다.

- 검색어 일치 구간 강조
- 이름, 소분류 또는 대분류 fallback
- 층, 건물명, 추천 이유, 경로 안내 불가
- 도달 가능할 때만 거리·도보 시간
- 검색 결과, 자동완성, 건물, 야외 POI에 따른 서로 다른 callback

`RoutexListCell`의 현재 공개 입력은 plain `title`, 한 개 `subtitle`, 의미 icon과 callback이다.
포팅 시 정보를 조용히 버리거나 앱에서 custom Row를 끼우지 않는다. 승인된 목표 화면에 필요한
정보 순서를 먼저 정한 뒤 다음 중 하나로 해결한다.

1. 한 subtitle 문장으로 합쳐도 정보·위계가 유지되면 앱 adapter에서 문자열을 만든다.
2. 강조나 두 보조 줄이 제품 계약이면 Runtime Kit의 의미형 입력을 보강하고 Showcase·golden을
   먼저 검증한다.
3. 제품 결정으로 정보를 제거한다면 기존 테스트를 삭제해서 숨기지 말고 결정 문서와 대체 테스트를
   함께 남긴다.

#### 장소 상세

| 원본 값·상태 | Runtime Kit 입력 | 규칙 |
|---|---|---|
| `title` | `RoutexPlaceHeader.name` | 최대 두 줄 규칙은 component가 소유 |
| `floor`, `subcategory ?? category` | `metadata` | 빈 값을 제거해 `층 · 분류`로 조합 |
| `reach` | 상세 header에는 전달하지 않음 | 검색 결과에는 유지, 선택 후 상세의 도보 시간 반복 제거 |
| `category` icon | 상세에서는 `leadingIcon: null` | 합의한 상세 header에서 장식 매장 icon 제거 |
| favorites `contains(key)` | `saved` | 상태 원본은 `FavoritesController` |
| toggle callback | `onSaved` | component가 준 bool을 신뢰해 직접 저장 상태를 만들지 말고 controller 실행 후 실제 상태 확인 |
| 유효한 공유 계약 | `onShare` | ID·HTTPS origin 중 하나라도 없으면 null로 숨김 |
| `StoreInfoAction` | `RoutexPlaceActions` callback | enum과 상위 `_showStoreInfo` 분기는 그대로 유지 |
| `_isLoading` | detail skeleton 한 벌 | header와 출발·도착은 즉시 유지 |
| `_isExcluded` | 상세 section 없음 | excluded 분류를 UI 문자열로 다시 판정하지 않음 |
| `_visibleSections` | tabs, menu, info, link, media 공개 pattern | `MapSection` 제외와 서버 순서 유지 |

저장 feedback은 현재 `_onToggleFavorite` 안의 `ScaffoldMessenger.showSnackBar`가 담당한다. 이를
그대로 둔 채 `RoutexInlineNotice`를 추가하면 두 개가 된다. 한 PR에서 기존 snackbar 호출을 제거하고
상태 하나가 소유하는 notice 한 개로 바꾼다. 저장 취소도 같은 host에서 문구와 undo 가능 여부를
명시한다. 플랫폼 공유 취소는 저장 feedback을 닫거나 오류를 띄우지 않는다.

#### 영업시간

판정은 `client/lib/domain/store/store_hours.dart`를 그대로 사용한다. Runtime Kit은 판정하지 않는다.

```text
computeStoreHoursStatus(hours, now) → RoutexHoursState
storeHoursWeek(hours, now)          → List<RoutexHoursDay>
```

어댑터 규칙은 다음과 같다.

- `StoreOpenState.open/closed/unknown`을 같은 이름의 `RoutexHoursState`에 매핑한다.
- `nextChangeAt`은 기존 `_detailText` 규칙으로 `20:00 종료`, `내일 10:30 영업 시작`을 만든다.
- 각 `StoreHoursDay.date`는 `weekdayLabelOf(date)`만 `label`로 사용한다.
- interval은 기존 순서를 유지해 `10:30 - 20:00 · 21:00 - 23:00`처럼 만든다.
- `intervals.isEmpty`면 `value: '휴무'`, `closed: true`다.
- 예외의 `note`는 유지한다. 날짜를 매주 반복하지 않는 것과 예외 날짜 정보를 없애는 것은 다르다.
- `status.isStale`이면 확인일과 오래됐을 수 있다는 근거를 `staleNote`로 전달한다.

#### 안내와 도착

현재 `EtaCard` 하나가 야외 계획, 자동 경로, 실내 안내와 도착까지 분기한다. 이 private 분기를
Runtime Kit 위젯 하나로 다시 만들지 말고 `OutdoorMapBody._buildBody`에서 제품 상태별 pattern을
명시적으로 고른다.

| 현재 조건 | 목표 pattern | 원본 계산 |
|---|---|---|
| 자동차 계획 `_offerStartGuidance` | `RoutexEtaCard` | `_outdoorEta(route)`, 지역화한 절대 도착 시각, `startFollowingCurrentLocation` |
| 안내 전 실내/도보 계획 | `RoutexEtaCard` | `_indoorEta()` 또는 `_outdoorEta(route)`; 시작 동작 존재 여부는 제품 상태로 명시 |
| 실내 turn-by-turn | `RoutexManeuverBanner` + `RoutexTripProgress` | `_indoorRouteGuidance`, `_indoorEta`, `_dismissIndoorRouteFromEtaCard` |
| wrong-way | 상단 error `RoutexStatusBanner` | `RouteGuidanceAction.wrongWay`; 재탐색은 기존 자동 경로가 담당 |
| GPS accuracy 저하 | 작은 warning `RoutexBadge` 또는 미표시 | `_outdoorGpsVisible`과 accuracy 50m 기준 유지 |
| arrival | 상단 성공 상태 한 번 + 하단 후속 행동 | `_arrivedDestination`, `_confirmArrival`, highlight·timer 유지 |

현재 도착 순간에는 `_arrivedDestination`의 중앙 `IndoorArrivalCard`와
`indoorRouteDestination`의 하단 `EtaCard`가 timer가 끝날 때까지 함께 렌더링될 수 있다. 포팅에서는
`_arrivedDestination != null`일 때 안내 중 pattern을 렌더링하지 않아 중복을 구조적으로 막는다.
`RoutexStatusBanner`와 `RoutexArrivalCard`는 둘 다 도착 문구를 소유하므로 동시에 사용하지 않는다.
권장 구조인 상단 상태 + 하단 후속 행동을 택하면 하단은 `RoutexBottomSheet`와 `RoutexButton`으로
행동만 조합한다. `RoutexArrivalCard`를 택하면 그 하나가 상태와 행동을 대체해야 한다.

### 7.3 파일별 실제 변경 절차

#### `client/pubspec.yaml`

1. 불변 Runtime Kit ref를 dependencies에 추가한다. (적용 완료)
2. 장소 링크 단계에서 검토한 URI 수신 package를 별도 추가한다.
3. 기존 `indoor_pdr_core` path와 `objective_c` override를 보존한다. (적용 시 확인 완료 —
   lockfile 변화는 `routex_design_system` 항목 9줄 추가뿐이고 transitive plugin은 그대로다.)
4. `flutter pub get` 후 lockfile의 Runtime Kit ref와 transitive plugin 변화를 검토한다.
5. package가 가진 Pretendard와 앱 asset의 중복 번들 크기를 측정한다. 첫 단계에서는 앱 font 선언을
   제거하지 않는다.

5번 측정 결과(`flutter build bundle`의 `FontManifest.json`)는 다음과 같다. 두 벌은 SHA-256이 서로
같은 파일이다.

| family | 위치 | 크기 |
|---|---|---|
| `Pretendard` | `assets/fonts/` | 7.6MB (5 face) |
| `packages/routex_design_system/Pretendard` | `packages/routex_design_system/assets/fonts/` | 7.6MB (5 face) |

즉 다리를 놓는 것만으로 번들이 약 7.6MB 늘고, 웹에서는 그만큼이 그대로 내려간다. 그런데 **두 벌은
모두 실제로 쓰인다.** `RoutexTypography`의 모든 style은 `package: 'routex_design_system'`을 넘기므로
Runtime Kit 텍스트는 `packages/routex_design_system/Pretendard`로 해석되고, 앱이 소유한 Material
텍스트와 지도 fontstack·mock SVG는 앱이 선언한 `Pretendard`로 해석된다
(`test/core/pretendard_font_assets_test.dart`). 이름이 다른 두 family라 한쪽이 다른 쪽을 대신하지
못한다.

따라서 한 벌로 줄이는 것은 asset 정리가 아니라 **font family 계약을 어느 쪽으로 정할지**의 문제이며,
전역 theme 전환(단계 8)에서 함께 판단한다. 그전에 한쪽 선언만 지우면 지우는 쪽 텍스트가 조용히
플랫폼 기본 글꼴로 떨어진다.

#### `client/lib/app.dart`와 routing

1. `AppTheme.light`에 Runtime Kit ThemeExtension을 병합하되 `NavigationApp`의 PDR observer는
   그대로 둔다.
2. 링크 수신은 `initState`에서 한 번 구독하고 `dispose`에서 취소한다. hot restart·background 복귀로
   listener가 누적되지 않는 테스트를 추가한다.
3. initial URI와 stream URI를 `PlaceLinkIntent(buildingId, placeId)` 하나로 정규화한다.
4. `MaterialApp.routes`에 동적 place path를 문자열로 억지 등록하지 않는다. 현재 상세는 modal이고
   지도 준비가 선행돼야 하기 때문이다.
5. intent는 앱 소유 coordinator/controller로 `MapShellScreen`에 전달한다. private State를 깨려고
   외부 `GlobalKey<_MapShellScreenState>`를 만들지 않는다.
6. shell과 지도 store index가 준비되기 전 intent는 한 개만 보류하고, 같은 URI는 dedupe한다.

`NavigationApp`의 widget test가 `home`을 주입해 `outdoorMap` route를 제거하는 계약도 보존한다.
link coordinator가 test home 위에 강제로 map shell을 열면 기존 테스트 격리가 깨진다.

#### `client/lib/screens/map_shell/map_shell_screen.dart`

1. place intent 소비 진입점을 `_runSheetChain` 안에 둔다.
2. 현재 `intent.buildingId != _buildingId`면 다중 건물 전환이 없는 한 이용 불가로 끝낸다.
3. `buildingRepository.getStoreIndex(_buildingId)`에서 `entry.id == placeId`를 exact match한다.
4. 찾은 `StoreIndexEntry`를 `OutdoorMapBodyState.resolveIndexEntry`로 `PoiSearchResult`에 복원한다.
5. 복원 성공 시 기존 `_showStoreInfo(resolved, focusOnMap: true)`로 합류한다.
6. `resolveIndexEntry`가 실내 진입 전 타 층에서 null을 반환할 수 있음을 고려한다. 기존 검색의 이름
   재검색 fallback은 딥링크에는 사용하지 않는다. 링크는 정확성 우선으로 실패한다.
7. `_showStoreInfo`의 병렬 camera focus, `bottomSheetFraction`, `_nearbyOriginPlaceId`, highlight clear,
   `StoreInfoAction` 분기를 유지한다.

장기적으로 임의 건물 링크를 지원하려면 `_buildingId` 상수를 먼저 명시적 building session state로
바꾸고 repository cache, category future, floor overlay, route draft 초기화 규칙을 정해야 한다. 이는
디자인 포팅이 아니라 별도 제품·상태 architecture 작업이다.

#### `client/lib/screens/map_shell/widgets/sheets/place_detail_sheet.dart`

1. `show`, `MapPassThroughSheetRoute`, `MapOverlayGuard`, `PopScope`, `_intentionalPop`을 유지한다.
2. `DraggableScrollableSheet`의 0.5/0.3/0.92 extent와 `expand: false`를 우선 보존한다. 시각 검수로
   initial extent를 바꾸면 `focusStore(bottomSheetFraction: ...)`의 camera 계약도 함께 바꾼다.
3. builder가 준 controller를 `SingleChildScrollView`에 그대로 연결하고 keyboard bottom inset과
   overscroll 억제를 유지한다.
4. Material·개별 padding·`SheetGrabHandle`·`SheetHeader`·`_PlaceCore`·`_PlaceActions`의 표시 책임만
   `RoutexBottomSheet(showHandle: true)`, `RoutexSheetHeader`, `RoutexPlaceHeader`,
   `RoutexPlaceActions`로 교체한다.
5. 상세 header의 `supportingText`와 `leadingIcon`은 비운다. 검색 결과의 reach는 삭제하지 않는다.
6. `_loadDetailContent`와 `_loadNearbyStores`는 독립 완료 순서와 실패 격리를 유지한다.
7. section은 summary, hours, menu, business info, link, media, nearby의 데이터 순서와 조건을 먼저
   adapter로 만들고 하나씩 공개 pattern으로 옮긴다.
8. 공유 button의 `RenderBox`를 share 호출 직전에 읽어 iPad origin을 만든다. async 이전에 context와
   mounted 상태를 확인한다.

#### `client/lib/screens/map_shell/widgets/sheets/category_stores_sheet.dart`

1. `MapPassThroughSheetRoute`와 chain-close flag를 유지한다.
2. 0.55/0.35/0.9 extent 및 상위 camera의 `kCategoryStoresSheetInitialSize` 연결을 유지한다.
3. Future 하나가 건물 층별 GeoJSON을 순회하는 현재 로딩을 앱에 남긴다.
4. hidden subcategory, 층 정렬, 이름 보조 정렬, 현재 층의 첫 매장 callback을 표시 위젯으로 옮기지
   않는다.
5. `CustomScrollView(controller: scrollController)`를 유지한 채 header, filter, 상태, cell만 포팅한다.

#### `client/lib/screens/map_shell/widgets/sheets/favorites_sheet.dart`

1. 첫 포팅에서는 `showModalBottomSheet`, 최대 높이 80%, `ReorderableListView`를 유지한다.
2. 고정형이므로 Runtime Kit `showHandle`은 false로 둔다. 현재 `SheetGrabHandle`은 제거 대상이다.
3. `ListenableBuilder`를 유지한다. controller listener + `setState` 방식으로 되돌리지 않는다.
4. `ReorderableDelayedDragStartListener`, stable `ValueKey(place.key)`, `favoritesController.reorder`를
   유지한다.
5. `RoutexListCell(reorderable: true)`의 보이는 손잡이와 실제 long-press drag listener가 같은 의미를
   갖는지 widget test로 확인한다. 보이는 손잡이만 눌러 drag할 수 있다고 오해하게 만들지 않는다.
6. 확장형 favorites는 이 포팅에서 하지 않는다. 필요하면 gesture architecture와 테스트를 별도
   결정한다.

#### `client/lib/screens/map_shell/widgets/search/search_panel.dart`

1. `_SearchPhase`, debounce 300ms + semantic grace 400ms, `_requestId`를 그대로 둔다.
2. `_storeIndex`, `_suggestions`, `_sortOverride`, `_floorScopeOnce`, discovery facet 상태를 UI
   컴포넌트로 옮기지 않는다.
3. 먼저 `_body`의 상태별 composition을 adapter/view-model 경계로 분리한다.
4. 다음 PR에서 `_listHeader`, recent search, result row, empty/error를 하나씩 Runtime Kit으로 바꾼다.
5. `_resultScrollController`를 Scrollbar와 scroll view 양쪽에 계속 연결한다.
6. `ListView(shrinkWrap)`로 단순 교체하지 않는다. 현재 `SingleChildScrollView + Column` 선택에는
   keyboard와 제한 높이의 이유가 있으므로 실제 layout test 없이 바꾸면 안 된다.
7. `highlightedNameSpans`, nearest ordering, distinctive reason, indoor/outdoor merge는 domain/adapter로
   유지한다.

#### `client/lib/screens/map_shell/widgets/search/route_field_results.dart`

1. `RoutePlanField`에 따른 현재 위치 shortcut과 문구를 유지한다.
2. 야외에서는 `showPickOnMap`이 false인 계약을 유지한다.
3. shortcut도 결과도 없을 때 표면 자체를 숨기는 early return을 유지한다.
4. keyboard bottom inset, suggestion 우선순위, unreachable 문구와 reach 표시를 adapter에서 만든다.
5. 일반 검색 `RoutexResultList`와 같은 외형을 쓰더라도 출발·도착 선택 callback은 분리한다.

#### `client/lib/screens/outdoor_map/outdoor_map_screen.dart`

1. `_buildBody`의 위치·경로·도착 계산은 그대로 두고 widget 선택만 상태별 함수로 추출한다.
2. GPS Badge는 `_outdoorGpsVisible && (position == null || accuracy > 50m)` 조건을 유지한다. 위치가
   없는 실내 PDR 상태에서 GPS 경고를 만들지 않는다.
3. wrong-way 상단 banner의 표시 여부는 `_indoorRouteGuidance.action`과 재탐색 상태에서 파생한다.
   별도 reroute callback을 만들지 않는다.
4. `onClosePointerDown`을 Runtime Kit button 바깥 `Listener` 또는 의미형 callback 계약으로 보존한다.
5. 안내 배너 탭이 `RouteStepsSheet`를 여는 기존 동작과 종료 버튼 tap을 구분한다.
6. `_arrivedDestination`이 있으면 안내 중 bottom pattern을 숨기고 도착 표현 하나만 렌더링한다.
7. `_syncArrival`, `_syncArrivalHighlight`, `_confirmArrival`, route clear timer는 UI 교체와 분리한다.

### 7.4 현재 Runtime Kit의 선행 보강 후보

아래는 원본 앱 대조에서 확인한 공급자 API 간극이다. 앱에서 사설 복제품을 만드는 대신 실제
포팅 범위에 들어가기 전에 유지·제거할 제품 정보를 결정한다.

| 간극 | 현재 Runtime Kit | 원본 앱 요구 | 착수 게이트 |
|---|---|---|---|
| 검색 오류 상태 | `RoutexResultStatus`는 loading/empty/ready | degraded/error/clarify가 별도 | 공개 조합 예제와 golden 또는 의미형 상태 보강 |
| 검색 행 정보 | plain title/subtitle | 강조 span, 업종, 이유, 거리의 복수 위계 | 승인된 정보 순서와 API 확정 |
| favorites drag | `reorderable`은 손잡이 시각만 소유 | 실제 long-press reorder | semantics와 affordance test 확정 |
| 도착 권장 구조 | `RoutexArrivalCard`가 도착 문구+행동 소유 | 상단 상태 1회 + 하단 후속 행동 | 둘 중 하나만 쓰는 Showcase 상태 확정 |
| iPad 공유 anchor | `RoutexPlaceHeader.onShare`만 공개 | 실제 share icon의 non-zero bounds 필요 | header bounds 사용 승인 또는 action key/context 계약 보강 |
| draggable sheet 조합 | `RoutexBottomSheet`는 drag를 소유하지 않고 `expand`만 제공 | 전달 controller, scroll되는 header 여부, keyboard inset | 실제 Draggable fixture와 pointer test 통과 |
| theme font | `RoutexTheme.light`에 명시 font family 없음 | 앱·지도·SVG Pretendard 고정 | 브리지와 최종 theme font 계약 테스트 |
| route planner focus | `RoutexRoutePlanner`만 `Theme.of(context).focusColor`를 읽는다 | 브리지는 앱의 Material 기본 focus를 유지한다 | 단계 4 착수 전에 semantic focus 입력 보강 또는 국소 `Theme` 결정 |
| map overlay | semantic slot 중심 | shell의 동적 Column, keyboard inset, GlobalKey hit exclusion | 기존 pointer/key 계약을 표현할 수 있는지 proof |
| 칩 줄의 스크롤 소유권 | `RoutexChipBar`가 제 가로 뷰포트를 소유 | 지도 오버레이가 스크롤·휠·잠금을 이미 소유 | **닫힘.** `RoutexChipBarOverflow.deferToParent`(v0.2.3) |
| 선택 없음을 뜻하는 칩 | `selectedId: null`이면 강조된 칩이 없다 | 카테고리 시트가 `전체` 칩을 그리고 늘 하나가 선택돼 있다 | 단계 3 착수 전에 "반드시 하나 선택" 모드 결정 |
| 칩의 해제 어포던스와 개수 | 라벨만 | 고른 값에 `×`, 선택지에 `(개수)`, 조작 칩과 구분선 | 단계 4 착수 전에 검색 되물음 줄의 정보 순서 확정 |

이 표의 항목은 “나중에 개선” 목록이 아니다. 해당 기능을 포팅하려면 먼저 결정하고 공급자 release에
포함하거나, 원본 앱의 정보·동작을 의도적으로 폐기한다는 별도 제품 승인이 있어야 한다.

### 7.5 딥링크의 현재 앱 제약을 반영한 상세 절차

현재 앱은 건물 하나만 소유하므로 장소 공유는 두 단계로 나눈다.

#### 1차: 현재 demo 건물의 정확한 장소만 지원

- URL의 `buildingId`가 `demoBuildingId`와 정확히 같을 때만 처리한다.
- store index에서 `entry.id == placeId`를 exact match한다.
- 현재 floor·실내 overlay 준비가 필요한 복원은 `resolveIndexEntry`의 성공 여부를 따른다.
- 복원 실패 시 이름 검색으로 떨어지지 않고 링크 오류를 한 번 알린다.
- cold start intent는 MapShell과 OutdoorMap의 building/floor data가 준비될 때까지 한 개 보류한다.

#### 2차: 다중 건물 지원 후 범위 확대

- `_buildingId` 상수를 building session state로 교체한다.
- 건물 전환 시 category future, floor data, store index, highlight, search reach, route draft를 어느
  순서로 초기화할지 정한다.
- 전환이 완료된 뒤 exact place를 복원한다.
- 이전 건물의 async 응답이 새 건물을 덮지 않도록 generation/request ID를 둔다.

1차 지원만 출시하면서 다른 건물 URL을 생성하면 안 된다. 공유 builder가 만들 수 있는 범위와
수신 coordinator가 열 수 있는 범위는 같아야 한다.

#### 플랫폼 연결 확인점

Android는 `client/android/app/src/main/AndroidManifest.xml`의 `MainActivity`에 현재 launcher
intent만 있다. 장소 링크를 추가할 때 기존 launcher filter를 수정하지 않고 별도의 HTTPS filter를
추가한다.

- `android:autoVerify="true"`
- `VIEW`, `DEFAULT`, `BROWSABLE`
- 확정된 `https` scheme과 서비스 host
- `/place` 이하만 받는 path 제한
- 현재 `launchMode="singleTop"`에서 실행 중 URI가 stream으로 한 번 전달되는지 실기기 확인

iOS에는 현재 Runner entitlement 파일이 없다. 다음을 하나의 플랫폼 설정 변경으로 검증한다.

- `Runner.entitlements` 생성 또는 기존 signing 설정에 associated domains capability 추가
- `applinks:<서비스 도메인>` 등록
- Xcode build configuration의 `CODE_SIGN_ENTITLEMENTS` 연결
- 서비스 domain의 `apple-app-site-association`에 실제 Team ID와 bundle ID 등록
- 앱 미설치, 앱 종료, background, foreground 각각에서 Safari와 메신저 링크 확인

서비스 쪽에는 Android `assetlinks.json`과 iOS association 파일, 미설치 사용자가 볼 HTTPS fallback이
같은 release 전에 있어야 한다. custom scheme은 개발 진단에 쓸 수 있어도 공유 canonical URL로
사용하지 않는다.

`RoutexPlaceHeader`의 현재 `onShare`는 callback만 제공하므로 iPad popover anchor를 어디서 읽을지
선행 결정이 필요하다. header 전체 bounds를 쓰면 플랫폼 요구는 충족하지만 popover의 시각 anchor가
share icon과 어긋날 수 있다. 정확한 icon bounds가 기준이면 외형을 바꾸지 않는 public action key
또는 context 계약을 Runtime Kit에 추가하고 fixture test로 고정한다. 앱에서 descendant 구조를
탐색하거나 package private key에 의존하지 않는다.

### 7.6 기존 테스트의 유지·변경·신규 구분

포팅은 기존 테스트를 전부 golden으로 갈아치우는 작업이 아니다. 테스트마다 다음처럼 처리한다.

#### 그대로 유지할 계약

- `place_detail_sheet_test.dart`: 로딩 중 core/action 즉시 표시, excluded 처리, action 한 벌,
  overscroll 없음, 저장 시 sheet 유지, `StoreInfoAction`, back/X chain 의미
- `search_panel_test.dart`: 9개 상태로 이어지는 검색 의미, 최신 응답 우선, 정렬, 최근 검색,
  suggestion ID, indoor/outdoor 분기, 거리·비용 규칙
- `store_hours_test.dart`: 개·폐점 경계, 자정 넘김, 예외, stale, timezone
- `route_guidance_test.dart`: wrong-way 우선, 다음 행동 거리, 중간 층 비도착, 최종 도착
- `route_arrival_auto_clear_test.dart`: timer 한 번, 진행률 없는 근접 경로 비자동 종료
- `dijkstra_test.dart`와 PDR·지도 style·route line 테스트 전부
- `pretendard_font_assets_test.dart`: 앱·지도·SVG font 계약

#### 합의된 디자인에 맞게 기대를 교체할 계약

- 상세의 `거리와 도보 시간을 ... 보여준다` 테스트는 **상세에는 도보 시간이 없다**로 바꾼다.
  검색 결과의 reach 테스트는 유지한다.
- 영업시간 widget test의 `화(8/11)` 기대는 `화 · 10:30 - 20:00`과 예외 note 유지로 바꾼다.
- legacy ETA의 `약 7분 / 480m` 기대는 절대 도착 시각과 `7분 소요 · 480m 거리`로 바꾼다.
- 도착 ETA와 중앙 arrival card를 각각 기대하던 테스트는 한 화면에서 도착 문구가 한 번만
  존재하는 통합 widget test로 바꾼다.
- GPS Badge와 wrong-way는 강도·위치·action 없음까지 새 테스트로 고정한다.

기존 기대를 바꾸는 commit에는 이 문서 또는 제품 결정 문서를 연결한다. 단순히 테스트가 실패한다는
이유로 finder를 삭제하거나 `findsNothing`을 느슨하게 만들지 않는다.

#### 새로 필요한 회귀 테스트

- `MapPassThroughSheetRoute` 위 빈 영역의 pointer가 지도 mock에 도달함
- sheet 내부 tap/scroll은 지도 mock에 도달하지 않음
- favorites reorder와 dismiss gesture가 충돌하지 않음
- save/share callback과 feedback이 각 한 번
- URI parser의 host/path/percent encoding/누락·여분 segment
- cold/warm URI dedupe와 shell 준비 전 보류
- 다른 building ID, 없는 place ID, 삭제 장소에서 modal 0개
- 동명 매장 중 exact ID 한 개만 열림
- iPad `sharePositionOrigin`이 non-zero
- `_arrivedDestination` 동안 안내 중 banner 0개, 도착 상태 1개
- 360/390px × text scale 1.0/1.3/2.0의 주요 상태 golden

기존 widget test의 `MaterialApp` host도 함께 점검한다. Runtime Kit 위젯은
`RoutexColorTokens` ThemeExtension이 없으면 실패하는 것이 정상이다. 테스트마다 임의 token fallback을
넣지 않고 Navigation의 실제 테마 브리지를 쓰는 공통 test host를 만든다. 순수 Runtime Kit fixture는
`RoutexTheme.light`, 소비 앱 widget test는 `AppTheme.light`의 bridge 결과를 사용해 두 경로를 각각
검증한다.

## 8. 검증 매트릭스

| 분류 | 최소 검증 |
|---|---|
| 공급자 정적 검증 | analyze, 공개 API, source contract, 사용하지 않는 export |
| 공급자 시각 검증 | 기존 Showcase golden SHA-256 유지, 360/390px, 글자 배율 1.0/1.3/2.0 |
| 앱 단위 테스트 | 상태 어댑터, 영업시간 표현, 링크 builder/parser, ID 오류, URI dedupe |
| 앱 위젯 테스트 | 검색 상태, 결과 행, 상세, feedback 1회, 안내 상태별 값, 도착 중복 없음 |
| 앱 golden | 360/390px × 1.0/1.3/2.0 × loading/empty/error/ready 및 선택 상태 |
| 제스처 | 지도 pass-through, sheet drag, 목록 scroll, favorites reorder, pointer guard |
| 통합 | cold/warm link, 정확한 장소 복원, 저장·공유, 출발·도착, 안내 시작·종료 |
| 회귀 | API parsing, Dijkstra, PDR, 지도 style, route line, 장소 상세 기존 테스트 |
| 실기기 | iOS/Android App Links, iPad share anchor, 키보드, 스크린 리더, 큰 글자 |

golden을 다시 생성했다는 사실은 검증이 아니다. 시스템화 단계에서는 기존 공급자 golden의 hash가
같아야 한다. 제품 요구로 디자인이 바뀌는 경우에는 시스템화 PR과 분리하고 변경 전·후 및 승인
근거를 남긴다.

### 단계별 실행 명령

공급자 release 후보는 디자인 시스템 저장소에서 각각 실행한다.

```bash
cd packages/routex_design_system
flutter pub get
flutter analyze
flutter test
```

```bash
cd apps/showcase
flutter pub get
flutter analyze
flutter test
```

소비 앱은 Navigation의 `client/`에서 실행한다. UI 포팅만 검증할 때 로컬 backend를 띄우지 않고
기존 `config.local.json`의 배포 backend를 사용한다.

```bash
flutter pub get
flutter analyze
flutter test
```

수직 기능 작업 중에는 먼저 좁은 회귀를 실행한 뒤 전체 suite를 실행한다.

```bash
flutter test test/screens/map_shell/widgets/sheets/place_detail_sheet_test.dart
flutter test test/screens/map_shell/widgets/sheets/place_detail/place_detail_hours_section_test.dart
flutter test test/screens/map_shell/widgets/search/search_panel_test.dart
flutter test test/widgets/eta_card_test.dart
flutter test test/screens/outdoor_map/widgets/indoor_arrival_card_test.dart
flutter test test/domain/store/store_hours_test.dart
flutter test test/domain/guidance/route_guidance_test.dart
flutter test test/domain/guidance/route_arrival_auto_clear_test.dart
flutter test test/domain/route/dijkstra_test.dart
```

PDR smoke는 센서와 실기기 조건이 필요하므로 일반 widget test 통과로 대체하지 않는다.

```bash
flutter test integration_test/pdr_device_smoke_test.dart -d <device-id>
```

App/Universal Links와 iPad share popover는 플랫폼 build와 실제 설치 앱에서 검증한다. 웹 hot restart나
widget test만으로 통과 처리하지 않는다.

## 9. 진행 중 주의사항

### 사용자 변경 보존

- 두 저장소의 dirty worktree는 소유자를 확인하지 않고 정리하거나 덮어쓰지 않는다.
- 자동 formatter와 대량 치환은 대상 파일을 먼저 확인하고 관련 범위에만 적용한다.
- 앱과 package를 동시에 고쳐야 하면 package release와 앱 소비 commit의 순서를 분리한다.

### API 안정성

- v1 전 공개 컴포넌트는 기본적으로 beta다. 소비 앱은 고정 ref와 wrapper로 변경 범위를 제한한다.
- 앱이 여러 component 생성자에 직접 결합하기보다 수직 기능별 얇은 app-local composition을 둔다.
- breaking change는 deprecated 기간 또는 migration 문서 없이 소비 앱에 먼저 반영하지 않는다.

### 상태와 비동기 처리

- async 완료 후 이미 닫힌 sheet의 context를 사용하지 않는다.
- 빠른 연속 탭, URI 중복, 재시도, background 복귀를 정상 경로와 별도로 테스트한다.
- share 취소를 오류로 알리지 않고, 저장 undo와 공유 결과를 같은 feedback channel로 합치지 않는다.
- 네트워크 실패를 삭제된 장소로 단정하거나, 삭제를 검색 fallback으로 복구하지 않는다.

### 제스처와 지도

- 화면 전체의 투명 `GestureDetector` 또는 opaque hit-test surface를 무심코 추가하지 않는다.
- sheet 시각 포팅 중 route, overlay guard, controller wiring을 제거하지 않는다.
- handle은 장식이 아니라 affordance다. 실제 동작이 없으면 표시하지 않는다.
- favorites를 확장형으로 바꾸는 일은 별도 gesture 설계와 검증 없이는 이 포팅에 포함하지 않는다.

## 10. commit, PR과 롤백

권장 논리 단위는 다음과 같다.

1. `chore:` 불변 package 의존성과 테마 브리지
2. `test:` 소비 앱 기존 동작과 시각 기준선
3. `refactor:` 저위험 기반 요소 또는 하나의 수직 기능 포팅
4. `feat:` 장소 공유·딥링크처럼 새 제품 동작 연결
5. `test:` 해당 단계 회귀·실기기 증거
6. `refactor:` 참조가 사라진 legacy 코드 제거
7. `docs:` 적용 상태와 기준 ref 갱신

각 PR에는 고정 package ref, 포팅한 책임과 남겨 둔 앱 책임, 전후 캡처, golden diff, 실행한 테스트,
실패 기준 점검 결과를 포함한다. 서로 다른 고위험 화면을 한 commit에 섞지 않는다.

롤백은 다음 원칙을 따른다.

- 화면이 아니라 수직 기능 단위로 되돌린다.
- 공통 component 결함은 앱 override로 숨기지 않고 Runtime Kit에서 수정·검증·새 ref를 발행한다.
- 앱 연결 결함은 앱 어댑터와 composition만 되돌린다.
- 공유가 잘못된 장소를 열 가능성이 있으면 공유 진입점과 링크 생성을 즉시 중단한다.
- 지도·PDR·안내 회귀가 생기면 해당 포팅 단계를 전체 롤백한다.
- 롤백 후 lockfile, import, 문서와 사용하지 않는 코드도 이전 정상 상태와 일치시킨다.

## 11. 착수 전 결정 사항

| 결정 | 권장안 | 필요한 시점 |
|---|---|---|
| package 버전 | 검토 완료 tag 또는 전체 SHA | 단계 0 이전 |
| 전역 theme | 초기 bridge, 전체 포팅 후 전환 검토 | 단계 1 |
| 저장한 장소 sheet | 우선 고정형 유지, handle 없음 | 단계 3 |
| 공유 서비스 domain | HTTPS canonical URL과 미설치 fallback | 단계 5 이전 |
| 도착 표현 | 상단 도착 상태 한 번 + 하단 후속 행동 | 단계 6 이전 |
| 지도 token | 제품 UI와 분리한 map visual 대응표 | 단계 7 이전 |

## 12. 구현 착수 체크리스트

다음에 모두 답하기 전에는 실제 포팅을 시작하지 않는다.

- [ ] 사용할 Runtime Kit ref가 불변이며 검토 완료됐는가?
- [ ] 그 ref의 Showcase와 기준 문서 permalink가 준비됐는가?
- [ ] 원본 앱의 동작 기준선과 기존 실패 목록이 있는가?
- [ ] 첫 수직 기능의 앱 책임과 표시 책임을 구분했는가?
- [ ] 단계 실패 시 되돌릴 commit 경계가 정해졌는가?
- [ ] 360/390px와 글자 배율 검증 환경이 있는가?
- [ ] 지도 pass-through와 sheet gesture를 반복 가능하게 검증할 수 있는가?
- [ ] 공유를 포함한다면 HTTPS domain과 Universal/App Links가 준비됐는가?
- [ ] Dijkstra·PDR·API 계약이 변경 범위 밖임을 확인했는가?
- [ ] 포팅 뒤 제거할 legacy UI와 갱신할 문서를 식별했는가?
- [ ] 리뷰어가 시각 결과와 동작 결과를 모두 판정할 증거가 있는가?

첫 구현은 테마 브리지와 저위험 수직 기능 하나로 제한한다. 이 작은 범위에서 공급, 상태 어댑터,
시각 보존, 테스트와 롤백 규칙이 실제로 작동함을 증명한 뒤 다음 단계로 확장한다.
