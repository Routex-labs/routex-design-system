import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../components/routex_surface.dart';
import '../theme/routex_color_tokens.dart';

/// 상단 바의 왼쪽 자리가 맡는 동작이다.
///
/// 이 자리는 비지 않는다. 지도 위 기본 상태에서는 메뉴, 검색이나 하위 화면으로
/// 들어간 뒤에는 뒤로다. 화면마다 이 자리가 있다 없다 하면 같은 상단 바가 다른
/// 컴포넌트로 읽힌다.
enum RoutexSearchLeading { menu, back }

/// 지도 홈에서 검색 진입, 메뉴/뒤로, 길찾기의 위치와 터치 영역을 고정한다.
///
/// 왼쪽 자리는 언제나 채워진다. 길찾기는 동작을 넘긴 화면에서만 나타나며, 없을
/// 때는 같은 폭의 여백으로 검색 입력의 끝선을 유지한다.
///
/// `controller`를 넘기면 실제 입력 줄이 되고, 넘기지 않으면 검색 화면으로 넘어가는
/// 탭 타깃이 된다. 두 모드가 같은 높이·같은 시작선을 쓰므로 검색을 시작해도 상단
/// 바가 흔들리지 않는다. 지우기 버튼은 입력이 있을 때만, 진행 표시는 `isLoading`
/// 동안만 나타나며 둘 다 길찾기와 같은 자리를 쓴다.
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

  /// 넘기면 입력 줄, 넘기지 않으면 검색 진입 탭 타깃이 된다.
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// 입력이 있을 때 지우기 버튼을 노출한다.
  final VoidCallback? onClear;

  /// 검색 결과를 기다리는 중이다.
  final bool isLoading;

  final VoidCallback? onDirectionsPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return RoutexSurface(
      role: RoutexSurfaceRole.onMap,
      shape: RoutexSurfaceShape.field,
      child: SizedBox(
        height: RoutexMetrics.searchField,
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
                        border: InputBorder.none,
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
            ] else if (controller case final controller? when onClear != null)
              // 입력 여부에 따라 자리가 생겼다 없어지므로 controller를 직접
              // 구독한다. 화면이 setState로 다시 그려주길 기대하면 지우기 버튼이
              // 한 박자 늦게 나타난다.
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
    // 글리프는 20dp 그대로 두고 투명한 동작 영역만 48dp로 확보한다. 아이콘을
    // 40dp 박스에 가두면 IconButton의 padded tap target도 함께 잘린다.
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
