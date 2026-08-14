import 'package:flutter/widgets.dart';

import '../theme/routex_color_tokens.dart';

/// 지도 위 제품 UI의 깊이 역할이다.
enum RoutexLayerRole { onMap, chrome, overlay }

extension RoutexLayerRoleValue on RoutexLayerRole {
  double get elevation => switch (this) {
    RoutexLayerRole.onMap => RoutexLayer.onMap,
    RoutexLayerRole.chrome => RoutexLayer.chrome,
    RoutexLayerRole.overlay => RoutexLayer.overlay,
  };
}

/// z-order와 그림자를 같은 세 역할로 제한한다.
abstract final class RoutexLayer {
  static const onMap = 1.0;
  static const chrome = 3.0;
  static const overlay = 8.0;

  static List<BoxShadow> shadow(
    RoutexLayerRole role,
    RoutexColorTokens colors,
  ) => switch (role) {
    RoutexLayerRole.onMap => [
      BoxShadow(
        color: colors.shadow,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
    RoutexLayerRole.chrome => [
      BoxShadow(
        color: colors.shadow,
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
    RoutexLayerRole.overlay => [
      BoxShadow(
        color: colors.shadowStrong,
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  };
}
