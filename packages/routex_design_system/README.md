# Routex Design System Runtime Kit

Routex 제품 UI가 import하는 Flutter package다. v0.1 범위는 semantic foundation token과
사용량이 검증된 핵심 컴포넌트 6~10개다.

현재 proposal에는 색상, 타이포그래피, 간격, 곡률, 공통 metric, 지도 위 layer와 제품 motion
token이 들어 있다. 화면의 여백과 자식 간격을 semantic role로 제한하는 `RoutexInset`,
`RoutexStack`, `RoutexCluster`도 proposal로 제공한다. 공급 경로와 상태 계약을 검증하기 위한
`RoutexButton`과 텍스트 열을 고정하는 `RoutexListCell`은 beta다. 값과 API는 `v0.1.0`
전에 조정할 수 있으므로 아직 stable이 아니다.

```dart
import 'package:routex_design_system/routex_design_system.dart';

MaterialApp(
  theme: RoutexTheme.light,
  home: RoutexInset(
    role: RoutexInsetRole.screen,
    child: RoutexStack(
      gap: RoutexStackGap.section,
      children: [
        const Text('저장한 장소'),
        RoutexButton(label: '길찾기', onPressed: startRoute),
      ],
    ),
  ),
);
```

## 소비 규칙

- primitive 색 이름과 숫자는 package 밖에 공개하지 않는다.
- 제품은 `RoutexColorTokens`, `RoutexTypography`, `RoutexSpacing`, `RoutexRadii`,
  `RoutexMetrics`, `RoutexLayer`, `RoutexMotion`의 semantic 역할을 사용한다.
- Showcase 같은 진단 도구는 `RoutexColorRole.values` 등 공개 catalog를 순회하며 목록과 값을
  복사하지 않는다.
- v0.1은 light theme만 지원한다. 검증되지 않은 자동 반전 dark theme은 제공하지 않는다.
- 텍스트와 주요 action 조합은 WCAG 2.2 AA 4.5:1을 테스트로 고정한다.
- 터치 가능한 control은 48dp보다 작아지지 않는다.
- 반복되는 화면 여백, 세로 간격과 컨트롤 묶음은 `Padding`, `Column`, `Wrap`을 조합하지 않고
  `RoutexInset`, `RoutexStack`, `RoutexCluster`의 semantic role로 표현한다.
- layout primitive에는 임의 수치나 alignment를 입력할 수 없다. 새로운 반복 관계가 확인되면
  role과 실패 테스트를 먼저 추가한다.
- 장소·검색 결과 행은 `RoutexListCell`을 사용한다. v0.1 beta는 leading 유무와 관계없이
  leading column을 예약하며 임의 padding, TextStyle 또는 커스텀 leading 위젯을 받지 않는다.

카메라 이동, 파티클, 영상 타임라인, 장면 연출과 프로모션 asset은 이 package에 넣지 않는다.
제품 앱의 domain model, MapLibre controller와 Dijkstra도 소비 앱이 소유한다.
