import 'package:flutter/material.dart';

/// 제품 문장에서 맡는 정보 위계다.
enum RoutexTypographyRole {
  display,
  headline,
  title,
  body,
  bodyStrong,
  label,
  caption,
}

extension RoutexTypographyRoleValue on RoutexTypographyRole {
  TextStyle get textStyle => switch (this) {
    RoutexTypographyRole.display => RoutexTypography.display,
    RoutexTypographyRole.headline => RoutexTypography.headline,
    RoutexTypographyRole.title => RoutexTypography.title,
    RoutexTypographyRole.body => RoutexTypography.body,
    RoutexTypographyRole.bodyStrong => RoutexTypography.bodyStrong,
    RoutexTypographyRole.label => RoutexTypography.label,
    RoutexTypographyRole.caption => RoutexTypography.caption,
  };
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
