import 'package:flutter/material.dart';

import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../components/routex_bottom_sheet.dart';
import '../components/routex_button.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';
import 'routex_trip_progress.dart';

/// 안내를 시작하기 전, 지금 그려진 경로가 무엇인지 요약한다.
///
/// **`RoutexTripProgress`와 나누는 기준은 "출발했는가"다.** 두 표면이 답하는 질문이
/// 다르다 — 계획 화면은 "어디로 어떻게 가는가"라 경로 전체와 도착 시각이 필요하고,
/// 안내 화면은 "지금 어디서 뭘 하는가"라 남은 값과 종료만 있으면 된다. 경로를
/// 그리자마자 위치로 확대해 버리면 사용자는 전체 경로를 한 번도 못 보고 안내에
/// 들어간다.
///
/// **도착 시각이 가장 큰 글자다.** 소요 시간(`22분`)은 언제 나가야 하는지를 스스로
/// 계산하게 만들지만 도착 시각(`오후 3:24`)은 약속과 바로 견줄 수 있다. 소요와 거리는
/// 그 아래 수치 줄로 내린다.
class RoutexEtaCard extends StatelessWidget {
  const RoutexEtaCard({
    required this.arrivalTime,
    required this.metrics,
    required this.onStart,
    this.routeOptions,
    this.title = '도착 예정',
    super.key,
  }) : assert(metrics.length > 0 && metrics.length <= 3);

  /// `오후 3:24`처럼 서식까지 끝낸 도착 시각이다. 시간 표기는 지역을 따라가는
  /// 값이라 소비 앱이 만든다.
  final String arrivalTime;

  /// 소요·거리·환승처럼 판단에 쓰는 값들이다.
  final List<RoutexTripMetric> metrics;

  final VoidCallback? onStart;

  /// 복수 경로를 고를 수 있을 때 도착 요약 위에 놓는 선택 영역이다.
  /// `RoutexRouteOption` 묶음을 넘기며, 단일 경로라면 생략한다.
  final Widget? routeOptions;

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return RoutexBottomSheet(
      showHandle: false,
      child: RoutexStack(
        gap: RoutexStackGap.content,
        children: [
          ?routeOptions,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: RoutexStack(
                  gap: RoutexStackGap.inline,
                  children: [
                    Text(
                      title,
                      style: RoutexTypography.caption.copyWith(
                        color: colors.contentSecondary,
                      ),
                    ),
                    Text(
                      arrivalTime,
                      style: RoutexTypography.tabular(
                        RoutexTypography.headline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RoutexSpacing.contentGap),
              // 시작이 이 표면의 유일한 주 행동이다. 계획 취소는 상단 길찾기
              // 입력의 닫기가 맡아 같은 역할을 두 곳에 만들지 않는다.
              RoutexButton(label: '안내 시작', onPressed: onStart),
            ],
          ),
          Semantics(
            container: true,
            label: [
              for (final metric in metrics) '${metric.value} ${metric.label}',
            ].join(', '),
            excludeSemantics: true,
            child: Text.rich(
              TextSpan(
                children: [
                  for (var index = 0; index < metrics.length; index++) ...[
                    if (index > 0)
                      TextSpan(
                        text: ' · ',
                        style: RoutexTypography.bodySmall.copyWith(
                          color: colors.contentSecondary,
                        ),
                      ),
                    TextSpan(
                      text: metrics[index].value,
                      style: RoutexTypography.tabular(RoutexTypography.label),
                    ),
                    TextSpan(
                      text: ' ${metrics[index].label}',
                      style: RoutexTypography.bodySmall.copyWith(
                        color: colors.contentSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
