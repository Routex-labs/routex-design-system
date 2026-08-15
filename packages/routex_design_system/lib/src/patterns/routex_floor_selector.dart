import 'package:flutter/material.dart';

import '../foundations/routex_layer.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';

@immutable
class RoutexFloorOption {
  const RoutexFloorOption({required this.id, required this.label});

  final int id;
  final String label;
}

/// 지도 위 층 목록의 크기, 구분선, 선택 상태와 접근성 이름을 고정한다.
class RoutexFloorSelector extends StatelessWidget {
  const RoutexFloorSelector({
    required this.options,
    required this.selectedId,
    required this.onSelected,
    super.key,
  }) : assert(options.length > 0);

  final List<RoutexFloorOption> options;
  final int selectedId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    // 세로 컨트롤이므로 부모가 넓어져도 폭은 셀 하나의 폭을 유지한다.
    return SizedBox(
      width: RoutexMetrics.minimumTouchTarget,
      child: Material(
        color: colors.surfaceRaised,
        borderRadius: RoutexRadii.field,
        elevation: RoutexLayer.onMap,
        shadowColor: colors.shadow,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < options.length; index++) ...[
              if (index > 0)
                SizedBox(
                  width: RoutexMetrics.minimumTouchTarget,
                  child: Divider(height: 1, color: colors.borderSubtle),
                ),
              _FloorItem(
                option: options[index],
                selected: options[index].id == selectedId,
                onPressed: () => onSelected(options[index].id),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FloorItem extends StatelessWidget {
  const _FloorItem({
    required this.option,
    required this.selected,
    required this.onPressed,
  });

  final RoutexFloorOption option;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return Semantics(
      button: true,
      selected: selected,
      label: option.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          width: RoutexMetrics.minimumTouchTarget,
          height: RoutexMetrics.minimumTouchTarget,
          color: selected ? colors.actionPrimarySubtle : Colors.transparent,
          child: Center(
            child: Text(
              option.label,
              style: RoutexTypography.tabular(RoutexTypography.label).copyWith(
                color: selected
                    ? colors.actionPrimary
                    : colors.contentSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
