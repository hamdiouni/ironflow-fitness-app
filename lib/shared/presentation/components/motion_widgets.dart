import 'dart:ui';
import 'package:flutter/material.dart';

/// Animated count-up text that counts from 0 to target on mount with tabular figures.
class AnimatedCountUpText extends StatefulWidget {
  final num targetValue;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final Curve curve;
  final int decimalPlaces;

  const AnimatedCountUpText({
    super.key,
    required this.targetValue,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 650),
    this.curve = Curves.easeOutCubic,
    this.decimalPlaces = 0,
  });

  @override
  State<AnimatedCountUpText> createState() => _AnimatedCountUpTextState();
}

class _AnimatedCountUpTextState extends State<AnimatedCountUpText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final defaultStyle = (widget.style ?? const TextStyle()).copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    if (disableMotion) {
      final formatted = widget.decimalPlaces == 0
          ? widget.targetValue.toInt().toString()
          : widget.targetValue.toStringAsFixed(widget.decimalPlaces);
      return Text('${widget.prefix}$formatted${widget.suffix}', style: defaultStyle);
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final current = _animation.value * widget.targetValue;
        final formatted = widget.decimalPlaces == 0
            ? current.toInt().toString()
            : current.toStringAsFixed(widget.decimalPlaces);
        return Text('${widget.prefix}$formatted${widget.suffix}', style: defaultStyle);
      },
    );
  }
}

/// Tactile button with animated scale-down on press.
class AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scaleDown;
  final Duration duration;

  const AnimatedScaleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.scaleDown = 0.96,
    this.duration = const Duration(milliseconds: 110),
  });

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: widget.scaleDown,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null) _controller.reverse();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onPressed != null) {
      _controller.forward();
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: disableMotion ? null : _onTapDown,
      onTapUp: disableMotion ? null : _onTapUp,
      onTapCancel: disableMotion ? null : _onTapCancel,
      onTap: disableMotion ? widget.onPressed : null,
      child: disableMotion
          ? widget.child
          : AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.scale(
                scale: _controller.value,
                child: child,
              ),
              child: widget.child,
            ),
    );
  }
}

/// Interactive Touch-Friendly Stepper with animated feedback.
class QuantityStepper extends StatelessWidget {
  final double value;
  final double step;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;

  const QuantityStepper({
    super.key,
    required this.value,
    this.step = 10.0,
    this.min = 0.0,
    this.max = 2000.0,
    this.unit = 'g',
    required this.onChanged,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: value > min ? () => onChanged((value - step).clamp(min, max)) : null,
            borderRadius: BorderRadius.circular(borderRadius),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(
                Icons.remove,
                size: 18,
                color: value > min ? foregroundColor : foregroundColor.withValues(alpha: 0.3),
              ),
            ),
          ),
          SizedBox(
            width: 52,
            child: Center(
              child: Text(
                '${value == value.roundToDouble() ? value.toInt() : value.toStringAsFixed(1)}${unit.isNotEmpty ? ' $unit' : ''}',
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          InkWell(
            onTap: value < max ? () => onChanged((value + step).clamp(min, max)) : null,
            borderRadius: BorderRadius.circular(borderRadius),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(
                Icons.add,
                size: 18,
                color: value < max ? foregroundColor : foregroundColor.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular macro ring that smoothly animates its progress.
class LiveMacroRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color primaryColor;
  final Color backgroundColor;
  final double size;
  final double strokeWidth;
  final Widget? centerChild;

  const LiveMacroRing({
    super.key,
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
    this.size = 140.0,
    this.strokeWidth = 10.0,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return CircularProgressIndicator(
                value: val,
                strokeWidth: strokeWidth,
                strokeCap: StrokeCap.round,
                backgroundColor: backgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              );
            },
          ),
          ?centerChild,
        ],
      ),
    );
  }
}

/// Staggered container that enters with a subtle slide & fade.
class AnimatedStaggerItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration duration;

  const AnimatedStaggerItem({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 40),
    this.duration = const Duration(milliseconds: 280),
  });

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableMotion) return child;

    final delay = baseDelay * index;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + delay,
      curve: Curves.easeOutCubic,
      builder: (context, val, ch) {
        return Opacity(
          opacity: val.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 12 * (1.0 - val)),
            child: ch,
          ),
        );
      },
      child: child,
    );
  }
}
