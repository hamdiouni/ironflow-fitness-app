import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_providers.dart';

/// Screen for managing privacy settings, telemetry permissions, and data deletion.
///
/// Complies with Apple Store Guideline 5.1.1(v) and Google Play User Data policies:
/// - Provides two distinct actions: (a) Purge Local Data on Device, and (b) Delete Account & All Data.
/// - Requires type-to-confirm verification (typing "DELETE").
/// - Handles re-authentication and `requires-recent-login` safely.
/// - In-app privacy policy display and compliance documentation.
class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _analyticsEnabled = true;
  bool _crashReportingEnabled = true;
  bool _dataSharing = false;
  bool _aiPersonalizationConsent = false;
  bool _isLoading = true;
  bool _isProcessingAction = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
      _crashReportingEnabled = prefs.getBool('crash_reporting_enabled') ?? true;
      _dataSharing = prefs.getBool('data_sharing_enabled') ?? false;
      _aiPersonalizationConsent = prefs.getBool('ai_personalization_consent') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('analytics_enabled', _analyticsEnabled);
    await prefs.setBool('crash_reporting_enabled', _crashReportingEnabled);
    await prefs.setBool('data_sharing_enabled', _dataSharing);
    await prefs.setBool('ai_personalization_consent', _aiPersonalizationConsent);
  }

  // --- ACTION A: PURGE LOCAL DATA ON THIS DEVICE ---

  Future<void> _showPurgeLocalDataFlow() async {
    final tokens = AppThemeTokens.of(context);
    final confirmed = await _showTypeToConfirmDialog(
      title: 'PURGE LOCAL DEVICE DATA',
      subtitle: 'ERADICATE LOCAL TELEMETRY WHILE KEEPING ACCOUNT ACTIVE',
      accentColor: tokens.warning,
      consequences: const [
        'Permanently delete all workouts, sets, and exercise history stored on this device',
        'Permanently delete all nutrition logs, meals, and macronutrient targets',
        'Permanently delete all body weight measurements and local progress photos',
        'Clear all safety backup snapshots and export files',
        'Clear all AI coaching chat history and personalization caches',
        'Cancel all active rest timers and scheduled workout notifications',
      ],
      notice: 'Your user account will remain active. You can log in on this or another device to start fresh.',
      confirmButtonText: 'PURGE LOCAL DATA',
    );

    if (confirmed != true) return;

    setState(() => _isProcessingAction = true);
    try {
      final currentUser = await ref.read(authRepositoryProvider).getCurrentUser();
      final userId = currentUser?.id ?? '';

      final useCase = ref.read(deleteUserDataUseCaseProvider);
      final result = await useCase.call(userId);

      if (!mounted) return;
      if (result.success) {
        await AppHaptics.shared.buttonPress();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: tokens.warning,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        await AppHaptics.shared.error();
        _showErrorDialog('Local Purge Failed', result.message);
      }
    } catch (e) {
      await AppHaptics.shared.error();
      _showErrorDialog('Local Purge Error', e.toString());
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  // --- ACTION B: DELETE ACCOUNT & ALL DATA ---

  Future<void> _showDeleteAccountFlow() async {
    final tokens = AppThemeTokens.of(context);

    // Step 1: Explain consequences and require typing "DELETE"
    final confirmed = await _showTypeToConfirmDialog(
      title: 'DELETE ACCOUNT & ALL DATA',
      subtitle: 'PERMANENT, IRREVERSIBLE TERMINATION OF ACCOUNT AND TELEMETRY',
      accentColor: tokens.error,
      consequences: const [
        'Permanently delete your user account from authentication servers',
        'Purge all remote cloud profile data and synchronization records',
        'Permanently eradicate all local workouts, sets, exercises, and routines',
        'Permanently delete all nutrition logs, meals, and macro histories',
        'Permanently delete all body measurements and progress photos',
        'Wipe all encrypted safety snapshots and authentication tokens from secure storage',
      ],
      notice: 'This action is PERMANENT and CANNOT BE UNDONE. You will need to re-authenticate with your password to verify ownership before deletion.',
      confirmButtonText: 'CONTINUE TO RE-AUTH',
    );

    if (confirmed != true) return;

    // Step 2: Prompt for re-authentication
    final currentUser = await ref.read(authRepositoryProvider).getCurrentUser();
    if (currentUser == null) {
      _showErrorDialog('Authentication Required', 'No active user session found to delete.');
      return;
    }

    final reauthData = await _showReauthenticationDialog(currentUser.email);
    if (reauthData == null) return;

    // Step 3: Execute permanent deletion pipeline
    setState(() => _isProcessingAction = true);
    try {
      final useCase = ref.read(deleteAccountUseCaseProvider);
      final result = await useCase.call(
        userId: currentUser.id,
        password: reauthData['password'],
        isGoogleAuth: reauthData['isGoogle'] == true,
      );
      if (!mounted) return;

      if (result.success) {
        await AppHaptics.shared.buttonPress();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: tokens.error,
              duration: const Duration(seconds: 5),
            ),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } else {
        await AppHaptics.shared.error();
        _showErrorDialog(
          result.requiresRecentLogin ? 'Recent Login Required' : 'Account Deletion Failed',
          result.requiresRecentLogin
              ? 'Security policy requires a recent login to delete this account. Please sign out, log back in, and retry the deletion.'
              : result.message,
        );
      }
    } catch (e) {
      await AppHaptics.shared.error();
      _showErrorDialog('Deletion Pipeline Error', e.toString());
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  // --- RE-AUTHENTICATION DIALOG ---

  Future<Map<String, dynamic>?> _showReauthenticationDialog(String userEmail) async {
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
              side: BorderSide(color: tokens.error.withValues(alpha: 0.5), width: 1.5),
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
                      prefixIcon: Icon(Icons.password_rounded, color: tokens.error, size: 20),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  final pw = passwordController.text;
                  if (pw.isEmpty) {
                    setDialogState(() => localError = 'Please enter your account password.');
                    return;
                  }
                  Navigator.of(dialogCtx).pop({'password': pw, 'isGoogle': false});
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

  // --- TYPE TO CONFIRM MODAL ---

  Future<bool?> _showTypeToConfirmDialog({
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
              side: BorderSide(color: accentColor.withValues(alpha: 0.6), width: 1.5),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: accentColor, size: 24),
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
                          Text('• ', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
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
                      hintStyle: TextStyle(color: tokens.textMuted.withValues(alpha: 0.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: canConfirm ? () => Navigator.of(dialogCtx).pop(true) : null,
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

  // --- PRIVACY POLICY MODAL ---

  void _showPrivacyPolicyModal() {
    final tokens = AppThemeTokens.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: tokens.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
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
                    body: 'All workout telemetry, sets, repetitions, Rate of Perceived Exertion (RPE), nutrition logs, and body measurements remain strictly on your personal device by default.',
                    tokens: tokens,
                  ),
                  _policySection(
                    title: '2. External Transmissions & Integrations',
                    body: '• Firebase Authentication: Secure credential management and token refresh.\n'
                        '• Firebase Analytics & Crashlytics: Anonymous diagnostics only (toggleable below).\n'
                        '• AI Coaching: Dispatches prompts strictly when AI Personalization Consent is toggled ON. No API keys in release builds.\n'
                        '• YouTube Demonstrations: Embeds load ONLY when you tap "Play". Zero tracking or background loading before tap.',
                    tokens: tokens,
                  ),
                  _policySection(
                    title: '3. Store Deletion Compliance',
                    body: 'In accordance with Apple Guideline 5.1.1(v) and Google Play policies, you can wipe your local data or permanently destroy your account and all records at any time from this screen.',
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
                              const ClipboardData(text: AppConstants.privacyPolicyUrl),
                            );
                            await AppHaptics.shared.selectionChanged();
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: const Text('Privacy policy URL copied to clipboard'),
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

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: tokens.canvas,
        appBar: AppBar(
          backgroundColor: tokens.canvas,
          title: const Text('PRIVACY & TELEMETRY'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRIVACY & TELEMETRY',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: tokens.textPrimary,
              ),
            ),
            Text(
              'DATA SOVEREIGNTY & DELETION CONTROLS',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: tokens.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          if (_isProcessingAction) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(color: tokens.warning.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: tokens.warning),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Executing privacy deletion sequence...',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 13,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Telemetry & Permissions Section
          _buildSectionHeader('TELEMETRY & PERMISSIONS', tokens),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Diagnostics & Crash Telemetry',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Automatically submit crash traces to Firebase Crashlytics to resolve bugs',
                    style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                  ),
                  value: _crashReportingEnabled,
                  activeColor: tokens.kineticAccent,
                  onChanged: (val) async {
                    setState(() => _crashReportingEnabled = val);
                    await _saveSettings();
                  },
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                SwitchListTile(
                  title: Text(
                    'Usage Analytics',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Share anonymous screen engagement metrics to guide feature upgrades',
                    style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                  ),
                  value: _analyticsEnabled,
                  activeColor: tokens.kineticAccent,
                  onChanged: (val) async {
                    setState(() => _analyticsEnabled = val);
                    await _saveSettings();
                  },
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                SwitchListTile(
                  title: Text(
                    'Anonymous Research Sharing',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Share anonymized aggregate workout volume stats for fitness science',
                    style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                  ),
                  value: _dataSharing,
                  activeColor: tokens.kineticAccent,
                  onChanged: (val) async {
                    setState(() => _dataSharing = val);
                    await _saveSettings();
                  },
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                SwitchListTile(
                  title: Text(
                    'AI Personalization Consent',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Allow AI Coach to inspect local training telemetry for tailored recommendations',
                    style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                  ),
                  value: _aiPersonalizationConsent,
                  activeColor: tokens.kineticAccent,
                  onChanged: (val) async {
                    setState(() => _aiPersonalizationConsent = val);
                    await _saveSettings();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Management Section
          _buildSectionHeader('DATA MANAGEMENT', tokens),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                _buildActionTile(
                  title: 'Telemetry Archive & Restore',
                  subtitle: 'Export workouts and nutrition in CSV/JSON, or restore backups',
                  icon: Icons.swap_vert_rounded,
                  accentColor: tokens.cyanAccent,
                  tokens: tokens,
                  onTap: () => Navigator.pushNamed(context, '/settings/export'),
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _buildActionTile(
                  title: 'Privacy Policy & Charter',
                  subtitle: 'Review local data sovereignty and external transmission guarantees',
                  icon: Icons.policy_rounded,
                  accentColor: tokens.kineticAccent,
                  tokens: tokens,
                  onTap: _showPrivacyPolicyModal,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Danger Zone Section
          _buildSectionHeader('DANGER ZONE (DELETION CONTROLS)', tokens),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.error.withValues(alpha: 0.3), width: 1),
            ),
            child: Column(
              children: [
                _buildActionTile(
                  title: 'Purge Local Device Data',
                  subtitle: 'Wipe all workouts, logs, photos, and snapshots while keeping account',
                  icon: Icons.phonelink_erase_rounded,
                  accentColor: tokens.warning,
                  tokens: tokens,
                  onTap: _isProcessingAction ? null : _showPurgeLocalDataFlow,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _buildActionTile(
                  title: 'Delete Account & All Data',
                  subtitle: 'Permanently destroy account, cloud records, and all device telemetry',
                  icon: Icons.delete_forever_rounded,
                  accentColor: tokens.error,
                  tokens: tokens,
                  onTap: _isProcessingAction ? null : _showDeleteAccountFlow,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppThemeTokens tokens) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: AppTypography.displayFontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: tokens.textMuted,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required AppThemeTokens tokens,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tokens.card,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(color: tokens.borderSubtle, width: 1),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 11,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: tokens.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}