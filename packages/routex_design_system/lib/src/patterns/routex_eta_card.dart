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
/// **첫 번째 경로 metric이 가장 큰 글자다.** 안내를 시작할지 판단할 때는 도착 시각보다
/// `22분 소요`처럼 지금부터 필요한 시간이 먼저 읽혀야 한다. 도착 예정 시각은 그 시간의
/// 결과이므로 아래 보조 줄로 내린다. 소비 앱은 [metrics]의 첫 항목에 총 소요를 준다.
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
  ///
  /// 첫 항목은 계획을 시작할지 고르는 주 정보다. 보통 `22분 소요`를 주고, 나머지는
  /// 도착 시각과 같은 보조 줄에 둔다.
  final List<RoutexTripMetric> metrics;

  /// 안내를 시작한다. **null이면 버튼 자체를 그리지 않는다** — 시작이라는 동작이
  /// 없는 경로(건물 입구까지 자동으로 그려진 경로)에서 눌리지 않는 버튼만 남기면,
  /// 사용자는 그것이 왜 안 되는지 알 수 없다. `RoutexPlaceHeader.onSaved`와 같은
  /// 규칙이다.
  final VoidCallback? onStart;

  /// 복수 경로를 고를 수 있을 때 도착 요약 위에 놓는 선택 영역이다.
  /// `RoutexRouteOption` 묶음을 넘기며, 단일 경로라면 생략한다.
  final Widget? routeOptions;

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final primaryMetric = metrics.first;
    final secondaryMetrics = metrics.skip(1).toList(growable: false);

    return RoutexBottomSheet(
      showHandle: false,
      includeBottomSafeArea: true,
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
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: primaryMetric.value,
                            style: RoutexTypography.tabular(
                              RoutexTypography.headline,
                            ),
                          ),
                          TextSpan(
                            text: ' ${primaryMetric.label}',
                            style: RoutexTypography.body.copyWith(
                              color: colors.contentSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Semantics(
                      label: [
                        '$title $arrivalTime',
                        for (final metric in secondaryMetrics)
                          '${metric.value} ${metric.label}',
                      ].join(', '),
                      excludeSemantics: true,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '$title $arrivalTime',
                              style: RoutexTypography.bodySmall.copyWith(
                                color: colors.contentSecondary,
                              ),
                            ),
                            for (final metric in secondaryMetrics) ...[
                              TextSpan(
                                text: ' · ',
                                style: RoutexTypography.bodySmall.copyWith(
                                  color: colors.contentSecondary,
                                ),
                              ),
                              TextSpan(
                                text: metric.value,
                                style: RoutexTypography.tabular(
                                  RoutexTypography.bodySmall,
                                ),
                              ),
                              TextSpan(
                                text: ' ${metric.label}',
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
              ),
              // 시작이 이 표면의 유일한 주 행동이다. 계획 취소는 상단 길찾기
              // 입력의 닫기가 맡아 같은 역할을 두 곳에 만들지 않는다.
              if (onStart case final onStart?) ...[
                const SizedBox(width: RoutexSpacing.contentGap),
                RoutexButton(label: '안내 시작', onPressed: onStart),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
