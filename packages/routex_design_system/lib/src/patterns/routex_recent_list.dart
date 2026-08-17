import 'package:flutter/material.dart';

import '../components/routex_divider.dart';
import '../components/routex_list_cell.dart';
import '../components/routex_section_header.dart';
import '../foundations/routex_icons.dart';
import '../foundations/routex_spacing.dart';

/// 최근 검색과 최근 경로가 공유하는 한 항목이다.
class RoutexRecentItem {
  const RoutexRecentItem({
    required this.id,
    required this.title,
    required this.onPressed,
    required this.onRemove,
    this.subtitle,
  });

  final String id;
  final String title;
  final String? subtitle;
  final VoidCallback onPressed;
  final VoidCallback onRemove;
}

/// 최근 항목의 제목·전체 삭제·행 밀도·아이콘을 한 계약으로 고정한다.
class RoutexRecentList extends StatelessWidget {
  const RoutexRecentList({
    required this.title,
    required this.items,
    required this.onClear,
    this.showTopDivider = false,
    super.key,
  });

  final String title;
  final List<RoutexRecentItem> items;
  final VoidCallback onClear;
  final bool showTopDivider;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTopDivider)
          const RoutexDivider(role: RoutexDividerRole.section),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RoutexSpacing.contentGap,
          ),
          child: RoutexSectionHeader(
            title: title,
            actionLabel: '전체 삭제',
            onAction: onClear,
          ),
        ),
        for (final item in items)
          RoutexListCell(
            key: ValueKey(item.id),
            title: item.title,
            subtitle: item.subtitle,
            leadingIcon: RoutexIcons.recent,
            leadingIconTone: RoutexListIconTone.quiet,
            trailingActionLabel: '${item.title} 삭제',
            trailingActionIcon: RoutexIcons.close,
            onTrailingAction: item.onRemove,
            onPressed: item.onPressed,
          ),
      ],
    );
  }
}
