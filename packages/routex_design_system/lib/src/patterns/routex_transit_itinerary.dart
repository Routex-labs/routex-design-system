import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../components/routex_badge.dart';
import '../components/routex_focus_ring.dart';
import '../theme/routex_color_tokens.dart';

/// 대중교통 경로의 한 구간이다.
@immutable
class RoutexTransitLeg {
  const RoutexTransitLeg({
    required this.label,
    required this.icon,
    this.accent,
  });

  /// `5호선`, `간선 472`처럼 그 구간을 부르는 이름이다.
  ///
  /// 도보 구간은 노선 이름이 없으므로 소요 시간(`도보 5분`)을 적는다 — "도보"만
  /// 적으면 몇 분을 걷는지가 목록에서 사라진다.
  final String label;

  final IconData icon;

  /// 노선색이다. 운영사가 정한 값이라 소비 앱이 넘긴다. 없으면(도보) 무채색이다.
  ///
  /// 색과 그 위 글자를 짝으로 받는다. 노선색만 받아 글자를 흰색으로 고정하면
  /// 밝은 노선(예: 노랑)에서 라벨이 사라진다.
  final RoutexBadgeAccent? accent;
}

/// 구간을 순서대로 잇는 줄이다.
///
/// **도보 구간까지 그린다.** 요약 숫자만으로는 "지하철역까지 12분 걷는다"가 보이지
/// 않는다. 갈아타는 횟수보다 걷는 시간 때문에 경로를 바꾸는 사람이 많다.
///
/// 구간이 많으면 줄바꿈한다. 가로 스크롤로 두면 지도 위 시트에서 스크롤 방향이
/// 겹쳐(세로 시트 드래그 vs 가로 스트립) 둘 다 잘 듣지 않는다.
class RoutexTransitLegStrip extends StatelessWidget {
  const RoutexTransitLegStrip({required this.legs, super.key});

  final List<RoutexTransitLeg> legs;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return Semantics(
      container: true,
      label: legs.map((leg) => leg.label).join(', 다음 '),
      excludeSemantics: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: RoutexSpacing.inlineGap,
        children: [
          for (var index = 0; index < legs.length; index++) ...[
            if (index > 0)
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: RoutexSpacing.inlineGap,
                ),
                child: Icon(
                  RoutexIcons.forward,
                  size: RoutexMetrics.iconSmall,
                  color: colors.contentSecondary,
                ),
              ),
            RoutexBadge(
              label: legs[index].label,
              icon: legs[index].icon,
              accent: legs[index].accent,
            ),
          ],
        ],
      ),
    );
  }
}

/// 대중교통 경로 후보 한 줄이다.
///
/// **소요 시간만 크게 적지 않는다.** 환승 횟수·도보 시간·요금을 함께 적는 이유는
/// 가장 빠른 경로가 늘 최선은 아니기 때문이다. 3분 빠른 대신 두 번 갈아타는 경로와
/// 조금 느려도 한 번에 가는 경로 중 무엇을 고를지는 사용자만 안다.
///
/// **첫 줄이 왜 첫 줄인지 밝힌다**([fastest]). 정렬 기준을 화면에 적지 않으면
/// 사용자가 순서의 뜻을 추측해야 한다.
class RoutexTransitItinerary extends StatelessWidget {
  const RoutexTransitItinerary({
    required this.duration,
    required this.facts,
    required this.legs,
    required this.onPressed,
    this.fastest = false,
    this.selected = false,
    super.key,
  });

  /// `35분`처럼 서식까지 끝낸 총 소요다.
  final String duration;

  /// `환승 1회`, `도보 8분`, `1,500원`처럼 판단에 쓰는 값들이다. 가운뎃점으로 잇는다.
  final List<String> facts;

  final List<RoutexTransitLeg> legs;

  /// 목록에서 가장 빠른 경로인지.
  final bool fastest;

  /// 지금 지도에 그려져 있는 경로인지. 목록으로 되돌아왔을 때 방금 보던 줄이
  /// 어느 것인지 알 수 있어야 한다.
  final bool selected;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return Semantics(
      button: true,
      selected: selected,
      focusable: true,
      label: '$duration, ${facts.join(', ')}',
      onTap: onPressed,
      excludeSemantics: true,
      child: RoutexFocusRing(
        radius: RoutexRadii.field,
        child: Material(
          color: selected ? colors.actionPrimarySubtle : Colors.transparent,
          borderRadius: RoutexRadii.field,
          child: InkWell(
            onTap: onPressed,
            borderRadius: RoutexRadii.field,
            focusColor: Colors.transparent,
            hoverColor: colors.actionPrimarySubtle,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: RoutexSpacing.contentGap,
                vertical: RoutexSpacing.contentGap,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 소요와 배지는 한 줄에 나란히 서지만, 큰 글자에서는 배지가
                      // 아랫줄로 내려간다. 배지를 줄이거나 소요를 말줄임하면 이
                      // 줄에서 읽어야 할 두 값 중 하나가 사라진다.
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: RoutexSpacing.controlGap,
                          runSpacing: RoutexSpacing.inlineGap,
                          children: [
                            Text(
                              duration,
                              style: RoutexTypography.tabular(
                                RoutexTypography.title,
                              ),
                            ),
                            if (fastest)
                              const RoutexBadge(
                                label: '최단 시간',
                                tone: RoutexBadgeTone.info,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: RoutexSpacing.controlGap),
                      Icon(
                        RoutexIcons.forward,
                        size: RoutexMetrics.iconMedium,
                        color: colors.contentSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: RoutexSpacing.inlineGap),
                  Text(
                    facts.join(' · '),
                    style: RoutexTypography.bodySmall.copyWith(
                      color: colors.contentSecondary,
                    ),
                  ),
                  const SizedBox(height: RoutexSpacing.controlGap),
                  RoutexTransitLegStrip(legs: legs),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
