import 'package:flutter/material.dart';

import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';

/// 경로 안내의 한 단계다.
@immutable
class RoutexStep {
  const RoutexStep({
    required this.instruction,
    required this.icon,
    this.distance,
    this.detail,
  });

  /// `오른쪽 통로로 이동`처럼 다음에 할 행동이다.
  final String instruction;

  final IconData icon;

  /// 이 단계까지 남은 거리다. `92 m`처럼 서식까지 끝낸 값을 받는다.
  final String? distance;

  /// `3층 에스컬레이터 옆`처럼 위치를 짚어 주는 한 줄이다.
  final String? detail;
}

/// 경로 전체를 단계 목록으로 펼친다.
///
/// **안내 배너와 역할이 다르다.** `RoutexManeuverBanner`는 걷는 동안 **지금 할 하나**를
/// 크게 보여 주고, 이 목록은 출발 전이나 멈춰 섰을 때 **전체 흐름**을 확인하는 자리다.
/// 같은 데이터를 두 모양으로 그리는 것이 중복이 아닌 이유는 답하는 질문이 다르기
/// 때문이다.
///
/// **지금 단계를 표시한다**([currentIndex]). 목록을 열었을 때 어디까지 왔는지 표시가
/// 없으면 사용자가 화면 밖 지도와 목록을 번갈아 보며 스스로 맞춰야 한다.
class RoutexStepList extends StatelessWidget {
  const RoutexStepList({required this.steps, this.currentIndex, super.key});

  final List<RoutexStep> steps;

  /// 지금 수행 중인 단계다. null이면 아직 출발하지 않았다는 뜻이다.
  final int? currentIndex;

  @override
  Widget build(BuildContext context) {
    assert(steps.isNotEmpty, '단계가 없으면 목록을 그리지 않는다');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < steps.length; index++)
          _StepRow(
            step: steps[index],
            current: index == currentIndex,
            // 지나온 단계는 무게를 낮춘다. 전부 같은 무게면 목록에서 현재 위치를
            // 찾는 데 시간이 걸린다.
            passed: currentIndex != null && index < currentIndex!,
            last: index == steps.length - 1,
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.current,
    required this.passed,
    required this.last,
  });

  final RoutexStep step;
  final bool current;
  final bool passed;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final foreground = passed ? colors.contentSecondary : colors.contentPrimary;

    return Semantics(
      container: true,
      selected: current,
      label: [step.instruction, ?step.distance, ?step.detail].join(', '),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: current ? colors.actionPrimarySubtle : Colors.transparent,
          borderRadius: RoutexRadii.field,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: RoutexSpacing.contentGap,
            vertical: RoutexSpacing.controlGap,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: RoutexMetrics.leadingColumn,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      step.icon,
                      size: RoutexMetrics.iconMedium,
                      color: current
                          ? colors.actionPrimary
                          : passed
                          ? colors.contentDisabled
                          : colors.contentSecondary,
                    ),
                    // 단계 사이를 선으로 잇는다. 아이콘만 세우면 순서가 아니라
                    // 서로 무관한 항목의 나열로 읽힌다.
                    if (!last)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: RoutexSpacing.inlineGap,
                        ),
                        child: SizedBox(
                          width: RoutexStroke.hairline,
                          height: RoutexSpacing.componentPadding,
                          child: ColoredBox(color: colors.borderSubtle),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: RoutexSpacing.contentGap),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.instruction,
                      style: RoutexTypography.bodyStrong.copyWith(
                        color: foreground,
                      ),
                    ),
                    if (step.detail?.trim().isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: RoutexSpacing.inlineGap,
                        ),
                        child: Text(
                          step.detail!,
                          style: RoutexTypography.bodySmall.copyWith(
                            color: colors.contentSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (step.distance case final distance?) ...[
                const SizedBox(width: RoutexSpacing.controlGap),
                Text(
                  distance,
                  style: RoutexTypography.tabular(RoutexTypography.label)
                      .copyWith(
                        color: current ? colors.actionPrimary : foreground,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
