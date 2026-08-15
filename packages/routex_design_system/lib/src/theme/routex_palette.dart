import 'package:flutter/painting.dart';

/// primitive 색 이름과 숫자다.
///
/// 이 층은 package 밖으로 공개하지 않는다. 제품 UI는 언제나 semantic token을 읽고,
/// 팔레트는 semantic token이 어떤 값을 가리키는지만 정의한다. light 외 테마를
/// 추가할 때도 팔레트가 아니라 semantic 매핑을 교체한다.
abstract final class RoutexPalette {
  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral50 = Color(0xFFF4F7FC);
  static const neutral200 = Color(0xFFDDE3EC);

  /// borderStrong 전용. 색상과 채도는 유지하고 명도만 낮춘 값이다.
  ///
  /// 이전 값(0xFF98A3B3)은 흰 표면에서 2.55, 지도 바탕에서 2.38로 비텍스트
  /// 기준(3:1)에 못 미쳤다. secondary 버튼은 이 선이 유일한 경계라 선이 옅어지면
  /// 버튼인지 알 수 없다. 지금 값은 3.44 / 3.20이다.
  static const neutral400 = Color(0xFF828B99);
  static const neutral500 = Color(0xFF8B96A8);
  static const neutral600 = Color(0xFF4F5D73);
  static const neutral900 = Color(0xFF172033);

  static const blue50 = Color(0xFFE7F0FF);
  static const blue100 = Color(0xFFE8F2FF);

  /// Navigation 앱이 쓰던 하늘색이다. `AppColors.blue500`, 경로선과 같은 값이다.
  ///
  /// 흰 배경에서 3.48이라 글자에는 못 쓴다(글자 기준 4.5 미달). 비텍스트 3:1은
  /// 넘으므로 선·표시·아이콘에만 쓴다. accentBrand가 이 제약을 문서가 아니라
  /// contrast test로 지킨다.
  static const blue400 = Color(0xFF4A87F1);
  static const blue500 = Color(0xFF2563C7);
  static const blue600 = Color(0xFF1559BE);
  static const blue700 = Color(0xFF1E5EAA);
  static const blue800 = Color(0xFF194EAA);

  static const green50 = Color(0xFFE8F6EC);
  static const green700 = Color(0xFF1E743B);

  static const amber50 = Color(0xFFFFF2D6);
  static const amber800 = Color(0xFF855600);

  static const red50 = Color(0xFFFFECEA);
  static const red700 = Color(0xFFB9382E);

  /// 지도 위 깊이와 덮개에 쓰는 neutral900 투명도 단계다.
  static const neutral900At12 = Color(0x1F172033);
  static const neutral900At22 = Color(0x38172033);
  static const neutral900At45 = Color(0x73172033);
}
