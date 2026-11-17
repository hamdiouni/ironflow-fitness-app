import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_theme.dart';
import '../providers/settings_providers.dart';
import '../widgets/export/export_restore_modal.dart';
import '../widgets/export/export_settings_tiles.dart';

/// Stripe screen for Telemetry Data Export & System Restore.
class ExportSettingsScreen extends ConsumerStatefulWidget {
  const ExportSettingsScreen({super.key});

  @override
  ConsumerState<ExportSettingsScreen> createState() =>
      _ExportSettingsScreenState();
}

class _ExportSettingsScreenState extends ConsumerState<ExportSettingsScreen> {
  bool _isProcessing = false;
  String? _statusMessage;
  bool _hasUndoSnapshot = false;

  @override
  void initState() {
    super.initState();
    _checkUndoAvailability();
  }

  Future<void> _checkUndoAvailability() async {
    try {
      final restoreUseCase = ref.read(restoreDataUseCaseProvider);
      final hasUndo = await restoreUseCase.hasUndoSnapshot();
      if (mounted) {
        setState(() {
          _hasUndoSnapshot = hasUndo;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

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
              'EXPORT & BACKUP',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: tokens.textPrimary,
              ),
            ),
            Text(
              'BACKUP, EXPORT & RESTORATION',
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
          // Header info card
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: tokens.card,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(color: tokens.borderSubtle, width: 1),
                  ),
                  child: Icon(
                    Icons.security_rounded,
                    color: tokens.kineticAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOCAL DATA SOVEREIGNTY',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Extract raw metrics into portable CSV or JSON schemas. Restore previous system archives with strict memory pre-validation.',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 12,
                          color: tokens.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Restoration Section
          ExportSectionHeader(title: 'RESTORE ARCHIVE', tokens: tokens),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                ExportActionTile(
                  title: 'Restore From JSON Archive',
                  subtitle:
                      'Pre-validate backup schema, preview counts & choose merge/overwrite',
                  icon: Icons.restore_rounded,
                  accentColor: tokens.cyanAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : () => _openRestoreModal(context),
                ),
                if (_hasUndoSnapshot) ...[
                  Divider(color: tokens.borderSubtle, height: 1),
                  ExportActionTile(
                    title: 'Undo Last Restore',
                    subtitle:
                        'Roll back database to state captured before the most recent restore',
                    icon: Icons.undo_rounded,
                    accentColor: tokens.warning,
                    tokens: tokens,
                    onTap: _isProcessing ? null : _confirmAndUndoRestore,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Complete Backup Section
          ExportSectionHeader(title: 'SYSTEM BACKUP', tokens: tokens),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                ExportActionTile(
                  title: 'Export Full System Backup (JSON)',
                  subtitle:
                      'Complete encrypted snapshot of workouts, nutrition, body & biometrics',
                  icon: Icons.backup_rounded,
                  accentColor: tokens.kineticAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : _exportCompleteBackup,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Workouts Section
          ExportSectionHeader(title: 'WORKOUT DATA', tokens: tokens),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                ExportActionTile(
                  title: 'Export Workouts (CSV)',
                  subtitle:
                      'Tabular format for Excel, Google Sheets, or data science analysis',
                  icon: Icons.table_chart_outlined,
                  accentColor: tokens.kineticAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : _exportWorkoutsCsv,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                ExportActionTile(
                  title: 'Export Workouts (JSON)',
                  subtitle:
                      'Normalized object hierarchy with set entries and timestamps',
                  icon: Icons.code_rounded,
                  accentColor: tokens.kineticAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : _exportWorkoutsJson,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                ExportActionTile(
                  title: 'Export Workout Summary Report (CSV)',
                  subtitle:
                      'Aggregated volume, frequency and monthly distribution stats',
                  icon: Icons.analytics_outlined,
                  accentColor: tokens.kineticAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : _exportWorkoutSummaryCsv,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Nutrition Section
          ExportSectionHeader(title: 'NUTRITION & MACROS', tokens: tokens),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                ExportActionTile(
                  title: 'Export Nutrition Logs (CSV)',
                  subtitle:
                      'Daily records with itemized macros, micros and meal timing',
                  icon: Icons.table_chart_outlined,
                  accentColor: tokens.violetAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : _exportNutritionCsv,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                ExportActionTile(
                  title: 'Export Nutrition Logs (JSON)',
                  subtitle:
                      'Structured format including macro targets and micronutrients',
                  icon: Icons.code_rounded,
                  accentColor: tokens.violetAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : _exportNutritionJson,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                ExportActionTile(
                  title: 'Export Macro Trends Report (CSV)',
                  subtitle:
                      'Longitudinal time-series analysis of daily caloric & macro intake',
                  icon: Icons.timeline_rounded,
                  accentColor: tokens.violetAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : _exportMacroTrendsCsv,
                ),
              ],
            ),
          ),

          // Processing progress indicator
          if (_isProcessing) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(
                  color: tokens.kineticAccent.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tokens.kineticAccent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _statusMessage ?? 'Processing export...',
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
        ],
      ),
    );
  }

  Future<void> _exportWorkoutsCsv() async {
    _startOp('Compiling workout CSV data...');
    try {
      final useCase = ref.read(exportWorkoutsUseCaseProvider);
      final path = await useCase.exportToCSV();
      await _shareFile(path, 'Workout CSV exported successfully');
    } catch (e) {
      _showError('Failed to export workout CSV: $e');
    } finally {
      _endOp();
    }
  }

  Future<void> _exportWorkoutsJson() async {
    _startOp('Compiling workout JSON archive...');
    try {
      final useCase = ref.read(simpleJsonExportUseCaseProvider);
      final path = await useCase.exportWorkoutsToJSON();
      await _shareFile(path, 'Workout JSON exported successfully');
    } catch (e) {
      _showError('Failed to export workout JSON: $e');
    } finally {
      _endOp();
    }
  }

  Future<void> _exportWorkoutSummaryCsv() async {
    _startOp('Generating workout analytics summary...');
    try {
      final useCase = ref.read(exportWorkoutsUseCaseProvider);
      final path = await useCase.exportSummaryToCSV();
      await _shareFile(path, 'Workout summary report exported successfully');
    } catch (e) {
      _showError('Failed to generate workout summary: $e');
    } finally {
      _endOp();
    }
  }

  Future<void> _exportNutritionCsv() async {
    _startOp('Compiling nutrition CSV logs...');
    try {
      final useCase = ref.read(exportNutritionUseCaseProvider);
      final path = await useCase.exportToCSV();
      await _shareFile(path, 'Nutrition CSV logs exported successfully');
    } catch (e) {
      _showError('Failed to export nutrition CSV: $e');
    } finally {
      _endOp();
    }
  }

  Future<void> _exportNutritionJson() async {
    _startOp('Compiling nutrition JSON archive...');
    try {
      final useCase = ref.read(simpleJsonExportUseCaseProvider);
      final path = await useCase.exportNutritionToJSON();
      await _shareFile(path, 'Nutrition JSON exported successfully');
    } catch (e) {
      _showError('Failed to export nutrition JSON: $e');
    } finally {
      _endOp();
    }
  }

  Future<void> _exportMacroTrendsCsv() async {
    _startOp('Generating macro trends time-series report...');
    try {
      final useCase = ref.read(exportNutritionUseCaseProvider);
      final path = await useCase.exportMacroTrendsToCSV();
      await _shareFile(path, 'Macro trends report exported successfully');
    } catch (e) {
      _showError('Failed to generate macro trends: $e');
    } finally {
      _endOp();
    }
  }

  Future<void> _exportCompleteBackup() async {
    _startOp('Creating full system snapshot...');
    try {
      final useCase = ref.read(exportAllDataUseCaseProvider);
      final path = await useCase.exportToJSON();
      await _shareFile(path, 'Full system backup exported successfully');
    } catch (e) {
      _showError('Failed to export system backup: $e');
    } finally {
      _endOp();
    }
  }

  void _openRestoreModal(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final restoreUseCase = ref.read(restoreDataUseCaseProvider);

    showExportRestoreModal(
      context: context,
      restoreUseCase: restoreUseCase,
      onExecuteRestore: (jsonText, overwriteExisting) async {
        _startOp(
          'Restoring backup data (overwrite: $overwriteExisting)...',
        );
        try {
          final result = await restoreUseCase.restoreFromJsonString(
            jsonText,
            overwriteExisting: overwriteExisting,
          );

          if (result.success) {
            final counts = result.restoredCounts;
            final summary = [
              if (counts.containsKey('workouts'))
                '${counts['workouts']} workouts',
              if (counts.containsKey('nutrition_logs'))
                '${counts['nutrition_logs']} nutrition logs',
              if (counts.containsKey('body_measurements'))
                '${counts['body_measurements']} body entries',
              if (counts.containsKey('user_profile')) 'profile updated',
            ].join(', ');

            if (!mounted) return;
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(
                content: Text(
                  'Restoration complete: ${summary.isNotEmpty ? summary : "Success"}',
                ),
                backgroundColor: tokens.kineticAccent,
                duration: const Duration(seconds: 4),
              ),
            );
          } else {
            _showError(
              'Restoration failed: ${result.message}\n${result.errors.join("\n")}',
            );
          }
        } catch (e) {
          _showError('Restoration error: $e');
        } finally {
          _endOp();
          await _checkUndoAvailability();
        }
      },
    );
  }

  void _startOp(String msg) {
    setState(() {
      _isProcessing = true;
      _statusMessage = msg;
    });
  }

  void _endOp() {
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _statusMessage = null;
      });
    }
  }

  Future<void> _shareFile(String filePath, String successMsg) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            backgroundColor: AppThemeTokens.of(context).kineticAccent,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to share file: $e');
    }
  }

  Future<void> _confirmAndUndoRestore() async {
    final tokens = AppThemeTokens.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.panel,
        title: Text(
          'REVERT RESTORE OPERATION',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            color: tokens.warning,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will revert all database changes and restore the system state captured immediately before your last restore.\n\nAre you sure you want to proceed?',
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            color: tokens.textPrimary,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(color: tokens.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.warning,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('CONFIRM ROLLBACK'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _startOp('Rolling back database to pre-restore snapshot...');
    try {
      final restoreUseCase = ref.read(restoreDataUseCaseProvider);
      final result = await restoreUseCase.undoRestore();
      if (result.success) {
        await _checkUndoAvailability();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Successfully rolled back to pre-restore snapshot'),
            backgroundColor: tokens.kineticAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        _showError('Rollback failed: ${result.message}');
      }
    } catch (e) {
      _showError('Rollback error: $e');
    } finally {
      _endOp();
    }
  }

  void _showError(String error) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppThemeTokens.of(context).panel,
        title: Text(
          'EXPORT ERROR',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            color: AppThemeTokens.of(context).error,
          ),
        ),
        content: Text(
          error,
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            color: AppThemeTokens.of(context).textPrimary,
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
}
