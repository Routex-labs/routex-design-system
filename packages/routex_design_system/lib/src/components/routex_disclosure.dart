import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_motion.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';
import 'routex_focus_ring.dart';

/// 접혀 있는 내용을 그 자리에서 펼친다.
///
/// **화면을 바꾸지 않는다.** 자세히 보려고 새 화면으로 넘어가면 돌아왔을 때
/// 스크롤 위치와 다른 섹션의 펼침 상태를 잃는다. 상세 화면의 곁가지 정보는 전부
/// 이 자리에서 열고 닫는다.
///
/// **접힌 상태에서도 답 하나는 보인다**([preview]). 영업시간을 보는 사람의 첫
/// 질문은 "지금 갈 수 있나"이고 두 번째가 "오늘 몇 시까지"다. 일곱 줄을 전부
/// 접으면 두 번째 질문에 답하려고 매번 펼쳐야 하고, 전부 펴면 다른 섹션이 화면
/// 밖으로 밀린다. 한 줄만 남기는 것이 그 사이다.
///
/// 펼침 상태는 부르는 쪽이 가진다. 섹션이 스스로 기억하면 목록을 다시 그릴 때
/// 조용히 접히고, 화면은 그 사실을 알 수 없다.
class RoutexDisclosure extends StatelessWidget {
  const RoutexDisclosure({
    required this.header,
    required this.expanded,
    required this.onExpanded,
    required this.child,
    this.leadingIcon,
    this.preview,
    this.semanticsLabel,
    super.key,
  });

  /// 접혀 있어도 늘 보이는 요약 줄이다.
  final Widget header;

  /// 접혀 있어도 보이는 본문 첫 줄이다.
  final Widget? preview;

  /// 펼쳤을 때 나오는 나머지다.
  final Widget child;

  final IconData? leadingIcon;
  final bool expanded;
  final ValueChanged<bool> onExpanded;

  /// 머리 줄이 글자가 아닐 때(상태 문장·수치) 읽어 줄 이름이다.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = RoutexMotion.effectiveDuration(
      disableAnimations: disableAnimations,
      role: RoutexMotionRole.transition,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: expanded,
          label: semanticsLabel,
          child: RoutexFocusRing(
            radius: RoutexRadii.control,
            child: Material(
              color: Colors.transparent,
              borderRadius: RoutexRadii.control,
              child: InkWell(
                onTap: () => onExpanded(!expanded),
                borderRadius: RoutexRadii.control,
                focusColor: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: RoutexMetrics.minimumTouchTarget,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        // 아이콘이 없어도 같은 폭을 비운다. 아래 본문 줄이 이
                        // 시작선에 맞춰 들여쓰기 때문에, 줄마다 폭이 달라지면
                        // 머리 줄과 본문의 왼쪽이 어긋난다.
                        width: RoutexMetrics.iconLarge,
                        child: leadingIcon == null
                            ? null
                            : Icon(
                                leadingIcon,
                                size: RoutexMetrics.iconMedium,
                                color: colors.contentSecondary,
                              ),
                      ),
                      const SizedBox(width: RoutexSpacing.contentGap),
                      Expanded(child: header),
                      const SizedBox(width: RoutexSpacing.controlGap),
                      AnimatedRotation(
                        turns: expanded
                            ? RoutexMotion.disclosureExpandedTurns
                            : 0,
                        duration: duration,
                        curve: RoutexMotion.standardCurve,
                        child: Icon(
                          RoutexIcons.expand,
                          size: RoutexMetrics.iconMedium,
                          color: colors.contentSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // 접혀 있고 미리 보여 줄 줄도 없으면 본문 자리를 만들지 않는다. 빈 상자에
        // 들여쓰기만 남으면 아래 섹션과의 간격이 다른 섹션보다 넓어져, 접힌 섹션만
        // 위계가 한 칸 내려간 것처럼 보인다.
        if (expanded || preview != null)
          Padding(
            // 본문은 머리 줄의 글자 시작선에 맞춘다. 아이콘 아래까지 내려오면 어느
            // 머리 줄에 딸린 내용인지가 흐려진다.
            padding: const EdgeInsetsDirectional.only(
              start: RoutexMetrics.iconLarge + RoutexSpacing.contentGap,
            ),
            child: AnimatedSize(
              duration: duration,
              curve: RoutexMotion.standardCurve,
              alignment: Alignment.topCenter,
              child: Column(
                key: ValueKey(expanded),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [?preview, if (expanded) child],
              ),
            ),
          ),
      ],
    );
  }
}

/// 잘린 목록 끝에서 나머지를 펼치는 줄이다.
///
/// **개수를 적는 것은 접혀 있을 때뿐이다.** 펼친 뒤의 "6개 접기"는 이미 화면에
/// 보이는 것을 다시 세는 말이라 읽는 사람이 확인할 이유가 없다.
///
/// 새 화면으로 넘기지 않고 그 자리에서 펼친다 — 목록을 더 보려던 사람이 돌아올
/// 자리를 잃지 않게 한다.
class RoutexShowMore extends StatelessWidget {
  const RoutexShowMore({
    required this.expanded,
    required this.onExpanded,
    this.hiddenCount,
    super.key,
  });

  final bool expanded;
  final ValueChanged<bool> onExpanded;

  /// 접혀서 지금 보이지 않는 항목 수다. 모르면 그냥 "더보기"가 된다.
  final int? hiddenCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final label = expanded
        ? '접기'
        : hiddenCount == null
        ? '더보기'
        : '$hiddenCount개 더보기';

    return Semantics(
      button: true,
      expanded: expanded,
      label: label,
      excludeSemantics: true,
      child: TextButton(
        onPressed: () => onExpanded(!expanded),
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(double.infinity, RoutexMetrics.minimumTouchTarget),
          ),
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: RoutexRadii.control),
          ),
          textStyle: const WidgetStatePropertyAll(RoutexTypography.label),
          foregroundColor: WidgetStatePropertyAll(colors.actionPrimary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Text(label, maxLines: 1)),
            AnimatedRotation(
              turns: expanded ? RoutexMotion.disclosureExpandedTurns : 0,
              duration: RoutexMotion.effectiveDuration(
                disableAnimations: disableAnimations,
                role: RoutexMotionRole.transition,
              ),
              curve: RoutexMotion.standardCurve,
              child: const Icon(
                RoutexIcons.expand,
                size: RoutexMetrics.iconMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
