import 'package:flutter/material.dart';

/// 제품 UI가 용도로 읽는 semantic color token이다.
@immutable
class RoutexColorTokens extends ThemeExtension<RoutexColorTokens> {
  const RoutexColorTokens({
    required this.surfaceCanvas,
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.contentPrimary,
    required this.contentSecondary,
    required this.contentDisabled,
    required this.contentInverse,
    required this.actionPrimary,
    required this.actionPrimaryPressed,
    required this.borderSubtle,
    required this.borderStrong,
    required this.statusSuccess,
    required this.statusWarning,
    required this.statusError,
    required this.focusRing,
  });

  static const light = RoutexColorTokens(
    surfaceCanvas: Color(0xFFEEF4FE),
    surfaceBase: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    contentPrimary: Color(0xFF212121),
    contentSecondary: Color(0xFF686F7A),
    contentDisabled: Color(0xFF9BA2AC),
    contentInverse: Color(0xFFFFFFFF),
    actionPrimary: Color(0xFF4A87F1),
    actionPrimaryPressed: Color(0xFF3575DD),
    borderSubtle: Color(0x14000000),
    borderStrong: Color(0x3D000000),
    statusSuccess: Color(0xFF248A3D),
    statusWarning: Color(0xFF9A6700),
    statusError: Color(0xFFD93025),
    focusRing: Color(0xFF1A73E8),
  );

  final Color surfaceCanvas;
  final Color surfaceBase;
  final Color surfaceRaised;
  final Color contentPrimary;
  final Color contentSecondary;
  final Color contentDisabled;
  final Color contentInverse;
  final Color actionPrimary;
  final Color actionPrimaryPressed;
  final Color borderSubtle;
  final Color borderStrong;
  final Color statusSuccess;
  final Color statusWarning;
  final Color statusError;
  final Color focusRing;

  @override
  RoutexColorTokens copyWith({
    Color? surfaceCanvas,
    Color? surfaceBase,
    Color? surfaceRaised,
    Color? contentPrimary,
    Color? contentSecondary,
    Color? contentDisabled,
    Color? contentInverse,
    Color? actionPrimary,
    Color? actionPrimaryPressed,
    Color? borderSubtle,
    Color? borderStrong,
    Color? statusSuccess,
    Color? statusWarning,
    Color? statusError,
    Color? focusRing,
  }) {
    return RoutexColorTokens(
      surfaceCanvas: surfaceCanvas ?? this.surfaceCanvas,
      surfaceBase: surfaceBase ?? this.surfaceBase,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      contentPrimary: contentPrimary ?? this.contentPrimary,
      contentSecondary: contentSecondary ?? this.contentSecondary,
      contentDisabled: contentDisabled ?? this.contentDisabled,
      contentInverse: contentInverse ?? this.contentInverse,
      actionPrimary: actionPrimary ?? this.actionPrimary,
      actionPrimaryPressed: actionPrimaryPressed ?? this.actionPrimaryPressed,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusWarning: statusWarning ?? this.statusWarning,
      statusError: statusError ?? this.statusError,
      focusRing: focusRing ?? this.focusRing,
    );
  }

  @override
  RoutexColorTokens lerp(RoutexColorTokens? other, double t) {
    if (other == null) return this;
    return RoutexColorTokens(
      surfaceCanvas: Color.lerp(surfaceCanvas, other.surfaceCanvas, t)!,
      surfaceBase: Color.lerp(surfaceBase, other.surfaceBase, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      contentPrimary: Color.lerp(contentPrimary, other.contentPrimary, t)!,
      contentSecondary: Color.lerp(
        contentSecondary,
        other.contentSecondary,
        t,
      )!,
      contentDisabled: Color.lerp(contentDisabled, other.contentDisabled, t)!,
      contentInverse: Color.lerp(contentInverse, other.contentInverse, t)!,
      actionPrimary: Color.lerp(actionPrimary, other.actionPrimary, t)!,
      actionPrimaryPressed: Color.lerp(
        actionPrimaryPressed,
        other.actionPrimaryPressed,
        t,
      )!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
    );
  }
}

extension RoutexColorTokensContext on BuildContext {
  RoutexColorTokens get routexColors {
    final tokens = Theme.of(this).extension<RoutexColorTokens>();
    if (tokens == null) {
      throw FlutterError(
        'RoutexColorTokens가 Theme에 없습니다. '
        'MaterialApp.theme에 RoutexTheme.light를 사용하세요.',
      );
    }
    return tokens;
  }
}
