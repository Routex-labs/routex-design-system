import 'package:flutter/widgets.dart';

import '../foundations/routex_spacing.dart';

/// 세로로 쌓이는 콘텐츠 사이의 관계를 표현한다.
enum RoutexStackGap { inline, control, content, section }

class RoutexStack extends StatelessWidget {
  const RoutexStack({required this.gap, required this.children, super.key});

  final RoutexStackGap gap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _separatedChildren,
    );
  }

  List<Widget> get _separatedChildren {
    if (children.length < 2) return children;

    return [
      for (var index = 0; index < children.length; index++) ...[
        if (index > 0) SizedBox(height: _gapValue),
        children[index],
      ],
    ];
  }

  double get _gapValue => switch (gap) {
    RoutexStackGap.inline => RoutexSpacing.inlineGap,
    RoutexStackGap.control => RoutexSpacing.controlGap,
    RoutexStackGap.content => RoutexSpacing.contentGap,
    RoutexStackGap.section => RoutexSpacing.sectionGap,
  };
}
