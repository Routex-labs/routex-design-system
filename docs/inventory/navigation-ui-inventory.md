# Navigation UI inventory — v0.1 기준선

이 문서는 Runtime Kit의 토큰과 핵심 컴포넌트를 무엇부터 만들지 결정하기 위한 **측정 근거의
단일 출처**다. 숫자가 많다는 이유만으로 코드를 디자인 시스템으로 옮기지 않고, 제품 UI와
지도·데이터 표현, 디버그, 앱 도메인 조합을 먼저 분리한다.

구조와 적용 흐름만 빠르게 볼 때는
[Navigation UI 시각 지도](./navigation-ui-visual-map.md)를 사용한다.

## 1. 조사 조건과 완료 판정

- 조사일: 2026-08-14
- 대상: sibling `Navigation/client/lib`
- 기준 commit: `65f4fd7`
- Dart 파일: 186개
- 방식: 소스 정적 검색, 실제 호출 경로·테스트 확인, 로컬 실행 화면 상호작용 점검
- 변경 원칙: Navigation worktree는 읽기만 하고 수정하지 않음

조사 시점의 Navigation에는 지도, 장소 상세와 층 전환 관련 미커밋 변경이 있다. 아래 수치는
그 worktree를 포함한 현재 모습이며, 해당 파일은 첫 pilot에서 제외한다. `config.local.json`은
존재하지만 앱을 새로 실행하거나 값을 읽지 않았다.

이 inventory는 다음을 만족하면 완료다.

1. 직접 style 값을 제품 UI, 지도·데이터, mixed, debug로 구분한다.
2. 기존 공통 UI를 `stable / beta / deprecated / app-local` 중 하나로 분류한다.
3. v0.1 컴포넌트 6~10개와 실제 사용 근거를 연결한다.
4. 현재 수정 중이지 않고 호출 경로와 테스트가 있는 pilot 1~2개를 고른다.
5. 다음 token PR의 결정 항목과 검증 조건을 남긴다.
6. 실행 화면에서 확인한 문제와 실행 환경 때문에 확인하지 못한 상태를 구분한다.

다음 상태가 되면 inventory가 실패한 것이다.

- 지도 페인트와 노선색까지 제품 UI 위반으로 계산한다.
- 한 파일에 지도와 UI가 섞였는데 파일 전체를 literal allowlist에 넣는다.
- 호출되지 않는 legacy 화면을 쉬워 보인다는 이유로 pilot에 고른다.
- 현재 수정 중인 장소 상세·지도 파일을 동시에 이관한다.
- `0.0.1` bootstrap token을 검증 없이 stable로 간주한다.

## 2. 런타임 UI 점검

2026-08-14에 실행 중인 Flutter Web(`http://localhost:53660`)에서 외부 지도와 실내 지도를
오가며 다음 흐름을 직접 조작했다.

- 메인 지도, 상단 검색, GPS 신호 약함 상태
- 앱 메뉴의 저장한 장소, 길찾기, 위치 보정, 디버그 설정
- 저장한 장소의 빈 상태
- 길찾기의 자동차·대중교통·도보 선택, 목적지 검색, GPS 실패 피드백
- 일반 검색의 loading·결과 목록, 장소 상세, 저장 토글, 출발·도착 액션
- 카테고리 선택, 소분류 chip, 매장 목록과 상세
- 실내 B1 층 전환, PDR 위치 버튼과 센서 권한 실패
- 디버그 모드 off/on, 확장 설정과 지도 진단 레이어

브라우저 호스트는 1280×720이었지만 이 제품은 모바일 앱이므로 넓은 폭에서 목록이
벌어지거나 패널이 커지는 현상은 디자인 시스템 문제로 집계하지 않는다. 이번 실행은 상태와
구조의 일관성을 확인하는 데 사용하고, 실제 크기 통과 여부는 360/390px fixture와 모바일
golden으로 판정한다.

### 화면에서 확인한 핵심 문제

