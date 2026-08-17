import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/routex_focus_ring.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';

/// 중첩된 세그먼트 표면의 geometry다.
///
/// 48dp는 터치 영역이고 회색 트랙은 그보다 8dp 얇은 40dp다. 트랙을 4dp 위로
/// 올리면 위의 도착지 행과 리듬을 맞추면서, 남은 아래 8dp가 카드의 시각 여백이
/// 된다. 32dp 선택 면은 트랙 안에서 위아래 4dp를 같은 값으로 둔다.
abstract final class _TravelModeGeometry {
  static const hitHeight = RoutexMetrics.minimumTouchTarget;
  static const visualHeightReduction = RoutexSpacing.controlGap;
  static const trackHeight = hitHeight - visualHeightReduction;
  static const selectionHeight = RoutexMetrics.compactControl;
  static const inset = RoutexSpacing.inlineGap;
  static const trackRadius = RoutexRadii.field;
  static const selectionRadius = RoutexRadii.control;
}

@immutable
class RoutexTravelModeOption {
  const RoutexTravelModeOption({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

/// 실제로 지원하는 이동수단만 한 줄에서 선택한다.
///
/// 선택지가 하나면 선택 UI를 숨긴다. 큰 글자에서는 세로로 접지 않고 내부에서
/// 가로 스크롤해 각 수단의 아이콘과 이름을 유지한다.
class RoutexTravelModeBar extends StatelessWidget {
  const RoutexTravelModeBar({
    required this.options,
    required this.selectedId,
    required this.onSelected,
    super.key,
  }) : assert(options.length > 0),
       assert(options.length == 1 || selectedId != null);

  final List<RoutexTravelModeOption> options;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.length < 2) return const SizedBox.shrink();

    final colors = context.routexColors;
    // 세그먼트는 선택지를 균등하게 나눈다. 고정 폭을 주면 라벨 길이에 따라 어떤
    // 칸은 꽉 차고 어떤 칸은 헐거워져 같은 위계로 읽히지 않는다. 큰 글자에서만
    // 한 줄 폭을 넘기므로 그때 가로 스크롤로 넘긴다.
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final scrollable = textScale > RoutexTypography.scrollLayoutTextScale;

    final items = Row(
      mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max,
      children: [
        for (final option in options)
          if (scrollable)
            // 가로 스크롤 안에서는 폭이 무한이므로 한 칸의 최대 폭을 준다.
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: RoutexContentMeasure.scrollableOption,
              ),
              child: _TravelModeItem(
                option: option,
                selected: option.id == selectedId,
                onPressed: () => onSelected(option.id),
              ),
            )
          else
            Expanded(
              child: _TravelModeItem(
                option: option,
                selected: option.id == selectedId,
                onPressed: () => onSelected(option.id),
              ),
            ),
      ],
    );

    final track = SizedBox(
      height: _TravelModeGeometry.hitHeight,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          PositionedDirectional(
            top: 0,
            start: 0,
            end: 0,
            height: _TravelModeGeometry.trackHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceCanvas,
                borderRadius: _TravelModeGeometry.trackRadius,
              ),
            ),
          ),
          items,
        ],
      ),
    );

    return Semantics(
      container: true,
      label: '이동수단',
      child: scrollable
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: track,
            )
          : track,
    );
  }
}

class _TravelModeItem extends StatefulWidget {
  const _TravelModeItem({
    required this.option,
    required this.selected,
    required this.onPressed,
  });

  final RoutexTravelModeOption option;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_TravelModeItem> createState() => _TravelModeItemState();
}

class _TravelModeItemState extends State<_TravelModeItem> {
  bool _hovered = false;
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    // 칩과 달리 여기는 채움으로 그린다. 이동수단은 트랙 안에서 자리를 옮겨 다니는
    // 세그먼트라, 옅은 트랙 바탕 위의 옅은 틴트로는 어느 칸이 선택됐는지 약하게
    // 읽힌다. 지도를 덮는 넓이도 칩 한 줄보다 작아 무거워질 여지가 적다.
    final foreground = widget.selected
        ? colors.contentInverse
        : colors.contentSecondary;
    final fill = widget.selected
        ? (_pressed ? colors.actionPrimaryPressed : colors.actionPrimary)
        : (_hovered || _pressed
              ? colors.actionPrimarySubtle
              : Colors.transparent);

    return Semantics(
      button: true,
      selected: widget.selected,
      focusable: true,
      label: widget.option.label,
      onTap: widget.onPressed,
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (hovered) {
          if (_hovered == hovered) return;
          setState(() => _hovered = hovered);
        },
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          child: SizedBox(
            height: _TravelModeGeometry.hitHeight,
            child: Padding(
              // 48dp hit box 안에서 40dp 트랙만 보이게 한다. 남는 8dp를 아래에
              // 두면 트랙은 4dp 위로 올라가고 선택 면은 트랙의 중앙을 유지한다.
              padding: const EdgeInsetsDirectional.only(
                bottom: _TravelModeGeometry.visualHeightReduction,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: _TravelModeGeometry.inset,
                  ),
                  child: SizedBox(
                    height: _TravelModeGeometry.selectionHeight,
                    width: double.infinity,
                    child: RoutexFocusRing(
                      radius: _TravelModeGeometry.selectionRadius,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: fill,
                          borderRadius: _TravelModeGeometry.selectionRadius,
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: RoutexSpacing.controlGap,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.option.icon,
                                size: RoutexMetrics.iconSmall,
                                color: foreground,
                              ),
                              const SizedBox(width: RoutexSpacing.inlineGap),
                              Flexible(
                                child: Text(
                                  widget.option.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: RoutexTypography.control(
                                    RoutexTypography.label,
                                  ).copyWith(color: foreground),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
