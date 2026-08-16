import 'package:flutter/material.dart';

import '../foundations/routex_layer.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';

/// 본문 여백을 표면과 본문 중 누가 소유하는가.
///
/// 기본은 표면이다([surface]). 짧은 카드형 본문은 스스로 여백을 갖지 않는다.
///
/// 스크롤하는 시트는 다르다. 대표 사진처럼 **가장자리까지 닿아야 하는 조각**과
/// 안쪽으로 들어와야 하는 글이 한 본문에 섞여 있어서, 표면이 여백을 강제하면
/// 사진을 표현할 수 없다. 그런 시트는 [content]로 주고 조각마다 제 여백을 갖는다.
enum RoutexBottomSheetContentInset { surface, content }

/// 지도 위 하단 표면의 곡률, 그림자, 내부 여백과 handle을 고정한다.
///
/// 본문은 이 표면의 곡률로 잘린다. 스크롤하는 본문이 위로 올라가면 둥근 모서리
/// 밖으로 새는데, 그때 표면이 아니라 본문이 모서리를 그리는 것처럼 보인다.
class RoutexBottomSheet extends StatelessWidget {
  const RoutexBottomSheet({
    required this.child,
    this.header,
    this.expand = false,
    this.showHandle = false,
    this.contentInset = RoutexBottomSheetContentInset.surface,
    super.key,
  });

  final Widget child;

  /// handle과 본문 사이의 제목 줄이다. `RoutexSheetHeader`를 넘긴다.
  ///
  /// 제목·뒤로·닫기를 본문 안에서 다시 조립하지 않는다. 시트마다 header anatomy가
  /// 달라지는 것이 v0.1에서 고치기로 한 첫 번째 문제다.
  final Widget? header;

  final bool expand;

  /// 소비 화면에서 실제로 끌어 확장할 수 있을 때만 true로 둔다.
  ///
  /// handle은 여백이나 장식이 아니다. 고정형 카드·검색 드롭다운에 표시하면 할 수
  /// 없는 조작을 약속하게 되므로 기본값은 false다. 이 컴포넌트는 드래그 동작을
  /// 소유하지 않으며, `DraggableScrollableSheet` 같은 제스처는 소비 화면이 맡는다.
  ///
  /// **본문이 스크롤하는 시트에서는 이 자리가 아니다.** [RoutexSheetHandle]을
  /// 본문 안에 직접 둔다 — 이유는 그 위젯에 적어 두었다.
  final bool showHandle;

  final RoutexBottomSheetContentInset contentInset;

  /// Showcase와 소비 앱이 handle 적용 대상을 검증할 때 쓰는 안정된 key다.
  static const handleKey = ValueKey('routex-sheet-handle');

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final leading = <Widget>[
      if (showHandle) const RoutexSheetHandle(),
      ?header,
    ];

    final content = leading.isEmpty
        ? child
        : expand
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final widget in leading) ...[
                widget,
                const SizedBox(height: RoutexSpacing.controlGap),
              ],
              Expanded(child: child),
            ],
          )
        : RoutexStack(
            gap: RoutexStackGap.control,
            children: [...leading, child],
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: RoutexRadii.sheet,
        boxShadow: RoutexLayer.shadow(RoutexLayerRole.chrome, colors),
      ),
      // 본문을 표면의 곡률로 자른다. 스크롤하는 본문은 위로 올라가며 둥근 모서리를
      // 지나는데, 자르지 않으면 그 자리에서 사각으로 튀어나온다.
      child: ClipRRect(
        borderRadius: RoutexRadii.sheet,
        // **표면은 잉크가 앉을 자리이기도 하다.** 시트 안의 누를 수 있는 줄은 배경과
        // 물결을 가장 가까운 Material에 칠하는데, 그 사이에 색을 칠한 상자가 있으면
        // 그 아래로 가려진다(`ListTile`은 그 상황을 단언으로 잡는다). 색과 그림자는
        // 위의 DecoratedBox가 계속 그리고, 여기서는 투명한 잉크 면만 얹는다 —
        // 그리는 것이 없으므로 픽셀은 그대로다.
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            // handle은 그 자체가 위쪽 여백처럼 읽히므로 8, handle 없이 header나 본문이
            // 바로 오면 컴포넌트 여백 16을 쓴다.
            padding: switch (contentInset) {
              RoutexBottomSheetContentInset.surface =>
                EdgeInsetsDirectional.fromSTEB(
                  RoutexSpacing.componentPadding,
                  showHandle
                      ? RoutexSpacing.controlGap
                      : RoutexSpacing.componentPadding,
                  RoutexSpacing.componentPadding,
                  RoutexSpacing.sectionGap,
                ),
              // 여백은 본문 조각들이 저마다 갖는다. 표면이 넣으면 가장자리까지 닿아야
              // 하는 사진을 표현할 수 없다.
              RoutexBottomSheetContentInset.content =>
                EdgeInsetsDirectional.zero,
            },
            child: content,
          ),
        ),
      ),
    );
  }
}

/// 시트를 끌어 크기를 바꿀 수 있다는 표시다.
///
/// **본문이 스크롤하는 시트에서는 스크롤 콘텐츠의 첫 항목으로 둔다.**
/// `DraggableScrollableSheet`는 제 scrollController가 받은 드래그로만 크기가
/// 바뀌므로, 표면 위에 고정하면 눌러도 끌리지 않는 장식이 된다. 그래서 표면이
/// 아니라 본문이 이것을 소유할 수 있어야 한다.
///
/// 본문이 스크롤하지 않는 시트라면 `RoutexBottomSheet.showHandle`이 같은 것을
/// 같은 자리에 그린다. 어느 쪽이든 **끌 수 있는 시트에만** 둔다.
class RoutexSheetHandle extends StatelessWidget {
  const RoutexSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return Align(
      child: Container(
        key: RoutexBottomSheet.handleKey,
        width: RoutexMetrics.compactControl,
        height: RoutexSpacing.inlineGap,
        decoration: BoxDecoration(
          color: colors.borderStrong.withValues(
            alpha: RoutexOpacity.sheetHandle,
          ),
          borderRadius: RoutexRadii.full,
        ),
      ),
    );
  }
}
