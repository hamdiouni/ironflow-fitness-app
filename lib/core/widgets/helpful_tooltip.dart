import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// Enhanced tooltip widget with helpful hints.
class HelpfulTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final Duration showDuration;
  final TextStyle? textStyle;

  const HelpfulTooltip({
    required this.message,
    required this.child,
    this.showDuration = const Duration(seconds: 4),
    this.textStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      showDuration: showDuration,
      textStyle: textStyle ??
          const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      child: child,
    );
  }
}

/// Input field with helpful hint text.
class HintedInputField extends StatelessWidget {
  final String label;
  final String hint;
  final String? helperText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const HintedInputField({
    required this.label,
    required this.hint,
    this.helperText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            helperText: helperText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingSmall,
            ),
          ),
        ),
      ],
    );
  }
}

/// Onboarding hint widget for new features.
class OnboardingHint extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onDismiss;
  final bool showDismissButton;

  const OnboardingHint({
    required this.title,
    required this.description,
    required this.icon,
    this.onDismiss,
    this.showDismissButton = true,
    super.key,
  });

  @override
  State<OnboardingHint> createState() => _OnboardingHintState();
}

class _OnboardingHintState extends State<OnboardingHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_animation),
        child: AppTheme.glassmorphicCard(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    widget.icon,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget.showDismissButton)
                    GestureDetector(
                      onTap: () {
                        _controller.reverse().then((_) {
                          widget.onDismiss?.call();
                        });
                      },
                      child: const Icon(Icons.close, size: 20),
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                widget.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Info badge for displaying helpful information.
class InfoBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const InfoBadge({
    required this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: textColor ?? AppTheme.primaryColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: textColor ?? AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
