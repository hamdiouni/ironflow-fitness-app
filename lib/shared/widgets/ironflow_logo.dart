import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

/// Brand logo mark widget.
/// Renders a crisp dumbbell glyph using the active Iron Scoreboard tokens.
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
    final tokens = Theme.of(context).extension<AppThemeTokens>();
    final bgColor = tokens?.card ?? const Color(0xFF14171D);
    final accentColor = tokens?.kineticAccent ?? const Color(0xFFF59E0B);
    final borderColor = tokens?.borderSubtle ?? const Color(0xFF2D3340);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.22),
            color: bgColor,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: CustomPaint(
            painter: _DumbbellPainter(
              accentColor: accentColor,
              cutoutColor: bgColor,
            ),
          ),
        ),
        if (showLabel) ...[
          SizedBox(height: size * 0.12),
          Text(
            'PROGRESSION',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              color: accentColor,
              fontSize: size * 0.24,
              fontWeight: FontWeight.w800,
              letterSpacing: size * 0.02,
            ),
          ),
        ],
      ],
    );
  }
}

class _DumbbellPainter extends CustomPainter {
  const _DumbbellPainter({
    required this.accentColor,
    required this.cutoutColor,
  });

  final Color accentColor;
  final Color cutoutColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final paint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    // Dimensions
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

    // Draw dumbbell
    canvas.drawCircle(Offset(lPlateX, cy), plateR, paint);
    canvas.drawCircle(Offset(rPlateX, cy), plateR, paint);
    canvas.drawCircle(Offset(lCollarX, cy), collarR, paint);
    canvas.drawCircle(Offset(rCollarX, cy), collarR, paint);
    final barRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barX, barY, barW, barH),
      Radius.circular(barH / 2),
    );
    canvas.drawRRect(barRRect, paint);

    // Holes in plates
    final holePaint = Paint()
      ..color = cutoutColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(lPlateX, cy), plateR * 0.30, holePaint);
    canvas.drawCircle(Offset(rPlateX, cy), plateR * 0.30, holePaint);
  }

  @override
  bool shouldRepaint(_DumbbellPainter old) =>
      old.accentColor != accentColor || old.cutoutColor != cutoutColor;
}
