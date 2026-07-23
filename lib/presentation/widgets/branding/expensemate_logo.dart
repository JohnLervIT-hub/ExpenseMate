import 'package:flutter/material.dart';

class ExpenseMateLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  const ExpenseMateLogo({super.key, this.size = 96, this.showShadow = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(showShadow: showShadow),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final bool showShadow;
  _LogoPainter({required this.showShadow});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = size.shortestSide * 0.22;
    final rrect = RRect.fromRectAndRadius(rect.deflate(size.shortestSide * 0.06), Radius.circular(radius));

    if (showShadow) {
      final shadow = Path()..addRRect(rrect);
      canvas.drawShadow(shadow, const Color(0xFF3E2A7A), 22, false);
    }

    // Base tile gradient
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8B7CE0), Color(0xFF6750A4), Color(0xFF3E2A7A)],
        stops: [0.0, 0.55, 1.0],
      ).createShader(rrect.outerRect);
    canvas.drawRRect(rrect, basePaint);

    // Vertical shine
    final shine = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withOpacity(0.55), Colors.white.withOpacity(0.08), Colors.transparent],
        stops: const [0, 0.45, 1],
      ).createShader(rrect.outerRect);
    canvas.drawRRect(rrect, shine);

    // Radial highlight
    final glow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.5),
        radius: 0.85,
        colors: [const Color(0xFFF1E9FF).withOpacity(0.9), Colors.transparent],
      ).createShader(rrect.outerRect);
    canvas.drawRRect(rrect, glow);

    // Ring
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final ringRadius = size.shortestSide * 0.32;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.02
      ..color = Colors.white.withOpacity(0.18);
    canvas.drawCircle(Offset(centerX, centerY), ringRadius, ringPaint);

    // "E" monogram
    final barPaint = Paint()..color = Colors.white;
    final barH = size.shortestSide * 0.055;
    final barR = Radius.circular(barH / 2);
    final left = centerX - size.shortestSide * 0.17;
    final right = centerX + size.shortestSide * 0.17;
    final top = centerY - size.shortestSide * 0.22;
    final bottom = centerY + size.shortestSide * 0.22;

    // vertical stroke
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(left, top, barH, bottom - top), barR),
      barPaint,
    );
    // top
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(left, top, right - left, barH), barR),
      barPaint,
    );
    // middle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, centerY - barH / 2, (right - left) * 0.75, barH),
        barR,
      ),
      barPaint,
    );
    // bottom
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(left, bottom - barH, right - left, barH), barR),
      barPaint,
    );

    // Dollar coin accent (top-right of the E)
    final coinCenter = Offset(centerX + size.shortestSide * 0.22, centerY - size.shortestSide * 0.19);
    final coinRadius = size.shortestSide * 0.09;
    canvas.drawCircle(
      coinCenter,
      coinRadius + size.shortestSide * 0.012,
      Paint()..color = Colors.white.withOpacity(0.2),
    );
    canvas.drawCircle(
      coinCenter,
      coinRadius,
      Paint()..color = const Color(0xFFF6C445),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '\$',
        style: TextStyle(
          color: const Color(0xFF3E2A7A),
          fontWeight: FontWeight.w900,
          fontSize: coinRadius * 1.35,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, coinCenter.translate(-tp.width / 2, -tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) => oldDelegate.showShadow != showShadow;
}
