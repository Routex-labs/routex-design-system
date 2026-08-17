import 'package:flutter/material.dart';

import '../foundations/routex_typography.dart';
import 'routex_color_tokens.dart';

abstract final class RoutexTheme {
  static ThemeData get light {
    const colors = RoutexColorTokens.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.actionPrimary,
      brightness: Brightness.light,
      primary: colors.actionPrimary,
      onPrimary: colors.contentInverse,
      primaryContainer: colors.actionPrimarySubtle,
      onPrimaryContainer: colors.actionPrimary,
      error: colors.statusError,
      onError: colors.contentInverse,
      errorContainer: colors.statusErrorSubtle,
      onErrorContainer: colors.statusError,
      surface: colors.surfaceBase,
      onSurface: colors.contentPrimary,
      outline: colors.borderStrong,
      outlineVariant: colors.borderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.surfaceCanvas,
      // 역할 슬롯은 여덟이고 Material 슬롯은 열다섯이다. 가족을 함께 주지 않으면
      // 남는 일곱(titleLarge·bodyLarge 등)이 기본값 Roboto로 남는데, Roboto에는
      // 한글이 없어 그 자리만 시스템 대체 글꼴로 떨어진다. TextField의 입력 글자가
      // bodyLarge라 검색창 하나 때문에 화면에 두 글꼴이 서는 식이다.
      // 크기·굵기는 Material 기본을 그대로 둔다 — 남는 슬롯을 우리 역할에
      // 매핑하는 것은 글꼴 결함과 별개 결정이다.
      fontFamily: RoutexTypography.fontFamily,
      package: RoutexTypography.fontPackage,
      textTheme: RoutexTypography.textTheme.apply(
        bodyColor: colors.contentPrimary,
        displayColor: colors.contentPrimary,
      ),
      extensions: const [colors],
      // Material 기본 컨트롤은 선택 채움과 구분되는 옅은 focus state layer를
      // 사용한다. 경계가 있는 커스텀 표면은 RoutexFocusRing이 같은 token의
      // 불투명한 2dp 링을 그린다.
      focusColor: colors.focusRing.withValues(alpha: 0.12),
      dividerColor: colors.borderSubtle,
      disabledColor: colors.contentDisabled,
    );
  }
}
