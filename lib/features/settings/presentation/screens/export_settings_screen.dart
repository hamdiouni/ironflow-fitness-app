import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_theme.dart';
import '../../domain/usecases/simple_json_export_use_case.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../../../nutrition/presentation/providers/nutrition_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Export settings screen for data export functionality.
///
/// Allows users to:
/// - Export workouts to CSV/JSON
/// - Export nutrition to CSV/JSON
/// - Export all data to JSON/ZIP
/// - Share exported files
///
/// **Validates: Requirements 8.1**
class ExportSettingsScreen extends ConsumerStatefulWidget {
  const ExportSettingsScreen({super.key});

  @override
  ConsumerState<ExportSettingsScreen> createState() => _ExportSettingsScreenState();
}

class _ExportSettingsScreenState extends ConsumerState<ExportSettingsScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        children: [
          // Export description
          AppTheme.glassmorphicCard(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export Your Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                const Text(
                  'Export your fitness data in standard formats for backup, migration, or external analysis.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // Workout exports
          _ExportSection(
            title: 'Workout Data',
            children: [
              _ExportOption(
                title: 'Export Workouts (JSON)',
                subtitle: 'Structured format for migration and backup',
                icon: Icons.code,
                onTap: _isExporting ? null : () => _exportWorkouts(),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // Nutrition exports
          _ExportSection(
            title: 'Nutrition Data',
            children: [
              _ExportOption(
                title: 'Export Nutrition (JSON)',
                subtitle: 'Structured format for migration and backup',
                icon: Icons.code,
                onTap: _isExporting ? null : () => _exportNutrition(),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // Complete data exports
          _ExportSection(
            title: 'Complete Backup',
            children: [
              _ExportOption(
                title: 'Export All Data (JSON)',
                subtitle: 'Complete backup in JSON format',
                icon: Icons.backup,
                onTap: _isExporting ? null : () => _exportAllData(),
              ),
            ],
          ),

          if (_isExporting) ...[
            const SizedBox(height: AppTheme.spacingLarge),
            AppTheme.glassmorphicCard(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),
                  const Text('Exporting data...'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _exportWorkouts() async {
    setState(() => _isExporting = true);

    try {
      final workoutRepository = ref.read(workoutRepositoryProvider);
      final nutritionRepository = ref.read(nutritionRepositoryProvider);
      final authRepository = ref.read(authRepositoryProvider);
      
      final exportUseCase = SimpleJsonExportUseCase(
        workoutRepository,
        nutritionRepository,
        authRepository,
      );

      final filePath = await exportUseCase.exportWorkoutsToJSON();
      await _shareFile(filePath, 'Workout data exported successfully!');
    } catch (e) {
      _showErrorDialog('Failed to export workout data: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportNutrition() async {
    setState(() => _isExporting = true);

    try {
      final workoutRepository = ref.read(workoutRepositoryProvider);
      final nutritionRepository = ref.read(nutritionRepositoryProvider);
      final authRepository = ref.read(authRepositoryProvider);
      
      final exportUseCase = SimpleJsonExportUseCase(
        workoutRepository,
        nutritionRepository,
        authRepository,
      );

      final filePath = await exportUseCase.exportNutritionToJSON();
      await _shareFile(filePath, 'Nutrition data exported successfully!');
    } catch (e) {
      _showErrorDialog('Failed to export nutrition data: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportAllData() async {
    setState(() => _isExporting = true);

    try {
      final workoutRepository = ref.read(workoutRepositoryProvider);
      final nutritionRepository = ref.read(nutritionRepositoryProvider);
      final authRepository = ref.read(authRepositoryProvider);
      
      final exportUseCase = SimpleJsonExportUseCase(
        workoutRepository,
        nutritionRepository,
        authRepository,
      );

      final filePath = await exportUseCase.exportAllDataToJSON();
      await _shareFile(filePath, 'Complete data backup exported successfully!');
    } catch (e) {
      _showErrorDialog('Failed to export all data: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _shareFile(String filePath, String successMessage) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to share file: $e');
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class _ExportSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ExportSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        AppTheme.glassmorphicCard(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ExportOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _ExportOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingSmall),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSmall),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: onTap != null ? AppTheme.textSecondary : AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}