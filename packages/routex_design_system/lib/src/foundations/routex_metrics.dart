/// 접근성과 반복 정렬에 영향을 주는 공통 크기 역할이다.
enum RoutexMetricRole {
  compactControl(32),
  standardControl(44),
  minimumTouchTarget(48),
  searchField(52),
  leadingColumn(40),
  textKeyline(64),
  thumbnail(72),
  mediaBand(200),
  iconSmall(16),
  iconMedium(20),
  iconLarge(24);

  const RoutexMetricRole(this.value);

  final double value;
}

/// 컴포넌트가 임의 높이와 아이콘 크기를 만들지 않게 하는 공통 metric이다.
abstract final class RoutexMetrics {
  static const compactControl = 32.0;
  static const standardControl = 44.0;
  static const minimumTouchTarget = 48.0;
  static const searchField = 52.0;
  static const leadingColumn = 40.0;

  /// 행의 제목 글자가 시작하는 자리다. 표면 안쪽 가장자리에서 잰다.
  ///
  /// `contentGap + leadingColumn + contentGap`으로, 지금까지 `RoutexListCell`
  /// 안에서만 계산되던 값이다. 같은 표면에 놓인 머리글이 이 값을 모르면 제목 열이
  /// 행마다 어긋난다. 머리글은 자기 앞자리를 이 폭으로 잡아 제목을 맞춘다.
  static const textKeyline = 64.0;

  /// 목록 행 안에 놓이는 사진의 짧은 변이다.
  ///
  /// 행 높이를 사진이 정하는 자리라 값이 하나여야 한다. 행마다 사진 크기가
  /// 다르면 제목 열은 맞아도 행의 세로 리듬이 무너진다.
  static const thumbnail = 72.0;

  /// 상세 첫 화면을 차지하는 대표 사진 띠의 높이다.
  ///
  /// 사진 비율이 아니라 **화면에서 사진이 가져가는 몫**으로 정한다. 비율로 두면
  /// 폭이 넓은 기기에서 사진만으로 첫 화면이 채워져 이름과 주 행동이 밀려난다.
  static const mediaBand = 200.0;

  static const iconSmall = 16.0;
  static const iconMedium = 20.0;
  static const iconLarge = 24.0;
}
