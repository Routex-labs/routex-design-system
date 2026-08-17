import 'package:flutter/material.dart';

import '../foundations/routex_layer.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_motion.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';

@immutable
class RoutexFloorOption {
  const RoutexFloorOption({required this.id, required this.label});

  /// 층을 가리키는 값이다. `B2`·`1F`처럼 **데이터가 이미 갖고 있는 식별자**를 그대로
  /// 쓴다 — 목록 순서에서 만든 번호를 쓰면 층이 하나 추가되는 날 조용히 밀린다.
  final String id;

  final String label;
}

/// 지도 위 층 목록의 크기, 구분선, 선택 상태와 접근성 이름을 고정한다.
///
/// **한 번에 [_maxVisibleOptions]개까지만 보인다.** 층이 그보다 많으면 세로로
/// 스크롤하고, 지금 층은 뷰포트 가운데에 맞춘다. 전량을 세우면 지하 4층·지상 8층인
/// 건물에서 기둥 하나가 지도 좌측을 통째로 가린다.
///
/// 상한을 입력으로 열지 않는 이유는 그 값이 화면별 취향이 아니라 **"지도가 보여야
/// 한다"는 이 시스템의 규칙**이기 때문이다. 스크롤도 이 컴포넌트가 갖는다 — 셀 높이가
/// 비공개 값인데 스크롤 계산이 그 값을 알아야 해서, 소비 앱에 넘기면 둘이 어긋난다.
class RoutexFloorSelector extends StatefulWidget {
  const RoutexFloorSelector({
    required this.options,
    required this.selectedId,
    required this.onSelected,
    super.key,
  }) : assert(options.length > 0);

  final List<RoutexFloorOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  State<RoutexFloorSelector> createState() => _RoutexFloorSelectorState();
}

/// 한 번에 보이는 최대 셀 수.
const _maxVisibleOptions = 5;

/// 지도 위 층 전환기는 반복된 세로 control이라 표준 시각 높이를 쓴다.
///
/// 한 셀을 48dp로 두면 다섯 층 기둥이 지도 위에서 지나치게 넓고 길어진다. 층
/// 전환은 화면 가장자리에 고정된 밀집 control이므로, 일반 버튼과 같은 44dp
/// 밀도로 낮춰 지도와 경쟁하지 않게 한다.
const _floorCellExtent = RoutexMetrics.standardControl;

class _RoutexFloorSelectorState extends State<RoutexFloorSelector> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // 첫 프레임에는 controller에 아직 clients가 붙기 전이라 여기서 바로 못 옮긴다.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _revealSelected(animate: false),
    );
  }

  @override
  void didUpdateWidget(covariant RoutexFloorSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId ||
        oldWidget.options.length != widget.options.length) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _revealSelected(animate: true),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 지금 층을 뷰포트 가운데로 옮긴다. 위아래 끝에서는 목록 밖으로 넘기지 않는다.
  void _revealSelected({required bool animate}) {
    if (!mounted || !_controller.hasClients) return;
    final index = widget.options.indexWhere(
      (option) => option.id == widget.selectedId,
    );
    if (index < 0) return;
    const cell = _floorCellExtent;
    // 목록 밖으로는 넘기지 않는다 — 위아래 끝에서는 가운데 맞춤을 포기한다.
    final target = (index * cell - (_maxVisibleOptions - 1) / 2 * cell)
        .clamp(0, _controller.position.maxScrollExtent)
        .toDouble();
    if (!animate) {
      _controller.jumpTo(target);
      return;
    }
    _controller.animateTo(
      target,
      duration: RoutexMotion.effectiveDuration(
        disableAnimations:
            MediaQuery.maybeOf(context)?.disableAnimations ?? false,
        role: RoutexMotionRole.transition,
      ),
      curve: RoutexMotion.standardCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final visible = widget.options.length < _maxVisibleOptions
        ? widget.options.length
        : _maxVisibleOptions;
    final scrolls = widget.options.length > _maxVisibleOptions;

    return SizedBox(
      // 세로 컨트롤이므로 부모가 넓어져도 폭은 셀 하나의 폭을 유지한다.
      width: _floorCellExtent,
      height: visible * _floorCellExtent,
      child: Material(
        color: colors.surfaceRaised,
        borderRadius: RoutexRadii.control,
        elevation: RoutexLayer.onMap,
        shadowColor: colors.shadow,
        clipBehavior: Clip.antiAlias,
        child: ListView.builder(
          controller: _controller,
          // 층이 다 보이면 굴릴 것이 없다. 그때도 스크롤을 열어 두면 목록이
          // 손끝에서 미끄러지며 "덜 왔나" 싶게 만든다.
          physics: scrolls
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemExtent: _floorCellExtent,
          itemCount: widget.options.length,
          itemBuilder: (context, index) => _FloorItem(
            option: widget.options[index],
            selected: widget.options[index].id == widget.selectedId,
            // 구분선은 셀 **아래**에 그린다. 선택한 층으로 정확히 스크롤됐을 때
            // 첫 셀 위로 이전 층의 선이 비치면, 목록이 아직 움직이는 것처럼 보인다.
            divided: index < widget.options.length - 1,
            onPressed: () => widget.onSelected(widget.options[index].id),
          ),
        ),
      ),
    );
  }
}

class _FloorItem extends StatelessWidget {
  const _FloorItem({
    required this.option,
    required this.selected,
    required this.divided,
    required this.onPressed,
  });

  final RoutexFloorOption option;
  final bool selected;
  final bool divided;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return Semantics(
      button: true,
      selected: selected,
      focusable: true,
      label: option.label,
      onTap: onPressed,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: divided
              ? Border(
                  bottom: BorderSide(
                    color: colors.borderSubtle,
                    width: RoutexStroke.hairline,
                  ),
                )
              : null,
        ),
        child: InkWell(
          onTap: onPressed,
          child: Ink(
            color: selected ? colors.actionPrimarySubtle : Colors.transparent,
            child: Center(
              child: Text(
                option.label,
                style: RoutexTypography.tabular(RoutexTypography.label)
                    .copyWith(
                      color: selected
                          ? colors.actionPrimary
                          : colors.contentSecondary,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
