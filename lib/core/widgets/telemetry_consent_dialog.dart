import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_theme.dart';
import '../services/telemetry_preferences.dart';

/// Explicit opt-in consent screen/modal for Analytics & Crashlytics.
///
/// Both Analytics and Crashlytics default to **OFF (`false`)** until the user
/// explicitly opts in here or in `PrivacySettingsScreen`.
class TelemetryConsentScreen extends StatefulWidget {
  final VoidCallback? onDecisionSaved;

  const TelemetryConsentScreen({
    super.key,
    this.onDecisionSaved,
  });

  /// Shows the consent modal if the user has not yet recorded a telemetry
  /// consent decision.
  static Future<void> showIfNeeded(
    BuildContext context, {
    SharedPreferences? prefs,
  }) async {
    final alreadyShown = await TelemetryPreferences.hasShownConsentPrompt(prefs);
    if (alreadyShown || !context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TelemetryConsentScreen(
        onDecisionSaved: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  State<TelemetryConsentScreen> createState() => _TelemetryConsentScreenState();
}

class _TelemetryConsentScreenState extends State<TelemetryConsentScreen> {
  bool _analyticsOptIn = false;
  bool _crashlyticsOptIn = false;
  bool _saving = false;

  Future<void> _submit({
    required bool analytics,
    required bool crashlytics,
  }) async {
    setState(() => _saving = true);
    await TelemetryPreferences.recordConsentDecision(
      analyticsEnabled: analytics,
      crashReportingEnabled: crashlytics,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    widget.onDecisionSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return AlertDialog(
      backgroundColor: tokens.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        side: BorderSide(color: tokens.borderSubtle),
      ),
      title: Text(
        'Privacy & Diagnostics Consent',
        style: TextStyle(
          fontFamily: AppTypography.displayFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: tokens.textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics and crash reporting are OFF by default. Your workouts, meals, and body logs stay private and are never included in diagnostics.',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13,
                color: tokens.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Crash Reporting (Crashlytics)',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
              ),
              subtitle: Text(
                'Send anonymous stack traces when the app crashes.',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12,
                  color: tokens.textMuted,
                ),
              ),
              value: _crashlyticsOptIn,
              onChanged: _saving
                  ? null
                  : (val) => setState(() => _crashlyticsOptIn = val),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Usage Analytics',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
              ),
              subtitle: Text(
                'Share anonymous screen and feature usage counts.',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12,
                  color: tokens.textMuted,
                ),
              ),
              value: _analyticsOptIn,
              onChanged: _saving
                  ? null
                  : (val) => setState(() => _analyticsOptIn = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () => _submit(analytics: false, crashlytics: false),
          child: Text(
            'KEEP ALL OFF',
            style: TextStyle(
              color: tokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _saving
              ? null
              : () => _submit(
                    analytics: _analyticsOptIn,
                    crashlytics: _crashlyticsOptIn,
                  ),
          child: const Text('SAVE CHOICES'),
        ),
      ],
    );
  }
}

