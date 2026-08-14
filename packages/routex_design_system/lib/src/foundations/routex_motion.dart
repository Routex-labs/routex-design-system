import 'package:flutter/animation.dart';

/// 제품 UI가 공유하는 duration과 easing이다.
///
/// Promo Studio의 카메라, 파티클, 타임라인과 장면 연출에는 사용하지 않는다.
abstract final class RoutexMotion {
  static const fast = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 320);

  static const enterCurve = Curves.easeOutCubic;
  static const exitCurve = Curves.easeInCubic;

  /// OS에서 애니메이션 축소를 요청하면 시간 기반 전환을 제거한다.
  static Duration duration({
    required bool disableAnimations,
    required Duration standard,
  }) {
    return disableAnimations ? Duration.zero : standard;
  }
}
