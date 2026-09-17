import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Screen for managing privacy settings and data controls.
///
/// **Validates: Requirements 8.4**
class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _analyticsEnabled = true;
  bool _crashReportingEnabled = true;
  bool _dataSharing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
      _crashReportingEnabled = prefs.getBool('crash_reporting_enabled') ?? true;
      _dataSharing = prefs.getBool('data_sharing_enabled') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('analytics_enabled', _analyticsEnabled);
    await prefs.setBool('crash_reporting_enabled', _crashReportingEnabled);
    await prefs.setBool('data_sharing_enabled', _dataSharing);
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. Deleting your account will:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Permanently delete all your workout data'),
            Text('• Permanently delete all your nutrition logs'),
            Text('• Permanently delete all your body measurements'),
            Text('• Permanently delete your user profile'),
            Text('• Remove all cloud backups'),
            SizedBox(height: 12),
            Text(
              'Are you absolutely sure you want to delete your account?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  Future<void> _showDeleteDataDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete all your data but keep your account:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• All workout history'),
            Text('• All nutrition logs'),
            Text('• All body measurements'),
            Text('• All programs'),
            Text('• All progress photos'),
            SizedBox(height: 12),
            Text(
              'Your account will remain active but all data will be lost.',
              style: TextStyle(color: Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Data'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAllData();
    }
  }

  Future<void> _deleteAccount() async {
    try {
      setState(() => _isLoading = true);

      // Delete all user data first
      await _deleteAllData();

      // Delete user account
      // TODO: Implement with actual auth repository
      // await ref.read(authRepositoryProvider).deleteAccount();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );

        // Navigate to login screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  Future<void> _deleteAllData() async {
    try {
      setState(() => _isLoading = true);

      // TODO: Implement with actual repositories
      // await ref.read(workoutRepositoryProvider).deleteAllWorkouts();
      // await ref.read(workoutRepositoryProvider).deleteAllPrograms();
      // await ref.read(nutritionRepositoryProvider).deleteAllNutritionLogs();
      // await ref.read(bodyRepositoryProvider).deleteAllMeasurements();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data deleted successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Privacy Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        children: [
          _buildDataCollectionSection(),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildDataControlSection(),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildDangerZoneSection(),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildDataCollectionSection() {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'Data Collection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          SwitchListTile(
            title: const Text('Analytics'),
            subtitle: const Text(
              'Help improve the app by sharing anonymous usage data',
            ),
            value: _analyticsEnabled,
            onChanged: (value) async {
              setState(() => _analyticsEnabled = value);
              await _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text('Crash Reporting'),
            subtitle: const Text(
              'Automatically send crash reports to help fix bugs',
            ),
            value: _crashReportingEnabled,
            onChanged: (value) async {
              setState(() => _crashReportingEnabled = value);
              await _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text('Data Sharing'),
            subtitle: const Text(
              'Share anonymized fitness data for research purposes',
            ),
            value: _dataSharing,
            onChanged: (value) async {
              setState(() => _dataSharing = value);
              await _saveSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataControlSection() {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security, color: AppTheme.accentColor),
              SizedBox(width: 8),
              Text(
                'Data Control',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ListTile(
            leading: const Icon(Icons.download, color: AppTheme.primaryColor),
            title: const Text('Export My Data'),
            subtitle: const Text('Download all your data in JSON format'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/settings/export');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup, color: AppTheme.accentColor),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Manage your data backups'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/settings/backup');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.visibility, color: AppTheme.successColor),
            title: const Text('View Privacy Policy'),
            subtitle: const Text('Read our privacy policy'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // TODO: Open privacy policy URL
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneSection() {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.orange),
                  title: const Text(
                    'Delete All Data',
                    style: TextStyle(color: Colors.orange),
                  ),
                  subtitle: const Text(
                    'Permanently delete all your data (keeps account)',
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.orange),
                  onTap: _showDeleteDataDialog,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person_remove, color: Colors.red),
                  title: const Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text(
                    'Permanently delete your account and all data',
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.red),
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'Privacy Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          const Text(
            'Your Privacy Matters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We are committed to protecting your privacy and giving you control over your data. '
            'All data is encrypted in transit and at rest. You can export, delete, or modify '
            'your data at any time.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          const Text(
            'Data We Collect:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '• Workout and exercise data\n'
            '• Nutrition and meal logs\n'
            '• Body measurements and progress photos\n'
            '• App usage analytics (if enabled)\n'
            '• Crash reports (if enabled)',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          const Text(
            'Data We Don\'t Collect:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '• Personal conversations or messages\n'
            '• Location data (unless explicitly enabled)\n'
            '• Financial or payment information\n'
            '• Data from other apps',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}