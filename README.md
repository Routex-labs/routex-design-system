# Routex Design System + Promo

Navigation 앱과 릴리스 주기가 다른 디자인 시스템과 프로모션 제작 도구를 모은 작업 공간이다.

## 현재 상태

| 경로 | 상태 | 역할 |
|---|---|---|
| `apps/promo_studio/` | 사용 가능 | 결정론적 Flutter 프로모션 영상 스튜디오 |
| `docs/design-system-plan.md` | 작성됨 | 진단, 설계 원칙, 레퍼런스 적용 결정, 단계별 실행 계획의 단일 출처 |
| `packages/routex_design_system/` | bootstrap 완료 | semantic foundation과 첫 beta Button을 제공하는 Runtime Kit |
| `apps/showcase/` | bootstrap 완료 | 실제 Runtime Kit을 import하는 Flutter Web Showcase |
| `.github/workflows/verify.yml` | 작성됨 | Runtime Kit, Showcase, Promo Studio 검증 |

디자인 시스템 package와 Showcase는 같은 저장소에 둔다. Showcase는 package의 실제
컴포넌트를 import해 렌더링하고, Navigation 앱은 release tag를 고정해 package를 사용한다.
구체적인 계층, 수치 후보, 저장소 경계와 검증 조건은
[`docs/design-system-plan.md`](docs/design-system-plan.md)만 기준으로 삼는다.

현재 구조는 유지하되 3인 팀에 맞는 경량 v0.1로 시작한다. 한 명이 디자인 시스템과
Promo Studio를 주로 운영하는 동안 토큰, 핵심 컴포넌트 6~10개, 실제 패키지를 사용하는
Showcase, Promo Studio 핵심 장면, Navigation 1~2개 시범 화면까지만 첫 범위에 포함한다.
전체 앱을 한 번에 재작성하지 않는다.

현재 package 버전 `0.0.1`은 공급 경로를 검증하기 위한 bootstrap이며 Navigation 적용용
release가 아니다. 실제 시범 적용은 토큰과 핵심 컴포넌트를 검토한 `v0.1.0`부터 시작한다.

현재 폴더는 아직 독립 Git 저장소나 GitHub 원격으로 초기화하지 않았다. 원격 후보는
`Routex-labs/routex-design-system`이며, 공개 여부와 라이선스를 결정한 뒤 연결한다.

## 다른 앱에서 사용하는 방식

Runtime Kit이 첫 release를 만들면 소비 앱은 정확한 tag를 지정한다.

```yaml
dependencies:
  routex_design_system:
    git:
      url: https://github.com/Routex-labs/routex-design-system.git
      ref: v0.1.0
      path: packages/routex_design_system
```

패키지 전체를 내려받더라도 앱 코드는 필요한 public API만 import하고, release build에서는
참조되지 않는 Dart 코드가 제거된다. 반면 폰트·이미지 같은 자산은 같은 방식으로 정리된다고
가정할 수 없으므로 무거운 지도·프로모션 자산은 Runtime Kit에 넣지 않는다. 두 저장소를
동시에 개발할 때만 gitignore된 `pubspec_overrides.yaml`로 로컬 sibling 경로를 연결한다.
원격 연결은 먼저 내용이 적은 package로 검증하고, Navigation의 실제 UI 이관은 `v0.1.0`
release 이후 시작한다.

Runtime Kit은 공통 Motion Token과 제품 컴포넌트의 상태 전환 모션까지만 제공한다.
프로모션 카메라 이동, 파티클, 전체 타임라인, 장면 연출과 영상 전용 asset은
`apps/promo_studio/`에 남긴다. 프로모 앱은 색·타입·공통 motion 같은 foundation을 공유할 수
있지만, 영상 전용 구현을 공용 패키지에 추가하지 않는다.

## 프로모션 스튜디오 실행

```bash
cd apps/promo_studio
flutter run -d macos
```

지도 스냅샷을 갱신하려면 `config.example.json`을 `config.local.json`으로 복사해 배포
백엔드 주소를 넣은 뒤 다음을 실행한다.

```bash
python3 promo/generate_navigation_promo_data.py
```
