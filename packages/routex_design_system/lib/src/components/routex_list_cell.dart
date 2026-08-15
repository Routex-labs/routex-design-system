import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';
import 'routex_focus_ring.dart';
import 'routex_icon_action.dart';

/// 장소·검색 결과에서 텍스트 열과 상태 위계를 고정하는 v0.1 beta cell이다.
class RoutexListCell extends StatelessWidget {
  const RoutexListCell({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailingIcon,
    this.trailingActionLabel,
    this.onTrailingAction,
    this.reorderable = false,
    this.selected = false,
    this.enabled = true,
    this.onPressed,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// 행 자체와 다른 동작을 하는 끝 버튼이다. 이름 없이는 만들 수 없다.
  final String? trailingActionLabel;
  final VoidCallback? onTrailingAction;

  /// 순서를 바꿀 수 있는 목록의 행이면 손잡이를 보여준다. 드래그 처리는 목록을
  /// 가진 화면이 맡고, 이 컴포넌트는 손잡이의 자리와 이름만 고정한다.
  final bool reorderable;

  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  bool get _hasSubtitle => subtitle?.trim().isNotEmpty ?? false;

  /// line box 안에서 글자가 실제로 시작하는 위치다. bodyStrong 16 * 1.5 line box
  /// 기준으로 위아래 4씩 남는다.
  static const _titleGlyphInset = 4.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final interactive = onPressed != null;
    final foreground = enabled ? colors.contentPrimary : colors.contentDisabled;
    final secondaryForeground = enabled
        ? colors.contentSecondary
        : colors.contentDisabled;

    return Semantics(
      container: true,
      button: interactive,
      enabled: interactive ? enabled : null,
      selected: selected,
      label: _hasSubtitle ? '$title, $subtitle' : title,
      excludeSemantics: true,
      child: RoutexFocusRing(
        radius: RoutexRadii.field,
        enabled: interactive && enabled,
        child: Material(
          color: selected ? colors.actionPrimarySubtle : Colors.transparent,
          borderRadius: RoutexRadii.field,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: RoutexRadii.field,
            // focus는 링이 맡는다. 채움은 selected·hover·pressed가 나눠 쓴다.
            focusColor: Colors.transparent,
            hoverColor: colors.actionPrimarySubtle,
            overlayColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.pressed)
                  ? selected
                        ? colors.surfaceCanvas
                        : colors.actionPrimarySubtle
                  : null;
            }),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: RoutexMetrics.minimumTouchTarget,
              ),
              child: Padding(
                // 선택·hover 배경이 행 전체를 덮으므로 좌우 여백도 행이 가진다.
                // 세로 여백만 주면 배경 안에서 텍스트가 한쪽으로 붙어 보인다.
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: RoutexSpacing.contentGap,
                  vertical: RoutexSpacing.controlGap,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: RoutexMetrics.leadingColumn,
                      child: leadingIcon == null
                          ? null
                          // 아이콘 윗면을 제목 글리프 윗면에 맞춘다. line box는
                          // 글자보다 위아래로 여유가 있어 세로 중앙에 두면 아이콘이
                          // 글자보다 떠 보인다.
                          : Padding(
                              padding: const EdgeInsetsDirectional.only(
                                top: _titleGlyphInset,
                              ),
                              child: Align(
                                alignment: AlignmentDirectional.topStart,
                                child: Icon(
                                  leadingIcon,
                                  size: RoutexMetrics.iconMedium,
                                  color: enabled
                                      ? colors.actionPrimary
                                      : colors.contentDisabled,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: RoutexSpacing.contentGap),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            style: RoutexTypography.bodyStrong.copyWith(
                              color: foreground,
                            ),
                          ),
                          if (_hasSubtitle) ...[
                            const SizedBox(height: RoutexSpacing.inlineGap),
                            Text(
                              subtitle!,
                              style: RoutexTypography.bodySmall.copyWith(
                                color: secondaryForeground,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailingIcon case final icon?) ...[
                      const SizedBox(width: RoutexSpacing.contentGap),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: _titleGlyphInset,
                        ),
                        child: Icon(
                          icon,
                          size: RoutexMetrics.iconMedium,
                          color: secondaryForeground,
                        ),
                      ),
                    ],
                    // 행 안의 보조 동작과 손잡이는 같은 평면에 있다. 하나만 타일
                    // 배경을 가지면 서로 다른 컨트롤로 읽힌다.
                    if (trailingActionLabel case final actionLabel?) ...[
                      const SizedBox(width: RoutexSpacing.controlGap),
                      RoutexIconAction(
                        label: actionLabel,
                        icon: RoutexIcons.more,
                        tone: RoutexIconActionTone.quiet,
                        onPressed: enabled ? onTrailingAction : null,
                      ),
                    ],
                    if (reorderable) ...[
                      const SizedBox(width: RoutexSpacing.controlGap),
                      SizedBox.square(
                        // 옆의 보조 동작은 눌 수 있는 컨트롤이라 48 터치 영역을
                        // 가진다. 손잡이를 44로 두면 같은 줄에서 두 글리프의
                        // 중심이 2 어긋난다. 누르지 않는 자리라도 상자는 맞춘다.
                        dimension: RoutexMetrics.minimumTouchTarget,
                        child: Semantics(
                          label: '순서 바꾸기 손잡이',
                          child: Icon(
                            RoutexIcons.reorder,
                            size: RoutexMetrics.iconMedium,
                            // 손잡이는 글이 아니라 잡는 자리를 알리는 장식이다.
                            // 보조 동작과 같은 content 색을 쓰면 둘이 같은 무게의
                            // 버튼으로 읽힌다.
                            color: enabled
                                ? colors.borderStrong
                                : colors.contentDisabled,
                          ),
                        ),
                      ),
                    ],
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
