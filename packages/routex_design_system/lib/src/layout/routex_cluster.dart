import 'package:flutter/widgets.dart';

import '../foundations/routex_spacing.dart';

/// 같은 계층의 컨트롤을 가로로 배치하고 좁은 폭에서 줄바꿈한다.
enum RoutexClusterGap { control, content }

class RoutexCluster extends StatelessWidget {
  const RoutexCluster({required this.gap, required this.children, super.key});

  final RoutexClusterGap gap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: _gapValue, runSpacing: _gapValue, children: children);
  }

  double get _gapValue => switch (gap) {
    RoutexClusterGap.control => RoutexSpacing.controlGap,
    RoutexClusterGap.content => RoutexSpacing.contentGap,
  };
}
