# Navigation UI 조사 기준선

## 조사 조건

- 원본 저장소: `Routex-labs/Navigation`
- 확인 commit: `b655c066e00ca6b2bab6dd9035c37a9d8d54fe62`
- 목적: Runtime Kit 포팅 시 보존할 상태·책임과 교체할 시각 구현을 분리한다.
- 제한: 이 문서는 원본 앱의 현재 구현 snapshot이다. 포팅 착수 시 HEAD가 다르면 다시 조사한다.

## 책임 지도

| 원본 영역 | 유지할 앱 책임 | Runtime Kit이 받을 표현 책임 |
|---|---|---|
| `client/lib/app.dart` | lifecycle, router, deep-link coordinator, theme 설치 | semantic theme |
| `screens/map_shell/map_shell_screen.dart` | 검색·sheet chain·route draft·선택 상태 | overlay slot과 제품 패턴 |
| `screens/outdoor_map/outdoor_map_screen.dart` | MapLibre, GPS, 실내 전환, 안내·도착 상태 | 지도 chrome과 상태 표현 |
| `screens/map_shell/widgets/sheets/place_detail_sheet.dart` | 상세 조회, 저장, 공유 callback, 출발·도착 intent | sheet/header/actions/tabs/content |
| `screens/map_shell/widgets/sheets/category_stores_sheet.dart` | 분류·정렬 데이터 | result list, sort, list cell |
| `screens/map_shell/widgets/sheets/favorites_sheet.dart` | 저장 데이터, reorder, route intent | 확장형 sheet와 목록 표현 |
| `screens/map_shell/widgets/search/search_panel.dart` | query와 비동기 상태 | search/result/empty/loading 표현 |
| `widgets/eta_card.dart` | ETA·소요·거리 계산값 | 안내 전 요약 위계 |
| `screens/outdoor_map/widgets/indoor_arrival_card.dart` | 도착 판정과 종료 action | 도착 상태·후속 행동 표현 |
| `domain/store/store_hours.dart` | 영업 상태와 요일 계산 | 접힘/펼침 영업시간 표현 |
| `widgets/map_pass_through_sheet_route.dart` | pointer routing과 sheet lifecycle | 없음 |

## 현재 포팅 위험

- 상세는 named route가 아니라 modal sheet이므로 URL을 파싱하는 것만으로 장소를 열 수 없다.
- 지도 shell이 준비되기 전에 cold-start link로 modal을 열면 context·데이터 준비 순서가 깨진다.
- sheet 확장, 내부 scroll, 저장 목록 reorder가 같은 세로 gesture를 사용한다.
- MapLibre의 camera·marker·route layer는 UI 교체와 결합하면 회귀 범위가 커진다.
- 현재 AppTheme과 Runtime Kit Theme를 한 번에 바꾸면 legacy 화면의 기본 Material 값도 달라질 수 있다.
- 동명 장소 fallback, 누락 ID fallback은 엉뚱한 매장을 열 수 있어 금지한다.
- 저장 callback에서 기존 SnackBar와 새 notice를 함께 호출하면 중복 피드백이 생긴다.

## 포팅 우선순위

1. 정확한 package ref와 theme bridge
2. Button, ListCell, status처럼 저위험 leaf UI
3. 검색 결과와 고정 sheet
4. 장소 상세과 저장·공유
5. 확장형·reorder sheet gesture
6. 안내 전·안내 중·도착 상태
7. 지도 overlay와 map visual token
8. legacy wrapper와 사용되지 않는 구현 제거

각 단계의 구체적인 파일·테스트·중단 조건은
[Navigation 포팅 가이드](../navigation-app-porting-guide.md)가 단일 출처다. 최종 UX는
[장소 상세·안내 결정](../place-detail-guidance-decisions.md)을 따른다.