| 우선순위 | 문제 | 실행 근거 | 시스템에서 정할 규칙 |
|---|---|---|---|
| P0 | 같은 계열 시트의 anatomy와 rhythm이 다름 | 메뉴는 독립 제목, 저장 목록은 `SheetHeader`, 카테고리는 icon+title, 상세는 title+bookmark+action을 각각 직접 조립 | handle/header/body/action 슬롯, 좌우 gutter, header 높이와 시작선을 `Sheet frame` 계약으로 고정 |
| P0 | 상태 표현 문법이 서로 다름 | 검색·카테고리는 작은 중앙 spinner, GPS/PDR/보정 실패는 화면 전체 폭의 snackbar, GPS 약함은 노란 pill, 저장 토글은 성공·실패 피드백이 보이지 않음 | loading/empty/error/info/success와 persistent/transient 상태를 `Status` 역할로 정의 |
| P0 | selected 상태의 의미보다 구현 위젯 색이 앞섬 | 이동수단은 파란 segment, 층은 파란 pill, 카테고리는 민트 pill, debug는 초록 switch, bookmark는 선택 변화가 식별되지 않음 | control별 selected 색을 만들지 않고 semantic accent와 icon/fill/stroke 조합을 상태표로 정의 |
| P1 | 타이포 역할과 정렬선이 화면마다 달라짐 | 메뉴 제목 16, 공통 header 15, 장소명 20대, 목록 14/12, 빈 상태 13이 직접 지정되고 leading 유무에 따라 제목 시작선이 이동 | title/body/label/caption 역할, line-height, weight, leading column과 baseline 규칙을 함께 정의 |
| P1 | 곡률이 hierarchy가 아니라 개별 위젯에서 결정됨 | sheet 24, chip 15, 저장 아이콘 배경 10, 검색·모드·지도 버튼이 각자 다른 곡률을 사용 | control/field/card/sheet/full의 5개 역할로 제한하고 크기와 radius를 쌍으로 검증 |
| P1 | 지도 위 layer의 깊이 규칙이 불명확함 | top bar, category chip, floor selector, floating location button, sheet와 dim barrier가 모두 다른 방식으로 떠 있음 | onMap/chrome/overlay elevation, border, dim opacity와 겹침 순서를 하나의 layer scale로 정의 |
| P1 | 실패 후 다음 행동이 제시되지 않음 | GPS와 동작·피트니스 권한 실패 snackbar에 설정 이동이나 수동 위치 지정 action이 없음 | 오류 문구, icon, 지속시간, recovery action 유무를 원인별로 정의 |
| P2 | motion의 기능과 시간이 화면별 구현에 묶임 | sheet 진입, 검색 loading, 지도 이동, 층 전환의 목적과 완료 신호가 분리돼 있지 않음 | 제품 component motion만 공통 token으로 두고 지도 camera/PDR 업무 시간은 app-local로 유지 |

빈 즐겨찾기 상태는 문구가 `+ 버튼`을 안내하지만 실제 상세 header는 bookmark 아이콘을
사용한다. 이처럼 카피가 현재 control과 어긋나는 경우도 component 변경과 함께 고쳐야 한다.
장소 상세에서 bookmark를 눌렀지만 이번 실행에서는 목록에 항목이 생기지 않았고 성공·실패
피드백도 없었다. 저장 로직의 결함인지 실행 데이터 조건인지는 이 문서에서 단정하지 않으며,
pilot fixture에는 반드시 selected/loading/success/error 상태를 독립적으로 넣는다.

### 확인하지 못한 상태

- 현재 위치를 얻지 못해 실제 경로 안내와 도착 화면에는 진입하지 못했다.
- 브라우저 도구의 viewport가 고정되어 360/390px와 text scale 1.3/2.0은 실행 화면으로
  캡처하지 못했다. 이 항목은 pilot 완료 조건에서 제거하지 않는다.
- bookmark 저장 실패의 원인은 별도 Navigation 기능 점검 대상이다.

