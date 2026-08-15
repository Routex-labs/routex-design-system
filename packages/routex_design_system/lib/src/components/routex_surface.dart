import 'package:flutter/material.dart';

import '../foundations/routex_layer.dart';
import '../foundations/routex_radii.dart';
import '../theme/routex_color_tokens.dart';

/// 표면이 화면에서 맡는 역할이다.
///
/// 색·곡률·경계·깊이를 각자 조합하지 않고 이 네 역할 중 하나를 고른다. 같은
/// 깊이를 어떤 화면은 그림자로, 어떤 화면은 테두리로 표현하면 지도 위 겹침
/// 순서가 화면마다 달라진다.
enum RoutexSurfaceRole {
  /// 목록·시트 안의 평평한 묶음. 그림자 없이 배경색으로만 구분한다.
  flat,

  /// 같은 평면에서 경계로만 구분하는 카드.
  outlined,

  /// 지도 위에 떠 있는 조작 표면(검색 줄, 지도 버튼, 칩).
  onMap,

  /// 지도 위 주 표면(경로 입력, 안내 배너처럼 화면을 대표하는 덩어리).
  chrome,
}

/// 표면의 색, 곡률, 경계와 깊이를 역할 하나로 고정한다.
///
/// 내부 여백은 소유하지 않는다. 여백은 `RoutexInset`이, 자식 사이 간격은
/// `RoutexStack`이 맡는다.
class RoutexSurface extends StatelessWidget {
  const RoutexSurface({
    required this.role,
    required this.child,
    this.radius = RoutexRadii.card,
    this.clip = true,
    super.key,
  });

  final RoutexSurfaceRole role;
  final Widget child;

  /// 곡률만 역할별로 다시 고를 수 있다. 값이 아니라 `RoutexRadii`의 역할을 넘긴다.
  final BorderRadius radius;

  final bool clip;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    // Material은 shape와 borderRadius를 동시에 받지 않는다. outlined는 경계선을
    // 그려야 하므로 shape 하나로 곡률까지 표현한다.
    final outlined = role == RoutexSurfaceRole.outlined;

    return Material(
      color: switch (role) {
        RoutexSurfaceRole.flat => colors.surfaceCanvas,
        RoutexSurfaceRole.outlined ||
        RoutexSurfaceRole.onMap ||
        RoutexSurfaceRole.chrome => colors.surfaceRaised,
      },
      borderRadius: outlined ? null : radius,
      elevation: switch (role) {
        RoutexSurfaceRole.flat || RoutexSurfaceRole.outlined => 0,
        RoutexSurfaceRole.onMap => RoutexLayer.onMap,
        RoutexSurfaceRole.chrome => RoutexLayer.chrome,
      },
      shadowColor: colors.shadow,
      shape: outlined
          ? RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: colors.borderSubtle),
            )
          : null,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      child: child,
    );
  }
}
