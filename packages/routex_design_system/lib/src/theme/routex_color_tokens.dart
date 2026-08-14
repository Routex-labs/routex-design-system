import 'package:flutter/material.dart';

/// Showcase와 진단 도구가 색 역할을 별도 목록으로 복사하지 않게 하는 catalog다.
enum RoutexColorRole {
  surfaceCanvas,
  surfaceBase,
  surfaceRaised,
  contentPrimary,
  contentSecondary,
  contentDisabled,
  contentInverse,
  actionPrimary,
  actionPrimaryPressed,
  actionPrimarySubtle,
  actionDisabled,
  borderSubtle,
  borderStrong,
  statusInfo,
  statusSuccess,
  statusWarning,
  statusError,
  statusInfoSubtle,
  statusSuccessSubtle,
  statusWarningSubtle,
  statusErrorSubtle,
  focusRing,
  shadow,
  shadowStrong,
  scrim,
}

extension RoutexColorRoleValue on RoutexColorRole {
  Color resolve(RoutexColorTokens tokens) => switch (this) {
    RoutexColorRole.surfaceCanvas => tokens.surfaceCanvas,
    RoutexColorRole.surfaceBase => tokens.surfaceBase,
    RoutexColorRole.surfaceRaised => tokens.surfaceRaised,
    RoutexColorRole.contentPrimary => tokens.contentPrimary,
    RoutexColorRole.contentSecondary => tokens.contentSecondary,
    RoutexColorRole.contentDisabled => tokens.contentDisabled,
    RoutexColorRole.contentInverse => tokens.contentInverse,
    RoutexColorRole.actionPrimary => tokens.actionPrimary,
    RoutexColorRole.actionPrimaryPressed => tokens.actionPrimaryPressed,
    RoutexColorRole.actionPrimarySubtle => tokens.actionPrimarySubtle,
    RoutexColorRole.actionDisabled => tokens.actionDisabled,
    RoutexColorRole.borderSubtle => tokens.borderSubtle,
    RoutexColorRole.borderStrong => tokens.borderStrong,
    RoutexColorRole.statusInfo => tokens.statusInfo,
    RoutexColorRole.statusSuccess => tokens.statusSuccess,
    RoutexColorRole.statusWarning => tokens.statusWarning,
    RoutexColorRole.statusError => tokens.statusError,
    RoutexColorRole.statusInfoSubtle => tokens.statusInfoSubtle,
    RoutexColorRole.statusSuccessSubtle => tokens.statusSuccessSubtle,
    RoutexColorRole.statusWarningSubtle => tokens.statusWarningSubtle,
    RoutexColorRole.statusErrorSubtle => tokens.statusErrorSubtle,
    RoutexColorRole.focusRing => tokens.focusRing,
    RoutexColorRole.shadow => tokens.shadow,
    RoutexColorRole.shadowStrong => tokens.shadowStrong,
    RoutexColorRole.scrim => tokens.scrim,
  };
}

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
    surfaceCanvas: Color(0xFFF4F7FC),
    surfaceBase: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    contentPrimary: Color(0xFF172033),
    contentSecondary: Color(0xFF4F5D73),
    contentDisabled: Color(0xFF8B96A8),
    contentInverse: Color(0xFFFFFFFF),
    actionPrimary: Color(0xFF2563C7),
    actionPrimaryPressed: Color(0xFF194EAA),
    actionPrimarySubtle: Color(0xFFE7F0FF),
    actionDisabled: Color(0xFFDDE3EC),
    borderSubtle: Color(0xFFDDE3EC),
    borderStrong: Color(0xFF98A3B3),
    statusInfo: Color(0xFF1E5EAA),
    statusSuccess: Color(0xFF1E743B),
    statusWarning: Color(0xFF855600),
    statusError: Color(0xFFB9382E),
    statusInfoSubtle: Color(0xFFE8F2FF),
    statusSuccessSubtle: Color(0xFFE8F6EC),
    statusWarningSubtle: Color(0xFFFFF2D6),
    statusErrorSubtle: Color(0xFFFFECEA),
    focusRing: Color(0xFF1559BE),
    shadow: Color(0x1F172033),
    shadowStrong: Color(0x38172033),
    scrim: Color(0x73172033),
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
