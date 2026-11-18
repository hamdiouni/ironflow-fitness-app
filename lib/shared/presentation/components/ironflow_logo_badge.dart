import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Vector brand emblem for IronFlow: Option D — Iron Scoreboard HUD Emblem
/// (36-tick chronometer gauge, dual amber/cyan telemetry arcs, and diagonal
/// loaded Olympic barbell on an obsidian squircle badge).
class IronFlowLogoBadge extends StatelessWidget {
  const IronFlowLogoBadge({
    super.key,
    this.size = 64,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: const IronFlowLogoPainter(),
      ),
    );
  }
}

class IronFlowLogoPainter extends CustomPainter {
  const IronFlowLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scale = size.width / 1024.0;
    canvas.scale(scale, scale);
    paintOptionD1024(canvas, const Size(1024, 1024));
    canvas.restore();
  }

  /// Paints the canonical 1024x1024 Option D (Iron Scoreboard HUD Emblem) logo.
  static void paintOptionD1024(Canvas canvas, Size size) {
    const amber = Color(0xFFF59E0B);
    const amberBright = Color(0xFFFBBF24);
    const cyan = Color(0xFF06B6D4);
    const cyanBright = Color(0xFF22D3EE);
    const center = Offset(512, 512);

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(16),
      const Radius.circular(220),
    );

    // Deep obsidian background gradient
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(size.width, size.height),
        const [
          Color(0xFF0E1117),
          Color(0xFF08090C),
          Color(0xFF121620),
        ],
        const [0.0, 0.55, 1.0],
      );
    canvas.drawRRect(rrect, bgPaint);

    // Ambient radial glow top-left (amber) & bottom-right (cyan)
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(260, 260),
          460,
          [amber.withValues(alpha: 0.18), Colors.transparent],
        ),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(764, 764),
          460,
          [cyan.withValues(alpha: 0.16), Colors.transparent],
        ),
    );

    // Metallic bezel
    canvas.drawRRect(
      rrect.deflate(5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(size.width, size.height),
          [
            amber.withValues(alpha: 0.65),
            const Color(0xFF283040),
            cyan.withValues(alpha: 0.65),
          ],
          const [0.0, 0.5, 1.0],
        ),
    );

    // Outer Scoreboard HUD tick marks (36 ticks)
    final tickPaint = Paint()
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 36; i++) {
      final angle = (i * 10) * math.pi / 180;
      final isMajor = i % 3 == 0;
      tickPaint.color = i < 27
          ? amber.withValues(alpha: isMajor ? 0.9 : 0.35)
          : cyanBright.withValues(alpha: isMajor ? 0.95 : 0.45);
      final r1 = isMajor ? 365.0 : 375.0;
      const r2 = 392.0;
      canvas.drawLine(
        Offset(
          center.dx + r1 * math.cos(angle),
          center.dy + r1 * math.sin(angle),
        ),
        Offset(
          center.dx + r2 * math.cos(angle),
          center.dy + r2 * math.sin(angle),
        ),
        tickPaint,
      );
    }

    // Segmented Telemetry Gauge Ring
    final ringRect = Rect.fromCircle(center: center, radius: 325);
    canvas.drawArc(
      ringRect,
      -math.pi * 0.8,
      math.pi * 1.35,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 38
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          const Offset(200, 200),
          const Offset(800, 800),
          const [amberBright, amber],
        ),
    );
    canvas.drawArc(
      ringRect,
      math.pi * 0.65,
      math.pi * 0.42,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 38
        ..strokeCap = StrokeCap.round
        ..color = cyanBright,
    );

    // Diagonal Minimalist Olympic Barbell (rotated -28 degrees)
    canvas.save();
    canvas.translate(512, 512);
    canvas.rotate(-28 * math.pi / 180);

    final barShader = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(-260, 0),
        const Offset(260, 0),
        const [cyanBright, Colors.white, amberBright],
        const [0.0, 0.5, 1.0],
      );

    // Central knurled shaft
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 500, height: 34),
        const Radius.circular(12),
      ),
      barShader,
    );

    final plateAmber = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, -140),
        const Offset(0, 140),
        const [amberBright, amber, Color(0xFFB45309)],
        const [0.0, 0.5, 1.0],
      );

    final plateCyan = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, -140),
        const Offset(0, 140),
        const [cyanBright, cyan, Color(0xFF0E7490)],
        const [0.0, 0.5, 1.0],
      );

    // Left plates (Cyan telemetry side)
    for (final spec in const [
      (x: -145.0, w: 38.0, h: 240.0),
      (x: -195.0, w: 34.0, h: 185.0),
      (x: -238.0, w: 28.0, h: 130.0),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(spec.x, 0),
            width: spec.w,
            height: spec.h,
          ),
          const Radius.circular(12),
        ),
        plateCyan,
      );
    }

    // Right plates (Amber kinetic side)
    for (final spec in const [
      (x: 145.0, w: 38.0, h: 240.0),
      (x: 195.0, w: 34.0, h: 185.0),
      (x: 238.0, w: 28.0, h: 130.0),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(spec.x, 0),
            width: spec.w,
            height: spec.h,
          ),
          const Radius.circular(12),
        ),
        plateAmber,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
