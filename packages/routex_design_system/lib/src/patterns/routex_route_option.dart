import 'package:flutter/material.dart';

import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';

/// 시간·거리·경로 특성과 선택 상태의 위계를 고정한다.
class RoutexRouteOption extends StatelessWidget {
  const RoutexRouteOption({
    required this.title,
    required this.detail,
    required this.meta,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final String title;
  final String detail;
  final String meta;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return Semantics(
      button: true,
      selected: selected,
      enabled: onPressed != null,
      label: '$title, $detail, $meta',
      excludeSemantics: true,
      child: Material(
        color: selected ? colors.actionPrimarySubtle : colors.surfaceRaised,
        borderRadius: RoutexRadii.field,
        child: InkWell(
          onTap: onPressed,
          borderRadius: RoutexRadii.field,
          child: Container(
            padding: const EdgeInsetsDirectional.all(
              RoutexSpacing.componentPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: RoutexRadii.field,
              border: Border.all(
                color: selected ? colors.accentBrand : colors.borderSubtle,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RoutexStack(
                    gap: RoutexStackGap.inline,
                    children: [
                      Text(
                        title,
                        style: RoutexTypography.tabular(RoutexTypography.title),
                      ),
                      Text(
                        detail,
                        style: RoutexTypography.tabular(
                          RoutexTypography.caption,
                        ).copyWith(color: colors.contentSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: RoutexSpacing.contentGap),
                Text(
                  meta,
                  textAlign: TextAlign.end,
                  style: RoutexTypography.tabular(RoutexTypography.label)
                      .copyWith(
                        color: onPressed == null
                            ? colors.contentDisabled
                            : colors.actionPrimary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
