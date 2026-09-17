import 'package:flutter/material.dart';

/// Smooth animation for macro wheel updates.
class MacroWheelAnimation extends StatefulWidget {
  final double value;
  final Duration duration;
  final Curve curve;
  final Widget Function(BuildContext, double) builder;

  const MacroWheelAnimation({
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOutCubic,
    super.key,
  });

  @override
  State<MacroWheelAnimation> createState() => _MacroWheelAnimationState();
}

class _MacroWheelAnimationState extends State<MacroWheelAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(MacroWheelAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value)
          .animate(
        CurvedAnimation(parent: _controller, curve: widget.curve),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => widget.builder(context, _animation.value),
    );
  }
}

/// Smooth animation for list items appearing.
class ListItemAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration staggerDuration;
  final Duration itemDuration;
  final Curve curve;

  const ListItemAnimation({
    required this.child,
    required this.index,
    this.staggerDuration = const Duration(milliseconds: 50),
    this.itemDuration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  @override
  State<ListItemAnimation> createState() => _ListItemAnimationState();
}

class _ListItemAnimationState extends State<ListItemAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.itemDuration, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Future.delayed(
      widget.staggerDuration * widget.index,
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Smooth animation for set completion celebration.
class SetCompletionAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;

  const SetCompletionAnimation({
    required this.child,
    this.onComplete,
    super.key,
  });

  @override
  State<SetCompletionAnimation> createState() => _SetCompletionAnimationState();
}

class _SetCompletionAnimationState extends State<SetCompletionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Smooth animation for value changes (e.g., weight, reps).
class ValueChangeAnimation extends StatefulWidget {
  final double value;
  final Duration duration;
  final Curve curve;
  final Widget Function(BuildContext, double) builder;

  const ValueChangeAnimation({
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOutCubic,
    super.key,
  });

  @override
  State<ValueChangeAnimation> createState() => _ValueChangeAnimationState();
}

class _ValueChangeAnimationState extends State<ValueChangeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ValueChangeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value)
          .animate(
        CurvedAnimation(parent: _controller, curve: widget.curve),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => widget.builder(context, _animation.value),
    );
  }
}
