import 'package:flutter/animation.dart';

/// 제품 컴포넌트 전환이 맡는 역할이다.
enum RoutexMotionRole { feedback, transition, emphasized }

extension RoutexMotionRoleValue on RoutexMotionRole {
  Duration get duration => switch (this) {
    RoutexMotionRole.feedback => RoutexMotion.feedback,
    RoutexMotionRole.transition => RoutexMotion.transition,
    RoutexMotionRole.emphasized => RoutexMotion.emphasized,
  };
}

/// 제품 UI가 공유하는 duration과 easing이다.
///
/// 지도 camera·PDR·debounce·timeout과 Promo Studio의 카메라, 파티클,
/// 타임라인, 장면 연출에는 사용하지 않는다.
abstract final class RoutexMotion {
  static const feedback = Duration(milliseconds: 120);
  static const transition = Duration(milliseconds: 200);
  static const emphasized = Duration(milliseconds: 320);

  static const standardCurve = Curves.easeInOutCubic;
  static const enterCurve = Curves.easeOutCubic;
  static const exitCurve = Curves.easeInCubic;

  /// OS에서 애니메이션 축소를 요청하면 시간 기반 전환을 제거한다.
  static Duration effectiveDuration({
    required bool disableAnimations,
    required RoutexMotionRole role,
  }) {
    return disableAnimations ? Duration.zero : role.duration;
  }
}
