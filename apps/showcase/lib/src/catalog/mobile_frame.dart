import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

/// 컴포넌트를 실제 제품 폭 안에서 보여준다.
///
/// 넓은 브라우저에서 컴포넌트를 그대로 늘려 놓으면 줄바꿈·말줄임·터치 영역이
/// 실제 화면과 다르게 보인다. 이 앱이 판정하는 폭(360/390dp)으로 고정해 두면
/// 카탈로그에서 본 모습이 기기에서 본 모습과 같아진다.
/// 컴포넌트가 실제 제품에서 놓이는 바탕이다.
///
/// 카탈로그가 바탕을 하나로 통일하면 절반은 안 보인다. 흰 바탕에서는 시트·카드가
/// 사라지고, 회색 바탕에서는 시트 위에 놓이는 목록·정보가 뜬다. 그래서 각 틀이
/// 그 컴포넌트가 실제로 올라가는 표면을 고른다.
enum MobileFrameSurface {
  /// 지도 위. 검색 줄, 지도 컨트롤, 하단 시트처럼 지도를 덮는 표면이 온다.
  map,

  /// 시트·패널 안. 목록, 장소 요약, 정보처럼 이미 흰 표면 위에 놓이는 것이 온다.
  sheet,
}

/// 검색창 바로 아래에 붙는 목록은 독립 카드보다 위쪽 inset을 한 단계 낮춘다.
enum MobileFrameContentInset { standard, searchAttached }

class MobileFrame extends StatelessWidget {
  const MobileFrame({
    required this.child,
    required this.surface,
    this.label,
    this.width = 390,
    this.fitContent = false,
    this.contentInset = MobileFrameContentInset.standard,
    super.key,
  });

  final Widget child;

  final MobileFrameSurface surface;

  /// 이 틀이 무엇을 보여주는지 알리는 짧은 이름이다.
  final String? label;

  final double width;

  /// 세로 컨트롤처럼 폭이 좁은 컴포넌트는 제품 폭을 다 쓰지 않는다. 이때 틀이
  /// 내용 폭까지 줄어들어야 빈 공간이 생기지 않는다.
  final bool fitContent;

  final MobileFrameContentInset contentInset;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return SizedBox(
      width: fitContent ? null : width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: fitContent
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.stretch,
        children: [
          if (label case final label?)
            Text(
              label,
              style: RoutexTypography.label.copyWith(
                color: colors.contentSecondary,
              ),
            ),
          if (label != null) const SizedBox(height: RoutexSpacing.controlGap),
          DecoratedBox(
            decoration: BoxDecoration(
              color: switch (surface) {
                MobileFrameSurface.map => colors.surfaceCanvas,
                MobileFrameSurface.sheet => colors.surfaceRaised,
              },
              borderRadius: RoutexRadii.card,
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Padding(
              padding: switch (contentInset) {
                MobileFrameContentInset.standard =>
                  const EdgeInsetsDirectional.all(RoutexSpacing.screenGutter),
                MobileFrameContentInset.searchAttached =>
                  const EdgeInsetsDirectional.fromSTEB(
                    RoutexSpacing.screenGutter,
                    RoutexSpacing.controlGap,
                    RoutexSpacing.screenGutter,
                    RoutexSpacing.screenGutter,
                  ),
              },
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
