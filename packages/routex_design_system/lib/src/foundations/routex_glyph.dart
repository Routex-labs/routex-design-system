import 'package:flutter/widgets.dart';

/// 소비 앱의 자산으로 글리프를 그린다.
///
/// **이 패키지는 자산을 갖지 않는다.** 그래서 경로가 아니라 그리는 함수를 받는다 —
/// `RoutexMediaItem`이 경로 대신 `ImageProvider`를 받는 것과 같은 이유다. SVG는
/// `ImageProvider`가 아니라서 그쪽 문법으로는 표현되지 않는다.
///
/// [color]와 [size]는 컴포넌트가 상태에서 정해 넘긴 값이며, 구현은 **이 둘만 써야
/// 한다.** 앱이 색을 따로 고르면 활성·비활성 판정이 두 벌이 되고, 한쪽만 바뀌는 날
/// 화면에서 상태가 어긋난다.
typedef RoutexGlyphBuilder =
    Widget Function(BuildContext context, Color color, double size);
