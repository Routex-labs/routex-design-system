import 'package:flutter/material.dart';

import '../foundations/routex_layer.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';

/// 안내 중 다음 행동과 보조 맥락을 한 묶음으로 표시한다.
class RoutexManeuverBanner extends StatelessWidget {
  const RoutexManeuverBanner({
    required this.distance,
    required this.detail,
    required this.icon,
    super.key,
  });

  final String distance;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return Semantics(
      container: true,
      label: '$distance, $detail',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.actionPrimaryPressed,
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
              Icon(
                icon,
                size: RoutexMetrics.iconLarge,
                color: colors.contentInverse,
              ),
              const SizedBox(width: RoutexSpacing.contentGap),
              Expanded(
                child: RoutexStack(
                  gap: RoutexStackGap.inline,
                  children: [
                    Text(
                      distance,
                      style: RoutexTypography.tabular(
                        RoutexTypography.title,
                      ).copyWith(color: colors.contentInverse),
                    ),
                    Text(
                      detail,
                      style: RoutexTypography.label.copyWith(
                        color: colors.contentInverse,
                      ),
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
