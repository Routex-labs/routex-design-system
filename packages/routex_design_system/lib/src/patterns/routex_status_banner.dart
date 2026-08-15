import 'package:flutter/material.dart';

import '../foundations/routex_layer.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';

enum RoutexStatusBannerTone { neutral, success, warning, error }

/// 완료·경고·오류처럼 현재 상태를 지도 위에서 제목과 설명으로 전달한다.
class RoutexStatusBanner extends StatelessWidget {
  const RoutexStatusBanner({
    required this.title,
    required this.detail,
    this.icon,
    this.tone = RoutexStatusBannerTone.neutral,
    super.key,
  });

  final String title;
  final String detail;
  final IconData? icon;
  final RoutexStatusBannerTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final (background, foreground) = switch (tone) {
      RoutexStatusBannerTone.neutral => (
        colors.surfaceRaised,
        colors.contentPrimary,
      ),
      RoutexStatusBannerTone.success => (
        colors.statusSuccessSubtle,
        colors.statusSuccess,
      ),
      RoutexStatusBannerTone.warning => (
        colors.statusWarningSubtle,
        colors.statusWarning,
      ),
      RoutexStatusBannerTone.error => (
        colors.statusErrorSubtle,
        colors.statusError,
      ),
    };

    return Semantics(
      container: true,
      label: '$title, $detail',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: RoutexRadii.field,
          boxShadow: RoutexLayer.shadow(RoutexLayerRole.chrome, colors),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(
            RoutexSpacing.componentPadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, size: RoutexMetrics.iconLarge, color: foreground),
                const SizedBox(width: RoutexSpacing.contentGap),
              ],
              Expanded(
                child: RoutexStack(
                  gap: RoutexStackGap.inline,
                  children: [
                    Text(
                      title,
                      style: RoutexTypography.title.copyWith(color: foreground),
                    ),
                    Text(
                      detail,
                      style: RoutexTypography.label.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
