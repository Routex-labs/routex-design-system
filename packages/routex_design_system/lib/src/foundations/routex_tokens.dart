import 'package:flutter/material.dart';

/// 4px grid에서 파생된 의미 기반 간격이다.
abstract final class RoutexSpacing {
  static const controlGap = 8.0;
  static const contentGap = 12.0;
  static const controlPadding = 16.0;
  static const sectionGap = 24.0;
  static const screenGutterCompact = 16.0;
  static const screenGutterWide = 24.0;
}

/// 컴포넌트 역할에 연결된 곡률이다.
abstract final class RoutexRadii {
  static const control = BorderRadius.all(Radius.circular(8));
  static const field = BorderRadius.all(Radius.circular(12));
  static const card = BorderRadius.all(Radius.circular(16));
  static const sheet = BorderRadius.vertical(top: Radius.circular(24));
  static const pill = BorderRadius.all(Radius.circular(999));
}

/// z-order를 표현하는 제품 UI elevation이다.
abstract final class RoutexElevation {
  static const onMap = 1.0;
  static const chrome = 3.0;
  static const overlay = 8.0;
}

/// 카드 장식이 아니라 레이어 분리가 필요할 때만 사용하는 그림자다.
abstract final class RoutexShadows {
  static const chrome = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const overlay = <BoxShadow>[
    BoxShadow(color: Color(0x24000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

/// v0.1에서 허용하는 타이포그래피 역할이다.
abstract final class RoutexTypography {
  static const _fontFamily = 'Pretendard';
  static const _fontPackage = 'routex_design_system';

  static const display = TextStyle(
    fontFamily: _fontFamily,
    package: _fontPackage,
    fontSize: 28,
    height: 1.25,
    fontWeight: FontWeight.w800,
  );
  static const headline = TextStyle(
    fontFamily: _fontFamily,
    package: _fontPackage,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w800,
  );
  static const title = TextStyle(
    fontFamily: _fontFamily,
    package: _fontPackage,
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w700,
  );
  static const body = TextStyle(
    fontFamily: _fontFamily,
    package: _fontPackage,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );
  static const bodyStrong = TextStyle(
    fontFamily: _fontFamily,
    package: _fontPackage,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w700,
  );
  static const label = TextStyle(
    fontFamily: _fontFamily,
    package: _fontPackage,
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w600,
  );
  static const caption = TextStyle(
    fontFamily: _fontFamily,
    package: _fontPackage,
    fontSize: 11,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );

  static const textTheme = TextTheme(
    displaySmall: display,
    headlineSmall: headline,
    titleMedium: title,
    bodyMedium: body,
    labelLarge: bodyStrong,
    labelMedium: label,
    bodySmall: caption,
  );
}