따라서 런타임 점검은 “모든 화면 검증 완료”가 아니다. 실제로 도달한 상태의 시각 기준선이며,
경로 안내·도착·모바일 폭·글자 확대는 후속 golden에서 닫아야 한다.

## 3. 직접 표현 기준선

전체 `client/lib`의 단순 출현 수다. 발생 수는 “모두 제거할 위반 수”가 아니라 분류할
inventory 크기다.

| 표현 | 발생 수 | 파일 수 | 관찰 |
|---|---:|---:|---|
| `TextStyle(` | 176 | 38 | 화면별 크기·굵기 조합이 typography role보다 우세 |
| `EdgeInsets*.` | 171 | 43 | component padding과 screen gutter가 같은 API로 흩어짐 |
| `SizedBox(` | 162 | 35 | layout size와 임의 gap을 추가 분류해야 함 |
| `BorderRadius.` | 69 | 33 | 작은 컨트롤부터 시트까지 역할 이름 없이 직접 결정 |
| raw `Colors.*` / `Color(0x...)` | 194 | 44 | 제품·지도·노선·상태색이 한 집계에 섞임 |
| `Duration(` | 73 | 24 | motion 외 debounce, network timeout, 업무 timer 포함 |
| Material 버튼·필드·행 | 73 | 27 | variant를 화면이 직접 조립하는 지점 |
| sheet API | 21 | 11 | route/gesture 계약과 시각 frame의 분리가 필요 |

raw color 검색에는 단어 경계를 사용한다. `Colors.`를 그대로 찾으면 `AppColors.` 참조까지
포함해 496회로 과대 집계된다. semantic facade 사용량과 raw literal은 같은 지표가 아니다.

### 값 분포

| 축 | 현재 값과 빈도 | v0.1 판단 |
|---|---|---|
| font size | 12(40), 14(25), 13(22), 12.5(15), 11(12), 13.5(10), 16(9), 그 외 10종 | 12.5·13.5·14.5 같은 보간값을 역할로 승격하지 않음 |
| font weight | 700(60), 800(17), 600(14), 500(4), 400(1) | 이름·CTA·제목이 모두 700에 몰렸는지 위계별 fixture로 확인 |
| circular radius | 20(12), 10(10), 16(5), 8/12/14/26/full(각 3), 그 외 9종 | 8/12/16/24/full 역할로 검증하고 20·10은 화면별 유지 금지 |
| EdgeInsets 숫자 | 12(22), 4/8(각 16), 16(11), 14(10), 10(8), 2/6/24(각 5), 그 외 | 4px grid 밖 값은 component metric 또는 제거 대상으로 분류 |
| SizedBox 치수 | 8(29), 6(22), 4/12(각 19), 10(18), 16(8), 3/5(각 7), 그 외 | 6·10이 반복되는 이유를 compact control fixture로 먼저 검증 |
| product motion | 200, 220, 240, 260, 280ms 등 | 공통 120/200/320ms 후보와 비교; 업무 timer·debounce는 제외 |

숫자가 4의 배수가 아니라는 사실만으로 즉시 고치지 않는다. 예를 들어 30px `FilterPill`의
vertical padding 6은 현재 밀도를 만든다. v0.1에서는 32px control로 바꿨을 때 한 줄 선택지와
48dp hit area가 함께 유지되는지 먼저 확인한다. 검증 없이 `spacing6` 토큰을 추가하는 것은
현재 불규칙을 이름만 바꿔 보존하는 일이다.

## 4. 소유 영역 분류

`screens/widgets/theme`의 파일 단위 1차 분류다. mixed 파일은 UI와 지도 코드가 한 파일 안에
있어 별도 추출 전까지 파일 전체 allowlist가 될 수 없다.

