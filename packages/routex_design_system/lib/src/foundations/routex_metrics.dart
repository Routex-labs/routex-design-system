/// 접근성과 반복 정렬에 영향을 주는 공통 크기 역할이다.
enum RoutexMetricRole {
  compactControl(32),
  standardControl(40),
  minimumTouchTarget(48),
  leadingColumn(40),
  iconSmall(16),
  iconMedium(20),
  iconLarge(24);

  const RoutexMetricRole(this.value);

  final double value;
}

/// 컴포넌트가 임의 높이와 아이콘 크기를 만들지 않게 하는 공통 metric이다.
abstract final class RoutexMetrics {
  static const compactControl = 32.0;
  static const standardControl = 40.0;
  static const minimumTouchTarget = 48.0;
  static const leadingColumn = 40.0;
  static const iconSmall = 16.0;
  static const iconMedium = 20.0;
  static const iconLarge = 24.0;
}
