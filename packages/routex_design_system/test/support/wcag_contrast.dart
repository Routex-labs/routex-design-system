import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// WCAG 2.x의 명도 대비를 계산한다.
///
/// 눈에 보이는 밝기는 sRGB 값에 비례하지 않는다. 그래서 채널마다 감마를 되돌린
/// 뒤(=선형 광량) 가중합해 상대 휘도를 구하고, 두 휘도의 비를 대비로 삼는다.
/// 결과는 1(같은 색)에서 21(검정과 흰색) 사이다.
double contrastRatio(Color foreground, Color background) {
  final a = _relativeLuminance(foreground);
  final b = _relativeLuminance(background);
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

double _relativeLuminance(Color color) {
  // 반투명 색은 뒤에 무엇이 깔리는지에 따라 대비가 달라진다. 알파를 무시하고
  // 재면 실제보다 후하게 나오므로, 합성된 불투명 색만 받는다.
  assert(color.a == 1, '반투명 색은 그대로 잴 수 없다. 배경과 합성한 불투명 색을 넘겨라.');
  return 0.2126 * _linearize(color.r) +
      0.7152 * _linearize(color.g) +
      0.0722 * _linearize(color.b);
}

double _linearize(double channel) {
  return channel <= 0.04045
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
}
