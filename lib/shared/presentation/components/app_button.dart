import 'package:flutter/material.dart';
import '../services/app_haptics.dart';
import '../../../core/constants/app_theme.dart';

/// Button variant enum for [AppButton].
enum AppButtonVariant {
  /// Primary kinetic lime button (high emphasis CTA).
  primary,

  /// Secondary dark titanium surface with structural border.
  secondary,

  /// Outline button with kinetic colored border and text.
  outline,

  /// Ghost button with no background or border.
  ghost,

  /// Destructive danger button for deletions and resets.
  destructive,
}

/// Monolithic Sci-Fi button component.
///
/// Enforces WCAG AA 48dp minimum touch target height, tactile scale feedback,
/// built-in loading spinner, and Semantics label support.
class AppButton extends StatefulWidget {
  /// Creates an [AppButton].
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = AppSpacings.huge,
    this.borderRadius,
    this.semanticsLabel,
  });

  /// The text displayed inside the button.
  final String label;

  /// Callback when the button is tapped. If null, the button is disabled.
  final VoidCallback? onPressed;

  /// Visual styling variant. Defaults to [AppButtonVariant.primary].
  final AppButtonVariant variant;

  /// Optional leading icon.
  final Widget? icon;

  /// Whether the button is in a busy/loading state.
  final bool isLoading;

  /// If true, expands to full horizontal width.
  final bool isFullWidth;

  /// Button height. Defaults to [AppSpacings.huge] (48dp).
  final double height;

  /// Custom corner radius. Defaults to [AppSpacings.radiusPill] (pill shape).
  final double? borderRadius;

  /// Optional accessibility semantics label.
  final String? semanticsLabel;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: AppSpacings.durationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  void _handleTapDown(TapDownDetails _) {
    if (_isEnabled) {
      _pressController.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (_isEnabled) {
      _pressController.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isEnabled) {
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = widget.borderRadius ?? tokens.radiusPill;

    // Resolve colors based on variant
    Color bg;
    Color fg;
    Border? border;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        bg = _isEnabled ? tokens.kineticAccent : tokens.elevated;
        fg = _isEnabled ? Colors.black : tokens.textMuted;
        border = null;
        break;
      case AppButtonVariant.secondary:
        bg = tokens.elevated;
        fg = _isEnabled ? tokens.textPrimary : tokens.textMuted;
        border = Border.all(color: tokens.borderSubtle, width: 1);
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = _isEnabled ? tokens.kineticAccent : tokens.textMuted;
        border = Border.all(
          color: _isEnabled ? tokens.kineticAccent : tokens.borderSubtle,
          width: 1.5,
        );
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = _isEnabled ? tokens.textPrimary : tokens.textMuted;
        border = null;
        break;
      case AppButtonVariant.destructive:
        bg = _isEnabled ? tokens.error.withValues(alpha: 0.15) : tokens.elevated;
        fg = _isEnabled ? tokens.error : tokens.textMuted;
        border = Border.all(
          color: _isEnabled ? tokens.error.withValues(alpha: 0.4) : tokens.borderSubtle,
          width: 1,
        );
        break;
    }

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        else ...[
          if (widget.icon != null) ...[
            IconTheme(
              data: IconThemeData(color: fg, size: 18),
              child: widget.icon!,
            ),
            const SizedBox(width: AppSpacings.sm),
          ],
          Flexible(
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: fg,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.semanticsLabel ?? widget.label,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            height: widget.height,
            constraints: const BoxConstraints(minHeight: AppSpacings.minTouchTarget),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(radius),
              border: border,
              boxShadow: (widget.variant == AppButtonVariant.primary && _isEnabled && tokens.isDark)
                  ? [
                      BoxShadow(
                        color: tokens.kineticAccent.withValues(alpha: 0.25),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(radius),
              child: InkWell(
                borderRadius: BorderRadius.circular(radius),
                onTap: _isEnabled
                    ? () {
                        AppHaptics.shared.buttonPress();
                        widget.onPressed?.call();
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacings.xl),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
