import 'package:flutter/material.dart';

import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../components/routex_badge.dart';
import '../components/routex_disclosure.dart';
import '../components/routex_focus_ring.dart';
import '../components/routex_media.dart';
import '../theme/routex_color_tokens.dart';

/// 판매 항목 한 줄이다.
@immutable
class RoutexMenuEntry {
  const RoutexMenuEntry({
    required this.name,
    this.description,
    this.price,
    this.badges = const <RoutexBadge>[],
    this.thumbnail,
    this.selectable = true,
  });

  final String name;

  /// 한두 줄짜리 설명이다. 없을 수 있다 — 출처마다 가진 값이 다르다.
  final String? description;

  /// `4,500원`처럼 서식까지 끝낸 값이다. 통화 표기는 지역을 따라가는 값이라
  /// 숫자를 받아 여기서 만들지 않는다.
  final String? price;

  /// `NEW`·`시즌 한정`처럼 줄에 붙는 표시다. 색은 데이터를 아는 소비 앱이 정한다.
  final List<RoutexBadge> badges;

  final RoutexMediaItem? thumbnail;

  /// 눌러서 더 볼 것이 있는지.
  ///
  /// **더 볼 것이 없으면 누를 수 없게 둔다.** 눌렀는데 줄에 이미 있는 이름만 다시
  /// 나오는 팝업은 막다른 길이고, 한 번 겪으면 다음 줄도 누르지 않는다. 배지는
  /// 세지 않는다 — 배지는 이미 줄에 그려져 있다.
  final bool selectable;
}

/// 매장이 파는 것을 세로 목록으로 세운다.
///
/// **탭과 검색은 이 컴포넌트가 갖지 않는다.** 갈래(음료·푸드)는 `RoutexTabs`, 세부
/// 분류는 `RoutexChipBar`, 이름 찾기는 `RoutexSearchBar`가 이미 맡고 있다. 목록이
/// 자기 위에 붙는 컨트롤까지 소유하면 같은 역할이 화면마다 다른 모양으로 두 번
/// 만들어진다. 여기는 **줄의 생김새와 접힘**만 정한다.
///
/// **배지는 이름 아래 줄이다.** 옆에 붙이면 이름이 그만큼 짧게 잘리는데, 배지가
/// 붙는 항목은 열에 하나 정도라 나머지 아홉의 이름 자리를 소수를 위해 내주는 셈이 된다.
class RoutexMenuList extends StatelessWidget {
  const RoutexMenuList({
    required this.entries,
    required this.expanded,
    required this.onExpanded,
    this.collapsedCount = 5,
    this.onSelected,
    super.key,
  }) : assert(collapsedCount > 0);

  final List<RoutexMenuEntry> entries;

  /// 접혀 있을 때 보이는 줄 수다. 이보다 적으면 펼침 줄 자체가 없다.
  final int collapsedCount;

  final bool expanded;
  final ValueChanged<bool> onExpanded;

  /// 줄을 눌렀을 때. null이면 읽기만 하는 목록이다.
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final visibleCount = expanded
        ? entries.length
        : entries.length.clamp(0, collapsedCount);
    final hidden = entries.length - visibleCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < visibleCount; index++)
          _MenuRow(
            entry: entries[index],
            onPressed: onSelected == null || !entries[index].selectable
                ? null
                : () => onSelected!(index),
          ),
        if (hidden > 0 || expanded)
          RoutexShowMore(
            expanded: expanded,
            onExpanded: onExpanded,
            hiddenCount: hidden > 0 ? hidden : null,
          ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.entry, required this.onPressed});

  final RoutexMenuEntry entry;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    final content = Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: RoutexSpacing.contentGap,
        vertical: RoutexSpacing.contentGap,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RoutexTypography.bodyStrong,
                ),
                if (entry.badges.isNotEmpty) ...[
                  const SizedBox(height: RoutexSpacing.inlineGap),
                  Wrap(
                    spacing: RoutexSpacing.inlineGap,
                    runSpacing: RoutexSpacing.inlineGap,
                    children: entry.badges,
                  ),
                ],
                if (entry.description?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: RoutexSpacing.inlineGap),
                  Text(
                    entry.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: RoutexTypography.bodySmall.copyWith(
                      color: colors.contentSecondary,
                    ),
                  ),
                ],
                if (entry.price?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: RoutexSpacing.controlGap),
                  Text(
                    entry.price!,
                    style: RoutexTypography.tabular(RoutexTypography.label),
                  ),
                ],
              ],
            ),
          ),
          if (entry.thumbnail case final thumbnail?) ...[
            const SizedBox(width: RoutexSpacing.contentGap),
            SizedBox.square(
              dimension: RoutexMetrics.thumbnail,
              child: ClipRRect(
                borderRadius: RoutexRadii.field,
                child: Image(image: thumbnail.image, fit: BoxFit.cover),
              ),
            ),
          ],
        ],
      ),
    );

    if (onPressed == null) return content;

    return Semantics(
      button: true,
      label: entry.name,
      excludeSemantics: true,
      child: RoutexFocusRing(
        radius: RoutexRadii.field,
        child: Material(
          color: Colors.transparent,
          borderRadius: RoutexRadii.field,
          child: InkWell(
            onTap: onPressed,
            borderRadius: RoutexRadii.field,
            focusColor: Colors.transparent,
            hoverColor: colors.actionPrimarySubtle,
            child: content,
          ),
        ),
      ),
    );
  }
}
