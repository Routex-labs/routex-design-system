import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../layout/routex_stack.dart';
import '../components/routex_surface.dart';
import '../theme/routex_color_tokens.dart';
import 'routex_travel_mode_bar.dart';

/// 출발지 → 목적지 → 가능한 이동수단 순서를 고정하는 경로 계획 패턴이다.
class RoutexRoutePlanner extends StatelessWidget {
  const RoutexRoutePlanner({
    required this.originLabel,
    required this.destinationLabel,
    required this.travelModes,
    required this.selectedTravelModeId,
    required this.onTravelModeSelected,
    this.onOriginPressed,
    this.onDestinationPressed,
    this.onClose,
    this.onDestinationMore,
    super.key,
  });

  final String originLabel;
  final String destinationLabel;
  final List<RoutexTravelModeOption> travelModes;
  final String? selectedTravelModeId;
  final ValueChanged<String> onTravelModeSelected;
  final VoidCallback? onOriginPressed;
  final VoidCallback? onDestinationPressed;
  final VoidCallback? onClose;
  final VoidCallback? onDestinationMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return RoutexSurface(
      role: RoutexSurfaceRole.chrome,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(RoutexSpacing.controlGap),
        child: RoutexStack(
          gap: RoutexStackGap.inline,
          children: [
            _RouteLocationField(
              label: originLabel,
              destination: false,
              onPressed: onOriginPressed,
              actionLabel: '경로 계획 닫기',
              actionIcon: RoutexIcons.close,
              onAction: onClose,
            ),
            Divider(height: 1, color: colors.borderSubtle),
            _RouteLocationField(
              label: destinationLabel,
              destination: true,
              onPressed: onDestinationPressed,
              actionLabel: '목적지 더보기',
              actionIcon: RoutexIcons.more,
              onAction: onDestinationMore,
            ),
            RoutexTravelModeBar(
              options: travelModes,
              selectedId: selectedTravelModeId,
              onSelected: onTravelModeSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteLocationField extends StatelessWidget {
  const _RouteLocationField({
    required this.label,
    required this.destination,
    required this.onPressed,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  final String label;
  final bool destination;
  final VoidCallback? onPressed;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return Row(
      children: [
        const SizedBox(width: RoutexSpacing.controlGap),
        Container(
          width: RoutexSpacing.contentGap,
          height: RoutexSpacing.contentGap,
          decoration: BoxDecoration(
            color: destination ? colors.statusError : colors.surfaceRaised,
            shape: BoxShape.circle,
            border: destination
                ? null
                : Border.all(color: colors.actionPrimary, width: 2),
          ),
        ),
        const SizedBox(width: RoutexSpacing.contentGap),
        Expanded(
          child: Semantics(
            button: true,
            enabled: onPressed != null,
            label: label,
            excludeSemantics: true,
            child: InkWell(
              onTap: onPressed,
              borderRadius: RoutexRadii.control,
              // focus·hover는 화면마다 Material 기본 회색이 되지 않도록
              // 목록 행과 같은 tint를 쓴다.
              focusColor: colors.actionPrimarySubtle,
              hoverColor: colors.actionPrimarySubtle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: RoutexMetrics.standardControl,
                ),
                child: Padding(
                  // 두 칸의 강조 영역이 같은 여백을 갖도록 텍스트 열 안쪽에서
                  // 여백을 준다. 칸마다 다르면 hover·focus 폭이 달라 보인다.
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: RoutexSpacing.controlGap,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: RoutexTypography.label,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox.square(
          dimension: RoutexMetrics.standardControl,
          child: IconButton(
            tooltip: actionLabel,
            onPressed: onAction,
            padding: EdgeInsets.zero,
            iconSize: RoutexMetrics.iconMedium,
            color: colors.contentSecondary,
            icon: Icon(actionIcon),
          ),
        ),
      ],
    );
  }
}
