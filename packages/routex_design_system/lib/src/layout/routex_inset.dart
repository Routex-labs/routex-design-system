import 'package:flutter/widgets.dart';

import '../foundations/routex_spacing.dart';

/// 콘텐츠가 놓이는 영역의 의미에 따라 내부 여백을 적용한다.
enum RoutexInsetRole { screen, component }

class RoutexInset extends StatelessWidget {
  const RoutexInset({required this.role, required this.child, super.key});

  final RoutexInsetRole role;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: _padding, child: child);
  }

  EdgeInsetsGeometry get _padding => switch (role) {
    RoutexInsetRole.screen => const EdgeInsetsDirectional.fromSTEB(
      RoutexSpacing.screenGutter,
      RoutexSpacing.sectionGap,
      RoutexSpacing.screenGutter,
      RoutexSpacing.sectionGap,
    ),
    RoutexInsetRole.component => const EdgeInsetsDirectional.all(
      RoutexSpacing.componentPadding,
    ),
  };
}
