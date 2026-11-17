import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import 'app_card.dart';

/// Direction 4 compliant non-intrusive Medical & Fitness Disclaimer Banner (Wave 6.2 — LEG-03).
///
/// Prominently displays legal protections for client deployment, certifying
/// that AI coaching responses and recovery estimates are educational guidelines
/// rather than licensed clinical advice.
class MedicalDisclaimerBanner extends StatelessWidget {
  const MedicalDisclaimerBanner({
    super.key,
    this.compact = false,
    this.customText,
    this.onDismiss,
  });

  /// When true, renders a slim single-line banner suitable for headers or sheets.
  final bool compact;

  /// Custom disclaimer text override.
  final String? customText;

  /// Optional callback to dismiss the banner.
  final VoidCallback? onDismiss;

  static const String defaultMessage =
      'Progression Tracker provides workout tracking and educational fitness estimates, not medical advice. Always consult a healthcare professional before starting or modifying an exercise regimen.';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: tokens.info.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: tokens.info.withValues(alpha: 0.20),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: tokens.info,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                customText ?? 'Estimate only — not medical advice. Listen to your body.',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: tokens.textSecondary,
                  height: 1.25,
                ),
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: tokens.textMuted,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacings.md),
      backgroundColor: tokens.info.withValues(alpha: 0.07),
      borderColor: tokens.info.withValues(alpha: 0.18),
      borderRadius: 14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: tokens.info.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.health_and_safety_outlined,
              size: 18,
              color: tokens.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical & Fitness Notice',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  customText ?? defaultMessage,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: tokens.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: tokens.textMuted,
              onPressed: onDismiss,
            ),
          ],
        ],
      ),
    );
  }
}
