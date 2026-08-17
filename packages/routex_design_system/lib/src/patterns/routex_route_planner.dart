import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../components/routex_surface.dart';
import '../theme/routex_color_tokens.dart';
import 'routex_travel_mode_bar.dart';

enum RoutexRouteField { origin, destination }

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
    this.editingField,
    this.editingController,
    this.editingFocusNode,
    this.editingFieldKey,
    this.onEditingChanged,
    this.onEditingSubmitted,
    super.key,
  }) : assert(
         editingField == null || editingController != null,
         '편집 행은 controller가 필요하다',
       );

  final String originLabel;
  final String destinationLabel;
  final List<RoutexTravelModeOption> travelModes;
  final String? selectedTravelModeId;
  final ValueChanged<String> onTravelModeSelected;
  final VoidCallback? onOriginPressed;
  final VoidCallback? onDestinationPressed;
  final VoidCallback? onClose;
  final VoidCallback? onDestinationMore;
  final RoutexRouteField? editingField;
  final TextEditingController? editingController;
  final FocusNode? editingFocusNode;
  final Key? editingFieldKey;
  final ValueChanged<String>? onEditingChanged;
  final ValueChanged<String>? onEditingSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return RoutexSurface(
      role: RoutexSurfaceRole.chrome,
      child: Padding(
        // 각 위치 행이 이미 48dp 터치 영역을 보장한다. 상하에도 controlGap을
        // 더하면 입력 중 카드가 필요 이상으로 두꺼워지므로 inlineGap만 둔다.
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: RoutexSpacing.controlGap,
          vertical: RoutexSpacing.inlineGap,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RouteLocationField(
              label: originLabel,
              destination: false,
              editing: editingField == RoutexRouteField.origin,
              controller: editingField == RoutexRouteField.origin
                  ? editingController
                  : null,
              focusNode: editingField == RoutexRouteField.origin
                  ? editingFocusNode
                  : null,
              editingKey: editingField == RoutexRouteField.origin
                  ? editingFieldKey
                  : null,
              onChanged: onEditingChanged,
              onSubmitted: onEditingSubmitted,
              onPressed: onOriginPressed,
              actionLabel: '경로 계획 닫기',
              actionIcon: RoutexIcons.close,
              onAction: onClose,
            ),
            Divider(height: RoutexStroke.hairline, color: colors.borderSubtle),
            _RouteLocationField(
              label: destinationLabel,
              destination: true,
              editing: editingField == RoutexRouteField.destination,
              controller: editingField == RoutexRouteField.destination
                  ? editingController
                  : null,
              focusNode: editingField == RoutexRouteField.destination
                  ? editingFocusNode
                  : null,
              editingKey: editingField == RoutexRouteField.destination
                  ? editingFieldKey
                  : null,
              onChanged: onEditingChanged,
              onSubmitted: onEditingSubmitted,
              onPressed: onDestinationPressed,
              actionLabel: '목적지 더보기',
              actionIcon: RoutexIcons.more,
              onAction: onDestinationMore,
            ),
            if (travelModes.isNotEmpty) ...[
              const SizedBox(height: RoutexSpacing.inlineGap),
              RoutexTravelModeBar(
                options: travelModes,
                selectedId: selectedTravelModeId,
                onSelected: onTravelModeSelected,
              ),
            ],
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
    required this.editing,
    required this.controller,
    required this.focusNode,
    required this.editingKey,
    required this.onChanged,
    required this.onSubmitted,
    required this.onPressed,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  final String label;
  final bool destination;
  final bool editing;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Key? editingKey;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
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
                : Border.all(
                    color: colors.actionPrimary,
                    width: RoutexStroke.emphasis,
                  ),
          ),
        ),
        const SizedBox(width: RoutexSpacing.contentGap),
        Expanded(
          child: editing
              ? KeyedSubtree(
                  key: editingKey,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: RoutexMetrics.minimumTouchTarget,
                    ),
                    child: Center(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: true,
                        onChanged: onChanged,
                        onSubmitted: onSubmitted,
                        textInputAction: TextInputAction.search,
                        maxLines: 1,
                        style: RoutexTypography.label,
                        decoration: InputDecoration(
                          hintText: destination ? '도착지를 입력하세요' : '출발지를 입력하세요',
                          hintStyle: RoutexTypography.label.copyWith(
                            color: colors.contentSecondary,
                          ),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsetsDirectional.symmetric(
                            horizontal: RoutexSpacing.controlGap,
                            vertical: RoutexSpacing.contentGap,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Semantics(
                  button: true,
                  enabled: onPressed != null,
                  focusable: onPressed != null,
                  label: label,
                  onTap: onPressed,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: onPressed,
                    borderRadius: RoutexRadii.control,
                    // focus는 theme의 focus state layer를, hover는 중립적인 제품 tint를
                    // 쓴다. 둘을 같은 채움으로 두면 키보드 초점을 구분할 수 없다.
                    focusColor: Theme.of(context).focusColor,
                    hoverColor: colors.actionPrimarySubtle,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: RoutexMetrics.minimumTouchTarget,
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
          dimension: RoutexMetrics.minimumTouchTarget,
          child: onAction == null
              ? null
              : IconButton(
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
