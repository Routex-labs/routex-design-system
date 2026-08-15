import 'package:flutter/widgets.dart';

import '../foundations/routex_spacing.dart';

/// 세로로 쌓이는 콘텐츠 사이의 관계를 표현한다.
enum RoutexStackGap { inline, control, content, section }

/// 쌓인 것이 가로 폭을 어떻게 쓰는지다.
enum RoutexStackFill {
  /// 폭을 가득 채운다. 목록 행, 본문, 시트 안 내용처럼 가로로 꽉 차는 것들이다.
  full,

  /// 제 폭만 차지하고 시작선에 붙는다. 지도 조작 버튼이나 층 전환기처럼 세로로
  /// 쌓이는 컨트롤 줄이 여기 해당한다. 이런 것들이 폭까지 늘어나면 실제 화면에서
  /// 지도를 가리는 넓이와 달라져, 카탈로그에서 본 크기가 기기에서 달라진다.
  content,
}

class RoutexStack extends StatelessWidget {
  const RoutexStack({
    required this.gap,
    required this.children,
    this.fill = RoutexStackFill.full,
    super.key,
  });

  final RoutexStackGap gap;
  final List<Widget> children;
  final RoutexStackFill fill;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: switch (fill) {
        RoutexStackFill.full => CrossAxisAlignment.stretch,
        RoutexStackFill.content => CrossAxisAlignment.start,
      },
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
