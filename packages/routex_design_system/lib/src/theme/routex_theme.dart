import 'package:flutter/material.dart';

import '../foundations/routex_tokens.dart';
import 'routex_color_tokens.dart';

abstract final class RoutexTheme {
  static ThemeData get light {
    const colors = RoutexColorTokens.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.actionPrimary,
      brightness: Brightness.light,
      primary: colors.actionPrimary,
      error: colors.statusError,
      surface: colors.surfaceBase,
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
      focusColor: colors.focusRing,
      dividerColor: colors.borderSubtle,
    );
  }
}
