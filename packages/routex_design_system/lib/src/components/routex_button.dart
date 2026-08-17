import 'package:flutter/material.dart';

import '../foundations/routex_motion.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';

enum RoutexButtonVariant { primary, secondary, quiet, danger }

/// 버튼이 차지하는 시각적 밀도다. 두 크기 모두 실제 터치 영역은 48dp다.
enum RoutexButtonSize { standard, compact }

/// v0.1의 첫 vertical slice다. 임의 padding/radius/textStyle은 외부에 열지 않는다.
class RoutexButton extends StatelessWidget {
  const RoutexButton({
    required this.label,
    required this.onPressed,
    this.variant = RoutexButtonVariant.primary,
    this.leadingIcon,
    this.isLoading = false,
    this.size = RoutexButtonSize.standard,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final RoutexButtonVariant variant;
  final IconData? leadingIcon;
  final bool isLoading;
  final RoutexButtonSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final disabled = onPressed == null || isLoading;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final foreground = _foreground(colors, disabled: disabled);

    return Semantics(
      button: true,
      enabled: !disabled,
      focusable: !disabled,
      label: label,
      liveRegion: isLoading,
      onTap: disabled ? null : onPressed,
      excludeSemantics: true,
      child: TextButton(
        onPressed: disabled ? null : onPressed,
        style: ButtonStyle(
          // ThemeData.visualDensity는 데스크톱에서 기본적으로 compact라 같은
          // size도 웹에서 작아진다. 크기 토큰은 플랫폼과 무관한 계약이다.
          visualDensity: VisualDensity.standard,
          minimumSize: WidgetStatePropertyAll(
            Size(
              RoutexMetrics.minimumButtonWidth,
              size == RoutexButtonSize.compact
                  ? RoutexMetrics.compactControl
                  : RoutexMetrics.standardControl,
            ),
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
          padding: WidgetStatePropertyAll(
            EdgeInsetsDirectional.symmetric(
              horizontal: RoutexSpacing.componentPadding,
              vertical: size == RoutexButtonSize.compact
                  ? 0
                  : RoutexSpacing.inlineGap,
            ),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: RoutexRadii.field),
          ),
          textStyle: WidgetStatePropertyAll(
            RoutexTypography.control(RoutexTypography.bodyStrong),
          ),
          foregroundColor: WidgetStatePropertyAll(foreground),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => _background(colors, states, disabled: disabled),
          ),
          side: WidgetStatePropertyAll(_border(colors, disabled: disabled)),
        ),
        child: AnimatedSwitcher(
          duration: RoutexMotion.effectiveDuration(
            disableAnimations: disableAnimations,
            role: RoutexMotionRole.feedback,
          ),
          child: isLoading
              ? SizedBox.square(
                  key: const ValueKey('loading'),
                  dimension: RoutexMetrics.iconMedium,
                  child: CircularProgressIndicator(
                    strokeWidth: RoutexStroke.emphasis,
                    color: foreground,
                  ),
                )
              : Row(
                  key: const ValueKey('content'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leadingIcon case final icon?) ...[
                      Icon(icon, size: RoutexMetrics.iconMedium),
                      const SizedBox(width: RoutexSpacing.controlGap),
                    ],
                    Flexible(child: Text(label)),
                  ],
                ),
        ),
      ),
    );
  }

  Color _foreground(RoutexColorTokens colors, {required bool disabled}) {
    if (disabled) return colors.contentDisabled;
    return switch (variant) {
      RoutexButtonVariant.primary ||
      RoutexButtonVariant.danger => colors.contentInverse,
      RoutexButtonVariant.secondary ||
      RoutexButtonVariant.quiet => colors.actionPrimary,
    };
  }

  Color _background(
    RoutexColorTokens colors,
    Set<WidgetState> states, {
    required bool disabled,
  }) {
    if (disabled) return colors.actionDisabled;
    if (variant == RoutexButtonVariant.quiet) return Colors.transparent;
    if (variant == RoutexButtonVariant.secondary) {
      return states.contains(WidgetState.pressed)
          ? colors.surfaceCanvas
          : colors.surfaceRaised;
    }
    if (variant == RoutexButtonVariant.danger) return colors.statusError;
    return states.contains(WidgetState.pressed)
        ? colors.actionPrimaryPressed
        : colors.actionPrimary;
  }

  BorderSide _border(RoutexColorTokens colors, {required bool disabled}) {
    if (variant != RoutexButtonVariant.secondary) return BorderSide.none;
    return BorderSide(
      color: disabled ? colors.borderSubtle : colors.borderStrong,
    );
  }
}
