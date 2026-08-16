import 'package:flutter/material.dart';

import '../foundations/routex_metrics.dart';
import '../theme/routex_color_tokens.dart';

/// 키보드 focus를 표면 위에 링으로 그린다.
///
/// focus를 배경 채움으로 표현하면 selected·hover·pressed와 같은 언어를 써서
/// "지금 골라진 것"과 "지금 키보드가 가리키는 것"이 구분되지 않는다. 그래서
/// 채움은 selected·hover·pressed가 나눠 쓰고, focus는 `focusRing` 색의 링만
/// 그린다.
///
/// 링은 표면 밖에 그려지므로 표면 크기를 바꾸지 않는다. 자식의 곡률을 그대로
/// 받아 같은 모양으로 두른다.
class RoutexFocusRing extends StatefulWidget {
  const RoutexFocusRing({
    required this.radius,
    required this.child,
    this.enabled = true,
    super.key,
  });

  final BorderRadius radius;
  final Widget child;

  /// 누를 수 없는 표면에는 링을 그리지 않는다.
  final bool enabled;

  static const width = RoutexStroke.emphasis;

  @override
  State<RoutexFocusRing> createState() => _RoutexFocusRingState();
}

class _RoutexFocusRingState extends State<RoutexFocusRing> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      descendantsAreFocusable: true,
      onFocusChange: (focused) {
        if (!widget.enabled || _focused == focused) return;
        setState(() => _focused = focused);
      },
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: widget.radius,
          border: _focused && widget.enabled
              ? Border.all(
                  color: colors.focusRing,
                  width: RoutexFocusRing.width,
                )
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}
