import 'dart:math' as math;
import 'package:flutter/material.dart';

/// IronFlow brand logo widget.
/// Renders a dumbbell icon with neon green glow on a dark rounded background.
/// Fully vector — scales to any size.
class IronFlowLogo extends StatelessWidget {
  const IronFlowLogo({
    this.size = 64,
    this.showLabel = false,
    super.key,
  });

  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.22),
            color: const Color(0xFF0A0A0A),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withValues(alpha: 0.35),
                blurRadius: size * 0.3,
                spreadRadius: size * 0.02,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _DumbbellPainter(),
          ),
        ),
        if (showLabel) ...[
          SizedBox(height: size * 0.12),
          Text(
            'IronFlow',
            style: TextStyle(
              color: const Color(0xFF00E676),
              fontSize: size * 0.28,
              fontWeight: FontWeight.bold,
              letterSpacing: size * 0.02,
            ),
          ),
        ],
      ],
    );
  }
}

class _DumbbellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Gradient paint for dumbbell
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF00E676),
        const Color(0xFF00B050),
      ],
    );

    final rect = Rect.fromLTWH(0, 0, w, h);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Glow paint
    final glowPaint = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..style = PaintingStyle.fill;

    // ── Dimensions ────────────────────────────────────────────────────────────
    final barW = w * 0.50;
    final barH = h * 0.10;
    final barX = cx - barW / 2;
    final barY = cy - barH / 2;

    final plateR = w * 0.175;
    final lPlateX = cx - barW / 2 - plateR * 0.3;
    final rPlateX = cx + barW / 2 + plateR * 0.3;

    final collarR = w * 0.095;
    final lCollarX = cx - barW / 2 + w * 0.04;
    final rCollarX = cx + barW / 2 - w * 0.04;

    // ── Draw glow (slightly larger shapes) ───────────────────────────────────
    canvas.drawCircle(Offset(lPlateX, cy), plateR + 3, glowPaint);
    canvas.drawCircle(Offset(rPlateX, cy), plateR + 3, glowPaint);

    // ── Draw dumbbell ─────────────────────────────────────────────────────────
    // Left plate
    canvas.drawCircle(Offset(lPlateX, cy), plateR, paint);
    // Right plate
    canvas.drawCircle(Offset(rPlateX, cy), plateR, paint);
    // Left collar
    canvas.drawCircle(Offset(lCollarX, cy), collarR, paint);
    // Right collar
    canvas.drawCircle(Offset(rCollarX, cy), collarR, paint);
    // Bar
    final barRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barX, barY, barW, barH),
      Radius.circular(barH / 2),
    );
    canvas.drawRRect(barRRect, paint);

    // ── Holes in plates ───────────────────────────────────────────────────────
    final holePaint = Paint()
      ..color = const Color(0xFF0A0A0A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(lPlateX, cy), plateR * 0.30, holePaint);
    canvas.drawCircle(Offset(rPlateX, cy), plateR * 0.30, holePaint);
  }

  @override
  bool shouldRepaint(_DumbbellPainter old) => false;
}
