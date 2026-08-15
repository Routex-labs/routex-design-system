import 'package:flutter/material.dart';

import '../foundations/routex_layer.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';

/// 지도 위 하단 표면의 곡률, 그림자, 내부 여백과 handle을 고정한다.
class RoutexBottomSheet extends StatelessWidget {
  const RoutexBottomSheet({
    required this.child,
    this.header,
    this.expand = false,
    this.showHandle = true,
    super.key,
  });

  final Widget child;

  /// handle과 본문 사이의 제목 줄이다. `RoutexSheetHeader`를 넘긴다.
  ///
  /// 제목·뒤로·닫기를 본문 안에서 다시 조립하지 않는다. 시트마다 header anatomy가
  /// 달라지는 것이 v0.1에서 고치기로 한 첫 번째 문제다.
  final Widget? header;

  final bool expand;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final leading = <Widget>[if (showHandle) const _SheetHandle(), ?header];

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
      child: Padding(
        // handle은 그 자체가 위쪽 여백처럼 읽히므로 8, handle 없이 header나 본문이
        // 바로 오면 컴포넌트 여백 16을 쓴다.
        padding: EdgeInsetsDirectional.fromSTEB(
          RoutexSpacing.componentPadding,
          showHandle
              ? RoutexSpacing.controlGap
              : RoutexSpacing.componentPadding,
          RoutexSpacing.componentPadding,
          RoutexSpacing.sectionGap,
        ),
        child: content,
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return Align(
      child: Container(
        width: RoutexMetrics.compactControl,
        height: RoutexSpacing.inlineGap,
        decoration: BoxDecoration(
          color: colors.borderStrong.withValues(alpha: .55),
          borderRadius: RoutexRadii.full,
        ),
      ),
    );
  }
}
