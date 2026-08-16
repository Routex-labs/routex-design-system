import 'package:flutter/material.dart';

/// 매장 분류가 지도와 목록에서 갖는 고유 색과 아이콘이다.
///
/// 제품 semantic token(actionPrimary·status…)과 **다른 층**이다. 분류색은 의미를
/// 전달하는 것이 아니라 서로를 구분하는 것이 목적이므로, 버튼·상태색과 값을
/// 공유하지 않는다. 본문 텍스트, CTA, 오류 의미로 재사용하지 않는다.
///
/// 값과 아이콘은 Navigation의 `category_icon.dart`에서 가져왔다. 지도 강조, 분류
/// 칩, 목록 leading이 같은 색과 글리프를 쓰게 하는 것이 이 층의 목적이다.
///
/// 어휘가 바뀌면(`식음료` → `음식점`) 예전 이름도 남겨 두어 저장된 데이터가 조용히
/// 회색으로 떨어지지 않게 한다.
abstract final class RoutexCategoryTokens {
  static const _colors = <String, Color>{
    '패션': Color(0xFFA2B2C8),
    '편의시설': Color(0xFFAEBDC3),
    '음식점': Color(0xFFCA9A8E),
    '카페': Color(0xFFE1B87F),
    '식품관': Color(0xFF85B09A),
    '식음료': Color(0xFFCA9A8E),
    '리빙': Color(0xFF87BEB8),
    '서비스': Color(0xFF9BA3D6),
    '키즈': Color(0xFFC5A8D0),
    '뷰티': Color(0xFFF2ACB9),
  };

  static const _icons = <String, IconData>{
    '패션': Icons.checkroom,
    '편의시설': Icons.info_outline,
    '음식점': Icons.restaurant,
    '카페': Icons.local_cafe_outlined,
    '식품관': Icons.local_grocery_store_outlined,
    '식음료': Icons.restaurant,
    '리빙': Icons.weekend_outlined,
    '서비스': Icons.support_agent,
    '키즈': Icons.child_care,
    '뷰티': Icons.brush,
  };

  /// 분류색을 글자·테두리에 쓸 수 있게 낮춘 값이다. 색상은 그대로, 명도만 낮췄다.
  ///
  /// 원색은 도면 위 넓은 면을 칠하려고 고른 파스텔이라 흰 배경에서 1.80~2.46밖에
  /// 안 나온다. 비텍스트 3:1도 못 넘기므로 **선택 표시나 글자에 원색을 그대로 쓰면
  /// 무엇이 선택됐는지 보이지 않는다.** 그렇다고 포인트 색으로 통일하면 분류마다 색이
  /// 다른 의미가 사라지므로, 색상을 유지한 채 대비만 확보한 짝을 따로 둔다.
  ///
  /// 각 값은 제 tint 위에서 4.5:1, 흰 배경에서 5:1 이상이다.
  static const _inks = <String, Color>{
    '패션': Color(0xFF556E90),
    '편의시설': Color(0xFF5A717A),
    '음식점': Color(0xFF9C5A49),
    '카페': Color(0xFF956523),
    '식품관': Color(0xFF4D7762),
    '식음료': Color(0xFF9C5A49),
    '리빙': Color(0xFF417771),
    '서비스': Color(0xFF4A59B5),
    '키즈': Color(0xFF8B569F),
    '뷰티': Color(0xFFCD2040),
  };

  /// 선택된 분류의 배경이다. 같은 색상의 아주 옅은 단계다.
  static const _surfaces = <String, Color>{
    '패션': Color(0xFFECEFF4),
    '편의시설': Color(0xFFEDF1F2),
    '음식점': Color(0xFFF5ECEA),
    '카페': Color(0xFFF9F1E7),
    '식품관': Color(0xFFECF3F0),
    '식음료': Color(0xFFF5ECEA),
    '리빙': Color(0xFFEBF4F3),
    '서비스': Color(0xFFE9EBF6),
    '키즈': Color(0xFFF2EBF4),
    '뷰티': Color(0xFFF9E7EA),
  };

  /// 분류를 모르면 일반 매장으로 떨어진다.
  static const fallbackColor = Color(0xFFB9C2CC);
  static const fallbackInk = Color(0xFF5E6E80);
  static const fallbackSurface = Color(0xFFEDF0F2);
  static const fallbackIcon = Icons.storefront;

  /// 도면 위 면을 칠하는 원색이다. 글자나 선에는 [inkFor]를 쓴다.
  static Color colorFor(String category) => _colors[category] ?? fallbackColor;

  /// 글자·아이콘·테두리에 쓰는 색이다.
  static Color inkFor(String category) => _inks[category] ?? fallbackInk;

  /// 선택된 상태의 배경이다.
  static Color surfaceFor(String category) =>
      _surfaces[category] ?? fallbackSurface;

  static IconData iconFor(String category) => _icons[category] ?? fallbackIcon;

  /// Showcase와 진단 도구가 목록을 복사하지 않도록 공개하는 catalog다.
  static Iterable<String> get categories => _colors.keys;
}
