# Routex Design System + Promo

Navigation 앱과 독립된 Flutter 디자인 시스템 작업 공간이다. Runtime Kit의 실제 컴포넌트를
Flutter Showcase가 렌더링하며, Promo Studio는 촬영 전용 표현을 별도로 소유한다.

## 저장소 구성

| 경로 | 역할 | 현재 상태 |
|---|---|---|
| `packages/routex_design_system/` | semantic foundation, 공통 컴포넌트, Navigation 제품 패턴 | `0.2.7` (`v0.2.7` tag), 공개 위젯 beta |
| `apps/showcase/` | 실제 Runtime Kit을 검수하는 Flutter Web 카탈로그 | 사용 가능 |
| `apps/promo_studio/` | 결정론적 Flutter 프로모션 영상 스튜디오 | 사용 가능 |
| `docs/` | 시스템 계약, 제품 결정, Navigation 포팅 가이드 | [문서 안내](docs/README.md) |
| `.github/workflows/verify.yml` | package·Showcase·Promo Studio 자동 검증 | 사용 중 |

정적 HTML Showcase는 폐기했다. `apps/showcase/web/index.html`은 Flutter Web runner이며 카탈로그
내용의 출처가 아니다.

## 핵심 원칙

- Runtime Kit과 Showcase는 같은 토큰과 실제 Flutter 컴포넌트를 사용한다.
- 현재 디자인을 시스템화할 때 픽셀을 바꾸지 않는다. 디자인 변경은 별도 변경으로 검토한다.
- 제품 UI, 지도 시각화, 프로모션 표현의 token·asset·motion 소유권을 섞지 않는다.
- 앱의 도메인 모델, API, lifecycle, MapLibre controller와 Dijkstra는 소비 앱에 남긴다.
- 소비 앱은 검증된 release tag 또는 commit SHA를 고정한다.
- 360/390px, 글자 배율 1.0/1.3/2.0, focus·semantics, WCAG 2.2 AA를 완료 조건으로 삼는다.

상세 실패 기준과 계층은 [시스템 계약](docs/system-contract.md), 현재 UX 결정은
[장소 상세·안내 결정](docs/place-detail-guidance-decisions.md), 원본 앱 적용 절차는
[Navigation 포팅 가이드](docs/navigation-app-porting-guide.md)를 따른다.

## 다른 앱에서 사용하는 방식

공급 release가 준비되면 소비 앱은 정확한 ref를 지정한다.

```yaml
dependencies:
  routex_design_system:
    git:
      url: https://github.com/Routex-labs/routex-design-system.git
      ref: <검증된-tag-또는-SHA>
      path: packages/routex_design_system
```

두 저장소를 동시에 개발할 때만 gitignore된 `pubspec_overrides.yaml`로 로컬 sibling 경로를
연결한다. release 검증에는 로컬 override가 남아 있으면 안 된다.

## 실행

```bash
cd apps/showcase
flutter run -d chrome
```

```bash
cd apps/promo_studio
flutter run -d macos
```

프로모션 지도 snapshot을 갱신할 때만 `apps/promo_studio/config.example.json`을
`config.local.json`으로 복사해 배포 API를 설정하고 다음을 실행한다.

```bash
cd apps/promo_studio
python3 tool/generate_navigation_promo_data.py
```

저장소는 공개되어 있어도 프로젝트 코드의 재사용 허가는 별도다. Pretendard font는 각 asset
디렉터리에 포함된 OFL을 따른다.
