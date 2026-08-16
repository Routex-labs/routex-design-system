# Routex 디자인 시스템 계약

## 현재 상태

이 저장소는 Flutter Runtime Kit, Flutter Showcase, Promo Studio를 함께 관리한다. package 버전
`0.2.4`(`v0.2.4` tag)가 Navigation이 소비하는 release다. 그 앞의 `0.0.1`은 공급 구조 검증용
bootstrap이었다. 공개 위젯은 별도 표시가 없으면 v1 전까지 `beta`다. foundation과 layout
primitive는 `proposal`이다.

```text
navdesignsystem+promo/
├── packages/routex_design_system/  Flutter Runtime Kit
├── apps/showcase/                  실제 package를 렌더링하는 Flutter Web 카탈로그
├── apps/promo_studio/              결정론적 프로모션 영상 도구
└── docs/                           계약·결정·포팅 문서
```

정적 HTML Showcase는 사용하지 않는다. `apps/*/web/index.html`은 Flutter Web 실행에 필요한
runner이므로 정적 카탈로그와 다르며 유지한다.

## 계층과 소유권

```text
private primitive → semantic token → core component → product pattern → consumer screen
```

- primitive 숫자와 색 이름은 package 내부 구현이다.
- semantic token은 제품 역할을 이름으로 표현한다.
- `components/`는 도메인 독립 UI, `patterns/`는 내비게이션 제품 패턴이다.
- Runtime Kit은 외형·상태 표현을 소유하고 소비 앱은 도메인 상태, API adapter, navigation,
  MapLibre controller, GPS와 Dijkstra를 소유한다.
- Runtime Kit은 제품 component motion까지만 소유한다. 카메라, 파티클, 타임라인과 촬영 asset은
  Promo Studio가 소유한다.
- Showcase는 실제 공개 API를 조합한다. 검수용이라는 이유로 제품 카드·버튼을 사설 복제하지 않는다.

## 공개 API 정책

- 소비자는 `package:routex_design_system/routex_design_system.dart`만 import한다.
- 외형을 바꾸는 임의 padding, radius, 높이, 색, `TextStyle` 입력을 추가하지 않는다.
- 새 관계가 반복되면 화면에서 숫자로 보정하지 않고 semantic role과 실패 테스트를 먼저 만든다.
- `stable`·`deprecated`는 예외일 때만 CHANGELOG와 migration에 기록한다.
- 소비 앱은 release tag 또는 commit SHA를 고정한다. `main`이나 개발자의 로컬 경로를 release에
  사용하지 않는다.

## 실패 기준

아래 중 하나라도 발생하면 시스템 변경은 실패다.

- 시스템화 작업 전후 대표 golden의 픽셀이 의도 없이 달라진다.
- `components/`, `patterns/`, `layout/`에 이름 없는 색·간격·크기·곡률·투명도·duration이 생긴다.
- 같은 역할의 텍스트·아이콘·콘텐츠 시작선, baseline 또는 내부 리듬이 화면마다 달라진다.
- 360px/390px 또는 text scale 1.0/1.3/2.0에서 overflow, 잘림, 행동 순서 붕괴가 생긴다.
- 터치 영역이 48dp 미만이거나 focus·semantics가 사라진다.
- 주요 텍스트/행동 대비가 WCAG 2.2 AA 4.5:1 미만이다.
- 로딩·빈 값·오류·GPS 약함·경로 이탈에서 상태 또는 복구 흐름이 없다.
- Badge, Chip, Status, Toast를 모양이 비슷하다는 이유로 같은 역할로 합친다.
- 고정 표면에 장식용 handle을 표시하거나 확장형 시트의 gesture가 목록 스크롤·재정렬과 충돌한다.
- 소비 앱의 API, 지도, 경로 계산 또는 lifecycle 책임을 package로 옮긴다.
- Showcase가 package API를 복제하거나 정적 HTML을 다시 단일 출처로 만든다.

## 완료 판정과 자동 검증

변경은 다음을 모두 통과해야 완료다.

1. Runtime Kit analyze/test 통과
2. Showcase analyze/test/web build 통과
3. source contract, visual spec, viewport, contrast 테스트 통과
4. Ubuntu CI가 생성한 대표 golden의 의도된 변경 여부를 사람이 확인
5. 문서 링크 검사와 README의 상태·명령이 실제 구조와 일치
6. 변경으로 불필요해진 코드·문서·fixture가 남지 않음

```bash
cd packages/routex_design_system
flutter analyze
flutter test

cd ../../apps/showcase
flutter analyze
flutter test
flutter build web

cd ../promo_studio
flutter analyze
flutter build web
```

현재 디자인 보존의 세부 자동 경계는 [0002](decisions/0002-visual-source-contract.md), 제품별
결정은 [제품 결정](place-detail-guidance-decisions.md), 앱 이관은
[포팅 가이드](navigation-app-porting-guide.md)를 따른다.

Showcase 자체와 기능·레이아웃 테스트는 Windows·macOS·Linux에서 동작해야 한다. 픽셀 골든만
Flutter 3.44.8 Ubuntu CI를 canonical renderer로 사용한다. 다른 운영체제의 렌더링을 Linux
PNG와 직접 비교하거나 플랫폼별 기준선을 여러 벌 관리하지 않는다.
