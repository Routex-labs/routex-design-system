import 'package:flutter/painting.dart';

import 'routex_color_tokens.dart';

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
  accentBrand,
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
    RoutexColorRole.accentBrand => tokens.accentBrand,
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
