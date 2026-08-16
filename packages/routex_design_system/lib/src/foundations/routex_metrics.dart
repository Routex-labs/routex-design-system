import 'routex_spacing.dart';

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

/// 경계선이 맡는 시각적 무게다.
///
/// 컴포넌트에서 `1`과 `2`를 직접 고르면 같은 선택 상태가 서로 다른 무게가 된다.
/// hairline은 구획·기본 경계, emphasis는 선택·focus 경계에만 사용한다.
abstract final class RoutexStroke {
  static const hairline = 1.0;
  static const emphasis = 2.0;
}

/// 넓은 화면에서 콘텐츠 한 단위가 읽기 좋은 폭을 넘지 않게 하는 measure다.
///
/// 화면 폭이나 개별 문구 길이를 맞춘 값이 아니라 컴포넌트 역할의 상한이다.
abstract final class RoutexContentMeasure {
  static const scrollableOption = 240.0;
  static const dialog = 360.0;
}

/// 기존 시각 결과를 보존하기 위한 glyph live-area 보정이다.
///
/// spacing으로 사용하지 않는다. 아이콘 세트가 동일한 live area를 제공하거나
/// ListCell과 IconAction이 같은 glyph frame을 공유하게 되면 제거한다.
abstract final class RoutexOpticalCorrection {
  static const listTitleGlyphTop = 4.0;

  static const sheetHeaderGlyph =
      RoutexMetrics.minimumTouchTarget / 2 -
      (RoutexSpacing.contentGap + RoutexMetrics.iconMedium / 2);
}

/// 의미색의 존재감을 조절하는 투명도다.
///
/// 색 자체는 color token이 정하고, 이 값은 어떤 역할로 겹쳐 보이는지만 정한다.
abstract final class RoutexOpacity {
  static const subtleOutline = 0.24;
  static const sheetHandle = 0.55;
}

/// 부모 크기에서 콘텐츠가 차지하는 의미 있는 비율이다.
///
/// 임의 `double`을 컴포넌트 API에 노출하지 않고, 화면 밀도와 자리표시 리듬을
/// 이름 있는 선택지로만 조합한다.
abstract final class RoutexProportion {
  static const shortLine = 0.45;
  static const longLine = 0.6;
  static const largeSheet = 0.75;
}
