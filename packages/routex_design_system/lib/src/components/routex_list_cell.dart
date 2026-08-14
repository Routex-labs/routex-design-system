import 'package:flutter/material.dart';

import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';

/// 장소·검색 결과에서 텍스트 열과 상태 위계를 고정하는 v0.1 beta cell이다.
class RoutexListCell extends StatelessWidget {
  const RoutexListCell({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailingIcon,
    this.selected = false,
    this.enabled = true,
    this.onPressed,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  bool get _hasSubtitle => subtitle?.trim().isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final interactive = onPressed != null;
    final foreground = enabled ? colors.contentPrimary : colors.contentDisabled;
    final secondaryForeground = enabled
        ? colors.contentSecondary
        : colors.contentDisabled;

    return Semantics(
      container: true,
      button: interactive,
      enabled: interactive ? enabled : null,
      selected: selected,
      label: _hasSubtitle ? '$title, $subtitle' : title,
      excludeSemantics: true,
      child: Material(
        color: selected ? colors.actionPrimarySubtle : Colors.transparent,
        borderRadius: RoutexRadii.field,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: RoutexRadii.field,
          focusColor: colors.actionPrimarySubtle,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.pressed)
                ? selected
                      ? colors.surfaceCanvas
                      : colors.actionPrimarySubtle
                : null;
          }),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: RoutexMetrics.minimumTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: RoutexSpacing.controlGap,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: RoutexMetrics.leadingColumn,
                    child: leadingIcon == null
                        ? null
                        : Align(
                            alignment: AlignmentDirectional.topStart,
                            child: Icon(
                              leadingIcon,
                              size: RoutexMetrics.iconMedium,
                              color: enabled
                                  ? colors.actionPrimary
                                  : colors.contentDisabled,
                            ),
                          ),
                  ),
                  const SizedBox(width: RoutexSpacing.contentGap),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          style: RoutexTypography.bodyStrong.copyWith(
                            color: foreground,
                          ),
                        ),
                        if (_hasSubtitle) ...[
                          const SizedBox(height: RoutexSpacing.inlineGap),
                          Text(
                            subtitle!,
                            style: RoutexTypography.body.copyWith(
                              color: secondaryForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailingIcon case final icon?) ...[
                    const SizedBox(width: RoutexSpacing.contentGap),
                    Icon(
                      icon,
                      size: RoutexMetrics.iconMedium,
                      color: secondaryForeground,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
