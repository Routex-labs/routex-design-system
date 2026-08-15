import 'package:flutter/material.dart';

import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';
import '../components/routex_bottom_sheet.dart';
import '../components/routex_button.dart';

class RoutexTripMetric {
  const RoutexTripMetric({required this.value, required this.label});

  final String value;
  final String label;
}

/// 안내 중 남은 시간·거리와 종료 동작의 순서와 위계를 고정한다.
class RoutexTripProgress extends StatelessWidget {
  const RoutexTripProgress({
    required this.metrics,
    required this.onStop,
    super.key,
  }) : assert(metrics.length > 0 && metrics.length <= 3);

  final List<RoutexTripMetric> metrics;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    // 큰 글자에서는 수치와 종료 버튼이 한 줄에 들어가지 않는다. 이때 수치를
    // 줄이거나 버튼을 아이콘으로 바꾸지 않고 줄을 나눈다.
    final stacked = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final values = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final metric in metrics)
          Expanded(child: _TripValue(metric: metric)),
      ],
    );
    final stop = RoutexButton(
      label: '안내 종료',
      variant: RoutexButtonVariant.secondary,
      onPressed: onStop,
    );

    return RoutexBottomSheet(
      showHandle: false,
      child: stacked
          ? RoutexStack(gap: RoutexStackGap.content, children: [values, stop])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: values),
                const SizedBox(width: RoutexSpacing.contentGap),
                stop,
              ],
            ),
    );
  }
}

class _TripValue extends StatelessWidget {
  const _TripValue({required this.metric});

  final RoutexTripMetric metric;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return RoutexStack(
      gap: RoutexStackGap.inline,
      children: [
        Text(
          metric.value,
          style: RoutexTypography.tabular(RoutexTypography.label),
        ),
        Text(
          metric.label,
          style: RoutexTypography.caption.copyWith(
            color: colors.contentSecondary,
          ),
        ),
      ],
    );
  }
}