| 영역 | 파일 | TextStyle | EdgeInsets | SizedBox | Radius | Color | 처리 |
|---|---:|---:|---:|---:|---:|---:|---|
| 제품 UI | 47 | 161 | 132 | 130 | 58 | 99 | Runtime Kit 후보와 app-local composition으로 세분화 |
| mixed map screen | 2 | 5 | 19 | 8 | 5 | 20 | `map_shell_screen`, `outdoor_map_screen`; 전체 allowlist 금지 |
| 지도·데이터 표현 | 18 | 3 | 3 | 3 | 1 | 48 | Navigation의 `MapVisualTokens`와 데이터 style에 유지 |
| debug | 3 | 1 | 6 | 16 | 2 | 7 | production guard 예외, 제품 토큰 사용은 선택 사항 |

분류 규칙은 다음과 같다.

- **제품 UI:** 검색, 목록, 시트, 버튼, 상태, 지도 위 chrome. Runtime Kit 또는 app-local pattern.
- **지도·데이터:** 도면 paint, route/POI marker, 시설·카테고리·노선색. Navigation 소유.
- **mixed:** 지도 controller/layer와 Material UI가 같은 파일에 있음. UI를 작은 위젯으로 추출한
  뒤 그 위젯만 guard 대상에 포함한다.
- **debug:** 출시 위계와 다르게 정보 밀도를 우선할 수 있다. 예외 이유를 유지한다.
- **업무 시간:** debounce, timeout, GPS freshness, 자동 종료는 Motion Token이 아니다.

프로모션 카메라·파티클·타임라인·장면 연출은 이 집계 대상이 아니며 계속 Promo Studio가
소유한다.

## 5. 우선 확인할 제품 UI 파일

직접 style 합계는 `TextStyle + EdgeInsets + SizedBox + BorderRadius + Color`의 단순 합이다.

| 파일 | 합계 | 상태 | 결정 |
|---|---:|---|---|
| `place_detail_rich_sections.dart` | 104 | 현재 수정 중 | inventory만 기록, pilot 제외 |
| `search_panel.dart` | 75 | clean, 상태·검색 로직 복잡 | app-local composition 유지; 내부 ListCell/Chip만 후속 이관 |
| `app_theme.dart` | 34 | 기존 token facade | semantic token 전환 뒤 deprecated |
| `place_detail_sheet.dart` | 31 | 현재 수정 중 | pilot 제외 |
| `map_shell_screen.dart` | 30 | 현재 수정 중, mixed | composition만 유지; Runtime Kit 역의존 금지 |
| `eta_card.dart` | 28 | 실제 호출, 테스트 풍부 | RouteInstruction/ETA pattern 후보, v0.1 pilot 뒤 검토 |
| `outdoor_map_screen.dart` | 27 | 현재 수정 중, mixed | 파일 allowlist 금지; UI 추출 전 이관 금지 |
| `outdoor_poi_sheet.dart` | 26 | 실제 호출, 지도 동작 결합 | Sheet frame/Button 후보, route는 app-local |
| `route_guide_screen.dart` | 26 | legacy 진입 chain | deep link 확인 전 deprecated 후보 |
| `category_stores_sheet.dart` | 24 | 실제 호출, pass-through gesture | ListCell/Chip 후보, gesture route는 app-local |
| `map_top_bar.dart` | 15 | 실제 호출, 검색·길찾기 두 모드 | SearchField/MapChrome pattern 후보 |
| `app_menu_sheet.dart` | 13 | 실제 호출, clean, 테스트 있음 | **pilot 1** |
| `favorites_sheet.dart` | 9 | 실제 호출, clean, 빈 상태·reorder | **pilot 2** |

## 6. 기존 UI 생명주기 분류

