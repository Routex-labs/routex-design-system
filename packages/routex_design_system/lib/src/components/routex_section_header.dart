import 'package:flutter/material.dart';

import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';

/// 제목 줄이 맡는 위계다.
///
/// `section`은 화면 안에서 목록 묶음을 여는 제목이고, `group`은 한 목록 안에서
/// 항목을 몇 갈래로 나누는 구획 라벨이다. 같은 크기로 그리면 목록 안의 구획이
/// 새 화면처럼 읽힌다.
enum RoutexSectionHeaderLevel { section, group }

/// 목록 묶음의 제목과 묶음 전체에 대한 보조 동작을 한 줄에 고정한다.
///
/// 제목은 언제나 같은 위계를 쓰고, 보조 동작은 목록을 여는 quiet 동작 하나만
/// 받는다. 주 행동은 이 줄에 넣지 않는다.
class RoutexSectionHeader extends StatelessWidget {
  const RoutexSectionHeader({
    required this.title,
    this.level = RoutexSectionHeaderLevel.section,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : assert(
         actionLabel == null || onAction != null,
         '보조 동작 이름만 있고 동작이 없으면 누를 수 없는 줄이 된다',
       );

  final String title;
  final RoutexSectionHeaderLevel level;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return Semantics(
      container: true,
      header: true,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: switch (level) {
                RoutexSectionHeaderLevel.section => RoutexTypography.title,
                RoutexSectionHeaderLevel.group =>
                  RoutexTypography.label.copyWith(
                    color: colors.contentSecondary,
                  ),
              },
            ),
          ),
          if (actionLabel case final actionLabel?) ...[
            const SizedBox(width: RoutexSpacing.controlGap),
            Semantics(
              button: true,
              focusable: true,
              label: actionLabel,
              onTap: onAction,
              excludeSemantics: true,
              child: TextButton(
                onPressed: onAction,
                style: ButtonStyle(
                  // 누를 자리는 넓히되 글자는 표면 가장자리에 맞춘다. 좌우
                  // 패딩으로 터치 영역을 만들면 그 패딩만큼 글자가 안쪽으로
                  // 밀려, 패딩 없는 왼쪽 제목과 여백이 달라진다. 상자를 키우고
                  // 글자를 끝에 붙여 터치 영역이 정렬선 바깥으로 자라게 한다.
                  // 짧은 라벨에도 상자를 48로 잡는다. 44로 두면 Material이
                  // 터치 영역을 48로 늘리면서 좌우로 2씩 나눠 붙여, 글자가 다시
                  // 안쪽으로 밀린다.
                  minimumSize: const WidgetStatePropertyAll(
                    Size.square(RoutexMetrics.minimumTouchTarget),
                  ),
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                  shape: const WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: RoutexRadii.control),
                  ),
                  textStyle: const WidgetStatePropertyAll(
                    RoutexTypography.label,
                  ),
                  foregroundColor: WidgetStatePropertyAll(colors.actionPrimary),
                ),
                child: Text(actionLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
