import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

/// 같은 역할에서 고정폭 숫자만 켰을 때 숫자 열이 어떻게 달라지는지 비교한다.
class TabularCatalog extends StatelessWidget {
  const TabularCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    return RoutexCluster(
      gap: RoutexClusterGap.content,
      children: [
        _TabularSample(label: '기본', style: RoutexTypography.title),
        _TabularSample(
          label: 'tabular 적용',
          style: RoutexTypography.tabular(RoutexTypography.title),
        ),
      ],
    );
  }
}

class _TabularSample extends StatelessWidget {
  const _TabularSample({required this.label, required this.style});

  /// 자리수가 다른 값을 겹쳐 보여 폭이 흔들리는 정도를 비교한다.
  static const _steps = ['1,240m · 14분', '980m · 9분', '110m · 1분'];

  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return SizedBox(
      width: 176,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceCanvas,
          borderRadius: RoutexRadii.control,
        ),
        child: Padding(
          padding: const EdgeInsets.all(RoutexSpacing.contentGap),
          child: RoutexStack(
            gap: RoutexStackGap.inline,
            children: [
              Text(
                label,
                style: RoutexTypography.label.copyWith(
                  color: colors.contentSecondary,
                ),
              ),
              for (final step in _steps) Text(step, style: style),
            ],
          ),
        ),
      ),
    );
  }
}
