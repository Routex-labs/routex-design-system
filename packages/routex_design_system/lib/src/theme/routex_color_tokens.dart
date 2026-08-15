import 'package:flutter/material.dart';

import 'routex_palette.dart';

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
    required this.actionPrimarySubtle,
    required this.actionDisabled,
    required this.accentBrand,
    required this.borderSubtle,
    required this.borderStrong,
    required this.statusInfo,
    required this.statusSuccess,
    required this.statusWarning,
    required this.statusError,
    required this.statusInfoSubtle,
    required this.statusSuccessSubtle,
    required this.statusWarningSubtle,
    required this.statusErrorSubtle,
    required this.focusRing,
    required this.shadow,
    required this.shadowStrong,
    required this.scrim,
  });

  /// v0.1은 현재 제품과 같은 light theme만 지원한다.
  static const light = RoutexColorTokens(
    surfaceCanvas: RoutexPalette.neutral50,
    surfaceBase: RoutexPalette.neutral0,
    surfaceRaised: RoutexPalette.neutral0,
    contentPrimary: RoutexPalette.neutral900,
    contentSecondary: RoutexPalette.neutral600,
    contentDisabled: RoutexPalette.neutral500,
    contentInverse: RoutexPalette.neutral0,
    actionPrimary: RoutexPalette.blue500,
    actionPrimaryPressed: RoutexPalette.blue800,
    actionPrimarySubtle: RoutexPalette.blue50,
    actionDisabled: RoutexPalette.neutral200,
    accentBrand: RoutexPalette.blue400,
    borderSubtle: RoutexPalette.neutral200,
    borderStrong: RoutexPalette.neutral400,
    statusInfo: RoutexPalette.blue700,
    statusSuccess: RoutexPalette.green700,
    statusWarning: RoutexPalette.amber800,
    statusError: RoutexPalette.red700,
    statusInfoSubtle: RoutexPalette.blue100,
    statusSuccessSubtle: RoutexPalette.green50,
    statusWarningSubtle: RoutexPalette.amber50,
    statusErrorSubtle: RoutexPalette.red50,
    focusRing: RoutexPalette.blue600,
    shadow: RoutexPalette.neutral900At12,
    shadowStrong: RoutexPalette.neutral900At22,
    scrim: RoutexPalette.neutral900At45,
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
  final Color actionPrimarySubtle;
  final Color actionDisabled;

  /// RoutEx를 대표하는 하늘색. **글자가 올라가지 않는 자리에만 쓴다.**
  ///
  /// 선택 상태의 테두리, 탭 표시줄, 지도 위 표시처럼 선과 면으로만 뜻을 전하는
  /// 자리다. 흰 배경 기준 3.48이라 비텍스트 3:1은 넘지만 글자 4.5에는 못 미친다.
  /// 글자나 글자 밑 배경이 필요하면 actionPrimary를 쓴다.
  final Color accentBrand;
  final Color borderSubtle;
  final Color borderStrong;
  final Color statusInfo;
  final Color statusSuccess;
  final Color statusWarning;
  final Color statusError;
  final Color statusInfoSubtle;
  final Color statusSuccessSubtle;
  final Color statusWarningSubtle;
  final Color statusErrorSubtle;
  final Color focusRing;
  final Color shadow;
  final Color shadowStrong;
  final Color scrim;

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
    Color? actionPrimarySubtle,
    Color? actionDisabled,
    Color? accentBrand,
    Color? borderSubtle,
    Color? borderStrong,
    Color? statusInfo,
    Color? statusSuccess,
    Color? statusWarning,
    Color? statusError,
    Color? statusInfoSubtle,
    Color? statusSuccessSubtle,
    Color? statusWarningSubtle,
    Color? statusErrorSubtle,
    Color? focusRing,
    Color? shadow,
    Color? shadowStrong,
    Color? scrim,
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
      actionPrimarySubtle: actionPrimarySubtle ?? this.actionPrimarySubtle,
      actionDisabled: actionDisabled ?? this.actionDisabled,
      accentBrand: accentBrand ?? this.accentBrand,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      statusInfo: statusInfo ?? this.statusInfo,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusWarning: statusWarning ?? this.statusWarning,
      statusError: statusError ?? this.statusError,
      statusInfoSubtle: statusInfoSubtle ?? this.statusInfoSubtle,
      statusSuccessSubtle: statusSuccessSubtle ?? this.statusSuccessSubtle,
      statusWarningSubtle: statusWarningSubtle ?? this.statusWarningSubtle,
      statusErrorSubtle: statusErrorSubtle ?? this.statusErrorSubtle,
      focusRing: focusRing ?? this.focusRing,
      shadow: shadow ?? this.shadow,
      shadowStrong: shadowStrong ?? this.shadowStrong,
      scrim: scrim ?? this.scrim,
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
      actionPrimarySubtle: Color.lerp(
        actionPrimarySubtle,
        other.actionPrimarySubtle,
        t,
      )!,
      actionDisabled: Color.lerp(actionDisabled, other.actionDisabled, t)!,
      accentBrand: Color.lerp(accentBrand, other.accentBrand, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      statusInfo: Color.lerp(statusInfo, other.statusInfo, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
      statusInfoSubtle: Color.lerp(
        statusInfoSubtle,
        other.statusInfoSubtle,
        t,
      )!,
      statusSuccessSubtle: Color.lerp(
        statusSuccessSubtle,
        other.statusSuccessSubtle,
        t,
      )!,
      statusWarningSubtle: Color.lerp(
        statusWarningSubtle,
        other.statusWarningSubtle,
        t,
      )!,
      statusErrorSubtle: Color.lerp(
        statusErrorSubtle,
        other.statusErrorSubtle,
        t,
      )!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      shadowStrong: Color.lerp(shadowStrong, other.shadowStrong, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
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