| 대상 | 분류 | 근거와 migration |
|---|---|---|
| `AppElevation.onMap/chrome/overlay` | stable 후보 | 이미 의미와 사용 이유가 있음; Runtime Kit token과 값·이름을 맞춘 뒤 facade 제공 |
| `AppTheme.light` | deprecated 예정 facade | 첫 pilot 동안 `RoutexTheme.light`를 감싸고 마지막 소비처 뒤 제거 |
| `AppColors` 제품색 | deprecated 예정 | semantic color로 치환; map/category/data 의미색은 Navigation에 분리 |
| `SheetHeader` | beta | 5개 소비 시트에서 사용; focus·48dp·leading column 계약을 추가해 package 후보 |
| `SheetGrabHandle` | beta | 7개 소비 시트에서 사용; route/drag 동작은 소유하지 않음 |
| `FilterPill` | beta | 검색 6회, 카테고리 2회 사용; 30px visual과 hit area 분리 필요 |
| 직접 `ListTile` 조립 | deprecated 예정 | 10개 파일 17회; `RoutexListCell` variant로 점진적 교체 |
| 직접 Material 버튼 조립 | deprecated 예정 | Filled 8, Outlined 2, Text 6; `RoutexButton` beta 검증 뒤 신규 사용 차단 |
| 지도 paint/style helper | app-local | map/data 값과 domain model을 Runtime Kit으로 이동하지 않음 |
| `SearchPanel`, `MapTopBar`, `EtaCard` | app-local → pattern 후보 | 상태·domain 결합을 유지하고 값/callback API가 안정된 조각만 승격 |
| `DestinationScreen → RouteGuideScreen → ArrivalScreen` | deprecated 후보 | route 등록은 남아 있지만 제품 코드에서 첫 진입 호출이 없음; deep link 확인 후 삭제 판단 |

`deprecated 후보`는 이 PR에서 삭제하지 않는다. 분석 또는 수동 진입 경로를 확인하고 별도
Navigation PR에서 결정한다.

## 7. v0.1 핵심 컴포넌트 결정

상한은 8개다. 사용량보다 API를 크게 만들지 않고, pilot에서 사용하지 않은 variant는
stable로 승격하지 않는다.

| 순서 | 컴포넌트 | 근거 | v0.1 범위 |
|---:|---|---|---|
| 1 | Button | 직접 버튼 16회, 이미 beta vertical slice 존재 | primary/secondary/quiet/danger, loading/disabled |
| 2 | IconButton | 10개 파일 19회 | standard/onMap, selected/disabled, 48dp |
| 3 | Surface | 카드·패널·지도 chrome의 경계/elevation 중복 | flat/outlined/onMap/chrome/overlay |
| 4 | ListCell | 10개 파일 17회, 목록 간 정렬 차이 | 1~3행, leading/trailing, selected/disabled |
| 5 | Sheet frame | Header 5개, GrabHandle 7개 소비 시트 | frame/header/handle만; route와 gesture는 app-local |
| 6 | Status | 검색 없음·빈 즐겨찾기·loading/error 표현 분산 | loading/empty/error/info와 복구 action |
| 7 | SearchField | 4개 파일 5회 | idle/focused/typing/loading/error |
| 8 | Chip | `FilterPill` 소비 8회 | filter/choice, selected/disabled |

Button은 현재 beta다. 나머지는 proposal로 시작하며 Showcase fixture와 pilot을 통과한 API만
stable로 바꾼다.

## 8. pilot 선정

### Pilot 1 — `AppMenuSheet`

선정 이유:

- `MapShellScreen`에서 실제 호출된다.
- 현재 worktree에서 수정 중이지 않다.
- 동작별 반환값을 검증하는 `app_menu_sheet_test.dart`와 handle 테스트가 있다.
- Sheet frame, ListCell, IconButton, typography와 section rhythm을 한 화면에서 검증한다.
- 지도 controller나 API 응답을 직접 다루지 않아 blast radius가 낮다.

적용 범위는 내부 시각 구조뿐이다. `AppMenuAction`, debug 노출 조건과 `Navigator.pop` 계약은
Navigation에 남긴다.

### Pilot 2 — `FavoritesSheet`

선정 이유:

- `MapShellScreen`에서 실제 호출된다.
- 빈 상태, 일반 행, trailing menu, reorder라는 ListCell의 현실적인 변형을 포함한다.
- `SheetHeader`와 `SheetGrabHandle`을 이미 공유한다.
- 현재 worktree에서 수정 중이지 않다.

