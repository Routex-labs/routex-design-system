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

일반 기능·레이아웃 테스트는 Windows·macOS·Linux에서 실행한다. 픽셀 골든은 운영체제와 Flutter
버전에 따라 글꼴 rasterization이 달라지므로 Flutter 3.44.8을 설치한 Ubuntu CI만 기준으로
판정한다. 골든 suite에는 `@TestOn('linux')`가 있어 Windows와 macOS의 `flutter test`에서는
자동 제외된다. CI에서 골든이 실패하면 actual·diff 이미지를 7일간 artifact로 남긴다. 의도된
변경은 artifact를 육안 검수한 뒤 Ubuntu actual 이미지만 새 기준선으로 커밋한다. 픽셀 허용
오차를 넓혀 운영체제 차이나 실제 회귀를 숨기지 않는다.

## 페이지 역할

- `한눈에`: 390px 제품 카드 네 열을 유지하고 좁은 창에서는 전체를 비율 축소한다.
- `컴포넌트`: action, list, input, surface, place, guidance, status 등 실제 공개 API의 상태를 본다.
- `기초`: semantic color, map visual, typography, category, spacing, layer, motion을 공개 catalog에서 읽는다.
- `품질 기준`: 360/390px과 text scale 1.0/1.3/2.0의 정렬·리듬 fixture와 실패 기준을 검수한다.

## 데이터와 소유 경계

매장 상세는 Navigation의 오설록 상세 snapshot을 사용하며 `API_BASE_URL`이 있으면
`GET /buildings/{id}/places/{place_id}` 응답으로 대체한다. 사진은 소비 앱 자산의 대표 일부만
`assets/place_details/`에 둔다. 없는 사진 경로를 다른 사진으로 바꿔치기하지 않는다.

Showcase 앱 계층에 남을 수 있는 것은 다음뿐이다.

- 카탈로그 페이지 전환 상태와 상세 API adapter
- fixture와 catalog 배치

검색·시트·목록·상태·경로 UI는 Runtime Kit 공개 API로만 조합한다. MapLibre, 실제 GPS, 도메인
모델, Dijkstra와 별도 제품 흐름 상태 머신은 가져오지 않는다.

시스템 실패·완료 기준은 [시스템 계약](../../docs/system-contract.md), 장소 상세와 안내의 제품
결정은 [제품 결정](../../docs/place-detail-guidance-decisions.md)을 따른다.
