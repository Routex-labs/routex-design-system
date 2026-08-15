import 'package:flutter/material.dart';

import '../foundations/routex_layer.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';

/// 배지가 전하는 상태의 뜻이다.
enum RoutexBadgeTone { neutral, info, success, warning, error }

/// 배지가 놓인 평면이다.
///
/// 시트·목록 안의 배지는 같은 평면에 있으므로 그림자를 갖지 않는다. 지도 위에
/// 홀로 떠 있는 상태 배지만 깊이를 가진다 — 지도 그림 위에서는 그림자가 없으면
/// 배지가 지도의 일부로 읽힌다.
enum RoutexBadgeSurface { inSheet, onMap }

/// 데이터가 이름과 함께 들고 오는 배지 색이다.
///
/// `NEW`·`시즌 한정`처럼 뜻이 상태가 아니라 **분류**인 배지가 있다. 이런 값에
/// `RoutexBadgeTone`을 억지로 배정하면 새 값이 왔을 때 배정할 뜻이 없어진다.
/// 그래서 색은 부르는 쪽이 짝으로 넘기고, 넘기지 않으면 무채색으로 떨어진다.
/// 색은 정보를 더하는 장치이지 그리기 위한 조건이 아니다.
@immutable
class RoutexBadgeAccent {
  const RoutexBadgeAccent({required this.surface, required this.ink});

  final Color surface;

  /// 글자와 테두리에 쓴다. 제 [surface] 위에서 4.5:1을 넘어야 한다.
  final Color ink;
}

/// 상태·분류를 한 낱말로 알리는 작은 표시다.
///
/// **누르는 것이 아니다.** 목록을 좁히는 선택지는 `RoutexChipBar`이고, 배지는
/// 지금 상태를 읽기만 하는 표시다. 둘을 같은 모양으로 그리면 사용자가 배지를
/// 눌러 보고 아무 일도 일어나지 않는 것을 겪는다. 그래서 배지는 알약이 아니라
/// 모서리만 깎은 상자이고, 터치 영역 규칙을 적용하지 않는다.
class RoutexBadge extends StatelessWidget {
  const RoutexBadge({
    required this.label,
    this.tone = RoutexBadgeTone.neutral,
    this.icon,
    this.accent,
    this.surface = RoutexBadgeSurface.inSheet,
    super.key,
  });

  final String label;
  final RoutexBadgeTone tone;
  final IconData? icon;

  /// 데이터가 들고 온 고유색이다. 있으면 [tone]보다 우선한다.
  final RoutexBadgeAccent? accent;

  final RoutexBadgeSurface surface;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final resolved =
        accent ??
        RoutexBadgeAccent(
          surface: switch (tone) {
            RoutexBadgeTone.neutral => colors.surfaceCanvas,
            RoutexBadgeTone.info => colors.statusInfoSubtle,
            RoutexBadgeTone.success => colors.statusSuccessSubtle,
            RoutexBadgeTone.warning => colors.statusWarningSubtle,
            RoutexBadgeTone.error => colors.statusErrorSubtle,
          },
          ink: switch (tone) {
            RoutexBadgeTone.neutral => colors.contentSecondary,
            RoutexBadgeTone.info => colors.statusInfo,
            RoutexBadgeTone.success => colors.statusSuccess,
            RoutexBadgeTone.warning => colors.statusWarning,
            RoutexBadgeTone.error => colors.statusError,
          },
        );

    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: resolved.surface,
          borderRadius: RoutexRadii.control,
          // 테두리는 배경과 같은 색 계열이다. 연한 배경만으로는 흰 표면 위에서
          // 배지의 경계가 사라진다.
          border: Border.all(color: resolved.ink.withValues(alpha: 0.24)),
          boxShadow: switch (surface) {
            RoutexBadgeSurface.inSheet => null,
            RoutexBadgeSurface.onMap => RoutexLayer.shadow(
              RoutexLayerRole.onMap,
              colors,
            ),
          },
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: RoutexSpacing.controlGap,
            vertical: RoutexSpacing.inlineGap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon case final icon?) ...[
                Icon(icon, size: RoutexMetrics.iconSmall, color: resolved.ink),
                const SizedBox(width: RoutexSpacing.inlineGap),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RoutexTypography.control(
                    RoutexTypography.caption,
                  ).copyWith(color: resolved.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
