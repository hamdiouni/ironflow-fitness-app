import 'package:flutter/material.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/shared/presentation/components/app_button.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

class OnboardingSelectableCard<T> extends StatelessWidget {
  const OnboardingSelectableCard({
    super.key,
    required this.tokens,
    required this.value,
    required this.groupValue,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onSelect,
  });

  final AppThemeTokens tokens;
  final T value;
  final T? groupValue;
  final String code;
  final String title;
  final String subtitle;
  final IconData icon;
  final void Function(T) onSelect;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () {
        AppHaptics.shared.selectionChanged();
        onSelect(value);
      },
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.kineticAccent.withValues(alpha: 0.08)
              : tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(
            color: isSelected ? tokens.kineticAccent : tokens.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? tokens.kineticAccent
                    : tokens.canvas,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.black : tokens.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isSelected
                                ? tokens.kineticAccent
                                : tokens.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        code,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12,
                      color: tokens.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContainerBox extends StatelessWidget {
  const OnboardingContainerBox({
    super.key,
    required this.tokens,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final AppThemeTokens tokens;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: child,
    );
  }
}

class OnboardingUnitChip extends StatelessWidget {
  const OnboardingUnitChip({
    super.key,
    required this.tokens,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemeTokens tokens;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusPill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? tokens.kineticAccent : tokens.canvas,
          borderRadius: BorderRadius.circular(tokens.radiusPill),
          border: Border.all(
            color: isSelected ? tokens.kineticAccent : tokens.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: isSelected ? Colors.black : tokens.textSecondary,
          ),
        ),
      ),
    );
  }
}

class OnboardingMetricSlider extends StatelessWidget {
  const OnboardingMetricSlider({
    super.key,
    required this.tokens,
    required this.label,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final AppThemeTokens tokens;
  final String label;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: tokens.textSecondary,
              ),
            ),
            Text(
              valueText,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: tokens.kineticAccent,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: tokens.kineticAccent,
            inactiveTrackColor: tokens.borderSubtle,
            thumbColor: tokens.kineticAccent,
            overlayColor: tokens.kineticAccent.withValues(alpha: 0.15),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class OnboardingSafetyNotice extends StatelessWidget {
  const OnboardingSafetyNotice({
    super.key,
    required this.tokens,
    required this.icon,
    required this.title,
    required this.message,
  });

  final AppThemeTokens tokens;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.cyanAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: tokens.cyanAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: tokens.cyanAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: tokens.cyanAccent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11,
                    color: tokens.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingBottomNavigation extends StatelessWidget {
  const OnboardingBottomNavigation({
    super.key,
    required this.tokens,
    required this.currentStep,
    required this.totalSteps,
    required this.canProceed,
    required this.onPrevious,
    required this.onNext,
  });

  final AppThemeTokens tokens;
  final int currentStep;
  final int totalSteps;
  final bool canProceed;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(top: BorderSide(color: tokens.borderSubtle, width: 1)),
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              flex: 1,
              child: AppButton(
                label: 'BACK',
                variant: AppButtonVariant.secondary,
                onPressed: onPrevious,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: AppButton(
              label: isLastStep ? 'START PROTOCOL' : 'CONTINUE',
              icon: Icon(
                isLastStep ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                size: 18,
                color: Colors.black,
              ),
              variant: AppButtonVariant.primary,
              onPressed: canProceed ? onNext : null,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSynthesisOverlay extends StatelessWidget {
  const OnboardingSynthesisOverlay({super.key, required this.tokens});

  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: tokens.panel,
            borderRadius: BorderRadius.circular(tokens.radiusPill),
            border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(tokens.kineticAccent),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'INITIALIZING PROTOCOL',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Generating workout program & diet plan...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 11,
                  color: tokens.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingStepContentLayout extends StatelessWidget {
  const OnboardingStepContentLayout({
    super.key,
    required this.stepTitle,
    required this.whyWeAsk,
    required this.children,
  });

  final String stepTitle;
  final String whyWeAsk;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepTitle,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WHY WE ASK: ',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: tokens.kineticAccent,
                ),
              ),
              Expanded(
                child: Text(
                  whyWeAsk,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11,
                    color: tokens.textMuted,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
