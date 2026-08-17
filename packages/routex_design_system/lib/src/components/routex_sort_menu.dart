import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';

/// 목록을 세우는 기준 하나다.
@immutable
class RoutexSortOption {
  const RoutexSortOption({
    required this.id,
    required this.label,
    this.unavailableReason,
  });

  final String id;
  final String label;

  /// 지금 이 기준을 쓸 수 없는 이유다. 있으면 고를 수 없고, 라벨 뒤에 이유가
  /// 함께 적힌다.
  ///
  /// **사용할 수 없는 기준을 목록에서 감추지 않는다.** 감추면 "가까운 순"이 아예
  /// 없는 앱으로 읽히고, 눌러 본 뒤 오류로 막으면 왜 안 되는지를 그때야 알게 된다.
  /// 이유를 먼저 적으면 사용자가 무엇을 하면 쓸 수 있는지까지 안다.
  final String? unavailableReason;

  bool get available => unavailableReason == null;
}

/// 목록의 정렬 기준을 고른다.
///
/// 지금 기준을 글자로 드러낸다. 아이콘만 두면 목록이 무슨 순서인지 화면 어디에도
/// 적혀 있지 않게 되고, 사용자는 결과가 이상할 때 그것이 정렬 때문인지 검색 때문인지
/// 구분하지 못한다.
///
/// 기준이 하나뿐이면 이 컨트롤을 그리지 않는다 — 고를 것이 없는 선택지는 자리만
/// 차지한다.
class RoutexSortMenu extends StatelessWidget {
  const RoutexSortMenu({
    required this.options,
    required this.selectedId,
    required this.onSelected,
    super.key,
  }) : assert(options.length > 1, '고를 것이 하나뿐이면 정렬 컨트롤을 그리지 않는다');

  final List<RoutexSortOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final selected = options.firstWhere(
      (option) => option.id == selectedId,
      orElse: () => options.first,
    );

    return Semantics(
      container: true,
      button: true,
      label: '정렬 기준, ${selected.label}',
      child: PopupMenuButton<String>(
        initialValue: selected.id,
        tooltip: '정렬 기준',
        position: PopupMenuPosition.under,
        color: colors.surfaceRaised,
        shape: const RoundedRectangleBorder(borderRadius: RoutexRadii.field),
        onSelected: onSelected,
        itemBuilder: (context) => [
          for (final option in options)
            PopupMenuItem<String>(
              value: option.id,
              enabled: option.available,
              child: Row(
                children: [
                  // 고른 항목에만 체크를 둔다. 자리 자체는 모든 줄이 가진다 —
                  // 체크가 있는 줄만 들여쓰기가 달라지면 목록이 흔들린다.
                  SizedBox(
                    width: RoutexMetrics.iconLarge,
                    child: option.id == selected.id
                        ? Icon(
                            RoutexIcons.success,
                            size: RoutexMetrics.iconSmall,
                            color: colors.actionPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(width: RoutexSpacing.controlGap),
                  Flexible(
                    child: Text(
                      option.available
                          ? option.label
                          : '${option.label} (${option.unavailableReason})',
                      style: RoutexTypography.label.copyWith(
                        color: option.available
                            ? colors.contentPrimary
                            : colors.contentDisabled,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: RoutexSpacing.controlGap,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: RoutexMetrics.minimumTouchTarget,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  RoutexIcons.sort,
                  size: RoutexMetrics.iconMedium,
                  color: colors.actionPrimary,
                ),
                const SizedBox(width: RoutexSpacing.inlineGap),
                Text(
                  selected.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RoutexTypography.label.copyWith(
                    color: colors.actionPrimary,
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
