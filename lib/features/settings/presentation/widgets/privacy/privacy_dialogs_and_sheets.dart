import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_theme.dart';
import '../../../../../shared/presentation/services/app_haptics.dart';

Future<Map<String, dynamic>?> showPrivacyReauthenticationDialog(
  BuildContext context,
  String userEmail,
) async {
  final tokens = AppThemeTokens.of(context);
  final passwordController = TextEditingController();
  String? localError;

  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        return AlertDialog(
          backgroundColor: tokens.panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            side: BorderSide(
              color: tokens.error.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.lock_person_rounded, color: tokens.error, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'SECURITY RE-AUTHENTICATION',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm ownership of account $userEmail before permanent deletion.',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12,
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  autofocus: true,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 14,
                    color: tokens.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Account Password',
                    labelStyle: TextStyle(color: tokens.textMuted),
                    prefixIcon: Icon(
                      Icons.password_rounded,
                      color: tokens.error,
                      size: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      borderSide: BorderSide(color: tokens.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      borderSide: BorderSide(color: tokens.error, width: 1.5),
                    ),
                  ),
                ),
                if (localError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    localError!,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12,
                      color: tokens.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(null),
              child: Text('CANCEL', style: TextStyle(color: tokens.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.error,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () {
                final pw = passwordController.text;
                if (pw.isEmpty) {
                  setDialogState(
                    () => localError = 'Please enter your account password.',
                  );
                  return;
                }
                Navigator.of(dialogCtx)
                    .pop({'password': pw, 'isGoogle': false});
              },
              child: const Text(
                'CONFIRM & DESTROY',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    ),
  );
}

Future<bool?> showPrivacyTypeToConfirmDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required Color accentColor,
  required List<String> consequences,
  required String notice,
  required String confirmButtonText,
}) async {
  final tokens = AppThemeTokens.of(context);
  final textController = TextEditingController();
  bool canConfirm = false;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        return AlertDialog(
          backgroundColor: tokens.panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            side: BorderSide(
              color: accentColor.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: accentColor,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: tokens.textMuted,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This action has the following consequences:',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                for (final item in consequences)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 11,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: tokens.card,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(color: tokens.borderSubtle),
                  ),
                  child: Text(
                    notice,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 11,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'To confirm, type DELETE in the box below:',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: textController,
                  autofocus: true,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: tokens.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'DELETE',
                    hintStyle: TextStyle(
                      color: tokens.textMuted.withValues(alpha: 0.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      borderSide: BorderSide(color: tokens.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      borderSide: BorderSide(color: accentColor, width: 1.5),
                    ),
                  ),
                  onChanged: (val) {
                    final matches = val.trim() == 'DELETE';
                    if (matches != canConfirm) {
                      setDialogState(() => canConfirm = matches);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: Text('CANCEL', style: TextStyle(color: tokens.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canConfirm ? accentColor : tokens.card,
                foregroundColor: canConfirm ? Colors.white : tokens.textMuted,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed:
                  canConfirm ? () => Navigator.of(dialogCtx).pop(true) : null,
              child: Text(
                confirmButtonText,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    ),
  );
}

void showPrivacyPolicySheet(BuildContext context) {
  final tokens = AppThemeTokens.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: tokens.canvas,
    shape: RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
    ),
    builder: (sheetCtx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'PRIVACY POLICY & TELEMETRY CHARTER',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'LOCAL DATA SOVEREIGNTY & EXTERNAL TRANSMISSIONS',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: tokens.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                _policySection(
                  title: '1. Local-First Architecture',
                  body:
                      'All workout telemetry, sets, repetitions, Rate of Perceived Exertion (RPE), nutrition logs, and body measurements remain strictly on your personal device by default.',
                  tokens: tokens,
                ),
                _policySection(
                  title: '2. External Transmissions & Integrations',
                  body:
                      '• Firebase Authentication: Secure credential management and token refresh.\n'
                      '• Firebase Analytics & Crashlytics: Anonymous diagnostics only (toggleable below).\n'
                      '• AI Coaching: Dispatches prompts strictly when AI Personalization Consent is toggled ON. No API keys in release builds.\n'
                      '• YouTube Demonstrations: Embeds load ONLY when you tap "Play". Zero tracking or background loading before tap.',
                  tokens: tokens,
                ),
                _policySection(
                  title: '3. Store Deletion Compliance',
                  body:
                      'In accordance with Apple Guideline 5.1.1(v) and Google Play policies, you can wipe your local data or permanently destroy your account and all records at any time from this screen.',
                  tokens: tokens,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tokens.panel,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(color: tokens.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Public Web Policy & Deletion Link:',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        AppConstants.privacyPolicyUrl,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 12,
                          color: tokens.kineticAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('COPY POLICY URL'),
                        onPressed: () async {
                          await Clipboard.setData(
                            const ClipboardData(
                              text: AppConstants.privacyPolicyUrl,
                            ),
                          );
                          await AppHaptics.shared.selectionChanged();
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Privacy policy URL copied to clipboard',
                                ),
                                backgroundColor: tokens.kineticAccent,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokens.panel,
                          foregroundColor: tokens.textPrimary,
                        ),
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                        child: const Text('CLOSE'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _policySection({
  required String title,
  required String body,
  required AppThemeTokens tokens,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: tokens.kineticAccent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 12,
            color: tokens.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

void showPrivacyErrorDialog(
  BuildContext context,
  String title,
  String message,
) {
  final tokens = AppThemeTokens.of(context);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: tokens.panel,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: AppTypography.displayFontFamily,
          color: tokens.error,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          color: tokens.textPrimary,
          fontSize: 13,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('ACKNOWLEDGE'),
        ),
      ],
    ),
  );
}

