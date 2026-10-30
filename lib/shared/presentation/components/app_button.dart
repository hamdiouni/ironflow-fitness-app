import 'package:flutter/material.dart';
import '../services/app_haptics.dart';
import '../../../core/constants/app_theme.dart';

/// Button variant enum for [AppButton].
enum AppButtonVariant {
  /// Primary kinetic teal button (high emphasis CTA).
  primary,

  /// Secondary dark slate surface with subtle border.
  secondary,

  /// Outline button with kinetic colored border and text.
  outline,

  /// Ghost button with no background or border.
  ghost,

  /// Tertiary link-style text button.
  tertiary,

  /// Destructive danger button for deletions and resets.
  destructive,
}

/// Sizing scale for [AppButton].
enum AppButtonSize {
  /// 36dp visual height (padded to 48dp touch target).
  small,

  /// 44dp visual height.
  medium,

  /// 50dp visual height (standard CTA).
  large,
}

/// Unified Slate Teal button component.
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
    this.size,
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

  /// Sizing preset (small, medium, large). Overrides [height] if provided.
  final AppButtonSize? size;

  /// Optional leading icon.
  final Widget? icon;

  /// Whether the button is in a busy/loading state.
  final bool isLoading;

  /// If true, expands to full horizontal width.
  final bool isFullWidth;

  /// Button height. Defaults to [AppSpacings.huge] (48dp).
  final double height;

  /// Custom corner radius. Defaults to [tokens.buttonRadius] (12dp).
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

  double _resolveHeight() {
    if (widget.size == null) return widget.height;
    switch (widget.size!) {
      case AppButtonSize.small:
        return 36.0;
      case AppButtonSize.medium:
        return 44.0;
      case AppButtonSize.large:
        return 50.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = widget.borderRadius ?? tokens.buttonRadius;
    final targetHeight = _resolveHeight();

    // Resolve colors based on variant with 100% WCAG AA contrast pass
    Color bg;
    Color fg;
    Border? border;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        bg = _isEnabled ? tokens.kineticAccent : tokens.elevated;
        fg = _isEnabled ? tokens.onAccent : tokens.textMuted;
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
      case AppButtonVariant.tertiary:
        bg = Colors.transparent;
        fg = _isEnabled ? tokens.kineticAccent : tokens.textMuted;
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
              data: IconThemeData(color: fg, size: widget.size == AppButtonSize.small ? 14 : 18),
              child: widget.icon!,
            ),
            const SizedBox(width: AppSpacings.sm),
          ],
          Flexible(
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: widget.size == AppButtonSize.small ? 12 : 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
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
        onTap: _isEnabled
            ? () {
                AppHaptics.shared.buttonPress();
                widget.onPressed?.call();
              }
            : null,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacings.minTouchTarget),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: AppSpacings.durationFast,
              height: targetHeight,
              width: widget.isFullWidth ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: widget.size == AppButtonSize.small ? AppSpacings.md : AppSpacings.lg,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(radius),
                border: border,
              ),
              alignment: Alignment.center,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// Accessible 48×48 icon button with touch-target guarantee.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 48.0,
    this.iconSize = 20.0,
    this.color,
    this.backgroundColor,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fg = color ?? tokens.textPrimary;

    Widget button = InkWell(
      onTap: onPressed != null
          ? () {
              AppHaptics.shared.buttonPress();
              onPressed!();
            }
          : null,
      borderRadius: BorderRadius.circular(tokens.buttonRadius),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(tokens.buttonRadius),
        ),
        child: IconTheme(
          data: IconThemeData(color: fg, size: iconSize),
          child: icon,
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
