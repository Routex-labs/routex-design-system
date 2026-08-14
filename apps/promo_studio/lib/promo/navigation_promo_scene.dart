import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import 'navigation_promo_data.dart';
import 'navigation_promo_timeline.dart';

const _stageSize = Size(1920, 1080);
const _blue = Color(0xFF2878F0);
const _blueDeep = Color(0xFF0B55C9);
const _ink = Color(0xFF13233A);
const _muted = Color(0xFF718096);
const _line = Color(0xFFC8D2DF);
const _paper = Color(0xFFF7F9FC);
const _red = Color(0xFFF04452);
// 16:9 영상 무대 안에 배치되는 19.5:9 모바일 촬영 뷰포트.
const _phoneLeft = 724.0;
const _phoneTop = 29.0;
const _phoneWidth = 472.0;
const _phoneHeight = 1022.0;
const _phoneRadius = 62.0;
const _mobileStageLeft = 752.0;
const _mobileStageWidth = 416.0;
const _openingExtensionMs = 2000;
const _openingUiDelayMs = 3100 + _openingExtensionMs;
const _openingMapSettleMs = 5300 + _openingExtensionMs;
const _routeTravelExtensionMs = 4500;
const _indoorSequenceExtensionMs = 3000;

/// 촬영 전용 38.6초 장면.
///
/// 전체 앱이나 전체 평면도를 한 번에 보여주지 않는다. 위치점 하나에서 시작해
/// 검색, 경로, 층 전환, 도착 순으로 필요한 실제 UI와 지도 조각만 조립한다.
class NavigationPromoScene extends StatelessWidget {
  const NavigationPromoScene({
    super.key,
    required this.timeMs,
    this.segment = NavigationPromoSegment.full,
  });

  /// 구간 시간. `full`에서는 원본 시간과 같고, `webC`에서는 0부터 시작한다.
  final int timeMs;
  final NavigationPromoSegment segment;

  @override
  Widget build(BuildContext context) {
    final sourceTimeMs = segment.sourceTimeFor(timeMs);
    final storyTimeMs = _extendedStoryTime(sourceTimeMs - _openingUiDelayMs);
    final shellTimeMs = storyTimeMs + 3100;
    final handoff = _PromoHandoff.of(segment, sourceTimeMs);
    // 무대에는 Material 조상이 없어서 Text가 테마 대신 플랫폼 기본 서체로
    // 떨어진다. 촬영 결과가 호스트에 따라 달라지지 않도록 앱 서체를 못박는다.
    return DefaultTextStyle(
      style: const TextStyle(
        fontFamily: 'Pretendard',
        color: _ink,
        fontSize: 14,
        height: 1.2,
        decoration: TextDecoration.none,
      ),
      child: ColoredBox(
        color: _paper,
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox.fromSize(
              size: _stageSize,
              child: ClipRect(
                child: _PhoneScreenUnwarp(
                  progress: handoff.unwarp,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: _WorldPainter(
                          sourceTimeMs,
                          zoomBoost: handoff.mapZoom,
                          routeIgnition: handoff.routeIgnition,
                        ),
                      ),
                      _MobileViewportVeil(
                        timeMs: shellTimeMs,
                        fade: handoff.uiFade,
                      ),
                      _SearchBarShellUi(
                        timeMs: shellTimeMs,
                        fade: handoff.uiFade,
                      ),
                      _AppShellUi(timeMs: shellTimeMs, fade: handoff.uiFade),
                      _SearchUi(timeMs: storyTimeMs, fade: handoff.uiFade),
                      _SearchResultsUi(
                        timeMs: storyTimeMs,
                        fade: handoff.uiFade,
                      ),
                      _KeyboardUi(timeMs: storyTimeMs, fade: handoff.uiFade),
                      _PlacePreviewUi(
                        timeMs: storyTimeMs,
                        fade: handoff.uiFade,
                      ),
                      _GuidanceUi(timeMs: storyTimeMs, fade: handoff.uiFade),
                      _FloorTransitionUi(
                        timeMs: storyTimeMs,
                        fade: handoff.uiFade,
                      ),
                      _ArrivalUi(timeMs: storyTimeMs, fade: handoff.uiFade),
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _FinishPainter(storyTimeMs),
                        ),
                      ),
                      if (handoff.edgeBloom > 0)
                        IgnorePointer(
                          child: CustomPaint(
                            painter: _EdgeBloomPainter(handoff.edgeBloom),
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
    );
  }
}

/// 구간 경계에서만 살아나는 전환 값. `full`에서는 전부 중립이라 기존 장면과
/// 픽셀이 같다.
class _PromoHandoff {
  const _PromoHandoff({
    this.uiFade = 1,
    this.mapZoom = 1,
    this.edgeBloom = 0,
    this.routeIgnition = 0,
    this.unwarp = 0,
  });

  /// 모바일 UI 전체에 곱하는 농도. 지도와 파란 경로에는 곱하지 않는다.
  final double uiFade;
  final double mapZoom;
  final double edgeBloom;

  /// WEB_A 마지막 구간에서 `길찾기` 탭의 결과로 파란 경로가 뻗기 시작하는 양.
  /// Blender 첫 프레임의 경로 시작과 인과관계를 만든다.
  final double routeIgnition;

  /// Blender 휴대폰 화면에서 확대되어 나오는 느낌의 사다리꼴 왜곡.
  final double unwarp;

  factory _PromoHandoff.of(NavigationPromoSegment segment, int sourceTimeMs) {
    switch (segment) {
      case NavigationPromoSegment.full:
        return const _PromoHandoff();
      case NavigationPromoSegment.webA:
        final handoff = _motion(
          sourceTimeMs,
          webAHandoffStartMs,
          webAEndMs,
          _premium,
        );
        return _PromoHandoff(
          uiFade: 1 - handoff,
          mapZoom: mix(1, webAHandoffZoom, handoff),
          edgeBloom:
              _motion(sourceTimeMs, webABloomStartMs, webAEndMs, _premium) *
              webAHandoffBloom,
          routeIgnition: handoff,
        );
      case NavigationPromoSegment.webC:
        final segmentTimeMs = sourceTimeMs - webCSourceStartMs;
        return _PromoHandoff(
          uiFade: _motion(segmentTimeMs, webCUiStartMs, webCUiEndMs, _premium),
          // 첫 6프레임은 Blender 카메라 속도를 받아 빠르고 이후 감속한다.
          unwarp: 1 - _motion(segmentTimeMs, 0, webCUnwarpMs, _premium),
        );
    }
  }
}

class _PhoneScreenUnwarp extends StatelessWidget {
  const _PhoneScreenUnwarp({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) return child;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, .0009 * progress)
      ..rotateX(-.035 * progress)
      ..scaleByDouble(mix(1, 1.05, progress), mix(1, 1.05, progress), 1, 1);
    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: child,
    );
  }
}

/// 마지막 몇 프레임에서 가장자리만 흰색으로 날린다. 중앙의 지도와 파란 경로는
/// 남겨서 Blender 첫 프레임과 겹칠 기준을 유지한다.
class _EdgeBloomPainter extends CustomPainter {
  const _EdgeBloomPainter(this.strength);

  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    if (strength <= 0) return;
    final rect = Offset.zero & size;
    final radius = size.width * .62;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          rect.center,
          radius,
          [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: .48 * strength),
            Colors.white.withValues(alpha: strength),
          ],
          const [0, .44, .78, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _EdgeBloomPainter oldDelegate) =>
      oldDelegate.strength != strength;
}

class _WorldPainter extends CustomPainter {
  const _WorldPainter(
    this.timeMs, {
    this.zoomBoost = 1,
    this.routeIgnition = 0,
  });

  final int timeMs;

