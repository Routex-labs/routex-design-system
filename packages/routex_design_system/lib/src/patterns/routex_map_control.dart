import 'package:flutter/material.dart';

import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_typography.dart';
import '../components/routex_focus_ring.dart';
import '../components/routex_surface.dart';
import '../theme/routex_color_tokens.dart';

/// 지도 위 단일 아이콘 또는 층 라벨 동작의 크기와 상태를 고정한다.
class RoutexMapControl extends StatelessWidget {
  const RoutexMapControl({
    required this.label,
    required this.icon,
    this.text,
    this.selected = false,
    this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final String? text;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final foreground = onPressed == null
        ? colors.contentDisabled
        : selected
        ? colors.actionPrimary
        : colors.contentPrimary;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        // 보이는 크기는 44, 터치 영역은 48이다. 지도 버튼이 48로 보이면 지도를
        // 그만큼 더 가린다.
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: SizedBox.square(
            dimension: RoutexMetrics.minimumTouchTarget,
            child: Center(
              child: RoutexFocusRing(
                radius: RoutexRadii.field,
                enabled: onPressed != null,
                child: RoutexSurface(
                  role: RoutexSurfaceRole.onMap,
                  shape: RoutexSurfaceShape.field,
                  child: Ink(
                    color: selected
                        ? colors.actionPrimarySubtle
                        : colors.surfaceRaised,
                    child: InkWell(
                      onTap: onPressed,
                      borderRadius: RoutexRadii.field,
                      child: SizedBox.square(
                        dimension: RoutexMetrics.standardControl,
                        child: Center(
                          child: text == null
                              ? Icon(
                                  icon,
                                  size: RoutexMetrics.iconMedium,
                                  color: foreground,
                                )
                              : Text(
                                  text!,
                                  style: RoutexTypography.label.copyWith(
                                    color: onPressed == null
                                        ? colors.contentDisabled
                                        : colors.actionPrimary,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
