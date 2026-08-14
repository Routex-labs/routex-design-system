# 작업 규칙

## 공통

- 문서·커밋·PR은 한국어로 작성한다.
- 구현 전에 실패 조건과 완료 판정을 먼저 적고, 그 기준으로 검증한다.
- 기능, 문서, 파일 이동·삭제는 논리적 작업 단위별 커밋으로 나눈다.

## 디자인 시스템

- 3인 팀에서 한 명이 디자인 시스템과 Promo Studio를 주로 운영한다는 전제로, v0.1은
  토큰·핵심 컴포넌트 6~10개·Showcase·대표 적용 화면에만 집중한다.
- 모든 기존 화면과 컴포넌트를 한 번에 재작성하거나 대규모 플랫폼을 먼저 만들지 않는다.
- Runtime Kit과 Showcase는 같은 토큰과 실제 Flutter 컴포넌트를 사용한다.
- primitive 값은 package 밖에 노출하지 않고 semantic token으로 소비한다.
- 제품 UI, 지도·데이터 시각화, 프로모션 표현의 token과 asset 소유 경계를 섞지 않는다.
- Runtime Kit에는 공통 Motion Token과 제품 컴포넌트 모션만 둔다. 프로모션 카메라 이동,
  파티클, 타임라인, 장면 연출과 영상 전용 asset은 `apps/promo_studio`가 소유한다.
- Showcase에 색 값, 상태 목록, 버전을 손으로 복사하지 않는다.
- 앱 도메인 모델, API, MapLibre controller, Dijkstra를 디자인 시스템 package로 옮기지 않는다.
- 소비 앱은 release tag 또는 commit을 고정하고 `main` branch나 개인 로컬 경로에 의존하지 않는다.
- WCAG 2.2 AA, focus·semantics, 2배 글자, 긴 한글, 빈 값, 로딩, 오류 상태를 컴포넌트
  완료 조건에 포함한다. APCA는 보조 진단으로만 사용한다.
- 컴포넌트는 `proposal → beta → stable → deprecated → removed` 상태와 migration 경로를 갖는다.
- 기존 UI는 사용량과 일관성을 기준으로 `stable / beta / deprecated / app-local`로 분류하고,
  호환 wrapper를 거쳐 점진적으로 교체한다.

## 프로모션 스튜디오

- `apps/promo_studio`는 Navigation 앱 코드를 import하지 않는 독립 앱으로 유지한다.
- 제품과 브랜드 foundation은 공유하되 촬영용 gradient·입자·과장된 motion을 Runtime Kit으로
  역수입하지 않는다.
- 공통 Motion Token을 사용할 수는 있지만 영상 타임라인을 그 token에 맞추기 위해 왜곡하지
  않는다. 촬영 장면의 시간축과 카메라 연출은 독립적으로 결정한다.
- 촬영 데이터는 생성 시점에 고정하며 제품 런타임 데이터로 사용하지 않는다.
- 같은 시간값은 재생 이력과 무관하게 같은 장면을 만들어야 한다.
