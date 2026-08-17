import 'package:flutter/material.dart';

import '../components/routex_surface.dart';
import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';

/// 상단 바의 왼쪽 자리가 맡는 동작이다.
enum RoutexSearchLeading { menu, back }

/// 지도 홈에서 검색 진입, 메뉴/뒤로, 길찾기의 위치와 터치 영역을 고정한다.
class RoutexSearchBar extends StatelessWidget {
  const RoutexSearchBar({
    required this.placeholder,
    required this.onSearchPressed,
    required this.leading,
    required this.onLeadingPressed,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.isLoading = false,
    this.onDirectionsPressed,
    super.key,
  });

  final String placeholder;
  final VoidCallback? onSearchPressed;
  final RoutexSearchLeading leading;
  final VoidCallback onLeadingPressed;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool isLoading;
  final VoidCallback? onDirectionsPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return SizedBox(
      // 표면은 44dp로 얇게 보이되, 메뉴·검색·길찾기 모두 48dp로 누른다.
      height: RoutexMetrics.minimumTouchTarget,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: SizedBox(
              width: double.infinity,
              height: RoutexMetrics.searchField,
              child: const RoutexSurface(
                role: RoutexSurfaceRole.onMap,
                shape: RoutexSurfaceShape.field,
                child: SizedBox.expand(),
              ),
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: Row(
              children: [
                _SearchAction(
                  label: leading == RoutexSearchLeading.menu ? '메뉴' : '뒤로',
                  icon: leading == RoutexSearchLeading.menu
                      ? RoutexIcons.menu
                      : RoutexIcons.back,
                  onPressed: onLeadingPressed,
                ),
                Expanded(
                  child: controller == null
                      ? Semantics(
                          button: true,
                          enabled: onSearchPressed != null,
                          focusable: onSearchPressed != null,
                          label: placeholder,
                          onTap: onSearchPressed,
                          excludeSemantics: true,
                          child: InkWell(
                            onTap: onSearchPressed,
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                placeholder,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: RoutexTypography.body.copyWith(
                                  color: colors.contentSecondary,
                                ),
                              ),
                            ),
                          ),
                        )
                      : TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onChanged: onChanged,
                          onSubmitted: onSubmitted,
                          textInputAction: TextInputAction.search,
                          style: RoutexTypography.body,
                          cursorColor: colors.actionPrimary,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: placeholder,
                            hintStyle: RoutexTypography.body.copyWith(
                              color: colors.contentSecondary,
                            ),
                          ),
                        ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: RoutexSpacing.controlGap),
                  SizedBox.square(
                    dimension: RoutexMetrics.iconMedium,
                    child: CircularProgressIndicator(
                      strokeWidth: RoutexStroke.emphasis,
                      color: colors.actionPrimary,
                    ),
                  ),
                  const SizedBox(width: RoutexSpacing.contentGap),
                ] else if (controller case final controller?
                    when onClear != null)
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : _SearchAction(
                            label: '검색어 지우기',
                            icon: RoutexIcons.close,
                            onPressed: onClear,
                          ),
                  ),
                if (onDirectionsPressed != null) ...[
                  const SizedBox(width: RoutexSpacing.inlineGap),
                  _SearchAction(
                    label: '길찾기',
                    icon: RoutexIcons.directions,
                    color: colors.actionPrimary,
                    onPressed: onDirectionsPressed,
                  ),
                ] else
                  const SizedBox(width: RoutexSpacing.contentGap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAction extends StatelessWidget {
  const _SearchAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return SizedBox.square(
      dimension: RoutexMetrics.minimumTouchTarget,
      child: IconButton(
        tooltip: label,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        iconSize: RoutexMetrics.iconMedium,
        color: color ?? colors.contentSecondary,
        disabledColor: colors.contentDisabled,
        icon: Icon(icon),
      ),
    );
  }
}
