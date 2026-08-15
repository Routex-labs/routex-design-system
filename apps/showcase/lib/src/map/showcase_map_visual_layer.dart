import 'package:flutter/material.dart';

import '../mockup/mockup_step.dart';
import 'navigation_map_painter.dart';

/// 목업에서만 사용하는 지도 시각 계층이다.
///
/// 실제 Navigation 앱의 MapLibre controller·source·layer를 Runtime Kit으로
/// 옮기지 않고, Showcase가 고정 데이터와 [NavigationMapPainter]를 연결한다.
/// 지도 시각이 필요한 단계에서만 이 계층을 삽입하며, 나머지 단계의 화면 바탕은
/// `IphoneNavigationMockup`의 단색 지도 canvas가 맡는다.
class ShowcaseMapVisualLayer extends StatelessWidget {
  const ShowcaseMapVisualLayer({
    required this.step,
    required this.progress,
    required this.mapController,
    required this.onInteractionStart,
    super.key,
  });

  final MockupStep step;
  final double progress;
  final TransformationController mapController;
  final GestureScaleStartCallback onInteractionStart;

  @override
  Widget build(BuildContext context) {
    assert(step.showsMapVisuals);
    return InteractiveViewer(
      transformationController: mapController,
      constrained: false,
      alignment: Alignment.center,
      minScale: 1,
      maxScale: 2.8,
      panEnabled: true,
      scaleEnabled: true,
      onInteractionStart: onInteractionStart,
      child: SizedBox(
        key: const ValueKey('mockup-map-canvas'),
        width: 520,
        height: 1000,
        child: CustomPaint(painter: NavigationMapPainter(step, progress)),
      ),
    );
  }
}
