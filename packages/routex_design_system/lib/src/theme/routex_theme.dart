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
