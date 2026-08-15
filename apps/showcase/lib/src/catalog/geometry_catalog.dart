import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

/// 간격·크기·곡률 역할을 눈에 보이는 길이로 보여준다.
///
/// 숫자만 나열하면 4와 8의 차이가 읽히지 않는다. 각 역할을 실제 길이의 막대와
/// 실제 곡률의 도형으로 그려서 역할 사이의 간격이 보이게 한다.
class GeometryCatalog extends StatelessWidget {
  const GeometryCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    return RoutexStack(
      gap: RoutexStackGap.section,
      children: [
        _Group(
          label: '간격',
          child: RoutexStack(
            gap: RoutexStackGap.control,
            children: [
              for (final role in RoutexSpacingRole.values)
                _LengthRow(name: role.name, value: role.value),
            ],
          ),
        ),
        _Group(
          label: '크기',
          child: RoutexStack(
            gap: RoutexStackGap.control,
            children: [
              for (final role in RoutexMetricRole.values)
                _LengthRow(name: role.name, value: role.value),
            ],
          ),
        ),
        _Group(
          label: '곡률',
          child: RoutexCluster(
            gap: RoutexClusterGap.content,
            children: [
              for (final role in RoutexRadiusRole.values)
                _RadiusSample(role: role),
            ],
          ),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RoutexStack(
      gap: RoutexStackGap.control,
      children: [
        RoutexSectionHeader(
          title: label,
          level: RoutexSectionHeaderLevel.group,
        ),
        child,
      ],
    );
  }
}

/// 역할 이름·실제 길이 막대·수치를 한 줄에 둔다.
class _LengthRow extends StatelessWidget {
  const _LengthRow({required this.name, required this.value});

  final String name;
  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 148,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RoutexTypography.bodySmall,
          ),
        ),
        const SizedBox(width: RoutexSpacing.contentGap),
        // 막대는 실제 길이로 그리되 남은 폭까지만 그린다. 사진 띠처럼 200을 넘는
        // 역할은 360px 화면에서 이름 열과 수치를 밀어내며 넘친다. 값의 진실은
        // 오른쪽 수치가 들고 있으므로, 넘치는 대신 잘린 막대를 보여 준다.
        Flexible(
          child: Container(
            width: value,
            height: RoutexSpacing.contentGap,
            decoration: BoxDecoration(
              color: colors.actionPrimary,
              borderRadius: RoutexRadii.control,
            ),
          ),
        ),
        const SizedBox(width: RoutexSpacing.controlGap),
        Text(
          '${value.toInt()}',
          style: RoutexTypography.tabular(
            RoutexTypography.label,
          ).copyWith(color: colors.contentSecondary),
        ),
      ],
    );
  }
}

/// 같은 크기의 표면에 역할별 곡률만 다르게 적용해 비교한다.
class _RadiusSample extends StatelessWidget {
  const _RadiusSample({required this.role});

  final RoutexRadiusRole role;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return RoutexStack(
      gap: RoutexStackGap.inline,
      children: [
        Container(
          width: 96,
          height: 64,
          decoration: BoxDecoration(
            color: colors.actionPrimarySubtle,
            borderRadius: role.borderRadius,
            border: Border.all(color: colors.actionPrimary),
          ),
        ),
        Text(
          role.name,
          textAlign: TextAlign.center,
          style: RoutexTypography.label.copyWith(
            color: colors.contentSecondary,
          ),
        ),
      ],
    );
  }
}
