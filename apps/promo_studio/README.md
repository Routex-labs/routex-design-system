# Routex Promo Studio

Navigation 앱과 분리된 결정론적 Flutter 프로모션 영상 스튜디오다. 더현대 서울의 다층 경로,
PDR 보행, 층 전환과 도착을 촬영용 장면으로 재구성한다.

## 실행과 조작

```bash
flutter run -d macos
```

- Space: 재생·일시정지
- R: 처음으로
- H: 컨트롤 숨기기
- 좌우 방향키: 한 프레임 이동
- 하단 scrubber: 밀리초 단위 탐색

같은 `timeMs`는 재생 이력과 무관하게 같은 장면을 만들어야 한다. 프레임과 영상은 생성물이며
`output/` 아래에 둔다.

## 촬영 데이터 갱신

`config.example.json`을 `config.local.json`으로 복사해 배포 백엔드를 설정한 뒤 실행한다.

```bash
python3 tool/generate_navigation_promo_data.py
```

스크립트는 더현대 B1·B2 지도와 건물 그래프를 받아
`lib/promo/navigation_promo_data.dart`로 고정한다. 제품 런타임은 이 snapshot을 import하지 않는다.

## 소유 경계

- `lib/promo/**`: 촬영 scene, timeline, 고정 데이터
- `tool/generate_navigation_promo_data.py`: 촬영 snapshot 생성 도구
- `lib/theme/app_theme.dart`: Runtime Kit 연결 전의 독립 실행용 theme snapshot
- camera, particle, 전체 timeline, 장면 transition, 촬영 easing·asset: Promo Studio 전용
- 제품 component가 등장하는 구간의 foundation·motion만 Runtime Kit과 공유 가능

Navigation 화면과 위젯을 import하지 않으며 촬영 표현을 제품 token으로 역수입하지 않는다.

## 검증

```bash
flutter analyze
flutter build web
```
