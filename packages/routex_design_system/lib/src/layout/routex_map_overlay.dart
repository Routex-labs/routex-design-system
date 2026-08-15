import 'package:flutter/widgets.dart';

import '../foundations/routex_spacing.dart';

/// 지도 위 하단 표면이 차지하는 높이다.
///
/// 시트 높이를 화면마다 계산하지 않고 두 단계 중 하나로 고른다.
enum RoutexSheetExtent {
  /// 내용 높이만큼만 차지한다.
  content(null),

  /// 지도를 맥락으로만 남기고 시트가 대부분을 차지한다.
  large(.75);

  const RoutexSheetExtent(this.heightFactor);

  final double? heightFactor;
}

enum _OverlaySlot { top, filters, leading, trailing, notice, sheet }

/// 지도 위 오버레이의 화면 gutter, 안전 영역과 시트 기준 세로 순서를 고정한다.
///
/// 지도 컨트롤은 하단 표면 위에 쌓인다. 시트 높이를 좌표로 계산하지 않으므로
/// 시트 내용이 늘어나도 컨트롤이 시트에 가려지지 않는다.
class RoutexMapOverlay extends StatelessWidget {
  const RoutexMapOverlay({
    this.top,
    this.filters,
    this.leadingControls = const <Widget>[],
    this.trailingControls = const <Widget>[],
    this.notice,
    this.sheet,
    this.sheetExtent = RoutexSheetExtent.content,
    super.key,
  });

  /// 안내 배너, 검색이나 경로 입력처럼 화면 위쪽에 고정하는 표면이다.
  final Widget? top;

  /// 상단 표면 바로 아래에 붙는 지도 필터 줄이다.
  ///
  /// 지도에 보이는 대상을 좁히는 선택지만 온다. 목록을 좁히는 필터는 그 목록이
  /// 있는 시트 안에 둔다.
  final Widget? filters;

  /// 지도 왼쪽 아래에 세로로 쌓는 컨트롤이다.
  final List<Widget> leadingControls;

  /// 지도 오른쪽 아래에 세로로 쌓는 컨트롤이다.
  final List<Widget> trailingControls;

  /// 시트 바로 위에 겹치는 짧은 결과 알림이다.
  final Widget? notice;

  /// 하단 표면이다.
  final Widget? sheet;

  final RoutexSheetExtent sheetExtent;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.paddingOf(context);

    return CustomMultiChildLayout(
      delegate: _RoutexMapOverlayDelegate(
        viewPadding: viewPadding,
        sheetHeightFactor: sheetExtent.heightFactor,
      ),
      children: [
        if (top case final top?) LayoutId(id: _OverlaySlot.top, child: top),
        if (filters case final filters?)
          LayoutId(id: _OverlaySlot.filters, child: filters),
        if (leadingControls.isNotEmpty)
          LayoutId(
            id: _OverlaySlot.leading,
            child: _ControlColumn(
              alignment: CrossAxisAlignment.start,
              children: leadingControls,
            ),
          ),
        if (trailingControls.isNotEmpty)
          LayoutId(
            id: _OverlaySlot.trailing,
            child: _ControlColumn(
              alignment: CrossAxisAlignment.end,
              children: trailingControls,
            ),
          ),
        if (notice case final notice?)
          LayoutId(id: _OverlaySlot.notice, child: notice),
        if (sheet case final sheet?)
          LayoutId(id: _OverlaySlot.sheet, child: sheet),
      ],
    );
  }
}

/// 오버레이 사이의 세로 순서를 좌표 대신 계약으로 계산한다.
///
/// 아래에서 위로 시트 → 알림 → 지도 컨트롤 순으로 쌓고, 상단 표면만 안전 영역을
/// 기준으로 고정한다. 공간이 모자라면 컨트롤이 먼저 위로 밀린다.
class _RoutexMapOverlayDelegate extends MultiChildLayoutDelegate {
  _RoutexMapOverlayDelegate({
    required this.viewPadding,
    required this.sheetHeightFactor,
  });

  final EdgeInsets viewPadding;
  final double? sheetHeightFactor;

  static const _gutter = RoutexSpacing.screenGutter;

  @override
  void performLayout(Size size) {
    final contentWidth = size.width - _gutter * 2;
    var anchor = size.height;

    if (hasChild(_OverlaySlot.sheet)) {
      final factor = sheetHeightFactor;
      final sheetSize = layoutChild(
        _OverlaySlot.sheet,
        factor == null
            ? BoxConstraints.tightFor(width: size.width)
            : BoxConstraints.tightFor(
                width: size.width,
                height: size.height * factor,
              ),
      );
      anchor -= sheetSize.height;
      positionChild(_OverlaySlot.sheet, Offset(0, anchor));
    } else {
      anchor -= viewPadding.bottom + _gutter;
    }

    if (hasChild(_OverlaySlot.notice)) {
      final noticeSize = layoutChild(
        _OverlaySlot.notice,
        BoxConstraints.tightFor(width: contentWidth),
      );
      anchor -= RoutexSpacing.contentGap + noticeSize.height;
      positionChild(_OverlaySlot.notice, Offset(_gutter, anchor));
    }

    final controlConstraints = BoxConstraints.loose(
      Size(contentWidth, size.height),
    );
    final controlsBottom = anchor - RoutexSpacing.contentGap;

    if (hasChild(_OverlaySlot.leading)) {
      final leadingSize = layoutChild(_OverlaySlot.leading, controlConstraints);
      positionChild(
        _OverlaySlot.leading,
        Offset(_gutter, controlsBottom - leadingSize.height),
      );
    }
    if (hasChild(_OverlaySlot.trailing)) {
      final trailingSize = layoutChild(
        _OverlaySlot.trailing,
        controlConstraints,
      );
      positionChild(
        _OverlaySlot.trailing,
        Offset(
          size.width - _gutter - trailingSize.width,
          controlsBottom - trailingSize.height,
        ),
      );
    }

    var topAnchor = viewPadding.top + RoutexSpacing.controlGap;
    if (hasChild(_OverlaySlot.top)) {
      final topSize = layoutChild(
        _OverlaySlot.top,
        BoxConstraints.tightFor(width: contentWidth),
      );
      positionChild(_OverlaySlot.top, Offset(_gutter, topAnchor));
      // 필터 줄은 칩의 터치 영역(48) 안에 시각 여백 8을 이미 갖고 있다. 여기서
      // contentGap을 그대로 더하면 눈에는 20으로 보인다.
      topAnchor += topSize.height + RoutexSpacing.inlineGap;
    }

    if (hasChild(_OverlaySlot.filters)) {
      layoutChild(
        _OverlaySlot.filters,
        BoxConstraints.tightFor(width: contentWidth),
      );
      positionChild(_OverlaySlot.filters, Offset(_gutter, topAnchor));
    }
  }

  @override
  bool shouldRelayout(_RoutexMapOverlayDelegate oldDelegate) =>
      oldDelegate.viewPadding != viewPadding ||
      oldDelegate.sheetHeightFactor != sheetHeightFactor;
}

class _ControlColumn extends StatelessWidget {
  const _ControlColumn({required this.alignment, required this.children});

  final CrossAxisAlignment alignment;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(height: RoutexSpacing.controlGap),
          children[index],
        ],
      ],
    );
  }
}
