import 'package:flutter/painting.dart';

/// 지도 위에 그리는 데이터 표현의 색과 굵기다.
///
/// 제품 UI semantic token과 **다른 층**이다. 버튼·시트의 파랑을 바꾼다고 경로선이
/// 따라 바뀌면 안 되고, 반대도 마찬가지다. 지도 renderer(MapLibre style, CustomPaint,
/// 목업)는 색 literal을 직접 적지 않고 여기서 읽는다.
///
/// 값은 Navigation의 `map_route_style.dart`, `location_marker.dart`,
/// `destination_pin.dart`에서 가져왔다. 실제 앱과 Showcase 목업, 홍보 영상이 같은
/// 경로선·마커를 그리게 하는 것이 이 층의 목적이다. 앱 값을 바꿀 때 여기도 함께
/// 바꾼다.
abstract final class RoutexMapVisualTokens {
  /// 경로 본선. 제품 `actionPrimary`와 값이 다르며 서로 독립적으로 관리한다.
  static const routeLine = Color(0xFF4A87F1);

  /// 본선 아래 진한 casing. 밝은 도면 위에서 본선 경계를 만든다.
  static const routeCasing = Color(0xFF1B57C4);

  /// 이미 지나온 구간.
  static const routeCompleted = Color(0xFF9AA0A6);

  /// 대중교통 경로의 도보 구간(점선).
  static const routeWalk = Color(0xFF8A9199);

  /// 진행 방향 화살표.
  static const routeArrow = Color(0xFFFFFFFF);

  /// 현재 위치 점.
  static const location = Color(0xFF1976D2);

  /// 현재 위치 정확도 원. 중심에서 바깥으로 세 단계로 옅어진다.
  static const locationAccuracy = <Color>[
    Color(0x8F1976D2),
    Color(0x451976D2),
    Color(0x001976D2),
  ];

  /// 목적지 핀 본체와 테두리, 핀 안 글자.
  static const destination = Color(0xFFE53935);
  static const destinationOutline = Color(0xFFA81B18);
  static const destinationLabel = Color(0xFFFFFFFF);

  /// 도면 바탕과 구조물. 실내 도면과 야외 지도가 같은 단계를 쓴다.
  static const canvasOutdoor = Color(0xFFE8EDF0);
  static const canvasIndoor = Color(0xFFF2F3F4);
  static const structure = Color(0xFFD8E0E4);
  static const structureOutline = Color(0xFFCBD4DA);
  static const facility = Color(0xFFE5E8EB);
  static const facilityOutline = Color(0xFFC5CDD4);
  static const walkway = Color(0xFFFFFFFF);
  static const walkwayOutline = Color(0xFFAEB8C2);

  /// 도면 위 시설 이름.
  static const mapLabel = Color(0xFF66717D);

  /// 경로선 굵기. casing이 본선보다 두꺼워야 경계가 생긴다.
  static const routeLineWidth = 7.0;
  static const routeCasingWidth = 11.0;
}

/// Showcase와 지도 진단 도구가 지도 색 목록을 따로 복사하지 않도록 하는 catalog다.
///
/// 제품 semantic color와 달리 지도 도면·경로·마커가 맡는 시각 역할을 열거한다. 지도
/// renderer와 목업은 값을 직접 고르지 않고 [RoutexMapVisualTokens]를 읽는다.
enum RoutexMapVisualRole {
  routeLine,
  routeCasing,
  routeCompleted,
  routeWalk,
  routeArrow,
  location,
  destination,
  canvasOutdoor,
  canvasIndoor,
  structure,
  structureOutline,
  facility,
  facilityOutline,
  walkway,
  walkwayOutline,
  mapLabel,
}

extension RoutexMapVisualRoleValue on RoutexMapVisualRole {
  Color resolve() => switch (this) {
    RoutexMapVisualRole.routeLine => RoutexMapVisualTokens.routeLine,
    RoutexMapVisualRole.routeCasing => RoutexMapVisualTokens.routeCasing,
    RoutexMapVisualRole.routeCompleted => RoutexMapVisualTokens.routeCompleted,
    RoutexMapVisualRole.routeWalk => RoutexMapVisualTokens.routeWalk,
    RoutexMapVisualRole.routeArrow => RoutexMapVisualTokens.routeArrow,
    RoutexMapVisualRole.location => RoutexMapVisualTokens.location,
    RoutexMapVisualRole.destination => RoutexMapVisualTokens.destination,
    RoutexMapVisualRole.canvasOutdoor => RoutexMapVisualTokens.canvasOutdoor,
    RoutexMapVisualRole.canvasIndoor => RoutexMapVisualTokens.canvasIndoor,
    RoutexMapVisualRole.structure => RoutexMapVisualTokens.structure,
    RoutexMapVisualRole.structureOutline =>
      RoutexMapVisualTokens.structureOutline,
    RoutexMapVisualRole.facility => RoutexMapVisualTokens.facility,
    RoutexMapVisualRole.facilityOutline =>
      RoutexMapVisualTokens.facilityOutline,
    RoutexMapVisualRole.walkway => RoutexMapVisualTokens.walkway,
    RoutexMapVisualRole.walkwayOutline => RoutexMapVisualTokens.walkwayOutline,
    RoutexMapVisualRole.mapLabel => RoutexMapVisualTokens.mapLabel,
  };
}
