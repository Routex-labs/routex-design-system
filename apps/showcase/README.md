# Routex Flutter Showcase

`routex_design_system`의 실제 공개 API를 렌더링하는 Flutter Web 카탈로그다. 별도 HTML 버전이나
복제 컴포넌트는 운영하지 않는다.

## 실행과 검증

```bash
flutter run -d chrome
```

배포 API를 연결하려면 `config.example.json`을 `config.local.json`으로 복사해
`API_BASE_URL`을 채운다. 설정이 없거나 응답·CORS가 실패하면 저장소의 고정 snapshot을 사용한다.

```bash
flutter run -d chrome --dart-define-from-file=config.local.json
flutter analyze
flutter test
flutter build web
```

asset 목록을 바꾸면 hot reload가 아니라 앱을 다시 실행한다.

## 페이지 역할

- `한눈에`: 390px 제품 카드 네 열을 유지하고 좁은 창에서는 전체를 비율 축소한다.
- `컴포넌트`: action, list, input, surface, place, guidance, status 등 실제 공개 API의 상태를 본다.
- `기초`: semantic color, map visual, typography, category, spacing, layer, motion을 공개 catalog에서 읽는다.
- `품질 기준`: 360/390px과 text scale 1.0/1.3/2.0의 정렬·리듬 fixture와 실패 기준을 검수한다.
- `모바일 UX 목업`: 메인→장소→상세→경로→안내→실내→도착 흐름의 조합 계약을 검수한다.

## 데이터와 소유 경계

매장 상세는 Navigation의 오설록 상세 snapshot을 사용하며 `API_BASE_URL`이 있으면
`GET /buildings/{id}/places/{place_id}` 응답으로 대체한다. 사진은 소비 앱 자산의 대표 일부만
`assets/place_details/`에 둔다. 없는 사진 경로를 다른 사진으로 바꿔치기하지 않는다.

Showcase 앱 계층에 남을 수 있는 것은 다음뿐이다.

- 기기 frame과 상태 bar
- 화면 전환용 상태 machine과 API adapter
- 단색 지도 canvas와 검수용 지도 painter
- fixture와 catalog 배치

검색·시트·목록·상태·경로 UI는 Runtime Kit 공개 API로만 조합한다. MapLibre, 실제 GPS, 도메인
모델, Dijkstra는 가져오지 않는다. 이동수단은 소비 앱이 넘긴 실제 가용 수단만 표시하고 하나면
선택기를 숨긴다.

시스템 실패·완료 기준은 [시스템 계약](../../docs/system-contract.md), 장소 상세와 안내의 제품
결정은 [제품 결정](../../docs/place-detail-guidance-decisions.md)을 따른다.
