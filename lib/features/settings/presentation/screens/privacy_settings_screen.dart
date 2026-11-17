import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/build_stamp.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/record_ownership.dart';
import '../../../../core/widgets/telemetry_consent_dialog.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import '../../../ai/presentation/providers/ai_provider.dart';
import '../../../auth/presentation/providers/auth_notifier.dart'
    show currentUserIdProvider;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_providers.dart';
import '../widgets/export/export_settings_tiles.dart';
import '../widgets/privacy/privacy_dialogs_and_sheets.dart';

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
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _analyticsEnabled = false;
  bool _crashReportingEnabled = false;
  bool _dataSharing = false;
  bool _aiPersonalizationConsent = false;
  bool _hasRecordedTelemetryConsent = false;
  bool _isLoading = true;
  bool _isProcessingAction = false;

  String get _effectiveUserId =>
      ref.read(currentUserIdProvider) ?? RecordOwnershipRules.guestUserId;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(privacyPreferencesRepositoryProvider);
    final snapshot = await repo.loadSettings(userId: _effectiveUserId);
    if (!mounted) return;
    setState(() {
      _analyticsEnabled = snapshot.analyticsEnabled;
      _crashReportingEnabled = snapshot.crashReportingEnabled;
      _dataSharing = snapshot.dataSharingEnabled;
      _aiPersonalizationConsent = snapshot.aiPersonalizationConsent;
      _hasRecordedTelemetryConsent = snapshot.hasRecordedTelemetryConsent;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final repo = ref.read(privacyPreferencesRepositoryProvider);
    await repo.saveSettings(
      userId: _effectiveUserId,
      analyticsEnabled: _analyticsEnabled,
      crashReportingEnabled: _crashReportingEnabled,
      dataSharingEnabled: _dataSharing,
      aiPersonalizationConsent: _aiPersonalizationConsent,
    );
    if (mounted) {
      setState(() => _hasRecordedTelemetryConsent = true);
    }
  }

  Future<void> _showPurgeLocalDataFlow() async {
    final tokens = AppThemeTokens.of(context);
    final confirmed = await showPrivacyTypeToConfirmDialog(
      context,
      title: 'PURGE LOCAL DEVICE DATA',
      subtitle: 'ERASE LOCAL DATA WHILE KEEPING ACCOUNT ACTIVE',
      accentColor: tokens.warning,
      consequences: const [
        'Permanently delete all workouts, sets, and exercise history stored on this device',
        'Permanently delete all nutrition logs, meals, and macronutrient targets',
        'Permanently delete all body weight measurements and local progress photos',
        'Clear all safety backup snapshots and export files',
        'Clear all AI coaching chat history and personalization caches',
        'Cancel all active rest timers and scheduled workout notifications',
      ],
      notice:
          'Your user account will remain active. You can log in on this or another device to start fresh.',
      confirmButtonText: 'PURGE LOCAL DATA',
    );

    if (confirmed != true) return;

    setState(() => _isProcessingAction = true);
    try {
      final currentUser =
          await ref.read(authRepositoryProvider).getCurrentUser();
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
        if (mounted) {
          showPrivacyErrorDialog(context, 'Local Purge Failed', result.message);
        }
      }
    } catch (e) {
      await AppHaptics.shared.error();
      if (mounted) {
        showPrivacyErrorDialog(context, 'Local Purge Error', e.toString());
      }
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  Future<void> _showDeleteAccountFlow() async {
    final tokens = AppThemeTokens.of(context);

    final confirmed = await showPrivacyTypeToConfirmDialog(
      context,
      title: 'DELETE ACCOUNT & ALL DATA',
      subtitle: 'PERMANENT, IRREVERSIBLE DELETION OF ACCOUNT AND DATA',
      accentColor: tokens.error,
      consequences: const [
        'Permanently delete your user account from authentication servers',
        'Purge all remote cloud profile data and synchronization records',
        'Permanently eradicate all local workouts, sets, exercises, and routines',
        'Permanently delete all nutrition logs, meals, and macro histories',
        'Permanently delete all body measurements and progress photos',
        'Wipe all encrypted safety snapshots and authentication tokens from secure storage',
      ],
      notice:
          'This action is PERMANENT and CANNOT BE UNDONE. You will need to re-authenticate with your password to verify ownership before deletion.',
      confirmButtonText: 'CONTINUE TO RE-AUTH',
    );

    if (confirmed != true) return;

    final currentUser =
        await ref.read(authRepositoryProvider).getCurrentUser();
    if (!mounted) return;
    if (currentUser == null) {
      showPrivacyErrorDialog(
        context,
        'Authentication Required',
        'No active user session found to delete.',
      );
      return;
    }

    final reauthData =
        await showPrivacyReauthenticationDialog(context, currentUser.email);
    if (reauthData == null) return;

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
        if (mounted) {
          showPrivacyErrorDialog(
            context,
            result.requiresRecentLogin
                ? 'Recent Login Required'
                : 'Account Deletion Failed',
            result.requiresRecentLogin
                ? 'Security policy requires a recent login to delete this account. Please sign out, log back in, and retry the deletion.'
                : result.message,
          );
        }
      }
    } catch (e) {
      await AppHaptics.shared.error();
      if (mounted) {
        showPrivacyErrorDialog(
          context,
          'Deletion Pipeline Error',
          e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: tokens.canvas,
        appBar: AppBar(
          backgroundColor: tokens.canvas,
          title: const Text('PRIVACY & DATA'),
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
              'PRIVACY & DATA',
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
                border: Border.all(
                  color: tokens.warning.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tokens.warning,
                    ),
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

          // Privacy & Permissions Section
          ExportSectionHeader(title: 'DATA & PERMISSIONS', tokens: tokens),
          if (!_hasRecordedTelemetryConsent)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(color: tokens.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.privacy_tip_outlined,
                        size: 18,
                        color: tokens.kineticAccent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Analytics & Crashlytics default OFF until you opt in.',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 12,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        await showDialog<void>(
                          context: context,
                          builder: (ctx) => TelemetryConsentScreen(
                            onDecisionSaved: () => Navigator.of(ctx).pop(),
                          ),
                        );
                        await _loadSettings();
                      },
                      child: const Text('REVIEW CONSENT'),
                    ),
                  ),
                ],
              ),
            ),
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
                    'Diagnostics & Crash Reports',
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
                  activeThumbColor: tokens.kineticAccent,
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
                  activeThumbColor: tokens.kineticAccent,
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
                  activeThumbColor: tokens.kineticAccent,
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
                    'Allow AI Coach to read local training data for tailored recommendations',
                    style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                  ),
                  value: _aiPersonalizationConsent,
                  activeThumbColor: tokens.kineticAccent,
                  onChanged: (val) async {
                    setState(() => _aiPersonalizationConsent = val);
                    await ref
                        .read(aiPersonalizationConsentProvider.notifier)
                        .setConsent(val);
                    await _saveSettings();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Management Section
          ExportSectionHeader(title: 'DATA MANAGEMENT', tokens: tokens),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                ExportActionTile(
                  title: 'Data Archive & Restore',
                  subtitle:
                      'Export workouts and nutrition in CSV/JSON, or restore backups',
                  icon: Icons.swap_vert_rounded,
                  accentColor: tokens.cyanAccent,
                  tokens: tokens,
                  onTap: () => Navigator.pushNamed(context, '/settings/export'),
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                ExportActionTile(
                  title: 'Privacy Policy & Charter',
                  subtitle:
                      'Review local data sovereignty and external transmission guarantees',
                  icon: Icons.policy_rounded,
                  accentColor: tokens.kineticAccent,
                  tokens: tokens,
                  onTap: () => showPrivacyPolicySheet(context),
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                ExportActionTile(
                  title: 'Data Attributions & Open Database Notices',
                  subtitle:
                      'Open Food Facts (ODbL), USDA FoodData Central, and bundled typography',
                  icon: Icons.menu_book_outlined,
                  accentColor: tokens.warning,
                  tokens: tokens,
                  onTap: () => showAttributionsSheet(context),
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                ExportActionTile(
                  title: 'Open Source & Font Licenses',
                  subtitle:
                      'View bundled OFL font licenses (Inter, Space Grotesk) and package notices',
                  icon: Icons.description_outlined,
                  accentColor: tokens.cyanAccent,
                  tokens: tokens,
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'IronFlow (Progression Tracker)',
                    applicationVersion: BuildStamp.version,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Danger Zone Section
          ExportSectionHeader(
            title: 'DANGER ZONE (DELETION CONTROLS)',
            tokens: tokens,
          ),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(
                color: tokens.error.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                ExportActionTile(
                  title: 'Purge Local Device Data',
                  subtitle:
                      'Wipe all workouts, logs, photos, and snapshots while keeping account',
                  icon: Icons.phonelink_erase_rounded,
                  accentColor: tokens.warning,
                  tokens: tokens,
                  onTap:
                      _isProcessingAction ? null : _showPurgeLocalDataFlow,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                ExportActionTile(
                  title: 'Delete Account & All Data',
                  subtitle:
                      'Permanently delete account, cloud records, and all device data',
                  icon: Icons.delete_forever_rounded,
                  accentColor: tokens.error,
                  tokens: tokens,
                  onTap:
                      _isProcessingAction ? null : _showDeleteAccountFlow,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
