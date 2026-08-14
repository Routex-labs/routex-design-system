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
      focusColor: colors.focusRing,
      dividerColor: colors.borderSubtle,
      disabledColor: colors.contentDisabled,
    );
  }
}
