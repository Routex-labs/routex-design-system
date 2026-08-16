import 'package:flutter/material.dart';

/// 제품 문장에서 맡는 정보 위계다.
enum RoutexTypographyRole {
  display,
  headline,
  title,
  body,
  bodyStrong,
  bodySmall,
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
    RoutexTypographyRole.bodySmall => RoutexTypography.bodySmall,
    RoutexTypographyRole.label => RoutexTypography.label,
    RoutexTypographyRole.caption => RoutexTypography.caption,
  };
}

/// v0.1에서 허용하는 타이포그래피 역할이다.
abstract final class RoutexTypography {
  /// 이 배율부터 균등 칸보다 가로 스크롤이 읽기 순서를 더 잘 보존한다.
  static const scrollLayoutTextScale = 1.3;

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
    fontSize: 22,
    height: 30 / 22,
    fontWeight: FontWeight.w700,
  );
  static const title = TextStyle(
    fontFamily: _fontFamily,
    package: _fontPackage,
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w700,
  );
  static const body = TextStyle(
    fontFamily: _fontFamily,
    package: _fontPackage,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );
  static const bodyStrong = TextStyle(
    fontFamily: _fontFamily,
    package: _fontPackage,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
  );
  static const bodySmall = TextStyle(
    fontFamily: _fontFamily,
    package: _fontPackage,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );
  static const label = TextStyle(
    fontFamily: _fontFamily,
    package: _fontPackage,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
  );
  static const caption = TextStyle(
    fontFamily: _fontFamily,
    package: _fontPackage,
    fontSize: 12,
    height: 1.5,
    fontWeight: FontWeight.w500,
  );

  static const _tabularFigures = <FontFeature>[FontFeature.tabularFigures()];

  /// 역할을 바꾸지 않고 숫자만 고정폭으로 고정한다.
  ///
  /// 남은 거리·시간·층처럼 값이 실시간으로 바뀌는 자리에서만 사용한다. 가변폭
  /// 숫자는 값이 바뀔 때마다 텍스트 폭이 흔들려 이동 중 읽기를 방해한다. 크기와
  /// 굵기는 그대로 두므로 이것이 typography 역할에 허용하는 유일한 변형이다.
  static TextStyle tabular(TextStyle style) =>
      style.copyWith(fontFeatures: _tabularFigures);

  /// 어절이 줄 끝에서 쪼개지지 않게 음절을 묶는다.
  ///
  /// 유니코드 기본 줄바꿈 규칙(UAX #14)은 한글 음절 사이 어디서나 줄을 끊을 수 있게
  /// 본다. 그래서 `더현대서울(B2)R / 점입니다`처럼 한 낱말이 두 줄로 갈라진다. CSS의
  /// `word-break: keep-all`에 해당하는 옵션이 Flutter에는 없어서, 어절 안의 글자를
  /// word joiner(U+2060)로 이어 붙여 **공백에서만** 끊기게 만든다.
  ///
  /// **긴 어절은 손대지 않는다.** 한 줄보다 긴 어절을 통째로 묶으면 줄바꿈이 아니라
  /// 넘침이 되어 글자가 잘린다. [maxJoinLength]는 "이 정도면 어차피 한 줄에 들어간다"고
  /// 보는 길이다. 제품 폭 390에 본문 16px이면 한 줄에 24자쯤 들어가므로 18자까지는
  /// 묶어도 안전하고, 그보다 긴 어절은 기존 규칙대로 쪼개지게 둔다.
  ///
  /// **한글이 든 어절만 손댄다.** 숫자·영문은 애초에 낱자 사이에서 끊기지 않으므로
  /// 묶을 이유가 없고, 보이지 않는 글자를 전화번호나 주소에 심으면 복사한 값이 원본과
  /// 달라진다.
  static String keepWordsWhole(String text, {int maxJoinLength = 18}) {
    const joiner = '\u2060';
    return text
        .split(' ')
        .map(
          (word) =>
              word.length > maxJoinLength ||
                  word.length < 2 ||
                  !_hangul.hasMatch(word)
              ? word
              : word.split('').join(joiner),
        )
        .join(' ');
  }

  /// 완성형 음절과 자모. 한글이 하나라도 있으면 그 어절은 음절 사이에서 끊긴다.
  static final _hangul = RegExp(r'[가-힣ㄱ-ㅎㅏ-ㅣ]');

  /// 한 줄 컨트롤 라벨에서 줄 간격을 없앤다.
  ///
  /// 본문용 행간(1.5)을 버튼·칩처럼 한 줄짜리 컨트롤 안에서 그대로 쓰면 line box가
  /// 글자보다 커서 라벨이 아래로 쏠려 보인다. 크기와 굵기는 그대로 두고 줄 간격만
  /// 없애 글리프를 컨트롤 중앙에 세운다.
  static TextStyle control(TextStyle style) => style.copyWith(height: 1);

  static const textTheme = TextTheme(
    displaySmall: display,
    headlineSmall: headline,
    titleMedium: title,
    bodyMedium: body,
    labelLarge: bodyStrong,
    labelMedium: label,
    bodySmall: bodySmall,
    labelSmall: caption,
  );
}
