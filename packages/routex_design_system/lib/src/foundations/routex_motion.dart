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

  /// disclosure 화살표가 접힘에서 펼침으로 바뀌는 회전량이다.
  static const disclosureExpandedTurns = 0.5;

  /// OS에서 애니메이션 축소를 요청하면 시간 기반 전환을 제거한다.
  static Duration effectiveDuration({
    required bool disableAnimations,
    required RoutexMotionRole role,
  }) {
    return disableAnimations ? Duration.zero : role.duration;
  }
}

/// 애니메이션이 아니라 사용자가 결과 문장을 읽을 수 있게 유지하는 시간이다.
///
/// motion duration과 분리해 전환 속도를 조정해도 피드백 노출 시간이 흔들리지 않게 한다.
abstract final class RoutexFeedbackTiming {
  static const toastVisibility = Duration(milliseconds: 1600);

  /// 되돌리기가 붙은 알림이 떠 있는 시간이다.
  ///
  /// 토스트보다 긴 이유는 문장이 길어서가 아니라 **읽고 나서 손이 닿아야** 하기
  /// 때문이다. 읽는 시간만 재면 누르려던 사람의 손이 도착하기 전에 사라진다.
  ///
  /// 그래도 사라지기는 한다. 이 알림의 되돌리기는 화면에 남아 있는 토글의 지름길일
  /// 뿐 유일한 경로가 아니므로, 놓쳐도 되돌릴 방법이 사라지지 않는다. 되돌릴 길이
  /// 여기뿐인 동작이라면 시간으로 지우지 말고 확인을 받는다(`RoutexDialog`).
  static const noticeVisibility = Duration(seconds: 4);
}
