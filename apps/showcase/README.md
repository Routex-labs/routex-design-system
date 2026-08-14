# Routex Showcase

Runtime Kit의 실제 Flutter 컴포넌트를 import해 렌더링하는 경량 카탈로그다. v0.1에서는
foundation, 핵심 컴포넌트 상태와 반응형·텍스트 배율 검수에 집중한다.

```bash
flutter run -d chrome
```

```bash
flutter test
flutter build web
```

색 값과 컴포넌트 상태를 이 앱에 다시 정의하지 않는다. 표시 값은
`routex_design_system` package의 공개 API에서 읽는다.

`Alignment & Rhythm` fixture는 360/390px과 text scale 1.0/1.3/2.0을 전환한다. 정확한 기준
폭을 유지하기 때문에 좁은 화면에서는 fixture를 좌우로 확인하며, 자동 테스트는 여섯 조합의
긴 한글·상태 메시지·48dp action이 overflow 없이 렌더링되는지 검사한다.
