import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import '../mockup/mockup_step.dart';

class NavigationMapPainter extends CustomPainter {
  const NavigationMapPainter(this.step, this.progress);

  final MockupStep step;
  final double progress;

  // 경로선·마커·도면 색은 화면이 정하지 않고 지도 시각 토큰에서 읽는다.
  static const _route = RoutexMapVisualTokens.routeLine;
  static const _routeCasing = RoutexMapVisualTokens.routeCasing;
  static const _routeCompleted = RoutexMapVisualTokens.routeCompleted;
  static const _location = RoutexMapVisualTokens.location;
  static const _destination = RoutexMapVisualTokens.destination;

  @override
  void paint(Canvas canvas, Size size) {
    final indoor = step == MockupStep.indoor || step == MockupStep.arrival;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = indoor
            ? RoutexMapVisualTokens.canvasIndoor
            : RoutexMapVisualTokens.canvasOutdoor,
    );
    if (indoor) {
      _paintIndoor(canvas, size);
    } else {
      _paintOutdoor(canvas, size);
    }
  }

  void _paintOutdoor(Canvas canvas, Size size) {
    final road = Path()
      ..moveTo(-30, size.height * .22)
      ..lineTo(size.width + 30, size.height * .52)
      ..moveTo(size.width * .08, -20)
      ..lineTo(size.width * .54, size.height + 20)
      ..moveTo(size.width * .91, -20)
      ..lineTo(size.width * .32, size.height + 20);
    canvas.drawPath(
      road,
      Paint()
        ..color = RoutexMapVisualTokens.walkway
        ..strokeWidth = 22
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      road,
      Paint()
        ..color = RoutexMapVisualTokens.structureOutline
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    final buildings = [
      Rect.fromLTWH(size.width * .08, size.height * .18, 88, 88),
      Rect.fromLTWH(size.width * .59, size.height * .22, 100, 78),
      Rect.fromLTWH(size.width * .14, size.height * .54, 92, 72),
      Rect.fromLTWH(size.width * .60, size.height * .60, 98, 118),
    ];
    for (final rect in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(7)),
        Paint()..color = RoutexMapVisualTokens.structure,
      );
    }
    Offset? guidedLocation;
    // 메인 화면은 아직 목적지가 없으므로 경로와 목적지 마커를 그리지 않는다.
    final hasDestination = step != MockupStep.home;
    if (hasDestination &&
        step != MockupStep.place &&
        step != MockupStep.detail) {
      final path = Path()
        ..moveTo(size.width * .34, size.height * .82)
        ..cubicTo(
          size.width * .31,
          size.height * .66,
          size.width * .28,
          size.height * .50,
          size.width * .37,
          size.height * .39,
        )
        ..cubicTo(
          size.width * .48,
          size.height * .28,
          size.width * .56,
          size.height * .34,
          size.width * .62,
          size.height * .28,
        );
      final effectiveProgress = step == MockupStep.guidance
          ? progress.clamp(0.0, 1.0)
          : step == MockupStep.arrival
          ? 1.0
          : 0.0;
      guidedLocation = _paintRoute(canvas, path, progress: effectiveProgress);
      if (effectiveProgress < 1) {
        _paintArrow(canvas, Offset(size.width * .43, size.height * .36), -.8);
        _paintArrow(canvas, Offset(size.width * .54, size.height * .32), -.25);
      }
    }
    if (hasDestination) {
      _paintDestination(canvas, Offset(size.width * .62, size.height * .28));
    }
    _paintLocation(
      canvas,
      guidedLocation ??
          (step == MockupStep.place || step == MockupStep.detail
              ? Offset(size.width * .36, size.height * .42)
              : Offset(size.width * .34, size.height * .82)),
      heading: step == MockupStep.guidance,
    );
  }

  void _paintIndoor(Canvas canvas, Size size) {
    final footprint = _floorPolygon(size, const [
      Offset(.64, 50.44),
      Offset(81.2, 50.44),
      Offset(81.2, 44.24),
      Offset(76.92, 39.76),
      Offset(79.36, 37.16),
      Offset(81.2, 37.16),
      Offset(81.2, 16.88),
      Offset(80.2, 15.92),
      Offset(77.56, 13.56),
      Offset(81.2, 9.24),
      Offset(81.2, 3.24),
      Offset(.68, 3.24),
      Offset(.68, 6.16),
      Offset(.56, 6.16),
      Offset(.56, 16.04),
      Offset(1.92, 16.04),
      Offset(2, 32.56),
      Offset(.68, 32.56),
    ]);
    canvas.drawPath(footprint, Paint()..color = RoutexMapVisualTokens.walkway);
    canvas.drawPath(
      footprint,
      Paint()
        ..color = RoutexMapVisualTokens.walkwayOutline
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    const stores = <(String, List<Offset>)>[
      (
        '발렌시아가',
        [
          Offset(2.04, 34.84),
          Offset(12.56, 34.84),
          Offset(14.28, 35.4),
          Offset(14.28, 39.44),
          Offset(4.48, 39.44),
          Offset(3.84, 37.24),
          Offset(2.04, 35.08),
        ],
      ),
      (
        '미우미우',
        [
          Offset(15.92, 43.4),
          Offset(15.92, 35.76),
          Offset(20.56, 36.92),
          Offset(20.6, 43.4),
        ],
      ),
      (
        '발렌티노',
        [
          Offset(20.72, 43.4),
          Offset(20.72, 36.96),
          Offset(25.88, 37.96),
          Offset(25.88, 43.4),
        ],
      ),
      (
        '티파니앤코',
        [
          Offset(27.8, 44.88),
          Offset(27.8, 38.28),
          Offset(37.88, 39.4),
          Offset(37.88, 44.88),
        ],
      ),
      (
        '로에베',
        [
          Offset(44.12, 43.84),
          Offset(44.12, 39.4),
          Offset(49.28, 39),
          Offset(49.28, 43.84),
        ],
      ),
      (
        '구찌',
        [
          Offset(54.88, 43.04),
          Offset(54.92, 38.68),
          Offset(66.56, 35.76),
          Offset(66.56, 40.64),
          Offset(64.16, 43.04),
        ],
      ),
      (
        '셀린느',
        [
          Offset(68.84, 41.12),
          Offset(74, 41.12),
          Offset(76.92, 39.76),
          Offset(72, 34.76),
          Offset(68.92, 34.76),
        ],
      ),
    ];
    for (final store in stores) {
      final shape = _floorPolygon(size, store.$2);
      canvas.drawPath(shape, Paint()..color = RoutexMapVisualTokens.facility);
      canvas.drawPath(
        shape,
        Paint()
          ..color = RoutexMapVisualTokens.facilityOutline
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
    }
    _paintFloorLabel(canvas, size, '발렌시아가', const Offset(8, 37));
    _paintFloorLabel(canvas, size, '구찌', const Offset(60, 39));
    final path = Path()
      ..moveTo(size.width * .50, size.height * .84)
      ..lineTo(size.width * .50, size.height * .61)
      ..cubicTo(
        size.width * .50,
        size.height * .50,
        size.width * .44,
        size.height * .48,
        size.width * .44,
        size.height * .39,
      )
      ..cubicTo(
        size.width * .44,
        size.height * .31,
        size.width * .56,
        size.height * .29,
        size.width * .64,
        size.height * .29,
      );
    final indoorProgress = step == MockupStep.arrival
        ? 1.0
        : ((progress - .58) / .42).clamp(0.0, 1.0);
    final guidedLocation = _paintRoute(canvas, path, progress: indoorProgress);
    if (indoorProgress < 1) {
      _paintArrow(canvas, Offset(size.width * .50, size.height * .56), -1.57);
      _paintArrow(canvas, Offset(size.width * .52, size.height * .31), -.1);
    }
    _paintDestination(canvas, Offset(size.width * .65, size.height * .29));
    _paintLocation(canvas, guidedLocation, heading: step == MockupStep.indoor);
  }

  Path _floorPolygon(Size size, List<Offset> points) {
    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final point = _floorPoint(size, points[index]);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  Offset _floorPoint(Size size, Offset point) => Offset(
    size.width * .07 + (point.dx / 82) * size.width * .86,
    size.height * .17 + ((51 - point.dy) / 49) * size.height * .60,
  );

  void _paintFloorLabel(Canvas canvas, Size size, String label, Offset local) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF66717D),
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final point = _floorPoint(size, local);
    painter.paint(
      canvas,
      point - Offset(painter.width / 2, painter.height / 2),
    );
  }

  Offset _paintRoute(Canvas canvas, Path path, {required double progress}) {
    canvas.drawPath(
      path,
      Paint()
        ..color = _routeCasing
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = _route
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    final metric = path.computeMetrics().first;
    final distance = metric.length * progress.clamp(0.0, 1.0);
    if (distance > 0) {
      canvas.drawPath(
        metric.extractPath(0, distance),
        Paint()
          ..color = _routeCompleted
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );
    }
    return metric.getTangentForOffset(distance)?.position ?? Offset.zero;
  }

  void _paintLocation(Canvas canvas, Offset center, {bool heading = false}) {
    canvas.drawCircle(
      center,
      16,
      Paint()..color = _location.withValues(alpha: .18),
    );
    canvas.drawCircle(
      center,
      10,
      Paint()..color = RoutexMapVisualTokens.walkway,
    );
    if (heading) {
      final marker = Path()
        ..moveTo(center.dx, center.dy - 10)
        ..lineTo(center.dx + 7, center.dy + 7)
        ..lineTo(center.dx, center.dy + 4)
        ..lineTo(center.dx - 7, center.dy + 7)
        ..close();
      canvas.drawPath(marker, Paint()..color = _location);
    } else {
      canvas.drawCircle(center, 7, Paint()..color = _location);
      canvas.drawCircle(
        center,
        2.5,
        Paint()..color = RoutexMapVisualTokens.walkway,
      );
    }
  }

  void _paintDestination(Canvas canvas, Offset tip) {
    final head = Offset(tip.dx, tip.dy - 18);
    final pin = Path()
      ..moveTo(tip.dx, tip.dy)
      ..cubicTo(
        tip.dx - 5,
        tip.dy - 8,
        tip.dx - 14,
        tip.dy - 18,
        head.dx - 14,
        head.dy,
      )
      ..arcToPoint(
        Offset(head.dx + 14, head.dy),
        radius: const Radius.circular(14),
        largeArc: true,
      )
      ..cubicTo(
        tip.dx + 14,
        tip.dy - 18,
        tip.dx + 5,
        tip.dy - 8,
        tip.dx,
        tip.dy,
      )
      ..close();
    canvas.drawPath(pin, Paint()..color = _destination);
    canvas.drawPath(
      pin,
      Paint()
        ..color = RoutexMapVisualTokens.destinationOutline
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(head, 4, Paint()..color = RoutexMapVisualTokens.walkway);
  }

  void _paintArrow(Canvas canvas, Offset center, double angle) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final arrow = Path()
      ..moveTo(-4, -5)
      ..lineTo(3, 0)
      ..lineTo(-4, 5);
    canvas.drawPath(
      arrow,
      Paint()
        ..color = RoutexMapVisualTokens.walkway
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant NavigationMapPainter oldDelegate) =>
      oldDelegate.step != step || oldDelegate.progress != progress;
}
