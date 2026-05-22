import 'package:flutter/material.dart';

import '../core/theme.dart';

class WessLessLogoMark extends StatelessWidget {
  final double size;

  const WessLessLogoMark({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(painter: _WessLessLogoPainter()),
    );
  }
}

class _WessLessLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wPaint = Paint()
      ..color = WessLessTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final wPath = Path()
      ..moveTo(size.width * 0.24, size.height * 0.38)
      ..lineTo(size.width * 0.38, size.height * 0.68)
      ..lineTo(size.width * 0.50, size.height * 0.42)
      ..lineTo(size.width * 0.62, size.height * 0.68)
      ..lineTo(size.width * 0.76, size.height * 0.42);
    canvas.drawPath(wPath, wPaint);

    final smilePaint = Paint()
      ..color = WessLessTheme.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.24,
        size.height * 0.50,
        size.width * 0.52,
        size.height * 0.34,
      ),
      0.22,
      2.70,
      false,
      smilePaint,
    );

    final leafPaint = Paint()
      ..color = WessLessTheme.primaryLight
      ..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(size.width * 0.75, size.height * 0.30);
    canvas.rotate(-0.72);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 0.24,
        height: size.height * 0.14,
      ),
      leafPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
