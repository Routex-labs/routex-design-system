# Routex Design System Runtime Kit

Routex 제품 UI가 import하는 Flutter package다. v0.1 범위는 semantic foundation token과
사용량이 검증된 핵심 컴포넌트 6~10개다.

현재 bootstrap에는 색상, 타이포그래피, 간격, 곡률, 그림자, 제품 motion token과 공급 경로를
검증하기 위한 `RoutexButton` vertical slice만 들어 있다. 이 값은 inventory와 접근성 검증을
거쳐 `v0.1.0` 전에 조정할 수 있으므로 아직 stable API가 아니다.

```dart
import 'package:routex_design_system/routex_design_system.dart';

MaterialApp(
  theme: RoutexTheme.light,
  home: RoutexButton(
    label: '길찾기',
    onPressed: startRoute,
  ),
);
```

카메라 이동, 파티클, 영상 타임라인, 장면 연출과 프로모션 asset은 이 package에 넣지 않는다.
제품 앱의 domain model, MapLibre controller와 Dijkstra도 소비 앱이 소유한다.
