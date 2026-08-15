import 'package:flutter/material.dart';

import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../theme/routex_color_tokens.dart';

/// 아이콘 동작이 놓인 자리에 따라 배경을 가질지 정한다.
///
/// `neutral`은 지도나 표면 위에 홀로 떠 있는 동작이라 눌 수 있는 자리임을 배경으로
/// 알린다. `quiet`는 이미 배경이 있는 행·헤더 안에 있는 동작이라 배경을 갖지
/// 않는다. 한 줄 안에서 어떤 동작만 타일을 가지면 서로 다른 컨트롤로 읽힌다.
enum RoutexIconActionTone { neutral, quiet, primary, danger }

/// 아이콘의 시각 크기와 48dp 터치 영역, 상태 색, 접근성 이름을 함께 고정한다.
class RoutexIconAction extends StatelessWidget {
  const RoutexIconAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.selected = false,
    this.tone = RoutexIconActionTone.neutral,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool selected;
  final RoutexIconActionTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final enabled = onPressed != null;
    final foreground = !enabled
        ? colors.contentDisabled
        : switch (tone) {
            RoutexIconActionTone.danger => colors.statusError,
            RoutexIconActionTone.primary => colors.actionPrimary,
            RoutexIconActionTone.quiet || RoutexIconActionTone.neutral =>
              selected ? colors.actionPrimary : colors.contentSecondary,
          };
    final background = switch (tone) {
      RoutexIconActionTone.danger => colors.statusErrorSubtle,
      RoutexIconActionTone.primary => colors.actionPrimarySubtle,
      RoutexIconActionTone.quiet =>
        selected ? colors.actionPrimarySubtle : Colors.transparent,
      RoutexIconActionTone.neutral =>
        selected ? colors.actionPrimarySubtle : colors.surfaceCanvas,
    };

    // 보이는 크기는 44, 터치 영역은 padded tap target으로 48을 유지한다.
    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      iconSize: RoutexMetrics.iconMedium,
      style: IconButton.styleFrom(
        foregroundColor: foreground,
        disabledForegroundColor: colors.contentDisabled,
        backgroundColor: background,
        disabledBackgroundColor: tone == RoutexIconActionTone.quiet
            ? Colors.transparent
            : colors.actionDisabled,
        padding: EdgeInsets.zero,
        fixedSize: const Size.square(RoutexMetrics.standardControl),
        minimumSize: const Size.square(RoutexMetrics.standardControl),
        tapTargetSize: MaterialTapTargetSize.padded,
        shape: const RoundedRectangleBorder(borderRadius: RoutexRadii.field),
      ),
      icon: Icon(icon),
    );
  }
}