두 번째로 두는 이유는 reorder drag와 controller 재빌드가 시각 교체보다 위험하기 때문이다.
첫 pilot에서 ListCell/Sheet API를 안정화한 뒤 적용하며, reorder listener와 persistence는 손대지
않는다.

두 pilot의 통과 조건:

- 기존 action 반환, 닫기 chain, drag/reorder 동작이 그대로다.
- 360/390px, text scale 1.0/1.3/2.0, 긴 한글, 빈 상태에서 overflow가 없다.
- title/subtitle/leading icon의 시작선과 baseline이 같은 ListCell 계약을 따른다.
- 새 임의 `TextStyle`, `EdgeInsets`, `BorderRadius`, 제품색을 추가하지 않는다.
- Navigation은 `v0.1.0` release tag를 사용하고 로컬 path나 `main`을 사용하지 않는다.
- 저장 토글처럼 제자리에서 바뀌는 action은 selected/loading/success/error 중 현재 상태가
  시각적으로 식별되고, 실패 시 복구 경로를 제공한다.
- 빈 상태 안내 문구는 실제 노출 control의 이름과 icon을 사용한다.

## 9. 다음 token PR의 결정 항목

이 inventory는 숫자를 확정하지 않는다. 다음 PR에서 아래 순서로 fixture와 함께 결정한다.

1. **색:** 현재 앱 값과 bootstrap 값의 차이를 표로 만들고 UI semantic과 MapVisual을 분리한다.
   `success`, `error`, `contentSecondary`는 두 코드베이스 값이 다르므로 아직 stable이 아니다.
2. **타이포그래피:** display/headline/title/body/bodyStrong/label/caption 역할을 360px와 2배
   글자에서 검증한다. 13·12.5 사용처는 label 또는 body 중 하나로 흡수한다.
3. **간격·정렬:** screen gutter, component padding, sibling gap, section gap을 분리한다.
   6·10·14를 새 global scale로 추가하지 않는다.
4. **곡률·경계:** control/field/card/sheet/full과 onMap/chrome/overlay만 남긴다.
5. **모션:** 120/200/320ms를 제품 component에만 적용한다. debounce, timeout, GPS·camera와
   Promo Studio timeline은 포함하지 않는다.
6. **Showcase:** Alignment & Rhythm fixture에서 ListCell과 Sheet의 시작선, baseline, 긴 한글,
   leading 유무와 text scale을 비교한다.
7. **상태 문법:** GPS/PDR, 검색, 저장을 예제로 persistent warning, inline loading, snackbar,
   recovery action의 사용 조건을 표로 만든다.

다음 PR의 완료 조건은 token 개수가 늘어나는 것이 아니라 AppMenu/Favorites fixture를 임의
수치 없이 만들 수 있고, 현재 UI와 달라지는 지점마다 의도와 접근성 근거가 있는 상태다.

## 10. 재현 명령

아래 명령은 `Navigation` 저장소 루트에서 실행한다.

```bash
rg --files client/lib -g '*.dart' | wc -l
rg -o -F 'TextStyle(' client/lib -g '*.dart' | wc -l
rg -o -e 'EdgeInsets(?:Directional)?\.' client/lib -g '*.dart' | wc -l
rg -o -F 'SizedBox(' client/lib -g '*.dart' | wc -l
rg -o -e 'BorderRadius\.' client/lib -g '*.dart' | wc -l
rg -o -e '\b(?:Colors\.|Color\(0x)' client/lib -g '*.dart' | wc -l
rg -n '\bDuration\(' client/lib/screens client/lib/widgets -g '*.dart'
```

원시 집계 결과를 CI 위반 수로 직접 사용하지 않는다. token과 component 이관이 시작된 뒤
제품 UI 디렉터리만 guard하고, mixed 파일은 UI 추출 또는 좁은 예외 marker를 사용한다.
