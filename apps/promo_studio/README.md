# Routex Promo Studio

Navigation 앱과 분리된 Flutter 프로모션 영상 스튜디오다.
현재 `lib/theme/app_theme.dart`는 독립 실행을 위해 복사한 임시 snapshot이다. 첫 Runtime Kit
release가 나오면 `routex_design_system` package import로 교체하고 이 파일은 제거한다.

프로모션은 제품과 브랜드 foundation을 공유하지만 표현 강도는 분리한다. 촬영용 gradient,
입자, 과장된 motion은 제품 UI token이나 공통 component로 역수입하지 않는다.

Runtime Kit의 공통 Motion Token은 버튼·시트 등 제품 UI가 실제로 등장하는 부분에만 사용할
수 있다. 카메라 이동, 파티클, 전체 타임라인, 장면 전환과 촬영 전용 easing은 이 앱이 별도로
소유하며, 영상 전용 asset과 함께 공용 package에 넣지 않는다.

```bash
flutter run -d macos
```

장면 구성, 데이터 갱신, 검증 방법은 [`promo/README.md`](promo/README.md)를 따른다.
