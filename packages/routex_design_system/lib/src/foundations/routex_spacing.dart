/// 제품 레이아웃에서 간격이 맡는 역할이다.
enum RoutexSpacingRole {
  inlineGap(4),
  controlGap(8),
  contentGap(12),
  componentPadding(16),
  screenGutter(16),
  sectionGap(24);

  const RoutexSpacingRole(this.value);

  final double value;
}

/// 4px grid에서 파생된 의미 기반 간격이다.
abstract final class RoutexSpacing {
  static const inlineGap = 4.0;
  static const controlGap = 8.0;
  static const contentGap = 12.0;
  static const componentPadding = 16.0;
  static const screenGutter = 16.0;
  static const sectionGap = 24.0;
}
