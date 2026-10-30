import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_theme.dart';
import '../../domain/usecases/restore_data_use_case.dart';
import '../providers/settings_providers.dart';

/// Monolithic Sci-Fi screen for Telemetry Data Export & System Restore.
class ExportSettingsScreen extends ConsumerStatefulWidget {
  const ExportSettingsScreen({super.key});

  @override
  ConsumerState<ExportSettingsScreen> createState() => _ExportSettingsScreenState();
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
              'TELEMETRY DATA',
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
          _SectionHeader(title: 'RESTORE ARCHIVE', tokens: tokens),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                _ActionTile(
                  title: 'Restore From JSON Archive',
                  subtitle: 'Pre-validate backup schema, preview counts & choose merge/overwrite',
                  icon: Icons.restore_rounded,
                  accentColor: tokens.cyanAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : () => _showRestoreModal(context),
                ),
                if (_hasUndoSnapshot) ...[
                  Divider(color: tokens.borderSubtle, height: 1),
                  _ActionTile(
                    title: 'Undo Last Restore',
                    subtitle: 'Roll back database to state captured before the most recent restore',
                    icon: Icons.undo_rounded,
                    accentColor: tokens.warning,
                    tokens: tokens,
                    onTap: _isProcessing ? null : () => _confirmAndUndoRestore(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Complete Backup Section
          _SectionHeader(title: 'SYSTEM BACKUP', tokens: tokens),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                _ActionTile(
                  title: 'Export Full System Backup (JSON)',
                  subtitle: 'Complete encrypted snapshot of workouts, nutrition, body & biometrics',
                  icon: Icons.backup_rounded,
                  accentColor: tokens.kineticAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : () => _exportCompleteBackup(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Workouts Section
          _SectionHeader(title: 'WORKOUT TELEMETRY', tokens: tokens),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                _ActionTile(
                  title: 'Export Workouts (CSV)',
                  subtitle: 'Tabular format for Excel, Google Sheets, or data science analysis',
                  icon: Icons.table_chart_outlined,
                  accentColor: tokens.kineticAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : () => _exportWorkoutsCsv(),
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _ActionTile(
                  title: 'Export Workouts (JSON)',
                  subtitle: 'Normalized object hierarchy with set entries and timestamps',
                  icon: Icons.code_rounded,
                  accentColor: tokens.kineticAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : () => _exportWorkoutsJson(),
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _ActionTile(
                  title: 'Export Workout Summary Report (CSV)',
                  subtitle: 'Aggregated volume, frequency and monthly distribution stats',
                  icon: Icons.analytics_outlined,
                  accentColor: tokens.kineticAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : () => _exportWorkoutSummaryCsv(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Nutrition Section
          _SectionHeader(title: 'NUTRITION & MACROS', tokens: tokens),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                _ActionTile(
                  title: 'Export Nutrition Logs (CSV)',
                  subtitle: 'Daily records with itemized macros, micros and meal timing',
                  icon: Icons.table_chart_outlined,
                  accentColor: tokens.violetAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : () => _exportNutritionCsv(),
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _ActionTile(
                  title: 'Export Nutrition Logs (JSON)',
                  subtitle: 'Structured format including macro targets and micronutrients',
                  icon: Icons.code_rounded,
                  accentColor: tokens.violetAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : () => _exportNutritionJson(),
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _ActionTile(
                  title: 'Export Macro Trends Report (CSV)',
                  subtitle: 'Longitudinal time-series analysis of daily caloric & macro intake',
                  icon: Icons.timeline_rounded,
                  accentColor: tokens.violetAccent,
                  tokens: tokens,
                  onTap: _isProcessing ? null : () => _exportMacroTrendsCsv(),
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
                border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5), width: 1),
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
                      _statusMessage ?? 'Processing data...',
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

  // --- Export Actions ---

  Future<void> _exportWorkoutsCsv() async {
    _startOp('Compiling workout CSV file...');
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

  // --- Restore Actions & Modal ---

  void _showRestoreModal(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final jsonController = TextEditingController();
    BackupPreview? currentPreview;
    bool isValidating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: tokens.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final bottomInset = MediaQuery.of(modalCtx).viewInsets.bottom;

            void runValidation(String text) {
              final trimmed = text.trim();
              if (trimmed.isEmpty) {
                setModalState(() {
                  currentPreview = null;
                });
                return;
              }

              setModalState(() {
                isValidating = true;
              });

              final restoreUseCase = ref.read(restoreDataUseCaseProvider);
              final preview = restoreUseCase.getRestorePreviewFromJson(trimmed);

              setModalState(() {
                currentPreview = preview;
                isValidating = false;
              });
            }

            Future<void> loadLatestLocalBackup() async {
              setModalState(() => isValidating = true);
              try {
                final dir = await getApplicationDocumentsDirectory();
                final files = dir.listSync().whereType<File>().toList();
                files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

                final backupFile = files.cast<File?>().firstWhere(
                  (f) => f != null && f.path.contains('backup') && f.path.endsWith('.json'),
                  orElse: () => null,
                );

                if (backupFile == null) {
                  if (sheetContext.mounted) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      SnackBar(
                        content: const Text('No local backup file found in documents directory'),
                        backgroundColor: tokens.warning,
                      ),
                    );
                  }
                  setModalState(() => isValidating = false);
                  return;
                }

                final content = await backupFile.readAsString();
                jsonController.text = content;
                runValidation(content);
              } catch (e) {
                if (sheetContext.mounted) {
                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                    SnackBar(
                      content: Text('Error reading local file: $e'),
                      backgroundColor: tokens.error,
                    ),
                  );
                }
                setModalState(() => isValidating = false);
              }
            }

            Future<void> pasteFromClipboard() async {
              final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
              if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
                jsonController.text = clipboardData.text!;
                runValidation(clipboardData.text!);
              }
            }

            Future<void> executeRestore(bool overwriteExisting) async {
              final jsonText = jsonController.text.trim();
              if (jsonText.isEmpty) return;

              Navigator.of(sheetContext).pop();
              _startOp('Restoring system telemetry (overwrite: $overwriteExisting)...');

              try {
                final restoreUseCase = ref.read(restoreDataUseCaseProvider);
                final result = await restoreUseCase.restoreFromJsonString(
                  jsonText,
                  overwriteExisting: overwriteExisting,
                );

                if (result.success) {
                  final counts = result.restoredCounts;
                  final summary = [
                    if (counts.containsKey('workouts')) '${counts['workouts']} workouts',
                    if (counts.containsKey('nutrition_logs')) '${counts['nutrition_logs']} nutrition logs',
                    if (counts.containsKey('body_measurements')) '${counts['body_measurements']} body entries',
                    if (counts.containsKey('user_profile')) 'profile updated',
                  ].join(', ');

                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('Restoration complete: ${summary.isNotEmpty ? summary : "Success"}'),
                      backgroundColor: tokens.kineticAccent,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                } else {
                  _showError('Restoration failed: ${result.message}\n${result.errors.join("\n")}');
                }
              } catch (e) {
                _showError('Restoration error: $e');
              } finally {
                _endOp();
                await _checkUndoAvailability();
              }
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, bottomInset + 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      'SYSTEM RESTORATION PROTOCOL',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Validate incoming JSON archive before applying any changes.',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 12,
                        color: tokens.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: tokens.kineticAccent,
                              side: BorderSide(color: tokens.borderSubtle),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.paste_rounded, size: 16),
                            label: const Text('PASTE JSON', style: TextStyle(fontSize: 11)),
                            onPressed: pasteFromClipboard,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: tokens.cyanAccent,
                              side: BorderSide(color: tokens.borderSubtle),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.folder_open_rounded, size: 16),
                            label: const Text('LOAD LOCAL', style: TextStyle(fontSize: 11)),
                            onPressed: loadLatestLocalBackup,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: jsonController,
                      maxLines: 5,
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        hintText: 'Paste backup JSON string here...',
                        hintStyle: TextStyle(color: tokens.textMuted, fontSize: 11),
                        filled: true,
                        fillColor: tokens.panel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          borderSide: BorderSide(color: tokens.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          borderSide: BorderSide(color: tokens.borderSubtle),
                        ),
                      ),
                      onChanged: (text) => runValidation(text),
                    ),
                    const SizedBox(height: 14),

                    // Pre-validation preview card
                    if (isValidating)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(color: tokens.kineticAccent),
                        ),
                      )
                    else if (currentPreview != null) ...[
                      if (!currentPreview!.isValid) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tokens.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(tokens.radiusSm),
                            border: Border.all(color: tokens.error.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, color: tokens.error, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'INVALID BACKUP ARCHIVE: ${currentPreview!.error ?? currentPreview!.validationErrors.join(", ")}',
                                  style: TextStyle(
                                    fontFamily: AppTypography.bodyFontFamily,
                                    fontSize: 11,
                                    color: tokens.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tokens.card,
                            borderRadius: BorderRadius.circular(tokens.radiusSm),
                            border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.verified_rounded, color: tokens.kineticAccent, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'VALIDATED TELEMETRY ARCHIVE',
                                    style: TextStyle(
                                      fontFamily: AppTypography.displayFontFamily,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: tokens.kineticAccent,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'v${currentPreview!.exportVersion ?? "1.0"}',
                                    style: TextStyle(
                                      fontFamily: AppTypography.displayFontFamily,
                                      fontSize: 10,
                                      color: tokens.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 12,
                                runSpacing: 6,
                                children: [
                                  _PreviewTag(label: 'WORKOUTS', count: currentPreview!.workoutCount, tokens: tokens),
                                  _PreviewTag(label: 'NUTRITION DAYS', count: currentPreview!.nutritionCount, tokens: tokens),
                                  _PreviewTag(label: 'BODY ENTRIES', count: currentPreview!.bodyMeasurementCount, tokens: tokens),
                                  _PreviewTag(label: 'PROFILE', count: currentPreview!.hasUserProfile ? 1 : 0, tokens: tokens),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: tokens.kineticAccent,
                                  side: BorderSide(color: tokens.kineticAccent),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () => executeRestore(false),
                                child: Text(
                                  'MERGE DATA',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: tokens.error,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: modalCtx,
                                    builder: (confirmCtx) => AlertDialog(
                                      backgroundColor: tokens.panel,
                                      title: const Text('OVERWRITE ALL DATA?'),
                                      content: const Text(
                                        'This will clear existing local records and replace them with this backup archive.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(confirmCtx),
                                          child: const Text('CANCEL'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(confirmCtx);
                                            executeRestore(true);
                                          },
                                          child: Text('OVERWRITE', style: TextStyle(color: tokens.error)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Text(
                                  'OVERWRITE ALL',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Helper state methods ---

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
            content: const Text('Successfully rolled back to pre-restore snapshot'),
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
          'TELEMETRY FAULT',
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppThemeTokens tokens;

  const _SectionHeader({required this.title, required this.tokens});

  @override
  Widget build(BuildContext context) {
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
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final AppThemeTokens tokens;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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

class _PreviewTag extends StatelessWidget {
  final String label;
  final int count;
  final AppThemeTokens tokens;

  const _PreviewTag({required this.label, required this.count, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 10,
            color: tokens.textMuted,
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: tokens.textPrimary,
          ),
        ),
      ],
    );
  }
}