import 'package:flutter/material.dart';

import '../foundations/routex_metrics.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';

/// 같은 위계의 상세 콘텐츠를 바꾸는 고정형 탭이다.
class RoutexTabs extends StatelessWidget {
  const RoutexTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  }) : assert(labels.length > 1),
       assert(selectedIndex >= 0 && selectedIndex < labels.length);

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return Row(
      children: [
        for (var index = 0; index < labels.length; index++)
          Expanded(
            child: Semantics(
              button: true,
              selected: selectedIndex == index,
              child: InkWell(
                onTap: () => onSelected(index),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: RoutexMetrics.minimumTouchTarget,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          // 표시줄은 선이라 accentBrand, 라벨은 글자라
                          // actionPrimary다. 같은 포인트 계열이되 역할이 다르다.
                          color: selectedIndex == index
                              ? colors.accentBrand
                              : colors.borderSubtle,
                          width: selectedIndex == index
                              ? RoutexStroke.emphasis
                              : RoutexStroke.hairline,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        labels[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RoutexTypography.label.copyWith(
                          color: selectedIndex == index
                              ? colors.actionPrimary
                              : colors.contentSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
