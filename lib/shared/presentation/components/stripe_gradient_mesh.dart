import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

/// Signature Stripe atmospheric gradient mesh backdrop from DESIGN.md.
///
/// Features the iconic horizontal wash of pastel cream (#F5E9D4), sherbet lemon (#F7A072),
/// lavender (#B9B9F9), electric indigo (#533AFD), and ruby pink (#EA2261).
class StripeMeshBackdrop extends StatelessWidget {
  const StripeMeshBackdrop({
    super.key,
    this.height = 180.0,
    this.borderRadius,
    this.child,
    this.opacity = 1.0,
  });

  /// Height of the atmospheric mesh band.
  final double height;

  /// Optional border radius (e.g. For rounded card headers).
  final BorderRadius? borderRadius;

  /// Optional child content rendered above the mesh wash.
  final Widget? child;

  /// Overall opacity multiplier.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget mesh = Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.brandDark900,
                  const Color(0xFF282566),
                  const Color(0xFF1E265C),
                  const Color(0xFF161947),
                ]
              : [
                  const Color(0xFFFFF7ED), // Cream wash
                  const Color(0xFFFEE2E2), // Ruby soft
                  const Color(0xFFE0E7FF), // Lavender soft
                  const Color(0xFFEDE9FE), // Indigo tint
                ],
          stops: const [0.0, 0.35, 0.70, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Ambient organic blob 1 (Electric Indigo / Lavender)
          Positioned(
            top: -40,
            right: -30,
            width: 200,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          AppColors.primary.withValues(alpha: 0.35),
                          Colors.transparent,
                        ]
                      : [
                          AppColors.primaryBgSubduedHover.withValues(alpha: 0.65),
                          Colors.transparent,
                        ],
                ),
              ),
            ),
          ),
          // Ambient organic blob 2 (Ruby / Sherbet)
          Positioned(
            bottom: -30,
            left: 20,
            width: 160,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          AppColors.ruby.withValues(alpha: 0.20),
                          Colors.transparent,
                        ]
                      : [
                          const Color(0xFFFFD4DE).withValues(alpha: 0.55),
                          Colors.transparent,
                        ],
                ),
              ),
            ),
          ),
          // Ambient organic blob 3 (Lemon / Warm Gold)
          Positioned(
            top: 10,
            left: -20,
            width: 120,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF9B6829).withValues(alpha: 0.22),
                          Colors.transparent,
                        ]
                      : [
                          AppColors.canvasCream.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                ),
              ),
            ),
          ),
          if (child != null) Positioned.fill(child: child!),
        ],
      ),
    );

    if (borderRadius != null) {
      mesh = ClipRRect(
        borderRadius: borderRadius!,
        child: mesh,
      );
    }

    if (opacity < 1.0) {
      mesh = Opacity(opacity: opacity, child: mesh);
    }

    return mesh;
  }
}

/// A soft indigo pill tag adapted from Stripe's `pill-tag-soft` (DESIGN.md:420).
class StripePillTag extends StatelessWidget {
  const StripePillTag({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  final String label;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final bg = backgroundColor ??
        (tokens.isDark
            ? AppColors.primary.withValues(alpha: 0.22)
            : AppColors.primaryBgSubduedHover.withValues(alpha: 0.45));
    final fg = textColor ??
        (tokens.isDark ? const Color(0xFFC4B5FD) : AppColors.primaryDeep);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacings.radiusPill),
        border: Border.all(
          color: fg.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: fg, size: 12),
              child: icon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