  /// WEB_A 마지막 구간에서 지도만 남기고 가볍게 들어가는 배율.
  final double zoomBoost;
  final double routeIgnition;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);

    final timelineTimeMs = _worldTimelineTime(timeMs);
    final baseCamera = _cameraAt(timelineTimeMs);
    final camera = zoomBoost == 1
        ? baseCamera
        : _CameraState(baseCamera.focus, baseCamera.scale * zoomBoost);
    const detailFocus = 0.0;
    final mapOpacity =
        (1 - detailFocus) *
        (1 - _motion(timelineTimeMs, 28200, 29000, _travel));
    if (mapOpacity > 0) {
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.scale(camera.scale);
      canvas.translate(-camera.focus.dx, -camera.focus.dy);

      // 외부에서는 특정 건물을 영웅처럼 세우지 않는다. 도로와 주변 블록,
      // 목적지 건물 외곽선이 모두 같은 도시 조립 웨이브로 나타난다.
      final cityAssembly = _motion(timelineTimeMs, 2800, 7200, smooth);
      final indoorFocus = _motion(
        timelineTimeMs,
        _entryPauseStartMs,
        _entryZoomEndMs,
        _premium,
      );
      // 입구를 통과한 뒤에는 실내가 시각적 주체가 된다. 외부 도시는 완전히
      // 지우지 않고 밝기만 눌러, 확대 전후의 공간 관계가 끊기지 않게 한다.
      final exteriorOpacity = mapOpacity * mix(1, .24, indoorFocus);
      _drawCityContext(
        canvas,
        assembly: cityAssembly,
        opacity: exteriorOpacity,
        cameraScale: camera.scale,
        timelineTimeMs: timelineTimeMs,
      );

      // WEB_A 구간에서 더현대는 내부가 없는 일반적인 도시 블록으로만 보인다.
      // 내부 구조와 경로가 생기는 연출은 Blender/WEB_C 구간이 맡는다.
      // 실내가 조립된 뒤에도 목적지 건물의 외곽선은 약하게 남긴다.
      final floorOutlineExit = _motion(
        timelineTimeMs,
        _floorOutlineExitStartMs,
        _floorTransitionStartMs,
        _premium,
      );
      final buildingMass =
          mix(1, .34, _indoorHandover(timelineTimeMs)) * (1 - floorOutlineExit);
      if (buildingMass > 0) {
        _drawBuildingMass(
          canvas,
          buildingMass * mapOpacity * mix(1, .72, indoorFocus),
          camera.scale,
          assembly: _motion(timelineTimeMs, 3000, 7300, smooth),
        );
      }

      final floorSwap = _motion(timelineTimeMs, 14900, 20700, _travel);
      final b1Exit = _motion(
        timelineTimeMs,
        _floorDisassemblyStartMs,
        _floorDisassemblyEndMs,
        smooth,
      );
      // 층 전환 뒤 매장 폴리곤이 한꺼번에 튀지 않도록 조립 호흡을 길게 둔다.
      final b2Enter = interval(timelineTimeMs, 18200, 21500);
      final activeFocus = timelineTimeMs < 15600
          ? _pointOnPath(_entryRoute, _entryWalk(timelineTimeMs))
          : Offset.lerp(_entryRouteEnd, _arrivalTransfer, floorSwap)!;

      if (b1Exit < 1) {
        _drawFloor(
          canvas,
          shapes: _entryShapes,
          footprint: _entryFootprint,
          anchor: _entryStart,
          transitionAnchor: _entryRouteEnd,
          focus: activeFocus,
          entrance: _indoorHandover(timelineTimeMs),
          exit: b1Exit,
          opacity: mapOpacity,
          reverseExit: false,
          entranceGap: _entryStart,
          outlineExit: floorOutlineExit,
        );
      }

      if (b2Enter > 0) {
        _drawFloor(
          canvas,
          shapes: _arrivalShapes,
          footprint: _arrivalFootprint,
          anchor: _arrivalTransfer,
          transitionAnchor: _arrivalTransfer,
          focus: timelineTimeMs < 21000
              ? _arrivalTransfer
              : _pointOnPath(_arrivalRoute, _arrivalWalk(timelineTimeMs)),
          entrance: b2Enter,
          exit: 0,
          opacity: mapOpacity,
          reverseExit: true,
        );
      }

      // 외부 지점에서 목적지를 선택한 직후, 실제 이동 경로가 도로를 따라
      // 더현대 입구로 뻗는다. Blender가 이어받는 마지막 프레임에서도 같은
      // 경로의 앞머리를 유지한다.
      final unifiedProgress = _unifiedEntryProgress(timelineTimeMs);
      // 하나의 연속 경로를 입구에서 잠시 멈췄다가 이어 그린다. 실외와 실내를
      // 별도 선으로 겹쳐 그리지 않으며, 각 구간 모두 선두가 마커보다 먼저 간다.
      final approachReveal = math.max(
        _unifiedEntryReveal(timelineTimeMs),
        routeIgnition * webARouteIgnitionReveal,
      );
      final approachOpacity =
          1 - _motion(timelineTimeMs, _indoorWalkEndMs, 15700, _premium);
      if (approachReveal > 0 && approachOpacity > 0) {
        _drawRoute(
          canvas,
          _approachRoute,
          reveal: approachReveal,
          walked: unifiedProgress,
          opacity: mapOpacity * approachOpacity,
          cameraScale: camera.scale,
          lagCoreBehindReveal: false,
        );
      }

      final b2Route = _motion(timelineTimeMs, 21000, 21400, _travel);
      if (b2Route > 0) {
        _drawRoute(
          canvas,
          _arrivalRoute,
          reveal: b2Route,
          walked: _arrivalWalk(timelineTimeMs),
          opacity: mapOpacity,
          cameraScale: camera.scale,
        );
      }

      final arrival = _motion(timelineTimeMs, 23300, 24700, _premium);
      if (arrival > 0) {
        _drawDestination(canvas, arrival, mapOpacity);
      }
      canvas.restore();
    }

    // 시작 마커는 가상 도시 외부 도로의 한 지점이다. 두 번 점멸한 뒤,
    // 카메라가 물러나 도시 전체가 조립되는 동안 출발점을 계속 붙잡는다.
    if (timelineTimeMs < _openingMapSettleMs) {
      final openingMarkerOpacity = timelineTimeMs <= 0
          ? 1.0
          : smooth(interval(timelineTimeMs, 100, 700));
      final blinkTime = interval(timelineTimeMs, 100, 2600);
      final openingBlink = math
          .pow(math.sin(blinkTime * math.pi * 2), 2)
          .toDouble();
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.scale(camera.scale);
      canvas.translate(-camera.focus.dx, -camera.focus.dy);
      _drawOpeningUserDot(
        canvas,
        _outdoorStand,
        opacity: openingMarkerOpacity,
        bloom: openingBlink,
        cameraScale: camera.scale,
        timelineTimeMs: timelineTimeMs,
      );
      canvas.restore();
    }

    _drawScreenMarkers(canvas, size, camera, detailFocus, timelineTimeMs);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF5F8FC), Color(0xFFEDF4FC)],
        ).createShader(rect),
    );

    final seconds = timeMs / 1000;
    final blueCenter = Offset(
      size.width * (.18 + math.sin(seconds * .18) * .025),
      size.height * (.70 + math.cos(seconds * .16) * .025),
    );
    final mintCenter = Offset(
      size.width * (.82 + math.cos(seconds * .14) * .02),
      size.height * (.22 + math.sin(seconds * .17) * .02),
    );
    for (final glow in [
      (blueCenter, const Color(0xFF9CC8FF), 560.0, .24),
      (mintCenter, const Color(0xFFBDEDE4), 480.0, .20),
    ]) {
      canvas.drawCircle(
        glow.$1,
        glow.$3,
        Paint()
          ..shader = RadialGradient(
            colors: [
              glow.$2.withValues(alpha: glow.$4),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: glow.$1, radius: glow.$3)),
      );
    }
  }

  /// 건물 전체 외곽선을 채워진 하나의 도시 블록으로 그린다. 내부 구조는 없다.
  /// 주변 블록과 같은 조립 웨이브를 사용해 특정 건물이 영웅처럼 보이지 않게 한다.
  void _drawBuildingMass(
    Canvas canvas,
    double opacity,
    double cameraScale, {
    required double assembly,
  }) {
    if (opacity <= 0 || assembly <= 0) return;
    final unit = 1 / cameraScale;
    final path = _pathFromPoints(_outdoorBuildingFootprint, close: true);
    final bounds = path.getBounds();
    final center = bounds.center;
    final assembled = _premium(assembly);
    final incoming = Offset(0, (1 - assembled) * 92);
    final scale = mix(.84, 1, assembled);
    final visible = opacity * mix(.12, 1, assembled);

    canvas.save();
    canvas.translate(center.dx + incoming.dx, center.dy + incoming.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);
    final outline = _pathWithEntranceGap(path, _outdoorEntry, 64);
    for (final segment in outline) {
      canvas.drawPath(
        segment,
        Paint()
          ..color = const Color(0xFF9FB4CC).withValues(alpha: .24 * visible)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8 * unit
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * unit),
      );
    }
    // 실외에서는 목적지의 내부 덩어리를 미리 노출하지 않는다. 입구에 도착한 뒤
    // 실제 층 폴리곤이 조립되기 전까지는 외곽선만 도시 위에 남는다.
    for (final segment in outline) {
      canvas.drawPath(
        segment,
        Paint()
          ..color = const Color(0xFF9FB3C8).withValues(alpha: .82 * visible)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0 * unit,
      );
    }
    canvas.restore();
  }

  void _drawCityContext(
    Canvas canvas, {
    required double assembly,
    required double opacity,
    required double cameraScale,
    required int timelineTimeMs,
  }) {
    if (opacity <= 0) return;
    final unit = 1 / cameraScale;
    final roadReveal = _motion(timelineTimeMs, 2700, 7200, smooth);

    // 건물은 도로 사이 필지에 먼저 놓고, 연결된 도로 면을 마지막에 올린다.
    // 작은 좌표 오차가 있어도 건물이 노면 위를 침범해 보이지 않는다.
    for (var index = 0; index < _cityBlocks.length; index++) {
      final block = _cityBlocks[index];
      final distance = (block.bounds.center - _cityAssemblyOrigin).distance;
      final delay = clamp01(distance / 1250) * .28 + (index % 3) * .025;
      final reveal = clamp01((assembly - delay) / .72);
      if (reveal <= 0) continue;
      _drawCityBlock(
        canvas,
        block,
        reveal: reveal,
        opacity: opacity,
        unit: unit,
      );
    }

    for (var index = 0; index < _cityRoads.length; index++) {
      final delay = index / math.max(1, _cityRoads.length - 1) * .20;
      final reveal = clamp01((roadReveal - delay) / .80);
      if (reveal <= 0) continue;
      _drawCityRoad(
        canvas,
        _cityRoads[index],
        reveal: reveal,
        opacity: opacity,
        unit: unit,
        surface: false,
      );
    }

    // 모든 도로의 바닥을 먼저 합친 뒤 밝은 노면을 한 번 더 올린다. 도로별로
    // 바닥·노면을 번갈아 그리면 교차로마다 테두리가 중앙선처럼 남는다.
    for (var index = 0; index < _cityRoads.length; index++) {
      final delay = index / math.max(1, _cityRoads.length - 1) * .20;
      final reveal = clamp01((roadReveal - delay) / .80);
      if (reveal <= 0) continue;
      _drawCityRoad(
        canvas,
        _cityRoads[index],
        reveal: reveal,
        opacity: opacity,
        unit: unit,
        surface: true,
      );
    }
  }

  void _drawCityRoad(
    Canvas canvas,
    Path source, {
    required double reveal,
    required double opacity,
    required double unit,
    required bool surface,
  }) {
    final metric = source.computeMetrics().first;
    final length = metric.length * clamp01(reveal);
    final road = metric.extractPath(0, length);
    final easedReveal = smooth(reveal);
    canvas.drawPath(
      road,
      Paint()
        ..color = (surface
            ? const Color(
                0xFFF8FAFC,
              ).withValues(alpha: .78 * opacity * easedReveal)
            : const Color(
                0xFFDCE5EE,
              ).withValues(alpha: .32 * opacity * easedReveal))
        ..style = PaintingStyle.stroke
        ..strokeWidth = (surface ? 62 : 78) * unit
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.bevel,
    );
  }

  void _drawCityBlock(
    Canvas canvas,
    _CityBlock block, {
    required double reveal,
    required double opacity,
    required double unit,
  }) {
    final eased = smooth(reveal);
    final center = block.bounds.center;
    var direction = center - _cityAssemblyOrigin;
    if (direction.distance < 1) direction = const Offset(1, 0);
    direction /= direction.distance;
    final travel = math.min(
      110,
      math.max(42, (center - _cityAssemblyOrigin).distance * .12),
    );
    final offset = direction * ((1 - eased) * -travel);
    final scale = mix(.78, 1, eased);
    final outlineReveal = smooth(clamp01(reveal / .72));
    final fillReveal = smooth(clamp01((reveal - .30) / .70));

    canvas.save();
    canvas.translate(center.dx + offset.dx, center.dy + offset.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);

    final metric = block.path.computeMetrics().first;
    final outline = metric.extractPath(0, metric.length * outlineReveal);
    canvas.drawPath(
      outline,
      Paint()
        ..color = const Color(0xFFAFC0D0).withValues(alpha: .62 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7 * unit
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.bevel,
    );
    if (fillReveal > 0) {
      canvas.drawPath(
        block.path.shift(Offset(0, 7 * unit * (1 - fillReveal))),
        Paint()
          ..color = const Color(
            0xFF9BAEC1,
          ).withValues(alpha: .08 * opacity * fillReveal)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * unit),
      );
      canvas.drawPath(
        block.path,
        Paint()
          ..color = block.tone.withValues(alpha: .88 * opacity * fillReveal),
      );
    }
    canvas.restore();
  }

  void _drawFloor(
    Canvas canvas, {
    required List<_MapShape> shapes,
    required List<Offset> footprint,
    required Offset anchor,
    required Offset transitionAnchor,
    required Offset focus,
    required double entrance,
    required double exit,
    required double opacity,
    required bool reverseExit,
    Offset? entranceGap,
    double outlineExit = 0,
  }) {
    final structureOpacity =
        _stagger(entrance, 0, 4, .46) *
        (1 - math.max(exit, outlineExit)) *
        opacity;
    if (structureOpacity > 0) {
      final footprintPath = _pathFromPoints(footprint, close: true);
      final outlines = entranceGap == null
          ? [footprintPath]
          : _pathWithEntranceGap(footprintPath, entranceGap, 56);
      for (final outline in outlines) {
        canvas.drawPath(
          outline,
          Paint()
            ..color = Colors.white.withValues(alpha: .10 * structureOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }

    for (var index = 0; index < shapes.length; index++) {
      final shape = shapes[index];
      final distance = (shape.bounds.center - focus).distance;
      // 거리값은 화면에서 의미 없는 먼 조각을 거르는 데만 쓴다. 최종 농도에
      // 곱하면 현재 위치 근처 매장만 강조된 것처럼 보이므로 재질은 모두 같다.
      if (distance >= 620) continue;
      final assemblyDistance = (shape.bounds.center - anchor).distance;
      // 중심 거리 자체를 지연값으로 사용해 중앙에서 외곽으로 연속적인
      // 조립 웨이브가 퍼지게 한다. 개별 조각의 가속도는 분해의 역재생이다.
      const radialSpread = .42;
      final radialDelay = clamp01(assemblyDistance / 620) * radialSpread;
      final pieceProgress = clamp01(
        (entrance - radialDelay) / (1 - radialSpread),
      );
      final reversedLeave = _travel(1 - pieceProgress);
      final enter = 1 - reversedLeave;
      final transitionDistance =
          (shape.bounds.center - transitionAnchor).distance;
      final group = transitionDistance < 180
          ? 0
          : transitionDistance < 360
          ? 1
          : 2;
      final leave = smooth(clamp01((exit - group * .08) / .84));
      final visible = enter * (1 - leave) * opacity;
      if (visible <= .01) continue;

      var incomingDirection = shape.bounds.center - anchor;
      if (incomingDirection.distance < 1) {
        incomingDirection = const Offset(1, 0);
      }
      incomingDirection /= incomingDirection.distance;
      var outgoingDirection = shape.bounds.center - transitionAnchor;
      if (outgoingDirection.distance < 1) {
        outgoingDirection = const Offset(1, 0);
      }
      outgoingDirection /= outgoingDirection.distance;
      final assemblyTravel = math.min(
        120.0,
        math.max(24.0, assemblyDistance * .30),
      );
      // 각 조각은 바깥에서 중심으로 들어오지 않고, 중심 쪽에서 자기 자리로
      // 방사형으로 퍼져나가며 결합된다.
      final incoming = incomingDirection * -(1 - enter) * assemblyTravel;
      final outgoingSign = reverseExit ? -1.0 : 1.0;
      final outgoing = outgoingDirection * leave * 150 * outgoingSign;
      final center = shape.bounds.center;

      canvas.save();
      canvas.translate(
        center.dx + incoming.dx + outgoing.dx,
        center.dy + incoming.dy + outgoing.dy,
      );
      canvas.scale(mix(.92, 1, enter) * mix(1, .92, leave));
      canvas.translate(-center.dx, -center.dy);
      canvas.drawPath(
        shape.path,
        Paint()
          ..color = Colors.white.withValues(alpha: .34 * visible)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawPath(
        shape.path,
        Paint()
          ..color = const Color(0xFFFAFCFF).withValues(alpha: .32 * visible),
      );
      canvas.drawPath(
        shape.path,
        Paint()
          ..color = _line.withValues(alpha: .22 * visible)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.25,
      );
      canvas.restore();
    }
  }

  void _drawRoute(
    Canvas canvas,
    Path path, {
    required double reveal,
    required double walked,
    required double opacity,
    required double cameraScale,
    bool lagCoreBehindReveal = true,
  }) {
    final unit = 1 / cameraScale;
    final metric = path.computeMetrics().first;
    final glassHead = clamp01(reveal);
    final coreHead = lagCoreBehindReveal
        ? clamp01((reveal - .055) / .945)
        : glassHead;
    final walkedHead = math.min(clamp01(walked), coreHead);
    final glass = metric.extractPath(0, metric.length * glassHead);
    canvas.drawPath(
      glass,
      Paint()
        ..color = Colors.white.withValues(alpha: .56 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18 * unit
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * unit),
    );
    canvas.drawPath(
      glass,
      Paint()
        ..color = const Color(0xFFBFD9FA).withValues(alpha: .58 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12 * unit
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    if (walkedHead > 0) {
      final done = metric.extractPath(0, metric.length * walkedHead);
      canvas.drawPath(
        done,
        Paint()
          ..color = const Color(0xFFA9B3BF).withValues(alpha: .84 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 * unit
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
    if (coreHead > walkedHead) {
      final core = metric.extractPath(
        metric.length * walkedHead,
        metric.length * coreHead,
      );
      canvas.drawPath(
        core,
        Paint()
          ..color = _blueDeep.withValues(alpha: .90 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7 * unit
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(
        core,
        Paint()
          ..color = _blue.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4 * unit
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  void _drawUserDot(
    Canvas canvas,
    Offset point, {
    required double opacity,
    required double pulse,
    double scale = 1,
  }) {
    if (opacity <= 0) return;
    canvas.drawCircle(
      point,
      (17 + pulse * 4) * scale,
      Paint()..color = _blue.withValues(alpha: .10 * opacity),
    );
    canvas.drawCircle(
      point,
      10 * scale,
      Paint()..color = Colors.white.withValues(alpha: opacity),
    );
    canvas.drawCircle(
      point,
      6.5 * scale,
      Paint()..color = _blue.withValues(alpha: opacity),
    );
  }

  void _drawOpeningUserDot(
    Canvas canvas,
    Offset point, {
    required double opacity,
    required double bloom,
    required double cameraScale,
    required int timelineTimeMs,
  }) {
    if (opacity <= 0) return;
    // 줌아웃 동안 화면상 반지름을 16.5 → 6.5px로 줄인다. 마지막 크기를 일반
    // 폰 지도 마커와 같게 맞춰 폰 프레임 등장 순간의 크기 점프를 없앤다.
    final zoomProgress = _travel(interval(timelineTimeMs, 2600, 7200));
    final screenScale = mix(16.5 / 6.5, 1, zoomProgress);
    final unit = screenScale / cameraScale;
    final glowStrength = opacity * bloom;
    final glowRadius = (21 + bloom * 9) * unit;
    if (glowStrength > 0) {
      canvas.drawCircle(
        point,
        glowRadius,
        Paint()
          ..shader = ui.Gradient.radial(
            point,
            glowRadius,
            [
              _blue.withValues(alpha: .26 * glowStrength),
              _blue.withValues(alpha: .17 * glowStrength),
              const Color(0xFF8EBBFF).withValues(alpha: .075 * glowStrength),
              _blue.withValues(alpha: 0),
            ],
            const [.08, .34, .68, 1],
          ),
      );
    }
    canvas.drawCircle(
      point,
      10 * unit,
      Paint()..color = Colors.white.withValues(alpha: opacity),
    );
    canvas.drawCircle(
      point,
      6.5 * unit,
      Paint()..color = _blue.withValues(alpha: opacity),
    );
  }

  void _drawMarkerHeading(
    Canvas canvas,
    Offset point, {
    required double angle,
    required double opacity,
  }) {
    if (opacity <= 0) return;
    canvas.save();
    canvas.translate(point.dx, point.dy);
    canvas.rotate(angle);
    final heading = Path()
      ..moveTo(6, 0)
      ..quadraticBezierTo(14, -8, 23, -10)
      ..quadraticBezierTo(20, 0, 23, 10)
      ..quadraticBezierTo(14, 8, 6, 0)
      ..close();
    canvas.drawPath(
      heading,
      Paint()
        ..color = _blue.withValues(alpha: .14 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      heading,
      Paint()..color = _blue.withValues(alpha: .10 * opacity),
    );
    canvas.restore();
  }

  void _drawDestination(Canvas canvas, double reveal, double opacity) {
    final polygon = _pathFromPoints(
      promoDestinationPolygon.map(_floorToStage).toList(),
      close: true,
    );
    canvas.drawPath(
      polygon,
      Paint()
        ..color = const Color(
          0xFFE8F2FF,
        ).withValues(alpha: .52 * reveal * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13),
    );
    canvas.drawPath(
      polygon,
      Paint()
        ..color = _blue.withValues(alpha: .30 * reveal * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _drawScreenMarkers(
    Canvas canvas,
    Size size,
    _CameraState camera,
    double detailFocus,
    int timelineTimeMs,
  ) {
    final markerOpacity =
        _motion(timelineTimeMs, 180, 620, _premium) * (1 - detailFocus);
    if (markerOpacity <= 0) return;

    final walkingOnB1 =
        timelineTimeMs >= _approachWalkStartMs &&
        timelineTimeMs <= _indoorWalkEndMs;
    final walkingOnB2 = timelineTimeMs >= 21000 && timelineTimeMs <= 23200;
    final approachProgress = _unifiedEntryProgress(timelineTimeMs);
    final markerWorld = walkingOnB1
        ? _pointOnPath(_approachRoute, approachProgress)
        : walkingOnB2
        ? _pointOnPath(_arrivalRoute, _arrivalWalk(timelineTimeMs))
        : timelineTimeMs < _indoorWalkEndMs
        // 외부 도로를 따라 이동한 마커가 Blender 구간의 입구에서 이어진다.
        ? _pointOnPath(_approachRoute, approachProgress)
        : timelineTimeMs < 17400
        ? _entryRouteEnd
        : timelineTimeMs < 21000
        ? _arrivalTransfer
        : _destination;
    final floorSwap = _motion(timelineTimeMs, 17100, 18700, _travel);
    final b2Recenter = _motion(timelineTimeMs, 20000, 21000, _travel);
    final inFloorTransition =
        timelineTimeMs >= 16800 && timelineTimeMs <= 21000;
    final transitionMarkerY = timelineTimeMs < 20000
        ? mix(-80, 80, floorSwap)
        : mix(80, 0, b2Recenter);
    final screenPoint = inFloorTransition
        ? size.center(Offset(0, transitionMarkerY))
        : _worldToScreen(markerWorld, size, camera);
    if (timelineTimeMs >= _openingMapSettleMs) {
      if (walkingOnB1 || walkingOnB2) {
        final route = walkingOnB1 ? _approachRoute : _arrivalRoute;
        final progress = walkingOnB1
            ? approachProgress
            : _arrivalWalk(timelineTimeMs);
        _drawMarkerHeading(
          canvas,
          screenPoint,
          angle: _pathHeading(route, progress),
          opacity: markerOpacity,
        );
      }
      _drawUserDot(
        canvas,
        screenPoint,
        opacity:
            markerOpacity *
            (1 - _motion(timelineTimeMs, 23500, 24300, _premium)),
        pulse: math.max(
          _pulse(timelineTimeMs, 620, 280),
          _pulse(timelineTimeMs, 15050, 400),
        ),
      );
    }

    final destinationOpacity =
        _motion(timelineTimeMs, 23300, 24000, _premium) * (1 - detailFocus);
    if (destinationOpacity > 0) {
      final destinationPoint = _worldToScreen(_destination, size, camera);
      canvas.drawCircle(
        destinationPoint,
        11,
        Paint()..color = Colors.white.withValues(alpha: destinationOpacity),
      );
      canvas.drawCircle(
        destinationPoint,
        7,
        Paint()..color = _red.withValues(alpha: destinationOpacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WorldPainter oldDelegate) =>
      oldDelegate.timeMs != timeMs ||
      oldDelegate.zoomBoost != zoomBoost ||
      oldDelegate.routeIgnition != routeIgnition;
}

class _MobileViewportVeil extends StatelessWidget {
  const _MobileViewportVeil({required this.timeMs, this.fade = 1});

  final int timeMs;

  /// 구간 전환에서 모바일 UI 전체에 곱해지는 농도.
  final double fade;

  @override
  Widget build(BuildContext context) {
    // 앱 셸 조립 → 검색 → 상세 → 첫 길안내는 같은 폰 세션이다.
    final firstPhoneSession = _sceneOpacity(timeMs, 5100, 19000, 420, 520);
    // B2 경로가 그려지는 순간에 맞춰 폰 프레임도 다시 들어온다.
    final b2Guidance = _sceneOpacity(timeMs, 23000, 26800, 400, 420);
    final arrival = _sceneOpacity(timeMs, 26500, 31900, 420, 420);
    final opacity =
        math.max(firstPhoneSession, math.max(b2Guidance, arrival)) * fade;
    if (opacity <= 0) return const SizedBox.shrink();
    final hasLaterPhoneSession = math.max(b2Guidance, arrival) > 0;
    final disassembly = hasLaterPhoneSession
        ? 0.0
        : smooth(interval(timeMs, 18400, 19000));

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: const _PhoneOutsideClipper(),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                child: ColoredBox(color: Colors.white.withValues(alpha: .34)),
              ),
            ),
            Positioned(
              left: _phoneLeft,
              top: _phoneTop,
              width: _phoneWidth,
              height: _phoneHeight,
              child: Transform.scale(
                scaleX: mix(1, 1.025, disassembly),
                scaleY: mix(1, .99, disassembly),
                child: const CustomPaint(painter: _PhoneFramePainter()),
              ),
            ),
            Transform.translate(
              offset: Offset(0, -12 * disassembly),
              child: Stack(
                children: [
                  const Positioned(
                    left: _phoneLeft + 64,
                    top: _phoneTop + 20,
                    child: Text(
                      '9:41',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 17.5,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.3,
                      ),
                    ),
                  ),
                  Positioned(
                    left: _phoneLeft + (_phoneWidth - 110) / 2,
                    top: _phoneTop + 13,
                    width: 110,
                    height: 30,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF090B0E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  Positioned(
                    right: _stageSize.width - _phoneLeft - _phoneWidth + 38,
                    top: _phoneTop + 18,
                    child: const _DeviceStatusGlyphs(),
                  ),
                ],
              ),
            ),
            Positioned(
              left: _phoneLeft + (_phoneWidth - 160) / 2,
              top: _phoneTop + _phoneHeight - 16,
              width: 160,
              height: 6,
              child: Transform.translate(
                offset: Offset(0, 14 * disassembly),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF263342),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBarShellUi extends StatelessWidget {
  const _SearchBarShellUi({required this.timeMs, this.fade = 1});

  final int timeMs;
  final double fade;

  @override
  Widget build(BuildContext context) {
    final enter = _motion(timeMs, 5350, 5800, _premium);
    final exit = _motion(timeMs, 10200, 10850, _travel);
    final opacity = enter * (1 - exit) * fade;
    if (opacity <= 0) return const SizedBox.shrink();
    return Positioned(
      left: _mobileStageLeft,
      top: 92,
      width: _mobileStageWidth,
      height: 52,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, mix(18, 0, enter)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .94),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x203A6EA5),
                      blurRadius: 22,
                      offset: Offset(0, 8),
                    ),
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

class _AppShellUi extends StatelessWidget {
  const _AppShellUi({required this.timeMs, this.fade = 1});

  final int timeMs;
  final double fade;

  @override
  Widget build(BuildContext context) {
    final searchEnter = _motion(timeMs, 5350, 5800, _premium);
    final categoriesEnter = _motion(timeMs, 5500, 5850, _premium);
    final controlsEnter = _motion(timeMs, 5650, 5950, _premium);
    final tap = _pulse(timeMs, 6050, 360);
    final exit = _motion(timeMs, 6100, 6500, _travel);
    final opacity = (1 - exit) * fade;
    if (opacity <= 0) return const SizedBox.shrink();

    final phoneBottom = _stageSize.height - _phoneTop - _phoneHeight;
    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Stack(
          children: [
            Positioned(
              left: _mobileStageLeft,
              top: 92,
              width: _mobileStageWidth,
              height: 52,
              child: Opacity(
                opacity: searchEnter,
                child: Transform.translate(
                  offset: Offset(0, mix(18, 0, searchEnter) - exit * 8),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        const SizedBox.square(
                          dimension: 42,
                          child: Icon(
                            Icons.menu_rounded,
                            color: _muted,
                            size: 25,
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  '건물, 장소를 검색하세요',
                                  style: TextStyle(
                                    color: _muted,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: _TouchRing(progress: tap),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox.square(
                          dimension: 42,
                          child: Icon(
                            Icons.directions_rounded,
                            color: _blue,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: _mobileStageLeft,
              top: 154,
              width: _phoneLeft + _phoneWidth - _mobileStageLeft,
              child: Opacity(
                opacity: categoriesEnter,
                child: Transform.translate(
                  offset: Offset(0, mix(14, 0, categoriesEnter)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      children: [
                        _categoryChip(
                          '장소',
                          Icons.bookmark_border_rounded,
                          _blue,
                        ),
                        const SizedBox(width: 8),
                        _categoryChip(
                          '리빙',
                          Icons.chair_outlined,
                          const Color(0xFF009B89),
                        ),
                        const SizedBox(width: 8),
                        _categoryChip(
                          '뷰티',
                          Icons.brush_outlined,
                          const Color(0xFFF04452),
                        ),
                        const SizedBox(width: 8),
                        _categoryChip(
                          '서비스',
                          Icons.support_agent_rounded,
                          const Color(0xFF3157D5),
                        ),
                        const SizedBox(width: 8),
                        _categoryChip(
                          '식품관',
                          Icons.shopping_cart_outlined,
                          const Color(0xFF14A82F),
                        ),
                        const SizedBox(width: 8),
                        _categoryChip(
                          '음식점',
                          Icons.restaurant_rounded,
                          const Color(0xFFC9877E),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: _phoneLeft + 22,
              bottom: phoneBottom + 78,
              child: Opacity(
                opacity: controlsEnter,
                child: Transform.translate(
                  offset: Offset(mix(-18, 0, controlsEnter), 0),
                  child: Container(
                    width: 44,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .95),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x24000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _floorCell('3F', false),
                        _floorCell('2F', false),
                        _floorCell('1F', false),
                        _floorCell('B1', true),
                        _floorCell('B2', false),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: _stageSize.width - _phoneLeft - _phoneWidth + 22,
              bottom: phoneBottom + 78,
              child: Opacity(
                opacity: controlsEnter,
                child: Transform.translate(
                  offset: Offset(mix(18, 0, controlsEnter), 0),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x24000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: _blue,
                      size: 21,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _floorCell(String label, bool selected) => Container(
    width: 36,
    height: 34,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: selected ? _blue : Colors.transparent,
      borderRadius: BorderRadius.circular(17),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: selected ? Colors.white : _ink.withValues(alpha: .55),
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _categoryChip(String label, IconData icon, Color color) => Container(
    height: 32,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: _ink,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -.35,
          ),
        ),
      ],
    ),
  );
}

class _DeviceStatusGlyphs extends StatelessWidget {
  const _DeviceStatusGlyphs();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 84,
    height: 20,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: 1,
          width: 19,
          height: 16,
          child: CustomPaint(painter: _CellularSignalPainter()),
        ),
        Positioned(
          left: 25,
          top: 1.25,
          width: 21,
          height: 20,
          child: Center(
            child: Text(
              '5G',
              style: TextStyle(
                color: _ink,
                fontSize: 14.5,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: -.6,
              ),
            ),
          ),
        ),
        Positioned(
          left: 54,
          top: -2.5,
          width: 25,
          height: 20,
          child: Center(
            child: Icon(CupertinoIcons.battery_100, size: 26, color: _ink),
          ),
        ),
      ],
    ),
  );
}

class _CellularSignalPainter extends CustomPainter {
  const _CellularSignalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _ink
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var index = 0; index < 4; index++) {
      final height = 4.0 + index * 3.1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(index * 4.6, size.height - height, 3.1, height),
          const Radius.circular(1),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CellularSignalPainter oldDelegate) => false;
}

class _PhoneOutsideClipper extends CustomClipper<Path> {
  const _PhoneOutsideClipper();

  @override
  Path getClip(Size size) => Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(Offset.zero & size)
    ..addRSuperellipse(
      ui.RSuperellipse.fromRectAndRadius(
        const Rect.fromLTWH(_phoneLeft, _phoneTop, _phoneWidth, _phoneHeight),
        const Radius.circular(_phoneRadius),
      ),
    );

  @override
  bool shouldReclip(covariant _PhoneOutsideClipper oldClipper) => false;
}

class _PhoneFramePainter extends CustomPainter {
  const _PhoneFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final shape = ui.RSuperellipse.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(_phoneRadius),
    );
    final path = Path()..addRSuperellipse(shape);
    canvas.drawShadow(
      path.shift(const Offset(0, 8)),
      const Color(0x183A5C80),
      24,
      false,
    );
    canvas.drawRSuperellipse(
      shape,
      Paint()
        ..color = const Color(0xFF9EACBC).withValues(alpha: .42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15,
    );
  }

  @override
  bool shouldRepaint(covariant _PhoneFramePainter oldDelegate) => false;
}

class _SearchUi extends StatelessWidget {
  const _SearchUi({required this.timeMs, this.fade = 1});

  final int timeMs;
  final double fade;

  @override
  Widget build(BuildContext context) {
    final enter = _motion(timeMs, 3000, 3820, _premium);
    final exit = _motion(timeMs, 7100, 7750, _travel);
    final opacity = enter * (1 - exit) * fade;
    if (opacity <= 0) return const SizedBox.shrink();

    final text = _typedSearchQuery(timeMs);
    return Positioned(
      left: _mobileStageLeft,
      top: 92,
      width: _mobileStageWidth,
      height: 52,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(mix(18, 0, enter), mix(7, 0, enter)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Transform.scale(
                  scale: mix(.78, 1, enter),
                  child: const _LineIcon(
                    kind: _LineIconKind.search,
                    size: 24,
                    color: _blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text.isEmpty ? '어디로 갈까요?' : text,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                      color: text.isEmpty ? _muted : _ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResultsUi extends StatelessWidget {
  const _SearchResultsUi({required this.timeMs, this.fade = 1});

  final int timeMs;
  final double fade;

  @override
  Widget build(BuildContext context) {
    final enter = _motion(timeMs, 5350, 6100, _premium);
    final exit = _motion(timeMs, 7100, 7750, _travel);
    final opacity = enter * (1 - exit) * fade;
    if (opacity <= 0) return const SizedBox.shrink();
    final tap = _pulse(timeMs, 6950, 300);
    return Positioned(
      left: _mobileStageLeft,
      top: 150,
      width: _mobileStageWidth,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, mix(24, 0, enter)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: 64,
                padding: const EdgeInsets.fromLTRB(15, 7, 9, 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .90),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1C3A6EA5),
                      blurRadius: 22,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const _SimplePinIcon(color: _red, size: 22),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promoDestinationName,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            promoDestinationSubtitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox.square(
                      dimension: 34,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _TouchRing(progress: tap),
                          const _LineIcon(
                            kind: _LineIconKind.chevron,
                            color: _blue,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
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

class _TouchRing extends StatelessWidget {
  const _TouchRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) return const SizedBox.shrink();
    return Opacity(
      opacity: math.min(1, progress * 1.7),
      child: Transform.scale(
        scale: mix(.72, 1, progress),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: .20),
            border: Border.all(
              color: Colors.white.withValues(alpha: .64),
              width: 1.7,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x290B2444), blurRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyboardUi extends StatelessWidget {
  const _KeyboardUi({required this.timeMs, this.fade = 1});

  final int timeMs;
  final double fade;

  static const _rows = <List<String>>[
    ['ㅂ', 'ㅈ', 'ㄷ', 'ㄱ', 'ㅅ', 'ㅛ', 'ㅕ', 'ㅑ', 'ㅐ', 'ㅔ'],
    ['ㅁ', 'ㄴ', 'ㅇ', 'ㄹ', 'ㅎ', 'ㅗ', 'ㅓ', 'ㅏ', 'ㅣ'],
    ['⇧', 'ㅋ', 'ㅌ', 'ㅊ', 'ㅍ', 'ㅠ', 'ㅜ', 'ㅡ', '⌫'],
  ];
  @override
  Widget build(BuildContext context) {
    final enter = _motion(timeMs, 3520, 4070, _premium);
    final exit = _motion(timeMs, 5150, 5650, _travel);
    final opacity = enter * (1 - exit) * fade;
    if (opacity <= 0) return const SizedBox.shrink();
    final activeKey = _activeTypingKey(timeMs);
    final press = _typingKeyPress(timeMs);

    return Positioned(
      left: _phoneLeft,
      bottom: _stageSize.height - _phoneTop - _phoneHeight,
      width: _phoneWidth,
      height: 330,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, mix(330, 0, enter) + exit * 330),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(_phoneRadius),
              bottomRight: Radius.circular(_phoneRadius),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD9DEE5).withValues(alpha: .98),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 36,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _KeyboardSuggestion('카멜'),
                        _KeyboardSuggestionDivider(),
                        _KeyboardSuggestion('카멜커피'),
                        _KeyboardSuggestionDivider(),
                        _KeyboardSuggestion('커피'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      for (final key in _rows[0])
                        _KeyboardKey(
                          label: key,
                          active: key == activeKey,
                          press: key == activeKey ? press : 0,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        for (final key in _rows[1])
                          _KeyboardKey(
                            label: key,
                            active: key == activeKey,
                            press: key == activeKey ? press : 0,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const _KeyboardKey(
                        label: 'shift',
                        icon: Icons.arrow_upward_rounded,
                        flex: 14,
                        functional: true,
                      ),
                      for (final key in _rows[2].skip(1).take(7))
                        _KeyboardKey(
                          label: key,
                          active: key == activeKey,
                          press: key == activeKey ? press : 0,
                          flex: 10,
                        ),
                      const _KeyboardKey(
                        label: 'delete',
                        icon: Icons.backspace_outlined,
                        flex: 14,
                        functional: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const _KeyboardKey(
                        label: '123',
                        flex: 14,
                        functional: true,
                      ),
                      const _KeyboardKey(
                        label: 'language',
                        icon: Icons.language_rounded,
                        flex: 10,
                        functional: true,
                      ),
                      _KeyboardKey(
                        label: 'space',
                        displayLabel: '간격',
                        active: activeKey == 'space',
                        press: activeKey == 'space' ? press : 0,
                        flex: 43,
                      ),
                      const _KeyboardKey(
                        label: 'mic',
                        icon: Icons.mic_none_rounded,
                        flex: 10,
                        functional: true,
                      ),
                      const _KeyboardKey(
                        label: 'search',
                        displayLabel: '검색',
                        flex: 18,
                        blue: true,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 160,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF263342),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyboardSuggestion extends StatelessWidget {
  const _KeyboardSuggestion(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Center(
      child: Transform.translate(
        offset: const Offset(0, 2.5),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF344255),
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none,
            height: 1.1,
          ),
        ),
      ),
    ),
  );
}

class _KeyboardSuggestionDivider extends StatelessWidget {
  const _KeyboardSuggestionDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 18,
    color: const Color(0xFFB4BBC5).withValues(alpha: .58),
  );
}

class _KeyboardKey extends StatelessWidget {
  const _KeyboardKey({
    required this.label,
    this.displayLabel,
    this.icon,
    this.active = false,
    this.press = 0,
    this.flex = 10,
    this.functional = false,
    this.blue = false,
  });

  final String label;
  final String? displayLabel;
  final IconData? icon;
  final bool active;
  final double press;
  final int flex;
  final bool functional;
  final bool blue;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: AnimatedContainer(
        duration: Duration.zero,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: blue
              ? _blue
              : active
              ? Color.lerp(Colors.white, const Color(0xFFB8D2F3), press)
              : (functional ? const Color(0xFFB9C1CB) : Colors.white),
          borderRadius: BorderRadius.circular(7),
          boxShadow: const [
            BoxShadow(
              color: Color(0x350E1B2A),
              offset: Offset(0, 1.5),
              blurRadius: 1,
            ),
          ],
        ),
        child: icon != null
            ? Icon(icon, color: blue ? Colors.white : _ink, size: 22)
            : Text(
                displayLabel ?? label,
                style: TextStyle(
                  color: blue ? Colors.white : _ink,
                  fontSize: label.length > 1 ? 14 : 21,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}

enum _LineIconKind { search, chevron, turnRight, straight }

class _SimplePinIcon extends StatelessWidget {
  const _SimplePinIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _SimplePinPainter(color)),
  );
}

class _SimplePinPainter extends CustomPainter {
  const _SimplePinPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * .5, h * .96)
      ..cubicTo(w * .42, h * .82, w * .20, h * .59, w * .20, h * .38)
      ..cubicTo(w * .20, h * .15, w * .33, h * .04, w * .5, h * .04)
      ..cubicTo(w * .67, h * .04, w * .80, h * .15, w * .80, h * .38)
      ..cubicTo(w * .80, h * .59, w * .58, h * .82, w * .5, h * .96)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(
      Offset(w * .5, h * .36),
      w * .115,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _SimplePinPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _LineIcon extends StatelessWidget {
  const _LineIcon({
    required this.kind,
    required this.size,
    required this.color,
  });

  final _LineIconKind kind;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _LineIconPainter(kind, color)),
  );
}

class _LineIconPainter extends CustomPainter {
  const _LineIconPainter(this.kind, this.color);

  final _LineIconKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide;
    final stroke = math.max(2.2, scale * .075);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (kind) {
      case _LineIconKind.search:
        canvas.drawCircle(Offset(scale * .43, scale * .43), scale * .25, paint);
        canvas.drawLine(
          Offset(scale * .61, scale * .61),
          Offset(scale * .84, scale * .84),
          paint,
        );
      case _LineIconKind.chevron:
        canvas.drawLine(
          Offset(scale * .28, scale * .5),
          Offset(scale * .76, scale * .5),
          paint,
        );
        canvas.drawLine(
          Offset(scale * .58, scale * .30),
          Offset(scale * .78, scale * .5),
          paint,
        );
        canvas.drawLine(
          Offset(scale * .78, scale * .5),
          Offset(scale * .58, scale * .70),
          paint,
        );
      case _LineIconKind.turnRight:
        final path = Path()
          ..moveTo(scale * .25, scale * .78)
          ..lineTo(scale * .25, scale * .52)
          ..quadraticBezierTo(
            scale * .25,
            scale * .30,
            scale * .48,
            scale * .30,
          )
          ..lineTo(scale * .78, scale * .30);
        canvas.drawPath(path, paint);
        canvas.drawLine(
          Offset(scale * .62, scale * .15),
          Offset(scale * .79, scale * .30),
          paint,
        );
        canvas.drawLine(
          Offset(scale * .79, scale * .30),
          Offset(scale * .62, scale * .45),
          paint,
        );
      case _LineIconKind.straight:
        canvas.drawLine(
          Offset(scale * .5, scale * .82),
          Offset(scale * .5, scale * .18),
          paint,
        );
        canvas.drawLine(
          Offset(scale * .33, scale * .35),
          Offset(scale * .5, scale * .18),
          paint,
        );
        canvas.drawLine(
          Offset(scale * .5, scale * .18),
          Offset(scale * .67, scale * .35),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _LineIconPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.color != color;
}

class _GuidanceUi extends StatelessWidget {
  const _GuidanceUi({required this.timeMs, this.fade = 1});

  final int timeMs;
  final double fade;

  @override
  Widget build(BuildContext context) {
    final entryLeg = _sceneOpacity(timeMs, 11800, 15900, 520, 420);
    final arrivalLeg = _sceneOpacity(timeMs, 21000, 23700, 420, 360);
    final reveal = math.max(entryLeg, arrivalLeg);
    final opacity = reveal * fade;
    if (opacity <= 0) return const SizedBox.shrink();
    final onEntryFloor = entryLeg >= arrivalLeg;
    final disassembly = onEntryFloor
        ? smooth(interval(timeMs, 15300, 15900))
        : 0.0;
    final progress = onEntryFloor ? _entryWalk(timeMs) : _arrivalWalk(timeMs);
    final legMeters = onEntryFloor ? _entryRouteMeters : _arrivalRouteMeters;
    final meters = math.max(2, (legMeters * (1 - progress)).round());
    final instruction = onEntryFloor
        ? (progress < .46
              ? '오른쪽 통로로 이동'
              : timeMs < 14800
              ? '에스컬레이터로 내려가기'
              : '에스컬레이터 탑승 · $promoArrivalFloorName 이동 중')
        : (progress < .54 ? '통로를 따라 직진' : '오른쪽에 목적지');
    final iconKind = onEntryFloor
        ? (progress < .46 ? _LineIconKind.turnRight : _LineIconKind.straight)
        : (progress < .54 ? _LineIconKind.straight : _LineIconKind.turnRight);
    return Positioned(
      left: _mobileStageLeft,
      right: _mobileStageLeft,
      bottom: 74,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, mix(20, 0, reveal) + 24 * disassembly),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .88),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F31679B),
                  blurRadius: 20,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _LineIcon(kind: iconKind, size: 28, color: _blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    instruction,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  onEntryFloor && timeMs >= 14800
                      ? promoArrivalFloorName
                      : '$meters m',
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FloorTransitionUi extends StatelessWidget {
  const _FloorTransitionUi({required this.timeMs, this.fade = 1});

  final int timeMs;
  final double fade;

  @override
  Widget build(BuildContext context) {
    final enter = _motion(timeMs, 16800, 17100, _premium);
    final exit = _motion(timeMs, 20000, 20800, _premium);
    final opacity = enter * (1 - exit) * fade;
    if (opacity <= 0) return const SizedBox.shrink();
    final swap = _motion(timeMs, 17100, 18700, _travel);
    final markerY = mix(90, 250, swap);
    final labelsOpacity = 1 - _motion(timeMs, 18300, 18950, _premium);
    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Center(
          child: Transform.translate(
            offset: Offset.zero,
            child: SizedBox(
              width: 220,
              height: 340,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: labelsOpacity,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 4,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: _floorText(promoEntryFloorName, 1 - swap),
                            ),
                          ),
                          Positioned(
                            top: 90,
                            left: 108.5,
                            child: Container(
                              width: 3,
                              height: math.max(0, markerY - 102),
                              decoration: BoxDecoration(
                                color: _line.withValues(alpha: .78),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Positioned(
                            top: markerY + 12,
                            left: 108.5,
                            child: Container(
                              width: 3,
                              height: math.max(0, 238 - markerY),
                              decoration: BoxDecoration(
                                color: _line.withValues(alpha: .78),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: _floorText(promoArrivalFloorName, swap),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _floorText(String text, double selected) => Text(
    text,
    style: TextStyle(
      fontSize: mix(26, 42, selected),
      fontWeight: FontWeight.w800,
      color: Color.lerp(_muted.withValues(alpha: .42), _blue, selected),
    ),
  );
}

class _PlacePreviewUi extends StatelessWidget {
  const _PlacePreviewUi({required this.timeMs, this.fade = 1});

  final int timeMs;
  final double fade;

  @override
  Widget build(BuildContext context) {
    final enter = _motion(timeMs, 7150, 8000, _premium);
    final content = _motion(timeMs, 7520, 8360, _premium);
    final actions = _motion(timeMs, 7900, 8620, _premium);
    final press = _pulse(timeMs, 10100, 420);
    final exit = _motion(timeMs, 10250, 11050, _travel);
    final opacity = enter * (1 - exit) * fade;
    if (opacity <= 0) return const SizedBox.shrink();
    final sheetHeight = _hasPlaceDetail ? 520.0 : 262.0;
    return Positioned(
      left: _phoneLeft,
      width: _phoneWidth,
      height: sheetHeight,
      bottom: _stageSize.height - _phoneTop - _phoneHeight,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, mix(sheetHeight + 40, 0, enter) + exit * 620),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(38),
              bottom: Radius.circular(_phoneRadius),
            ),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .94),
                  border: Border.all(color: Colors.white, width: 1.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                    bottom: Radius.circular(_phoneRadius),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26345D88),
                      blurRadius: 36,
                      offset: Offset(0, -9),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _line.withValues(alpha: .82),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Opacity(
                      opacity: content,
                      child: Row(
                        children: [
                          const SizedBox.square(
                            dimension: 40,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: _muted,
                              size: 22,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox.square(
                            dimension: 40,
                            child: Icon(
                              Icons.bookmark_border_rounded,
                              color: _muted,
                              size: 22,
                            ),
                          ),
                          const SizedBox.square(
                            dimension: 40,
                            child: Icon(
                              Icons.close_rounded,
                              color: _muted,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Opacity(
                      opacity: content,
                      child: Transform.translate(
                        offset: Offset(0, mix(14, 0, content)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _blue.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.local_cafe_outlined,
                                color: _blue,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    promoDestinationName,
                                    style: TextStyle(
                                      color: _ink,
                                      fontSize: 20,
                                      height: 1.15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: promoArrivalFloorName,
                                          style: const TextStyle(
                                            color: _blue,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' · $promoDestinationCategory',
                                          style: const TextStyle(color: _muted),
                                        ),
                                      ],
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Opacity(
                      opacity: actions,
                      child: Transform.translate(
                        offset: Offset(0, mix(18, 0, actions)),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 94,
                              child: Container(
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF3FF),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  '출발',
                                  style: TextStyle(
                                    color: _blue,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 94,
                              child: Container(
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _blue,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    const Center(
                                      child: Text(
                                        '도착',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 5,
                                      top: 1,
                                      child: _TouchRing(progress: press),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 큐레이션된 소개 문구와 사진이 있는 장소에서만 아래 블록이
                    // 붙는다. 없는 매장은 실제 앱처럼 짧은 시트로 끝난다.
                    if (_hasPlaceDetail) ...[
                      const SizedBox(height: 20),
                      Opacity(
                        opacity: content,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '소개',
                              style: TextStyle(
                                color: _ink,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              promoDestinationSummary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _ink,
                                fontSize: 14,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (promoDestinationHeroAssets.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 116,
                                  child: Image.asset(
                                    promoDestinationHeroAssets.first,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ],
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

class _ArrivalUi extends StatelessWidget {
  const _ArrivalUi({required this.timeMs, this.fade = 1});

  final int timeMs;
  final double fade;

  @override
  Widget build(BuildContext context) {
    final enter = _motion(timeMs, 23400, 24000, _premium);
    final exit = _motion(timeMs, 28200, 28900, _premium);
    final check = _motion(timeMs, 23700, 24100, _premium);
    final accent = _pulse(timeMs, 24100, 520);
    final opacity = enter * (1 - exit) * fade;
    if (opacity <= 0) return const SizedBox.shrink();
    return Positioned(
      left: _mobileStageLeft,
      bottom: 74,
      width: _mobileStageWidth,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, mix(26, 0, enter)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: 84,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Row(
                  children: [
                    const _SimplePinIcon(size: 25, color: _red),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            promoDestinationName,
                            style: TextStyle(
                              color: _ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$promoArrivalFloorName · 목적지에 도착했습니다',
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox.square(
                      dimension: 36,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: accent * .42,
                            child: Transform.scale(
                              scale: mix(.7, 1.35, accent),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _blue.withValues(alpha: .55),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: mix(.35, 1, check) * (1 + accent * .12),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: _blue,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _FinishPainter extends CustomPainter {
  const _FinishPainter(this.timeMs);

  final int timeMs;

  @override
  void paint(Canvas canvas, Size size) {
    final fade = _motion(timeMs, 28300, 29000, _travel);
    if (fade <= 0) return;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.white.withValues(alpha: fade),
    );
  }

  @override
  bool shouldRepaint(covariant _FinishPainter oldDelegate) =>
      oldDelegate.timeMs != timeMs;
}

class _CameraState {
  const _CameraState(this.focus, this.scale);

  final Offset focus;
  final double scale;
}

class _CameraKey {
  const _CameraKey(this.timeMs, this.focus, this.scale);

  final int timeMs;
  final Offset focus;
  final double scale;
}

_CameraState _cameraAt(int timeMs) {
  if (timeMs < _openingMapSettleMs) {
    // 외부 도로의 내 위치에 붙어 있다가 가상 도시 전체로 물러난다.
    // 큰 배율은 선형 보간하면 초반이 늘어지므로 로그 배율에 travel 곡선을 쓴다.
    final openingZoom = _travel(interval(timeMs, 2600, 7200));
    final openingScale = math.exp(
      mix(
        math.log(_outdoorNearScale),
        math.log(_outdoorWideScale),
        openingZoom,
      ),
    );
    return _CameraState(
      Offset.lerp(_outdoorStand, _outdoorFocus, openingZoom)!,
      openingScale,
    );
  }
  final keys = <_CameraKey>[
    _CameraKey(_openingMapSettleMs, _outdoorFocus, _outdoorWideScale),
    _CameraKey(7800, _outdoorFocus, _outdoorWideScale),
    _CameraKey(10100, _outdoorFocus, _outdoorWideScale),
    _CameraKey(_approachWalkStartMs, _outdoorFocus, _outdoorWideScale),
    _CameraKey(_entryPauseStartMs, _outdoorEntry, _outdoorWideScale),
    // 입구에 도착한 뒤 마커와 경로를 멈추고 실내 쪽으로 먼저 확대한다.
    _CameraKey(_entryZoomEndMs, _entryStart, _indoorEntryScale),
    _CameraKey(_indoorWalkStartMs, _entryStart, _indoorEntryScale),
    _CameraKey(_indoorWalkEndMs, _entryRouteEnd, _indoorWalkScale),
    _CameraKey(15700, _entryRouteEnd, _indoorWalkScale),
    _CameraKey(16800, _entryTransitionCameraFocus, 1.42),
    _CameraKey(17300, _floorTransitionOverview, 1.42),
    _CameraKey(20000, _arrivalTransitionCameraFocus, 3.45),
    _CameraKey(21000, _arrivalTransfer, 3.45),
    _CameraKey(23200, _destination, 3.70),
    _CameraKey(25500, _destination, 3.70),
    _CameraKey(26700, _destination, 4.22),
    _CameraKey(28500, _destination, 4.22),
  ];
  if (timeMs <= keys.first.timeMs) {
    return _CameraState(keys.first.focus, keys.first.scale);
  }
  for (var index = 0; index < keys.length - 1; index++) {
    final from = keys[index];
    final to = keys[index + 1];
    if (timeMs <= to.timeMs) {
      final t = _travel(interval(timeMs, from.timeMs, to.timeMs));
      var focus = Offset.lerp(from.focus, to.focus, t)!;
      if (timeMs >= _approachWalkStartMs && timeMs <= _entryPauseStartMs) {
        focus = _pointOnPath(_approachRoute, _unifiedEntryProgress(timeMs));
      } else if (timeMs >= _indoorWalkStartMs && timeMs <= _indoorWalkEndMs) {
        focus = _indoorWalkingCameraFocus(_unifiedEntryProgress(timeMs));
      } else if (timeMs >= 21000 && timeMs <= 24000) {
        focus = _walkingCameraFocus(_arrivalRoute, _arrivalWalk(timeMs));
      }
      return _CameraState(focus, mix(from.scale, to.scale, t));
    }
  }
  return _CameraState(keys.last.focus, keys.last.scale);
}

double _entryWalk(int timeMs) {
  final unified = _unifiedEntryProgress(timeMs);
  return clamp01(
    (unified - _outdoorRouteFraction) / (1 - _outdoorRouteFraction),
  );
}

double _unifiedEntryProgress(int timeMs) {
  if (timeMs <= _entryPauseStartMs) {
    return _outdoorRouteFraction *
        _routeTravel(
          interval(timeMs, _approachWalkStartMs, _entryPauseStartMs),
        );
  }
  if (timeMs <= _indoorWalkStartMs) return _outdoorRouteFraction;
  return mix(
    _outdoorRouteFraction,
    1,
    _routeTravel(interval(timeMs, _indoorWalkStartMs, _indoorWalkEndMs)),
  );
}

/// 경로 선두는 마커 이동과 독립적으로 먼저 전진한다. 입구에서 정확히 멈춰
/// 확대를 기다린 다음, 동일한 Path의 남은 실내 구간을 계속 생성한다.
double _unifiedEntryReveal(int timeMs) {
  if (timeMs <= _entryPauseStartMs) {
    return _outdoorRouteFraction *
        _routeRevealTravel(
          interval(timeMs, _approachStartMs, _outdoorRouteRevealEndMs),
        );
  }
  if (timeMs <= _indoorRouteRevealStartMs) return _outdoorRouteFraction;
  return mix(
    _outdoorRouteFraction,
    1,
    _routeRevealTravel(
      interval(timeMs, _indoorRouteRevealStartMs, _indoorRouteRevealEndMs),
    ),
  );
}

double _arrivalWalk(int timeMs) {
  return _routeTravel(interval(timeMs, 21000, 23200));
}

Offset _walkingCameraFocus(Path path, double progress) {
  // 출발·도착에서는 마커와 다시 합쳐지고, 이동 중에만 진행 방향을 조금
  // 먼저 보여준다. 카메라와 마커가 한 점에 고정돼 지도가 미끄러지는 느낌을 없앤다.
  final lookAhead = .042 * math.sin(math.pi * clamp01(progress));
  return _pointOnPath(path, clamp01(progress + lookAhead));
}

Offset _indoorWalkingCameraFocus(double unifiedProgress) {
  final indoorProgress = clamp01(
    (unifiedProgress - _outdoorRouteFraction) / (1 - _outdoorRouteFraction),
  );
  // 실내 추적 첫 프레임의 선행 거리는 0이다. 이동하면서만 부드럽게
  // 늘었다 줄어들어 고정 카메라에서 추적 카메라로 바뀔 때 튀지 않는다.
  final lookAhead =
      (1 - _outdoorRouteFraction) * .055 * math.sin(math.pi * indoorProgress);
  return _pointOnPath(_approachRoute, clamp01(unifiedProgress + lookAhead));
}

/// 대부분의 구간을 일정 속도로 통과하고 양 끝에만 짧은 완충을 둔다.
/// 기존의 강한 ease-out 때문에 생기던 마지막 '미끄러짐'을 제거한다.
double _routeTravel(double value) => _cubicBezier(value, .12, 0, .88, 1);

/// 경로 선두는 잠깐 힘을 모은 뒤 빠르게 뻗고 끝에서 부드럽게 감속한다.
double _routeRevealTravel(double value) => _cubicBezier(value, .55, 0, .62, 1);

/// 진입 층 경로는 지상 출입구에서 시작한다. 촬영을 위해 중간부터 자르지 않는다.
final List<Offset> _entryRoutePoints = promoEntryRoute
    .map(_floorToStage)
    .toList();
final Path _entryRoute = _pathFromPoints(_entryRoutePoints);
final Path _arrivalRoute = _pathFromPoints(
  [...promoArrivalRoute, promoDestinationPoint].map(_floorToStage).toList(),
);
final Offset _entryStart = _floorToStage(promoEntrancePoint);
final Offset _entryRouteEnd = _pointOnPath(_entryRoute, 1);
final Offset _arrivalTransfer = _floorToStage(promoArrivalTransferPoint);
final Offset _destination = _floorToStage(promoDestinationPoint);
final List<Offset> _entryFootprint = promoEntryFootprint
    .map(_floorToStage)
    .toList();
final List<Offset> _arrivalFootprint = promoArrivalFootprint
    .map(_floorToStage)
    .toList();
final List<Offset> _buildingFootprint = promoBuildingFootprintLocal
    .map(_floorToStage)
    .toList();
final List<Offset> _outdoorBuildingFootprint = _scaleFootprint(
  _buildingFootprint,
  1,
);
final Offset _outdoorEntry = _nearestPointOnFootprint(
  _entryStart,
  _buildingFootprint,
);

/// 안내 카드에 쓰는 실제 구간 거리. 무대 좌표에서 되돌려 계산한다.
final double _entryRouteMeters =
    _entryRoute.computeMetrics().first.length / _stagePerMeter;
final double _arrivalRouteMeters =
    _arrivalRoute.computeMetrics().first.length / _stagePerMeter;

/// 더현대에서 한 블록 이상 떨어진 남동측 교차로. 검색 구간은 이 마커를
/// 중심으로 시작하며, 줌아웃 뒤에야 3×2 블록 규모의 목적지가 함께 들어온다.
const Offset _outdoorStand = Offset(2480, 1510);

/// 실외 카메라는 건물 하나를 꽉 채우지 않고 도시의 도로망과 여러 블록을
/// 함께 보여준다. 더현대 외곽선도 이 시점에는 주변 블록과 같은 시각 언어다.
const Offset _outdoorFocus = _outdoorStand;
const _outdoorNearScale = 2.60;
const _outdoorWideScale = .62;

/// `길찾기` 선택 직후 외부 출발점에서 더현대 입구로 이어지는 도시 경로.
/// 마지막 부분은 Blender 실외 경로가 자연스럽게 이어받을 수 있게 입구에서 끝난다.
const _approachStartMs = 10080;
const _outdoorRouteRevealEndMs = 10850;
const _approachWalkStartMs = 10600;
const _entryPauseStartMs = 11700;
const _entryZoomEndMs = 12450;
// 실내 폴리곤이 먼저 자리를 잡은 다음 그 위로 경로가 뻗는다. 경로가 절반
// 이상 확보된 뒤에만 마커를 출발시켜 맨땅 위에 선부터 생기는 인상을 없앤다.
const _indoorRouteRevealStartMs = 13050;
const _indoorRouteRevealEndMs = 14700;
const _indoorWalkStartMs = 13950;
const _indoorWalkEndMs = 15300;
const _indoorEntryScale = 2.08;
const _indoorWalkScale = 2.24;
const _floorDisassemblyStartMs = 15300;
const _floorDisassemblyEndMs = 16800;
const _floorOutlineExitStartMs = 15700;
const _floorTransitionStartMs = 16800;
final Path _approachRoute = _pathFromPoints([
  _outdoorStand,
  const Offset(1900, 1510),
  const Offset(1900, 1050),
  const Offset(1600, 1050),
  const Offset(1600, 760),
  _outdoorEntry,
  _entryStart,
  ..._entryRoutePoints.skip(1),
]);
// 외부 구간의 끝은 벽 위가 아니라 출입구를 통과한 직후의 실내 시작점이다.
// 여기까지 이동한 뒤 확대하므로 마커가 벽에 걸린 채 장면이 바뀌지 않는다.
final double _outdoorRouteFraction = _pathFractionAtPoint(
  _approachRoute,
  _entryStart,
);

/// 입구 도착과 확대가 끝난 다음에만 실내 폴리곤 조립을 시작한다.
double _indoorHandover(int timelineTimeMs) =>
    smooth(interval(timelineTimeMs, _entryZoomEndMs, 14350));
final Offset _floorTransitionOverview = Offset.lerp(
  _entryRouteEnd,
  _arrivalTransfer,
  .5,
)!;
final Offset _entryTransitionCameraFocus =
    _entryRouteEnd + const Offset(0, 80 / 1.42);
final Offset _arrivalTransitionCameraFocus =
    _arrivalTransfer - const Offset(0, 80 / 3.45);
final List<_MapShape> _entryShapes = _mapShapes(promoEntryStorePolygons);
final List<_MapShape> _arrivalShapes = _mapShapes(promoArrivalStorePolygons);

class _MapShape {
  const _MapShape(this.path, this.bounds);

  final Path path;
  final Rect bounds;
}

/// 여의도 실지도에서 읽히는 더현대·파크원·IFC·동측 아파트군의 상대 배치를
/// 촬영용 무대 좌표로 단순화한다. 모든 윤곽은 실내 지도와 같은 각진 언어를 쓴다.
class _CityBlock {
  factory _CityBlock(List<Offset> footprint, Color tone) {
    final path = _pathFromPoints(footprint, close: true);
    return _CityBlock._(path, path.getBounds(), tone);
  }

  const _CityBlock._(this.path, this.bounds, this.tone);

  final Path path;
  final Rect bounds;
  final Color tone;
}

const _cityAssemblyOrigin = _outdoorStand;

List<Offset> _rectFootprint(
  double left,
  double top,
  double width,
  double height,
) => [
  Offset(left, top),
  Offset(left + width, top),
  Offset(left + width, top + height),
  Offset(left, top + height),
];

List<Offset> _scaleFootprint(List<Offset> points, double factor) {
  final bounds = _pathFromPoints(points, close: true).getBounds();
  final center = bounds.center;
  return [for (final point in points) center + (point - center) * factor];
}

Offset _nearestPointOnFootprint(Offset point, List<Offset> footprint) {
  var nearest = footprint.first;
  var nearestDistance = double.infinity;
  for (var index = 0; index < footprint.length; index++) {
    final start = footprint[index];
    final end = footprint[(index + 1) % footprint.length];
    final segment = end - start;
    final lengthSquared = segment.distanceSquared;
    final t = lengthSquared == 0
        ? 0.0
        : clamp01(
            ((point - start).dx * segment.dx +
                    (point - start).dy * segment.dy) /
                lengthSquared,
          );
    final candidate = start + segment * t;
    final distance = (candidate - point).distanceSquared;
    if (distance < nearestDistance) {
      nearest = candidate;
      nearestDistance = distance;
    }
  }
  return nearest;
}

double _pathFractionAtPoint(Path path, Offset point) {
  final metric = path.computeMetrics().first;
  var nearestOffset = 0.0;
  var nearestDistance = double.infinity;
  const samples = 500;
  for (var index = 0; index <= samples; index++) {
    final offset = metric.length * index / samples;
    final candidate = metric.getTangentForOffset(offset)?.position;
    if (candidate == null) continue;
    final distance = (candidate - point).distanceSquared;
    if (distance < nearestDistance) {
      nearestDistance = distance;
      nearestOffset = offset;
    }
  }
  return nearestOffset / metric.length;
}

/// 닫힌 건물 외곽선에서 실제 진입점 주변만 잘라 출입구를 만든다.
/// 경로가 이 틈을 통과하므로 확대 화면에서도 벽을 관통하는 것처럼 보이지 않는다.
List<Path> _pathWithEntranceGap(Path outline, Offset entrance, double gap) {
  final metric = outline.computeMetrics().first;
  var nearestOffset = 0.0;
  var nearestDistance = double.infinity;
  const samples = 320;
  for (var index = 0; index <= samples; index++) {
    final offset = metric.length * index / samples;
    final point = metric.getTangentForOffset(offset)?.position;
    if (point == null) continue;
    final distance = (point - entrance).distanceSquared;
    if (distance < nearestDistance) {
      nearestDistance = distance;
      nearestOffset = offset;
    }
  }
  final halfGap = gap / 2;
  final before = math.max(0.0, nearestOffset - halfGap);
  final after = math.min(metric.length, nearestOffset + halfGap);
  return [
    if (before > 0) metric.extractPath(0, before),
    if (after < metric.length) metric.extractPath(after, metric.length),
  ];
}

const _cityTones = [
  Color(0xFFE3EBF3),
  Color(0xFFE8EEF4),
  Color(0xFFE0E9F2),
  Color(0xFFE6EDF4),
];

const _cityGridX = [
  -420.0,
  250.0,
  800.0,
  1350.0,
  1900.0,
  2480.0,
  3150.0,
  3740.0,
];
const _cityGridY = [-500.0, 80.0, 500.0, 1050.0, 1510.0, 2030.0, 2500.0];

List<List<Offset>> _cityLotBuildings(Rect lot, int row, int column) {
  const gutter = 28.0;
  final width = lot.width;
  final height = lot.height;
  final pattern = (row * 3 + column).abs() % 4;

  switch (pattern) {
    case 0:
      final split = width * .54;
      return [
        _rectFootprint(lot.left, lot.top, split - gutter / 2, height),
        _rectFootprint(
          lot.left + split + gutter / 2,
          lot.top,
          width - split - gutter / 2,
          height,
        ),
      ];
    case 1:
      final split = height * .46;
      return [
        _rectFootprint(lot.left, lot.top, width, split - gutter / 2),
        _rectFootprint(
          lot.left,
          lot.top + split + gutter / 2,
          width,
          height - split - gutter / 2,
        ),
      ];
    case 2:
      final splitX = width * .57;
      final splitY = height * .52;
      return [
        _rectFootprint(
          lot.left,
          lot.top,
          splitX - gutter / 2,
          splitY - gutter / 2,
        ),
        _rectFootprint(
          lot.left + splitX + gutter / 2,
          lot.top,
          width - splitX - gutter / 2,
          splitY - gutter / 2,
        ),
        _rectFootprint(
          lot.left,
          lot.top + splitY + gutter / 2,
          width,
          height - splitY - gutter / 2,
        ),
      ];
    default:
      final splitX = width * .49;
      final splitY = height * .55;
      return [
        _rectFootprint(
          lot.left,
          lot.top,
          splitX - gutter / 2,
          splitY - gutter / 2,
        ),
        _rectFootprint(
          lot.left + splitX + gutter / 2,
          lot.top,
          width - splitX - gutter / 2,
          splitY - gutter / 2,
        ),
        _rectFootprint(
          lot.left,
          lot.top + splitY + gutter / 2,
          splitX - gutter / 2,
          height - splitY - gutter / 2,
        ),
        _rectFootprint(
          lot.left + splitX + gutter / 2,
          lot.top + splitY + gutter / 2,
          width - splitX - gutter / 2,
          height - splitY - gutter / 2,
        ),
      ];
  }
}

/// 도로 축은 직교하지만 간격은 서로 다르고, 각 필지는 2~4개의 각진 건물로
/// 다시 나뉜다. 더현대가 차지하는 좌상단 3×2 셀만 하나의 큰 슈퍼블록으로 둔다.
final _cityBlocks = <_CityBlock>[
  for (var row = 0; row < _cityGridY.length - 1; row++)
    for (var column = 0; column < _cityGridX.length - 1; column++)
      if (!((row == 1 || row == 2) && column >= 1 && column <= 3))
        for (final footprint in _cityLotBuildings(
          Rect.fromLTRB(
            _cityGridX[column] + 64,
            _cityGridY[row] + 64,
            _cityGridX[column + 1] - 64,
            _cityGridY[row + 1] - 64,
          ),
          row,
          column,
        ))
          _CityBlock(
            footprint,
            _cityTones[(row * 2 + column) % _cityTones.length],
          ),
];

/// 더현대가 차지하는 3×2 셀 내부의 도로만 끊고, 나머지는 모두 수평·수직으로
/// 연결한다. 도로는 중앙선 없이 두 겹의 면으로만 그려 교차로도 깨끗하게 합쳐진다.
final _cityRoads = <Path>[
  for (final x in [-420.0, 250.0, 1900.0, 2480.0, 3150.0, 3740.0])
    _pathFromPoints([Offset(x, -650), Offset(x, 2600)]),
  for (final x in [800.0, 1350.0]) ...[
    _pathFromPoints([Offset(x, -650), Offset(x, 80)]),
    _pathFromPoints([Offset(x, 1050), Offset(x, 2600)]),
  ],
  for (final y in [-500.0, 80.0, 1050.0, 1510.0, 2030.0, 2500.0])
    _pathFromPoints([Offset(-700, y), Offset(4000, y)]),
  _pathFromPoints(const [Offset(-700, 500), Offset(250, 500)]),
  _pathFromPoints(const [Offset(1900, 500), Offset(4000, 500)]),
];
List<_MapShape> _mapShapes(List<List<Offset>> polygons) =>
    polygons.map((polygon) {
      final path = _pathFromPoints(
        polygon.map(_floorToStage).toList(),
        close: true,
      );
      return _MapShape(path, path.getBounds());
    }).toList();

Path _pathFromPoints(List<Offset> points, {bool close = false}) {
  if (points.isEmpty) return Path();
  final path = Path()..moveTo(points.first.dx, points.first.dy);
  for (final point in points.skip(1)) {
    path.lineTo(point.dx, point.dy);
  }
  if (close) path.close();
  return path;
}

/// 무대 픽셀 / 실제 미터.
const _stagePerMeter = 7.0;

/// 백엔드에 큐레이션된 소개/사진이 있는 장소인지. 없으면 장소 시트가 짧아진다.
final bool _hasPlaceDetail =
    promoDestinationSummary.isNotEmpty || promoDestinationHeroAssets.isNotEmpty;

Offset _floorToStage(Offset point) => Offset(
  309 + (point.dx - 55) * _stagePerMeter,
  137 + (point.dy - 93) * _stagePerMeter,
);

Offset _pointOnPath(Path path, double progress) {
  final metric = path.computeMetrics().first;
  return metric
      .getTangentForOffset(metric.length * clamp01(progress))!
      .position;
}

double _pathHeading(Path path, double progress) {
  final before = _pointOnPath(path, clamp01(progress - .018));
  final after = _pointOnPath(path, clamp01(progress + .018));
  final direction = after - before;
  return math.atan2(direction.dy, direction.dx);
}

Offset _worldToScreen(Offset world, Size size, _CameraState camera) =>
    size.center(Offset.zero) + (world - camera.focus) * camera.scale;

double _motion(
  int timeMs,
  int startMs,
  int endMs,
  double Function(double) curve,
) => curve(interval(timeMs, startMs, endMs));

int _worldTimelineTime(int timeMs) {
  // 지도 조립이 끝난 상태를 잠시 유지하며 앱 셸이 완성되도록 한 뒤,
  // 검색부터 기존 타임라인을 2초 늦춰 이어간다.
  if (timeMs <= _openingMapSettleMs) return timeMs;
  if (timeMs <= _openingMapSettleMs + _openingUiDelayMs) {
    return _openingMapSettleMs;
  }
  return _extendedStoryTime(timeMs - _openingUiDelayMs);
}

/// 실외 이동과 실내 조립·이동·분해 구간을 각각 늘린다. 논리 타임라인의
/// 장면 순서는 유지하면서 실제 영상 길이만 늘어나므로 후속 장면이 겹치지 않는다.
int _extendedStoryTime(int rawTimeMs) {
  final afterOutdoor = _stretchTimelineInterval(
    rawTimeMs,
    startMs: 10100,
    endMs: 11800,
    extensionMs: _routeTravelExtensionMs,
  );
  return _stretchTimelineInterval(
    afterOutdoor,
    startMs: _entryZoomEndMs,
    endMs: _floorTransitionStartMs,
    extensionMs: _indoorSequenceExtensionMs,
  );
}

int _stretchTimelineInterval(
  int timeMs, {
  required int startMs,
  required int endMs,
  required int extensionMs,
}) {
  if (timeMs <= startMs) return timeMs;
  final extendedEnd = endMs + extensionMs;
  if (timeMs >= extendedEnd) return timeMs - extensionMs;
  final progress = (timeMs - startMs) / (extendedEnd - startMs);
  return (startMs + (endMs - startMs) * progress).round();
}

double _premium(double value) => 1 - math.pow(1 - clamp01(value), 4).toDouble();

/// 첫 영상의 장거리 카메라 곡선: cubic-bezier(.72, 0, .18, 1).
double _travel(double value) => _cubicBezier(value, .72, 0, .18, 1);

double _cubicBezier(double x, double x1, double y1, double x2, double y2) {
  final target = clamp01(x);
  var low = 0.0;
  var high = 1.0;
  var t = target;
  for (var index = 0; index < 14; index++) {
    final estimate = _bezierAxis(t, x1, x2);
    if (estimate < target) {
      low = t;
    } else {
      high = t;
    }
    t = (low + high) / 2;
  }
  return _bezierAxis(t, y1, y2);
}

double _bezierAxis(double t, double p1, double p2) {
  final u = 1 - t;
  return 3 * u * u * t * p1 + 3 * u * t * t * p2 + t * t * t;
}

double _pulse(int timeMs, int centerMs, int halfWidthMs) {
  final distance = (timeMs - centerMs).abs();
  if (distance >= halfWidthMs) return 0;
  return math.sin((1 - distance / halfWidthMs) * math.pi / 2);
}

double _sceneOpacity(
  int timeMs,
  int startMs,
  int endMs,
  int fadeIn,
  int fadeOut,
) => math.min(
  _premium(interval(timeMs, startMs, startMs + fadeIn)),
  1 - _premium(interval(timeMs, endMs - fadeOut, endMs)),
);

double _stagger(double progress, int index, int count, double spread) {
  if (count <= 1) return clamp01(progress);
  final delay = index / (count - 1) * spread;
  return clamp01((progress - delay) / (1 - spread));
}

/// 실제 두벌식 입력 순서대로 한 글자씩 조합된다. 목적지 이름과 같은 수의
/// 타건이라 기존 타이밍을 그대로 쓴다.
const _typingFrames = <(int, String, String)>[
  (3920, 'ㅋ', 'ㅋ'),
  (4020, 'ㅏ', '카'),
  (4160, 'ㅁ', '카ㅁ'),
  (4270, 'ㅔ', '카메'),
  (4470, 'ㄹ', '카멜'),
  (4570, 'ㅋ', '카멜ㅋ'),
  (4690, 'ㅓ', '카멜커'),
  (4870, 'ㅍ', '카멜커ㅍ'),
  (4980, 'ㅣ', '카멜커피'),
];

String _typedSearchQuery(int timeMs) {
  var text = '';
  for (final frame in _typingFrames) {
    if (timeMs < frame.$1) break;
    text = frame.$3;
  }
  return text;
}

String _activeTypingKey(int timeMs) {
  for (final frame in _typingFrames) {
    if ((timeMs - frame.$1).abs() <= 85) return frame.$2;
  }
  return '';
}

double _typingKeyPress(int timeMs) {
  var press = 0.0;
  for (final frame in _typingFrames) {
    press = math.max(press, _pulse(timeMs, frame.$1, 85));
  }
  return press;
}
