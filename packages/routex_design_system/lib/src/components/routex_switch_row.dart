import 'package:flutter/material.dart';

import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';
import 'routex_focus_ring.dart';

/// 화면을 바꾸지 않고 값 하나를 켜고 끄는 행이다.
///
/// **줄 전체가 스위치다.** 스위치 글리프만 누를 수 있게 두면 손가락이 닿는 폭이
/// 화면 오른쪽 끝 50px뿐이고, 제목을 눌러 본 사람은 그 설정이 잠긴 줄 안다.
///
/// **설명은 결과를 적는다.** "고정밀 모드"처럼 이름만 있으면 켰을 때 무엇이
/// 달라지는지 알 수 없다. 설명이 없으면 그 줄은 이름만으로 결과가 분명한
/// 값이라는 뜻이다.
///
/// 값을 바꾸면 화면이 즉시 바뀐다. 확인 버튼을 두지 않는 대신, 되돌릴 수 없는
/// 설정은 이 행에 두지 않는다 — 그런 값은 `RoutexDialog`가 한 번 묻는다.
class RoutexSwitchRow extends StatelessWidget {
  const RoutexSwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.description,
    super.key,
  });

  final String title;
  final String? description;
  final bool value;

  /// null이면 지금은 바꿀 수 없는 값이다. 행을 숨기지 않는 이유는 그 설정이
  /// 사라진 것이 아니라 지금 조건이 아니기 때문이다.
  final ValueChanged<bool>? onChanged;

  bool get _hasDescription => description?.trim().isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final enabled = onChanged != null;
    final foreground = enabled ? colors.contentPrimary : colors.contentDisabled;

    return Semantics(
      container: true,
      toggled: value,
      enabled: enabled,
      label: _hasDescription ? '$title, $description' : title,
      excludeSemantics: true,
      child: RoutexFocusRing(
        radius: RoutexRadii.field,
        enabled: enabled,
        child: Material(
          color: Colors.transparent,
          borderRadius: RoutexRadii.field,
          child: InkWell(
            onTap: enabled ? () => onChanged!(!value) : null,
            borderRadius: RoutexRadii.field,
            focusColor: Colors.transparent,
            hoverColor: colors.actionPrimarySubtle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: RoutexMetrics.minimumTouchTarget,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: RoutexSpacing.contentGap,
                  vertical: RoutexSpacing.controlGap,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: RoutexStack(
                        gap: RoutexStackGap.inline,
                        children: [
                          Text(
                            title,
                            style: RoutexTypography.bodyStrong.copyWith(
                              color: foreground,
                            ),
                          ),
                          if (_hasDescription)
                            Text(
                              description!,
                              style: RoutexTypography.bodySmall.copyWith(
                                color: enabled
                                    ? colors.contentSecondary
                                    : colors.contentDisabled,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: RoutexSpacing.contentGap),
                    // 스위치는 이미 줄 전체가 눌리므로 자기 터치 영역을 따로
                    // 넓히지 않는다. 넓히면 오른쪽 끝에 보이지 않는 상자가 생겨
                    // 행의 세로 여백이 글자와 어긋난다.
                    Switch(
                      value: value,
                      onChanged: onChanged,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeThumbColor: colors.surfaceRaised,
                      activeTrackColor: colors.actionPrimary,
                      inactiveThumbColor: colors.surfaceRaised,
                      inactiveTrackColor: colors.borderStrong,
                      trackOutlineColor: const WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
