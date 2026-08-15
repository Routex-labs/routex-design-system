import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

/// 목업 기기의 상태바와 홈 인디케이터가 차지하는 안전 영역이다.
///
/// 제품 UI는 좌표 대신 이 padding을 읽어 배치한다.
const deviceViewPadding = EdgeInsets.only(top: 42, bottom: 20);

class PhoneStatusBar extends StatelessWidget {
  const PhoneStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: 42,
      child: Stack(
        children: [
          const Positioned(
            left: 53,
            top: 16,
            child: Text(
              '9:41',
              style: TextStyle(
                color: Color(0xFF13233A),
                fontSize: 14.5,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: -.25,
              ),
            ),
          ),
          Positioned(
            left: 150,
            top: 10,
            width: 91,
            height: 25,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF090B0E),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const Positioned(right: 28, top: 12, child: _DeviceStatusGlyphs()),
        ],
      ),
    );
  }
}

class _DeviceStatusGlyphs extends StatelessWidget {
  const _DeviceStatusGlyphs();

  // 세 글리프는 각자 좌표를 갖지 않고 한 줄에서 세로 중앙을 공유한다. 예전에는
  // top 값을 따로 줘서 신호·5G·배터리의 光학 중심이 서로 어긋났다.
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 18,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 11,
          child: CustomPaint(painter: _CellularSignalPainter()),
        ),
        SizedBox(width: 5),
        Text(
          '5G',
          style: TextStyle(
            color: Color(0xFF13233A),
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: -.45,
          ),
        ),
        SizedBox(width: 5),
        Icon(CupertinoIcons.battery_100, size: 22, color: Color(0xFF13233A)),
      ],
    ),
  );
}

class _CellularSignalPainter extends CustomPainter {
  const _CellularSignalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF13233A)
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 4; index++) {
      final barHeight = 3.5 + index * 2.6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(index * 3.8, size.height - barHeight, 2.6, barHeight),
          const Radius.circular(1),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CellularSignalPainter oldDelegate) => false;
}

class PhoneHomeIndicator extends StatelessWidget {
  const PhoneHomeIndicator({super.key});

  @override
  Widget build(BuildContext context) => Positioned(
    left: 129,
    bottom: 7,
    width: 132,
    height: 5,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF263342),
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}

class PromoPhoneClipper extends CustomClipper<Path> {
  const PromoPhoneClipper();

  @override
  Path getClip(Size size) => Path()
    ..addRSuperellipse(
      RSuperellipse.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(52),
      ),
    );

  @override
  bool shouldReclip(covariant PromoPhoneClipper oldClipper) => false;
}

class PromoPhoneFramePainter extends CustomPainter {
  const PromoPhoneFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final shape = RSuperellipse.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(52),
    );
    final path = Path()..addRSuperellipse(shape);
    canvas.drawShadow(
      path.shift(const Offset(0, 7)),
      const Color(0x183A5C80),
      20,
      false,
    );
    canvas.drawRSuperellipse(
      shape,
      Paint()
        ..color = const Color(0x6B9EACBC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15,
    );
  }

  @override
  bool shouldRepaint(covariant PromoPhoneFramePainter oldDelegate) => false;
}
