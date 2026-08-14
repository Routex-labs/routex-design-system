# 실내 내비게이션 프로모션 영상

Navigation 앱과 분리된 `apps/promo_studio`에서 구성하는 결정론적 제품 필름이다.
더현대 서울 B1에서 B2 스타벅스 리저브까지 이동하며 다층 경로, PDR 보행, 에스컬레이터
층 전환과 도착을 보여준다.

## 프리뷰

```bash
cd apps/promo_studio
flutter run -d macos
```

- Space: 재생·일시정지
- R: 처음으로
- H: 컨트롤 숨기기
- 좌우 방향키: 한 프레임 이동
- 하단 스크러버: 밀리초 단위 탐색

영상은 모바일 프레임에 고정되지 않는다. 외부 지도에서 실제 더현대 외곽선으로 접근한 뒤
B1 시작 노드를 확대하며 실내 지도로 전환한다. 검색·경로·안내 UI는 한꺼번에 뜨지 않고
점과 아이콘에서 순서대로 생성된다. 경로는 실제 그래프 간선을 따르며 파티클 → 유리 리본 →
푸른 중심선 순서로 응결한다. 층 전환에서는 실제 B1 매장 폴리곤이 이탈한 뒤 B2 폴리곤이
순차 결합한다. 앱 바깥의 설명 카피는 사용하지 않는다.

## 실제 지도 데이터 갱신

```bash
cd apps/promo_studio
python3 promo/generate_navigation_promo_data.py
```

`config.local.json`의 배포 백엔드에서 더현대 B1·B2 지도와 건물 전체 그래프를 한 번 받아
`lib/promo/navigation_promo_data.dart`로 고정한다. 현재 촬영 경로는 B1 서측 시작 노드에서
B2 스타벅스 리저브 입구 노드까지 온디바이스와 같은 비용 규칙으로 계산한 134.2m 경로다.
제품 런타임은 이 스냅샷을 import하지 않는다.

## 검증

```bash
flutter analyze
flutter build web
```

체크포인트·전체 프레임 렌더 테스트는 기존 Navigation 작업 폴더에 실제 파일이 없었으므로
이동 대상에 포함하지 않았다. 추가할 때는 같은 `timeMs`가 재생 이력과 무관하게 같은 픽셀을
만드는지를 먼저 검증한다. 프레임과 영상은 생성물이며 `output/` 아래에 둔다.

## 소유 경계

- `lib/main.dart`, `lib/promo/**`: 촬영 전용
- `lib/theme/app_theme.dart`: Runtime Kit 첫 release 전까지만 쓰는 임시 theme snapshot
- `promo/generate_navigation_promo_data.py`: 배포 백엔드에서 촬영용 스냅샷 생성
- Navigation 앱의 `MapShellScreen`, 지도 화면, 앱 위젯을 import하지 않음
- MapLibre 지도 표면: 같은 앱 팔레트와 경로 언어로 촬영 레이어에서 결정론적으로 재구성
- gradient·입자·촬영용 motion: 프로모션 표현 전용이며 제품 component token으로 승격하지 않음
- 카메라 이동·파티클·전체 타임라인·장면 전환·촬영용 easing과 asset: `promo_studio`가 소유
- 공통 Motion Token: 제품 컴포넌트가 등장하는 구간에서만 선택적으로 사용하며 영상의
  시간축이나 장면 연출을 이 token에 종속하지 않음
