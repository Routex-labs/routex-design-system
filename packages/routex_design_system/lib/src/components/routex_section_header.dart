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
                  // 카드의 끝선은 48dp 터치 상자가 맡는다. 글자를 끝에 붙이면
                  // hover·pressed 배경이 보일 때 짧은 라벨이 오른쪽으로 쏠려
                  // 보이므로, 글리프는 그 상자 한가운데에 둔다.
                  minimumSize: const WidgetStatePropertyAll(
                    Size.square(RoutexMetrics.minimumTouchTarget),
                  ),
                  alignment: AlignmentDirectional.center,
                  padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                  shape: const WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: RoutexRadii.control),
                  ),
                  textStyle: const WidgetStatePropertyAll(
                    RoutexTypography.label,
                  ),
                  foregroundColor: WidgetStatePropertyAll(colors.actionPrimary),
                ),
                child: Padding(
                  // line box는 중앙이어도 14dp 한글 glyph가 아래로 보인다. 아래
                  // padding을 두 배로 잡으면 48dp 버튼의 실제 글리프가 2dp 올라간다.
                  padding: const EdgeInsetsDirectional.only(
                    bottom:
                        RoutexOpticalCorrection.sectionHeaderActionLabelTop * 2,
                  ),
                  child: Text(actionLabel),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
