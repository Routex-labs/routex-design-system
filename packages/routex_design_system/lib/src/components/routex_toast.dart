import 'dart:async';

import 'package:flutter/material.dart';

import '../foundations/routex_motion.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';

/// 되돌릴 것이 없는 결과를 화면 위에 잠깐 띄운다.
///
/// **`ScaffoldMessenger`의 SnackBar를 쓰지 않는다.** 제품의 상세 시트는 `Navigator`에
/// 얹힌 모달 라우트라 화면 아래를 덮는데, SnackBar를 그리는 `Scaffold`는 그 **아래**에
/// 있다. 시트 안에서 띄운 SnackBar는 시트에 가려 보이지 않으므로, 눌렀는데 아무 일도
/// 일어나지 않은 것과 구분되지 않는다. 여기서는 루트 `Overlay` 맨 위에 끼워 시트보다
/// 앞에 그린다.
///
/// **되돌리기가 붙는 알림은 이것이 아니다.** 동작 버튼이 필요하면 `RoutexInlineNotice`를
/// 쓴다. 토스트는 포인터를 통과시키므로([IgnorePointer]) 누를 것을 담을 수 없고,
/// 담아서도 안 된다 — 1.6초 뒤 사라지는 표면에 유일한 되돌리기를 두면 놓친 사람에게는
/// 그 동작이 없는 것과 같다.
///
/// **화면에 한 개만 둔다.** 엔트리와 타이머를 클래스 수준에서 들고 있다가 새 토스트가
/// 뜨는 순간 이전 것을 걷어낸다. 해제를 취소 불가능한 지연 호출에 맡기면 연속 호출이
/// 엔트리를 겹겹이 쌓고, 그중 하나는 오버레이에 영원히 남는다.
abstract final class RoutexToast {
  /// 읽고 사라지기까지의 시간이다.
  ///
  /// `RoutexMotion`의 duration은 전환에 쓰는 값이라 여기 쓰지 않는다. 이 값은
  /// 애니메이션 길이가 아니라 **한 문장을 읽는 데 걸리는 시간**이고, 둘을 같은
  /// 상수로 묶으면 전환을 조정할 때 읽는 시간이 함께 흔들린다.
  static const visibleDuration = RoutexFeedbackTiming.toastVisibility;

  static OverlayEntry? _entry;
  static Timer? _timer;

  /// 지금 떠 있는 토스트가 있는지. 테스트와 진단용이다.
  static bool get isVisible => _entry != null;

  static void show(BuildContext context, String message) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    // 애니메이션 축소 설정은 부르는 쪽의 MediaQuery에서 읽는다. 오버레이 엔트리는
    // 루트에 얹히므로 이 값을 스스로 알지 못한다.
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    dismiss();

    final entry = OverlayEntry(
      builder: (context) => _RoutexToastLayer(
        message: message,
        disableAnimations: disableAnimations,
      ),
    );

    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(visibleDuration, dismiss);
  }

  /// 떠 있는 토스트를 걷어낸다.
  ///
  /// 화면이 사라질 때 부른다. 실패 경로가 없다 — 여기 들어오는 엔트리는 전부
  /// [show]가 insert한 것이고, [OverlayEntry.remove]는 Overlay가 이미 해제된
  /// 뒤에도 안전하다. 참조를 먼저 비우므로 같은 엔트리를 두 번 지울 일도 없다.
  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    final entry = _entry;
    _entry = null;
    entry?.remove();
  }
}

class _RoutexToastLayer extends StatelessWidget {
  const _RoutexToastLayer({
    required this.message,
    required this.disableAnimations,
  });

  final String message;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      // 좌우는 화면 여백보다 넉넉히 띄운다. 토스트는 폭을 채우는 표면이 아니라
      // 글자 길이만큼만 차지하는 알약이라, 가장자리에 닿으면 시트로 읽힌다.
      start: RoutexSpacing.sectionGap,
      end: RoutexSpacing.sectionGap,
      // 안전영역 위로 한 구획 띄운다. 바닥에 붙이면 홈 인디케이터·시트 손잡이와
      // 겹쳐 어느 표면의 일부인지 읽히지 않는다.
      bottom:
          MediaQuery.paddingOf(context).bottom +
          RoutexSpacing.sectionGap +
          RoutexSpacing.componentPadding,
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: RoutexMotion.effectiveDuration(
              disableAnimations: disableAnimations,
              role: RoutexMotionRole.feedback,
            ),
            curve: RoutexMotion.enterCurve,
            builder: (context, value, child) =>
                Opacity(opacity: value, child: child),
            child: RoutexToastSurface(message: message),
          ),
        ),
      ),
    );
  }
}

/// 토스트의 표면만 그린다.
///
/// [RoutexToast.show]가 오버레이에 얹는 것이 이 표면이고, 카탈로그는 같은 표면을
/// 제자리에 세워 보여 준다. **눌러야만 볼 수 있는 컴포넌트는 카탈로그에서 없는 것과
/// 같다** — 1.6초 뒤 사라지는 표면일수록 더 그렇다.
///
/// 뜨고 지는 것과 자리 잡는 규칙은 표면이 아니라 [RoutexToast]가 가진다. 표면만
/// 따로 세울 수 있어야 두 가지가 섞이지 않는다.
class RoutexToastSurface extends StatelessWidget {
  const RoutexToastSurface({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return Semantics(
      liveRegion: true,
      container: true,
      child: Material(
        color: colors.contentPrimary,
        borderRadius: RoutexRadii.full,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: RoutexSpacing.componentPadding,
            vertical: RoutexSpacing.controlGap,
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: RoutexTypography.label.copyWith(
              color: colors.contentInverse,
            ),
          ),
        ),
      ),
    );
  }
}
